import 'dart:convert';

class Breed {
  final int? id;
  final String vesselName;
  final String currentLoad;

  Breed({
    this.id,
    required this.vesselName,
    required this.currentLoad,
  });

  // Convert a Breed into a Map. The keys must correspond to the vesselNames of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vesselName': vesselName,
      'currentLoad': currentLoad,
    };
  }

  factory Breed.fromMap(Map<String, dynamic> map) {
    return Breed(
      id: map['id']?.toInt() ?? 0,
      vesselName: map['vesselName'] ?? '',
      currentLoad: map['currentLoad'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Breed.fromJson(String source) => Breed.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each breed when using the print statement.
  @override
  String toString() => 'Breed(id: $id, vesselName: $vesselName, currentLoad: $currentLoad)';
}
