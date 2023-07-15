import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:sqflite/sqflite.dart';

import '../common_widgets/widgets/log_level.dart';

class DatabaseService {
  // Singleton pattern
  String page = "Data_base_service";
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

  /// Initialization of database
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
      ' createdAt TEXT,updatedAt TEXT,duration TEXT,distance TEXT,speed TEXT,avgSpeed TEXT,isCloud INTEGER  DEFAULT 0)',
    );
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
      'duration TEXT, '
      'distance TEXT, '
      'speed TEXT, '
      'avgSpeed TEXT, '
      'isCloud INTEGER  DEFAULT 0'
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

  /// To add vessel into database
  Future<void> insertVessel(CreateVessel vessel) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    Utils.customPrint("vessel.toMap():${vessel.toMap()}");
    loggD.d("vessel.toMap():${vessel.toMap()} -> $page ${DateTime.now()}");
    loggV.v("vessel.toMap():${vessel.toMap()} -> $page ${DateTime.now()}");
    await db.insert(
      'vessels',
      vessel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// To get vessel name by vessel id
  Future<List<CreateVessel>> getVesselNameByID(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('vessels', where: 'id = ?', whereArgs: [id]);
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  /// To get All Trip by id
  Future<Trip> getTrip(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('trips', where: 'id = ?', whereArgs: [id]);
    return Trip.fromMap(maps[0]);
  }

  /// To get all vessels based on status
  Future<List<CreateVessel>> vessels() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('vessels', where: 'vesselStatus = ?', whereArgs: [1]);
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  /// Update vessel details
  Future<int> updateVessel(CreateVessel vessel) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    Utils.customPrint("vessel.toMap():${vessel.toMap()}");
    loggD.d("vessel.toMap():${vessel.toMap()} -> $page ${DateTime.now()}");
    loggV.v("vessel.toMap():${vessel.toMap()} -> $page ${DateTime.now()}");
    int result = await db.update('vessels', vessel.toMap(),
        where: 'id = ?', whereArgs: [vessel.id]);
    Utils.customPrint('UPDATE: $result');
    loggD.d('UPDATE: $result -> $page ${DateTime.now()}');
    loggV.v('UPDATE: $result -> $page ${DateTime.now()}');

    return result;
  }

  /// Update trip status while end trip
  Future<void> updateTripStatus(
      int status,
      String filePath,
      String updatedAt,
      String endPosition,
      String time,
      String distance,
      String speed,
      String avgSpeed,
      String tripId) async {

    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    int count = await db.rawUpdate(
        'UPDATE trips SET tripStatus = ?, filePath = ?, updatedAt = ?,endPosition = ?, duration = ?, distance = ?, speed = ?, avgSpeed = ? WHERE id = ?',
        [
          status,
          filePath,
          updatedAt,
          endPosition,
          time,
          distance,
          speed,
          avgSpeed,
          tripId
        ]);
    Utils.customPrint('updated: $count');
    loggD.d('updated: $count -> $page ${DateTime.now()}');
    loggV.v('updated: $count -> $page ${DateTime.now()}');
  }

  /// It will change vessel to retired vessel
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

  /// To delete trip by vessel id
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

  /// To check trip is runnign or not
  Future<bool> tripIsRunning() async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM trips WHERE tripStatus="0")',
    );
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST $exists');
    loggD.d('EXIST $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To check trip is running for which vessel
  Future<bool> checkIfTripIsRunningForSpecificVessel(String vesselId) async {

    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM trips WHERE vesselId="$vesselId" AND tripStatus="0")',
    );
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST $exists');
    loggD.d('EXIST $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To get retird vessel list
  Future<List<CreateVessel>> retiredVessels() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('vessels', where: 'vesselStatus = ?', whereArgs: [0]);
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  /// To get vessel is sync or not
  Future<bool> getVesselIsSyncOrNot(String vesselId) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    /*var list = await db.query('vessels',
        where: 'id = ?, isSync = ?', whereArgs: [vesselId, isSync]); */
    var list = await db.rawQuery(
        'SELECT * FROM vessels WHERE id LIKE ? AND isSync LIKE ?',
        [vesselId, 0]);
    int? exists = Sqflite.firstIntValue(list);
    Utils.customPrint('IS SYNC EXIST $exists');
    loggD.d('IS SYNC EXIST $exists -> $page ${DateTime.now()}');
    loggV.v('IS SYNC EXIST $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// Get vessel details by vessel id
  Future<CreateVessel?> getVesselFromVesselID(String vesselId) async {
    final db = await _databaseService.database;
    var list =
        await db.query('vessels', where: 'id = ?', whereArgs: [vesselId]);

    if (list.length > 0) {
      return CreateVessel.fromMap(list[0]);
    } else {
      return null;
    }
  }

  /// Update sync status
  Future<int> updateIsSyncStatus(int isSyncValue, String id) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    int update = await db.rawUpdate(
        '''UPDATE vessels SET isSync = ? WHERE id = ?''', [isSyncValue, id]);
    Utils.customPrint('UPDATEDDDDD: $update');
    loggD.d('UPDATEDDDDD: $update -> $page ${DateTime.now()}');
    loggV.v('UPDATEDDDDD: $update -> $page ${DateTime.now()}');
    return update;
  }

  /// Update trip sync status
  Future<void> updateTripIsSyncStatus(int isSyncValue, String id) async {
    final db = await _databaseService.database;
    await db.rawUpdate(
        '''UPDATE trips SET isSync = ? WHERE id = ?''', [isSyncValue, id]);
    return;
  }

  /// Update vessel name
  Future<void> updateVesselName(String vesselName, String vesselId) async {
    final db = await _databaseService.database;
    await db.rawUpdate('''UPDATE trips SET vesselName = ? WHERE vesselId = ?''',
        [vesselName, vesselId]);
  }

  /// Update vessel details with analytics
  Future<void> updateVesselDataWithDurationSpeedDistance(String time,
      String distance, String speed, String avgSpeed, String vesselId) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    int count = await db.rawUpdate(
        'UPDATE vessels SET duration = ?, distance = ?, speed = ?, avgSpeed = ? WHERE id = ?',
        [time, distance, speed, avgSpeed, vesselId]);
    Utils.customPrint('updated: $count');
    loggD.d('updated: $count -> $page ${DateTime.now()}');
    loggV.v('updated: $count -> $page ${DateTime.now()}');
  }

  /// To get trip sync details
  Future<bool> tripSyncDetails() async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM trips WHERE isSync="0")',
    );
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST $exists');
    loggD.d('EXIST $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To get vessel sync details
  Future<bool> vesselsSyncDetails() async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM vessels WHERE isSync="0")',
    );
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST $exists');
    loggD.d('EXIST $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To delete vessel
  Future<bool> deleteDataFromVesselTable() async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    final db = await _databaseService.database;
    var result = await db.rawQuery('DELETE FROM vessels');
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST Vessels  $exists');
    loggD.d('EXIST Vessels  $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST Vessels  $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To delete trip
  Future<bool> deleteDataFromTripTable() async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    var result = await db.rawQuery('DELETE FROM trips');
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST TRIPS  $exists');
    loggD.d('EXIST TRIPS  $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST TRIPS  $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To check vessel is exist in cloud
  Future<bool> vesselsExistInCloud(String vesselId) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    final db = await _databaseService.database;
    var result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM vessels WHERE id="$vesselId")',
    );
    int? exists = Sqflite.firstIntValue(result);
    Utils.customPrint('EXIST $exists');
    loggD.d('EXIST $exists -> $page ${DateTime.now()}');
    loggV.v('EXIST $exists -> $page ${DateTime.now()}');
    return exists == 1;
  }

  /// To get vessel analytics data
  Future<List<String>> getVesselAnalytics(String vesselId) async {
    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps =
        await db.query('trips', where: 'vesselId = ?', whereArgs: [vesselId]);

    List<Trip> tripsList =
        List.generate(maps.length, (index) => Trip.fromMap(maps[index]));
    double totalAverageSpeed = 0.0;
    double totalDistanceSum = 0.0;
    int totalTripsCount = tripsList.length;
    int totalTripsDuration = 0;

    for (int i = 0; i < tripsList.length; i++) {
      double singleTripAvgSpeed = double.parse(
          tripsList[i].avgSpeed == null || tripsList[i].avgSpeed!.isEmpty
              ? '0.0'
              : tripsList[i].avgSpeed.toString());
      double singleTripDistance = double.parse(
          tripsList[i].distance == null || tripsList[i].distance!.isEmpty
              ? '0.0'
              : tripsList[i].distance.toString());

      String startTime = tripsList[i].createdAt.toString();
      String endTime = tripsList[i].updatedAt.toString();

      print('UTC START TIME: $startTime');
      print('UTC END TIME: $endTime');

      loggD.d('UTC START TIME: $startTime -> $page ${DateTime.now()}');
      loggD.d('UTC END TIME: $endTime -> $page ${DateTime.now()}');

      loggV.v('UTC START TIME: $startTime -> $page ${DateTime.now()}');
      loggV.v('UTC END TIME: $endTime -> $page ${DateTime.now()}');


      DateTime startDateTime = DateTime.parse(startTime);
      DateTime endDateTime = DateTime.parse(endTime);

      print('DATE TIME START: $startDateTime');
      print('DATE TIME END: $endDateTime');

      loggD.d('DATE TIME START: $startDateTime -> $page ${DateTime.now()}');
      loggD.d('DATE TIME END: $endDateTime -> $page ${DateTime.now()}');

      loggV.v('DATE TIME START: $startDateTime -> $page ${DateTime.now()}');
      loggV.v('DATE TIME END: $endDateTime -> $page ${DateTime.now()}');

      Duration diffDuration = endDateTime.difference(startDateTime);
      totalTripsDuration = totalTripsDuration + diffDuration.inSeconds;

      print('DIFFERENCE DURATION IN SECONDS: $totalTripsDuration');
      loggD.d('DIFFERENCE DURATION IN SECONDS: $totalTripsDuration -> $page ${DateTime.now()}');
      loggV.v('DIFFERENCE DURATION IN SECONDS: $totalTripsDuration -> $page ${DateTime.now()}');

      totalAverageSpeed = totalAverageSpeed + singleTripAvgSpeed;
      totalDistanceSum = totalDistanceSum + singleTripDistance;
    }

    double average = totalAverageSpeed / tripsList.length;
    return [
      totalDistanceSum.toStringAsFixed(2),
      average.toStringAsFixed(2),
      totalTripsCount.toString(),
      Utils.calculateTripDuration(totalTripsDuration)
    ]; // 1. TotalDistanceSum, 2. AvgSpeed, 3. TripsCount, 4. Total Duration
  }

  /// A method that will sync unsynced vessel and sing out
  Future<List<CreateVessel>> syncAndSignOutVesselList() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('vessels');
    return List.generate(
        maps.length, (index) => CreateVessel.fromMap(maps[index]));
  }

  /// A method that retrieves all the unSynced trips from the trips table
  Future<List<Trip>> trips() async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Query the table for all the trips.
    final List<Map<String, dynamic>> maps = await db.query(
        'trips' /*, where: 'isSync = ?',whereArgs: [0]*/,
        orderBy: "isSync");

    List<Trip> finalTripList = [];
    List<Trip> tempList =
        List.generate(maps.length, (index) => Trip.fromMap(maps[index]));

    if (tempList.isNotEmpty) {
      List<Trip> unSyncedList =
          tempList.where((element) => element.isSync == 0).toList();
      List<Trip> syncedList =
          tempList.where((element) => element.isSync == 1).toList();

      syncedList.sort(((b, a) {
        return DateTime.parse(a.updatedAt!)
            .compareTo(DateTime.parse(b.updatedAt!));
      }));

      finalTripList.addAll(unSyncedList);
      finalTripList.addAll(syncedList);
    }
    //return List.generate(maps.length, (index) => Trip.fromMap(maps[index]));

    return finalTripList;
  }

  /// Method to get AllTrips data By Vessel Id
  Future<List<Trip>> getAllTripsByVesselId(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'vesselId = ?',
      whereArgs: [id],
      orderBy: 'isSync',
    );

    List<Trip> finalTripList = [];
    List<Trip> tempList =
        List.generate(maps.length, (index) => Trip.fromMap(maps[index]));

    if (tempList.isNotEmpty) {
      List<Trip> unSyncedList =
          tempList.where((element) => element.isSync == 0).toList();
      List<Trip> syncedList =
          tempList.where((element) => element.isSync == 1).toList();

      syncedList.sort(((b, a) {
        return DateTime.parse(a.updatedAt!)
            .compareTo(DateTime.parse(b.updatedAt!));
      }));

      finalTripList.addAll(unSyncedList);
      finalTripList.addAll(syncedList);
    }

    //return List.generate(maps.length, (index) => Trip.fromMap(maps[index]));
    return finalTripList;
  }
}
