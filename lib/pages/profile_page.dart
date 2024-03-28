import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/pages/view_image.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final fireAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final fireStorage = FirebaseStorage.instance;
  File? imageFile;
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  void changeProfileImage() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeProfileImage();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void changeEmail() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeEmail(emailController.text, context);
      setState(() {
        isLoading = false;
        emailController.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        emailController.clear();
      });
    }
  }

  void changeName() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeName(nameController.text, context);
      setState(() {
        isLoading = false;
        nameController.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        nameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        // actions: [
        //   IconButton(
        //       onPressed: () => AuthServices.logOut(context),
        //       icon: const Icon(Icons.logout)),
        // ],
      ),
      body: !isLoading
          ? SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    color: Colors.black87,
                    width: size.width,
                    height: size.height / 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewImage(
                                          imageUrl:
                                              fireAuth.currentUser!.photoURL!),
                                    )),
                                child: Hero(
                                  tag: fireAuth.currentUser!.photoURL!,
                                  child: CircleAvatar(
                                    radius: 42,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 40,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              cacheKey: fireAuth
                                                  .currentUser!.photoURL!,
                                              fireAuth.currentUser!.photoURL!),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: changeProfileImage,
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 10,
                                  child: Icon(
                                    Icons.change_circle,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fireAuth.currentUser!.displayName!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                fireAuth.currentUser!.email!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Iconsax.user_edit,
                                color: Colors.black87),
                            hintText: fireAuth.currentUser!.displayName,
                            suffixIcon: nameController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: changeName,
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              nameController.text = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Iconsax.personalcard,
                                color: Colors.black87),
                            hintText: fireAuth.currentUser!.email,
                            suffixIcon: emailController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: changeEmail,
                                    icon: const Icon(Icons.done,
                                        color: Colors.green),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              emailController.text = value;
                            });
                          },
                        ),
                        const SizedBox(height: 80),
                        InkWell(
                          onTap: () => AuthServices.logOut(context),
                          child: Container(
                            alignment: Alignment.center,
                            width: size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.black87,
                            ),
                            child: const Text(
                              "Log out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20),
            ),
    );
  }
}
