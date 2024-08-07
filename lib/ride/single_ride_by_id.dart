import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/utils/api.dart';
import 'package:fe/ride/chat_card.dart';
import 'package:fe/classes/chat_class.dart';
import 'package:fe/classes/message_class.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:fe/user/login_page.dart';

class SingleRideByID extends StatefulWidget {
  final String rideId;
  const SingleRideByID({
    super.key,
    required this.rideId,
  });

  @override
  State<SingleRideByID> createState() => _SingleRideByIDState();
}

class _SingleRideByIDState extends State<SingleRideByID> {
  late ActiveSession _currUser = const ActiveSession();
  dynamic _carDetails = {'reg': ''};
  late Ride _currRide = Ride();
  List<Chat> _rideChats = [];
  late String rideId = '';
  late List _startLatLong = [];
  late List _endLatLong = [];
  String _requestText = 'Request to jumpIn';
  bool _isRequestButtonActive = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    rideId = widget.rideId;
    _getRideDetails();
  }

  Future<void> _getRideDetails() async {
    try {
      final userState = Provider.of<AuthState>(context, listen: false);
      final currUser = await userState.checkActiveSession();
      userState.isAuthorized
          ? userState.setActiveSession(currUser)
          : throw Exception('no active user');
      Ride ride = await fetchRideById(rideId);
      bool isDriver = false;
      if (currUser.username == ride.driverUsername) isDriver = true;
      List<Chat> chats =
          await fetchMessagesByRideId(rideId, currUser.username, isDriver);
      final List startLatLong = await fetchLatLong(ride.from);
      final List endLatLong = await fetchLatLong(ride.to);
      setState(() {
        _currUser = currUser;
        _currRide = ride;
        _rideChats = chats;
        _startLatLong = startLatLong;
        _endLatLong = endLatLong;
        _loading = false;
      });
      _getCarDetails();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getCarDetails() async {
    final userData = await fetchUserByUsername(_currUser.username);
    setState(() {
      _carDetails = userData.car;
    });
  }

  void sendRequest(Ride rideData) async {
    setState(() {
      _requestText = 'jumpIn Request Sent';
      _isRequestButtonActive = false;
    });
    final newMessage = Message(
        from: _currUser.username,
        text: '${_currUser.username} would like to jumpIn',
        driver: rideData.driverUsername,
        rider: _currUser.username);
    postMessageByRideId(rideData.id, newMessage);
    final patchDetails = {
      'requestJumpin': _currUser.username,
    };
    await patchRideById(rideData.id, patchDetails);
    await _getRideDetails();
  }

  void acceptRequest(Ride rideData, requestFrom) async {
    final seatsLeft =
        _currRide.getAvailableSeats - _currRide.riderUsernames.length;
    if (seatsLeft > 0) {
      final patchDetails = {
        'acceptRider': requestFrom,
      };
      await patchRideById(rideData.id, patchDetails);
      final newMessage = Message(
          from: _currUser.username,
          text: 'Request from $requestFrom accepted',
          driver: rideData.driverUsername,
          rider: requestFrom);
      await postMessageByRideId(rideData.id, newMessage);
      await _getRideDetails();
    } else {
      debugPrint('no seats left');
    }
  }

  void rejectRequest(Ride rideData, requestFrom) async {
    final patchDetails = {
      'rejectRider': requestFrom,
    };
    await patchRideById(rideData.id, patchDetails);
    final newMessage = Message(
        from: _currUser.username,
        text: 'Request from $requestFrom rejected',
        driver: rideData.driverUsername,
        rider: requestFrom);
    await postMessageByRideId(rideData.id, newMessage);
    await _getRideDetails();
  }

  void removeRider(Ride rideData, requestFrom) async {
    final patchDetails = {
      'removeRider': requestFrom,
    };
    await patchRideById(rideData.id, patchDetails);
    final newMessage = Message(
        from: _currUser.username,
        text: '$requestFrom removed from ride',
        driver: rideData.driverUsername,
        rider: requestFrom);
    await postMessageByRideId(rideData.id, newMessage);
    await _getRideDetails();
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
    return _loading
        ? const CircularProgressIndicator()
        : context.read<AuthState>().isAuthorized
            ? Center(
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
                                            CupertinoIcons.arrow_right_circle),
                                        itemProfile('End', '${_currRide.to}',
                                            CupertinoIcons.flag_circle_fill),
                                        itemProfile(
                                            'Date',
                                            _currRide.getDateTime
                                                .substring(0, 10),
                                            CupertinoIcons.calendar_today),
                                        itemProfile(
                                            'Time',
                                            _currRide.getDateTime
                                                .substring(11, 16),
                                            CupertinoIcons.clock),
                                        itemProfile('Spaces Left', '$seatsLeft',
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
                                      child: SizedBox(
                                          height: 300,
                                          child:
                                              map(_startLatLong, _endLatLong)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          driverProfile(imgUrl, _currRide),
                          actionsCard(_currRide),
                          chatCards(
                              _currRide, _rideChats, rideId, driverUsername)
                        ],
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
          tileProvider: CancellableNetworkTileProvider(),
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

  driverProfile(imgURL, rideData) {
    final theme = Theme.of(context);
    bool isDriver = (rideData.driverUsername == _currUser.username);
    bool isAcceptedRider = rideData.riderUsernames.contains(_currUser.username);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(imgURL),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
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
                          Text("Driver:", style: theme.textTheme.headlineSmall),
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
                      isDriver || isAcceptedRider
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Car Registration:",
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${_carDetails['reg']}",
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                      Container(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  actionsCard(Ride rideData) {
    final theme = Theme.of(context);
    bool isDriver = (rideData.driverUsername == _currUser.username);
    int spacesLeft =
        rideData.getAvailableSeats - rideData.riderUsernames.length;
    final Widget driverRequestsView = Expanded(
      child: Column(
        children: [
          Text(
            'jumpIn Requests',
            style: theme.textTheme.headlineSmall,
          ),
          for (var rider in rideData.riderUsernames)
            Wrap(
              children: [
                Text(
                  '$rider - accepted',
                  style: theme.textTheme.bodyLarge,
                ),
                ElevatedButton(
                  onPressed: () {
                    removeRider(rideData, rider);
                  },
                  child: const Text('Remove Rider'),
                ),
              ],
            ),
          for (var rider in rideData.jumpInRequests)
            Wrap(
              children: [
                Text(
                  rider,
                  style: theme.textTheme.bodyLarge,
                ),
                ElevatedButton(
                  onPressed: () {
                    acceptRequest(rideData, rider);
                  },
                  child: const Text('Accept request'),
                ),
                ElevatedButton(
                  onPressed: () {
                    rejectRequest(rideData, rider);
                  },
                  child: const Text('Reject request'),
                ),
              ],
            ),
          rideData.jumpInRequests.isEmpty && rideData.riderUsernames.isEmpty
              ? Text(
                  'No requests',
                  style: theme.textTheme.bodyLarge,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
    final Widget riderRequestsView = Expanded(
      child: Column(
        children: [
          Text(
            'jumpIn Requests:',
            style: theme.textTheme.headlineSmall,
          ),
          rideData.riderUsernames.contains(_currUser.username)
              ? Text(
                  'Request accepted',
                  style: theme.textTheme.bodyLarge,
                )
              : rideData.jumpInRequests.contains(_currUser.username)
                  ? Text(
                      'Request pending',
                      style: theme.textTheme.bodyLarge,
                    )
                  : (spacesLeft > 0)
                      ? ElevatedButton(
                          onPressed: _isRequestButtonActive
                              ? () {
                                  sendRequest(rideData);
                                }
                              : null,
                          child: Text(_requestText),
                        )
                      : Text(
                          'No spaces left on this ride',
                          style: theme.textTheme.bodyLarge,
                        )
        ],
      ),
    );
    final Widget driverActionsView = Column(
      children: [
        Text(
          'Ride Actions',
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          'Only available when no riders accepted on ride',
          style: theme.textTheme.bodyLarge,
        ),
        ElevatedButton(
          onPressed: rideData.riderUsernames.isEmpty
              ? () {
                  deleteRide(rideData.id);
                  Navigator.of(context).pushNamed('/allrides');
                }
              : null,
          child: const Text('Delete Ride'),
        ),
        ElevatedButton(
          onPressed: rideData.riderUsernames.isEmpty
              ? () {
                  Navigator.of(context)
                      .pushNamed('/editride', arguments: rideData.id);
                }
              : null,
          child: const Text('Edit Ride'),
        ),
      ],
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            isDriver ? driverActionsView : const SizedBox.shrink(),
            isDriver ? driverRequestsView : riderRequestsView,
          ],
        ),
      ),
    );
  }

  chatCards(Ride rideData, rideChats, rideId, driverUsername) {
    final theme = Theme.of(context);
    final Widget headerText = Text(
      'Ride Chats',
      style: theme.textTheme.headlineSmall,
    );
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _rideChats.isEmpty
              ? ChatCard(
                  rideId: rideId,
                  driverUsername: driverUsername,
                  currChats: const [],
                )
              : headerText,
          for (var chat in _rideChats)
            ChatCard(
              rideId: rideId,
              driverUsername: driverUsername,
              currChats: [chat],
            ),
        ],
      ),
    );
  }
}
