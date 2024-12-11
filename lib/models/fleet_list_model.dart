
class FleetListModel {
  List<FleetData>? data;
  String? message;
  bool? status;
  int? statusCode;

  FleetListModel({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory FleetListModel.fromJson(Map<String, dynamic> json) => FleetListModel(
        data: json['data'] != null && json['data'] is List
            ? List<FleetData>.from(
                json['data'].map((data) => FleetData.fromJson(data)))
            : [],
        message: json['message'],
        status: json['status'],
        statusCode: json['statusCode'],
      );
}

class FleetData {
  dynamic updatedBy;
  String? fleetName;
  String? fleetOwnerId;
  int? status;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? fleetOwner;

  FleetData({
    this.updatedBy,
    this.fleetName,
    this.fleetOwnerId,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.fleetOwner
  });

  factory FleetData.fromJson(Map<String, dynamic> json) => FleetData(
        updatedBy: json['updatedBy'],
        fleetName: json['fleetName'],
        fleetOwnerId: json['fleetOwnerId'],
        status: json['status'],
        createdBy: json['createdBy'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        id: json['_id'],
        fleetOwner: json['fleetOwner']
      );
}