// To parse this JSON data, do
//
//     final forgotPasswordModel = forgotPasswordModelFromJson(jsonString);

import 'dart:convert';

ForgotPasswordModel forgotPasswordModelFromJson(String str) => ForgotPasswordModel.fromJson(json.decode(str));

String forgotPasswordModelToJson(ForgotPasswordModel data) => json.encode(data.toJson());

class ForgotPasswordModel {
  ForgotPasswordData? data;
  String? message;
  bool? status;
  int? statusCode;

  ForgotPasswordModel({
    this.data,
    this.message,
    this.status,
    this.statusCode,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) => ForgotPasswordModel(
    data: json["data"] != null ? ForgotPasswordData.fromJson(json["data"]) : ForgotPasswordData.fromJson({}),
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

class ForgotPasswordData {
  ForgotPasswordData();

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) => ForgotPasswordData(
  );

  Map<String, dynamic> toJson() => {
  };
}
