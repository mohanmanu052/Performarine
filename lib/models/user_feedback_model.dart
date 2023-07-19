import 'dart:convert';

UserFeedbackModel userFeedbackModelFromJson(String str) => UserFeedbackModel.fromJson(json.decode(str));

String userFeedbackModelToJson(UserFeedbackModel data) => json.encode(data.toJson());

class UserFeedbackModel {
  String? message;
  bool? status;
  int? statusCode;

  UserFeedbackModel({
    this.message,
    this.status,
    this.statusCode,
  });

  factory UserFeedbackModel.fromJson(Map<String, dynamic> json) => UserFeedbackModel(
    message: json["message"],
    status: json["status"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "statusCode": statusCode,
  };
}
