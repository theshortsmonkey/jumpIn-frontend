import 'package:fe/appbar.dart';
import 'package:fe/background.dart';
import 'package:fe/chat_card.dart';
import 'package:fe/classes/chat_class.dart';
import 'package:fe/classes/message_class.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:fe/classes/user_class.dart';
import 'package:fe/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import './api.dart';
import 'package:provider/provider.dart';
import "./auth_provider.dart";
import 'package:flutter/material.dart';

class SingleRideByID extends StatefulWidget {
  const SingleRideByID({
    super.key,
  });

  @override
  State<SingleRideByID> createState() => _SingleRideByIDState();
}

class _SingleRideByIDState extends State<SingleRideByID> {
  late User currUser;
  late Ride _currRide = Ride();
  List<Chat> _rideChats = [];
  late String rideId = '';
  late List _startLatLong = [];
  late List _endLatLong = [];
  String _requestText = 'Request to jumpIn';
  bool _isRequestButtonActive = true;

  @override
  void initState() {
    super.initState();
    currUser = context.read<AuthState>().userInfo;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (rideId.isEmpty && currUser.username != '') {
      final rideIdArg = ModalRoute.of(context)!.settings.arguments;
      if (rideIdArg != null) {
        rideId = rideIdArg as String;
      } else {
        rideId = '';
      }
      _getRideDetails();
    }
  }

  Future<void> _getRideDetails() async {
    Ride ride = await fetchRideById(rideId);
    bool isDriver = false;
    if (currUser.username == ride.driverUsername) isDriver = true;
    List<Chat> chats =
        await fetchMessagesByRideId(rideId, currUser.username, isDriver);
    final List startLatLong = await fetchLatLong(ride.from);
    final List endLatLong = await fetchLatLong(ride.to);
    setState(() {
      _currRide = ride;
      _rideChats = chats;
      _startLatLong = startLatLong;
      _endLatLong = endLatLong;
    });
  }

  void sendRequest(Ride rideData) async {
    // setState(() {
    //   _requestText = 'jumpIn Request Sent';
    //   _isRequestButtonActive = false;
    // });
    // final newMessage = Message(
    //     from: currUser.username,
    //     text: '${currUser.username} would like to jumpIn',
    //     driver: rideData.driverUsername,
    //     rider: currUser.username);
    // postMessageByRideId(rideData.id, newMessage);
    final patchDetails = {
      'requestJumpin': currUser.username,
    };
    final updatedRide = await patchRideById(rideData.id, patchDetails);
    setState(() {
      _currRide = updatedRide;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String imgUrl =
        'http://localhost:1337/users/${_currRide.driverUsername}/image';
    final String cost = NumberFormat.currency(locale: "en_GB", symbol: '£')
        .format(_currRide.price / 100);
    final String driverUsername = _currRide.driverUsername;
    final seatsLeft =
        _currRide.getAvailableSeats - _currRide.riderUsernames.length;
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Ride Details',
              context: context,
            ),
            body: ContainerWithBackgroundImage(
              child: SingleChildScrollView(
                child: Center(
                  child: _currRide.driverUsername == ''
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Row(
                                  children: [
                                    IntrinsicWidth(
                                      child: Column(
                                        children: [
                                          itemProfile(
                                              'Start',
                                              '${_currRide.from}',
                                              CupertinoIcons
                                                  .arrow_right_circle),
                                          itemProfile('End', '${_currRide.to}',
                                              CupertinoIcons.flag_circle_fill),
                                          itemProfile(
                                              'Date',
                                              '${_currRide.getDateTime?.substring(0, 10)}',
                                              CupertinoIcons.calendar_today),
                                          itemProfile(
                                              'Time',
                                              '${_currRide.getDateTime?.substring(11, 16)}',
                                              CupertinoIcons.clock),
                                          (currUser.username ==
                                                  _currRide.driverUsername)
                                              ? riderList(
                                                  _currRide.riderUsernames)
                                              : itemProfile(
                                                  'Accepted Riders',
                                                  '${_currRide.riderUsernames.length}',
                                                  CupertinoIcons.person_3),
                                          itemProfile(
                                              'Spaces Left',
                                              '$seatsLeft',
                                              CupertinoIcons.person_2),
                                          itemProfile(
                                              'Price',
                                              cost,
                                              CupertinoIcons
                                                  .money_pound_circle),
                                          itemProfile(
                                              'Total Carbon',
                                              '${_currRide.carbonEmissions}',
                                              CupertinoIcons
                                                  .leaf_arrow_circlepath),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox(
                                          height: 300,
                                          child:
                                              map(_startLatLong, _endLatLong)),
                                    ))
                                    // Expanded(
                                    //   child:
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            driverProfile(imgUrl, _currRide),
                            Column(
                              children: [
                                _rideChats.isEmpty
                                    ? ChatCard(
                                        rideId: rideId,
                                        driverUsername: driverUsername,
                                        currChats: const [],
                                      )
                                    : const ContainerWithBackgroundColor(
                                        child: Text(
                                          'Ride Chats',
                                        ),
                                      ),
                                for (var chat in _rideChats)
                                  ChatCard(
                                    rideId: rideId,
                                    driverUsername: driverUsername,
                                    currChats: [chat],
                                  ),
                              ],
                            )
                          ],
                        ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }

  riderList(riderList) {
    return Column(
      children: [
        itemProfile('Accepted Riders:', '', CupertinoIcons.person_3),
        for (var rider in riderList) Center(child: Text('$rider')),
      ],
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    final theme = Theme.of(context);
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData),
          const SizedBox(width: 10),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(width: 8),
          Text(subtitle, style: theme.textTheme.bodyLarge)
        ],
      ),
    );
  }

  driverProfile(imgURL, rideData) {
    final theme = Theme.of(context);
    Widget deleteButton =
        context.read<AuthState>().userInfo.username == rideData.driverUsername
            ? ElevatedButton(
                onPressed: () {
                  deleteRide(rideData.id);
                  Navigator.of(context).pushNamed('/allrides');
                },
                child: const Text('Delete Ride'),
              )
            : ElevatedButton(
                onPressed: _isRequestButtonActive
                    ? () {
                        sendRequest(rideData);
                      }
                    : null,
                child: Text(_requestText));

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(imgURL),
                      ),
                      const SizedBox(height: 10),
                      deleteButton,
                      itemProfile(
                          'Waiting jumpIn requests from:', '', CupertinoIcons.person_3),
                      for (var rider in _currRide.jumpInRequests)
                        Text('$rider'),
                    ],
                  ),
                  Container(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Driver:",
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(width: 8),
                            Text(
                              '${rideData.driverUsername}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Rating:",
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${rideData.driverRating}",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Container(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  map(startLatLong, endLatLong) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng((startLatLong[0] + endLatLong[0]) / 2,
            (startLatLong[1] + endLatLong[1]) / 2),
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: [
              LatLng(startLatLong[0], startLatLong[1]),
              LatLng(endLatLong[0], endLatLong[1])
            ], color: Colors.red, strokeWidth: 5),
          ],
        ),
      ],
    );
  }
}
