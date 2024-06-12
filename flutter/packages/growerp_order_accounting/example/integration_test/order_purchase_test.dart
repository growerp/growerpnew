/*
 * This GrowERP software is in the puuttolic domain under CC0 1.0 Universal plus a
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

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:growerp_inventory/growerp_inventory.dart';
import 'package:integration_test/integration_test.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_order_accounting/growerp_order_accounting.dart';
import 'package:order_accounting_example/main.dart' as router;
import 'package:order_accounting_example/main.dart';
import 'package:growerp_core/test_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:growerp_models/growerp_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    await Hive.initFlutter();
  });

  testWidgets('''GrowERP Order Purchase test''', (tester) async {
    RestClient restClient = RestClient(await buildDioClient());
    await CommonTest.startTestApp(
        tester,
        router.generateRoute,
        menuOptions,
        const [
          OrderAccountingLocalizations.delegate,
          InventoryLocalizations.delegate
        ],
        restClient: restClient,
        blocProviders:
            getOrderAccountingBlocProvidersExample(restClient, 'AppAdmin'),
        title: "Order Purchase Test",
        clear: true); // use data from previous run, ifnone same as true

    await CommonTest.createCompanyAndAdmin(tester, testData: {
      "categories": categories.sublist(0, 2),
      "products": products.sublist(0, 2),
      "users": suppliers.sublist(0, 2),
      "locations": locations,
    });

    await OrderTest.selectPurchaseOrders(tester);
    await OrderTest.addOrders(tester, purchaseOrders.sublist(0, 1));
    await OrderTest.updateOrders(tester, purchaseOrders.sublist(1, 2));
    await OrderTest.deleteLastOrder(tester);
    await OrderTest.approveOrders(tester);
    await PaymentTest.selectPurchasePayments(tester);
    await OrderTest.approvePayments(tester);
    await OrderTest.checkOrderPaymentsComplete(tester);
    await InvoiceTest.selectPurchaseInvoices(tester);
    await OrderTest.checkInvoicesComplete(tester);
    await ShipmentTest.selectIncomingShipments(tester);
    await OrderTest.approveShipments(tester);
    await ShipmentTest.receiveShipments(tester, locations);
    await OrderTest.checkShipmentsComplete(tester);
    await OrderTest.selectInventory(tester);
    await InventoryTest.checkInventory(tester);
    await OrderTest.selectPurchaseOrders(tester);
    await OrderTest.checkOrdersComplete(tester);
    await TransactionTest.selectTransactions(tester);
    await TransactionTest.checkTransactionsComplete(tester);
  });
}
