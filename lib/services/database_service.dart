import 'package:flutter_sqflite_example/models/breed.dart';
import 'package:flutter_sqflite_example/models/dog.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {

    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'flutter_sqflite_database.db');

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  // When the database is first created, create a table to store trips
  // and a table to store dogs.
  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {trips} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE trips(id Text PRIMARY KEY,vesselId Text, vesselName TEXT, currentLoad TEXT,isSync INTEGER DEFAULT 0,createdAt TEXT,updatedAt TEXT,FOREIGN KEY (vesselId) REFERENCES vessels(id) ON DELETE SET NULL)',
    );
    // Run the CREATE {dogs} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER, color INTEGER, breedId INTEGER,isSync INTEGER DEFAULT 0, FOREIGN KEY (breedId) REFERENCES breeds(id) ON DELETE SET NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS vessels(id Text PRIMARY KEY, vesselName TEXT, builder TEXT, model TEXT, registrationNumber TEXT'
          ', mmsi TEXT'
          ', engineType TEXT'
          ', fuelCapacity TEXT'
          ', batteryCapacity TEXT'
          ', weight TEXT'
          ', freeBoard DOUBLE, lengthOverall DOUBLE, beam DOUBLE, draft DOUBLE, size INTEGER, capacity INTEGER, builtYear TEXT ,isSync INTEGER DEFAULT 0,createdAt TEXT,updatedAt TEXT )',
    );
  //  ToDo: Foreign Key mapping
  //  FOREIGN KEY (breedId) REFERENCES trips(id) ON DELETE SET NULL


  }

  // Define a function that inserts trips into the database
  Future<void> insertBreed(Breed breed) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Insert the Breed into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same breed is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'trips',
      breed.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> insertTrip(Breed breed) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Insert the Breed into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same breed is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'trips',
      breed.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertDog(Dog dog) async {
    final db = await _databaseService.database;
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertVessel(CreateVessel vessel) async {
    final db = await _databaseService.database;
    print("vessel.toMap():${vessel.toMap()}");
    await db.insert(
      'vessels',
      vessel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the trips from the vessels table.
  Future<List<CreateVessel>> getAllVessels() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the vessels.
    final List<Map<String, dynamic>> maps = await db.query('vessels');
print("get vessels, :${maps.toString()}");
    // Convert the List<Map<String, dynamic> into a List<Breed>.
    return List.generate(maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }



  // A method that retrieves all the trips from the trips table.
  Future<List<Breed>> trips() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the trips.
    final List<Map<String, dynamic>> maps = await db.query('trips');

    // Convert the List<Map<String, dynamic> into a List<Breed>.
    return List.generate(maps.length, (index) => Breed.fromMap(maps[index]));
  }

  Future<Breed> breed(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('trips', where: 'id = ?', whereArgs: [id]);
    return Breed.fromMap(maps[0]);
  }

  Future<List<Dog>> dogs() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (index) => Dog.fromMap(maps[index]));
  }
  Future<List<CreateVessel>> vessels() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('vessels');
    return List.generate(maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  // A method that updates a breed data from the trips table.
  Future<void> updateBreed(Breed breed) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Update the given breed
    await db.update(
      'trips',
      breed.toMap(),
      // Ensure that the Breed has a matching id.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [breed.id],
    );
  }

  Future<void> updateDog(Dog dog) async {
    final db = await _databaseService.database;
    await db.update('dogs', dog.toMap(), where: 'id = ?', whereArgs: [dog.id]);
  }
  Future<void> updateVessel(CreateVessel vessel) async {
    final db = await _databaseService.database;
    print("vessel.toMap():${vessel.toMap()}");
    await db.update('vessels', vessel.toMap(), where: 'id = ?', whereArgs: [vessel.id]);
  }

  // A method that deletes a breed data from the trips table.
  Future<void> deleteBreed(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Remove the Breed from the database.
    await db.delete(
      'trips',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await _databaseService.database;
    await db.delete('dogs', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> deleteVessel(String id) async {
    final db = await _databaseService.database;
    await db.delete('vessels', where: 'id = ?', whereArgs: [id]);
  }
}
