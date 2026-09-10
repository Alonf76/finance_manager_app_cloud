import 'shared_receipt_data.dart';
import 'shared_receipt_io.dart' if (dart.library.html) 'shared_receipt_web.dart' as impl;

export 'shared_receipt_data.dart';

/// Reads and clears any bill/receipt shared into the app via the installed
/// PWA's share target since the last check. Always null on non-web platforms.
Future<SharedReceiptData?> consumePendingSharedReceipt() => impl.consumePendingSharedReceipt();
