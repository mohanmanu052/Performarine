import 'dart:convert';

class AssignVesselModel {
    List<VesselData>? data;
    String? message;
    bool? status;
    int? statusCode;

    AssignVesselModel({
        this.data,
        this.message,
        this.status,
        this.statusCode,
    });

    factory AssignVesselModel.fromJson(Map<String, dynamic> json) => AssignVesselModel(
data: (json["data"] == null || (json["data"] is Map && json["data"].isEmpty))
    ? []
    : List<VesselData>.from(json["data"].map((x) => VesselData.fromJson(x))),
        message: json["message"],
        status: json["status"],
        statusCode: json["statusCode"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "status": status,
        "statusCode": statusCode,
    };
}

class VesselData {
    String? id;
    String? name;
    String? model;
    String? builderName;
    String? regNumber;
    String? mmsi;
    String? engineType;
    dynamic fuelCapacity;
    dynamic batteryCapacity;
    String? weight;
    List<String>? imageUrLs;
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
    DateTime? createdAt;
    String? updatedBy;
    DateTime? updatedAt;
    DateTime? syncCreatedAt;
    DateTime? syncUpdatedAt;

    VesselData({
        this.id,
        this.name,
        this.model,
        this.builderName,
        this.regNumber,
        this.mmsi,
        this.engineType,
        this.fuelCapacity,
        this.batteryCapacity,
        this.weight,
        this.imageUrLs,
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
        this.syncUpdatedAt,
    });

    factory VesselData.fromJson(Map<String, dynamic> json) => VesselData(
        id: json["_id"],
        name: json["name"],
        model: json["model"],
        builderName: json["builderName"],
        regNumber: json["regNumber"],
        mmsi: json["MMSI"],
        engineType: json["engineType"],
        fuelCapacity: json["fuelCapacity"],
        batteryCapacity: json["batteryCapacity"],
        weight: json["weight"],
        imageUrLs: json["imageURLs"] == null ? [] : List<String>.from(json["imageURLs"]!.map((x) => x)),
        freeBoard: json["freeBoard"],
        lengthOverall: json["lengthOverall"],
        beam: json["beam"],
        depth: json["depth"],
        vesselSize: json["vesselSize"],
        capacity: json["capacity"],
        hullShape: json["hullShape"],
        builtYear: json["builtYear"],
        vesselStatus: json["vesselStatus"],
        createdBy: json["createdBy"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedBy: json["updatedBy"],
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        syncCreatedAt: json["syncCreatedAt"] == null ? null : DateTime.parse(json["syncCreatedAt"]),
        syncUpdatedAt: json["syncUpdatedAt"] == null ? null : DateTime.parse(json["syncUpdatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "model": model,
        "builderName": builderName,
        "regNumber": regNumber,
        "MMSI": mmsi,
        "engineType": engineType,
        "fuelCapacity": fuelCapacity,
        "batteryCapacity": batteryCapacity,
        "weight": weight,
        "imageURLs": imageUrLs == null ? [] : List<dynamic>.from(imageUrLs!.map((x) => x)),
        "freeBoard": freeBoard,
        "lengthOverall": lengthOverall,
        "beam": beam,
        "depth": depth,
        "vesselSize": vesselSize,
        "capacity": capacity,
        "hullShape": hullShape,
        "builtYear": builtYear,
        "vesselStatus": vesselStatus,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedAt": updatedAt?.toIso8601String(),
        "syncCreatedAt": syncCreatedAt?.toIso8601String(),
        "syncUpdatedAt": syncUpdatedAt?.toIso8601String(),
    };
}