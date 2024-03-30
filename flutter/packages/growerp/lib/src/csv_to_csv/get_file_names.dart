import 'package:logger/logger.dart';
import 'file_type_model.dart';
import '../logger.dart';

var logger = Logger(filter: MyFilter());

/// specify filenames here, * allowed for names with the same starting characters
///

List<String> getFileNames(FileType fileType) {
  List<String> searchFiles = [];
  switch (fileType) {
    case FileType.itemType:
      searchFiles.add('itemType.csv');
      break;
    case FileType.paymentType:
      searchFiles.add('paymentType.csv');
      break;
    case FileType.glAccount:
    case FileType.company:
    case FileType.finDocOrderPurchase:
    case FileType.finDocOrderPurchaseItem:
    case FileType.finDocInvoicePurchase:
    case FileType.finDocInvoicePurchaseItem:
    case FileType.finDocPaymentPurchase:
    case FileType.finDocPaymentPurchaseItem:
    case FileType.finDocOrderSale:
    case FileType.finDocOrderSaleItem:
    case FileType.finDocInvoiceSale:
    case FileType.finDocInvoiceSaleItem:
    case FileType.finDocPaymentSale:
    case FileType.finDocPaymentSaleItem:
    case FileType.product:
    case FileType.user:
    case FileType.finDocTransaction:
    case FileType.finDocTransactionItem:
      searchFiles.add('general_ledger_2022Q3.ods');
      break;
    case FileType.category:
    case FileType.asset:
    case FileType.website:
    default:
      logger.w("No files found for fileType: ${fileType.name}");
  }
  return searchFiles;
}
