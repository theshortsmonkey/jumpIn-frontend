import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/classes/user_class.dart';
import 'package:fe/utils/animated_progress_indicator.dart';
import 'package:fe/utils/api.dart';
import 'package:email_validator/email_validator.dart';

class ProfileDetailsForm extends StatefulWidget {
  final String submitType;
  const ProfileDetailsForm({super.key, required this.submitType});

  @override
  State<ProfileDetailsForm> createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<ProfileDetailsForm> {
  TextEditingController _firstNameTextController = TextEditingController(text: '');
  TextEditingController _lastNameTextController = TextEditingController(text: '');
  TextEditingController _usernameTextController = TextEditingController(text: '');
  final _passwordTextController = TextEditingController(text: '');
  TextEditingController _emailTextController = TextEditingController(text: '');
  TextEditingController _phoneNumberController = TextEditingController(text: '');
  TextEditingController _bioController = TextEditingController(text: '');
  User _currUser = const User();

  @override
  void initState() {
    super.initState();
    _setCurrUser();
  }

  Future<void> _setCurrUser() async {
    final provider = Provider.of<AuthState>(context, listen: false);
    if (provider.userInfo.username != '') {
      _currUser = await fetchUserByUsername(provider.userInfo.username);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _firstNameTextController =
            TextEditingController(text: _currUser.firstName);
        _lastNameTextController =
            TextEditingController(text: _currUser.lastName);
        _usernameTextController =
            TextEditingController(text: _currUser.username);
        _emailTextController = TextEditingController(text: _currUser.email);
        _phoneNumberController =
            TextEditingController(text: _currUser.phoneNumber);
        _bioController = TextEditingController(text: _currUser.bio);
        setState(() {});
      });
    }
  }

  bool _isEmailValid = true;
  bool _isPhoneNumberValid = true;
  bool _isUserNameValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordObscured = true;
  double _formProgress = 0;
  bool _doesUserExist = false;

  void _handleSubmit() async {
    final userData = User(
        firstName: _firstNameTextController.text,
        lastName: _lastNameTextController.text,
        username: _usernameTextController.text,
        email: _emailTextController.text,
        password: _passwordTextController.text,
        phoneNumber: _phoneNumberController.text,
        bio: _bioController.text,
        identity_verification_status: _currUser.identity_verification_status,
        driver_verification_status: _currUser.driver_verification_status,
        car: _currUser.car,
        reports: _currUser.reports
        );
    if (widget.submitType == 'post') {
      setState(() {
        _doesUserExist = false;
      });
      try {
        await postUser(userData);
        Navigator.of(context).pushNamed('/login',arguments: {'message':'Account created, please login'});
      } catch (e) {
        debugPrint(e.toString());
        setState(() {
          _doesUserExist = true;
        });
      }
    } else {
      try {
        await patchUser(userData);
        Navigator.of(context).pushNamed('/profile');
      } catch (e) {
        print(e);
        setState(() {
        });
      }
    }
  }

  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _passwordTextController,
      _firstNameTextController,
      _lastNameTextController,
      _usernameTextController,
      _emailTextController,
      _phoneNumberController,
      _bioController
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
    String titleText;
    widget.submitType == 'post'
        ?  _formProgress > 0.99 
          ? titleText = 'Click to sign up'
          : titleText = 'Enter your details to sign up'
        : _formProgress > 0.99 
          ? titleText = 'Click to sign in'
          : titleText = 'Edit your profile details';
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titleText, style: Theme.of(context).textTheme.headlineMedium),
          AnimatedProgressIndicator(value: _formProgress),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              enabled: widget.submitType == 'post', 
              controller: _usernameTextController,
              decoration: InputDecoration(
                  labelText: 'Username',
                  errorMaxLines: 3,
                  errorText: _isUserNameValid
                      ? null
                      : 'Enter valid username: letters, numbers or underscore. 5-20 characters'),
              onChanged: (value) {
                final RegExp regex = RegExp(r'^[a-zA-Z0-9_]{5,20}$');
                setState(() {
                  _isUserNameValid = regex.hasMatch(value);
                });
              },
              readOnly: widget.submitType == 'post' ? false : true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _firstNameTextController,
              decoration: const InputDecoration(labelText: 'First name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _lastNameTextController,
              decoration: const InputDecoration(labelText: 'Last name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
                controller: _emailTextController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText:
                      _isEmailValid ? null : 'enter a valid email address',
                ),
                onChanged: (value) {
                  setState(() {
                    _isEmailValid = EmailValidator.validate(value);
                  });
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                  labelText: 'Phone Number',
                  errorText: _isPhoneNumberValid
                      ? null
                      : 'enter valid UK phone number'),
              onChanged: (value) {
                final RegExp regex = RegExp(
                    r'^(?:(?:\(?(?:0(?:0|11)\)?[\s-]?\(?|\+)44\)?[\s-]?(?:\(?0\)?[\s-]?)?)|(?:\(?0))(?:(?:\d{5}\)?[\s-]?\d{4,5})|(?:\d{4}\)?[\s-]?(?:\d{5}|\d{3}[\s-]?\d{3}))|(?:\d{3}\)?[\s-]?\d{3}[\s-]?\d{3,4})|(?:\d{2}\)?[\s-]?\d{4}[\s-]?\d{4}))(?:[\s-]?(?:x|ext\.?|\#)\d{3,4})?$');
                setState(() {
                  _isPhoneNumberValid = regex.hasMatch(value);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
                obscureText: _isPasswordObscured,
                controller: _passwordTextController,
                decoration: InputDecoration(
                    labelText: widget.submitType == 'post' 
                    ? 'Password'
                    : 'Enter you current password to make edits',
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
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
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
            onPressed: _formProgress > 0.99 ? _handleSubmit : null,
            child: Text(titleText),
          ),
          _doesUserExist
              ? Text('Username already exists',
                  style: Theme.of(context).textTheme.bodyLarge)
              : const Text(''),
        ],
      ),
    );
  }
}
