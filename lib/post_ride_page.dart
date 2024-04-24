import 'package:fe/appbar.dart';
import 'package:fe/background.dart';
import 'package:fe/login_page.dart';
import 'package:flutter/material.dart';
import "./post_ride_form.dart";
import "./auth_provider.dart";
import 'package:provider/provider.dart';

class PostRidePage extends StatelessWidget {
  const PostRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Post a Ride',
              context: context,
              disablePostRideButton: true,
            ),
            body: ContainerWithBackgroundImage(
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: 600,
                  child: const Card(
                    child: (PostRideForm()),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
