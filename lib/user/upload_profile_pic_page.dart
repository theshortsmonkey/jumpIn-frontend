import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fe/auth_provider.dart';
import 'package:fe/appbar.dart';
import 'package:fe/utils/background.dart';
import 'package:fe/user/login_page.dart';
import 'package:fe/user/upload_profile_pic_form.dart';

class UploadProfilePicPage extends StatelessWidget {
  const UploadProfilePicPage({super.key});

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
                    child: (UploadProfilePicForm()),
                  ),
                ),
              ),
            ),
          )
        : const LoginPage();
  }
}
