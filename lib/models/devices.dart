class Device {
  final String id;
  final String devicename;
  final String mode;
  final String activationCode;
  final String modelNumber;
  final String image;

  Device({
    required this.id,
    required this.devicename,
    required this.mode,
    required this.activationCode,
    required this.modelNumber,
    required this.image,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'],
      devicename: json['devicename'],
      mode: json['mode'],
      activationCode: json['activationCode'],
      modelNumber: json['modelNumber'],
      image: json['image'],
    );
  }
}
