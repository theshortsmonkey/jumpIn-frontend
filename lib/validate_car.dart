import 'package:fe/appbar.dart';
import 'package:fe/login_page.dart';
import 'package:flutter/material.dart';
import "./validate_car_form.dart";
import "./auth_provider.dart";
import 'package:provider/provider.dart';

class ValidateCarPage extends StatelessWidget {
  const ValidateCarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Your Account',
              context: context,
              disablePostRideButton: true,
            ),
      body: const Center(
        child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Card(
            child: (ValidateCarFrom(submitType: 'patch')),
            
          ),
        ),
        ),
      ),
    )
    : const LoginPage();
  }
}