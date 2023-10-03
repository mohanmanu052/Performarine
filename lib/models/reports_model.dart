// To parse this JSON data, do
//
//     final reportModel = reportModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

ReportModel reportModelFromJson(String str) =>
    ReportModel.fromJson(json.decode(str));

String reportModelToJson(ReportModel data) => json.encode(data.toJson());

class ReportModel {
  Data? data;
  String? message;
  bool? status;
  int? statusCode;

  ReportModel({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        data: Data.fromJson(json["data"]),
        message: json["message"],
        status: json["status"],
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> toJson() => {
        "data": data!.toJson(),
        "message": message,
        "status": status,
        "statusCode": statusCode,
      };
}

class Data {
  List<TripModel>? trips;
  AvgInfo? avgInfo;

  Data({
    this.trips,
    this.avgInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        trips: List<TripModel>.from(
            json["trips"].map((x) => TripModel.fromJson(x))),
        avgInfo: AvgInfo.fromJson(json["avgInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "trips": List<dynamic>.from(trips!.map((x) => x.toJson())),
        "avgInfo": avgInfo!.toJson(),
      };
}

class AvgInfo {
  int? count;
  String? avgDuration;
  double? avgSpeed;
  dynamic avgFuelConsumption;
  dynamic avgPower;
  double? totalDurationHrs;

  AvgInfo({
    this.count,
    this.avgDuration,
    this.avgSpeed,
    this.avgFuelConsumption,
    this.avgPower,
    this.totalDurationHrs,
  });

  factory AvgInfo.fromJson(Map<String, dynamic> json) => AvgInfo(
        count: json["count"],
        avgDuration: json["avgDuration"],
        avgSpeed: json["avgSpeed"]?.toDouble(),
        avgFuelConsumption: json["avgFuelConsumption"] != null
            ? json["avgFuelConsumption"]
            : 0.0,
        avgPower: json["avgPower"] != null ? json["avgPower"] : 0.0,
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

class TripModel {
  String? date;
  List<TripsByDate>? tripsByDate;

  TripModel({
    this.date,
    this.tripsByDate,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        date: json["date"],
        tripsByDate: List<TripsByDate>.from(
            json["tripsByDate"].map((x) => TripsByDate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "tripsByDate": List<dynamic>.from(tripsByDate!.map((x) => x.toJson())),
      };
}

class TripsByDate {
  String? id;
  String? load;
  Color? dataLineColor=Colors.blue;
  List<String>? startPosition;
  List<String>? endPosition;
  List<SensorInfo>? sensorInfo;
  DeviceInfo? deviceInfo;
  String? vesselId;
  int? tripStatus;
  int? dataExtStatus;
  String? createdBy;
  DateTime? createdAt;
  String? updatedBy;
  DateTime? updatedAt;
  String? filePath;
  DateTime? syncCreatedAt;
  DateTime? syncUpdatedAt;
  String? duration;
  double? distance;
  double? speed;
  double? avgSpeed;
  int?SelectedDataIndex;
  MissingLineNumbers? missingLineNumbers;
  List<String>? sensorType;
  bool? vesselAnalyticsCalc;
  String? cloudFilePath;
  double? avgPower;
  double? fuelConsumption;

  TripsByDate({
    this.id,
    this.load,
    this.startPosition,
    this.endPosition,
    this.sensorInfo,
    this.deviceInfo,
    this.vesselId,
    this.tripStatus,
    this.dataExtStatus,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.dataLineColor,
    this.updatedAt,
    this.filePath,
    this.syncCreatedAt,
    this.syncUpdatedAt,
    this.duration,
    this.distance,
    this.SelectedDataIndex,
    this.speed,
    this.avgSpeed,
    this.missingLineNumbers,
    this.sensorType,
    this.vesselAnalyticsCalc,
    this.cloudFilePath,
    this.avgPower = 0.0,
    this.fuelConsumption = 0.0,
  });

  factory TripsByDate.fromJson(Map<String, dynamic> json) => TripsByDate(
// <<<<<<< Report-code-merge
        id: json["_id"],
        load: json["load"],
        startPosition: List<String>.from(json["startPosition"].map((x) => x)),
        endPosition: List<String>.from(json["endPosition"].map((x) => x)),
        sensorInfo: List<SensorInfo>.from(
            json["sensorInfo"].map((x) => SensorInfo.fromJson(x))),
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
        distance: json["distance"].toDouble(),
        speed: json["speed"].toDouble(),
        avgSpeed: json["avgSpeed"].toDouble(),
        missingLineNumbers: json["missingLineNumbers"] != null
            ? MissingLineNumbers.fromJson(json["missingLineNumbers"])
            : MissingLineNumbers.fromJson({}),
        sensorType: json["sensorType"] != null
            ? List<String>.from(json["sensorType"].map((x) => x))
            : List<String>.from({}),
        vesselAnalyticsCalc: json["vesselAnalyticsCalc"],
        cloudFilePath: json["cloudFilePath"],
        avgPower: json["avgPower"] != null ? json["avgPower"].toDouble() : 0.0,
        fuelConsumption: json["fuelConsumption"] != null
            ? json["fuelConsumption"].toDouble()
            : 0.0,
      );
// =======
//     id: json["_id"],
//     load: json["load"],
//     startPosition: List<String>.from(json["startPosition"].map((x) => x)),
//     endPosition: List<String>.from(json["endPosition"].map((x) => x)),
//     sensorInfo: List<SensorInfo>.from(json["sensorInfo"].map((x) => SensorInfo.fromJson(x))),
//     deviceInfo: DeviceInfo.fromJson(json["deviceInfo"]),
//     vesselId: json["vesselId"],
//     tripStatus: json["tripStatus"],
//     dataExtStatus: json["dataExtStatus"],
//     createdBy: json["createdBy"],
//     createdAt: DateTime.parse(json["createdAt"]),
//     updatedBy: json["updatedBy"],
//     updatedAt: DateTime.parse(json["updatedAt"]),
//     filePath: json["filePath"],
//     syncCreatedAt: DateTime.parse(json["syncCreatedAt"]),
//     syncUpdatedAt: DateTime.parse(json["syncUpdatedAt"]),
//     duration: json["duration"],
//     distance: json["distance"].toDouble(),
//     speed: json["speed"].toDouble(),
//     avgSpeed: json["avgSpeed"].toDouble(),
//     missingLineNumbers: json["missingLineNumbers"] != null? MissingLineNumbers.fromJson(json["missingLineNumbers"]) : MissingLineNumbers.fromJson({}),
//     sensorType: json["sensorType"] != null ? List<String>.from(json["sensorType"].map((x) => x)) : List<String>.from({}),
//     vesselAnalyticsCalc: json["vesselAnalyticsCalc"],
//     cloudFilePath: json["cloudFilePath"],
//     avgPower: json["avgPower"] != null ? json["avgPower"].toDouble() :0.0,
//     fuelConsumption:  json["fuelConsumption"] != null ? json["fuelConsumption"] : 0.0,
//   );
// >>>>>>> Bug_loc_reports

  Map<String, dynamic> toJson() => {
        "_id": id,
        "load": load,
        "startPosition": List<dynamic>.from(startPosition!.map((x) => x)),
        "endPosition": List<dynamic>.from(endPosition!.map((x) => x)),
        "sensorInfo": List<dynamic>.from(sensorInfo!.map((x) => x.toJson())),
        "deviceInfo": deviceInfo!.toJson(),
        "vesselId": vesselId,
        "tripStatus": tripStatus,
        "dataExtStatus": dataExtStatus,
        "createdBy": createdBy,
        "createdAt": createdAt!.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedAt": updatedAt!.toIso8601String(),
        "filePath": filePath,
        "syncCreatedAt": syncCreatedAt!.toIso8601String(),
        "syncUpdatedAt": syncUpdatedAt!.toIso8601String(),
        "duration": duration,
        "distance": distance,
        "speed": speed,
        "avgSpeed": avgSpeed,
        "missingLineNumbers": missingLineNumbers!.toJson(),
        "sensorType": List<dynamic>.from(sensorType!.map((x) => x)),
        "vesselAnalyticsCalc": vesselAnalyticsCalc,
        "cloudFilePath": cloudFilePath,
        "avgPower": avgPower,
        "fuelConsumption": fuelConsumption,
      };
}

enum AtedBy { THE_640023_F9_CE30_F37_DF289_C4_F9 }

final atedByValues = EnumValues(
    {"640023f9ce30f37df289c4f9": AtedBy.THE_640023_F9_CE30_F37_DF289_C4_F9});

class DeviceInfo {
  DeviceId? deviceId;
  Model? model;
  String? version;
  DeviceInfoMake? make;
  Board? board;
  DeviceType? deviceType;

  DeviceInfo({
    this.deviceId,
    this.model,
    this.version,
    this.make,
    this.board,
    this.deviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        deviceId: deviceIdValues.map[json["deviceId"]],
        model: modelValues.map[json["model"]],
        version: json["version"],
        make: deviceInfoMakeValues.map[json["make"]],
        board: boardValues.map[json["board"]],
        deviceType: deviceTypeValues.map[json["deviceType"]],
      );

  Map<String, dynamic> toJson() => {
        "deviceId": deviceIdValues.reverse[deviceId],
        "model": modelValues.reverse[model],
        "version": version,
        "make": deviceInfoMakeValues.reverse[make],
        "board": boardValues.reverse[board],
        "deviceType": deviceTypeValues.reverse[deviceType],
      };
}

enum Board { A32_X }

final boardValues = EnumValues({"a32x": Board.A32_X});

enum DeviceId { TP1_A_220624014 }

final deviceIdValues =
    EnumValues({"TP1A.220624.014": DeviceId.TP1_A_220624014});

enum DeviceType { ANDROID }

final deviceTypeValues = EnumValues({"Android": DeviceType.ANDROID});

enum DeviceInfoMake { SAMSUNG }

final deviceInfoMakeValues = EnumValues({"samsung": DeviceInfoMake.SAMSUNG});

enum Model { SM_M326_B }

final modelValues = EnumValues({"SM-M326B": Model.SM_M326_B});

enum Load { HALF, EMPTY, FULL, VARIABLE }

final loadValues = EnumValues({
  "Empty": Load.EMPTY,
  "Full": Load.FULL,
  "Half": Load.HALF,
  "Variable": Load.VARIABLE
});

class MissingLineNumbers {
  List<dynamic>? mobile1Csv;
  List<dynamic>? lpr1Csv;

  MissingLineNumbers({
    this.mobile1Csv,
    this.lpr1Csv,
  });

  factory MissingLineNumbers.fromJson(Map<String, dynamic> json) =>
      MissingLineNumbers(
        mobile1Csv: json["mobile_1.csv"] == null
            ? []
            : List<dynamic>.from(json["mobile_1.csv"]!.map((x) => x)),
        lpr1Csv: json["lpr_1.csv"] == null
            ? []
            : List<dynamic>.from(json["lpr_1.csv"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "mobile_1.csv": mobile1Csv == null
            ? []
            : List<dynamic>.from(mobile1Csv!.map((x) => x)),
        "lpr_1.csv":
            lpr1Csv == null ? [] : List<dynamic>.from(lpr1Csv!.map((x) => x)),
      };
}

class SensorInfo {
  SensorInfoMake? make;
  Name? name;

  SensorInfo({
    this.make,
    this.name,
  });

  factory SensorInfo.fromJson(Map<String, dynamic> json) => SensorInfo(
        make: sensorInfoMakeValues.map[json["make"]],
        name: nameValues.map[json["name"]],
      );

  Map<String, dynamic> toJson() => {
        "make": sensorInfoMakeValues.reverse[make],
        "name": nameValues.reverse[name],
      };
}

enum SensorInfoMake { QUALICOM }

final sensorInfoMakeValues = EnumValues({"qualicom": SensorInfoMake.QUALICOM});

enum Name { GPS }

final nameValues = EnumValues({"gps": Name.GPS});

enum VesselId { THE_6407700_E7_BC3_DCFBC74_BB358 }

final vesselIdValues = EnumValues(
    {"6407700e7bc3dcfbc74bb358": VesselId.THE_6407700_E7_BC3_DCFBC74_BB358});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
