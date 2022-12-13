class LoginModel {
  String? token;
  String? userId;
  bool? status;
  int? statusCode;
  String? message;
  String? userEmail;

  LoginModel(
      {this.token, this.userId, this.status, this.statusCode, this.userEmail});

  LoginModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userId = json['userId'];
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    userEmail = json['userEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['userId'] = this.userId;
    data['status'] = this.status;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    data['userEmail'] = this.userEmail;
    return data;
  }
}
