import 'package:admin/menuOption_data.dart';
import 'package:growerp_core/domains/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:integration_test/integration_test.dart';
import 'package:admin/router.dart' as router;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
  });

  // not implemented yet, use integration_test/chat_test.dart and lib/chatEcho_main.dart
  testWidgets('''GrowERP chat test''', (tester) async {
    await CommonTest.startTestApp(tester, router.generateRoute, menuOptions,
        clear: true); // use data from previous run, ifnone same as true
    await CompanyTest.createCompany(tester);
    await UserTest.selectAdministrators(tester);
    await UserTest.addAdministrators(tester, [administrators[0]], check: false);
    await ChatTest.selectChatRoom(tester);
    await ChatTest.addRooms(tester, chatRooms);
    await ChatTest.updateRooms(tester);
    await ChatTest.deleteRooms(tester);
    // needchat echo running
//    await ChatTest.sendDirectMessage(tester);
//    await ChatTest.sendRoomMessage(tester);
  });
}
