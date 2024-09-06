import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_page.dart';  // Assurez-vous que ce chemin est correct

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Démarrer un timer pour afficher la page de chargement pendant 3 secondes
    Timer(Duration(seconds: 3), () {
      // Naviguer vers la page d'accueil après 3 secondes
        Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color(0xFFE5E5E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image ou logo de chargement
            Image.asset('assets/tickbox.png', width: 150, height: 150),
            SizedBox(height: 20),
           
          ],
        ),
      ),
    );
  }
}
