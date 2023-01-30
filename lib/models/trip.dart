import 'dart:convert';
import 'dart:io';

import 'package:performarine/models/device_model.dart';

class Trip {
  final String? id;
  final String? vesselId;
  final String? vesselName;
  final String? currentLoad;
  final String? filePath;
  final String? startPosition;
  final String? endPosition;
  final String? createdAt;
  final String? updatedAt;
  final int? isSync;
  final int? tripStatus;
  String? deviceInfo;
  final String? time;
  final String? distance;
  final String? speed;

  Trip(
      {this.id,
      this.vesselId,
      this.vesselName,
      required this.currentLoad,
      this.filePath,
      this.isSync,
      this.tripStatus,
      this.updatedAt,
      this.createdAt,
      this.deviceInfo,
      this.startPosition,
      this.endPosition,
      this.time,
      this.distance,
      this.speed});

  // Convert a Trip into a Map. The keys must correspond to the vesselNames of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vesselId': vesselId,
      'vesselName': vesselName,
      'currentLoad': currentLoad,
      'filePath': filePath,
      'isSync': isSync,
      'tripStatus': tripStatus,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'deviceInfo': deviceInfo,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'time': time,
      'distance': distance,
      'speed': speed,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? 0,
      vesselId: map['vesselId'] ?? '',
      vesselName: map['vesselName'] ?? '',
      currentLoad: map['currentLoad'] ?? '',
      filePath: map['filePath'] ?? '',
      isSync: map['isSync']?.toInt() ?? 0,
      tripStatus: map['tripStatus']?.toInt() ?? 0,
      updatedAt: map['updatedAt'] ?? '',
      createdAt: map['createdAt'] ?? '',
      deviceInfo: map['deviceInfo'] ?? '',
      startPosition: map['startPosition'] ?? '',
      endPosition: map['endPosition'] ?? '',
      time: map['time'] ?? '',
      distance: map['distance'] ?? '',
      speed: map['speed'] ?? '',
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
      'vesselName: $vesselName,'
      'filePath: $filePath,'
      'isSync: $isSync,'
      'deviceInfo: $deviceInfo,'
      'tripStatus: $tripStatus)';
}
