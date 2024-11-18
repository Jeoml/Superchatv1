import 'package:flutter/material.dart';
import 'package:learnings1/screens/auth_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:learnings1/services/signup_service.dart';
import './app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:learnings1/services/pdf_api_Service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(
    Duration(seconds: 1),
  );
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: snackbarKey,
      debugShowCheckedModeBanner: false,
      title: 'Superchat',
      theme: ThemeData(
        primaryColor: MyTheme.kPrimaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: MyTheme.kAccentColor),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(),
    );
  }
}