// ignore_for_file: file_names

class User {
  String username;
  String email;
  String password;
  User(this.username, this.email, this.password);
}

class UserProfileModel {
  String? id;
  late String username;
  String? phone;
  late String email;
  Address? addressInfo;
  EmergencyContact? emergencyContact;
  late bool verified;
  late String password;
  List<String>? devices;

  UserProfileModel({
    this.id,
    required this.username,
    this.phone,
    required this.email,
    this.addressInfo,
    this.emergencyContact,
    this.verified = false,
    required this.password,
    this.devices,
  });

factory UserProfileModel.fromJson(Map<String, dynamic> json) {
  final userJson = json['User'];
  return UserProfileModel(
    id: userJson['_id'],
    username: userJson['name'],
    phone: userJson['phone'],
    email: userJson['email'],
    addressInfo: userJson['addressinfo'] != null
        ? Address.fromJson(userJson['addressinfo'])
        : null,
    emergencyContact: userJson['emergencycontact'] != null
        ? EmergencyContact.fromJson(userJson['emergencycontact'])
        : null,
    verified: userJson['verified'],
    password: userJson['password'],
    devices: userJson['devices'] != null
        ? List<String>.from(userJson['devices'].map((x) => x.toString()))
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'phone': phone,
      'email': email,
      'addressinfo': addressInfo?.toJson(),
      'emergencycontact': emergencyContact?.toJson(),
      'verified': verified,
      'password': password,
      'devices': devices,
    };
  }
}

class Address {
  String? area;
  String? houseNo;

  Address({this.area, this.houseNo});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      area: json['area'],
      houseNo: json['houseNo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'houseNo': houseNo,
    };
  }
}

class EmergencyContact {
  String? name;
  String? contact;

  EmergencyContact({this.name, this.contact});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
    };
  }
}
