import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:itgirls_hackathon/data/auth_datasource.dart';
import 'package:itgirls_hackathon/presentation/home_screen.dart';
import 'package:itgirls_hackathon/presentation/login_screen.dart';

import 'data/firebase_datasource.dart';
import 'firebase_options.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GetIt.I.registerSingleton(AuthDatasource());
  GetIt.I.registerSingleton(FirebaseDatasource());
  runApp(const ITGirlsHackathon());
}

class ITGirlsHackathon extends StatelessWidget {
  const ITGirlsHackathon({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _startingRoute(),
    );
  }

  Widget _startingRoute() {
    AuthDatasource authDatasource = AuthDatasource();
    if (authDatasource.isUserLoggedIn()) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}



