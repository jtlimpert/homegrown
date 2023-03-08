import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_grown/database/database.dart';
import 'package:home_grown/models/garden.dart';
import 'package:home_grown/models/plant.dart';
import 'package:home_grown/screens/garden_screen.dart';
import 'package:home_grown/screens/take_picture_screen.dart';

class GardenCard extends ConsumerWidget {
  final Garden garden;
  final CameraDescription camera;

  const GardenCard({super.key, required this.garden, required this.camera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    database.selectedGardenId = garden.id!;

    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(10.0),
      color: Colors.grey[200],
      shadowColor: Colors.grey[800],
      borderOnForeground: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GardenScreen(
                        imageUrl: garden.images.first?.url ?? '',
                        gardenId: garden.id ?? '',
                      ),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  garden.images.first?.url ?? '',
                  height: 350,
                  width: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream: database.allGardenPlants,
            builder: (context, snapshot) {
              List<Widget> children = [];
              if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Stack trace: ${snapshot.stackTrace}'),
                  ),
                ];
              } else {
                if (snapshot.hasData) {
                  for (var doc in snapshot.data.docs) {
                    final plant = Plant.fromMap(doc.data(), doc.id);
                    children.add(Dismissible(
                      key: Key(doc.id),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) async {
                        await database.removePlant(plant.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${plant.name} dismissed')));
                      },
                      child: ListTile(
                        title: Text(plant.name ?? ''),
                        leading: Icon(
                          Icons.yard,
                          color: Color.fromRGBO(
                              plant.icon.red,
                              plant.icon.green,
                              plant.icon.blue,
                              plant.icon.opacity),
                        ),
                      ),
                    ));
                  }
                }
              }
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                ),
                onPressed: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TakePictureScreen(
                            garden: garden,
                            camera: camera,
                            title: 'Camera',
                          )));
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  try {
                    await database.removeGarden(garden.id ?? '');
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
