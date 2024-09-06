import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticketsPage.dart'; // Assurez-vous que cette importation est correcte
import 'accueil_page.dart'; // Assurez-vous que cette importation est correcte
import 'inscription_page.dart'; // Assurez-vous que cette importation est correcte

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;

        if (user != null) {
          // Récupérer le rôle de l'utilisateur depuis Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('USERS').doc(user.uid).get();
          String userRole = userDoc['role'];

          // Afficher le rôle récupéré pour débogage
          print('Utilisateur connecté : ${user.email}');
          print('Rôle de l\'utilisateur : $userRole');

          // Rediriger vers la page appropriée en fonction du rôle
          if (userRole == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AccueilPage()));
          } else if (userRole == 'formateur') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TicketsPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TicketsPage()));
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/tickbox.png',
                    height: 130,
                    width: 130,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _buildTextField(
                    controller: _emailController,
                    hintText: 'Entrer email',
                    width: 300,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: _buildTextField(
                    controller: _passwordController,
                    hintText: 'Entrer mot de passe',
                    obscureText: true,
                    width: 300,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF16335F),
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
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    double? width,
    required String? Function(String?) validator,
  }) {
    return Container(
      width: width,
      child: TextFormField(
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
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}
