import 'package:fe/utils/api_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import "package:fe/appbar.dart";
import 'package:fe/utils/background.dart';
import 'package:fe/utils/api_users.dart';
import 'package:fe/classes/user_class.dart';
import 'package:fe/user/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDeleted = false;
  bool _areYouSure = false;
  String _deleteButtonText = 'Delete your account';
  ActiveSession _currUser = const ActiveSession();
  User _userData = const User();
  String _imgUrl = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    try {
      final userState = Provider.of<AuthState>(context, listen: false);
      final activeUser = await userState.checkActiveSession();
      userState.isAuthorized
          ? userState.setActiveSession(activeUser)
          : throw Exception('no active user');
      _currUser = userState.userInfo;
      _imgUrl = "$baseUrl/users/${_currUser.username}/image";
      final userData = await fetchUserByUsername(_currUser.username);
      setState(() {
        _userData = userData;
        _loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  void _handleDelete() async {
    if (_areYouSure) {
      deleteUser(_userData);
      setState(() {
        _isDeleted = true;
      });
      await Future.delayed(const Duration(seconds: 5), () {
        context.read<AuthState>().logout();
        Navigator.of(context).pushNamed('/');
      });
    } else {
      setState(() {
        _areYouSure = true;
        _deleteButtonText =
            'Your account is going to be destroyed! Are you sure?';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return context.read<AuthState>().isAuthorized
        ? Scaffold(
            appBar: CustomAppBar(
              title: 'jumpIn - Your Account',
              context: context,
              disableProfileButton: true,
            ),
            body: ContainerWithBackgroundImage(
              child: _loading
                  ? const CircularProgressIndicator()
                  : _isDeleted
                      ? Center(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: 400,
                              child: Column(
                                children: [
                                  itemProfile('Account Deleted', '',
                                      CupertinoIcons.person_badge_minus)
                                ],
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/editprofile');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(15),
                                    ),
                                    child: const Text('Edit Profile')),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/uploadProfilePic');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(15),
                                    ),
                                    child:
                                        const Text('Upload Profile Picture')),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: _currUser.isDriver
                                      ? Colors.green
                                      : Colors.amberAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundImage: NetworkImage(_imgUrl),
                                ),
                              ),
                              const SizedBox(height: 20),
                              itemProfile('Username', _userData.username,
                                  CupertinoIcons.location),
                              const SizedBox(height: 10),
                              itemProfile(
                                  'First Name, Last Name',
                                  '${_userData.firstName}, ${_userData.lastName}',
                                  CupertinoIcons.person),
                              const SizedBox(height: 10),
                              itemProfile('Email', '${_userData.email}',
                                  CupertinoIcons.mail),
                              const SizedBox(
                                height: 20,
                              ),
                              itemProfile('Phone', '${_userData.phoneNumber}',
                                  CupertinoIcons.phone),
                              const SizedBox(
                                height: 20,
                              ),
                              itemProfile('Bio', '${_userData.bio}',
                                  CupertinoIcons.profile_circled),
                              const SizedBox(height: 20),
                              _userData.identityVerificationStatus
                                  ? itemProfile(
                                      'Licence valid: ',
                                      '${_userData.identityVerificationStatus}',
                                      CupertinoIcons.check_mark)
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushNamed('/validatelicence');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(15),
                                          ),
                                          child:
                                              const Text('Validate Licence')),
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              _userData.car != null
                                  ? carBox(_userData.car)
                                  : const SizedBox.shrink(),
                              const SizedBox( height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/validatecar');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(15),
                                    ),
                                    child: _userData.car != null
                                        ? const Text('Change vehicle')
                                        : const Text('Add Vehicle')),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: _handleDelete,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(15),
                                      ),
                                      child: Text(_deleteButtonText))),
                            ]),
                          ),
                        ),
            ),
          )
        : const LoginPage();
  }

  carBox(car) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 5),
                color: Colors.lightGreen.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: Column(children: [
        const SizedBox(
          height: 20,
        ),
        itemProfile('Registration number: ', '${car["reg"]}',
            CupertinoIcons.check_mark),
        const SizedBox(
          height: 20,
        ),
        itemProfile('Make: ', '${car["make"]}', CupertinoIcons.check_mark),
        const SizedBox(
          height: 20,
        ),
        itemProfile('Colour: ', '${car["colour"]}', CupertinoIcons.check_mark),
        const SizedBox(
          height: 20,
        ),
        itemProfile('Tax Due Date: ', '${car["tax_due_date"]}',
            CupertinoIcons.check_mark),
        const SizedBox(
          height: 20,
        ),
        itemProfile(
            'Fuel Type: ', '${car["fuelType"]}', CupertinoIcons.check_mark),
        const SizedBox(
          height: 20,
        ),
        itemProfile('CO2 Emissions: ', '${car["co2Emissions"]}',
            CupertinoIcons.check_mark),
      ]),
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
                color: Colors.lightGreen.withOpacity(.2),
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
