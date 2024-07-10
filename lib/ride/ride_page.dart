import 'package:fe/ride/all_rides.dart';
import 'package:flutter/material.dart';
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/ride/single_ride_by_id.dart';

class RidePage extends StatelessWidget {
  const RidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rideIdArgs = ModalRoute.of(context)!.settings.arguments;
    String rideIdArg;
    rideIdArgs == null
    ? rideIdArg = ''
    : rideIdArg = rideIdArgs as String;
    return rideIdArg != ''
    ? Scaffold(
      appBar: CustomAppBar(
        title: 'jumpIn - Ride Details',
        context: context,
      ),
      body: ContainerWithBackgroundImage(
        child: SingleChildScrollView(
          child: SingleRideByID(rideId: rideIdArg),
        ),
      ),
    )
    : const AllRidesPage();
  }
}
