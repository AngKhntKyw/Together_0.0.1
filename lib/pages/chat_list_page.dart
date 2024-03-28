import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/pages/chat_page/chat_detail_page.dart';
import 'package:chat_app/pages/chat_page/chat_page.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    final fireAuth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: FutureBuilder(
        future: fireStore
            .collection("users")
            .where("uid", isNotEqualTo: fireAuth.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.black87, size: 20));
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> userMaps =
                    snapshot.data!.docs[index].data();
                return ListTile(
                    onTap: () {
                      String chatRoomId = getChatRoomId(
                          fireAuth.currentUser!.uid, userMaps['uid']);

                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          fullscreenDialog: true,
                          maintainStateData: true,
                          child: ChatPage(
                            chatRoomId: chatRoomId,
                            userMap: userMaps,
                          ),
                          inheritTheme: true,
                          ctx: context,
                          matchingBuilder:
                              const CupertinoPageTransitionsBuilder(),
                        ),
                      );
                    },
                    leading: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: LoadingAnimationWidget.hexagonDots(
                              color: Colors.black87, size: 20),
                          foregroundImage: CachedNetworkImageProvider(
                              cacheKey: userMaps['profileImage'],
                              userMaps['profileImage']),
                        ),
                        userMaps['isOnline']
                            ? const CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.green,
                              )
                            : const SizedBox()
                      ],
                    ),
                    title: Text(
                      userMaps['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(userMaps['email']),
                    trailing: Text(userMaps['isOnline']
                        ? "active now"
                        : Utils.changeIntoTimeAgo(userMaps['lastOnline'])));
              },
            );
          }
        },
      ),
    );
  }

  Future<void> checkChatInfos(String chatRoomId) async {
    QuerySnapshot<Map<String, dynamic>> result = await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chat_infos')
        .get();

    result.docs.isEmpty
        ? await fireStore
            .collection('chatroom')
            .doc(chatRoomId)
            .collection('chat_infos')
            .add({
            "theme": 0xfffafafa,
            "quick_react": "👍",
          })
        : null;
  }

  String getChatRoomId(String myUserId, String otherUserId) {
    List<String> userIds = [myUserId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join("_");
    // checkChatInfos(chatRoomId);
    return chatRoomId;
  }
}
