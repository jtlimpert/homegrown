import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:home_grown/database/database.dart';
import 'package:home_grown/models/garden.dart';
import 'package:home_grown/models/plant.dart';
import 'package:home_grown/screens/garden_screen.dart';

class PreviewPictureScreen extends ConsumerStatefulWidget {
  Garden? garden;
  final XFile image;
  final bool cameraImage;

  PreviewPictureScreen(
      {super.key, required this.image, this.garden, required this.cameraImage});

  @override
  ConsumerState<PreviewPictureScreen> createState() =>
      _PreviewPictureScreenState();
}

class _PreviewPictureScreenState extends ConsumerState<PreviewPictureScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    database.selectedGardenId = '';
    if (widget.garden != null) {
      database.selectedGardenId = widget.garden!.id ?? '';
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Garden Preview'),
      ),
      body: StreamBuilder(
        stream: database.allGardenPlants,
        builder: (context, snapshot) {
          if (!snapshot.hasData && database.selectedGardenId != '') {
            return const CircularProgressIndicator();
          }
          if (snapshot.error != null) {
            return Text(snapshot.error.toString());
          }
          List<Plant> savedPlants = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data.docs) {
              savedPlants.add(Plant.fromMap(doc.data(), doc.id));
            }
          }

          return Stack(
            children: [
              Image.file(File(widget.image.path)),
              CustomPaint(
                size: Size.infinite,
                painter: MyPlantDrawingPainter(null, savedPlants, null),
              ),
              for (var plant in savedPlants)
                Positioned(
                  left: plant.points[0]?.x,
                  top: plant.points[0]?.y,
                  height: 40,
                  width: 40,
                  child: Container(
                    color: Colors.white,
                    child: Icon(
                      Icons.yard,
                      size: 40.0,
                      color: Color.fromRGBO(plant.icon.red, plant.icon.green,
                          plant.icon.blue, plant.icon.opacity),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'photo',
            onPressed: loading
                ? null
                : () async {
                    setState(() {
                      loading = true;
                    });
                    final file = File(widget.image.path);
                    final storageRef = FirebaseStorage.instance.ref();
                    final imageRef = storageRef.child(
                        '${DateTime.now().millisecondsSinceEpoch.toString()}_${widget.image.name}');
                    try {
                      await imageRef.putFile(file);
                      var imageUrl = await imageRef.getDownloadURL();
                      var imageName = imageRef.name;
                      if (widget.garden != null && widget.garden?.id != null) {
                        await database.editGarden(
                            widget.garden!, imageUrl, imageName);
                      } else {
                        await database.addNewGarden(Garden(
                            images: [
                              GardenImage(url: imageUrl, name: imageName)
                            ],
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            id: widget.garden?.id,
                            updated: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString()));
                      }
                      if (widget.cameraImage) {
                        await GallerySaver.saveImage(widget.image.path);
                      }
                      if (context.mounted) {
                        setState(() {
                          loading = false;
                        });
                        int count = 0;
                        Navigator.popUntil(context, (route) => count++ == 2);
                      }
                    } catch (e) {
                      setState(() {
                        loading = false;
                      });
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  },
            child: loading
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 56, 42, 42),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
