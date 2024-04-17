import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:logger/logger.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/jwt_utils.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';
import 'package:performarine/pages/delegate/delegates_screen.dart';
import 'package:performarine/pages/fleet/manage_permissions_screen.dart';
import 'package:performarine/pages/fleet/my_fleet_screen.dart';
import 'package:performarine/pages/new_splash_screen.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/pages/auth/reset_password.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:performarine/pages/start_trip/trip_recording_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uni_links/uni_links.dart';
import 'package:wakelock/wakelock.dart';
import 'package:workmanager/workmanager.dart';

import 'analytics/get_or_create_folder.dart';
import 'common_widgets/controller/location_controller.dart';
import 'common_widgets/widgets/log_level.dart';
import 'pages/new_intro_screen.dart';

SharedPreferences? sharedPreferences;
bool? isStart;
bool isAppKilledFromBGMain = true;
Timer? timer;
Timer? tripDurationTimer;
Directory? ourDirectory;
bool isComingFromUnilinkMain = false;

FlutterBluePlus? flutterBluePlus;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const logFileUpload = "logFileUpload";
String page = "main";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  flutterBluePlus = FlutterBluePlus();

  configEasyLoading();

  initializeService();

  tz.initializeTimeZones();

  await FlutterMapTileCaching.initialise();

  //Firebase.initializeApp
  await Firebase.initializeApp();

  try{
    FMTC.instance('mapStore').manage.createAsync();

  }catch(error){
    print('the FMTC Initialization error was ${error.toString()}');
  }

  bool wakelockEnabled = await Wakelock.enabled;

  if(wakelockEnabled){
    Utils.customPrint("wake lock enabled: $wakelockEnabled");
    Wakelock.disable();
  } else{
    Wakelock.disable();
  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  performarineLogFile();

  createFolder();

  SharedPreferences.getInstance().then((value) {
    sharedPreferences = value;
    //sharedPreferences!.setBool('is_initial_uri_handled', false);
    runApp(Phoenix(child: MyApp()));
  });
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case logFileUpload:
        final now = DateTime.now();
        if(now.hour == 0 && now.minute == 0){
          Utils.customPrint("Log file upload at 12 AM ${DateTime.now()}");
        }
        Utils.customPrint("statement for log file upload ${DateTime.now()}");
        break;
    }
    return Future.value(true);
  });

}
registerBackgroundTask() async{
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    "1",
    logFileUpload,
    frequency: Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}

Future<void> performarineLogFile() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  mainFile = File('${directory.path}/performarinelogs_$formattedDate.log');
 // Utils.customPrint("file path: $mainFile");
}

createFolder() async{

  File? file;
  final Directory documentDirectory = await getApplicationDocumentsDirectory();
  file = File('${documentDirectory.path}/LogFiles');
  final directory = Directory(file.path);

  final debugLogFile = mainFile;
  String debugLogFilePath = debugLogFile!.path;
  String debugFileName = debugLogFilePath.split('/').last;
  String debugPath = await getFile(debugFileName);

  Utils.customPrint("Debug file path is: ${debugPath}");
  bool fileExists = await isFileExistsInFolder(file.path, debugFileName);
  Utils.customPrint("fileExists status: $fileExists");
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    Utils.customPrint('Folder created successfully');
  }
  else{
    Utils.customPrint('Content not appended to file');
  }
  File fileee;
  try{
    fileee = File(debugLogFilePath);

    if(fileee != null && fileee.existsSync()){
      String data = await fileee.readAsString(encoding: Latin1Codec());

      Utils.customPrint("main data is: ${data.toString()}");
      File files = File(debugPath);
      files.writeAsString(data,mode: FileMode.append);
    }
  }catch(e){
    Utils.customPrint("error $e");
  }

  List<FileSystemEntity> filesList = directory.listSync();
  filesList.sort((a, b) => a.statSync().changed.compareTo(b.statSync().changed));

  Utils.customPrint("filesList is: ${filesList}");
  if (filesList.length > 7) {
    File fileToDelete = filesList.first as File;
    fileToDelete.deleteSync();
    Utils.customPrint('File deleted: ${fileToDelete.path}');
  } else {
    Utils.customPrint('Invalid file index');
  }
}

Future<bool> isFileExistsInFolder(String folderPath, String fileName) async {
  final folder = Directory(folderPath);
  if (await folder.exists()) {
    final file = File('${folder.path}/$fileName');
    return await file.exists();
  }
  return false;
}

Future<String> getFile(String fileName) async {
  String folderPath = await GetOrCreateFolder().getOrCreateFolder('LogFiles');

  File logFileData = File('$folderPath/$fileName');
  return logFileData.path;
}

configEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..indicatorSize = 20.0
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.black
    ..textColor = Colors.black
    ..maskColor = Colors.blue.withOpacity(1)
    ..radius = 12.0
    ..textStyle = TextStyle(fontWeight: FontWeight.bold);
}

const notificationChannelId = 'my_foreground';

@pragma('vm:entry-point')
onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  pref.setBool('sp_key_called_from_noti', true);
  Utils.customPrint('APP RESTART 24');
  CustomLogger().logWithFile(Level.info, "APP RESTART 2 -> $page");
  /// APP RESTART
}

@pragma('vm:entry-point')
void bgLocationCallBack() async {
  DartPluginRegistrant.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  pref.setBool('sp_key_called_from_noti', true);
  Utils.customPrint('APP RESTART 23');
  CustomLogger().logWithFile(Level.info, "bgLocationCallBack APP RESTART 23-> $page");
  /// APP RESTART
}

onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) {
  Utils.customPrint('APP RESTART 3');
  CustomLogger().logWithFile(Level.info, "APP RESTART 3");
  /// APP RESTART
}

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;
Future<void> initializeService() async {
  //final service = FlutterBackgroundService();
  isStart = false;

  final appDirectory = await getApplicationDocumentsDirectory();
  ourDirectory = Directory('${appDirectory.path}');

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low, // importance must be at low or higher level
  );

  /*await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(sound: true, alert: true, badge: true);*/

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('noti_logo');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          requestCriticalPermission: false,
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin);

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (value) async {
    Utils.customPrint('APP RESTART 1');
    CustomLogger().logWithFile(Level.info, "APP RESTART 1 -> $page");

    if (value.id == 776 || value.id == 1 || value.id == 889) {
      Utils.customPrint('NOTIFICATION ID: ${value.id}');
      CustomLogger().logWithFile(Level.info, "NOTIFICATION ID: ${value.id} -> $page ");
      var pref = await SharedPreferences.getInstance();
      pref.setBool('sp_key_called_from_noti', true);
      List<String>? tripData = pref.getStringList('trip_data');
      bool? isTripStarted = pref.getBool('trip_started');

        Utils.customPrint("IS APP KILLED MAIN $isAppKilledFromBGMain");
      CustomLogger().logWithFile(Level.info, "IS APP KILLED MAIN $isAppKilledFromBGMain -> $page ");

      if(isAppKilledFromBGMain)
        {
          /*Get.to(TripAnalyticsScreen(
              tripId: tripData![0],
              vesselId: tripData[1],
              isAppKilled: false,
              tripIsRunningOrNot: isTripStarted));*/

          /*Get.to(NewTripAnalyticsScreen(
              tripId: tripData![0],
              vesselId: tripData[1],
              isAppKilled: false,
              tripIsRunningOrNot: isTripStarted));*/

          Get.to(TripRecordingScreen(
              tripId: tripData![0],
              vesselName: tripData[2],
              vesselId: tripData[1],
              isAppKilled: false,
              calledFrom: 'notification',
              tripIsRunningOrNot: isTripStarted));
        }
      else
        {
          /*Get.to(TripAnalyticsScreen(
              tripId: tripData![0],
              vesselId: tripData[1],
              isAppKilled: true,
              tripIsRunningOrNot: isTripStarted));*/

          /*Get.to(NewTripAnalyticsScreen(
              tripId: tripData![0],
              vesselId: tripData[1],
              isAppKilled: true,
              tripIsRunningOrNot: isTripStarted));*/

          sharedPreferences!.setBool('key_lat_time_dialog_open', false);
          Get.to(TripRecordingScreen(
              tripId: tripData![0],
              vesselName: tripData[2],
              vesselId: tripData[1],
              calledFrom: 'notification',
              isAppKilled: true,
              tripIsRunningOrNot: isTripStarted));
        }
    }
    return;

    /// APP RESTART
  },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isLoading = false, isComingFromUnilink = false;
  StreamSubscription? _sub;

  Future<void> initDeepLinkListener() async {

    try {
      print('coming to init deeplink-------');
      _sub = uriLinkStream.listen((Uri? uri) async{

       setState(() {
         isComingFromUnilink = true;
       });

       Utils.customPrint("URI 2: ${uri}");
       CustomLogger().logWithFile(Level.info, "URI: ${uri} -> $page");
        if (uri != null) {
          Utils.customPrint('Deep link received 2: $uri');
          CustomLogger().logWithFile(Level.info, "Deep link received -> $page ");
          if(uri.path=='/reset'){
            Utils.customPrint("reset: ${uri.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info, "reset: ${uri.queryParameters['verify'].toString()} -> $page ");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(Level.info, "isUserLoggedIn: $isUserLoggedIn -> $page ");

            Map<String, dynamic> arguments = {
              "isComingFromReset": true,
              "token": uri.queryParameters['verify'].toString()
            };
            if(isUserLoggedIn != null)
              {
                if(isUserLoggedIn)
                  {
                    isComingFromUnilinkMain = true;
                    sharedPreferences!.setBool('reset_dialog_opened', false);
                    Get.to(BottomNavigation(isComingFromReset: true,token: uri.queryParameters['verify'].toString(),),arguments: arguments);
                    CustomLogger().logWithFile(Level.info, "User navigating to home page -> $page ");
                  }
              }
            else
              {
                isComingFromUnilinkMain = true;
                Get.to(ResetPassword(token: uri.queryParameters['verify'].toString(),isCalledFrom: "Main",));
                CustomLogger().logWithFile(Level.info, "User navigating to reset password screen -> $page ");
              }

          }

                    else if (uri.path=='/fleetmember') {
            Utils.customPrint(
                "fleetmember: ${uri.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "fleetmember: ${uri.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn-> $page");

            Map<String, dynamic> arguments = {
              "isComingFromReset": false,
              "token": uri.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {

                isComingFromUnilinkMain = true;
                bool isSameUser=await        JwtUtils.getDecodedData(uri.queryParameters['verify'].toString());
                String fleetId=JwtUtils.getFleetId(uri.queryParameters['verify'].toString());
                if(isSameUser){
                  // Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>ManagePermissionsScreen(isComingFromUnilink:true,fleetId: fleetId,url: uri,),),
                  //     ModalRoute.withName('/')
                  //
                  // );
                  Get.to(
                      ManagePermissionsScreen(isComingFromUnilink:true,fleetId: fleetId,url: uri,),
                      arguments: arguments,

                  );
                }else{
                  Map<String, dynamic> arguments = {
                    "isComingFromReset": false,
                    "token": uri.queryParameters['verify'].toString(),
                    'isLoggedinUser':false
                  };
                  Get.offAll(
                      BottomNavigation(
                          isComingFromReset: false,
                          isAppKilled: true),
                      arguments: arguments);
                }
              }
            } else {


              Future.delayed(Duration(seconds: 2), () {
                //isComingFromUnilinkMain = true;
                Get.offAll(
                    SignInScreen(),
                    );
              });
            }
          }

          else if(uri.path=='/delegateaccess'){
                        Utils.customPrint(
                "delegate: ${uri.queryParameters['verify'].toString()}");
            CustomLogger().logWithFile(Level.info,
                "delegate: ${uri.queryParameters['verify'].toString()} -> $page");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');

            Utils.customPrint("isUserLoggedIn: $isUserLoggedIn");
            CustomLogger().logWithFile(
                Level.info, "isUserLoggedIn: $isUserLoggedIn-> $page");

            Map<String, dynamic> arguments = {
              "isComingFromReset": false,
              "token": uri.queryParameters['verify'].toString()
            };
            if (isUserLoggedIn != null) {
              if (isUserLoggedIn) {

                isComingFromUnilinkMain = true;
                bool isSameUser=await        JwtUtils.getDecodedData(uri.queryParameters['verify'].toString());
                String vesselId=JwtUtils.getVesselId(uri.queryParameters['verify'].toString());
                String? ownerId=JwtUtils.getOwnerId(uri.queryParameters['verify'].toString());
                if(isSameUser){
                  Get.to(
                      DelegatesScreen(isComingFromUnilink:true, vesselID: vesselId, uri: uri,
                      ownerId: ownerId,
                      
                      ),
                      arguments: arguments,

                  );
                }else{
                  Map<String, dynamic> arguments = {
                    "isComingFromReset": false,
                    "token": uri.queryParameters['verify'].toString(),
                    'isLoggedinUser':false
                  };
                  Get.offAll(
                      BottomNavigation(
                          isComingFromReset: false,
                          isAppKilled: true),
                      arguments: arguments);
                }
              }
            } else {


              Future.delayed(Duration(seconds: 2), () {
                //isComingFromUnilinkMain = true;
                Get.offAll(
                    SignInScreen(),
                    );
              });
            }
          }


          

        }
      }, onError: (err) {
        Utils.customPrint('Error handling deep link: $err');

        CustomLogger().logWithFile(Level.error, "Error handling deep link: $err -> $page ");
      });
    } on PlatformException {
      Utils.customPrint("Exception while handling with uni links : ${PlatformException}");
      CustomLogger().logWithFile(Level.error, "Exception while handling with uni links : ${PlatformException} -> $page ");

    }
  }

  @override
  void initState(){
    super.initState();

    getBaseUrl();

    WidgetsBinding.instance.addObserver(this);
    initDeepLinkListener();
    Utils.customPrint('APP IN BG INIT');
    CustomLogger().logWithFile(Level.info, "APP IN BG INIT -> -> $page ");
    checkGPS();
    listenToBluetoothState();
  }

  listenToBluetoothState(){
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      Utils.customPrint('BLE STATE: $state');
      if (state == BluetoothAdapterState.turningOff) {
        showEnableBluetoothState();
      }
    });
  }

  showEnableBluetoothState(){
    Fluttertoast.showToast(
        msg: "Please enable bluetooth",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );

    Future.delayed(Duration(seconds: 2), ()async{
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth, asAnotherTask: true);

    });
  }

  checkIfBluetoothIsOnAfterRedirecting() async {
    var pref = await Utils.initSharedPreferences();
    bool? isTripStarted = pref.getBool('trip_started') ?? false;

    if(isTripStarted){
      bool isEnabled = await blueIsOn();
      if(!isEnabled){
        showEnableBluetoothState();
      }
    }
  }

  Future<bool> blueIsOn() async {
    // FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
    BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
    final isOn = adapterState == BluetoothAdapterState.on;
    // if (isOn) return true;
    //
    // await Future.delayed(const Duration(seconds: 1));
    // BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
    return isOn;
  }

  checkGPS()
  {
    StreamSubscription<ServiceStatus> serviceStatusStream = Geolocator.getServiceStatusStream().listen(
            (ServiceStatus status) {
          print(status);

          if(status == ServiceStatus.disabled){

            Fluttertoast.showToast(
                msg: "Please enable GPS",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0
            );

            Future.delayed(Duration(seconds: 1), ()async{
              AppSettings.openAppSettings(type: AppSettingsType.location, asAnotherTask: true);
            });
          }

        });
  }

  readData()async{
    final _storage = const FlutterSecureStorage();
    final all = await _storage.read(
      key: 'baseUrl'
    );

    Utils.customPrint('ERROR: $all');
    Map<String, dynamic> decodedData = jsonDecode(all!);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var appVersion = packageInfo.version;

    Utils.customPrint('VERSION 1 $appVersion');

    for(String version in decodedData.keys)
      {
        Utils.customPrint('VERSION of firebase $version');
        Utils.customPrint('VERSION of app $appVersion');
        if(version == appVersion)
          {
            Urls.baseUrlVersion = decodedData[version];

            Utils.customPrint('VERSION 3 $version');
            Utils.customPrint('VERSION MAIN ${decodedData[version]}');
          }
      }

  }

  getTripData()async
  {
    bool? isTripStarted =
    sharedPreferences!.getBool('trip_started');

  Utils.customPrint("TRIP IN PROGRESS MAIN $isTripStarted");
    CustomLogger().logWithFile(Level.info, "TRIP IN PROGRESS MAIN $isTripStarted -> $page");

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // positionStream!.cancle
    _sub?.cancel();
    super.dispose();
    Utils.customPrint('APP IN BG DISPOSE');
    CustomLogger().logWithFile(Level.info, "APP IN BG DISPOSE -> $page");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommonProvider()),
        ChangeNotifierProvider(create: (_) => LocationController()),
      ],
      child: GetMaterialApp(
        theme: ThemeData(useMaterial3: false),

        title: 'PerforMarine',
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        builder: EasyLoading.init(),
        // builder: EasyLoading.init(),
        getPages: [
          GetPage(name: '/', page: () => NewSplashScreen()),
          GetPage(name: '/BottomNavigation', page: () => BottomNavigation()),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        checkIfBluetoothIsOnAfterRedirecting();
        if(!(await Geolocator.isLocationServiceEnabled()))
        {
          checkGPS();
        }
        Utils.customPrint('\n\n**********resumed');
        // var pref = await SharedPreferences.getInstance();

        String? result = sharedPreferences!.getString('tripAvgSpeed');

    Utils.customPrint("RESUME MAIN $result");
        CustomLogger().logWithFile(Level.info, "RESUME MAIN $result -> $page");

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Future.delayed(Duration(seconds: 1), () async {
            sharedPreferences = await SharedPreferences.getInstance();
          });

          sharedPreferences!.reload().then((value) {
            bool? isTripStarted = sharedPreferences!.getBool('trip_started');
            bool? result = sharedPreferences!.getBool('sp_key_called_from_noti');

            if (isTripStarted != null) {
              if (isTripStarted) {

                if(isComingFromUnilink)
                  {

                  }
                else
                  {
                    if(result != null)
                      {
                        if(result)
                          {
                            EasyLoading.show(
                                status: 'Loading your current trip',
                                maskType: EasyLoadingMaskType.black);
                          }
                      }

                  }
              }
            }

            Future.delayed(Duration(seconds: 3), () async {
              bool? result =
                  sharedPreferences!.getBool('sp_key_called_from_noti');

              Utils.customPrint('********$result');

              if (result != null) {
                if (result) {
                  List<String>? tripData =
                      sharedPreferences!.getStringList('trip_data');
                  bool? isTripStarted =
                      sharedPreferences!.getBool('trip_started');

                  EasyLoading.dismiss();

                  Utils.customPrint("LIFE CYCLE KILLED $isAppKilledFromBGMain");
                  CustomLogger().logWithFile(Level.info, "LIFE CYCLE KILLED $isAppKilledFromBGMain -> $page");

                  if(isAppKilledFromBGMain)
                    {
                      /*Get.to(NewTripAnalyticsScreen(
                        tripId: tripData![0],
                        vesselId: tripData[1],
                        isAppKilled: false,
                        tripIsRunningOrNot: isTripStarted));*/

                      Get.to(TripRecordingScreen(
                          tripId: tripData![0],
                          vesselName: tripData[2],
                          vesselId: tripData[1],
                          isAppKilled: false,
                          calledFrom: 'notification',
                          tripIsRunningOrNot: isTripStarted));

                      CustomLogger().logWithFile(Level.info, "User navigating to trip analytics screen :: isAppKilledFromBGMain $isAppKilledFromBGMain -> $page");
                    }
                  else
                    {
                      /*Get.to(NewTripAnalyticsScreen(
                          tripId: tripData![0],
                          vesselId: tripData[1],
                          isAppKilled: true,
                          tripIsRunningOrNot: isTripStarted));*/

                      sharedPreferences!.setBool('key_lat_time_dialog_open', false);
                      Get.to(TripRecordingScreen(
                          tripId: tripData![0],
                          vesselName: tripData[2],
                          vesselId: tripData[1],
                          isAppKilled: true,
                          calledFrom: 'notification',
                          tripIsRunningOrNot: isTripStarted));

                      CustomLogger().logWithFile(Level.info, "User navigating to trip analytics screen :: isAppKilledFromBGMain $isAppKilledFromBGMain -> $page");
                    }

                } else {
                  EasyLoading.dismiss();
                }
              } else {
                // EasyLoading.dismiss();
                // sharedPreferences!.reload();
                // bool? result =
                //     sharedPreferences!.getBool('sp_key_called_from_noti');
                //
                // Utils.customPrint('********XXXXX$result');
              }
            });
          });
        });
        break;
      case AppLifecycleState.inactive:

    Utils.customPrint('\n\ninactive');
        CustomLogger().logWithFile(Level.info, "App is inActive -> $page");
        break;
      case AppLifecycleState.paused:
        Utils.customPrint('\n\npaused');
        CustomLogger().logWithFile(Level.info, "App is paused -> $page");
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences!.reload();
        break;
      case AppLifecycleState.detached:
        setState(() {
          isAppKilledFromBGMain = false;
        });

        String? result = sharedPreferences!.getString('tripAvgSpeed');

    Utils.customPrint("DETACH MAIN $result");
        CustomLogger().logWithFile(Level.info, "DETACH MAIN $result -> $page");

        Utils.customPrint('\n\ndetached');
        break;
    }
  }

  void getBaseUrl() async {
    FirebaseRemoteConfig data = await setupRemoteConfig();
    String vinValidation = data.getString('version');
    String hullTypes = data.getString('HullType');
    String lprConfigaration=data.getString('LprConfigaration');

    Utils.customPrint('VINNNNNNNNNNNNNNN ${hullTypes}');

    final FlutterSecureStorage storage = FlutterSecureStorage();

    await storage.write(key: 'baseUrl', value: vinValidation);
    await storage.write(key: 'hullTypes', value: hullTypes);
    await storage.write(key:'lprConfig' ,value: lprConfigaration);

    readData();

  }

  Future<FirebaseRemoteConfig> setupRemoteConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    RemoteConfigValue(null, ValueSource.valueStatic);
    return remoteConfig;
  }
}
