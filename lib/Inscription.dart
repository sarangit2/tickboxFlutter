// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Inscription extends StatefulWidget {
//   @override
//   _InscriptionState createState() => _InscriptionState();
// }

// class _InscriptionState extends State<Inscription> {
//   final TextEditingController _nomController = TextEditingController();
//   final TextEditingController _prenomController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _telephoneController = TextEditingController();
  
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _registerUser() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       User? user = userCredential.user;
      
//       if (user != null) {
//         // Enregistrer les informations de l'utilisateur dans Firestore
//         await _firestore.collection('users').doc(user.uid).set({
//           'nom': _nomController.text.trim(),
//           'prenom': _prenomController.text.trim(),
//           'email': email,
//           'telephone': _telephoneController.text.trim(),
//           'role': _getUserRole(email), // Déterminer le rôle basé sur l'email
//         });

//         // Rediriger vers la page de connexion après l'inscription
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Inscription réussie !')),
//         );
//       }
//     } catch (e) {
//       String errorMessage;
//       if (e is FirebaseAuthException) {
//         errorMessage = e.message ?? 'Erreur inconnue';
//       } else {
//         errorMessage = 'Erreur d\'inscription : ${e.toString()}';
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//     }
//   }

//   String _getUserRole(String email) {
//     if (email == 'admin@example.com') {
//       return 'admin';
//     } else if (email == 'formateur@example.com') {
//       return 'formateur';
//     } else {
//       return 'apprenant';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Inscription',
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: 24),
//             _buildTextField(_nomController, 'Entrer le nom'),
//             SizedBox(height: 16),
//             _buildTextField(_prenomController, 'Entrer le prenom'),
//             SizedBox(height: 16),
//             _buildTextField(_emailController, 'Entrer email'),
//             SizedBox(height: 16),
//             _buildTextField(_passwordController, 'Creer password', obscureText: true),
//             SizedBox(height: 16),
//             _buildTextField(_telephoneController, 'Entrer telephone'),
//             SizedBox(height: 32),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _registerUser,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[900],
//                   padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   "S'inscrire",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         hintText: hintText,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'admin_page.dart';
// import 'formateur_page.dart';
// import 'apprenant_page.dart';
// import 'inscription_page.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//  Future<void> _loginUser() async {
//   String email = _emailController.text.trim();
//   String password = _passwordController.text.trim();

//   try {
//     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     User? user = userCredential.user;

//     if (user != null) {
//       // Récupérer le rôle de l'utilisateur depuis Firestore
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       String userRole = userDoc['role'];

//       // Rediriger vers la page appropriée en fonction du rôle
//       if (userRole == 'admin') {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage()));
//       } else if (userRole == 'formateur') {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FormateurPage()));
//       } else {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ApprenantPage()));
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Connexion réussie !')),
//       );
//     }
//   } catch (e) {
//     String errorMessage;
//     if (e is FirebaseAuthException) {
//       errorMessage = e.message ?? 'Erreur inconnue';
//     } else {
//       errorMessage = 'Erreur de connexion : ${e.toString()}';
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(errorMessage)),
//     );
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Center(
//         child: ListView(
//           shrinkWrap: true,
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           children: [
//             const SizedBox(height: 32),
//             const Text(
//               'S\'authentifier',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Center(
//               child: Image.asset(
//                 'assets/login.png',
//                 height: 150,
//                 width: 150,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Center(
//               child: _buildTextField(_emailController, 'Entrer email', width: 300),
//             ),
//             const SizedBox(height: 16),
//             Center(
//               child: _buildTextField(_passwordController, 'Entrer mot de passe', obscureText: true, width: 300),
//             ),
//             const SizedBox(height: 32),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _loginUser,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF16335F), // Nouvelle couleur de fond du bouton
//                   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "Se connecter",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => InscriptionPage()),
//                   );
//                 },
//                 child: Text(
//                   "Vous n'avez pas de compte ? Inscrivez-vous",
//                   style: TextStyle(
//                     color: Colors.blue[900],
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 32), // Pour donner un peu d'espace en bas
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false, double? width}) {
//     return Container(
//       width: width,
//       child: TextField(
//         controller: controller,
//         obscureText: obscureText,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           hintText: hintText,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Taille réduite
//         ),
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'login_page.dart';

// class InscriptionPage extends StatefulWidget {
//   @override
//   _InscriptionPageState createState() => _InscriptionPageState();
// }

// class _InscriptionPageState extends State<InscriptionPage> {
//   final TextEditingController _nomController = TextEditingController();
//   final TextEditingController _prenomController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _telephoneController = TextEditingController();
//   final TextEditingController _roleController = TextEditingController();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _registerUser() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       User? user = userCredential.user;

//       if (user != null) {
//         // Enregistrer les informations de l'utilisateur dans Firestore
//         await _firestore.collection('users').doc(user.uid).set({
//           'nom': _nomController.text.trim(),
//           'prenom': _prenomController.text.trim(),
//           'email': email,
//           'telephone': _telephoneController.text.trim(),
//           'role': _roleController.text.trim(),
//         });

//         // Afficher un message de succès
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Inscription réussie !'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Rediriger vers la page de connexion après un délai pour montrer le SnackBar
//         Future.delayed(Duration(seconds: 2), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => LoginPage()),
//           );
//         });
//       }
//     } catch (e) {
//       String errorMessage;
//       if (e is FirebaseAuthException) {
//         errorMessage = e.message ?? 'Erreur inconnue';
//       } else {
//         errorMessage = 'Erreur d\'inscription : ${e.toString()}';
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         children: [
//           SizedBox(height: 32),
//           Text(
//             'Inscription',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//             textAlign: TextAlign.center, // Centrer le texte
//           ),
//           SizedBox(height: 24),
//           _buildTextField(_nomController, 'Entrer le nom'),
//           SizedBox(height: 16),
//           _buildTextField(_prenomController, 'Entrer le prénom'),
//           SizedBox(height: 16),
//           _buildTextField(_emailController, 'Entrer email'),
//           SizedBox(height: 16),
//           _buildTextField(_passwordController, 'Créer mot de passe', obscureText: true),
//           SizedBox(height: 16),
//           _buildTextField(_telephoneController, 'Entrer téléphone'),
//           SizedBox(height: 16),
//           _buildTextField(_roleController, 'Entrer le rôle'),
//           SizedBox(height: 32),
//           Center(
//             child: ElevatedButton(
//               onPressed: _registerUser,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF16335F), // Couleur du bouton
//                 padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 "S'inscrire",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
//     return Center(
//       child: SizedBox(
//         width: 300, // Ajustez la largeur des champs de texte
//         child: TextField(
//           controller: controller,
//           obscureText: obscureText,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             hintText: hintText,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(30),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//           ),
//         ),
//       ),
//     );
//   }
// }
