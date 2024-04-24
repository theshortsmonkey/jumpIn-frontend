import 'package:fe/background.dart';
import 'package:fe/login_page.dart';
import 'package:flutter/material.dart';
import './sign_up_form.dart';
import "./appbar.dart";
import 'package:provider/provider.dart';
import "./auth_provider.dart";

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Your Account',
              context: context,
              disablePostRideButton: true,
              disableAllRidesButton: true,
            ),
            body: const ContainerWithBackgroundImage(
              child: Center(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 400,
                    child: Card(
                      child: (SignUpForm(submitType: 'patch')),
                    ),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
