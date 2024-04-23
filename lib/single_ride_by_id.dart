import 'package:fe/appbar.dart';
import 'package:fe/chat_card.dart';
import 'package:fe/classes/chat_class.dart';
import 'package:fe/classes/get_ride_class.dart';
import 'package:fe/classes/get_user_class.dart';
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
  late Ride _currRide = const Ride();
  List<Chat> _rideChats = [];
  late String rideId = '';

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
    List<Chat> chats = await fetchMessagesByRideId(rideId, currUser.username,isDriver);
    setState(() {
      _currRide = ride;
      _rideChats = chats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String imgUrl =
        'http://localhost:1337/users/${_currRide.driverUsername}/image';
    final String cost = NumberFormat.currency(locale: "en_GB", symbol: '£')
        .format(_currRide.price / 100);
    final String driverUsername = _currRide.driverUsername;
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Ride Details',
              context: context,
            ),
            body: SingleChildScrollView(
              child: Center(
                child: _currRide.driverUsername == ''
                    ? const Text('No ride data')
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
                                            CupertinoIcons.arrow_right_circle),
                                        itemProfile('End', '${_currRide.to}',
                                            CupertinoIcons.flag_circle_fill),
                                        itemProfile(
                                            'Date',
                                            '${_currRide.dateTime?.substring(0, 10)}',
                                            CupertinoIcons.calendar_today),
                                        itemProfile(
                                            'Time',
                                            '${_currRide.dateTime?.substring(11, 16)}',
                                            CupertinoIcons.clock),
                                        itemProfile(
                                            'Available Seats',
                                            '${_currRide.availableSeats}',
                                            CupertinoIcons.person_2),
                                        itemProfile('Price', cost,
                                            CupertinoIcons.money_pound_circle),
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
                                    child: SizedBox(height: 300, child: map()),
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
                                  : const Text('Ride Chats'),
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
          )
        : const LoginPage();
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
                child: const Text('Delete Ride'))
            : const SizedBox();

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
                      FilledButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/ridechat', arguments: rideId);
                          },
                          child: const Text('Messages')),
                      const SizedBox(height: 10),
                      deleteButton
                    ],
                  ),

                  // Add some spacing between the image and the text
                  Container(width: 20),
                  // Add an expanded widget to take up the remaining horizontal space
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

  map() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 3.4,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: [
              const LatLng(53.47764, -2.23892),
              const LatLng(51.51408, -0.10648)
            ], color: Colors.red, strokeWidth: 10),
          ],
        ),
        // RichAttributionWidget(
        //   attributions: [
        //     TextSourceAttribution(
        //       'OpenStreetMap contributors',
        //       onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
        //     ),
      ],
    );
  }
}
