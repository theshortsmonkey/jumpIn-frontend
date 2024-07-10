import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/user/login_page.dart';
import "package:fe/ride/ride_details_form.dart";

class EditRidePage extends StatelessWidget {
  const EditRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rideIdArgs = ModalRoute.of(context)!.settings.arguments;
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Edit Your Ride',
              context: context,
              disablePostRideButton: true,
            ),
            body: ContainerWithBackgroundImage(
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: 600,
                  child: Card(
                    child:
                        (RideDetailsForm(submitType: 'patch', rideId: rideIdArgs as String)),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
