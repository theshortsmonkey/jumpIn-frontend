import 'package:fe/animated_progress_indicator.dart';
import 'package:fe/api.dart';
import 'package:flutter/material.dart';
import 'classes/user_class.dart';
import "package:fe/auth_provider.dart";
import 'package:provider/provider.dart';

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
    final provider = Provider.of<AuthState>(context, listen: false);
    if (provider.userInfo.username != '') {
      _currUser = await fetchUserByUsername(provider.userInfo.username);
      setState(() {});
    }
  }

  void _validateVehicleDetails() async {
    dynamic carData;
    await fetchCarDetails(_regNumberController.text).then((res) {
      carData = res;
    });
    if (carData["taxStatus"] == "Taxed") {
      final carDetails = {
        "make": carData["make"],
        "reg": carData["registrationNumber"],
        "colour": carData["colour"],
        "tax_due_date": carData["taxDueDate"],
        "fuelType": carData["fuelType"],
        "co2Emissions": carData["co2Emissions"]
      };
      var userData = User(
          firstName: _currUser.firstName,
          lastName: _currUser.lastName,
          username: _currUser.username,
          email: _currUser.email,
          password: _passwordTextController.text,
          phoneNumber: _currUser.phoneNumber,
          bio: _currUser.bio,
          identity_verification_status: _currUser.identity_verification_status,
          driver_verification_status: true,
          car: carDetails,
          reports: _currUser.reports);
      await patchUser(userData);
      Navigator.of(context).pushNamed('/profile');
    } else {
      Navigator.of(context).pushNamed('/');
    }
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
            onPressed: _formProgress > 0.99 ? _validateVehicleDetails : null,
            child: Text(titleText),
          ),
        ],
      ),
    );
  }
}
