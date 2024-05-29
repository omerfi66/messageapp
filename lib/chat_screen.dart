import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messageaoo/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receivedId;

  const ChatScreen({super.key, required this.chatId, required this.receivedId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? loggedInUser;
  String? chatId;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final TextEditingController _textController = TextEditingController();
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.receivedId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final receviverData = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: Color(0XFFEEEEEE),
            appBar: AppBar(
              title: Row(children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(receviverData['imageUrl']),
                ),
                SizedBox(width: 10),
                Text(receviverData['name'])
              ]),
            ),
            body: Column(
              children: [
                Expanded(
                    child: chatId != null && chatId!.isNotEmpty
                        ? MessageStream(chatId: chatId!)
                        : Center(
                            child: Text('No Message Yet'),
                          )),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: _textController,
                        decoration: InputDecoration(
                            hintText: 'Enter your message..',
                            border: InputBorder.none),
                      )),
                      IconButton(
                          onPressed: () async {
                            if (_textController.text.isNotEmpty) {
                              if (chatId == null || chatId!.isEmpty) {
                                chatId = await chatProvider
                                    .createChatRoom(widget.receivedId);
                              }
                              if (chatId != null) {
                                chatProvider.sendMessage(chatId!,
                                    _textController.text, widget.receivedId);
                                _textController.clear();
                              }
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.blueAccent,
                          ))
                    ],
                  ),
                )
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class MessageStream extends StatelessWidget {
  final String chatId;

  const MessageStream({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')

          ///---------------
          .orderBy('timestamp', descending: true)

          ///---------------
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData['messageBody'];
          final messageSender = messageData['senderId'];
          final timestamp =
              messageData['timestamp'] ?? FieldValue.serverTimestamp();
          final currentUser = FirebaseAuth.instance.currentUser!.uid;
          final messageWidget = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            timeStamp: timestamp,
          );

          messageWidgets.add(messageWidget);
        }
        return ListView(reverse: true, children: messageWidgets);
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timeStamp;

  const MessageBubble(
      {super.key,
      required this.text,
      required this.isMe,
      this.timeStamp,
      required this.sender});

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime =
        (timeStamp is Timestamp) ? timeStamp.toDate() : DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 4, spreadRadius: 2)
                ],
                borderRadius: isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))
                    : BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                color: isMe ? Colors.blueAccent : Colors.white),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.black54,
                        fontSize: 15),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '${messageTime.hour} : ${messageTime.minute}',
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.black54,
                        fontSize: 10),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
