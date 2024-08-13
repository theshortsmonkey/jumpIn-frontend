import 'package:fe/classes/ride_class.dart';
import 'package:fe/utils/api_rides.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:fe/utils/api_users.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BuildContext context;
  final bool disableDefaultUserButton;
  final bool disableProfileButton;
  final bool disableLoginButton;
  final bool disableMailboxButton;
  final bool disableMainPageButton;
  final bool disablePostRideButton;
  final bool disableAllRidesButton;
  final bool isLoggedIn;

  const CustomAppBar(
      {super.key,
      required this.title,
      required this.context,
      this.disableDefaultUserButton = false,
      this.disableProfileButton = false,
      this.disableLoginButton = false,
      this.disableMailboxButton = false,
      this.disableMainPageButton = false,
      this.disablePostRideButton = false,
      this.disableAllRidesButton = false,
      this.isLoggedIn = false});

  void _setDefaultUser(context) async {
    try {
      final futureUser = await postLogin('user1', 'User123!');
      final userState = Provider.of<AuthState>(context, listen: false);
      userState.setActiveSession(futureUser);
      Navigator.of(context).pushNamed('/profile');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _calculatePriceTest() async {
    try {
      final fuelPriceFuture = await fetchFuelPrice('PETROL');
      print(fuelPriceFuture);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  void _postRideTest() async {
    final rideData = Ride(
      to: 'Leeds',
      toRegion: RegionsLabel.fromString('Yorkshire'),
      from: 'Durham',
      fromRegion: RegionsLabel.fromString('North East'),
      driverUsername: 'user1',
      carbonEmissions: 0,
      distance: 0,
      price: 2000,
      postAvailableSeats: SeatsLabel.fromInt(1),
      setDateTime: DateTime.now(),
    );
      final postedRide = await postRide(rideData);
      print(postedRide);
  }

  void _navigateToPage(String page) {
    Navigator.of(context).pushNamed('/$page');
  }

  void _handleLogout() {
    context.read<AuthState>().logout();
    Navigator.of(context).pushNamed('/');
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
                  image: AssetImage("web/images/logo.png"),
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
        if (!disableDefaultUserButton)
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: () { _setDefaultUser(context); },
            tooltip: 'Login default user',
          ),
          IconButton(
            icon: const Icon(Icons.abc),
            onPressed: () { _postRideTest(); },
            tooltip: 'testfunction',
          ),
          IconButton(
            icon: const Icon(Icons.currency_pound),
            onPressed: () { _calculatePriceTest(); },
            tooltip: 'testfunction',
          ),
        isLoggedIn
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.drive_eta),
                    onPressed: disableAllRidesButton
                        ? null
                        : () => _navigateToPage('allrides'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigation_rounded),
                    onPressed: disablePostRideButton
                        ? null
                        : () => _navigateToPage('postride'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_box_outlined),
                    onPressed: disableProfileButton
                        ? null
                        : () => _navigateToPage('profile'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _handleLogout,
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.login),
                onPressed:
                    disableLoginButton ? null : () => _navigateToPage('login'),
              ),
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: disableMainPageButton ? null : () => _navigateToPage(''),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
