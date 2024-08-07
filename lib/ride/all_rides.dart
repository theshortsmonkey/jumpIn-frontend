import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:fe/utils/api.dart';
import 'package:fe/ride/ride_card.dart';
import 'package:fe/user/login_page.dart';

class AllRidesPage extends StatefulWidget {
  const AllRidesPage({super.key});

  @override
  State<AllRidesPage> createState() => _AllRidesPageState();
}

class _AllRidesPageState extends State<AllRidesPage> {
  bool _loading = false;
  late Future<List<Ride>> _futureRides;
  ActiveSession _currUser = const ActiveSession();
  String _driverUsername = '';
  final _toController = TextEditingController();
  final _fromController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAllRides();
  }

  Future<void> _getAllRides() async {
    try {
      setState(() {
        _loading = true;
      });
      final userState = Provider.of<AuthState>(context, listen: false);
      final activeUser = await userState.checkActiveSession();
      userState.isAuthorized
          ? userState.setActiveSession(activeUser)
          : throw Exception('no active user');
      setState(() {
        _loading = false;
        _currUser = activeUser;
        _futureRides = fetchRides();
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _filterRides(
      {String? to,
      String? from,
      String? getDateTime,
      String? driverUsername,
      int? price,
      int? getAvailableSeats,
      int? carbonEmissions}) async {
    setState(() {
      _futureRides = fetchRides(
          driverUsername: driverUsername,
          to: to,
          from: from,
          getDateTime: getDateTime,
          price: price,
          getAvailableSeats: getAvailableSeats,
          carbonEmissions: carbonEmissions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Find a Ride',
              context: context,
              disableAllRidesButton: true,
            ),
            body: ContainerWithBackgroundImage(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _fromController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    hintText: 'Start Point',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _toController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    hintText: 'End Point',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            _filterRides(
                                to: _toController.text,
                                from: _fromController.text,
                                driverUsername: _driverUsername);
                          },
                          child: const Text('Filter by start and end point'),
                        ),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _driverUsername = _currUser.username;
                            });
                            _filterRides(
                                to: _toController.text,
                                from: _fromController.text,
                                driverUsername: _driverUsername);
                          },
                          child: const Text('Show only my rides'),
                        ),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _driverUsername = '';
                            });
                            _filterRides(
                                to: _toController.text,
                                from: _fromController.text,
                                driverUsername: _driverUsername);
                          },
                          child: const Text('Show all rides'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _toController.text = '';
                              _fromController.text = '';
                              _driverUsername = '';
                              _filterRides();
                            });
                          },
                          child: const Text('Clear'),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: FutureBuilder<List<Ride>>(
                              future: _futureRides,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      Ride ride = snapshot.data![index];
                                      return RideCard(ride: ride);
                                    },
                                  );
                                } else {
                                  return const Text('No data');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          )
        : const LoginPage();
  }
}
