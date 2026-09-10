// Companion to share-target/sw.js: reads the pending shared item back out of
// IndexedDB (and clears it), converting the shared file to a data URL so the
// Dart side never has to deal with Blobs directly.
window.consumePendingSharedReceipt = async function () {
  function openDb() {
    return new Promise((resolve, reject) => {
      const req = indexedDB.open('family-biz-finance-share', 1);
      req.onupgradeneeded = () => {
        req.result.createObjectStore('shared');
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }

  let db;
  try {
    db = await openDb();
  } catch (e) {
    return null;
  }

  const item = await new Promise((resolve, reject) => {
    const tx = db.transaction('shared', 'readwrite');
    const store = tx.objectStore('shared');
    const getReq = store.get('latest');
    getReq.onsuccess = () => {
      const value = getReq.result;
      store.delete('latest');
      resolve(value || null);
    };
    getReq.onerror = () => reject(getReq.error);
  });
  db.close();

  if (!item) return null;

  let dataUrl = null;
  if (item.fileBlob) {
    dataUrl = await new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = () => reject(reader.error);
      reader.readAsDataURL(item.fileBlob);
    });
  }

  return {
    title: item.title || '',
    text: item.text || '',
    fileName: item.fileName || null,
    fileType: item.fileType || null,
    dataUrl: dataUrl,
  };
};
