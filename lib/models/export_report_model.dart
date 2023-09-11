import 'dart:convert';

ExportDataModel exportDataModelFromJson(String str) => ExportDataModel.fromJson(json.decode(str));

String exportDataModelToJson(ExportDataModel data) => json.encode(data.toJson());

class ExportDataModel {
    Data? data;
    String? message;
    bool? status;
    int? statusCode;

    ExportDataModel({
        this.data,
        this.message,
        this.status,
        this.statusCode,
    });

    factory ExportDataModel.fromJson(Map<String, dynamic> json) => ExportDataModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
        status: json["status"],
        statusCode: json["statusCode"],
    );

    Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "message": message,
        "status": status,
        "statusCode": statusCode,
    };
}

class Data {
    String? exportUrl;

    Data({
        this.exportUrl,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        exportUrl: json["exportURL"],
    );

    Map<String, dynamic> toJson() => {
        "exportURL": exportUrl,
    };
}
