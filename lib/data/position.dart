import 'package:firebase_database/firebase_database.dart';


class Position {
  String? key;
  String name;
  String latitude;
  String longitude;
  Position(this.name,this.latitude, this.longitude);
  
  Position.fromJson(DataSnapshot snapshot, Map<dynamic, dynamic> json)
      : key = snapshot.key ?? '0',
        name = json['name'] ?? '1900/01/01',
        latitude = json['latitude'] ?? '0',
        longitude = json['longitude'] ?? '0';

  toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
