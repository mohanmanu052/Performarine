
class DeviceInfo {
  String? deviceId;
  String? model;
  String? version;
  String? make;
  String? board;
  String? deviceType;

  DeviceInfo(
      {this.deviceId,
        this.model,
        this.version,
        this.make,
        this.board,
        this.deviceType});

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    model = json['model'];
    version = json['version'];
    make = json['make'];
    board = json['board'];
    deviceType = json['deviceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceId'] = this.deviceId;
    data['model'] = this.model;
    data['version'] = this.version;
    data['make'] = this.make;
    data['board'] = this.board;
    data['deviceType'] = this.deviceType;
    return data;
  }
}