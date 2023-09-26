import 'dart:async';

import 'package:growerp_models/growerp_models.dart';

import '../../common/functions/helper_functions.dart';
import 'package:flutter/material.dart';
import '../../../services/chat_server.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domains.dart';

class ChatDialog extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDialog(this.chatRoom, {super.key});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<ChatDialog> {
  final _scrollController = ScrollController();
  final double _scrollThreshold = 200.0;
  late ChatMessageBloc _chatMessageBloc;
  late Authenticate authenticate;
  late ChatServer? chat;
  int limit = 20;
  late bool search;
  String? searchString;
  List<ChatMessage> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    _chatMessageBloc = context.read<ChatMessageBloc>()
      ..add(ChatMessageFetch(
          chatRoomId: widget.chatRoom.chatRoomId, limit: limit));
    Timer(
      const Duration(seconds: 1),
      () => _scrollController.jumpTo(0.0),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chat = context.read<ChatServer>();
    if (chat == null) return (const Center(child: Text("chat not active!")));
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state.status == AuthStatus.authenticated) {
        authenticate = state.authenticate!;
      }
      return BlocConsumer<ChatMessageBloc, ChatMessageState>(
          listener: ((context, state) {
        if (state.status == ChatMessageStatus.failure) {
          HelperFunctions.showMessage(context, '${state.message}', Colors.red);
        }
      }), builder: (context, state) {
        if (state.status == ChatMessageStatus.success ||
            state.status == ChatMessageStatus.failure) {
          messages = state.chatMessages;
          return Container(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: GestureDetector(
                      onTap: () {},
                      child: Dialog(
                        key: const Key('ChatDialog'),
                        insetPadding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:
                            Stack(clipBehavior: Clip.none, children: <Widget>[
                          Container(
                              padding: const EdgeInsets.all(20),
                              width: 500,
                              height: 600,
                              child: Scaffold(
                                backgroundColor: Colors.transparent,
                                body: chatPage(context),
                              )),
                          const Positioned(
                              top: 5, right: 5, child: DialogCloseButton())
                        ]),
                      ))));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      });
    });
  }

  Widget chatPage(BuildContext context) {
    return Column(children: [
      Center(
          child: Text("To: ${widget.chatRoom.chatRoomName} "
              "#${widget.chatRoom.chatRoomId}")),
      Expanded(
          child: RefreshIndicator(
              onRefresh: (() async => context
                  .read<ChatRoomBloc>()
                  .add(ChatRoomFetch(refresh: true, limit: limit))),
              child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  key: const Key('listView'),
                  reverse: true,
                  itemCount: messages.length,
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                            alignment: (messages[index].fromUserId ==
                                    authenticate.user!.userId
                                ? Alignment.topLeft
                                : Alignment.topRight),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: (messages[index].fromUserId ==
                                          authenticate.user!.userId
                                      ? Colors.grey.shade200
                                      : Colors.blue[200]),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  messages[index].content ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ))));
                  }))),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
            child: TextField(
          key: const Key('messageContent'),
          autofocus: true,
          controller: messageController,
          decoration: const InputDecoration(labelText: 'Message text..'),
        )),
        const SizedBox(
          width: 16,
        ),
        ElevatedButton(
            key: const Key('send'),
            child: const Text('Send'),
            onPressed: () {
              _chatMessageBloc.add(ChatMessageSendWs(WsChatMessage(
                  toUserId:
                      widget.chatRoom.getToUserId(authenticate.user!.userId!),
                  fromUserId: authenticate.user!.userId!,
                  chatRoomId: widget.chatRoom.chatRoomId,
                  content: messageController.text)));
              messageController.text = '';
              Timer(
                const Duration(seconds: 1),
                () => _scrollController.jumpTo(0.0),
              );
            })
      ])
    ]);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll > 0 && maxScroll - currentScroll <= _scrollThreshold) {
      _chatMessageBloc.add(ChatMessageFetch(
          chatRoomId: widget.chatRoom.chatRoomId,
          limit: limit,
          searchString: searchString ?? ''));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
