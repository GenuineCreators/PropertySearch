import 'package:agent/screens/Authetication/loginScreen.dart';
import 'package:agent/screens/themes/theme_provider.dart';
import 'package:agent/screens/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBxHFaPOaXAdBHtrfdB-NQjrDXH8ZwhiOE",
          authDomain: "tuzo-cdcbd.firebaseapp.com",
          projectId: "tuzo-cdcbd",
          storageBucket: "tuzo-cdcbd.firebasestorage.app",
          messagingSenderId: "37507938700",
          appId: "1:37507938700:web:ea7ea28db00b5f0ff83ea9",
          measurementId: "G-EM9FMEW5BD"),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      // theme: ThemeData(primarySwatch: Colors.blue),
      theme: themeProvider.themeData,
      debugShowCheckedModeBanner: false,
      home: AuthGate(), // Use an AuthGate widget for checking authentication
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, the user is signed in
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return BottomNavBar(); // If user is signed in, redirect to HomePage
          } else {
            return LoginScreen(); // If user is not signed in, show LoginScreen
          }
        }

        // While waiting for the authentication state, show a loading indicator
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
