class SpeedReportsModel {
  SpeedReportsModel({
      this.data, 
      this.status, 
      this.message, 
      this.statusCode,});

  SpeedReportsModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
  }
  List<Data>? data;
  bool? status;
  String? message;
  num? statusCode;
SpeedReportsModel copyWith({  List<Data>? data,
  bool? status,
  String? message,
  num? statusCode,
}) => SpeedReportsModel(  data: data ?? this.data,
  status: status ?? this.status,
  message: message ?? this.message,
  statusCode: statusCode ?? this.statusCode,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['status'] = status;
    map['message'] = message;
    map['statusCode'] = statusCode;
    return map;
  }

}

class Data {
  Data({
      this.tripId, 
      this.createdAt, 
      this.totalDuration, 
      this.speedDuration,});

  Data.fromJson(dynamic json) {
    tripId = json['tripId'];
    createdAt = json['createdAt'];
    totalDuration = json['totalDuration'];
    speedDuration = json['speedDuration'];
  }
  String? tripId;
  String? createdAt;
  double? totalDuration;
  num? speedDuration;
Data copyWith({  String? tripId,
  String? createdAt,
  double? totalDuration,
  num? speedDuration,
}) => Data(  tripId: tripId ?? this.tripId,
  createdAt: createdAt ?? this.createdAt,
  totalDuration: totalDuration ?? this.totalDuration,
  speedDuration: speedDuration ?? this.speedDuration,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tripId'] = tripId;
    map['createdAt'] = createdAt;
    map['totalDuration'] = totalDuration;
    map['speedDuration'] = speedDuration;
    return map;
  }

}