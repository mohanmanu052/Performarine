import 'dart:convert';

import 'package:flutter/widgets.dart';

class Dog {
  final int? id;
  final String name;//vessel name
  final int age;
  final Color color;
  final int breedId;

  Dog({
    this.id,
    required this.name,
    required this.age,
    required this.color,
    required this.breedId,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'color': color.value,
      'breedId': breedId,
    };
  }

  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      age: map['age']?? 0,
      color: Color(map['color']),
      breedId: map['breedId'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Dog.fromJson(String source) => Dog.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog(id: $id, name: $name, age: $age, breedId: $breedId)';
  }
}
class CreateVessel {
  String? id;
  String? vesselName;
  String? builder;
  String? model;
  String? registrationNumber;
  String? mmsi;
  String? engineType;
  String? fuelCapacity;
  String? batteryCapacity;
  int? weight;
  double? freeboard;
  double? lengthOverall;
  double? beam;
  double? draft;
  dynamic size;
  int? capacity;
  dynamic builtYear;

  CreateVessel(
      {this.id,
        this.vesselName,
        this.builder,
        this.model,
        this.registrationNumber,
        this.mmsi,
        this.engineType,
        this.fuelCapacity,
        this.batteryCapacity,
        this.weight,
        this.freeboard,
        this.lengthOverall,
        this.beam,
        this.draft,
        this.size,
        this.capacity,
        this.builtYear});

  CreateVessel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vesselName = json['vesselName'];
    builder = json['builder'];
    model = json['Model'];
    registrationNumber = json['registrationNumber'];
    mmsi = json['mmsi'];
    engineType = json['engineType'];
    fuelCapacity = json['fuelCapacity'];
    batteryCapacity = json['batteryCapacity'];
    weight = json['weight'];
    freeboard = json['freeboard'];
    lengthOverall = json['lengthOverall'];
    beam = json['beam'];
    draft = json['draft'];
    size = json['size'];
    capacity = json['capacity'];
    builtYear = json['builtYear'];
  }


  // Convert a CreateVessel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vesselName': vesselName,
      'builder': builder,
      'model': model,
      'registrationNumber': registrationNumber,
      'mmsi': mmsi,
      'engineType': engineType,
      'fuelCapacity': fuelCapacity,
      'batteryCapacity': batteryCapacity,
      'weight': weight,
      'freeboard': freeboard,
      'lengthOverall': lengthOverall,
      'beam': beam,
      'draft': draft,
      'size': size,
      'capacity': capacity,
      'builtYear': builtYear,

    };
  }

  factory CreateVessel.fromMap(Map<String, dynamic> map) {
    return CreateVessel(
      id: map['id'].toString(),
      vesselName: map['vesselName'] ?? '',
      builder : map['builder'],
      model : map['model'],
      registrationNumber : map['registrationNumber'],
      mmsi : map['mmsi'],
      engineType : map['engineType'],
      fuelCapacity : map['fuelCapacity'],
      batteryCapacity : map['batteryCapacity'],
      weight : 0,
      freeboard : map['freeBoard'],
      lengthOverall: map['lengthOverall'],
      beam : map['beam'],
      draft : map['draft'],
      size : map['size']??0.0,
      capacity : map['capacity'],
      builtYear : map['builtYear'],
    );
  }

  // String toJson() => json.encode(toMap());

  // factory CreateVessel.fromJson(String source) => CreateVessel().fromMap(json.decode(source));


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vesselName'] = this.vesselName;
    data['builder'] = this.builder;
    data['model'] = this.model;
    data['registrationNumber'] = this.registrationNumber;
    data['mmsi'] = this.mmsi;
    data['engineType'] = this.engineType;
    data['fuelCapacity'] = this.fuelCapacity;
    data['batteryCapacity'] = this.batteryCapacity;
    data['weight'] = this.weight;
    data['freeboard'] = this.freeboard;
    data['lengthOverall'] = this.lengthOverall;
    data['beam'] = this.beam;
    data['draft'] = this.draft;
    data['size'] = this.size;
    data['capacity'] = this.capacity;
    data['builtYear'] = this.builtYear;
    return data;
  }
}