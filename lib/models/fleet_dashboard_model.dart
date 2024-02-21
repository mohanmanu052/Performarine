class FleetDashboardModel {
  FleetDashboardModel({
      List<MyFleets>? myFleets, 
      List<FleetsIamIn>? fleetsIamIn, 
      List<FleetInvites>? fleetInvites, 
      String? message, 
      bool? status, 
      num? statusCode,}){
    _myFleets = myFleets;
    _fleetsIamIn = fleetsIamIn;
    _fleetInvites = fleetInvites;
    _message = message;
    _status = status;
    _statusCode = statusCode;
}

  FleetDashboardModel.fromJson(dynamic json) {
    if (json['my_fleets'] != null) {
      _myFleets = [];
      json['my_fleets'].forEach((v) {
        _myFleets?.add(MyFleets.fromJson(v));
      });
    }
    if (json['fleets_iam_in'] != null) {
      _fleetsIamIn = [];
      json['fleets_iam_in'].forEach((v) {
        _fleetsIamIn?.add(FleetsIamIn.fromJson(v));
      });
    }
    if (json['fleet_invites'] != null) {
      _fleetInvites = [];
      json['fleet_invites'].forEach((v) {
        _fleetInvites?.add(FleetInvites.fromJson(v));
      });
    }
    _message = json['message'];
    _status = json['status'];
    _statusCode = json['statusCode'];
  }
  List<MyFleets>? _myFleets;
  List<FleetsIamIn>? _fleetsIamIn;
  List<FleetInvites>? _fleetInvites;
  String? _message;
  bool? _status;
  num? _statusCode;
FleetDashboardModel copyWith({  List<MyFleets>? myFleets,
  List<FleetsIamIn>? fleetsIamIn,
  List<FleetInvites>? fleetInvites,
  String? message,
  bool? status,
  num? statusCode,
}) => FleetDashboardModel(  myFleets: myFleets ?? _myFleets,
  fleetsIamIn: fleetsIamIn ?? _fleetsIamIn,
  fleetInvites: fleetInvites ?? _fleetInvites,
  message: message ?? _message,
  status: status ?? _status,
  statusCode: statusCode ?? _statusCode,
);
  List<MyFleets>? get myFleets => _myFleets;
  List<FleetsIamIn>? get fleetsIamIn => _fleetsIamIn;
  List<FleetInvites>? get fleetInvites => _fleetInvites;
  String? get message => _message;
  bool? get status => _status;
  num? get statusCode => _statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_myFleets != null) {
      map['my_fleets'] = _myFleets?.map((v) => v.toJson()).toList();
    }
    if (_fleetsIamIn != null) {
      map['fleets_iam_in'] = _fleetsIamIn?.map((v) => v.toJson()).toList();
    }
    if (_fleetInvites != null) {
      map['fleet_invites'] = _fleetInvites?.map((v) => v.toJson()).toList();
    }
    map['message'] = _message;
    map['status'] = _status;
    map['statusCode'] = _statusCode;
    return map;
  }

}

class FleetInvites {
  FleetInvites({
      String? fleetId, 
      String? fleetMemberId, 
      String? fleetName, 
      String? invitationToken, 
      dynamic fleetCreatedBy,}){
    _fleetId = fleetId;
    _fleetMemberId = fleetMemberId;
    _fleetName = fleetName;
    _invitationToken = invitationToken;
    _fleetCreatedBy = fleetCreatedBy;
}

  FleetInvites.fromJson(dynamic json) {
    _fleetId = json['fleetId'];
    _fleetMemberId = json['fleetMemberId'];
    _fleetName = json['fleetName'];
    _invitationToken = json['invitationToken'];
    _fleetCreatedBy = json['fleetCreatedBy'];
  }
  String? _fleetId;
  String? _fleetMemberId;
  String? _fleetName;
  String? _invitationToken;
  dynamic _fleetCreatedBy;
FleetInvites copyWith({  String? fleetId,
  String? fleetMemberId,
  String? fleetName,
  String? invitationToken,
  dynamic fleetCreatedBy,
}) => FleetInvites(  fleetId: fleetId ?? _fleetId,
  fleetMemberId: fleetMemberId ?? _fleetMemberId,
  fleetName: fleetName ?? _fleetName,
  invitationToken: invitationToken ?? _invitationToken,
  fleetCreatedBy: fleetCreatedBy ?? _fleetCreatedBy,
);
  String? get fleetId => _fleetId;
  String? get fleetMemberId => _fleetMemberId;
  String? get fleetName => _fleetName;
  String? get invitationToken => _invitationToken;
  dynamic get fleetCreatedBy => _fleetCreatedBy;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['fleetId'] = _fleetId;
    map['fleetMemberId'] = _fleetMemberId;
    map['fleetName'] = _fleetName;
    map['invitationToken'] = _invitationToken;
    map['fleetCreatedBy'] = _fleetCreatedBy;
    return map;
  }

}

class FleetsIamIn {
  FleetsIamIn({
      String? fleetId, 
      String? fleetMemberId, 
      String? fleetName, 
      num? vesselCount, 
      String? fleetJoinedDate, 
      String? fleetCreatedBy,}){
    _fleetId = fleetId;
    _fleetMemberId = fleetMemberId;
    _fleetName = fleetName;
    _vesselCount = vesselCount;
    _fleetJoinedDate = fleetJoinedDate;
    _fleetCreatedBy = fleetCreatedBy;
}

  FleetsIamIn.fromJson(dynamic json) {
    _fleetId = json['fleetId'];
    _fleetMemberId = json['fleetMemberId'];
    _fleetName = json['fleetName'];
    _vesselCount = json['vesselCount'];
    _fleetJoinedDate = json['fleetJoinedDate'];
    _fleetCreatedBy = json['fleetCreatedBy'];
  }
  String? _fleetId;
  String? _fleetMemberId;
  String? _fleetName;
  num? _vesselCount;
  String? _fleetJoinedDate;
  String? _fleetCreatedBy;
FleetsIamIn copyWith({  String? fleetId,
  String? fleetMemberId,
  String? fleetName,
  num? vesselCount,
  String? fleetJoinedDate,
  String? fleetCreatedBy,
}) => FleetsIamIn(  fleetId: fleetId ?? _fleetId,
  fleetMemberId: fleetMemberId ?? _fleetMemberId,
  fleetName: fleetName ?? _fleetName,
  vesselCount: vesselCount ?? _vesselCount,
  fleetJoinedDate: fleetJoinedDate ?? _fleetJoinedDate,
  fleetCreatedBy: fleetCreatedBy ?? _fleetCreatedBy,
);
  String? get fleetId => _fleetId;
  String? get fleetMemberId => _fleetMemberId;
  String? get fleetName => _fleetName;
  num? get vesselCount => _vesselCount;
  String? get fleetJoinedDate => _fleetJoinedDate;
  String? get fleetCreatedBy => _fleetCreatedBy;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['fleetId'] = _fleetId;
    map['fleetMemberId'] = _fleetMemberId;
    map['fleetName'] = _fleetName;
    map['vesselCount'] = _vesselCount;
    map['fleetJoinedDate'] = _fleetJoinedDate;
    map['fleetCreatedBy'] = _fleetCreatedBy;
    return map;
  }

}

class MyFleets {
  MyFleets({
      String? id, 
      String? fleetName, 
      num? vesselCount, 
      num? totalMemberCount, 
      num? acceptedCount, 
      num? pendingCount,}){
    _id = id;
    _fleetName = fleetName;
    _vesselCount = vesselCount;
    _totalMemberCount = totalMemberCount;
    _acceptedCount = acceptedCount;
    _pendingCount = pendingCount;
}

  MyFleets.fromJson(dynamic json) {
    _id = json['_id'];
    _fleetName = json['fleetName'];
    _vesselCount = json['vessel_count'];
    _totalMemberCount = json['total_member_count'];
    _acceptedCount = json['accepted_count'];
    _pendingCount = json['pending_count'];
  }
  String? _id;
  String? _fleetName;
  num? _vesselCount;
  num? _totalMemberCount;
  num? _acceptedCount;
  num? _pendingCount;
MyFleets copyWith({  String? id,
  String? fleetName,
  num? vesselCount,
  num? totalMemberCount,
  num? acceptedCount,
  num? pendingCount,
}) => MyFleets(  id: id ?? _id,
  fleetName: fleetName ?? _fleetName,
  vesselCount: vesselCount ?? _vesselCount,
  totalMemberCount: totalMemberCount ?? _totalMemberCount,
  acceptedCount: acceptedCount ?? _acceptedCount,
  pendingCount: pendingCount ?? _pendingCount,
);
  String? get id => _id;
  String? get fleetName => _fleetName;
  num? get vesselCount => _vesselCount;
  num? get totalMemberCount => _totalMemberCount;
  num? get acceptedCount => _acceptedCount;
  num? get pendingCount => _pendingCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['fleetName'] = _fleetName;
    map['vessel_count'] = _vesselCount;
    map['total_member_count'] = _totalMemberCount;
    map['accepted_count'] = _acceptedCount;
    map['pending_count'] = _pendingCount;
    return map;
  }

}