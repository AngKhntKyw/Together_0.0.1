import 'package:chat_app/pages/feed_page/add_post_page/add_feed_page.dart';
import 'package:chat_app/pages/feed_page/feed_images_and_videos_widget.dart';
import 'package:chat_app/pages/feed_page/feed_images_widget.dart';
import 'package:chat_app/pages/feed_page/feed_video_widget/feed_videos_widget.dart';
import 'package:chat_app/pages/feed_page/post_owner_widget.dart';
import 'package:chat_app/pages/feed_page/post_text_widget.dart';
import 'package:chat_app/pages/feed_page/react_and_comment_widget.dart';
import 'package:chat_app/pages/user_profile_page/user_profile_card_widget.dart';
import 'package:chat_app/services/feed_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;
  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fireAuth = FirebaseAuth.instance;

    //
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text("Profile"),
      ),
      body: StreamBuilder(
        stream: FeedServices.getUserPost(userId),
        builder: (context, snapshot) {
          //
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.black87, size: 20));
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else if (snapshot.data!.docs.isEmpty) {
            return Column(
              children: [
                UserProfileCardWidget(userId: userId),
                const SizedBox(height: 20),
                Center(
                  child: Text("No post found."),
                )
              ],
            );
          } else {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  flexibleSpace: UserProfileCardWidget(userId: userId),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Feeds",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final postData = snapshot.data!.docs[index];
                    //for images
                    List<dynamic> dynamicImageList = postData['imageList'];
                    List<String> imageStringList = dynamicImageList
                        .map((dynamic item) => item.toString())
                        .toList();
                    //for videos
                    List<dynamic> dynamicVideoList = postData['videoList'];
                    List<String> videoStringList = dynamicVideoList
                        .map((dynamic item) => item.toString())
                        .toList();

                    // ui
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: size.width,
                        child: Column(
                          children: [
                            //

                            // Post Owner widget
                            Container(
                                padding: const EdgeInsets.all(6),
                                width: size.width,
                                child: PostOwnerWidget(
                                  time: postData['time'],
                                  PostId: postData.id,
                                  postData: postData,
                                )),

                            //Post Text Widget
                            Container(
                              padding: const EdgeInsets.all(6),
                              width: size.width,
                              child: PostText(postText: postData['post_text']),
                            ),

                            // Post Image Widget

                            videoStringList.isEmpty
                                ? FeedImagesWidget(imageList: imageStringList)
                                : imageStringList.isEmpty
                                    ? FeedVideosWidget(
                                        videoList: videoStringList)
                                    : FeedImagesAndVideosWidget(
                                        imageList: imageStringList,
                                        videoList: videoStringList),

                            //React and Comment Widget
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: size.width,
                              child: ReactAndCommentWidget(postId: postData.id),
                            ),
                            const Divider(
                                color: Colors.black87, thickness: 0.6),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            );
          }
        },
      ),
      floatingActionButton: Offstage(
        offstage: fireAuth.currentUser!.uid != userId,
        child: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: const Icon(Iconsax.edit, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                fullscreenDialog: true,
                maintainStateData: true,
                child: const AddFeedPage(),
                inheritTheme: true,
                ctx: context,
                matchingBuilder: const CupertinoPageTransitionsBuilder(),
              ),
            );
          },
        ),
      ),
    );
  }
}
