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

import 'package:flutter/material.dart';
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

  /// create or update a finDoc type document (not shipment)
  /// with header and product items
  /// After add/update get the generated finDocId and productId's
  /// after finish save the input list.
  static Future<void> enterFinDocData(
      WidgetTester tester, List<FinDoc> finDocs) async {
    List<FinDoc> newFinDocs =
        []; // with invoiceId added (when new) and productId's
    for (final finDoc in finDocs) {
      // add or modify?
      if (finDoc.pseudoId == null) {
        await CommonTest.tapByKey(tester, 'addNew');
      } else {
        await CommonTest.doNewSearch(tester, searchString: finDoc.pseudoId!);
        expect(CommonTest.getTextField('topHeader').split('#')[1],
            finDoc.pseudoId);
      }
      await CommonTest.checkWidgetKey(tester,
          "FinDocDialog${finDoc.sales ? 'Sales' : 'Purchase'}${finDoc.docType!.toString()}");
      // enter supplier/customer
      await CommonTest.enterDropDownSearch(tester,
          finDoc.sales ? 'customer' : 'supplier', finDoc.otherCompany!.name!);
      if (finDoc.docType == FinDocType.order ||
          finDoc.docType == FinDocType.invoice)
        await CommonTest.enterText(tester, 'description', finDoc.description!);
      // delete existing findoc items
      await CommonTest.drag(tester, listViewName: 'listView');
      // delete any existing items
      while (tester.any(find.byKey(const Key("itemDelete0")))) {
        await CommonTest.tapByKey(tester, "itemDelete0", seconds: 2);
      }
      // add new items
      for (FinDocItem item in finDoc.items) {
        await CommonTest.tapByKey(tester, 'addProduct', seconds: 1);
        await CommonTest.checkWidgetKey(tester, 'addProductItemDialog');
        await CommonTest.enterDropDownSearch(
            tester, 'product', item.description!);
        await CommonTest.enterText(tester, 'itemPrice', item.price.toString());
        await CommonTest.enterText(
            tester, 'itemQuantity', item.quantity.toString());
        await CommonTest.drag(tester, listViewName: 'listView3');
        await CommonTest.tapByKey(tester, 'ok');
      }
      // get productId's
      await CommonTest.drag(tester, seconds: 2);
      List<FinDocItem> newItems = [];
      for (final (index, item) in finDoc.items.indexed) {
        newItems.add(item.copyWith(
            productId: CommonTest.getTextField('itemProductId$index')));
      }
      // update/create finDoc
      await CommonTest.tapByKey(tester, 'update', seconds: CommonTest.waitTime);
      await CommonTest.waitForSnackbarToGo(tester);
      // create new findoc with pseudoId when adding
      newFinDocs.add(finDoc.copyWith(
          pseudoId: finDoc.pseudoId != null
              ? finDoc.pseudoId
              : CommonTest.getTextField('id0'), // Id always added at the top
          items: newItems));
    }
    await FinDocTest.saveFinDocs(newFinDocs);
  }

  /// check the entered data of a finDoc, company and products
  static Future<void> checkFinDocDetail(
      WidgetTester tester, FinDocType docType) async {
    List<FinDoc> finDocs = await FinDocTest.getFinDocs(docType);
    for (final finDoc in finDocs) {
      await CommonTest.doNewSearch(tester, searchString: finDoc.pseudoId!);
      expect(
          CommonTest.getTextField('topHeader').split('#')[1], finDoc.pseudoId);
      await CommonTest.checkWidgetKey(tester,
          "FinDocDialog${finDoc.sales ? 'Sales' : 'Purchase'}${finDoc.docType!.toString()}");
      // check supplier/customer
      expect(
          CommonTest.getDropdownSearch(finDoc.sales ? 'customer' : 'supplier'),
          finDoc.otherCompany!.name!);
      if (finDoc.docType == FinDocType.order ||
          finDoc.docType == FinDocType.invoice)
        expect(CommonTest.getTextFormField('description'), finDoc.description!);
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

      // cancel the last record in te list when we have at least 2 records
      if (status == FinDocStatusVal.cancelled && oldFinDocs.length > 1) {
        // copy when not last record
        if (finDoc != oldFinDocs.lastOrNull) {
          newFinDocs.add(finDoc);
          continue;
        }
      }

      // change status
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
        expect(true, false,
            reason:
                'Begin status: ${CommonTest.getDropdown('statusDropDown')} not valid');
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

      if (status != FinDocStatusVal.cancelled) {
        // not add cancelled record
        if ((type == FinDocType.order && subType == FinDocType.payment)) {
          expect(await CommonTest.getRelatedFindoc(tester, FinDocType.order),
              finDoc.orderId);
          expect(await CommonTest.getRelatedFindoc(tester, FinDocType.invoice),
              finDoc.invoiceId);
        }
        if ((type == FinDocType.order && subType == FinDocType.invoice)) {
          expect(await CommonTest.getRelatedFindoc(tester, FinDocType.order),
              finDoc.orderId);
          expect(await CommonTest.getRelatedFindoc(tester, FinDocType.payment),
              finDoc.paymentId);
        }
        if ((type == FinDocType.order && subType == FinDocType.shipment)) {
          expect(await CommonTest.getRelatedFindoc(tester, FinDocType.order),
              finDoc.orderId);
        }
        if (type == FinDocType.invoice && subType == null) {
          String? paymentId =
              await CommonTest.getRelatedFindoc(tester, FinDocType.payment);
          newFinDocs.add(finDoc.copyWith(paymentId: paymentId));
        }
      }

      await CommonTest.tapByKey(tester, 'cancel');
    }
    await saveFinDocs(newFinDocs);
  }
}
