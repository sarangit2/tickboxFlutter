import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_page.dart';
import 'formateur_page.dart';
import 'apprenant_page.dart';
import 'inscription_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

 Future<void> _loginUser() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
 print("TESjjjjjjjjjjjjjj");
    User? user = userCredential.user;
print("$user: testing");
    if (user != null) {
      // Récupérer le rôle de l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('USERS').doc(user.uid).get();
      String userRole = userDoc['role'];
      print("$userRole:=============================jjjjjjjjjjjjjj");

      // Rediriger vers la page appropriée en fonction du rôle
      if (userRole == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage()));
        print("$userRole:============================= admin");
      } else if (userRole == 'formateur') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FormateurPage()));
        print("$userRole:============================= formateur");
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ApprenantPage()));
        print("$userRole:============================= apprenant");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie !')),
      );
    }
  } catch (e) {
    String errorMessage;
    if (e is FirebaseAuthException) {
      errorMessage = e.message ?? 'Erreur inconnue';
    } else {
      errorMessage = 'Erreur de connexion : ${e.toString()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 32),
            const Text(
              'S\'authentifier',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/login.png',
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: _buildTextField(_emailController, 'Entrer email', width: 300),
            ),
            const SizedBox(height: 16),
            Center(
              child: _buildTextField(_passwordController, 'Entrer mot de passe', obscureText: true, width: 300),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF16335F), // Nouvelle couleur de fond du bouton
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Se connecter",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => InscriptionPage()),
                  );
                },
                child: Text(
                  "Vous n'avez pas de compte ? Inscrivez-vous",
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32), // Pour donner un peu d'espace en bas
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false, double? width}) {
    return Container(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Taille réduite
        ),
      ),
    );
  }
}
