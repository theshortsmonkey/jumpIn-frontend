import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/user/profile_page.dart';
import 'package:fe/user/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    dynamic args;
    (ModalRoute.of(context)?.settings.arguments != null)
        ? args = ModalRoute.of(context)?.settings.arguments as Map
        : args = {'message': null};
    return context.read<AuthState>().isAuthorized
        ? const ProfileScreen()
        : Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn: Login',
              context: context,
              disableLoginButton: true,
            ),
            body: ContainerWithBackgroundImage(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    (args['message'] != null)
                        ? ContainerWithBackgroundColor(
                            child: Text(
                              args['message'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 40),
                    const Center(
                      child: SizedBox(
                        width: 400,
                        child: Card(
                          child: (LoginForm()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
