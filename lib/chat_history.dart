import 'package:fe/classes/get_chat_class.dart';

import './api.dart';
import 'package:provider/provider.dart';
import "./auth_provider.dart";
import 'package:flutter/material.dart';

class ChatHistory extends StatefulWidget {
  final String rideId;
  final String driverUsername;
  final String driverImgUrl;
  const ChatHistory(
      {super.key,
      required this.rideId,
      required this.driverUsername,
      required this.driverImgUrl});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final _msgTextController = TextEditingController();
  List<Chat> rideChats = [];

  @override
  void initState() {
    super.initState();
    final currUser = context.read<AuthState>().userInfo;
    _getRideChats(currUser);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _postMessage(message, chatId, username) async {
    await postMessage(message, chatId);
    await fetchMessagesByRideId(chatId, username);
    // setState((){
    //   _chats = futureRideChats;
    // });
  }

  Future<void> _getRideChats(currUser) async {
    List<Chat> futureRideChats =
        await fetchMessagesByRideId(widget.rideId, currUser.username);
    setState(() {
      rideChats = futureRideChats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<AuthState>().userInfo;
    final riderImgUrl =
        "http://localhost:1337/users/${userData.username}/image";
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Form(
                  child: TextFormField(
                    controller: _msgTextController,
                    decoration: InputDecoration(
                        labelText: "Message to '${widget.driverUsername}'",
                        hintText: "Type your message here..."),
                  ),
                ),
              ),
              FilledButton(
                  onPressed: () {
                    final message = {
                      "from": userData.username,
                      "to": widget.driverUsername,
                      "message": _msgTextController.text
                    };
                    _postMessage(message, widget.rideId, userData.username);
                  },
                  child: const Text('Send'))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      const Text('Driver'),
                      const SizedBox(
                        height: 20,
                      ),
                      userCard(
                          widget.driverUsername, widget.driverImgUrl, true),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: Column(
                    children: [
                      const Text(
                        'Rider',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      userCard(userData.username, riderImgUrl, false),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              for (var chat in rideChats) messageCard(chat, userData.username),
            ],
          )
        ],
      ),
    );
  }
}

userCard(username, imgUrl, isDriver) {
  return Row(
    children: [
      Expanded(
        child: Center(
          child: Text(username),
        ),
      ),
      Center(
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDriver ? Colors.green : Colors.amberAccent,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imgUrl),
          ),
        ),
      )
    ],
  );
}

messageCard(chat, currUsername) {
  String leftText = '';
  String rightText = '';
  if (chat.from == currUsername) {
    rightText = chat.message;
  } else {
    leftText = chat.message;
  }
  return Row(
    children: [
      Expanded(
        child: Container(
          color: leftText == '' ? null : Colors.red,
          child: Center(
            child: Text(leftText),
          ),
        ),
      ),
      Expanded(
        child: Container(
          color: rightText == '' ? null : Colors.green,
          child: Center(
            child: Text(rightText),
          ),
        ),
      ),
    ],
  );
}
