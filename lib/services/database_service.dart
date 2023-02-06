// import 'package:performarine/models/Trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/models/trip.dart';
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
    final path = join(databasePath, 'Performarine.db');

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
    //tripStatus 0=started and 1= ended
    await db.execute(
      'CREATE TABLE trips(id Text PRIMARY KEY,vesselId Text,vesselName Text, currentLoad TEXT,filePath Text,isSync INTEGER DEFAULT 0,'
      'tripStatus INTEGER  DEFAULT 0,deviceInfo Text, startPosition Text,endPosition Text,'
      ' createdAt TEXT,updatedAt TEXT,time TEXT,distance TEXT,speed TEXT,FOREIGN KEY (vesselId) REFERENCES vessels(id) ON DELETE SET NULL)',
    );
    // Run the CREATE {dogs} TABLE statement on the database.
    // await db.execute(
    //   'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER, color INTEGER, TripId INTEGER,isSync INTEGER DEFAULT 0, FOREIGN KEY (TripId) REFERENCES Trips(id) ON DELETE SET NULL)',
    // );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS vessels('
      'id Text PRIMARY KEY, '
      'name TEXT, '
      'model TEXT, '
      'builderName TEXT, '
      'regNumber TEXT'
      ', mMSI TEXT'
      ', engineType TEXT'
      ', fuelCapacity TEXT'
      ', batteryCapacity TEXT'
      ', weight TEXT'
      ', imageURLs TEXT'
      ', freeBoard DOUBLE,'
      ' lengthOverall DOUBLE,'
      ' beam DOUBLE, '
      'draft DOUBLE, '
      'vesselSize INTEGER, '
      'capacity INTEGER,'
      'builtYear TEXT ,'
      'vesselStatus INTEGER DEFAULT 1,'
      'isSync INTEGER DEFAULT 0,'
      'createdAt TEXT,'
      'createdBy TEXT,'
      'updatedAt TEXT, '
      'updatedBy TEXT, '
      'time TEXT, '
      'distance TEXT, '
      'speed TEXT '
      ')',
    );
    //  ToDo: Foreign Key mapping
    //  FOREIGN KEY (TripId) REFERENCES trips(id) ON DELETE SET NULL
  }

  // Define a function that inserts trips into the database
  Future<void> insertTrip(Trip trip) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Insert the Trip into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same Trip is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'trips',
      trip.toMap(),
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

  // A method that retrieves all the unSynced trips from the trips table
  Future<List<Trip>> trips() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the trips.
    final List<Map<String, dynamic>> maps =
        await db.query('trips'/*, where: 'isSync = ?',whereArgs: [0]*/,orderBy: "isSync");

    return List.generate(maps.length, (index) => Trip.fromMap(maps[index]));
  }

  /// Method to get AllTrips data By Vessel Id
  Future<List<Trip>> getAllTripsByVesselId(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('trips', where: 'vesselId = ?', whereArgs: [id],orderBy: 'isSync');
    return List.generate(maps.length, (index) => Trip.fromMap(maps[index]));
  }

  Future<List<CreateVessel>> getVesselNameByID(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('vessels', where: 'id = ?', whereArgs: [id]);
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  Future<Trip> getTrip(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('trips', where: 'id = ?', whereArgs: [id]);
    return Trip.fromMap(maps[0]);
  }

  Future<List<CreateVessel>> vessels() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('vessels', where: 'vesselStatus = ?', whereArgs: [1]);
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }


  Future<int> updateVessel(CreateVessel vessel) async {
    final db = await _databaseService.database;
    print("vessel.toMap():${vessel.toMap()}");
    int result = await db.update('vessels', vessel.toMap(),
        where: 'id = ?', whereArgs: [vessel.id]);
    print('UPDATE: $result');

    return result;
  }

  Future<void> updateTripStatus(int status, String filePath, String updatedAt,String endPosition,
      String time, String distance, String speed, String tripId) async {
    final db = await _databaseService.database;
    int count = await db.rawUpdate(
        'UPDATE trips SET tripStatus = ?, filePath = ?, updatedAt = ?,endPosition = ?, time = ?, distance = ?, speed = ? WHERE id = ?',
        [status, filePath, updatedAt,endPosition, time, distance, speed, tripId]);
    print('updated: $count');
  }

  Future<void> deleteVessel(String id) async {
    final db = await _databaseService.database;
    // await db.delete('vessels', where: 'id = ?', whereArgs: [id]);
    await db.rawUpdate(
        '''UPDATE vessels SET vesselStatus = ? WHERE id = ?''', [0, id]);
  }

  //update the vesselStatus in vessel table when its deleted
  Future<void> updateVesselStatus(int vesselStatus, String id) async {
    final db = await _databaseService.database;
    await db.rawUpdate('''UPDATE vessels SET vesselStatus = ? WHERE id = ?''',
        [vesselStatus, id]);
  }

  Future<void> deleteVesselImage(
    String id,
  ) async {
    final db = await _databaseService.database;
    int count = await db
        .rawUpdate('UPDATE vessels SET imageURLs = ? WHERE id = ?', ['', id]);
    print('updated: $count');
  }

  Future<void> deleteTripBasedOnVesselId(String vesselId) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Remove the Trip from the database.
    await db.delete(
      'trips',
      // Use a `where` clause to delete a specific trip.
      where: 'vesselId = ?',
      // Pass the Trip's id as a whereArg to prevent SQL injection.
      whereArgs: [vesselId],
    );
  } // vesselId

  Future<bool> tripIsRunning() async {
    final db = await _databaseService.database;
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM trips WHERE tripStatus="0")',
    );
    int? exists = Sqflite.firstIntValue(result);
    print('EXIST $exists');
    return exists == 1;
  }

  Future<List<CreateVessel>> retiredVessels() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('vessels', where: 'vesselStatus = ?', whereArgs: [0]);
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  Future<bool> getVesselIsSyncOrNot(String vesselId) async {
    final db = await _databaseService.database;
    /*var list = await db.query('vessels',
        where: 'id = ?, isSync = ?', whereArgs: [vesselId, isSync]); */
    var list = await db.rawQuery(
        'SELECT * FROM vessels WHERE id LIKE ? AND isSync LIKE ?',
        [vesselId, 0]);
    int? exists = Sqflite.firstIntValue(list);
    print('IS SYNC EXIST $exists');
    return exists == 1;
  }

  Future<CreateVessel> getVesselFromVesselID(String vesselId) async {
    final db = await _databaseService.database;
    var list =
        await db.query('vessels', where: 'id = ?', whereArgs: [vesselId]);
    return CreateVessel.fromMap(list[0]);
  }

  Future<void> updateIsSyncStatus(int isSyncValue, String id) async {
    final db = await _databaseService.database;
    await db.rawUpdate(
        '''UPDATE vessels SET isSync = ? WHERE id = ?''', [isSyncValue, id]);
  }

  Future<void> updateTripIsSyncStatus(int isSyncValue, String id) async {
    final db = await _databaseService.database;
    await db.rawUpdate(
        '''UPDATE trips SET isSync = ? WHERE id = ?''', [isSyncValue, id]);
  }

  Future<void> updateVesselName(String vesselName, String vesselId) async {
    final db = await _databaseService.database;
    await db.rawUpdate('''UPDATE trips SET vesselName = ? WHERE vesselId = ?''',
        [vesselName, vesselId]);
  }

  Future<void> updateVesselDataWithDurationSpeedDistance(
      String time, String distance, String speed, String vesselId) async {
    final db = await _databaseService.database;
    int count = await db.rawUpdate(
        'UPDATE vessels SET time = ?, distance = ?, speed = ? WHERE id = ?',
        [time, distance, speed, vesselId]);
    print('updated: $count');
  }
}
