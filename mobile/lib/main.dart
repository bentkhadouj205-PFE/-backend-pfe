
// MAIN.DART - Entry point w l-main widget kamal

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';  // page1 ta3 app ..spash screen
import 'screens/bienvenue_screen.dart'; // page2 ta3 app ..beinvenue screen
import 'screens/creation_screen.dart';  //page 3 ta3 app ..creation compte screen
import 'screens/connexion_screen.dart';  // page 4 ta3 app ..connexion screen
import 'screens/home_screen.dart';  // page 5 ta3 app ..home screen (ba3d connexion)
import 'screens/naissance_screen.dart';  // page 6 ta3 app ..extrait de naissance screen

void main() {
  runApp(const PfeApp());
}

// PFE APP - Main widget

class PfeApp extends StatelessWidget {
  const PfeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baladiya Digital', // 1. ism l-app 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/', // li tbda bih i app
      routes: {
        '/': (context) => const SplashScreen(),
        '/bienvenue': (context) => const BienvenueScreen(),
        '/creation': (context) => const CreationScreen(),  
        '/connexion': (context) => const ConnexionScreen(),  
        '/home': (context) => const HomeScreen(),  
        '/naissance': (context) => const ExtraitNaissanceScreen(),  


      },
    );
  }
}