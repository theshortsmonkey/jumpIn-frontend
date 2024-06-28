import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:fe/auth_provider.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:fe/route_generator.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
      ],
      child: const MyApp()
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {    
    return MaterialApp(
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
      onGenerateRoute: RouteGenerator.generateRoutes,
    );
  }
} 
