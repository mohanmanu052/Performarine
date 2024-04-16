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
    String? vesselId;
    int? status;
    int? delegateAccessType;
    String? invitationLink;
    String? vesselName;
    String? invitedBy;
    String? userDelegateAccessId;

    MyDelegateInvite({
        this.vesselId,
        this.status,
        this.invitationLink,
        this.vesselName,
        this.userDelegateAccessId,
        this.delegateAccessType,
        this.invitedBy
    });

    factory MyDelegateInvite.fromJson(Map<String, dynamic> json) => MyDelegateInvite(
        vesselId: json["vesselId"],
        status: json["status"],
        invitationLink: json["invitationLink"],
        userDelegateAccessId: json["userDelegateAccessId"],
        vesselName: json["vesselName"],
        delegateAccessType:json["delegateAccessType"],
        invitedBy: json["invitedBy"],
    );

    Map<String, dynamic> toJson() => {
        "vesselId": vesselId,
        "status": status,
        "invitationLink": invitationLink,
        "vesselName": vesselName,
        "invitedBy": invitedBy,
        "delegateAccessType":delegateAccessType,
        "userDelegateAccessId":userDelegateAccessId
    };
}