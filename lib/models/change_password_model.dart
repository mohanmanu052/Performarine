// To parse this JSON data, do
//
//     final changePasswordModel = changePasswordModelFromJson(jsonString);

import 'dart:convert';

ChangePasswordModel changePasswordModelFromJson(String str) => ChangePasswordModel.fromJson(json.decode(str));

String changePasswordModelToJson(ChangePasswordModel data) => json.encode(data.toJson());

class ChangePasswordModel {
  ChnagePasswordData? data;
  String? message;
  bool? status;
  int? statusCode;

  ChangePasswordModel({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) => ChangePasswordModel(
    data: ChnagePasswordData.fromJson(json["data"]),
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

class ChnagePasswordData {
  ChnagePasswordData();

  factory ChnagePasswordData.fromJson(Map<String, dynamic> json) => ChnagePasswordData(
  );

  Map<String, dynamic> toJson() => {
  };
}
