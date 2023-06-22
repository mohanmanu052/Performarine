// To parse this JSON data, do
//
//     final changePasswordModel = changePasswordModelFromJson(jsonString);

import 'dart:convert';

ResetPasswordModel resetPasswordModelFromJson(String str) => ResetPasswordModel.fromJson(json.decode(str));

String resetPasswordModelToJson(ResetPasswordModel data) => json.encode(data.toJson());

class ResetPasswordModel {
  ResetPasswordData? data;
  String? message;
  bool? status;
  int? statusCode;

  ResetPasswordModel({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) => ResetPasswordModel(
    data: json["data"] != null ?  ResetPasswordData.fromJson(json["data"]) : ResetPasswordData.fromJson({}),
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

class ResetPasswordData {
  ResetPasswordData();

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) => ResetPasswordData(
  );

  Map<String, dynamic> toJson() => {
  };
}