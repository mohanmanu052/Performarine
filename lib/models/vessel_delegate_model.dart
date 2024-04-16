class VesselDelegateModel {
  List<MyVesselDelegaties>? myVesselDelegaties;
  String? message;
  bool? status;
  int? statusCode;

  VesselDelegateModel(
      {this.myVesselDelegaties, this.message, this.status, this.statusCode});

  VesselDelegateModel.fromJson(Map<String, dynamic> json) {
    if (json['my_vessel_delegaties'] != null) {
      myVesselDelegaties = <MyVesselDelegaties>[];
      json['my_vessel_delegaties'].forEach((v) {
        myVesselDelegaties!.add(new MyVesselDelegaties.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.myVesselDelegaties != null) {
      data['my_vessel_delegaties'] =
          this.myVesselDelegaties!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class MyVesselDelegaties {
  VesselInfo? vesselInfo;
  List<Delegates>? delegates;
  dynamic delegateCount;
  String? vesselId;

  MyVesselDelegaties(
      {this.vesselInfo, this.delegates, this.delegateCount, this.vesselId});

  MyVesselDelegaties.fromJson(Map<String, dynamic> json) {
    vesselInfo = json['vesselInfo'] != null
        ? new VesselInfo.fromJson(json['vesselInfo'])
        : null;
    if (json['delegates'] != null) {
      delegates = <Delegates>[];
      json['delegates'].forEach((v) {
        delegates!.add(new Delegates.fromJson(v));
      });
    }
    delegateCount = json['delegate_count'];
    vesselId = json['vesselId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vesselInfo != null) {
      data['vesselInfo'] = this.vesselInfo!.toJson();
    }
    if (this.delegates != null) {
      data['delegates'] = this.delegates!.map((v) => v.toJson()).toList();
    }
    data['delegate_count'] = this.delegateCount;
    data['vesselId'] = this.vesselId;
    return data;
  }
}

class VesselInfo {
  String? name;
  String? model;
  String? builderName;
  String? regNumber;
  String? mMSI;
  String? engineType;
  dynamic fuelCapacity;
  dynamic batteryCapacity;
  String? weight;
  List<String>? imageURLs;
  dynamic freeBoard;
  dynamic lengthOverall;
  dynamic beam;
  dynamic depth;
  String? vesselSize;
  String? capacity;
  dynamic hullShape;
  dynamic builtYear;
  dynamic vesselStatus;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? syncCreatedAt;
  String? syncUpdatedAt;

  VesselInfo(
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
        this.hullShape,
        this.builtYear,
        this.vesselStatus,
        this.createdBy,
        this.createdAt,
        this.updatedBy,
        this.updatedAt,
        this.syncCreatedAt,
        this.syncUpdatedAt});

  VesselInfo.fromJson(Map<String, dynamic> json) {
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
    hullShape = json['hullShape'];
    builtYear = json['builtYear'];
    vesselStatus = json['vesselStatus'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    syncCreatedAt = json['syncCreatedAt'];
    syncUpdatedAt = json['syncUpdatedAt'];
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
    data['hullShape'] = this.hullShape;
    data['builtYear'] = this.builtYear;
    data['vesselStatus'] = this.vesselStatus;
    data['createdBy'] = this.createdBy;
    data['createdAt'] = this.createdAt;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    data['syncCreatedAt'] = this.syncCreatedAt;
    data['syncUpdatedAt'] = this.syncUpdatedAt;
    return data;
  }
}

class Delegates {
  String? id;
  String? delegateUserId;
  String? delegateUserName;
  String? delegateUserEmail;
  dynamic delegateaccessType;
  String? delegateaccessTime;
  String? status;

  Delegates(
      {this.id,
        this.delegateUserId,
        this.delegateUserName,
        this.delegateUserEmail,
        this.delegateaccessType,
        this.delegateaccessTime,
        this.status});

  Delegates.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    delegateUserId = json['delegateUserId'];
    delegateUserName = json['delegateUserName'];
    delegateUserEmail = json['delegateUserEmail'];
    delegateaccessType = json['delegateaccessType'];
    delegateaccessTime = json['delegateaccessTime'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['delegateUserId'] = this.delegateUserId;
    data['delegateUserName'] = this.delegateUserName;
    data['delegateUserEmail'] = this.delegateUserEmail;
    data['delegateaccessType'] = this.delegateaccessType;
    data['delegateaccessTime'] = this.delegateaccessTime;
    data['status'] = this.status;
    return data;
  }
}
