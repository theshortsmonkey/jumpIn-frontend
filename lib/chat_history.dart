import 'package:fe/classes/chat_class.dart';
import 'package:fe/classes/message_class.dart';
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
  List<Chat> _rideChats = [];

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

  void _postMessage(String from, String driver) async {
    final newMessage = Message(
                from: from,
                text: _msgTextController.text,
                driver: driver,
                rider: from
              );
    final chat = await postMessageByRideId(widget.rideId,newMessage);
    setState((){
      _rideChats = chat;
    });
  }

  Future<void> _getRideChats(currUser) async {
    List<Chat> chats =
        await fetchMessagesByRideId(widget.rideId, currUser.username);
    setState(() {
      _rideChats = chats;
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
                    _postMessage(userData.username,widget.driverUsername);
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
              for (var message in _rideChats[0].messages) messageCard(message, userData.username),
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

messageCard(message, currUsername) {
  String leftText = '';
  String rightText = '';
  String displayText = '${message['text']} ${message['timeStamp'].substring(11, 16)} ${message['timeStamp'].substring(0, 10)}';
  if (message['from'] == currUsername) {
    rightText = displayText;
  } else {
    leftText = displayText;
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
