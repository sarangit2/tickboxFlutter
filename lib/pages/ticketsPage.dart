import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ajoutez cette ligne
import 'package:flutter/material.dart';

// Page de Tickets avec intégration des Catégories
class TicketsPage extends StatelessWidget {
  final Color primaryColor = Color(0xFF16335F); // Couleur #16335F
  final Color greenColor = Colors.green;
  final Color orangeColor = Colors.orange;
  final Color redColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    // Récupérer les informations de l'utilisateur connecté
    final user = FirebaseAuth.instance.currentUser;

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
            _buildProfileSection(user), // Passer l'utilisateur au widget
            SizedBox(height: 16.0),
            _buildCategorySection(context),
            SizedBox(height: 16.0),
            _buildTicketSection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileSection(User? user) {
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
                // Gérer la visibilité
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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

  Widget _buildTicketSection(BuildContext context) {
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
              return Center(child: Text('No tickets available.'));
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
                return DataRow(
                  cells: [
                    DataCell(Text(ticket['title'])),
                    DataCell(Text(ticket['dateAdded']?.toDate()?.toLocal()?.toString() ?? 'N/A')),
                    DataCell(Text(ticket['status'])),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () {
                              _showEditTicketDialog(
                                context,
                                ticket.id,
                                ticket['title'],
                                ticket['description'],
                                ticket['category'],
                                ticket['status'],
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
                    AddTicketForm(),
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
                      'Modifier le ticket',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    EditTicketForm(id: id, title: title, description: description, category: category, status: status),
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

  void _deleteTicket(String id) async {
    await FirebaseFirestore.instance.collection('tickets').doc(id).delete();
  }

  

}

// Les classes AddCategoryForm, AddTicketForm et EditTicketForm restent inchangées


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
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _addCategory();
                Navigator.of(context).pop(); // Fermer le modal
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _addCategory() async {
    final name = _nameController.text;
    final description = _descriptionController.text;

    await FirebaseFirestore.instance.collection('categories').add({
      'name': name,
      'description': description,
    });
  }
}

class AddTicketForm extends StatefulWidget {
  @override
  _AddTicketFormState createState() => _AddTicketFormState();
}

class _AddTicketFormState extends State<AddTicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String _status = 'Soumis';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('categories').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No categories available.'));
        }
        final categories = snapshot.data!.docs;

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
                items: categories.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Catégorie'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La catégorie est requise';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _addTicket();
                    Navigator.of(context).pop(); // Fermer le modal
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTicket() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    await FirebaseFirestore.instance.collection('tickets').add({
      'title': title,
      'description': description,
      'dateAdded': FieldValue.serverTimestamp(),
      'category': _selectedCategory,
      'status': _status,
    });
  }
}

class EditTicketForm extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;

  EditTicketForm({required this.id, required this.title, required this.description, required this.category, required this.status});

  @override
  _EditTicketFormState createState() => _EditTicketFormState();
}

class _EditTicketFormState extends State<EditTicketForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  String _status = 'Résolu'; // Set the default status to "Résolu"

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('categories').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text('No categories available.'));
        }
        final categories = snapshot.data!.docs;

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
                items: categories.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Catégorie'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La catégorie est requise';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _updateTicketStatus(widget.id, _status); // Update status to "Résolu"
                    Navigator.of(context).pop(); // Fermer le modal
                  }
                },
                child: Text('Modifier'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTicketStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('tickets').doc(id).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'status': status,
    });
  }
}
