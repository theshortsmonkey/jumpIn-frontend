import 'package:fe/appbar.dart';
import 'package:fe/profile_page.dart';
import 'package:flutter/material.dart';
import './login_form.dart';
import 'package:provider/provider.dart';
import "./auth_provider.dart";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
    ? const ProfileScreen()
    : Scaffold(
      appBar: CustomAppBar(
            title: 'jumpIn: Find a Ride',
            context: context,
            disableLoginButton: true,
          ),
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: (LoginForm()),
          ),
        ),
      ),
    );
  }
}