import 'dart:convert';
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'shared_receipt_data.dart';

/// Calls window.consumePendingSharedReceipt() (web/share_bridge.js), which
/// reads and clears the item the share-target service worker stashed in
/// IndexedDB, if any.
Future<SharedReceiptData?> consumePendingSharedReceipt() async {
  try {
    final fn = js_util.getProperty(js_util.globalThis, 'consumePendingSharedReceipt');
    if (fn == null) return null;

    final promise = js_util.callMethod(js_util.globalThis, 'consumePendingSharedReceipt', []);
    final result = await js_util.promiseToFuture<Object?>(promise);
    if (result == null) return null;

    final title = js_util.getProperty(result, 'title') as String? ?? '';
    final text = js_util.getProperty(result, 'text') as String? ?? '';
    final fileName = js_util.getProperty(result, 'fileName') as String?;
    final dataUrl = js_util.getProperty(result, 'dataUrl') as String?;

    Uint8List? bytes;
    if (dataUrl != null) {
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex != -1) {
        bytes = base64Decode(dataUrl.substring(commaIndex + 1));
      }
    }

    if (title.isEmpty && text.isEmpty && bytes == null) return null;

    return SharedReceiptData(title: title, text: text, fileName: fileName, bytes: bytes);
  } catch (_) {
    return null;
  }
}
