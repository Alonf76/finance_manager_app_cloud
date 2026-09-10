import 'shared_receipt_data.dart';

/// Non-web platforms have no share-target bridge; always nothing pending.
Future<SharedReceiptData?> consumePendingSharedReceipt() async => null;
