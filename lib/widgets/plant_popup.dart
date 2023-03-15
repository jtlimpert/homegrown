import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_grown/models/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_grown/database/database.dart';

class PlantPopup extends ConsumerStatefulWidget {
  final Plant plant;

  const PlantPopup({super.key, required this.plant});

  @override
  ConsumerState<PlantPopup> createState() => _PlantPopupState();
}

class _PlantPopupState extends ConsumerState<PlantPopup> {
  late String plantName;

  @override
  void initState() {
    super.initState();
    setState(() {
      plantName = widget.plant.name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return AlertDialog(
      scrollable: true,
      title: const Text('Plant Name'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                autofocus: true,
                initialValue: plantName,
                decoration: InputDecoration(
                  labelText: 'Name',
                  icon: Icon(
                    Icons.yard,
                    size: 40,
                    color: Color.fromRGBO(
                        widget.plant.icon.red,
                        widget.plant.icon.green,
                        widget.plant.icon.blue,
                        widget.plant.icon.opacity),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    plantName = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text(
            'Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onPressed: () async {
            try {
              if (widget.plant.id != null) {
                await database.removePlant(widget.plant.id ?? '');
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
        ),
        ElevatedButton(
          child: const Text("Save"),
          onPressed: () async {
            try {
              if (widget.plant.id != null) {
                await database.editPlant(plantName, widget.plant.id!);
              } else {
                Plant newPlant = Plant(
                    name: plantName,
                    points: widget.plant.points,
                    gardenId: widget.plant.gardenId,
                    icon: widget.plant.icon,
                    updated: DateTime.now().millisecondsSinceEpoch.toString());
                await database.addNewPlant(newPlant);
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
        ),
      ],
    );
  }
}
