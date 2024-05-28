import 'package:fe/animated_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fe/api.dart';
import "package:fe/auth_provider.dart";
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _isPasswordObscured = true;
  double _formProgress = 0;
  bool _isUserExist = true;
  bool _isLoginFailed = false;
  bool _isLoginSuccesful = false;

  void _handleLogin() async {
    setState(() {
      _isLoginFailed = false;
      _isLoginSuccesful = false;
    });
    try {
      final futureUser = await postLogin(
          _usernameTextController.text, _passwordTextController.text);
      final provider = Provider.of<AuthState>(context, listen: false);
      provider.setActiveSession(futureUser);
      setState(() {
        _isLoginSuccesful = true;
      });
      await Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushNamed('/');
      });
    } on Exception catch (e) {
      if (e.toString() == "Exception: Unauthorised") {
        setState(() {
          _isLoginFailed = true;
        });
      } else if (e.toString() == "Exception: User not found") {
        setState(() {
          _isUserExist = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showSignupPage() {
    Navigator.of(context).pushNamed(
      '/signup',
    );
  }

  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _usernameTextController,
      _passwordTextController,
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
    return !_isUserExist
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              itemProfile('Username does not exist', '',
                  CupertinoIcons.person_badge_minus),
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
                onPressed: _showSignupPage,
                child: const Text('You can Sign up here'),
              ),
            ],
          )
        : Form(
            onChanged: _updateFormProgress,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedProgressIndicator(value: _formProgress),
                Text('Login to your account',
                    style: Theme.of(context).textTheme.headlineMedium),
                _isLoginFailed
                    ? Text('Incorrect password',
                        style: Theme.of(context).textTheme.headlineSmall)
                    : const SizedBox.shrink(),
                _isLoginSuccesful
                    ? Text('Login successful - redirecting to homepage',
                        style: Theme.of(context).textTheme.headlineSmall)
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _usernameTextController,
                    decoration: const InputDecoration(hintText: 'Username'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordObscured
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: _setIsPasswordObscured,
                        )),
                    controller: _passwordTextController,
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.white;
                    }),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.blue;
                    }),
                  ),
                  onPressed: _formProgress > 0.99 ? _handleLogin : null,
                  child: const Text('Login'),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.white;
                    }),
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.blue;
                    }),
                  ),
                  onPressed: _showSignupPage,
                  child: const Text('Sign up'),
                ),
              ],
            ),
          );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 5),
                color: Colors.deepOrange.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        tileColor: Colors.white,
      ),
    );
  }
}
