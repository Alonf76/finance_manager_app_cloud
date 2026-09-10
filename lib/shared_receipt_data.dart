import 'dart:typed_data';

/// A receipt/bill shared into the app from another app (photo gallery,
/// Gmail, WhatsApp, ...) via the installed PWA's share target.
class SharedReceiptData {
  final String title;
  final String text;
  final String? fileName;
  final Uint8List? bytes;

  const SharedReceiptData({
    required this.title,
    required this.text,
    this.fileName,
    this.bytes,
  });
}
