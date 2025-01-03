import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:learnings1/screens/login_blocscreen.dart';
import 'package:learnings1/blocs/login_bloc/login_bloc.dart';
import 'package:learnings1/blocs/signup_bloc/signup_bloc.dart';
import 'package:learnings1/session/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/splashscreen.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide session management
        BlocProvider(create: (_) => SessionCubit()),

        // Provide LoginBloc and link it to SessionCubit
        BlocProvider(
          create: (context) => LoginBloc(
            sessionCubit: context.read<SessionCubit>(),
          ),
        ),

        // Provide SignupBloc
        BlocProvider(create: (_) => SignupBloc()),
      ],
      child: MaterialApp(
        // scaffoldMessengerKey: snackbarKey,
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
        // Start with the splash screen
        home: SplashScreen(),
      ),
    );
  }
}
