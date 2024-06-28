import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fe/auth_provider.dart';
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/user/profile_details_form.dart';
import 'package:fe/user/login_page.dart';

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
                      child: (ProfileDetailsForm(submitType: 'patch')),
                    ),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
