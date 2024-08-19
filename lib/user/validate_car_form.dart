import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/classes/user_class.dart';
import 'package:fe/utils/animated_progress_indicator.dart';
import 'package:fe/utils/api_users.dart';

class ValidateCarForm extends StatefulWidget {
  const ValidateCarForm({super.key});

  @override
  State<ValidateCarForm> createState() => _ValidateCarFormState();
}

class _ValidateCarFormState extends State<ValidateCarForm> {
  final _regNumberController = TextEditingController(text: '');
  final _passwordTextController = TextEditingController(text: '');
  User _currUser = const User();
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

  void _validateVehicleDetails(context) async {
    await setUserCarDetails(
        _regNumberController.text, _passwordTextController.text);
    Navigator.of(context).pushNamed('/profile');
  }

  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _regNumberController,
    ];

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
    String titleText = 'Validate Your Car';
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your car registration to validate your vehicle',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          AnimatedProgressIndicator(value: _formProgress),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _regNumberController,
              decoration: const InputDecoration(
                labelText: 'Reg Number',
              ),
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
                    : Colors.blue;
              }),
            ),
            onPressed: _formProgress > 0.99
                ? () {
                    _validateVehicleDetails(context);
                  }
                : null,
            child: Text(titleText),
          ),
        ],
      ),
    );
  }
}
