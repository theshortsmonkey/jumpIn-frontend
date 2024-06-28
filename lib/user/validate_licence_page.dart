import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import "package:fe/user/validate_licence_form.dart";
import 'package:fe/user/login_page.dart';

class ValidateLicencePage extends StatelessWidget {
  const ValidateLicencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Your Account',
              context: context,
              disablePostRideButton: true,
            ),
            body: const ContainerWithBackgroundImage(
              child: Center(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 400,
                    child: Card(
                      child: (ValidateLicenceForm()),
                    ),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
