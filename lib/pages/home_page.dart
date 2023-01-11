import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart'
    as pos;
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/trip_builder.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
// import 'package:performarine/common_widgets/Trip_builder.dart';
import 'package:performarine/common_widgets/vessel_builder.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
// import 'package:performarine/models/Trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/tripStart.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  List<String> tripData;
  HomePage({Key? key, this.tripData = const []}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;
  List<Trip> trips = [];
  int tripsCount = 0;
  int currentTabIndex = 0;

  late Future<List<CreateVessel>> getVesselFuture;

  Future<List<CreateVessel>> _getVessels() async {
    return await _databaseService.vessels();
  }

  Future<List<Trip>> _getTrips() async {
    trips = await _databaseService.trips();
    return await _databaseService.trips();
  }

  _getTripsCount() async {
    trips = await _databaseService.trips();

    setState(() {
      tripsCount = trips.length;
    });
    // return tripsCount.toString();
  }

//ToDo: Vessel Name by Vessel Id
//   Future<String> _getVesselName() async {
//     List<CreateVessel> data= await _databaseService.getVesselNameByID("538b49e0-7ab5-11ed-8f52-89603b7614ba");
//     debugPrint("data:${data[0].name.toString()}");
//     return data[0].name.toString();
//   }

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  DeviceInfo? deviceDetails;

  List<String> tripData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();*/

    //checkNotificationPermission();

    commonProvider = context.read<CommonProvider>();
    commonProvider.init();
    _getTripsCount();

    getVesselFuture = _databaseService.getAllVesselsData();
    debugPrint("tripsCount:$getVesselFuture");
  }

  checkNotificationPermission() async {
    bool isNotificationPermitted = await Permission.notification.isGranted;

    if (!isNotificationPermitted) {
      await Utils.getNotificationPermission(context);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    tripData = widget.tripData;

    if (tripData.isNotEmpty) {
      String tripId = tripData[0];
      String vesselId = tripData[1];
      String vesselName = tripData[2];
      String vesselWeight = tripData[3];

      print('TRIP DATA: $tripId * $vesselId * $vesselName');

      Future.delayed(Duration(milliseconds: 300), () {
        Utils().showEndTripDialog(context, () async {
          FlutterBackgroundService service = FlutterBackgroundService();

          bool isServiceRunning = await service.isRunning();

          print('IS SERVICE RUNNING: $isServiceRunning');

          try {
            service.invoke('stopService');
            if (positionStream != null) {
              positionStream!.cancel();
            }
            // instan.stopSelf();
          } on Exception catch (e) {
            print('SERVICE STOP BG EXE: $e');
          }

          final appDirectory = await getApplicationDocumentsDirectory();
          ourDirectory = Directory('${appDirectory.path}');

          File? zipFile;
          if (timer != null) timer!.cancel();
          print('TIMER STOPPED ${ourDirectory!.path}/$tripId');
          final dataDir = Directory('${ourDirectory!.path}/$tripId');

          try {
            zipFile = File('${ourDirectory!.path}/$tripId.zip');

            ZipFile.createFromDirectory(
                sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
            print('our path is $dataDir');
          } catch (e) {
            print(e);
          }

          File file = File(zipFile!.path);
          print('FINAL PATH: ${file.path}');

          sharedPreferences!.remove('trip_data');
          sharedPreferences!.remove('trip_started');

          // service.invoke('stopService');
          widget.tripData = [];

          onSave(file, context, tripId, vesselId, vesselName, vesselWeight);
        }, () {
          widget.tripData = [];
          Navigator.of(context).pop();
        });
        // showAlertDialog(context, tripId, vesselId, vesselName, vesselWeight);
      });
    }
  }

  showAlertDialog(
      BuildContext context, String tripId, vesselId, vesselName, vesselWeight) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Trip"),
          content: Text("Do you want to end the trip?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("End"),
              onPressed: () async {
                // ServiceInstance instan = Get.find(tag: 'serviceInstance');
                FlutterBackgroundService service = FlutterBackgroundService();

                bool isServiceRunning = await service.isRunning();

                print('IS SERVICE RUNNING: $isServiceRunning');

                try {
                  service.invoke('stopService');
                  if (positionStream != null) {
                    positionStream!.cancel();
                  }

                  // instan.stopSelf();
                } on Exception catch (e) {
                  print('SERVICE STOP BG EXE: $e');
                }

                final appDirectory = await getApplicationDocumentsDirectory();
                ourDirectory = Directory('${appDirectory.path}');

                File? zipFile;
                if (timer != null) timer!.cancel();
                print('TIMER STOPPED ${ourDirectory!.path}/$tripId');
                final dataDir = Directory('${ourDirectory!.path}/$tripId');

                try {
                  zipFile = File('${ourDirectory!.path}/$tripId.zip');

                  ZipFile.createFromDirectory(
                      sourceDir: dataDir,
                      zipFile: zipFile,
                      recurseSubDirs: true);
                  print('our path is $dataDir');
                } catch (e) {
                  print(e);
                }

                File file = File(zipFile!.path);
                print('FINAL PATH: ${file.path}');

                sharedPreferences!.remove('trip_data');
                sharedPreferences!.remove('trip_started');

                // service.invoke('stopService');

                onSave(
                    file, context, tripId, vesselId, vesselName, vesselWeight);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> onSave(File file, BuildContext context, String tripId, vesselId,
      vesselName, vesselWeight) async {
    pos.Position? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);
    // await fetchDeviceInfo();
    await fetchDeviceData();

    debugPrint('hello device details: ${deviceDetails!.toJson().toString()}');
    // debugPrint(" locationData!.latitude!.toString():${ locationData!.latitude!.toString()}");
    // String latitude = locationData!.latitude!.toString();
    // String longitude = locationData.longitude!.toString();

    debugPrint("current lod:$vesselWeight");

    /*await _databaseService.insertTrip(Trip(
        id: tripId,
        vesselId: vesselId,
        vesselName: vesselName,
        currentLoad: vesselWeight,
        filePath: file.path,
        isSync: 0,
        tripStatus: 0,
        createdAt: DateTime.now().toUtc().toString(),
        updatedAt: DateTime.now().toUtc().toString(),
        lat: latitude,
        long: longitude,
        deviceInfo: deviceDetails!.toJson().toString()));*/

    await _databaseService.updateTripStatus(
        1, file.path, DateTime.now().toUtc().toString(), tripId);
    Navigator.pop(context);
  }

  fetchDeviceData() async {
    await fetchDeviceInfo();
    // Platform.isAndroid
    //     ? androidDeviceInfo = await fetchDeviceInfo()!.androidDeviceData
    //     : iosDeviceInfo = await fetchDeviceInfo()!.androidDeviceData;
    deviceDetails = Platform.isAndroid
        ? DeviceInfo(
            board: androidDeviceInfo?.board,
            deviceId: androidDeviceInfo?.id,
            deviceType: androidDeviceInfo?.type,
            make: androidDeviceInfo?.manufacturer,
            model: androidDeviceInfo?.model,
            version: androidDeviceInfo?.version.release)
        : DeviceInfo(
            board: iosDeviceInfo?.utsname.machine,
            deviceId: '',
            deviceType: iosDeviceInfo?.utsname.machine,
            make: iosDeviceInfo?.utsname.machine,
            model: iosDeviceInfo?.model,
            version: iosDeviceInfo?.utsname.release);
    debugPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
  }

  fetchDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(19),
              child: Image.asset(
                'assets/images/menu.png',
              ),
            ),
          ),
          title: Container(
            width: MediaQuery.of(context).size.width / 2,
            // color: Colors.yellow,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/lognotitle.png",
                        height: 50,
                        width: 50,
                      ),
                      commonText(
                        context: context,
                        text: 'PerforMarine',
                        fontWeight: FontWeight.w600,
                        textColor: Colors.black87,
                        textSize: displayWidth(context) * 0.045,
                      ),
                    ],
                  )),
                  // TextSpan(
                  //   text: " to add",
                  // ),
                ],
              ),
            ),
          ),
          bottom: TabBar(
            padding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.zero,
            isScrollable: true,
            indicatorColor: Colors.white,
            onTap: (int value) {
              setState(() {
                currentTabIndex = value;
              });
            },
            tabs: [
              Container(
                margin: EdgeInsets.only(right: 2),
                width: displayWidth(context) * 0.45,
                decoration: BoxDecoration(
                    color: currentTabIndex == 0 ? buttonBGColor : Colors.white,
                    border: Border.all(color: buttonBGColor),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
                  child: commonText(
                    context: context,
                    text: 'Vessels',
                    fontWeight: FontWeight.w500,
                    textColor:
                        currentTabIndex == 0 ? Colors.white : Colors.black,
                    textSize: displayWidth(context) * 0.036,
                  ),
                  // Text('Vessels'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2),
                width: displayWidth(context) * 0.45,
                decoration: BoxDecoration(
                    color: currentTabIndex == 1 ? buttonBGColor : Colors.white,
                    border: Border.all(color: buttonBGColor),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
                  child: commonText(
                    context: context,
                    text: 'Activity (${tripsCount.toString()})',
                    fontWeight: FontWeight.w500,
                    textColor:
                        currentTabIndex == 1 ? Colors.white : Colors.black,
                    textSize: displayWidth(context) * 0.036,
                  ),
                  // Text('Activity (${tripsCount.toString()})'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
        drawer: const CustomDrawer(),

        body: TabBarView(
          children: [
            VesselBuilder(
              future: getVesselFuture,
              onEdit: (value) async {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => VesselFormPage(vessel: value),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
              onTap: (value) async {
                {
                  var result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VesselSingleView(
                        vessel: value,
                      ),
                      fullscreenDialog: true,
                    ),
                  );

                  if (result != null) {
                    print('RESULT HOME PAGE $result');
                    if (result) {
                      /* Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                          ModalRoute.withName(""));*/
                      setState(() {
                        getVesselFuture = _databaseService.vessels();
                        _getTripsCount();
                        setState(() {});
                      });
                    }
                  }
                }
              },
              onDelete: _onVesselDelete,
            ),
            SingleChildScrollView(
              child: TripViewListing(),
              // TripBuilder(
              //   future: _gettrips(),
              // ),
            ),
          ],
        ),
        // floatingActionButton: SpeedDial(
        //   // marginBottom: 10, //margin bottom
        //   icon: Icons.menu, //icon on Floating action button
        //   activeIcon: Icons.close, //icon when menu is expanded on button
        //   backgroundColor:
        //       letsGetStartedButtonColor, //background color of button
        //   foregroundColor: Colors.white, //font color, icon color in button
        //   activeBackgroundColor:
        //       letsGetStartedButtonColor, //background color when menu is expanded
        //   activeForegroundColor: Colors.white,
        //   buttonSize: Size(55, 55),
        //   visible: true,
        //   closeManually: false,
        //   curve: Curves.bounceIn,
        //   overlayColor: Colors.black,
        //   overlayOpacity: 0.5,
        //   onOpen: () {}, // action when menu opens
        //   onClose: () {}, //action when menu closes
        //
        //   elevation: 8.0, //shadow elevation of button
        //   shape: CircleBorder(), //shape of button
        //
        //   children: [
        //     SpeedDialChild(
        //         backgroundColor: buttonBGColor,
        //         foregroundColor: Colors.white,
        //         label: 'Add Vessel',
        //         labelStyle: TextStyle(fontSize: 14.0),
        //         onTap: () {
        //           Navigator.of(context)
        //               .push(
        //                 MaterialPageRoute(
        //                   builder: (_) => PickImages(),
        //                   fullscreenDialog: true,
        //                 ),
        //               )
        //               .then((_) => setState(() {}));
        //         },
        //         // onLongPress: () {
        //         //   Navigator.of(context)
        //         //       .push(
        //         //         MaterialPageRoute(
        //         //           builder: (_) => VesselFormPage(),
        //         //           fullscreenDialog: true,
        //         //         ),
        //         //       )
        //         //       .then((_) => setState(() {}));
        //         // },
        //         child: Icon(Icons.add)),
        //     // ToDo: floating button elements
        //     // SpeedDialChild(
        //     //   child: FaIcon(FontAwesomeIcons.ship),
        //     //   backgroundColor: primaryColor,
        //     //   foregroundColor: Colors.white,
        //     //   label: 'Start Trip',
        //     //   labelStyle: TextStyle(fontSize: 14.0),
        //     //   onTap: () async{
        //     //     List<CreateVessel>?vessel=await _databaseService.getAllVessels();
        //     //     // print(vessel[0].vesselName);
        //     //     Navigator.of(context)
        //     //         .push(
        //     //       MaterialPageRoute(
        //     //         builder: (_) => StartTrip(vessels: vessel,context: context,),
        //     //         fullscreenDialog: true,
        //     //       ),
        //     //     );
        //     //   },
        //     //   onLongPress: () {
        //     //     Navigator.of(context)
        //     //         .push(
        //     //       MaterialPageRoute(
        //     //         builder: (_) => StartTrip(context: context,),
        //     //         fullscreenDialog: true,
        //     //       ),
        //     //     )
        //     //         .then((_) => setState(() {}));
        //     //   },
        //     // ),
        //
        //     // add more menu item children here
        //   ],
        // ),
      ),
    );
  }
}
