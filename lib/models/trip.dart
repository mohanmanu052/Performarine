import 'dart:convert';

import 'package:flutter_sqflite_example/models/device_model.dart';

class Trip {
  final String? id;

  final String? vesselId;
  final String? currentLoad;
  final String? lat;
  final String? long;
  final String? createdAt;
  final String? updatedAt;
  final int? isSync;
  final int? tripStatus;
  String? deviceInfo;

  Trip({
    this.id,
    this.vesselId,
    required this.currentLoad,
    this.isSync,
    this.tripStatus,
    this.updatedAt,
    this.createdAt,
    this.deviceInfo,
    this.lat,
    this.long
  });

  // Convert a Trip into a Map. The keys must correspond to the vesselNames of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vesselId': vesselId,
      'currentLoad': currentLoad,
      'isSync': isSync,
      'tripStatus': tripStatus,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'deviceInfo': deviceInfo,
      'lat': lat,
      'long': long,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id']?? 0,
      vesselId: map['vesselId'] ?? '',
      currentLoad: map['currentLoad'] ?? '',
      isSync: map['isSync']?.toInt()?? 0,
      tripStatus: map['tripStatus']?.toInt() ?? 0,
      updatedAt: map['updatedAt'] ?? '',
      createdAt: map['createdAt'] ?? '',
      deviceInfo: map['deviceInfo'] ?? '',
      lat: map['lat'] ?? '',
      long: map['long'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each Trip when using the print statement.
  @override
  String toString() => 'Trip(id: $id, '
      'currentLoad: $currentLoad,'
      'vesselId: $vesselId,'
      'isSync: $isSync,'
      'deviceInfo: $deviceInfo,'
      'tripStatus: $tripStatus)';
}
