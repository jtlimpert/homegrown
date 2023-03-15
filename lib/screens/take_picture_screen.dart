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
import 'package:home_grown/screens/preview_picture_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class TakePictureScreen extends ConsumerStatefulWidget {
  final String title;
  Garden? garden;

  TakePictureScreen({
    super.key,
    required this.title,
    this.garden,
  });

  @override
  ConsumerState<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends ConsumerState<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<File> capturedImages = [];
  bool cameraLoading = false;
  bool galleryLoading = false;

  @override
  void initState() {
    super.initState();
    cameraLoading = false;
    galleryLoading = false;
    _controller =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    cameraLoading = false;
    galleryLoading = false;
    super.dispose();
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
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
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
                        child: CameraPreview(_controller),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'photo',
            onPressed: cameraLoading || galleryLoading
                ? null
                : () async {
                    try {
                      setState(() {
                        cameraLoading = true;
                      });
                      await _initializeControllerFuture;

                      final cameraImage = await _controller.takePicture();

                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PreviewPictureScreen(
                              image: cameraImage,
                              cameraImage: true,
                              garden: widget.garden,
                            ),
                          ),
                        );
                      }

                      setState(() {
                        cameraLoading = false;
                      });
                    } catch (e) {
                      setState(() {
                        cameraLoading = false;
                      });
                      if (kDebugMode) {
                        print(e);
                      }
                    }
                  },
            child: cameraLoading
                ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                : const Icon(Icons.camera_alt),
          ),
          const Padding(padding: EdgeInsets.only(left: 20, right: 20)),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: cameraLoading || galleryLoading
                ? null
                : () async {
                    setState(() {
                      galleryLoading = true;
                    });
                    final galleryImage = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (context.mounted && galleryImage != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PreviewPictureScreen(
                            image: galleryImage,
                            cameraImage: false,
                            garden: widget.garden,
                          ),
                        ),
                      );
                    }

                    setState(() {
                      galleryLoading = false;
                    });
                  },
            child: galleryLoading
                ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                : const Icon(Icons.photo_library),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
