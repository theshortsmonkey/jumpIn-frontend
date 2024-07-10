import 'package:flutter/material.dart';
import 'package:fe/homepage.dart';
import 'package:fe/user/sign_up_page.dart';
import 'package:fe/user/login_page.dart';
import 'package:fe/user/profile_page.dart';
import 'package:fe/ride/post_ride_page.dart';
import 'package:fe/ride/edit_ride_page.dart';
import 'package:fe/ride/all_rides.dart';
import 'package:fe/ride/ride_page.dart';
import 'package:fe/user/edit_profile_page.dart';
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
        return MaterialPageRoute(settings: settings, builder: (context) => const ProfilePage());
        
      case '/postride':
        return MaterialPageRoute(settings: settings, builder: (context) => const PostRidePage());
      
      case '/editride':
        RouteSettings customSettings = RouteSettings(name: '/singleride',arguments: settings.arguments);
        return MaterialPageRoute(settings: customSettings, builder: (context) => const EditRidePage());
        
      case '/allrides':
        return MaterialPageRoute(settings: settings, builder: (context) => const AllRidesPage());
        
      case '/singleride':
        return MaterialPageRoute(settings: settings, builder: (context) => const RidePage());

      case '/editprofile':
        RouteSettings customSettings = RouteSettings(name: '/profile',arguments: settings.arguments);
        return MaterialPageRoute(settings: customSettings, builder: (context) => const EditProfilePage());
        
      case '/uploadProfilePic':
        RouteSettings customSettings = RouteSettings(name: '/profile',arguments: settings.arguments);
        return MaterialPageRoute(settings: customSettings, builder: (context) => const UploadProfilePicPage());
        
      case '/validatelicence':
        RouteSettings customSettings = RouteSettings(name: '/profile',arguments: settings.arguments);
        return MaterialPageRoute(settings: customSettings, builder: (context) => const ValidateLicencePage());
        
      case '/validatecar':
        RouteSettings customSettings = RouteSettings(name: '/profile',arguments: settings.arguments);
        return MaterialPageRoute(settings: customSettings, builder: (context) => const ValidateCarPage());
        
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}