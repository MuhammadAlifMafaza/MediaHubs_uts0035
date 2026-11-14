import 'package:flutter/material.dart';

/// Cloud catalogue stays disconnected until rules, authentication and the
/// document path have been checked together in Firebase Console.
class CloudLibraryScreen extends StatelessWidget {
  const CloudLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cloud Library')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Icon(Icons.cloud_off_outlined, size: 72),
        SizedBox(height: 16),
        Text(
          'Cloud catalogue is not connected yet',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: Text('Firebase setup required'),
            subtitle: Text(
              'Verify Firestore Data, Security Rules, and Authentication in Firebase Console. '
              'Agree on a protected media collection path before reading or writing data.',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Your bundled media is still available'),
            subtitle: Text(
              'Open Library for local app assets. Cloud metadata does not download audio or video for offline use.',
            ),
          ),
        ),
      ],
    ),
  );
}
