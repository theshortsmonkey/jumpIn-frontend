import 'package:flutter/material.dart';
import 'classes/post_ride_class.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'api.dart';
import "./auth_provider.dart";
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
  dynamic _calculatedPrice; //in pence - to store calc'd result
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedSeats;

  double _formProgress = 0;

  dynamic carDetails;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuthState>(context, listen: false);
    carDetails = provider.userInfo.car;
  }

  void _postRide() async {
    final co2 = carDetails['co2Emissions'];

    final rideData = PostRideClass(
        to: _endPointTextController.text,
        to_region: _endRegionTextController.text,
        from: _startPointTextController.text,
        from_region: _startRegionTextController.text,
        driver_username: context.read<AuthState>().userInfo.username,
        available_seats: _selectedSeats,
        carbon_emissions: co2,
        distance: 0,
        price: int.parse(_inputPriceTextController.text),
        map: null,
        date_and_time: _selectedDay);

    final postedRide = await postRide(rideData);

    Navigator.of(context)
        .pushNamed('/singleridetest', arguments: postedRide.id);
  }

  Future calculatePrice() async {
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

  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _startPointTextController,
      _endPointTextController,
      _inputPriceTextController,
    ];

    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = context.read<AuthState>().userInfo;
    Widget priceWidget = _calculatedPrice != null
        ? Text('We recommend a price of £$_calculatedPrice')
        : const Text('We recommend a price');

    return Scaffold(
      body: userData.car != null
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
                      child: TextFormField(
                        controller: _startPointTextController,
                        decoration:
                            const InputDecoration(hintText: 'Start point'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _startRegionTextController,
                        decoration: const InputDecoration(
                            hintText: 'Select start region'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _endPointTextController,
                        decoration:
                            const InputDecoration(hintText: 'End point'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _endRegionTextController,
                        decoration: const InputDecoration(
                            hintText: 'Select end region'),
                      ),
                    ),
                    const Text('Select your date below'),
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
                            _selectedDay = selectedDay;
                            _focusedDay =
                                focusedDay; // update `_focusedDay` here as well
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButton(
                        hint: const Text('Select available seats'),
                        isExpanded: true,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedSeats = newValue;
                          });
                        },
                        items: [1, 2, 3, 4, 5]
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                      ),
                    ),
                    FilledButton(
                        onPressed: () {
                          calculatePrice().then((price) {
                            setState(() {
                              _calculatedPrice = price;
                            });
                          });
                        },
                        child: const Text('Calculate price')),
                    priceWidget,
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _inputPriceTextController,
                        decoration: const InputDecoration(hintText: 'Price'),
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
                          _formProgress == 1 ? _postRide : null, // UPDATED
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
