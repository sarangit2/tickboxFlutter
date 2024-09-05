import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tick_box/pages/chatPage.dart';

class TicketsPage extends StatelessWidget {
  final Color primaryColor = Color(0xFF16335F); // Couleur #16335F
  final Color greenColor = Colors.green;
  final Color orangeColor = Colors.orange;
  final Color redColor = Colors.red;
// Récupérer les informations de l'utilisateur connecté
    final user = FirebaseAuth.instance.currentUser;

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = userDoc['role'];
      return role;
    }
    return 'apprenant'; // Default to 'apprenant' if no user is found
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Tickets'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
  future: _getUserRole(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    final role = snapshot.data ?? 'apprenant';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          _buildProfileSection(user, context),
        _buildCategorySection(context, role),
       
        SizedBox(height: 16.0),
        _buildTicketSection(context, role),
      ],
    );
  },
),

           
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  
 Widget _buildProfileSection(User? user, BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/profile_pic.png'), // Ajoutez votre image de profil ici
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(user?.email ?? 'Email de l\'utilisateur', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 8.0),
                Text(
                  'Gestion des tickets',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.remove_red_eye, color: primaryColor),
              onPressed: () {
                _showUserDetailsDialog(context, user);
              },
            ),
          ],
        ),
      ),
    );
  }


 void _showUserDetailsDialog(BuildContext context, User? user) {
    if (user == null) return;

    final TextEditingController nameController = TextEditingController(text: user.displayName);
    final TextEditingController emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop(); // Fermer le modal
                      },
                    ),
                  ],
                ),
                Text(
                  'Détails de l\'utilisateur',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Mettre à jour les détails de l'utilisateur
                    final updatedName = nameController.text;
                    final updatedEmail = emailController.text;

                    try {
                      await user.updateProfile(displayName: updatedName);
                      await user.updateEmail(updatedEmail);

                      // Optionnel : Mettre à jour dans Firestore aussi
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'displayName': updatedName,
                        'email': updatedEmail,
                      });

                      Navigator.of(context).pop(); // Fermer le modal
                    } catch (e) {
                      // Gérer les erreurs
                      print(e);
                    }
                  },
                  child: Text('Sauvegarder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



Widget _buildCategorySection(BuildContext context, String role) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
       if (role == 'formateur' || role =='admin') // Vérifie si le rôle n'est pas 'apprenant'
      Text(
        'Category',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
     
        IconButton(
          icon: Icon(Icons.add_circle, color: greenColor),
          onPressed: () {
            _showAddCategoryDialog(context);
          },
        ),
    ],
  );
}

Widget _buildTicketSection(BuildContext context, String role) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tickets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          if (role == 'apprenant' || role == 'admin')
            IconButton(
              icon: Icon(Icons.add_circle, color: greenColor),
              onPressed: () {
                _showAddTicketDialog(context);
              },
            ),
        ],
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Pas de tickets disponible.'));
          }
          final tickets = snapshot.data!.docs;

          return DataTable(
            columns: [
              DataColumn(label: Text('Titre')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Statut')),
              DataColumn(label: Text('Actions')),
            ],
            rows: tickets.map((ticket) {
              final status = ticket['status'];
              final statusColor = _getStatusColor(status);

              return DataRow(
                cells: [
                  DataCell(Text(ticket['title'])),
                  DataCell(Text(ticket['dateAdded']?.toDate()?.toLocal()?.toString() ?? 'N/A')),
                  DataCell(
                    Container(
                      color: statusColor,
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        status,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility, color: primaryColor),
                          onPressed: () {
                            _showTicketDetailsDialog(
                              context,
                              ticket.id,
                              ticket['title'],
                              ticket['description'],
                              ticket['category'],
                              status,
                            );
                          },
                        ),
                        if (status == 'Résolu')
                          IconButton(
                            icon: Icon(Icons.chat, color: Colors.blue),
                            onPressed: () {
                              _startChat(context, ticket['userId']); // Remplacez 'userId' par l'ID utilisateur du ticket
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.edit, color: status == 'Résolu' ? Colors.grey : primaryColor),
                          onPressed: status == 'Résolu' ? null : () {
                            _showEditTicketDialog(
                              context,
                              ticket.id,
                              ticket['title'],
                              ticket['description'],
                              ticket['category'],
                              status,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: redColor),
                          onPressed: () {
                            _deleteTicket(ticket.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}

void _startChat(BuildContext context, String userId) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ChatPage(userId: userId),
    ),
  );
}


    Color _getStatusColor(String status) {
    switch (status) {
      case 'Résolu':
        return Colors.green;
      case 'Soumis':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

 void _showTicketDetailsDialog(BuildContext context, String id, String title, String description, String category, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer le modal
                          },
                        ),
                      ],
                    ),
                    Text(
                      'Détails du ticket',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Text('Titre: $title', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8.0),
                    Text('Description: $description', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8.0),
                    Text('Catégorie: $category', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8.0),
                    Text('Statut: $status', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tickets'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer le modal
                          },
                        ),
                      ],
                    ),
                    Text(
                      'Ajouter une catégorie',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    AddCategoryForm(),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 void _showAddTicketDialog(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop(); // Fermer le modal
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Ajouter un ticket',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  AddTicketForm(userId: user?.uid),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showEditTicketDialog(BuildContext context, String id, String title, String description, String category, String status) {
  final _responseController = TextEditingController(); // Contrôleur pour la réponse

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop(); // Fermer le modal
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Repondre le ticket',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  EditTicketForm(
                    id: id,
                    title: title,
                    description: description,
                    category: category,
                    status: status,
                  ),
                  if (status != 'Résolu') // Ajouter le champ de réponse si le ticket n'est pas résolu
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.0),
                        Text(
                          'Réponse',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: _responseController,
                          decoration: InputDecoration(labelText: 'Entrez votre réponse'),
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La réponse est requise';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_responseController.text.isNotEmpty) {
                        // Mettre à jour le ticket avec la réponse dans Firebase
                        await FirebaseFirestore.instance.collection('tickets').doc(id).update({
                          'response': _responseController.text, // Ajouter la réponse
                          'status': 'Résolu',
                        });
                      }
                      Navigator.of(context).pop(); // Fermer le modal après l'enregistrement
                    },
                    child: Text('Enregistrer les modifications'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  void _deleteTicket(String id) async {
    await FirebaseFirestore.instance.collection('tickets').doc(id).delete();
  }
}

class AddCategoryForm extends StatefulWidget {
  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nom'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La description est requise';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                await FirebaseFirestore.instance.collection('categories').add({
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                });
                Navigator.of(context).pop(); // Fermer le modal
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class AddTicketForm extends StatefulWidget {
  final String? userId;

  AddTicketForm({this.userId});

  @override
  _AddTicketFormState createState() => _AddTicketFormState();
}

class _AddTicketFormState extends State<AddTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Titre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le titre est requis';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La description est requise';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Choisir une catégorie'),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'La catégorie est requise';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                await FirebaseFirestore.instance.collection('tickets').add({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'category': _selectedCategory,
                  'status': 'Soumis', // Définir le statut par défaut à "Soumis"
                  'dateAdded': DateTime.now(),
                  'userId': widget.userId, // Inclure l'ID de l'utilisateur ici
                });
                Navigator.of(context).pop(); // Fermer le modal
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _fetchCategories() async {
    // Récupère les catégories depuis Firestore
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }
}


Future<List<String>> _fetchCategories() async {
  final snapshot = await FirebaseFirestore.instance.collection('categories').get();
  return snapshot.docs.map((doc) => doc['name'] as String).toList();
}
class EditTicketForm extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;

  EditTicketForm({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
  });

  @override
  _EditTicketFormState createState() => _EditTicketFormState();
}

class _EditTicketFormState extends State<EditTicketForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedCategory = widget.category;
    _fetchCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Titre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le titre est requis';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La description est requise';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Choisir une catégorie'),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'La catégorie est requise';
              }
              return null;
            },
          ),
        
        ],
      ),
    );
  }
}
