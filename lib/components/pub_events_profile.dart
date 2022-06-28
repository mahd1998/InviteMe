import 'package:cloud_firestore/cloud_firestore.dart';

class EventData {
  late String title;
  late Timestamp time;
  late String picture;
  late GeoPoint location;


  EventData({
    required this.title,
    required this.time,
    required this.picture,
    required this.location,
  });

  EventData.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    time = json['Date And Time'];
    picture = json['Event Image'];
    location = json['Location'];

  }
}