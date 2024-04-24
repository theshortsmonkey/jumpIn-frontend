import 'package:fe/appbar.dart';
import 'package:fe/background.dart';
import 'package:flutter/material.dart';
import './sign_up_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'jumpIn - Sign Up',
        context: context,
      ),
      body: const ContainerWithBackgroundImage(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Card(
                child: (SignUpForm(submitType: 'post')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
