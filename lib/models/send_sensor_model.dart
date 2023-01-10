class SendSensorDataModel {
	Data? data;
	int? noOfFileRecords;
	int? noOfInsertedRecords;
	String? message;
	bool? status;
	int? statusCode;

	SendSensorDataModel({this.data, this.noOfFileRecords, this.noOfInsertedRecords, this.message, this.status, this.statusCode});

	SendSensorDataModel.fromJson(Map<String, dynamic> json) {
		data = json['data'] != null ? new Data.fromJson(json['data']) : null;
		noOfFileRecords = json['no of file records'];
		noOfInsertedRecords = json['no of inserted records'];
		message = json['message'];
		status = json['status'];
		statusCode = json['statusCode'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
		data['no of file records'] = this.noOfFileRecords;
		data['no of inserted records'] = this.noOfInsertedRecords;
		data['message'] = this.message;
		data['status'] = this.status;
		data['statusCode'] = this.statusCode;
		return data;
	}
}

class Data {


	Data({
    String? Empty
  });

	Data.fromJson(Map<String, dynamic> json) {
    
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		return data;
	}
}