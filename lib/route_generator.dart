import 'package:fe/all_rides.dart';
import 'package:fe/edit_profile_page.dart';
import 'package:fe/homepage.dart';
import 'package:fe/login_page.dart';
import 'package:fe/post_ride_page.dart';
import 'package:fe/profile_page.dart';
import 'package:fe/sign_up_page.dart';
import 'package:fe/single_ride_by_id.dart';
import 'package:fe/upload_profile_pic.dart';
import 'package:fe/validate_car.dart';
import 'package:fe/validate_licence.dart';
import 'package:flutter/material.dart';

class RouteGenerator {

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    print('route settings');
    print(settings);
    switch(settings.name) {
      case '/':
        return MaterialPageRoute(settings: settings, builder: (context) => const MyHomePage(title:"jumpIn"));
      case '/signup':
        return MaterialPageRoute(settings: settings, builder: (context) => const SignUpPage());

      case '/login':
      print('in login route');
        return MaterialPageRoute(settings: settings, builder: (context) => const LoginPage());
        
      case '/profile':
      print('in profile route');
        return MaterialPageRoute(settings: settings, builder: (context) => const ProfileScreen());
        
      case '/postride':
        return MaterialPageRoute(builder: (context) => const PostRidePage());
        
      case '/allrides':
        return MaterialPageRoute(builder: (context) => const GetRide());
        
      case '/singleride':
        return MaterialPageRoute(builder: (context) => const SingleRideByID());

      case '/editprofile':
        return MaterialPageRoute(builder: (context) => const EditProfilePage());
        
      case '/uploadProfilePic':
        return MaterialPageRoute(builder: (context) => const UploadProfilePic());
        
      case '/validatelicence':
        return MaterialPageRoute(builder: (context) => const ValidateLicencePage());
        
      case '/validatecar':
        return MaterialPageRoute(builder: (context) => const ValidateCarPage());
        
      default:
        // return MaterialPageRoute(builder: (context) => const MyHomePage(title:"jumpIn"));
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}