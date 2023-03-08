import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_grown/database/database.dart';
import 'package:home_grown/models/garden.dart';
import 'package:home_grown/models/plant.dart';
import 'package:home_grown/screens/garden_screen.dart';

class TakePictureScreen extends ConsumerStatefulWidget {
  final CameraDescription camera;
  final String title;
  Garden? garden;

  TakePictureScreen({
    super.key,
    required this.camera,
    required this.title,
    this.garden,
  });

  @override
  ConsumerState<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends ConsumerState<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;
  List<File> capturedImages = [];

  XFile? image;

  initializeCamera(int cameraIndex) {
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();
    initializeCamera(selectedCamera);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    database.selectedGardenId = '';
    if (widget.garden != null) {
      database.selectedGardenId = widget.garden!.id ?? '';
    }
    if (image != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder(
          stream: database.allGardenPlants,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            if (snapshot.error != null) {
              return Text(snapshot.error.toString());
            }
            List<Plant> savedPlants = [];
            for (var doc in snapshot.data.docs) {
              savedPlants.add(Plant.fromMap(doc.data(), doc.id));
            }
            return Stack(
              children: [
                Image.file(
                  File(image!.path),
                ),
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
              onPressed: () async {
                setState(() {
                  image = null;
                });
              },
              child: const Icon(Icons.delete),
            ),
            const Padding(padding: EdgeInsets.only(left: 20, right: 20)),
            FloatingActionButton(
              heroTag: 'photo',
              onPressed: () async {
                final file = File(image!.path);
                final storageRef = FirebaseStorage.instance.ref();
                final imageRef = storageRef.child(image!.name);
                try {
                  await imageRef.putFile(file);
                  var imageUrl = await imageRef.getDownloadURL();
                  var imageName = imageRef.name;
                  if (widget.garden != null && widget.garden?.id != null) {
                    await database.editGarden(
                        widget.garden!, imageUrl, imageName);
                  } else {
                    await database.addNewGarden(Garden(
                        images: [GardenImage(url: imageUrl, name: imageName)],
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        id: widget.garden?.id));
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
              child: const Icon(Icons.save),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          print('builder');
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
                stream: database.allGardenPlants,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.error != null) {
                    return Text(snapshot.error.toString());
                  }
                  List<Plant> savedPlants = [];
                  for (var doc in snapshot.data.docs) {
                    savedPlants.add(Plant.fromMap(doc.data(), doc.id));
                  }

                  return Stack(
                    children: [
                      AspectRatio(
                          aspectRatio: 1 / _controller.value.aspectRatio,
                          child: CameraPreview(_controller)),
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
                              color: Color.fromRGBO(
                                  plant.icon.red,
                                  plant.icon.green,
                                  plant.icon.blue,
                                  plant.icon.opacity),
                            ),
                          ),
                        ),
                    ],
                  );
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'photo',
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final newImage = await _controller.takePicture();

            if (!mounted) return;

            setState(() {
              image = newImage;
            });
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
