class TripList {
  List<Data>? data;
  String? message;
  bool? status;
  int? statusCode;

  TripList({this.data, this.message, this.status, this.statusCode});

  TripList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Data {
  dynamic? endDate;
  String? load;
  String? startDate;
  String? lat;
  String? long;
  List<SensorInfo>? sensorInfo;
  DeviceInfo? deviceInfo;
  String? vesselId;
  int? tripStatus;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? id;

  Data(
      {this.endDate,
        this.load,
        this.startDate,
        this.lat,
        this.long,
        this.sensorInfo,
        this.deviceInfo,
        this.vesselId,
        this.tripStatus,
        this.createdBy,
        this.createdAt,
        this.updatedBy,
        this.updatedAt,
        this.id});

  Data.fromJson(Map<String, dynamic> json) {
    endDate = json['endDate'];
    load = json['load'];
    startDate = json['startDate'];
    lat = json['lat'];
    long = json['long'];
    if (json['sensorInfo'] != null) {
      sensorInfo = <SensorInfo>[];
      json['sensorInfo'].forEach((v) {
        sensorInfo!.add(new SensorInfo.fromJson(v));
      });
    }
    deviceInfo = json['deviceInfo'] != null
        ? new DeviceInfo.fromJson(json['deviceInfo'])
        : null;
    vesselId = json['vesselId'];
    tripStatus = json['tripStatus'];
    createdBy = json['createdBy'];
    createdAt = json['CreatedAt'] != null ? json['CreatedAt'] : "";
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['endDate'] = this.endDate;
    data['load'] = this.load;
    data['startDate'] = this.startDate;
    data['lat'] = this.lat;
    data['long'] = this.long;
    if (this.sensorInfo != null) {
      data['sensorInfo'] = this.sensorInfo!.map((v) => v.toJson()).toList();
    }
    if (this.deviceInfo != null) {
      data['deviceInfo'] = this.deviceInfo!.toJson();
    }
    data['vesselId'] = this.vesselId;
    data['tripStatus'] = this.tripStatus;
    data['createdBy'] = this.createdBy;
    data['CreatedAt'] = this.createdAt;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    data['id'] = this.id;
    return data;
  }
}

class SensorInfo {
  String? make;
  String? name;

  SensorInfo({this.make, this.name});

  SensorInfo.fromJson(Map<String, dynamic> json) {
    make = json['make'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['make'] = this.make;
    data['name'] = this.name;
    return data;
  }
}

class DeviceInfo {
  String? deviceId;
  String? model;
  String? version;
  String? make;
  String? board;
  String? deviceType;

  DeviceInfo(
      {this.deviceId,
        this.model,
        this.version,
        this.make,
        this.board,
        this.deviceType});

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    model = json['model'];
    version = json['version'];
    make = json['make'];
    board = json['board'];
    deviceType = json['deviceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceId'] = this.deviceId;
    data['model'] = this.model;
    data['version'] = this.version;
    data['make'] = this.make;
    data['board'] = this.board;
    data['deviceType'] = this.deviceType;
    return data;
  }
}