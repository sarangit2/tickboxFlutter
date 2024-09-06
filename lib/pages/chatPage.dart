import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String userId;

  ChatPage({required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('chats').add({
        'userId': widget.userId,
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
        'senderId': 'currentUserId', // Remplacez par l'ID de l'utilisateur actuel
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('chats')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: false) // Assurez-vous que les messages sont triés dans le bon ordre
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        print('Erreur dans la récupération des messages : ${snapshot.error}');
        return Center(child: Text('Erreur dans la récupération des messages.'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        print('Aucun message trouvé.');
        return Center(child: Text('Aucun message pour cet utilisateur.'));
      }

      final messages = snapshot.data!.docs;
      print('Nombre de messages reçus : ${messages.length}');

      return ListView.builder(
        reverse: false, // Les messages seront affichés du plus ancien au plus récent
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isCurrentUser = message['senderId'] == 'currentUserId'; // Changez selon l'ID utilisateur actuel

          print('Message ${index + 1} : ${message['message']} (envoyé par ${message['senderId']})');

          return ListTile(
            title: Align(
              alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message['message'],
                  style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                ),
              ),
            ),
          );
        },
      );
    },
  ),
)
,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
