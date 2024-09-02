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
          MaterialPageRoute(builder: (context) => TicketsPage()), // Page "Tickets"
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage()), // Page "Chat"
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()), // Page "Profile"
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildProfileSection(),
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
        _buildStatCard('Soumis', '15'),
        _buildStatCard('EnCours', '11'),
        _buildStatCard('Resolu', '5'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tickets récents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            _buildTicketRow('01.', 'Trivago', '2024-06-02', 'Resolu', Colors.green),
            _buildTicketRow('02.', 'Canon', '2024-06-02', 'Resolu', Colors.green),
            _buildTicketRow('03.', 'Uber Food', '2024-06-02', 'EnCour', Colors.orange),
            _buildTicketRow('04.', 'Nokia', '2024-06-02', 'Resolu', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String no, String title, String date, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(no),
          Expanded(
            child: Text(title, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(date),
          Text(status, style: TextStyle(color: statusColor)),
        ],
      ),
    );
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
