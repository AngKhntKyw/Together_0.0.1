import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/pages/auth_pages/authenticate.dart';
import 'package:chat_app/pages/chat_page/chat_detail_page.dart';
import 'package:chat_app/providers/add_post_provider.dart';
import 'package:chat_app/providers/chat_inputs_provider.dart';
import 'package:chat_app/providers/edit_post_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatInputsProviders()),
        ChangeNotifierProvider(create: (_) => AddPostProvider()),
        ChangeNotifierProvider(create: (_) => EditPostProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final fireAuth = FirebaseAuth.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setOnline();
    super.initState();
  }

  void setOnline() async {
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "isOnline": true,
      "inChat": true,
    });
  }

  void setOffline() async {
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "isOnline": false,
      "inChat": false,
      "lastOnline": Timestamp.now(),
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //online
      setOnline();
    } else {
      //offline
      setOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Together',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Authenticate(),
    );
  }
}
