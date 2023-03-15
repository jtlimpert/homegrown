class Plant {
  final String? name;
  final List<TouchPoint?> points;
  final String gardenId;
  final PlantIcon icon;
  String? id;
  String? updated;

  Plant(
      {required this.name,
      required this.points,
      this.id,
      required this.gardenId,
      required this.icon,
      this.updated});

  Map<String, dynamic> toMap() {
    var touchPoints = [];
    for (var element in points) {
      touchPoints.add(element?.toMap());
    }

    return {
      'name': name,
      'offsets': touchPoints,
      'gardenId': gardenId,
      'icon': icon.toMap(),
      'updated': updated
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map, String reference) {
    List<TouchPoint?> touchPoints = [];
    PlantIcon plantIcon = PlantIcon.fromMap(map['icon'], reference);
    var offset = map['offsets'] as List<dynamic>;
    offset.asMap().forEach(
      (key, value) {
        touchPoints.add(TouchPoint.fromMap(value, key.toString()));
      },
    );
    return Plant(
        name: map['name'],
        points: touchPoints,
        id: reference,
        gardenId: map['gardenId'],
        icon: plantIcon,
        updated: map['updated']);
  }
}

class PlantIcon {
  int red;
  int green;
  int blue;
  double opacity;

  PlantIcon(
      {required this.red,
      required this.green,
      required this.blue,
      required this.opacity});

  Map<String, dynamic> toMap() {
    return {'red': red, 'green': green, 'blue': blue, 'opacity': opacity};
  }

  factory PlantIcon.fromMap(Map<String, dynamic> map, String reference) {
    return PlantIcon(
        red: map['red'],
        green: map['green'],
        blue: map['blue'],
        opacity: map['opacity']);
  }
}

class TouchPoint {
  double x;
  double y;

  TouchPoint({required this.x, required this.y});

  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y};
  }

  factory TouchPoint.fromMap(Map<String, dynamic> map, String reference) {
    return TouchPoint(x: map['x'], y: map['y']);
  }
}
