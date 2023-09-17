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

class TransactionTest {
  static Future<void> selectTransactions(WidgetTester tester) async {
    await CommonTest.selectOption(tester, 'dbAccounting', 'AcctDashBoard');
    await CommonTest.selectOption(
        tester, 'acctLedger', 'FinDocListFormTransaction', '3');
  }

  static Future<void> checkTransactionComplete(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> finDocs = test.orders.isNotEmpty
        ? test.orders
        : test.transactions.isNotEmpty
            ? test.transactions
            : test.payments;
    for (FinDoc finDoc in finDocs) {
      await CommonTest.doSearch(tester, searchString: finDoc.chainId()!);
      await tester.pumpAndSettle();
      expect(CommonTest.getTextField('status0'), 'Y',
          reason: 'transaction status field check');
    }
  }

  static Future<void> addTransactions(
      WidgetTester tester, List<FinDoc> transactions,
      {bool check = true}) async {
    SaveTest test = await PersistFunctions.getTest();
    // test = test.copyWith(transactions: []); //======= remove
    // await PersistFunctions.persistTest(test); //=====remove
    if (test.transactions.isEmpty) {
      await PersistFunctions.persistTest(test.copyWith(
          transactions: await enterTransactionData(tester, transactions)));
    }
    if (check) {
      test = await PersistFunctions.getTest();
      await checkTransaction(tester, test.transactions);
    }
  }

  static Future<void> updateTransactions(
      WidgetTester tester, List<FinDoc> transactions) async {
    SaveTest test = await PersistFunctions.getTest();
    if (test.transactions[0].description != transactions[0].description) {
      // copy transactionId
      for (int x = 0; x < transactions.length; x++) {
        transactions[x] = transactions[x]
            .copyWith(transactionId: test.transactions[x].transactionId);
      }
      test = test.copyWith(
          transactions: await enterTransactionData(tester, transactions));
      await PersistFunctions.persistTest(test);
    }
    await checkTransaction(tester, test.transactions);
  }

/*
  static Future<void> deleteLastTransaction(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    var count = CommonTest.getWidgetCountByKey(tester, 'finDocItem');
    if (count == test.transactions.length) {
      await CommonTest.tapByKey(tester, 'edit${count - 1}');
      await CommonTest.tapByKey(tester, 'cancelFinDoc', seconds: 5);
      // refresh not work in test
      //await CommonTest.refresh(tester);
      //expect(find.byKey(Key('finDocItem')), findsNWidgets(count - 1));
      await PersistFunctions.persistTest(test.copyWith(
          payments:
              test.transactions.sublist(0, test.transactions.length - 1)));
    }
  }
*/
  static Future<List<FinDoc>> enterTransactionData(
      WidgetTester tester, List<FinDoc> transactions) async {
    int index = 0;
    List<FinDoc> newTransactions = []; // with transactionId added
    for (FinDoc transaction in transactions) {
      if (transaction.transactionId == null) {
        await CommonTest.tapByKey(tester, 'addNew');
      } else {
        await CommonTest.doSearch(tester,
            searchString: transaction.transactionId!);
        await CommonTest.tapByKey(tester, 'edit0');
        expect(CommonTest.getTextField('topHeader').split('#')[1],
            transaction.transactionId);
      }
      await CommonTest.checkWidgetKey(tester, "FinDocDialogSalesTransaction");
      await CommonTest.enterText(
          tester, 'description', transaction.description!);
      if (transaction.isPosted!) {
        await CommonTest.tapByKey(tester, 'isPosted');
      }
      // delete existing transaction items
      SaveTest test = await PersistFunctions.getTest();
      if (test.transactions.isNotEmpty &&
          test.transactions[index].items.isNotEmpty) {
        await CommonTest.drag(tester, listViewName: 'listView1');
        for (int x = 0; x < test.transactions[index].items.length; x++) {
          await CommonTest.tapByKey(tester, 'delete0');
        }
      }
      // items
      for (FinDocItem item in transaction.items) {
        await CommonTest.tapByKey(tester, 'addItem', seconds: 1);
        await CommonTest.checkWidgetKey(tester, 'addTransactionItemDialog');
        await CommonTest.enterDropDownSearch(
            tester, 'glAccount', item.glAccount!.accountCode!);
        await CommonTest.tapByKey(tester, item.isDebit! ? 'debit' : 'credit');
        await CommonTest.enterText(tester, 'price', item.price.toString());
        await CommonTest.tapByKey(tester, 'ok');
      }
      await CommonTest.drag(tester, seconds: 2);
      await CommonTest.tapByKey(tester, 'update');
      await CommonTest.waitForKey(tester, 'dismiss');
      await CommonTest.waitForSnackbarToGo(tester);
      // create new findoc with transactionId
      newTransactions.add(
          transaction.copyWith(transactionId: CommonTest.getTextField('id0')));
      await CommonTest.tapByKey(tester, 'edit0'); //open detail
      expect(transaction.description, CommonTest.getTextField('description'));
      expect(transaction.isPosted, CommonTest.getRadio('isPosted'));
      for (int x = 0; x < transaction.items.length; x++) {
        expect(transaction.items[x].glAccount!.accountCode!,
            CommonTest.getTextField('accountCode$x'));
        expect(
            transaction.items[x].price!.toString(),
            CommonTest.getTextField(
                "${transaction.items[x].isDebit! ? 'debit' : 'credit'}$x"));
      }
      await CommonTest.tapByKey(tester, 'cancel'); // close detail
      await tester.pumpAndSettle(); // for the message to disappear
      index++;
    }
    await CommonTest.closeSearch(tester);
    return newTransactions;
  }

  static Future<void> checkTransaction(
      WidgetTester tester, List<FinDoc> transactions) async {
    for (FinDoc transaction in transactions) {
      await CommonTest.doSearch(tester,
          searchString: transaction.transactionId!);
      expect(CommonTest.getTextField('grandTotal0'),
          equals(transaction.grandTotal.toString()));
      await CommonTest.tapByKey(tester, 'edit0'); //open detail
      expect(transaction.description, CommonTest.getTextField('description'));
      expect(transaction.isPosted, CommonTest.getRadio('isPosted'));
      for (int x = 0; x < transaction.items.length; x++) {
        expect(transaction.items[x].glAccount!.accountCode!,
            CommonTest.getTextField('accountCode$x'));
        expect(
            transaction.items[x].price!.toString(),
            CommonTest.getTextField(
                "${transaction.items[x].isDebit! ? 'debit' : 'credit'}$x"));
      }
      await CommonTest.tapByKey(tester, 'cancel'); // close detail
      await tester.pumpAndSettle(); // for the message to disappear
    }
    await CommonTest.closeSearch(tester);
  }

  static Future<void> postTransactions(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    for (FinDoc transaction in test.transactions) {
      await CommonTest.doSearch(tester,
          searchString: transaction.transactionId!);
      if (CommonTest.getTextField('isPosted') == 'N') {
        await CommonTest.tapByKey(tester, 'ispost0', seconds: 5);
      }
      if (CommonTest.getTextField('status0') ==
          finDocStatusValues[FinDocStatusVal.created.toString()]) {
        await CommonTest.tapByKey(tester, 'nextStatus0', seconds: 5);
      }
      await CommonTest.checkText(tester, 'Approved');
    }
  }

  /// check if the purchase process has been completed successfuly
  static Future<void> checkTransactionsComplete(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> transactions = test.orders.isNotEmpty
        ? test.orders
        : test.transactions.isNotEmpty
            ? test.transactions
            : test.payments;
    for (FinDoc transaction in transactions) {
      await CommonTest.doSearch(tester,
          searchString: transaction.transactionId!);
      expect(CommonTest.getTextField('status0'), 'completed');
    }
  }
}
