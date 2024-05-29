import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messageaoo/chat_provider.dart';
import 'package:messageaoo/login_screen.dart';
import 'package:messageaoo/search_screen.dart';
import 'package:messageaoo/widget/chat_tile.dart';
import 'package:provider/provider.dart';

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<HomeScreenState> createState() => __HomeScreenStateState();
}

class __HomeScreenStateState extends State<HomeScreenState> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
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

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();
    final users = chatData!['users'] as List<dynamic>;
    final receivedId = users.firstWhere((id) => id != loggedInUser!.uid);
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receivedId)
        .get();
    final userData = userDoc.data()!;
    return {
      'chatId': chatId,
      'lastMessage': chatData['lastMessage'] ?? '',
      'timeStamp': chatData['timeStamp']?.toDate() ?? DateTime.now(),
      'userData': userData
    };
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Chats"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreenState(),
                      ));
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChat(loggedInUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final chatDocs = snapshot.data!.docs;
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(chatDocs.map(
                    (chatDocs) => _fetchChatData(chatDocs.id),
                  )),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final chatDataList = snapshot.data!;
                    return ListView.builder(
                      itemCount: chatDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final chatData = chatDataList[index];
                        return ChatTile(
                          chatId: chatData['chatId'],
                          lastMessage: chatData['lastMessage'],
                          timeStamp: chatData['timeStamp'],
                          receivedData: chatData['userData'],
                        );
                      },
                    );
                  },
                );
              },
            ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            child: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ));
            }),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:messageaoo/chat_provider.dart';
// import 'package:messageaoo/login_screen.dart';
// import 'package:messageaoo/search_screen.dart';
// import 'package:messageaoo/widget/chat_tile.dart';
// import 'package:provider/provider.dart';

// class HomeScreenState extends StatefulWidget {
//   const HomeScreenState({super.key});

//   @override
//   State<HomeScreenState> createState() => __HomeScreenStateState();
// }

// class __HomeScreenStateState extends State<HomeScreenState> {
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;

//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }

//   void getCurrentUser() {
//     final user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         loggedInUser = user;
//       });
//     }
//   }

//   Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
//     final chatDoc =
//         await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
//     final chatData = chatDoc.data();
//     if (chatData == null) {
//       throw Exception("Chat data is null");
//     }

//     final users = chatData['users'] as List<dynamic>;
//     final receivedId = users.firstWhere((id) => id != loggedInUser!.uid);
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(receivedId)
//         .get();
//     final userData = userDoc.data();
//     if (userData == null) {
//       throw Exception("User data is null");
//     }

//     return {
//       'chatId': chatId,
//       'lastMessage': chatData['lastMessage'] ?? '',
//       'timeStamp': chatData['timeStamp']?.toDate() ?? DateTime.now(),
//       'userData': userData
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context);
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text("Chats"),
//           actions: [
//             IconButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LoginScreenState(),
//                       ));
//                 },
//                 icon: Icon(Icons.logout))
//           ],
//         ),
//         body: Column(
//           children: [
//             Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//               stream: chatProvider.getChat(loggedInUser!.uid),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//                 final chatDocs = snapshot.data!.docs;
//                 return FutureBuilder<List<Map<String, dynamic>>>(
//                   future: Future.wait(chatDocs.map(
//                     (chatDoc) => _fetchChatData(chatDoc.id),
//                   )),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }

//                     final chatDataList = snapshot.data!;
//                     return ListView.builder(
//                       itemCount: chatDataList.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         final chatData = chatDataList[index];
//                         return ChatTile(
//                           chatId: chatData['chatId'],
//                           lastMessage: chatData['lastMessage'],
//                           timeStamp: chatData['timeStamp'],
//                           receivedData: chatData['userData'],
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ))
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//             backgroundColor: Colors.blueAccent,
//             foregroundColor: Colors.white,
//             child: Icon(Icons.search),
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SearchScreen(),
//                   ));
//             }),
//       ),
//     );
//   }
// }
