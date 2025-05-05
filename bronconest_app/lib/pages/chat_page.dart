import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';

class ChatPage extends StatefulWidget {
  final String schoolId;
  final Dorm dorm;

  const ChatPage({super.key, required this.schoolId, required this.dorm});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('schools')
          .doc(widget.schoolId)
          .collection('dorms')
          .doc(widget.dorm.id)
          .collection('messages')
          .add({
            'sender_id': userId,
            'sender_name': userName,
            'text': text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
          });

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dorm.name} Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('schools')
                      .doc(widget.schoolId)
                      .collection('dorms')
                      .doc(widget.dorm.id)
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
                      title: Text(message['sender_name']),
                      subtitle: Text(message['text']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            message['timestamp'] != null
                                ? DateFormat('hh:mm a').format(
                                  (message['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : 'Just now',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
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
          ),
        ],
      ),
    );
  }
}
