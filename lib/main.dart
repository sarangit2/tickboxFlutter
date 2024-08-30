import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCvRl72pG0Tq_zh4r6D1F-em0QtQhRZdcg",
        authDomain: "tick-box-8a323.firebaseapp.com",
        projectId: "tick-box-8a323",
        storageBucket: "tick-box-8a323.appspot.com",
        messagingSenderId: "161244567953",
        appId: "1:161244567953:web:aa455c7d0a10142d27e230",
        measurementId: "G-SY9EGEYB1X",
      ),
    );
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Utilisateurs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),  // Utiliser `WelcomePage` comme page d'accueil
    );
  }
}
