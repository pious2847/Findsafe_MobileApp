class Phone {
   final String deviceId;
  final String name;
  final String imageUrl;

  Phone({
    required this.deviceId,
    required this.name,
    required this.imageUrl,
  });
  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      deviceId: json['_id'],
      name: json['devicename'],
      imageUrl: json['image'],
    );
  }
}
