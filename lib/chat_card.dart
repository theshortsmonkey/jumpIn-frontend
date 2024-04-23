import 'package:fe/classes/chat_class.dart';
import 'package:fe/classes/get_user_class.dart';
import 'package:fe/classes/message_class.dart';
import './api.dart';
import 'package:provider/provider.dart';
import "./auth_provider.dart";
import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  final String rideId;
  final String driverUsername;
  final List<Chat> currChats;
  const ChatCard(
      {super.key,
      required this.rideId,
      required this.driverUsername,
      required this.currChats});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  User? currUser;
  final _msgTextController = TextEditingController();
  List<Chat> _rideChats = [];
  User? _driver;
  User? _rider;
  String _otherUsersName = '';

  @override
  void initState() {
    super.initState();
    currUser = context.read<AuthState>().userInfo;
    _rideChats = widget.currChats;
    _getUserDetails();
  }

  void _getUserDetails() async {
    User? driver;
    User? rider;
    String otherUsersName;
    if (_rideChats.isEmpty) {
      driver = await fetchUserByUsername(widget.driverUsername);
      rider = currUser;
      _rideChats = const [Chat()];
    } else {
      driver = await fetchUserByUsername(_rideChats[0].driver);
      rider = await fetchUserByUsername(_rideChats[0].rider);
    }
    if (driver.username == currUser!.username) {
      otherUsersName = rider!.username;
    } else {
      otherUsersName = driver.username;
    }
    setState(() {
      _driver = driver;
      _rider = rider;
      _otherUsersName = otherUsersName;
    });
  }

  void _postMessage() async {
    final newMessage = Message(
        from: currUser!.username,
        text: _msgTextController.text,
        driver: _driver!.username,
        rider: _rider!.username);
    final chat = await postMessageByRideId(widget.rideId, newMessage);
    setState(() {
      _rideChats = chat;
      _msgTextController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_driver == null || _rider == null) {
      return const CircularProgressIndicator();
    } else {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _driver!.username == currUser!.username 
            ? const Text('No Chats started for this ride')
            : Row(
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
                        userCard(_driver),
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
                        userCard(_rider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                for (var message in _rideChats[0].messages)
                  messageCard(message, currUser!.username),
              ],
            ),
            _driver!.username == currUser!.username 
            ? const SizedBox(height: 20,)
            : Row(
              children: [
                Expanded(
                  child: Form(
                    child: TextFormField(
                      controller: _msgTextController,
                      decoration: InputDecoration(
                          labelText: 'Message to $_otherUsersName',
                          hintText: "Type your message here..."),
                    ),
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      _postMessage();
                    },
                    child: const Text('Send'))
              ],
            ),
          ],
        ),
      );
    }
  }

  userCard(User? user) {
    final imgUrl = "http://localhost:1337/users/${user!.username}/image";
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(user.username),
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: user.driver_verification_status
                  ? Colors.green
                  : Colors.amberAccent,
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
    String displayText =
        '${message['text']} ${message['timeStamp'].substring(11, 16)} ${message['timeStamp'].substring(0, 10)}';
    if (message['from'] == _rider!.username) {
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
}
