import 'package:flutter/material.dart';
import 'package:fe/all_rides.dart';
import 'package:fe/user/edit_profile_page.dart';
import 'package:fe/homepage.dart';
import 'package:fe/user/login_page.dart';
import 'package:fe/post_ride_page.dart';
import 'package:fe/user/profile_page.dart';
import 'package:fe/user/sign_up_page.dart';
import 'package:fe/single_ride_by_id.dart';
import 'package:fe/user/upload_profile_pic_page.dart';
import 'package:fe/user/validate_car_page.dart';
import 'package:fe/user/validate_licence_page.dart';

class RouteGenerator {

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        return MaterialPageRoute(settings: settings, builder: (context) => const MyHomePage(title:"jumpIn"));
      case '/signup':
        return MaterialPageRoute(settings: settings, builder: (context) => const SignUpPage());

      case '/login':
        return MaterialPageRoute(settings: settings, builder: (context) => const LoginPage());
        
      case '/profile':
        return MaterialPageRoute(settings: settings, builder: (context) => const ProfileScreen());
        
      case '/postride':
        return MaterialPageRoute(settings: settings, builder: (context) => const PostRidePage());
        
      case '/allrides':
        return MaterialPageRoute(settings: settings, builder: (context) => const GetRide());
        
      case '/singleride':
        return MaterialPageRoute(settings: settings, builder: (context) => const SingleRideByID());

      case '/editprofile':
        return MaterialPageRoute(builder: (context) => const EditProfilePage());
        
      case '/uploadProfilePic':
        return MaterialPageRoute(builder: (context) => const UploadProfilePicPage());
        
      case '/validatelicence':
        return MaterialPageRoute(builder: (context) => const ValidateLicencePage());
        
      case '/validatecar':
        return MaterialPageRoute(builder: (context) => const ValidateCarPage());
        
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}