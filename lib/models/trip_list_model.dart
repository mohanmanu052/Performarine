// To parse this JSON data, do
//
//     final tripList = tripListFromJson(jsonString);

import 'dart:convert';

TripList tripListFromJson(String str) => TripList.fromJson(json.decode(str));

String tripListToJson(TripList data) => json.encode(data.toJson());

class TripList {
  List<Data>? data;
  String? message;
  bool? status;
  int? statusCode;

  TripList({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory TripList.fromJson(Map<String, dynamic> json) => TripList(
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    message: json["message"],
    status: json["status"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "status": status,
    "statusCode": statusCode,
  };
}

class Data {
  dynamic exceptionMsg;
  MissingLineNumbers? missingLineNumbers;
  List<String>? sensorType;
  dynamic fuelConsumption;
  dynamic avgPower;
  bool? vesselAnalyticsCalc;
  Load? load;
  List<String>? startPosition;
  List<String>? endPosition;
  List<SensorInfo>? sensorInfo;
  DeviceInfo? deviceInfo;
  VesselId? vesselId;
  int? tripStatus;
  int? dataExtStatus;
  AtedBy? createdBy;
  DateTime? createdAt;
  AtedBy? updatedBy;
  DateTime? updatedAt;
  String? filePath;
  DateTime? syncCreatedAt;
  DateTime? syncUpdatedAt;
  String? duration;
  double? distance;
  double? speed;
  double? avgSpeed;
  String? cloudFilePath;
  String? id;

  Data({
    this.exceptionMsg,
    this.missingLineNumbers,
    this.sensorType,
    this.fuelConsumption,
    this.avgPower,
    this.vesselAnalyticsCalc,
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
    this.updatedAt,
    this.filePath,
    this.syncCreatedAt,
    this.syncUpdatedAt,
    this.duration,
    this.distance,
    this.speed,
    this.avgSpeed,
    this.cloudFilePath,
    this.id,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    exceptionMsg: json["exceptionMsg"],
    missingLineNumbers: MissingLineNumbers.fromJson(json["missingLineNumbers"]),
    sensorType: List<String>.from(json["sensorType"].map((x) => x)),
    fuelConsumption: json["fuelConsumption"],
    avgPower: json["avgPower"],
    vesselAnalyticsCalc: json["vesselAnalyticsCalc"],
    load: loadValues.map[json["load"]],
    startPosition: List<String>.from(json["startPosition"].map((x) => x)),
    endPosition: List<String>.from(json["endPosition"].map((x) => x)),
    sensorInfo: List<SensorInfo>.from(json["sensorInfo"].map((x) => SensorInfo.fromJson(x))),
    deviceInfo: DeviceInfo.fromJson(json["deviceInfo"]),
    vesselId: vesselIdValues.map[json["vesselId"]],
    tripStatus: json["tripStatus"],
    dataExtStatus: json["dataExtStatus"],
    createdBy: atedByValues.map[json["createdBy"]],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedBy: atedByValues.map[json["updatedBy"]],
    updatedAt: DateTime.parse(json["updatedAt"]),
    filePath: json["filePath"],
    syncCreatedAt: DateTime.parse(json["syncCreatedAt"]),
    syncUpdatedAt: DateTime.parse(json["syncUpdatedAt"]),
    duration: json["duration"],
    distance: json["distance"],
    speed: json["speed"].toDouble(),
    avgSpeed: json["avgSpeed"].toDouble(),
    cloudFilePath: json["cloudFilePath"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "exceptionMsg": exceptionMsg,
    "missingLineNumbers": missingLineNumbers!.toJson(),
    "sensorType": List<dynamic>.from(sensorType!.map((x) => x)),
    "fuelConsumption": fuelConsumption,
    "avgPower": avgPower,
    "vesselAnalyticsCalc": vesselAnalyticsCalc,
    "load": loadValues.reverse[load],
    "startPosition": List<dynamic>.from(startPosition!.map((x) => x)),
    "endPosition": List<dynamic>.from(endPosition!.map((x) => x)),
    "sensorInfo": List<dynamic>.from(sensorInfo!.map((x) => x.toJson())),
    "deviceInfo": deviceInfo!.toJson(),
    "vesselId": vesselIdValues.reverse[vesselId],
    "tripStatus": tripStatus,
    "dataExtStatus": dataExtStatus,
    "createdBy": atedByValues.reverse[createdBy],
    "createdAt": createdAt!.toIso8601String(),
    "updatedBy": atedByValues.reverse[updatedBy],
    "updatedAt": updatedAt!.toIso8601String(),
    "filePath": filePath,
    "syncCreatedAt": syncCreatedAt!.toIso8601String(),
    "syncUpdatedAt": syncUpdatedAt!.toIso8601String(),
    "duration": duration,
    "distance": distance,
    "speed": speed,
    "avgSpeed": avgSpeed,
    "cloudFilePath": cloudFilePath,
    "id": id,
  };
}

enum AtedBy { THE_640023_F9_CE30_F37_DF289_C4_F9 }

final atedByValues = EnumValues({
  "640023f9ce30f37df289c4f9": AtedBy.THE_640023_F9_CE30_F37_DF289_C4_F9
});

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

enum Board { A32_X, I_PHONE12_8 }

final boardValues = EnumValues({
  "a32x": Board.A32_X,
  "iPhone12,8": Board.I_PHONE12_8
});

enum DeviceId { TP1_A_220624014, EMPTY }

final deviceIdValues = EnumValues({
  "": DeviceId.EMPTY,
  "TP1A.220624.014": DeviceId.TP1_A_220624014
});

enum DeviceType { ANDROID, IOS }

final deviceTypeValues = EnumValues({
  "Android": DeviceType.ANDROID,
  "IOS": DeviceType.IOS
});

enum DeviceInfoMake { SAMSUNG, I_PHONE12_8 }

final deviceInfoMakeValues = EnumValues({
  "iPhone12,8": DeviceInfoMake.I_PHONE12_8,
  "samsung": DeviceInfoMake.SAMSUNG
});

enum Model { SM_M326_B, I_PHONE }

final modelValues = EnumValues({
  "iPhone": Model.I_PHONE,
  "SM-M326B": Model.SM_M326_B
});

enum Load { FULL, HALF, EMPTY, VARIABLE }

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

  factory MissingLineNumbers.fromJson(Map<String, dynamic> json) => MissingLineNumbers(
    mobile1Csv: json["mobile_1.csv"] == null ? [] : List<dynamic>.from(json["mobile_1.csv"].map((x) => x)),
    lpr1Csv: json["lpr_1.csv"] == null ? [] : List<dynamic>.from(json["lpr_1.csv"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "mobile_1.csv": List<dynamic>.from(mobile1Csv!.map((x) => x)),
    "lpr_1.csv": List<dynamic>.from(lpr1Csv!.map((x) => x)),
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

final sensorInfoMakeValues = EnumValues({
  "qualicom": SensorInfoMake.QUALICOM
});

enum Name { GPS }

final nameValues = EnumValues({
  "gps": Name.GPS
});

enum VesselId { THE_6407700_E7_BC3_DCFBC74_BB358 }

final vesselIdValues = EnumValues({
  "6407700e7bc3dcfbc74bb358": VesselId.THE_6407700_E7_BC3_DCFBC74_BB358
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}