import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_grown/models/plant.dart';
import 'package:home_grown/widgets/plant_popup.dart';
import 'package:touchable/touchable.dart';
import 'package:home_grown/database/database.dart';
import 'package:animate_icons/animate_icons.dart';

class GardenScreen extends ConsumerStatefulWidget {
  final String imageUrl;
  final String gardenId;
  const GardenScreen(
      {super.key, required this.imageUrl, required this.gardenId});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen>
    with SingleTickerProviderStateMixin {
  List<TouchPoint?> points = [];

  bool isOpened = false;
  bool shouldDraw = false;
  late AnimationController _animationController;
  late Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  late AnimateIconController controller;

  late Color selectedColor;

  @override
  initState() {
    selectedColor = Colors.black;

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    controller = AnimateIconController();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget blue() {
    return FloatingActionButton(
      heroTag: 'blue',
      backgroundColor:
          selectedColor == Colors.blue ? selectedColor : Colors.white,
      onPressed: () {
        setState(() {
          selectedColor = Colors.blue;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 36,
          width: 36,
          color: Colors.blue,
        ),
      ),
    );
    ;
  }

  Widget black() {
    return FloatingActionButton(
      heroTag: 'black',
      backgroundColor:
          selectedColor == Colors.black ? selectedColor : Colors.white,
      onPressed: () {
        setState(() {
          selectedColor = Colors.black;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 36,
          width: 36,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget red() {
    return FloatingActionButton(
      heroTag: 'red',
      backgroundColor:
          selectedColor == Colors.red ? selectedColor : Colors.white,
      onPressed: () {
        setState(() {
          selectedColor = Colors.red;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 36,
          width: 36,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget toggle() {
    return FloatingActionButton(
      heroTag: 'toggle',
      backgroundColor: Colors.white,
      onPressed: null,
      child: AnimateIcons(
        startIcon: Icons.draw,
        endIcon: Icons.close,
        controller: controller,
        size: 36.0,
        onStartIconPress: () {
          setState(() {
            shouldDraw = !shouldDraw;
          });
          animate();
          return true;
        },
        onEndIconPress: () {
          setState(() {
            shouldDraw = !shouldDraw;
          });
          animate();
          return true;
        },
        duration: const Duration(milliseconds: 500),
        startIconColor: selectedColor,
        endIconColor: Colors.redAccent,
        clockwise: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    database.selectedGardenId = widget.gardenId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Screen'),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(widget.imageUrl), fit: BoxFit.cover),
        ),
        child: GestureDetector(
          onPanStart: (details) {
            if (shouldDraw) {
              setState(() {
                points.add(TouchPoint(
                    x: details.localPosition.dx, y: details.localPosition.dy));
              });
            }
          },
          onPanUpdate: (details) {
            if (shouldDraw) {
              setState(() {
                points.add(TouchPoint(
                    x: details.localPosition.dx, y: details.localPosition.dy));
              });
            }
          },
          onPanEnd: (details) async {
            if (shouldDraw) {
              setState(() {
                points = [...points, points[0]];
              });
              await showDialog(
                  context: context,
                  builder: ((context) => PlantPopup(
                        plant: Plant(
                          points: points,
                          name: '',
                          gardenId: widget.gardenId,
                          icon: PlantIcon(
                              red: selectedColor.red,
                              blue: selectedColor.blue,
                              green: selectedColor.green,
                              opacity: selectedColor.opacity),
                        ),
                      )));
              setState(() {
                points = [];
              });
            }
          },
          child: StreamBuilder(
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
                  CustomPaint(
                    size: Size.infinite,
                    painter: MyPlantDrawingPainter(
                        points, savedPlants, selectedColor),
                  ),
                  for (var plant in savedPlants)
                    Positioned(
                      left: plant.points[0]?.x,
                      top: plant.points[0]?.y,
                      height: 40,
                      width: 40,
                      child: InkWell(
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
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: ((context) => PlantPopup(plant: plant)));
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * 3.0,
              0.0,
            ),
            child: red(),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * 2.0,
              0.0,
            ),
            child: blue(),
          ),
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value,
              0.0,
            ),
            child: black(),
          ),
          toggle(),
        ],
      ),
    );
  }
}

class MyPlantDrawingPainter extends CustomPainter {
  List<TouchPoint?>? pointsList;
  List<Plant> plants;
  Color? selectedColor;

  MyPlantDrawingPainter(this.pointsList, this.plants, this.selectedColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (pointsList != null) {
      for (int i = 0; i < pointsList!.length - 1; i++) {
        if (pointsList![i] != null && pointsList![i + 1] != null) {
          canvas.drawLine(
              Offset(pointsList![i]!.x, pointsList![i]!.y),
              Offset(pointsList![i + 1]!.x, pointsList![i + 1]!.y),
              Paint()
                ..strokeWidth = 5.0
                ..color = selectedColor ?? Colors.black
                ..strokeCap = StrokeCap.round);
        }
      }
    }

    for (var plant in plants) {
      for (int i = 0; i < plant.points.length - 1; i++) {
        if (plant.points[i] != null && plant.points[i + 1] != null) {
          canvas.drawLine(
              Offset(plant.points[i]!.x, plant.points[i]!.y),
              Offset(plant.points[i + 1]!.x, plant.points[i + 1]!.y),
              Paint()
                ..strokeWidth = 5.0
                ..color = Color.fromRGBO(plant.icon.red, plant.icon.green,
                    plant.icon.blue, plant.icon.opacity)
                ..strokeCap = StrokeCap.round);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyPlantPainter extends CustomPainter {
  Function() setState;
  final BuildContext context;
  final List<Plant> plantsToDraw;

  MyPlantPainter(this.context, this.setState, this.plantsToDraw);

  @override
  void paint(Canvas _canvas, Size size) {
    TouchyCanvas canvas = TouchyCanvas(context, _canvas);
    for (var plant in plantsToDraw) {
      for (int i = 0; i < plant.points.length - 1; i++) {
        if (plant.points[i] != null && plant.points[i + 1] != null) {
          canvas.drawLine(
            Offset(plant.points[i]!.x, plant.points[i]!.y),
            Offset(plant.points[i + 1]!.x, plant.points[i + 1]!.y),
            Paint()
              ..strokeWidth = 5.0
              ..color = Color.fromRGBO(plant.icon.red, plant.icon.green,
                  plant.icon.blue, plant.icon.opacity)
              ..strokeCap = StrokeCap.round,
            onTapDown: (details) {
              setState();
            },
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
