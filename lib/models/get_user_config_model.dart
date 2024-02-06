class GetUserConfigModel {
  String? userId;
  String? userEmail;
  String? firstName;
  String? lastName;
  List<Vessels>? vessels;
  List<Trips>? trips;
  String? message;
  bool? status;
  int? statusCode;

  GetUserConfigModel(
      {this.userId,
      this.userEmail,
      this.firstName,
      this.lastName,
      this.vessels,
      this.trips,
      this.message,
      this.status,
      this.statusCode});

  GetUserConfigModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userEmail = json['userEmail'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    if (json['vessels'] != null) {
      vessels = <Vessels>[];
      json['vessels'].forEach((v) {
        vessels!.add(new Vessels.fromJson(v));
      });
    }
    if (json['trips'] != null) {
      trips = <Trips>[];
      json['trips'].forEach((v) {
        trips!.add(new Trips.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userEmail'] = this.userEmail;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    if (this.vessels != null) {
      data['vessels'] = this.vessels!.map((v) => v.toJson()).toList();
    }
    if (this.trips != null) {
      data['trips'] = this.trips!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Vessels {
  String? name;
  String? model;
  String? builderName;
  String? regNumber;
  String? mMSI;
  String? engineType;
  int? fuelCapacity;
  int? batteryCapacity;
  String? weight;
  List<String>? imageURLs;
  double? freeBoard;
  double? lengthOverall;
  double? beam;
  double? depth;
  String? vesselSize;
  String? capacity;
  int? builtYear;
  int? vesselStatus;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? syncCreatedAt;
  String? syncUpdatedAt;
  String? id;
  int? hullType;

  Vessels(
      {this.name,
      this.model,
      this.builderName,
      this.regNumber,
      this.mMSI,
      this.engineType,
      this.fuelCapacity,
      this.batteryCapacity,
      this.weight,
      this.imageURLs,
      this.freeBoard,
      this.lengthOverall,
      this.beam,
      this.depth,
      this.vesselSize,
      this.capacity,
      this.builtYear,
      this.vesselStatus,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.syncCreatedAt,
      this.syncUpdatedAt,
      this.id, this.hullType});

  Vessels.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    model = json['model'];
    builderName = json['builderName'];
    regNumber = json['regNumber'];
    mMSI = json['MMSI'];
    engineType = json['engineType'];
    fuelCapacity = json['fuelCapacity'];
    batteryCapacity = json['batteryCapacity'];
    weight = json['weight'];
    if (json['imageURLs'] != null) {
      imageURLs = <String>[];
      json['imageURLs'].forEach((v) {
        imageURLs!.add(v);
      });
    }
    freeBoard = json['freeBoard'];
    lengthOverall = json['lengthOverall'];
    beam = json['beam'];
    depth = json['depth'];
    vesselSize = json['vesselSize'];
    capacity = json['capacity'];
    builtYear = json['builtYear'];
    vesselStatus = json['vesselStatus'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    syncCreatedAt = json['syncCreatedAt'];
    syncUpdatedAt = json['syncUpdatedAt'];
    id = json['id'];
    hullType = json['hullShape'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['model'] = this.model;
    data['builderName'] = this.builderName;
    data['regNumber'] = this.regNumber;
    data['MMSI'] = this.mMSI;
    data['engineType'] = this.engineType;
    data['fuelCapacity'] = this.fuelCapacity;
    data['batteryCapacity'] = this.batteryCapacity;
    data['weight'] = this.weight;
    if (this.imageURLs != null) {
      data['imageURLs'] = this.imageURLs!.map((v) => v).toList();
    }
    data['freeBoard'] = this.freeBoard;
    data['lengthOverall'] = this.lengthOverall;
    data['beam'] = this.beam;
    data['depth'] = this.depth;
    data['vesselSize'] = this.vesselSize;
    data['capacity'] = this.capacity;
    data['builtYear'] = this.builtYear;
    data['vesselStatus'] = this.vesselStatus;
    data['createdBy'] = this.createdBy;
    data['createdAt'] = this.createdAt;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    data['syncCreatedAt'] = this.syncCreatedAt;
    data['syncUpdatedAt'] = this.syncUpdatedAt;
    data['id'] = this.id;
    data['hullShape'] = this.hullType;
    return data;
  }
}

class Trips {
  String? load;
  List<String>? startPosition;
  List<String>? endPosition;
  List<SensorInfo>? sensorInfo;
  DeviceInfo? deviceInfo;
  String? vesselId;
  int? tripStatus;
  int? dataExtStatus;
  int? numberOfPassengers;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? filePath;
  String? syncCreatedAt;
  String? syncUpdatedAt;
  String? duration;
  double? distance;
  double? speed;
  double? avgSpeed;
  String? cloudFilePath;
  String? exceptionMsg;
  String? id;

  Trips(
      {this.load,
      this.startPosition,
      this.endPosition,
      this.sensorInfo,
      this.deviceInfo,
      this.vesselId,
      this.tripStatus,
      this.dataExtStatus,
      this.numberOfPassengers,
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
      this.exceptionMsg,
      this.id});

  Trips.fromJson(Map<String, dynamic> json) {
    load = json['load'];
    startPosition = json['startPosition'].cast<String>();
    endPosition = json['endPosition'].cast<String>();
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
    dataExtStatus = json['dataExtStatus'];
    numberOfPassengers = json['numberOfPassengers'] ?? json['number_of_passengers'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    filePath = json['filePath'];
    syncCreatedAt = json['syncCreatedAt'];
    syncUpdatedAt = json['syncUpdatedAt'];
    duration = json['duration'];
    distance = json['distance'];
    speed = json['speed'];
    avgSpeed = json['avgSpeed'];
    cloudFilePath = json['cloudFilePath'];
    exceptionMsg = json['exceptionMsg'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['load'] = this.load;
    data['startPosition'] = this.startPosition;
    data['endPosition'] = this.endPosition;
    if (this.sensorInfo != null) {
      data['sensorInfo'] = this.sensorInfo!.map((v) => v.toJson()).toList();
    }
    if (this.deviceInfo != null) {
      data['deviceInfo'] = this.deviceInfo!.toJson();
    }
    data['vesselId'] = this.vesselId;
    data['tripStatus'] = this.tripStatus;
    data['dataExtStatus'] = this.dataExtStatus;
    data['numberOfPassengers'] = this.numberOfPassengers;
    data['createdBy'] = this.createdBy;
    data['createdAt'] = this.createdAt;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    data['filePath'] = this.filePath;
    data['syncCreatedAt'] = this.syncCreatedAt;
    data['syncUpdatedAt'] = this.syncUpdatedAt;
    data['duration'] = this.duration;
    data['distance'] = this.distance;
    data['speed'] = this.speed;
    data['avgSpeed'] = this.avgSpeed;
    data['cloudFilePath'] = this.cloudFilePath;
    data['exceptionMsg'] = this.exceptionMsg;
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
