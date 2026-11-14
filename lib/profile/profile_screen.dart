import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('No app can open this link.');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open link: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 84,
            backgroundImage: AssetImage('assets/images/profile.jpeg'),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Muhammad Alif Mafaza',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Creator / Developer · MediaHub',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.badge_outlined),
                title: Text('NIM'),
                subtitle: Text('23.230.0035'),
              ),
              ListTile(
                leading: Icon(Icons.school_outlined),
                title: Text('Jurusan'),
                subtitle: Text('Sistem Informasi (Bisnis Digital)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Sosial', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: 'GitHub',
              icon: const FaIcon(FontAwesomeIcons.github),
              onPressed: () =>
                  _openLink(context, 'https://github.com/muhammadalifmafaza/'),
            ),
            const SizedBox(width: 20),
            IconButton.filledTonal(
              tooltip: 'Instagram',
              icon: const FaIcon(FontAwesomeIcons.instagram),
              onPressed: () =>
                  _openLink(context, 'https://www.instagram.com/m.alifmafaza/'),
            ),
            const SizedBox(width: 20),
            IconButton.filledTonal(
              tooltip: 'LinkedIn',
              icon: const FaIcon(FontAwesomeIcons.linkedin),
              onPressed: () => _openLink(
                context,
                'https://www.linkedin.com/in/alif-mafaza/',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
