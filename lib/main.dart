import 'package:fe/edit_profile_page.dart';
import 'package:fe/single_ride_by_id.dart';
import 'package:fe/upload_profile_pic.dart';
import './login_page.dart';
import 'package:flutter/material.dart';
import './sign_up_page.dart';
import 'profile_page.dart';
import './homepage.dart';
import "post_ride_page.dart";
import './all_rides.dart';
import './single_ride.dart';
import './inbox.dart';
import 'package:google_fonts/google_fonts.dart';
import "./auth_provider.dart";
import 'package:provider/provider.dart';
import "./validate_licence.dart";
import "./validate_car.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        // other providers
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'jumpIn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade900),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          headlineSmall: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          bodyMedium: GoogleFonts.merriweather(),
        )
      ),
      home: const MyHomePage(title:"jumpIn"),
      routes: {
        "/signup" : (context) => const SignUpPage(),
        "/login" : (context) => const LoginPage(),
        '/profile': (context) => const ProfileScreen(),
        "/postride" : (context) => const PostRidePage(),
        "/allrides": (context) => const GetRide(),
        '/singleridetest': (context) => const SingleRide(),
        '/singleride': (context) => const SingleRideByID(),
        '/editprofile': (context) => const EditProfilePage(),
        '/inbox': (context) => const GetMessage(),
        '/uploadProfilePic': (context) => const UploadProfilePic(),
        '/validatelicence': (context) => const ValidateLicencePage(),
        '/validatecar': (context) => const ValidateCarPage(),
        }
    )
   );
  }
} 
