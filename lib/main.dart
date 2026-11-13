import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';

void main() => runApp(const MediaHubApp());

class MediaHubApp extends StatelessWidget {
  const MediaHubApp({super.key, this.firebaseInitialization});

  final Future<String>? firebaseInitialization;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MediaHub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1769AA),
        secondary: const Color(0xFF25A879),
      ),
      useMaterial3: true,
    ),
    home: _FirebaseBootstrapScreen(initialization: firebaseInitialization),
  );
}

class _FirebaseBootstrapScreen extends StatefulWidget {
  const _FirebaseBootstrapScreen({this.initialization});

  final Future<String>? initialization;

  @override
  State<_FirebaseBootstrapScreen> createState() =>
      _FirebaseBootstrapScreenState();
}

class _FirebaseBootstrapScreenState extends State<_FirebaseBootstrapScreen> {
  late final Future<String> _initialization =
      widget.initialization ?? _initializeFirebase();

  Future<String> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      return 'Firebase initialized for this app session.';
    } catch (error) {
      return 'Firebase initialization failed: $error';
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _initialization,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return _MainNavigation(firebaseStatus: snapshot.data!);
    },
  );
}

class _MainNavigation extends StatefulWidget {
  const _MainNavigation({required this.firebaseStatus});

  final String firebaseStatus;

  @override
  State<_MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<_MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        firebaseStatus: widget.firebaseStatus,
        onOpenLibrary: () => setState(() => _selectedIndex = 2),
      ),
      const SearchScreen(),
      const LibraryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
