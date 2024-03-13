class FleetDetailsModel {
  List<MyFleets>? myFleets;
  String? message;
  bool? status;
  int? statusCode;

  FleetDetailsModel(
      {this.myFleets, this.message, this.status, this.statusCode});

  FleetDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json['my_fleets'] != null) {
      myFleets = <MyFleets>[];
      json['my_fleets'].forEach((v) {
        myFleets!.add(new MyFleets.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.myFleets != null) {
      data['my_fleets'] = this.myFleets!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class MyFleets {
  String? sId;
  String? fleetName;
  List<Members>? members;
  List<FleetVessels>? fleetVessels;

  MyFleets({this.sId, this.fleetName, this.members, this.fleetVessels});

  MyFleets.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fleetName = json['fleet_name'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
    if (json['fleetVessels'] != null) {
      fleetVessels = <FleetVessels>[];
      json['fleetVessels'].forEach((v) {
        fleetVessels!.add(new FleetVessels.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fleet_name'] = this.fleetName;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    if (this.fleetVessels != null) {
      data['fleetVessels'] = this.fleetVessels!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Members {
  String? memberId;
  int? vesselCount;
  String? fleetJoinedDate;
  String? memberUserId;
  int? memberStatus;
  String? memberName;

  Members(
      {this.memberId,
        this.vesselCount,
        this.fleetJoinedDate,
        this.memberUserId,
        this.memberStatus,
        this.memberName});

  Members.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    vesselCount = json['vessel_count'];
    fleetJoinedDate = json['fleetJoinedDate'];
    memberUserId = json['memberUserId'];
    memberStatus = json['memberStatus'];
    memberName = json['memberName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_id'] = this.memberId;
    data['vessel_count'] = this.vesselCount;
    data['fleetJoinedDate'] = this.fleetJoinedDate;
    data['memberUserId'] = this.memberUserId;
    data['memberStatus'] = this.memberStatus;
    data['memberName'] = this.memberName;
    return data;
  }
}

class FleetVessels {
  String? fleetvesselId;
  VesselInfo? vesselInfo;
  String? vesselId;
  String? vesselCreatedBy;
  String? vesselOwner;

  FleetVessels(
      {this.fleetvesselId,
        this.vesselInfo,
        this.vesselId,
        this.vesselCreatedBy,
        this.vesselOwner});

  FleetVessels.fromJson(Map<String, dynamic> json) {
    fleetvesselId = json['fleetvesselId'];
    vesselInfo = json['vessel_info'] != null
        ? new VesselInfo.fromJson(json['vessel_info'])
        : null;
    vesselId = json['vesselId'];
    vesselCreatedBy = json['vesselCreatedBy'];
    vesselOwner = json['vesselOwner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fleetvesselId'] = this.fleetvesselId;
    if (this.vesselInfo != null) {
      data['vessel_info'] = this.vesselInfo!.toJson();
    }
    data['vesselId'] = this.vesselId;
    data['vesselCreatedBy'] = this.vesselCreatedBy;
    data['vesselOwner'] = this.vesselOwner;
    return data;
  }
}

class VesselInfo {
  String? sId;
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
  dynamic builtYear;
  dynamic vesselStatus;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? syncCreatedAt;
  String? syncUpdatedAt;
  dynamic hullShape;

  VesselInfo(
      {this.sId,
        this.name,
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
        this.hullShape});

  VesselInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    model = json['model'];
    builderName = json['builderName'];
    regNumber = json['regNumber'];
    mMSI = json['MMSI'];
    engineType = json['engineType'];
    fuelCapacity = json['fuelCapacity'];
    batteryCapacity = json['batteryCapacity'];
    weight = json['weight'];
    imageURLs = json['imageURLs'].cast<String>();
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
    hullShape = json['hullShape'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['model'] = this.model;
    data['builderName'] = this.builderName;
    data['regNumber'] = this.regNumber;
    data['MMSI'] = this.mMSI;
    data['engineType'] = this.engineType;
    data['fuelCapacity'] = this.fuelCapacity;
    data['batteryCapacity'] = this.batteryCapacity;
    data['weight'] = this.weight;
    data['imageURLs'] = this.imageURLs;
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
    data['hullShape'] = this.hullShape;
    return data;
  }
}
