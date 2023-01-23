class AddVesselModel {
  AddVesselData? addVesselData;
  String? message;
  bool? status;
  int? statusCode;

  AddVesselModel(
      {this.addVesselData, this.message, this.status, this.statusCode});

  AddVesselModel.fromJson(Map<String, dynamic> json) {
    addVesselData =
        json['data'] != null ? new AddVesselData.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'] ?? false;
    statusCode = json['statusCode'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.addVesselData != null) {
      data['data'] = this.addVesselData!.toJson();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class AddVesselData {
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
  dynamic? builtYear;
  dynamic vesselStatus;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? id;

  AddVesselData(
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
      this.id});

  AddVesselData.fromJson(Map<String, dynamic> json) {
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
    createdAt = json['CreatedAt'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    id = json['id'];
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
    data['CreatedAt'] = this.createdAt;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    data['id'] = this.id;
    return data;
  }
}
