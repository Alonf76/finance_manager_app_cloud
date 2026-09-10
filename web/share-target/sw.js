// Dedicated service worker for the Web Share Target endpoint (/share-target/).
// Deliberately separate from Flutter's own generated service worker (scoped
// to "/"), so this never interferes with the app-shell caching/update logic.
//
// Android's share sheet POSTs the shared file/text here. Since Firebase
// Hosting is static (no server code can read a POST body), this worker
// intercepts the request itself, stashes the shared item in IndexedDB, and
// redirects into the app - which reads it back out on next load.

const DB_NAME = 'family-biz-finance-share';
const STORE_NAME = 'shared';

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

function openShareDb() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1);
    req.onupgradeneeded = () => {
      req.result.createObjectStore(STORE_NAME);
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

async function storeSharedItem(item) {
  const db = await openShareDb();
  await new Promise((resolve, reject) => {
    const tx = db.transaction(STORE_NAME, 'readwrite');
    tx.objectStore(STORE_NAME).put(item, 'latest');
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
  });
  db.close();
}

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'POST' || !url.pathname.startsWith('/share-target/')) {
    return;
  }

  event.respondWith((async () => {
    try {
      const formData = await event.request.formData();
      const file = formData.get('receipt');
      const item = {
        title: formData.get('title') || '',
        text: formData.get('text') || '',
        fileName: file ? file.name : null,
        fileType: file ? file.type : null,
        fileBlob: file || null,
        timestamp: Date.now(),
      };
      await storeSharedItem(item);
    } catch (e) {
      // If anything goes wrong, just fall through to opening the app normally.
    }
    return Response.redirect('/', 303);
  })());
});
