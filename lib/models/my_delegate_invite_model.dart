class MyDelegateInviteModel {
    List<MyDelegateInvite>? myDelegateInvities;
    String? message;
    bool? status;
    int? statusCode;

    MyDelegateInviteModel({
        this.myDelegateInvities,
        this.message,
        this.status,
        this.statusCode,
    });

    factory MyDelegateInviteModel.fromJson(Map<String, dynamic> json) => MyDelegateInviteModel(
        myDelegateInvities: json["my_delegate_invities"] == null ? [] : List<MyDelegateInvite>.from(json["my_delegate_invities"]!.map((x) => MyDelegateInvite.fromJson(x))),
        message: json["message"],
        status: json["status"],
        statusCode: json["statusCode"],
    );

    Map<String, dynamic> toJson() => {
        "my_delegate_invities": myDelegateInvities == null ? [] : List<dynamic>.from(myDelegateInvities!.map((x) => x.toJson())),
        "message": message,
        "status": status,
        "statusCode": statusCode,
    };
}

class MyDelegateInvite {
    String? id;
    String? vesselId;
    int? status;
    String? invitationLink;
    String? myDelegateInvityId;
    String? vesselName;
    String? invitedByUsername;

    MyDelegateInvite({
        this.id,
        this.vesselId,
        this.status,
        this.invitationLink,
        this.myDelegateInvityId,
        this.vesselName,
        this.invitedByUsername,
    });

    factory MyDelegateInvite.fromJson(Map<String, dynamic> json) => MyDelegateInvite(
        id: json["_id"],
        vesselId: json["vesselId"],
        status: json["status"],
        invitationLink: json["invitationLink"],
        myDelegateInvityId: json["id"],
        vesselName: json["vesselName"],
        invitedByUsername: json["invited_by_username"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "vesselId": vesselId,
        "status": status,
        "invitationLink": invitationLink,
        "id": myDelegateInvityId,
        "vesselName": vesselName,
        "invited_by_username": invitedByUsername,
    };
}