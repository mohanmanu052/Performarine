/// data : "Trip ID Does not exist"
/// message : "Delete trip info"
/// status : true
/// statusCode : 200

class DeleteTripModel {
  DeleteTripModel({
      String? data, 
      String? message, 
      bool? status, 
      num? statusCode,}){
    _data = data;
    _message = message;
    _status = status;
    _statusCode = statusCode;
}

  DeleteTripModel.fromJson(dynamic json) {
    _data = json['data'];
    _message = json['message'];
    _status = json['status'];
    _statusCode = json['statusCode'];
  }
  String? _data;
  String? _message;
  bool? _status;
  num? _statusCode;
DeleteTripModel copyWith({  String? data,
  String? message,
  bool? status,
  num? statusCode,
}) => DeleteTripModel(  data: data ?? _data,
  message: message ?? _message,
  status: status ?? _status,
  statusCode: statusCode ?? _statusCode,
);
  String? get data => _data;
  String? get message => _message;
  bool? get status => _status;
  num? get statusCode => _statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = _data;
    map['message'] = _message;
    map['status'] = _status;
    map['statusCode'] = _statusCode;
    return map;
  }

}