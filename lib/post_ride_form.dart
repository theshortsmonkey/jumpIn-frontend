import 'package:fe/classes/user_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fe/classes/ride_class.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:fe/api.dart';
import "package:fe/auth_provider.dart";
import 'package:provider/provider.dart';

class PostRideForm extends StatefulWidget {
  const PostRideForm({super.key});

  @override
  State<PostRideForm> createState() => _PostRideFormState();
}

class _PostRideFormState extends State<PostRideForm> {
  final _startPointTextController = TextEditingController();
  final _startRegionTextController = TextEditingController();
  final _endPointTextController = TextEditingController();
  final _endRegionTextController = TextEditingController();
  final _inputPriceTextController = TextEditingController();
  final _seatSelectionTextController = TextEditingController();
  final _dateSelectionTextController = TextEditingController();
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
  ActiveSession? _currUser;
  dynamic carDetails;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuthState>(context, listen: false);
    _currUser = provider.userInfo;
  }

  void _postRide() async {
    final co2 = carDetails['co2Emissions'];

    final rideData = Ride(
      to: _endPointTextController.text,
      toRegion: _endRegion,
      from: _startPointTextController.text,
      fromRegion: _startRegion,
      driverUsername: context.read<AuthState>().userInfo.username,
      postAvailableSeats: _selectedSeats,
      carbonEmissions: co2,
      distance: 0,
      price: int.parse(_inputPriceTextController.text),
      map: [],
      setDateTime: _selectedDay,
    );

    final postedRide = await postRide(rideData);

    Navigator.of(context).pushNamed('/singleride', arguments: postedRide.id);
  }

  Future calculatePrice() async {
    setState(() {
      isPriceLoading = true;
    });
    final startPointFuture = fetchLatLong(_startPointTextController.text);
    final endPointFuture = fetchLatLong(_endPointTextController.text);

    return Future.wait([
      startPointFuture,
      endPointFuture,
    ]).then((results) {
      final startPoint = results[0];
      final endPoint = results[1];
      if (carDetails == null) {
        throw Exception('Car details not found');
      }
      final fuelType = carDetails["fuelType"];

      final co2 =
          carDetails["co2Emissions"]; // I AM AN INTEGER emissions in g/km
      final fuelPriceFuture = fetchFuelPrice(fuelType);

      // Handle the results of all completed futures
      final double? startLat = startPoint[1];
      final double? startLong = startPoint[0];
      final double? endLat = endPoint[1];
      final double? endLong = endPoint[0];

      final String apiString =
          "lonlat:$startLong,$startLat|lonlat:$endLong,$endLat";

      final metreDistanceFuture = fetchDistance(apiString);

      return Future.wait([
        Future.value(fuelType),
        Future.value(co2),
        fuelPriceFuture,
        metreDistanceFuture
      ]).then((results) {
        final fuelType = results[0];
        final co2 = results[1];
        final fuelPrice = results[2];
        final metreDistance = results[3];

        final double fuelEfficiency;
        final double journeyPrice;

        if (fuelType == 'PETROL') {
          //use co2 to calc mpg and hence cost - petrol: 2310g/L; diesel: 2680g/L
          fuelEfficiency = (2310 / co2); //in km/L
          journeyPrice = (metreDistance / (1000 * fuelEfficiency)) * fuelPrice;
        } else {
          //DIESEL
          fuelEfficiency = (2680 / co2); //in km/L
          journeyPrice = (metreDistance / (1000 * fuelEfficiency)) * fuelPrice;
        }
        return (journeyPrice / 100).toString().substring(0, 5);
      });
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final dateTime = DateTime(_selectedDay!.year, _selectedDay!.month,
          _selectedDay!.day, picked.hour, picked.minute);
      setState(() {
        _rideTime = picked;
        _selectedDay = dateTime;
      });
    }
  }

  void _updateFormProgress() {
    double progress = 0.0;
    double priceProgress = 0.0;
    final controllers = [
      _startPointTextController,
      _endPointTextController,
      _inputPriceTextController,
      _startRegionTextController,
      _endRegionTextController,
      _seatSelectionTextController,
      _dateSelectionTextController
    ];
    final priceControllers = [
      _startPointTextController,
      _endPointTextController,
    ];

    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }
    for (final priceController in priceControllers) {
      if (priceController.value.text.isNotEmpty) {
        priceProgress += 1 / priceControllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
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

    return Scaffold(
      body: _currUser!.isDriver
          ? Form(
              onChanged: _updateFormProgress, // NEW
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Complete the form to post a ride',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    AnimatedProgressIndicator(value: _formProgress), // NEW
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
                        child: Text(
                            'Ride Time: ${_rideTime.hour.toString()}:${_rideTime.minute.toString()}')),
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
                      onPressed:
                          _formProgress > 0.99 ? _postRide : null, // UPDATED
                      child: const Text('Create Ride'),
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
//DROP DOWN BUTTO

//ANIMATION
class AnimatedProgressIndicator extends StatefulWidget {
  final double value;

  const AnimatedProgressIndicator({
    super.key,
    required this.value,
  });

  @override
  State<AnimatedProgressIndicator> createState() {
    return _AnimatedProgressIndicatorState();
  }
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final colorTween = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.red, end: Colors.orange),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.orange, end: Colors.yellow),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.yellow, end: Colors.green),
        weight: 1,
      ),
    ]);

    _colorAnimation = _controller.drive(colorTween);
    _curveAnimation = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.animateTo(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => LinearProgressIndicator(
        value: _curveAnimation.value,
        valueColor: _colorAnimation,
        backgroundColor: _colorAnimation.value?.withOpacity(0.4),
      ),
    );
  }
}
