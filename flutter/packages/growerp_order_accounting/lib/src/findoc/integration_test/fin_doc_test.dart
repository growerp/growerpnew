/*
 * This software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'package:growerp_core/growerp_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growerp_models/growerp_models.dart';

class FinDocTest {
  static Future<List<FinDoc>> getFinDocs(FinDocType type) async {
    final test = await PersistFunctions.getTest();
    switch (type) {
      case FinDocType.order:
        return test.orders;
      case FinDocType.invoice:
        return test.invoices;
      case FinDocType.payment:
        return test.payments;
      case FinDocType.shipment:
        return test.shipments;
      case FinDocType.transaction:
        return test.transactions;
      default:
        return [];
    }
  }

  /// a function to save findocs in the test structure for later retrieval.
  /// all findoc types will overwrite the list already present
  /// except for transactions, these are added to the ones already there
  static Future<void> saveFinDocs(List<FinDoc> finDocs) async {
    if (finDocs.isEmpty) return;
    final test = await PersistFunctions.getTest();
    switch (finDocs[0].docType) {
      case FinDocType.order:
        await PersistFunctions.persistTest(test.copyWith(orders: finDocs));
        break;
      case FinDocType.invoice:
        await PersistFunctions.persistTest(test.copyWith(invoices: finDocs));
        break;

      case FinDocType.payment:
        await PersistFunctions.persistTest(test.copyWith(payments: finDocs));
        break;

      case FinDocType.shipment:
        await PersistFunctions.persistTest(test.copyWith(shipments: finDocs));
        break;

      case FinDocType.transaction: // add to existing transactions
        final totalTransactions = List.of(test.transactions);
        totalTransactions.addAll(finDocs);
        await PersistFunctions.persistTest(
            test.copyWith(transactions: totalTransactions));
        break;

      default:
    }
  }

  /// check if a finDoc is complete and copy the transaction numbers
  /// when it is a payment, invoice or shipment.
  static Future<void> checkFinDocsComplete(WidgetTester tester, FinDocType type,
      {FinDocType? subType}) async {
    List<FinDoc> oldFinDocs = await getFinDocs(type);
    List<FinDoc> newFinDocs = [];

    for (FinDoc finDoc in oldFinDocs) {
      // if provided approve related findoc
      String? id;
      switch (subType) {
        case FinDocType.order:
          id = finDoc.orderId;
        case FinDocType.invoice:
          id = finDoc.invoiceId;
        case FinDocType.payment:
          id = finDoc.paymentId;
        case FinDocType.shipment:
          id = finDoc.shipmentId;
        case FinDocType.transaction:
          id = finDoc.transactionId;
        default:
      }

      await CommonTest.doNewSearch(tester,
          searchString: id != null ? id : finDoc.pseudoId!);
      // open detail
      expect(CommonTest.getDropdown('statusDropDown'),
          FinDocStatusVal.completed.toString());

      // get transaction id's
      if (type == FinDocType.invoice || subType == FinDocType.invoice) {
        String? transactionId =
            await CommonTest.getRelatedFindoc(tester, FinDocType.transaction);
        expect(transactionId, isNot(equals(isNull)));
        newFinDocs.add(FinDoc(
            docType: FinDocType.transaction,
            transactionId: transactionId,
            invoiceId: finDoc.invoiceId,
            sales: true));
      }

      if (type == FinDocType.payment || subType == FinDocType.payment) {
        String? transactionId =
            await CommonTest.getRelatedFindoc(tester, FinDocType.transaction);
        expect(transactionId, isNot(equals(isNull)));
        newFinDocs.add(FinDoc(
            docType: FinDocType.transaction,
            transactionId: transactionId,
            paymentId: finDoc.paymentId,
            sales: true));
      }

      if (type == FinDocType.shipment || subType == FinDocType.shipment) {
        String? transactionId =
            await CommonTest.getRelatedFindoc(tester, FinDocType.transaction);
        expect(transactionId, isNot(equals(isNull)));
        newFinDocs.add(FinDoc(
            docType: FinDocType.transaction,
            transactionId: transactionId,
            shipmentId: finDoc.shipmentId,
            sales: true));
      }

      await CommonTest.tapByKey(tester, 'cancel');
    }
    await saveFinDocs(newFinDocs);
  }

  /// same as approve findocs with the difference to set the status to 'complete'
  static Future<void> completeFinDocs(WidgetTester tester, FinDocType type,
      {FinDocType? subType}) async {
    await changeStatusFinDocs(tester, type,
        subType: subType, status: FinDocStatusVal.completed);
  }

  /// cancel the last findoc in a list when more then a single record...
  static Future<void> cancelLastFinDoc(WidgetTester tester, FinDocType type,
      {FinDocType? subType}) async {
    await changeStatusFinDocs(tester, type,
        subType: subType, status: FinDocStatusVal.cancelled);
  }

  /// Change status of all findocs for a specific type, however when a sub type
  /// is provided the related findoc staus is changed.
  /// When changing status of finDocs 'order' related documents are created of which the id's
  /// are stored with the order findoc.
  /// The default is approve.
  /// when cancelled just the last record is cancelled when there are at 2 records
  static Future<void> changeStatusFinDocs(WidgetTester tester, FinDocType type,
      {FinDocType? subType,
      FinDocStatusVal status = FinDocStatusVal.approved}) async {
    List<FinDoc> oldFinDocs = await getFinDocs(type);
    List<FinDoc> newFinDocs = [];

    for (FinDoc finDoc in oldFinDocs) {
      // if subType provided approve related findoc
      String? id;
      switch (subType) {
        case FinDocType.order:
          id = finDoc.orderId;
        case FinDocType.invoice:
          id = finDoc.invoiceId;
        case FinDocType.payment:
          id = finDoc.paymentId;
        case FinDocType.shipment:
          id = finDoc.shipmentId;
        case FinDocType.transaction:
          id = finDoc.transactionId;
        default:
      }

      // cancel the last record in te list
      if (status == FinDocStatusVal.cancelled && oldFinDocs.length > 1) {
        // copy when not last record
        if (finDoc != oldFinDocs.lastOrNull) {
          newFinDocs.add(finDoc);
          continue;
        }
      }

      await CommonTest.doNewSearch(tester,
          searchString: id != null ? id : finDoc.pseudoId!,
          seconds: CommonTest.waitTime);
      // approve on detail screen
      if (CommonTest.getDropdown('statusDropDown') ==
              FinDocStatusVal.inPreparation.toString() ||
          CommonTest.getDropdown('statusDropDown') ==
              FinDocStatusVal.created.toString() ||
          status != FinDocStatusVal.approved) {
        await CommonTest.tapByKey(tester, 'statusDropDown');
        await CommonTest.tapByText(tester, status.name);
        await CommonTest.tapByKey(tester, 'update', seconds: 2);
        await CommonTest.waitForSnackbarToGo(tester);
      } else {
        expect(true, false, reason: 'Begin status not valid');
      }
      // get related document numbers just for order,
      // transactions are saved by check completed
      await CommonTest.doNewSearch(tester,
          searchString: id != null ? id : finDoc.pseudoId!);
      // get order related documents
      if (type == FinDocType.order && subType == null) {
        String? paymentId =
            await CommonTest.getRelatedFindoc(tester, FinDocType.payment);
        String? invoiceId =
            await CommonTest.getRelatedFindoc(tester, FinDocType.invoice);
        String? shipmentId =
            await CommonTest.getRelatedFindoc(tester, FinDocType.shipment);
        newFinDocs.add(finDoc.copyWith(
            paymentId: paymentId,
            invoiceId: invoiceId,
            shipmentId: shipmentId));
      }
      if ((type == FinDocType.order && subType == FinDocType.payment)) {
        expect(await CommonTest.getRelatedFindoc(tester, FinDocType.order),
            finDoc.orderId);
        expect(await CommonTest.getRelatedFindoc(tester, FinDocType.invoice),
            finDoc.invoiceId);
      }
      if ((type == FinDocType.order && subType == FinDocType.invoice) ||
          type == FinDocType.invoice && subType == null) {
        if (type == FinDocType.order) {
          expect(await CommonTest.getRelatedFindoc(tester, FinDocType.order),
              finDoc.orderId);
        }
        expect(await CommonTest.getRelatedFindoc(tester, FinDocType.payment),
            finDoc.paymentId);
      }
      if ((type == FinDocType.order && subType == FinDocType.shipment)) {
        expect(await CommonTest.getRelatedFindoc(tester, FinDocType.order),
            finDoc.orderId);
      }
      await CommonTest.tapByKey(tester, 'cancel');
    }
    await saveFinDocs(newFinDocs);
  }

  static Future<void> checkFinDocDetail(
      WidgetTester tester, FinDocType docType) async {
    List<FinDoc> finDocs = await FinDocTest.getFinDocs(docType);
    for (final finDoc in finDocs) {
      await CommonTest.doNewSearch(tester, searchString: finDoc.pseudoId!);
      for (final (index, item) in finDoc.items.indexed) {
        expect(CommonTest.getTextField('itemProductId$index'), item.productId!);
        expect(CommonTest.getTextField('itemDescription$index'),
            item.description!);
        expect(
            CommonTest.getTextField('itemPrice$index'), item.price.currency());
        if (!CommonTest.isPhone())
          expect(CommonTest.getTextField('itemQuantity$index'),
              item.quantity.toString());
        await CommonTest.tapByKey(tester, 'cancel'); // cancel dialog
      }
    }
  }
}
