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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_models/growerp_models.dart';
import '../../growerp_core.dart';

class DisplayMenuOption extends StatefulWidget {
  final MenuOption? menuOption; // display not an item from the list like chat
  final List<MenuOption> menuList; // menu list to be used
  final int menuIndex; // navigator rail menu selected
  final int? tabIndex; // tab selected, if none create new
  final TabItem? tabItem; // create new tab if tabIndex null
  final List<Widget> actions; // actions at the appBar
  final Task? workflow;
  const DisplayMenuOption({
    super.key,
    this.menuOption,
    required this.menuList,
    required this.menuIndex,
    this.tabIndex,
    this.tabItem,
    this.actions = const [],
    this.workflow,
  });

  @override
  MenuOptionState createState() => MenuOptionState();
}

class MenuOptionState extends State<DisplayMenuOption>
    with SingleTickerProviderStateMixin {
  late int tabIndex;
  List<TabItem> tabItems = [];
  late String title;
  List<Widget> actions = [];
  Widget? leadAction;
  Widget? child;
  List<Widget> tabList = [];
  List<Widget> tabText = [];
  Map<int, FloatingActionButton> floatingActionButtonList = {};
  FloatingActionButton? floatingActionButton;
  List<BottomNavigationBarItem> bottomItems = [];
  TabController? _controller;
  late String displayMOFormKey;
  late String currentRoute = '';
  late bool isPhone;
  late TaskBloc taskBloc;
  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    if (widget.workflow != null) {
      taskBloc = context.read<TaskBloc>();
    }
    MenuOption menuOption =
        widget.menuOption ?? widget.menuList[widget.menuIndex];
    tabItems = menuOption.tabItems ?? [];
    title = menuOption.title;
    child = menuOption.child;
    tabIndex = widget.tabIndex ?? 0;
    if (tabItems.isEmpty) {
      displayMOFormKey =
          child.toString().replaceAll(RegExp(r'[^(a-z,A-Z)]'), '');
      // debugPrint("==1== current form key: $displayMOFormKey");
    }
    for (var i = 0; i < tabItems.length; i++) {
      // form key for testing
      displayMOFormKey =
          tabItems[i].form.toString().replaceAll(RegExp(r'[^(a-z,A-Z)]'), '');
      // debugPrint("==1== current form key: $displayMOFormKey");
      // form to display
      tabList.add(tabItems[i].form);
      // text of tabs at top of screen (tablet, web)
      tabText.add(Align(
          alignment: Alignment.center,
          child: Text(tabItems[i].label, key: Key('tap$displayMOFormKey'))));
      // tabs at bottom of screen : phone
      bottomItems.add(BottomNavigationBarItem(
          icon: tabItems[i].icon,
          label: tabItems[i].label.replaceAll('\n', ' '),
          tooltip: (i + 1).toString()));
      // floating actionbutton at each tab; not work with domain org
      if (tabItems[i].floatButtonRoute != null) {
        floatingActionButtonList[i] = FloatingActionButton(
            key: const Key("addNew"),
            onPressed: () async {
              await Navigator.pushNamed(
                  context, tabItems[tabIndex].floatButtonRoute!,
                  arguments: tabItems[tabIndex].floatButtonArgs);
            },
            tooltip: 'Add New',
            child: const Icon(Icons.add));
      }
      if (tabItems[i].floatButtonForm != null) {
        floatingActionButtonList[i] = FloatingActionButton(
            key: const Key("addNew"),
            onPressed: () async {
              await showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return tabItems[i].floatButtonForm!;
                  });
            },
            tooltip: 'Add New',
            child: const Icon(Icons.add));
      }
    }

    _controller = TabController(
      length: tabList.length,
      vsync: this,
      initialIndex: widget.tabIndex ?? 0,
    );
    _controller!.addListener(() {
      setState(() {
        tabIndex = _controller!.index;
      });
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    isPhone = isAPhone(context);
    actions = List.of(widget.actions);
    actions.insert(
        0,
        IconButton(
            key: const Key('chatButton'), // causes a duplicate key?
            icon: const Icon(Icons.chat),
            padding: EdgeInsets.zero,
            tooltip: 'Chat',
            onPressed: () async => {
                  await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return const ChatRoomListDialog();
                    },
                  )
                }));
    if (currentRoute != '/' && widget.workflow == null) {
      actions.add(IconButton(
          key: const Key('homeButton'),
          icon: const Icon(Icons.home),
          tooltip: 'Go Home',
          onPressed: () {
            if (currentRoute.startsWith('/acct')) {
              Navigator.pushNamed(context, '/accounting');
            } else {
              Navigator.pushNamed(context, '/');
            }
          }));
    }

    Widget workflowBar = SizedBox(
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
/*          ElevatedButton(
            child: const Text('Previous'),
            onPressed: () {
              taskBloc.add(TaskWorkflowPrevious(widget.workflow!.taskId));
            },
          ),
*/
      ElevatedButton(
        child: const Text('Cancel'),
        onPressed: () {
          taskBloc.add(TaskWorkflowCancel(widget.workflow!.taskId));
        },
      ),
/*          ElevatedButton(
            child: const Text('Suspend'),
            onPressed: () {
              taskBloc.add(TaskWorkflowSuspend(widget.workflow!.taskId));
            },
          ),
*/
      const SizedBox(width: 10),
      ElevatedButton(
        child: const Text('Next'),
        onPressed: () {
          taskBloc.add(TaskWorkflowNext(widget.workflow!.taskId));
        },
      ),
    ]));

    Widget simplePage(bool isPhone) {
      displayMOFormKey =
          child.toString().replaceAll(RegExp(r'[^(a-z,A-Z)]'), '');
      // debugPrint("==2-simple= current form key: $displayMOFormKey");

      List<Widget> simpleChildren = [Expanded(child: child!)];
      if (widget.workflow != null) {
        simpleChildren.insert(0, workflowBar);
      }

      return Scaffold(
          key: Key(currentRoute),
          appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              key: Key(displayMOFormKey),
              automaticallyImplyLeading: isPhone,
              leading: leadAction,
              title: appBarTitle(context, title, isPhone),
              actions: actions),
          drawer: myDrawer(context, isPhone, widget.menuList),
          floatingActionButton: floatingActionButton,
          body: Column(children: simpleChildren));
    }

    Widget tabPage(bool isPhone) {
      displayMOFormKey =
          tabList[tabIndex].toString().replaceAll(RegExp(r'[^(a-z,A-Z)]'), '');
      Color tabSelectedBackground = Theme.of(context).colorScheme.onSecondary;
      //debugPrint("==3-tab= current form key: $displayMOFormKey");
      List<Widget> tabChildren = [
        Expanded(
            child: isPhone
                ? Center(key: Key(displayMOFormKey), child: tabList[tabIndex])
                : TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    key: Key(displayMOFormKey),
                    controller: _controller,
                    children: tabList,
                  ))
      ];
      if (widget.workflow != null) {
        tabChildren.insert(0, workflowBar);
      }

      return Scaffold(
          key: Key(currentRoute),
          appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              automaticallyImplyLeading: isPhone,
              bottom: isPhone
                  ? null
                  : TabBar(
                      controller: _controller,
                      labelPadding: const EdgeInsets.all(5.0),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        color: tabSelectedBackground,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      tabs: tabText,
                    ),
              title: appBarTitle(
                  context,
                  '$title ${isPhone ? '\n' : ', '}${tabItems[tabIndex].label}',
                  isPhone),
              actions: actions),
          drawer: myDrawer(context, isPhone, widget.menuList),
          floatingActionButton: floatingActionButtonList[tabIndex],
          bottomNavigationBar: isPhone
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: bottomItems,
                  currentIndex: tabIndex,
                  selectedItemColor: Colors.amber[800],
                  onTap: (index) {
                    setState(() {
                      tabIndex = index;
                    });
                  })
              : null,
          body: Column(children: tabChildren));
    }

    if (tabItems.isEmpty) {
      // show simple page
      if (isPhone) {
        return simplePage(isPhone);
      } else {
        return myNavigationRail(
          context,
          simplePage(isPhone),
          widget.menuIndex,
          widget.menuList,
        );
      }
    } else {
      // show tabbar page
      if (isPhone) {
        return tabPage(isPhone);
      } else {
        return myNavigationRail(
          context,
          tabPage(isPhone),
          widget.menuIndex,
          widget.menuList,
        );
      }
    }
  }
}
