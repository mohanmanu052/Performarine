import 'dart:convert';


class Trip {
  final String? id;
  final String? name;
  final String? vesselId;
  final String? vesselName;
  final String? currentLoad;
  int? numberOfPassengers;
  final String? filePath;
  final String? startPosition;
  final String? endPosition;
  final String? createdAt;
  final String? updatedAt;
  int? isSync;
  int? tripStatus;
  String? deviceInfo;
  final String? time;
  final String? distance;
  final String? speed;
  final String? avgSpeed;
  int? isCloud;
  bool? isEndTripClicked;
  String? createdBy;

  Trip(
      {
        this.id,
        this.name,
      this.vesselId,
      this.vesselName,
      required this.currentLoad,
      this.numberOfPassengers,
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
      this.speed,
      this.avgSpeed,
      this.isCloud,
      this.createdBy,
      this.isEndTripClicked});

  // Convert a Trip into a Map. The keys must correspond to the vesselNames of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vesselId': vesselId,
      'vesselName': vesselName,
      'currentLoad': currentLoad,
      'numberOfPassengers': numberOfPassengers,
      'filePath': filePath,
      'isSync': isSync,
      'tripStatus': tripStatus,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'deviceInfo': deviceInfo,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'duration': time,
      'distance': distance,
      'speed': speed,
      'avgSpeed': avgSpeed,
      'createdBy':createdBy,
      'isCloud': isCloud,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      vesselId: map['vesselId'] ?? '',
      vesselName: map['vesselName'] ?? '',
      currentLoad: map['currentLoad'] ?? '',
      numberOfPassengers: map['numberOfPassengers'] ?? map['number_of_passengers'] ?? '',
      filePath: map['filePath'] ?? '',
      isSync: map['isSync']?.toInt() ?? 0,
      tripStatus: map['tripStatus']?.toInt() ?? 0,
      updatedAt: map['updatedAt'] ?? '',
      createdAt: map['createdAt'] ?? '',
      deviceInfo: map['deviceInfo'] ?? '',
      startPosition: map['startPosition'] ?? '',
      endPosition: map['endPosition'] ?? '',
      time: map['duration'] ?? '',
      distance: map['distance'] ?? '',
      speed: map['speed'] ?? '',
      avgSpeed: map['avgSpeed'] ?? '',
      isCloud: map['isCloud'] ?? 0,
      createdBy: map['createdBy']??'',
      isEndTripClicked: false,
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
