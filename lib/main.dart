import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'audio/audio_screen.dart';
import 'library/library_screen.dart';
import 'media/device_media_repository.dart';
import 'profile/profile_screen.dart';
import 'video/video_screen.dart';

void main() => runApp(const MediaHubApp());

class MediaHubApp extends StatelessWidget {
  const MediaHubApp({super.key, this.firebaseInitialization, this.deviceMedia});

  final Future<String>? firebaseInitialization;
  final DeviceMediaRepository? deviceMedia;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MediaHub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF28B6A8),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF101923),
      cardTheme: CardThemeData(
        color: const Color(0xFF1B2B36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      useMaterial3: true,
    ),
    home: _FirebaseBootstrapScreen(
      initialization: firebaseInitialization,
      deviceMedia: deviceMedia ?? const PhotoManagerDeviceMediaRepository(),
    ),
  );
}

class _FirebaseBootstrapScreen extends StatefulWidget {
  const _FirebaseBootstrapScreen({
    this.initialization,
    required this.deviceMedia,
  });

  final Future<String>? initialization;
  final DeviceMediaRepository deviceMedia;

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
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('assets/images/logo/logo.png'),
                  width: 180,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      }
      return _MainNavigation(
        firebaseStatus: snapshot.data!,
        deviceMedia: widget.deviceMedia,
      );
    },
  );
}

class _MainNavigation extends StatefulWidget {
  const _MainNavigation({
    required this.firebaseStatus,
    required this.deviceMedia,
  });

  final String firebaseStatus;
  final DeviceMediaRepository deviceMedia;

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
        onOpenLibrary: () => setState(() => _selectedIndex = 3),
        onOpenAudio: () => setState(() => _selectedIndex = 1),
        onOpenVideo: () => setState(() => _selectedIndex = 2),
      ),
      AudioScreen(
        deviceMedia: widget.deviceMedia,
        scanDevice: _selectedIndex == 1,
      ),
      VideoScreen(
        deviceMedia: widget.deviceMedia,
        scanDevice: _selectedIndex == 2,
      ),
      const LibraryScreen(),
      const ProfileScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones),
            label: 'Audio',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Video',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
