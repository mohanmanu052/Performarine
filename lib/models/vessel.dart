import 'dart:convert';

import 'package:flutter/widgets.dart';

class Dog {
  final String? id;
  final String name;//vessel name
  final int age;
  final Color color;
  final int TripId;

  Dog({
    this.id,
    required this.name,
    required this.age,
    required this.color,
    required this.TripId,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'color': color.value,
      'TripId': TripId,
    };
  }

  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      age: map['age']?? 0,
      color: Color(map['color']),
      TripId: map['TripId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Dog.fromJson(String source) => Dog.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog(id: $id, name: $name, age: $age, TripId: $TripId)';
  }
}
//  'id Text PRIMARY KEY, '
//           'name TEXT, '
//           'model TEXT, '
//           'builderName TEXT, '
//           'regNumber TEXT'
//           ', mMSI TEXT'
//           ', engineType TEXT'
//           ', fuelCapacity TEXT'
//           ', batteryCapacity TEXT'
//           ', weight TEXT'
//           ', imageURLs TEXT'
//           ', freeBoard DOUBLE,'
//           ' lengthOverall DOUBLE,'
//           ' beam DOUBLE, '
//           'depth DOUBLE, '
//           'vesselSize INTEGER, '
//           'capacity INTEGER,'
//           'builtYear TEXT ,'
//           'vesselStatus INTEGER DEFAULT 1,'
//           'isSync INTEGER DEFAULT 0,'
//           'createdAt TEXT,'
//           'createdBy TEXT,'
//           'updatedAt TEXT, '
//           'updatedBy TEXT '


class CreateVessel {
  String? id;
  String? name;
  String? builderName;
  String? model;
  String? regNumber;
  String? mMSI;
  String? engineType;
  String? fuelCapacity;
  String? batteryCapacity;
  int? weight;
  String? imageURLs;
  double? freeBoard;
  double? lengthOverall;
  double? beam;
  double? draft;
  dynamic vesselSize;
  int? capacity;
  dynamic builtYear;
  int? isSync;
  int? vesselStatus;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;


  CreateVessel(
      {this.id,
        this.name,
        this.builderName,
        this.model,
        this.regNumber,
        this.mMSI,
        this.engineType,
        this.fuelCapacity,
        this.batteryCapacity,
        this.weight,
        this.freeBoard,
        this.lengthOverall,
        this.beam,
        this.draft,
        this.vesselSize,
        this.capacity,
        this.builtYear,
        this.isSync,
        this.vesselStatus,
        this.createdAt,
        this.createdBy,
        this.updatedAt,
        this.updatedBy,
        this.imageURLs
      });

  CreateVessel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    builderName = json['builderName'];
    model = json['Model'];
    regNumber = json['regNumber'];
    mMSI = json['mMSI'];
    engineType = json['engineType'];
    fuelCapacity = json['fuelCapacity'];
    batteryCapacity = json['batteryCapacity'];
    weight = json['weight'];
    freeBoard = json['freeBoard'];
    lengthOverall = json['lengthOverall'];
    beam = json['beam'];
    draft = json['draft'];
    vesselSize = json['vesselSize'];
    capacity = json['capacity'];
    builtYear = json['builtYear'];
    imageURLs=json["imageURLs"];
    isSync=json["isSync"];
    vesselStatus=json["vesselStatus"];
    createdBy=json["createdBy"];
    createdAt=json["createdAt"];
    updatedBy=json["updatedBy"];
    updatedAt=json["updatedAt"];

  }


  // Convert a CreateVessel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'builderName': builderName,
      'model': model,
      'regNumber': regNumber,
      'mMSI': mMSI,
      'engineType': engineType,
      'fuelCapacity': fuelCapacity,
      'batteryCapacity': batteryCapacity,
      'weight': weight,
      'freeBoard': freeBoard,
      'lengthOverall': lengthOverall,
      'beam': beam,
      'draft': draft,
      'vesselSize': vesselSize,
      'capacity': capacity,
      'builtYear': builtYear,
      'imageURLs':imageURLs,
      'isSync':isSync,
      'vesselStatus':vesselStatus,
      'createdBy':createdBy,
      'createdAt':createdAt,
      'updatedAt':updatedAt,
      'updatedBy':updatedBy,
    };
  }

  factory CreateVessel.fromMap(Map<String, dynamic> map) {
    return CreateVessel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      builderName : map['builderName'],
      model : map['model'],
      regNumber : map['regNumber'],
      mMSI : map['mMSI'],
      engineType : map['engineType'],
      fuelCapacity : map['fuelCapacity'],
      batteryCapacity : map['batteryCapacity'],
      weight : 0,
      freeBoard : map['freeBoard'],
      lengthOverall: map['lengthOverall'],
      beam : map['beam'],
      draft : map['draft'],
      vesselSize : map['vesselSize']??0.0,
      capacity : map['capacity'],
      builtYear : map['builtYear'],
      isSync: map['isSync'],
      vesselStatus: map['vesselStatus'],
      imageURLs: map['imageURLs'],
      createdAt: map['createdAt'],
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      updatedAt: map['updatedAt'],
    );
  }

  // String toJson() => json.encode(toMap());

  // factory CreateVessel.fromJson(String source) => CreateVessel().fromMap(json.decode(source));


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['builderName'] = this.builderName;
    data['model'] = this.model;
    data['regNumber'] = this.regNumber;
    data['mMSI'] = this.mMSI;
    data['engineType'] = this.engineType;
    data['fuelCapacity'] = this.fuelCapacity;
    data['batteryCapacity'] = this.batteryCapacity;
    data['weight'] = this.weight;
    data['freeBoard'] = this.freeBoard;
    data['lengthOverall'] = this.lengthOverall;
    data['beam'] = this.beam;
    data['draft'] = this.draft;
    data['vesselSize'] = this.vesselSize;
    data['capacity'] = this.capacity;
    data['isSync'] = this.isSync;
    data['vesselStatus'] = this.vesselStatus;
    data['imageURLs'] = this.imageURLs;
    data['createdAt'] = this.createdAt;
    data['createdBy'] = this.createdBy;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}