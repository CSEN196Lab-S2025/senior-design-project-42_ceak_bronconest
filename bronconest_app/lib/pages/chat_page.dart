import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DormChatPage extends StatefulWidget {
  final String dormId;

  const DormChatPage({super.key, required this.dormId});

  @override
  State<DormChatPage> createState() => _DormChatPageState();
}

class _DormChatPageState extends State<DormChatPage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('dorm_chats')
        .doc(widget.dormId)
        .collection('messages')
        .add({
          'senderId': userId, // Replace with the current user's ID
          'senderName': userName, // Replace with the current user's name
          'text': text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dorm Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('dorm_chats')
                      .doc(widget.dormId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message['senderName']),
                      subtitle: Text(message['text']),
                      trailing: Text(
                        (message['timestamp'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
