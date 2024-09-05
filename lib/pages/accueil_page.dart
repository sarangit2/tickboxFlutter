import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tick_box/pages/chatPage.dart';
import 'package:tick_box/pages/profilePage.dart';
import 'package:tick_box/pages/ticketsPage.dart';

class AccueilPage extends StatefulWidget {
  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final Color primaryColor = Color(0xFF16335F); // Couleur #16335F
  int _selectedIndex = 0;

  int _submittedCount = 0;
  int _inProgressCount = 0;
  int _resolvedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTicketCounts();
  }

  void _fetchTicketCounts() async {
    final submittedQuery = await FirebaseFirestore.instance
        .collection('tickets')
        .where('status', isEqualTo: 'Soumis')
        .get();

    final inProgressQuery = await FirebaseFirestore.instance
        .collection('tickets')
        .where('status', isEqualTo: 'EnCours')
        .get();

    final resolvedQuery = await FirebaseFirestore.instance
        .collection('tickets')
        .where('status', isEqualTo: 'Résolu')
        .get();

    setState(() {
      _submittedCount = submittedQuery.docs.length;
      _inProgressCount = inProgressQuery.docs.length;
      _resolvedCount = resolvedQuery.docs.length;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Naviguer vers la page correspondante
    switch (index) {
      case 0:
        // Vous êtes déjà sur la page "Accueil", ne rien faire ou rafraîchir si nécessaire
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketsPage()), // Remplacez par votre page "Tickets"
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketsPage()), // Remplacez par votre page "Chat"
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()), // Remplacez par votre page "Profile"
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer les informations de l'utilisateur connecté
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Accueil'),
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
            _buildProfileSection(user),
            SizedBox(height: 16.0),
            _buildTicketStats(),
            SizedBox(height: 16.0),
            _buildRecentTickets(),
            SizedBox(height: 16.0),
            _buildGraph(),
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

  Widget _buildTicketStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Soumis', _submittedCount.toString()),
        _buildStatCard('EnCours', _inProgressCount.toString()),
        _buildStatCard('Résolu', _resolvedCount.toString()),
      ],
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Couleur des statistiques
              ),
            ),
            Text(title, style: TextStyle(color: primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTickets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .orderBy('dateAdded', descending: true) // Trier par date ajoutée en ordre décroissant
          .limit(3) // Limiter à 3 tickets
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur de chargement des tickets'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucun ticket récent'));
        }

        final tickets = snapshot.data!.docs;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tickets récents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Titre')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: tickets.map<DataRow>((ticket) {
                    final status = ticket['status'] ?? 'Inconnu';
                    final dateAdded = ticket['dateAdded']?.toDate();
                    final formattedDate = dateAdded != null
                        ? "${dateAdded.toLocal().day}/${dateAdded.toLocal().month}/${dateAdded.toLocal().year}"
                        : 'N/A';
                    final statusColor = _getStatusColor(status);

                    return DataRow(
                      cells: [
                        DataCell(Text(ticket['title'] ?? '')),
                        DataCell(Text(formattedDate)),
                        DataCell(
                          Container(
                            color: statusColor, // Couleur de fond du statut
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              status,
                              style: TextStyle(color: Colors.white), // Couleur du texte
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
                                  
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Remplir tout l'espace horizontal
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Couleur de fond du bouton
                ),
                onPressed: () {
                  // Gérer l'action du bouton
                },
                child: Text('Générer rapport'),
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 150.0,
              child: _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Placeholder pour un diagramme à barres, vous pouvez utiliser un package comme charts_flutter ou fl_chart
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBar('Mon', 60),
        _buildBar('Tue', 80),
        _buildBar('Wed', 70),
        _buildBar('Thu', 90),
        _buildBar('Fri', 50),
        _buildBar('Sat', 90),
        _buildBar('Sun', 70),
      ],
    );
  }

  Widget _buildBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          color: primaryColor, // Couleur des barres du graphique
        ),
        SizedBox(height: 4.0),
        Text(label),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: primaryColor, // Couleur de l'élément sélectionné
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tickets'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
