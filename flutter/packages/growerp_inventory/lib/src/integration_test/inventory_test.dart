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

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_core/test_data.dart';
import 'package:growerp_models/growerp_models.dart';

class InventoryTest {
  static Future<void> selectIncomingShipments(WidgetTester tester) async {
    await CommonTest.selectOption(
        tester, 'dbInventory', 'FinDocListShipmentsIn', '2');
  }

  static Future<void> selectOutgoingShipments(WidgetTester tester) async {
    await CommonTest.selectOption(
        tester, 'dbInventory', 'FinDocListShipmentsOut', '1');
  }

  static Future<void> selectWareHouseLocations(WidgetTester tester) async {
    await CommonTest.selectOption(
        tester, 'dbInventory', 'LocationListLocations', '3');
  }

  static Future<void> checkIncomingShipments(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> orders = test.orders;
    List<FinDoc> finDocs = [];
    for (FinDoc order in orders) {
      await CommonTest.doSearch(tester, searchString: order.orderId!);
      // save shipment id with order
      finDocs.add(order.copyWith(shipmentId: CommonTest.getTextField('id0')));
      // check list
      await CommonTest.tapByKey(tester, 'id0'); // open items
      expect(CommonTest.getTextField('itemLine0'),
          contains(order.items[0].product?.productId),
          reason: "checking productId");
      await CommonTest.tapByKey(tester, 'id0'); // close items
    }
    await PersistFunctions.persistTest(test.copyWith(orders: finDocs));
  }

  static Future<void> acceptShipmentInInventory(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> orders = test.orders;
    expect(orders.isNotEmpty, true,
        reason: 'This test needs orders created in previous steps');
    for (FinDoc order in orders) {
      await CommonTest.doSearch(tester, searchString: order.orderId!);
      await CommonTest.tapByKey(tester, 'nextStatus0',
          seconds: CommonTest.waitTime);
      await CommonTest.checkWidgetKey(tester, 'ShipmentReceiveDialogPurchase');
      await CommonTest.tapByKey(tester, 'update', seconds: CommonTest.waitTime);
      await CommonTest.tapByKey(tester, 'update', seconds: CommonTest.waitTime);
    }
  }

  static Future<void> sendOutGoingShipments(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> orders = test.orders;
    List<FinDoc> finDocs = [];
    expect(orders.isNotEmpty, true,
        reason: 'This test needs orders created in previous steps');
    for (FinDoc order in orders) {
      await CommonTest.doSearch(tester, searchString: order.orderId!);
      // save shipment id with order
      finDocs.add(order.copyWith(shipmentId: CommonTest.getTextField('id0')));
      await CommonTest.tapByKey(tester, 'nextStatus0',
          seconds: CommonTest.waitTime);
      await CommonTest.tapByKey(tester, 'nextStatus0',
          seconds: CommonTest.waitTime);
      expect(CommonTest.getTextField('status0'), equals('Completed'));
    }
    await PersistFunctions.persistTest(test.copyWith(orders: finDocs));
  }

  static Future<void> checkInventoryQOH(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> orders = test.orders;
    for (FinDoc order in orders) {
      await CommonTest.doSearch(tester, searchString: order.shipmentId!);
      expect(
          order.items[0].quantity.toString(), CommonTest.getTextField('qoh0'));
    }
  }

  static Future<void> checkInventory(WidgetTester tester) async {
    SaveTest test = await PersistFunctions.getTest();
    List<FinDoc> orders = test.orders;
    for (final order in orders) {
      for (final item in order.items) {
        // find asset for order product
        final asset = assets.firstWhere(
            // from test data
            (el) => el.product?.productName == item.description,
            orElse: () => Asset());
        expect(asset.location, isNotNull,
            reason:
                'Could not find product: ${item.description} in test data asset list');
        // find location (purchase order saved in receive shipments,
        // sales in asset list)
        await CommonTest.doNewSearch(tester,
            searchString: order.sales == false
                ? item.asset!.location!.locationName!
                : asset.location!.locationName!);
        late Decimal newQoh;
        if (order.sales == false) {
          newQoh = asset.quantityOnHand! + item.quantity!;
        } else {
          newQoh = asset.quantityOnHand! - item.quantity!;
        }
        expect(Decimal.parse(CommonTest.getTextFormField('qoh')), newQoh);
        await CommonTest.tapByKey(tester, 'cancel');
      }
    }
  }
}
