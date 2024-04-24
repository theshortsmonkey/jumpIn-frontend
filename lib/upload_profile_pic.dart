import 'package:fe/appbar.dart';
import 'package:fe/background.dart';
import 'package:fe/login_page.dart';
import 'package:fe/upload_image_form.dart';
import 'package:flutter/material.dart';
import "./auth_provider.dart";
import 'package:provider/provider.dart';

class UploadProfilePic extends StatelessWidget {
  const UploadProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Your Account',
              context: context,
            ),
            body: const ContainerWithBackgroundImage(
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: Card(
                    child: (UploadImageForm()),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
