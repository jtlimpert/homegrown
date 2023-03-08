import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:home_grown/screens/garden_list_screen.dart';

class AuthGate extends StatelessWidget {
  final CameraDescription camera;

  const AuthGate({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
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
                    child: Image(image: AssetImage('assets/plant_pot.png')),
                  ),
                );
              },
            ),
          );
        }

        return GardenListScreen(
          title: 'Garden',
          camera: camera,
        );
      },
    );
  }
}
