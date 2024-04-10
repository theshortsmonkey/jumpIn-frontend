// import 'dart:ffi';
import 'package:fe/api.dart';
import 'package:flutter/material.dart';
import "./auth_provider.dart";
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BuildContext context;
  final bool showDefaultUserButton;
  final bool showProfileButton;
  final bool showLoginButton;
  final bool showLogoutButton;
  final bool showMainPageButton;
  final bool showPostRideButton;
  final bool showAllRidesButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.context,
    this.showDefaultUserButton = false,
    this.showProfileButton = true,
    this.showLoginButton = true,
    this.showLogoutButton = true,
    this.showMainPageButton = true,
    this.showPostRideButton = true,
    this.showAllRidesButton = true,
  }) : super(key: key);

  void _setDefaultUser() async {
    final futureUser = await fetchUserByUsername('testUSername1');
    final userState = Provider.of<AuthState>(context, listen:false);
    userState.setUser(futureUser);
    Navigator.of(context).pushNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthState>().isAuthorized;

    return AppBar(
      backgroundColor: theme.colorScheme.inversePrimary,
      leading: ClipOval(
        child: Transform.scale(
          scale: 1.6,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("../web/icons/logo.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment(-0.2, -0.2),
                ),
              ),
            ),
          ), 
        ),
      ),
      title: Text(title),
      actions: [
        if (showDefaultUserButton)
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: _setDefaultUser,
            tooltip: 'Login default user',
          ),
        if (isLoggedIn && showPostRideButton)
          IconButton(
            icon: const Icon(Icons.navigation_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed('/postride');
            },
          ),
        if (isLoggedIn && showAllRidesButton)
          IconButton(
            icon: const Icon(Icons.drive_eta),
            onPressed: () {
              Navigator.of(context).pushNamed('/allrides');
            },
          ),
        if (isLoggedIn && showProfileButton)
          IconButton(
            icon: const Icon(Icons.account_box_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        if (!isLoggedIn && showLoginButton)
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
          ),
        if (isLoggedIn && showLogoutButton)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthState>().logout();
              Navigator.of(context).pushNamed('/');
            },
          ),
        if (isLoggedIn && showLoginButton)
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              Navigator.of(context).pushNamed('/inbox');
            },
          ),
        if (showMainPageButton)
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
                context.read<AuthState>();
                Navigator.of(context).pushNamed('/');
              },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

