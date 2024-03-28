import 'package:chat_app/pages/auth_pages/login_page.dart';
import 'package:chat_app/pages/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    final fireAuth = FirebaseAuth.instance;
    return fireAuth.currentUser != null
        ? const BottomNavBar()
        : const LogInPage();
  }
}
