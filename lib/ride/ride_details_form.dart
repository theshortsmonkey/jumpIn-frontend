import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/utils/animated_progress_indicator.dart';
import 'package:fe/utils/api_rides.dart';
import 'package:fe/utils/api_users.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';

class RideDetailsForm extends StatefulWidget {
  final String submitType;
  final String rideId;
  const RideDetailsForm(
      {super.key, required this.submitType, required this.rideId});

  @override
  State<RideDetailsForm> createState() => _RideDetailsFormState();
}

class _RideDetailsFormState extends State<RideDetailsForm> {
  TextEditingController _startPointTextController = TextEditingController();
  TextEditingController _startRegionTextController = TextEditingController();
  TextEditingController _endPointTextController = TextEditingController();
  TextEditingController _endRegionTextController = TextEditingController();
  TextEditingController _inputPriceTextController = TextEditingController();
  TextEditingController _seatSelectionTextController = TextEditingController();
  TextEditingController _dateSelectionTextController = TextEditingController();
  dynamic _calculatedPrice;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  SeatsLabel? _selectedSeats;
  RegionsLabel? _startRegion;
  RegionsLabel? _endRegion;

  double _formProgress = 0;
  double _priceProgress = 0;
  bool isPriceLoading = false;
  TimeOfDay _rideTime = TimeOfDay.now();
  ActiveSession _currUser = const ActiveSession();
  dynamic _carDetails;
  Ride _currRideData = Ride();

  @override
  void initState() {
    super.initState();
    final userState = Provider.of<AuthState>(context, listen: false);
    _currUser = userState.userInfo;
    if (userState.isAuthorized) {
      _getCarDetails();
      if (widget.rideId != '') {
        _setRideDetails();
      }
    }
  }

  Future<void> _getCarDetails() async {
    final userData = await fetchUserByUsername(_currUser.username);
    setState(() {
      _carDetails = userData.car;
    });
  }

  void _setRideDetails() async {
    Ride ride = await fetchRideById(widget.rideId);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startPointTextController = TextEditingController(text: ride.from);
      _endPointTextController = TextEditingController(text: ride.to);
      _startRegion = ride.fromRegion;
      _startRegionTextController =
          TextEditingController(text: _startRegion!.region);
          _endRegion = ride.toRegion;
      _endRegionTextController =
          TextEditingController(text: _endRegion!.region);
      _inputPriceTextController =
          TextEditingController(text: ride.price.toString());
      _selectedDay = DateTime.parse(ride.getDateTime);
      _dateSelectionTextController =
          TextEditingController(text: ride.getDateTime);
      _rideTime =
          TimeOfDay(hour: _selectedDay!.hour, minute: _selectedDay!.minute);
          _selectedSeats = SeatsLabel.fromInt(ride.getAvailableSeats);
      _seatSelectionTextController =
          TextEditingController(text: _selectedSeats!.seats.toString());
    setState(() {
      _currRideData = ride;
    });
      _updateFormProgress();
    });
  }

  void _handleSubmit(context) async {
    final co2 = _carDetails['co2Emissions'];
    final rideData = Ride(
      to: _endPointTextController.text,
      toRegion: _endRegion,
      from: _startPointTextController.text,
      fromRegion: _startRegion,
      driverUsername: _currUser.username,
      postAvailableSeats: _selectedSeats,
      carbonEmissions: co2,
      distance: 0,
      price: int.parse(_inputPriceTextController.text),
      map: _currRideData.map,
      setDateTime: _selectedDay,
      chats: _currRideData.chats
    );
    if (widget.submitType == 'post') {
      final postedRide = await postRide(rideData);
      Navigator.of(context).pushNamed('/singleride', arguments: postedRide.id);
    } else {
      final patchedRide = await patchRideById(widget.rideId,rideData);
      Navigator.of(context).pushNamed('/singleride', arguments: patchedRide.id);
    }
  }

  Future calculatePrice() async {
    setState(() {
      isPriceLoading = true;
    });
    final startPointFuture = await fetchLatLong(_startPointTextController.text);
    final endPointFuture = await fetchLatLong(_endPointTextController.text);

    if (_carDetails == null) {
      throw Exception('Car details not found');
    }
    final fuelType = _carDetails["fuelType"];

    final co2 =
        _carDetails["co2Emissions"]; // I AM AN INTEGER emissions in g/km
    final fuelPriceFuture = await fetchFuelPrice(fuelType);

    final double? startLat = startPointFuture[0];
    final double? startLong = startPointFuture[1];
    final double? endLat = endPointFuture[0];
    final double? endLong = endPointFuture[1];

    final String apiString =
        "lonlat:$startLong,$startLat|lonlat:$endLong,$endLat";

    final metreDistanceFuture = await fetchDistance(apiString);

    final double fuelEfficiency;
    final double journeyPrice;

    if (fuelType == 'PETROL') {
      //use co2 to calc mpg and hence cost - petrol: 2310g/L; diesel: 2680g/L
      fuelEfficiency = (2310 / co2); //in km/L
      journeyPrice =
          (metreDistanceFuture / (1000 * fuelEfficiency)) * fuelPriceFuture;
    } else {
      fuelEfficiency = (2680 / co2); //in km/L
      journeyPrice =
          (metreDistanceFuture / (1000 * fuelEfficiency)) * fuelPriceFuture;
    }
    return (journeyPrice / 100).toString().substring(0, 5);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && _selectedDay != null) {
      final dateTime = DateTime(_selectedDay!.year, _selectedDay!.month,
          _selectedDay!.day, picked.hour, picked.minute);
      setState(() {
        _rideTime = picked;
        _selectedDay = dateTime;
      });
    }
  }

  void _updateFormProgress() {
    double formProgress = 0.0;
    double priceProgress = 0.0;
    final formControllers = [
      _startPointTextController,
      _endPointTextController,
      _inputPriceTextController,
      _startRegionTextController,
      _endRegionTextController,
      _seatSelectionTextController,
      _dateSelectionTextController,
    ];
    final priceControllers = [
      _startPointTextController,
      _endPointTextController,
    ];

    for (final formController in formControllers) {
      if (formController.value.text.isNotEmpty) {
        formProgress += 1 / formControllers.length;
      }
    }
    for (final priceController in priceControllers) {
      if (priceController.value.text.isNotEmpty) {
        priceProgress += 1 / priceControllers.length;
      }
    }

    setState(() {
      _formProgress = formProgress;
      _priceProgress = priceProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget priceWidget = Text(
      _calculatedPrice != null
          ? 'We recommend a price of £$_calculatedPrice'
          : 'We recommend a price based on the supplied start and end points',
      textAlign: TextAlign.center,
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final viewWidth = screenWidth * pixelRatio;
    String titleText;
    String submitButtonText;
    if (widget.submitType == 'post') {
      titleText = 'Complete the form to post a ride';
      submitButtonText = 'Create Ride';
    } else {
      titleText = 'Edit the ride details';
      submitButtonText = 'Submit Ride Changes';
    }

    return Scaffold(
      body: _currUser.isDriver
          ? Form(
              onChanged: _updateFormProgress,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    AnimatedProgressIndicator(value: _formProgress),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownMenu<RegionsLabel>(
                        controller: _startRegionTextController,
                        requestFocusOnTap: true,
                        width: viewWidth * 0.5,
                        label: const Text('Start Region'),
                        onSelected: (RegionsLabel? region) {
                          setState(() {
                            _startRegion = region;
                          });
                        },
                        dropdownMenuEntries: RegionsLabel.values
                            .map<DropdownMenuEntry<RegionsLabel>>(
                                (RegionsLabel region) {
                          return DropdownMenuEntry<RegionsLabel>(
                            value: region,
                            label: region.label,
                            enabled: region.label != '0',
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _startPointTextController,
                        decoration: const InputDecoration(
                          hintText: 'Input start point',
                          labelText: 'Start Point',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownMenu<RegionsLabel>(
                        controller: _endRegionTextController,
                        requestFocusOnTap: true,
                        width: viewWidth * 0.5,
                        label: const Text('End Region'),
                        onSelected: (RegionsLabel? region) {
                          setState(() {
                            _endRegion = region;
                          });
                        },
                        dropdownMenuEntries: RegionsLabel.values
                            .map<DropdownMenuEntry<RegionsLabel>>(
                                (RegionsLabel region) {
                          return DropdownMenuEntry<RegionsLabel>(
                            value: region,
                            label: region.label,
                            enabled: region.label != '0',
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _endPointTextController,
                        decoration: const InputDecoration(
                          hintText: 'Input end point',
                          labelText: 'End Point',
                        ),
                      ),
                    ),
                    const Text('Select your ride date below'),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _dateSelectionTextController.text =
                                DateFormat('dd-MM-yyyy').format(selectedDay);
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                    FilledButton(
                      onPressed: _selectTime,
                      child: const Text('Set Ride Time'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(children: [
                        _selectedDay != null
                            ? Text(
                                'Chosen Ride Day: ${_selectedDay!.day.toString()}/${_selectedDay!.month.toString()}/${_selectedDay!.year.toString()}')
                            : const SizedBox.shrink(),
                        Text(
                            'Chosen Ride Time: ${_rideTime.hour.toString().padLeft(2, '0')}:${_rideTime.minute.toString().padLeft(2, '0')}'),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownMenu<SeatsLabel>(
                        controller: _seatSelectionTextController,
                        requestFocusOnTap: true,
                        width: viewWidth * 0.5,
                        label: const Text('Set Available Seats'),
                        onSelected: (SeatsLabel? seats) {
                          setState(() {
                            _selectedSeats = seats;
                          });
                        },
                        dropdownMenuEntries: SeatsLabel.values
                            .map<DropdownMenuEntry<SeatsLabel>>(
                                (SeatsLabel seats) {
                          return DropdownMenuEntry<SeatsLabel>(
                            value: seats,
                            label: seats.label,
                            enabled: seats.label != '0',
                          );
                        }).toList(),
                      ),
                    ),
                    FilledButton(
                      onPressed: _priceProgress == 1
                          ? () {
                              calculatePrice().then((price) {
                                setState(() {
                                  _calculatedPrice = price;
                                  isPriceLoading = false;
                                });
                              });
                            }
                          : null,
                      child: isPriceLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Calculate recommended price'),
                    ),
                    priceWidget,
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _inputPriceTextController,
                        decoration: const InputDecoration(
                          hintText: 'Input final price (in pence)',
                          labelText: 'Final Price (in pence)',
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          return states.contains(MaterialState.disabled)
                              ? null
                              : Colors.white;
                        }),
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          return states.contains(MaterialState.disabled)
                              ? null
                              : Colors.blue;
                        }),
                      ),
                      onPressed: _formProgress > 0.99
                          ? () {
                              _handleSubmit(context);
                            }
                          : null,
                      child: Text(submitButtonText),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text(
                'You need to have a car to post a ride.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
    );
  }
}
