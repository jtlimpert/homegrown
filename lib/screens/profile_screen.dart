import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const MyCustomForm(),
    );
  }
}

class MyCustomForm extends ConsumerWidget {
  const MyCustomForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, packageSnapshot) {
        switch (packageSnapshot.connectionState) {
          case ConnectionState.done:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                    initialValue: FirebaseAuth.instance.currentUser?.email,
                    enabled: false,
                  ),
                ),
                const Divider(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Sign Out'),
                  ),
                ),
                ListTile(trailing: Text(packageSnapshot.data?.version ?? ''))
              ],
            );
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
