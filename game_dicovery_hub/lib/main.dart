// lib/main.dart

// ignore_for_file: unused_import, non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_dicovery_hub/models/user_model.dart';
import 'package:game_dicovery_hub/services/firestore_service.dart';
import 'package:game_dicovery_hub/services/user_service.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'screens/admin_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CRITICAL: StreamProvider setup
        StreamProvider<UserModel?>(
          create: (context) => UserService().streamUserModel(),
          initialData: null,
          catchError: (context, error) {
            // Log the error but return null to prevent the provider from crashing the app
            // ignore: avoid_print
            print('StreamProvider userModel error: $error');
            return null;
          },
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Game Discovery Hub',
        themeMode: ThemeMode.dark, 
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E), 
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        theme: ThemeData.light(),
        home: const AuthWrapper(),
      ),
    );
  }
}

// --- THE AUTHWRAPPER (NO FORCED ADMIN REDIRECT) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel?>(context);

    if (userModel == null) {
      // If the model is null, we are either loading or logged out
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          // If we are definitely logged out, show AuthScreen
          if (!snapshot.hasData) {
            return const AuthScreen();
          }
          // Otherwise, we are just waiting for the UserModel stream to connect
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
      );
    }

    // FIX: Always return MainScreen if the user is logged in (Admin button is now in MainScreen's AppBar)
    return const MainScreen();
  }
}