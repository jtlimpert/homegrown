class Garden {
  final String userId;
  String? id;
  String? updated;
  List<GardenImage?> images;

  Garden({this.id, required this.userId, required this.images, this.updated});

  Map<String, dynamic> toMap() {
    var gardenImages = [];
    for (var element in images) {
      gardenImages.add(element?.toMap());
    }
    return {'images': gardenImages, 'userId': userId, 'updated': updated};
  }

  factory Garden.fromMap(Map<String, dynamic> map, String reference) {
    List<GardenImage?> gardenImages = [];
    var images = map['images'] as List<dynamic>;
    images.asMap().forEach((key, value) {
      gardenImages.add(GardenImage.fromMap(value, key.toString()));
    });
    return Garden(
        images: gardenImages,
        id: reference,
        userId: map['userId'],
        updated: map['updated']);
  }
}

class GardenImage {
  final String url;
  final String name;

  GardenImage({required this.url, required this.name});

  Map<String, dynamic> toMap() {
    return {'url': url, 'name': name};
  }

  factory GardenImage.fromMap(Map<String, dynamic> map, String reference) {
    return GardenImage(url: map['url'], name: map['name']);
  }
}
