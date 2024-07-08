import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/user/login_page.dart';
import "package:fe/ride/post_ride_form.dart";

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
