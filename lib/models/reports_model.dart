

import 'dart:convert';

ReportModel reportModelFromJson(String str) => ReportModel.fromJson(json.decode(str));

String reportModelToJson(ReportModel data) => json.encode(data.toJson());

class ReportModel {
  Data data;
  String message;
  bool status;
  int statusCode;

  ReportModel({
    required this.data,
    required this.message,
    required this.status,
    required this.statusCode,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    data: Data.fromJson(json["data"]),
    message: json["message"],
    status: json["status"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "message": message,
    "status": status,
    "statusCode": statusCode,
  };
}

class Data {
  List<Trip> trips;
  AvgInfo avgInfo;

  Data({
    required this.trips,
    required this.avgInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    trips: List<Trip>.from(json["trips"].map((x) => Trip.fromJson(x))),
    avgInfo: AvgInfo.fromJson(json["avgInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "trips": List<dynamic>.from(trips.map((x) => x.toJson())),
    "avgInfo": avgInfo.toJson(),
  };
}

class AvgInfo {
  int count;
  dynamic avgDuration;
  double avgSpeed;
  double avgFuelConsumption;
  double avgPower;
  double totalDurationHrs;

  AvgInfo({
    required this.count,
    required this.avgDuration,
    required this.avgSpeed,
    required this.avgFuelConsumption,
    required this.avgPower,
    required this.totalDurationHrs,
  });

  factory AvgInfo.fromJson(Map<String, dynamic> json) => AvgInfo(
    count: json["count"],
    avgDuration: json["avgDuration"],
    avgSpeed: json["avgSpeed"]?.toDouble(),
    avgFuelConsumption: json["avgFuelConsumption"],
    avgPower: json["avgPower"]?.toDouble(),
    totalDurationHrs: json["totalDurationHrs"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "avgDuration": avgDuration,
    "avgSpeed": avgSpeed,
    "avgFuelConsumption": avgFuelConsumption,
    "avgPower": avgPower,
    "totalDurationHrs": totalDurationHrs,
  };
}

class Trip {
  String date;
  List<TripsByDate> tripsByDate;

  Trip({
    required this.date,
    required this.tripsByDate,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    date: json["date"],
    tripsByDate: List<TripsByDate>.from(json["tripsByDate"].map((x) => TripsByDate.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "tripsByDate": List<dynamic>.from(tripsByDate.map((x) => x.toJson())),
  };
}

class TripsByDate {
  String id;
  String load;
  List<String> startPosition;
  List<String> endPosition;
  List<SensorInfo> sensorInfo;
  DeviceInfo deviceInfo;
  String vesselId;
  int tripStatus;
  int dataExtStatus;
  String createdBy;
  DateTime createdAt;
  String updatedBy;
  DateTime updatedAt;
  String filePath;
  DateTime syncCreatedAt;
  DateTime syncUpdatedAt;
  dynamic duration;
  double distance;
  double speed;
  double avgSpeed;
  String cloudFilePath;
  MissingLineNumbers? missingLineNumbers;
  List<String>? sensorType;
  bool? vesselAnalyticsCalc;
  String? exceptionMsg;
  double? avgPower;
  double? fuelConsumption;

  TripsByDate({
    required this.id,
    required this.load,
    required this.startPosition,
    required this.endPosition,
    required this.sensorInfo,
    required this.deviceInfo,
    required this.vesselId,
    required this.tripStatus,
    required this.dataExtStatus,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.filePath,
    required this.syncCreatedAt,
    required this.syncUpdatedAt,
    required this.duration,
    required this.distance,
    required this.speed,
    required this.avgSpeed,
    required this.cloudFilePath,
    this.missingLineNumbers,
    this.sensorType,
    this.vesselAnalyticsCalc,
    this.exceptionMsg,
    this.avgPower,
    this.fuelConsumption,
  });

  factory TripsByDate.fromJson(Map<String, dynamic> json) => TripsByDate(
    id: json["_id"],
    load: json["load"],
    startPosition: List<String>.from(json["startPosition"].map((x) => x)),
    endPosition: List<String>.from(json["endPosition"].map((x) => x)),
    sensorInfo: List<SensorInfo>.from(json["sensorInfo"].map((x) => SensorInfo.fromJson(x))),
    deviceInfo: DeviceInfo.fromJson(json["deviceInfo"]),
    vesselId: json["vesselId"],
    tripStatus: json["tripStatus"],
    dataExtStatus: json["dataExtStatus"],
    createdBy: json["createdBy"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedBy: json["updatedBy"],
    updatedAt: DateTime.parse(json["updatedAt"]),
    filePath: json["filePath"],
    syncCreatedAt: DateTime.parse(json["syncCreatedAt"]),
    syncUpdatedAt: DateTime.parse(json["syncUpdatedAt"]),
    duration: json["duration"],
    distance: json["distance"]?.toDouble(),
    speed: json["speed"]?.toDouble(),
    avgSpeed: json["avgSpeed"]?.toDouble(),
    cloudFilePath: json["cloudFilePath"],
    missingLineNumbers: json["missingLineNumbers"] == null ? null : MissingLineNumbers.fromJson(json["missingLineNumbers"]),
    sensorType: json["sensorType"] == null ? [] : List<String>.from(json["sensorType"]!.map((x) => x)),
    vesselAnalyticsCalc: json["vesselAnalyticsCalc"],
    exceptionMsg: json["exceptionMsg"],
    avgPower: json["avgPower"]?.toDouble(),
    fuelConsumption: json["fuelConsumption"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "load": load,
    "startPosition": List<dynamic>.from(startPosition.map((x) => x)),
    "endPosition": List<dynamic>.from(endPosition.map((x) => x)),
    "sensorInfo": List<dynamic>.from(sensorInfo.map((x) => x.toJson())),
    "deviceInfo": deviceInfo.toJson(),
    "vesselId": vesselId,
    "tripStatus": tripStatus,
    "dataExtStatus": dataExtStatus,
    "createdBy": createdBy,
    "createdAt": createdAt.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedAt": updatedAt.toIso8601String(),
    "filePath": filePath,
    "syncCreatedAt": syncCreatedAt.toIso8601String(),
    "syncUpdatedAt": syncUpdatedAt.toIso8601String(),
    "duration": duration,
    "distance": distance,
    "speed": speed,
    "avgSpeed": avgSpeed,
    "cloudFilePath": cloudFilePath,
    "missingLineNumbers": missingLineNumbers?.toJson(),
    "sensorType": sensorType == null ? [] : List<dynamic>.from(sensorType!.map((x) => x)),
    "vesselAnalyticsCalc": vesselAnalyticsCalc,
    "exceptionMsg": exceptionMsg,
    "avgPower": avgPower,
    "fuelConsumption": fuelConsumption,
  };
}

class DeviceInfo {
  String deviceId;
  String model;
  String version;
  String make;
  String board;
  String deviceType;

  DeviceInfo({
    required this.deviceId,
    required this.model,
    required this.version,
    required this.make,
    required this.board,
    required this.deviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    deviceId: json["deviceId"],
    model: json["model"],
    version: json["version"],
    make: json["make"],
    board: json["board"],
    deviceType: json["deviceType"],
  );

  Map<String, dynamic> toJson() => {
    "deviceId": deviceId,
    "model": model,
    "version": version,
    "make": make,
    "board": board,
    "deviceType": deviceType,
  };
}

class MissingLineNumbers {
  List<dynamic> lpr1Csv;
  List<dynamic> mobile1Csv;

  MissingLineNumbers({
    required this.lpr1Csv,
    required this.mobile1Csv,
  });

  factory MissingLineNumbers.fromJson(Map<String, dynamic> json) => MissingLineNumbers(
    lpr1Csv: List<dynamic>.from(json["lpr_1.csv"].map((x) => x)),
    mobile1Csv: List<dynamic>.from(json["mobile_1.csv"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "lpr_1.csv": List<dynamic>.from(lpr1Csv.map((x) => x)),
    "mobile_1.csv": List<dynamic>.from(mobile1Csv.map((x) => x)),
  };
}

class SensorInfo {
  String make;
  String name;

  SensorInfo({
    required this.make,
    required this.name,
  });

  factory SensorInfo.fromJson(Map<String, dynamic> json) => SensorInfo(
    make: json["make"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "make": make,
    "name": name,
  };
}
