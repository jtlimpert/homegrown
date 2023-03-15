import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_grown/database/database.dart';
import 'package:camera/camera.dart';
import 'package:home_grown/models/garden.dart';
import 'package:home_grown/screens/profile_screen.dart';
import 'package:home_grown/screens/take_picture_screen.dart';
import 'package:home_grown/widgets/garden_card.dart';

class GardenListScreen extends ConsumerWidget {
  final String title;

  const GardenListScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfileScreen()));
              },
            )
          ],
          automaticallyImplyLeading: false,
          title: Text(title),
        ),
        body: Center(
          child: StreamBuilder(
            stream: database.allGardens,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              if (snapshot.error != null) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.data.docs.length > 0) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GardenCard(
                        garden: Garden.fromMap(snapshot.data.docs[index].data(),
                            snapshot.data.docs[index].id));
                  },
                );
              }
              return const Text(
                  'To get started, take a picture of your garden!');
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'photo',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TakePictureScreen(
                      title: "Take Garden Picture",
                    )));
          },
          tooltip: 'Camera',
          child: const Icon(Icons.add_a_photo),
        ));
  }
}
