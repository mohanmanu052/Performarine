import 'dart:convert';

class CreateFleetResponse {
  List<CreateFleetData>? data;
  String? message;
  bool? status;
  int? statusCode;

  CreateFleetResponse({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory CreateFleetResponse.fromJson(Map<String, dynamic> json) => CreateFleetResponse(
        data: json["data"] != null && json["data"] is List
            ? List<CreateFleetData>.from(json["data"].map((x) => CreateFleetData.fromJson(x)))
            : [],
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

class CreateFleetData {
  dynamic updatedBy;
  String? fleetName;
  String? fleetOwnerId;
  int? status;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  CreateFleetData({
    this.updatedBy,
    this.fleetName,
    this.fleetOwnerId,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  factory CreateFleetData.fromJson(Map<String, dynamic> json) => CreateFleetData(
        updatedBy: json["updatedBy"] == null ? null : json["updatedBy"],
        fleetName: json["fleetName"],
        fleetOwnerId: json["fleetOwnerId"],
        status: json["status"],
        createdBy: json["createdBy"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "updatedBy": updatedBy,
        "fleetName": fleetName,
        "fleetOwnerId": fleetOwnerId,
        "status": status,
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

