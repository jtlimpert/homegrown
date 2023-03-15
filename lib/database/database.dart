import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_grown/models/garden.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:home_grown/models/plant.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late CollectionReference _plants;
  late QuerySnapshot _gardenPlants;
  late String selectedGardenId;
  final storage = FirebaseStorage.instance;
  final storageRef = FirebaseStorage.instance.ref();

  Stream get allGardens => _firestore
      .collection("gardens")
      .where('userId', isEqualTo: _firebaseAuth.currentUser!.uid)
      .snapshots();
  Stream get allGardenPlants => _firestore
      .collection('plants')
      .where('gardenId', isEqualTo: selectedGardenId)
      .snapshots();

  Future<bool> addNewGarden(Garden g) async {
    CollectionReference gardens = _firestore.collection('gardens');
    try {
      await gardens.add(g.toMap());
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removeGarden(String gardenId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> gardenDocument =
          await _firestore.collection('gardens').doc(gardenId).get();

      Garden garden = Garden.fromMap(gardenDocument.data()!, gardenDocument.id);
      QuerySnapshot gardenPlants = await _firestore
          .collection('plants')
          .where('gardenId', isEqualTo: garden.id)
          .get();
      await Future.wait(gardenPlants.docs.map((e) async => removePlant(e.id)));
      await Future.wait(
          garden.images.map((e) => storageRef.child(e!.name).delete()));
      await _firestore.collection('gardens').doc(garden.id).delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.error(e);
    }
  }

  Future<bool> editGarden(
      Garden oldGarden, String imageUrl, String imageName) async {
    CollectionReference gardens = _firestore.collection('gardens');
    List<dynamic> newGardenImages = [];
    for (var image in oldGarden.images) {
      newGardenImages.add({'name': image?.name, 'url': image?.url});
    }
    newGardenImages.insert(0, {'name': imageName, 'url': imageUrl});

    try {
      await gardens.doc(oldGarden.id).update({
        'images': newGardenImages,
        'updated': DateTime.now().millisecondsSinceEpoch.toString()
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Future.error(e);
    }
  }

  Future<bool> addNewPlant(Plant p) async {
    _plants = _firestore.collection('plants');
    try {
      await _plants.add(p.toMap());
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> editPlant(String name, String plantId) async {
    _plants = _firestore.collection('plants');
    try {
      await _plants.doc(plantId).update({
        'name': name,
        'updated': DateTime.now().millisecondsSinceEpoch.toString()
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removePlant(String plantId) async {
    _plants = _firestore.collection('plants');
    try {
      await _plants.doc(plantId).delete();
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      QuerySnapshot userGardens = await _firestore
          .collection('gardens')
          .where('uid', isEqualTo: user?.uid)
          .get();

      await Future.wait(userGardens.docs.map((e) async => removeGarden(e.id)));
      await user?.delete();
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }
}

final databaseProvider = Provider((ref) => Database());
