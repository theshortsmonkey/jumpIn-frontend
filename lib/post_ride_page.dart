import 'package:fe/login_page.dart';
import 'package:flutter/material.dart';
import "./post_ride_form.dart";
import "./auth_provider.dart";
import 'package:provider/provider.dart';

class PostRidePage extends StatelessWidget {
  const PostRidePage({super.key});

  @override
  Widget build(BuildContext context){
    return context.read<AuthState>().isAuthorized 
      ? Scaffold(
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: 400,
            child: const Card(
              child: (PostRideForm()),
            ),
          ),
      ),
      )
    : const LoginPage();
  }
}