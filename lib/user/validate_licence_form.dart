import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/classes/user_class.dart';
import 'package:fe/utils/animated_progress_indicator.dart';
import 'package:fe/utils/api.dart';

class ValidateLicenceForm extends StatefulWidget {
  const ValidateLicenceForm({super.key});

  @override
  State<ValidateLicenceForm> createState() => _ValidateLicenceFormState();
}

class _ValidateLicenceFormState extends State<ValidateLicenceForm> {
  final _licenceNumberController = TextEditingController(text: '');
  final _codeController = TextEditingController(text: '');
  final _passwordTextController = TextEditingController(text: '');
  User _currUser = const User();
  bool _isCodeValid = true;
  bool _isLicenceValid = true;
  double _formProgress = 0;
  bool _isPasswordValid = true;
  bool _isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    _setCurrUser();
  }

  Future<void> _setCurrUser() async {
    final userState = Provider.of<AuthState>(context, listen: false);
    if (userState.userInfo.username != '') {
      _currUser = await fetchUserByUsername(userState.userInfo.username);
      setState(() {});
    }
  }

  void _handleFormSubmit() async {
    final userData = User(
        firstName: _currUser.firstName,
        lastName: _currUser.lastName,
        username: _currUser.username,
        email: _currUser.email,
        password: _passwordTextController.text,
        phoneNumber: _currUser.phoneNumber,
        bio: _currUser.bio,
        identityVerificationStatus: true,
        driverVerificationStatus: _currUser.driverVerificationStatus,
        car: _currUser.car,
        reports: _currUser.reports);
    await patchUser(userData);
    Navigator.of(context).pushNamed('/profile');
  }

  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [_licenceNumberController, _codeController];

    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }

  void _setIsPasswordObscured() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    String titleText = 'Validate Licence';
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your license details to validate your license',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          AnimatedProgressIndicator(value: _formProgress),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _licenceNumberController,
              decoration: InputDecoration(
                labelText: 'Licence Number',
                errorText:
                    _isLicenceValid ? null : 'Enter a valid UK licence number',
              ),
              onChanged: (value) {
                final RegExp regex = RegExp(
                    r'[A-Z0-9]{5}\d[0156]\d([0][1-9]|[12]\d|3[01])\d[A-Z0-9]{3}[A-Z]{2}');
                setState(() {
                  _isLicenceValid = regex.hasMatch(value);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification code',
                errorText:
                    _isCodeValid ? null : 'Enter a valid verification code',
              ),
              onChanged: (value) {
                final RegExp regex = RegExp(r'[a-zA-Z0-9]{1,8}');
                setState(() {
                  _isCodeValid = regex.hasMatch(value);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
                obscureText: _isPasswordObscured,
                controller: _passwordTextController,
                decoration: InputDecoration(
                    labelText: 'Enter you current password to make edits',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: _setIsPasswordObscured,
                    ),
                    errorMaxLines: 3,
                    errorText: _isPasswordValid
                        ? null
                        : "Enter valid password: At least one lowercase letter, one uppercase letter, one digit, one special character '`@!%*?&', at least 8 characters"),
                onChanged: (value) {
                  final RegExp regex = RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@!%*?&t])[A-Za-z\d@$!%*?&]{8,}$');
                  setState(() {
                    _isPasswordValid = regex.hasMatch(value);
                  });
                }),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : const Color.fromARGB(255, 129, 142, 153);
              }),
            ),
            onPressed: _formProgress > 0.99 ? _handleFormSubmit : null,
            child: Text(titleText),
          ),
        ],
      ),
    );
  }
}

