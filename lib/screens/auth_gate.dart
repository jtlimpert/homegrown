import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:home_grown/screens/garden_list_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, packageSnapshot) {
          switch (packageSnapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Scaffold(
                      body: SignInScreen(
                        providerConfigs: const [
                          EmailProviderConfiguration(),
                        ],
                        headerBuilder: (context, constraints, shrinkOffset) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image(
                                  image: AssetImage('assets/plant_pot.png')),
                            ),
                          );
                        },
                        footerBuilder: (context, action) {
                          return ListTile(
                              trailing:
                                  Text(packageSnapshot.data?.version ?? ''));
                        },
                      ),
                    );
                  }

                  return const GardenListScreen(
                    title: 'Garden',
                  );
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
