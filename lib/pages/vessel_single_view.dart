import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart' as bglas;
import 'package:background_locator_2/settings/locator_settings.dart' as bgls;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:geolocator/geolocator.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/analytics/file_manager.dart';
import 'package:performarine/analytics/location_callback_handler.dart';
import 'package:performarine/analytics/start_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/expansionCard.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/lpr_bluetooth_list.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../lpr_bluetooth_widget.dart';

class VesselSingleView extends StatefulWidget {
  CreateVessel? vessel;
  final bool? isCalledFromSuccessScreen;

  VesselSingleView({this.vessel, this.isCalledFromSuccessScreen = false});
  @override
  State createState() {
    return VesselSingleViewState();
  }
}

class VesselSingleViewState extends State<VesselSingleView> {
  List<CreateVessel>? vessel = [];
  final DatabaseService _databaseService = DatabaseService();
  GlobalKey<ScaffoldState> _modelScaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  Position? startTripPosition;
  DateTime startDateTime = DateTime.now();
  SharedPreferences? pref;

  bool isStartButton = false,
      isEndTripButton = false,
      isZipFileCreate = false,
      isSensorDataUploaded = false,
      addingDataToDB = false,
      isLocationDialogBoxOpen = false,
      tripIsEnded = false;

  Timer? locationTimer;
  String fileName = '';
  int fileIndex = 1;
  String? latitude, longitude;
  String getTripId = '';
  var uuid = Uuid();

  double progress = 0.9;
  double deviceProgress = 1.0;
  double sensorProgress = 1.0;
  double accSensorProgress = 1.0;
  double lprSensorProgress = 1.0;
  double uaccSensorProgress = 1.0;
  double gyroSensorProgress = 1.0;
  double magnSensorProgress = 1.0;

  double progressBegin = 0.0;
  double deviceProgressBegin = 0.0;
  double sensorProgressBegin = 0.0;
  double accSensorProgressBegin = 0.0;
  double uaccSensorProgressBegin = 0.0;
  double gyroSensorProgressBegin = 0.0;
  double magnSensorProgressBegin = 0.0;
  double lprSensorProgressBegin = 0.0;

  String selectedVesselWeight = 'Select Current Load', bluetoothName = '';

  bool isServiceRunning = false;
  FlutterBackgroundService service = FlutterBackgroundService();

  Future<List<Trip>> getTripListByVesselId(String id) async {
    return await _databaseService.getAllTripsByVesselId(id);
  }

  Position? location;

  List<String> sensorDataTable = ['ACC', 'UACC', 'GYRO', 'MAGN'];
  bool isBluetoothDialog = false;
  bool isBluetoothConnected = false;
  bool isRefreshList = false, isScanningBluetooth = false;

  getIfServiceIsRunning() async {
    bool data = await service.isRunning();
    Utils.customPrint('IS SERVICE RUNNING: $data');
    setState(() {
      isServiceRunning = data;
    });
  }

  DeviceInfo? deviceDetails;

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

  fetchDeviceData() async {
    await fetchDeviceInfo();

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
    Utils.customPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
  }

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  Future<void> _onDeleteTripsByVesselID(String vesselId) async {
    await _databaseService.deleteTripBasedOnVesselId(vesselId);
    setState(() {});
  }

  bool isBottomSheetOpened = false,
      isDataUpdated = false,
      tripIsRunning = false,
      isCheckingPermission = false,
      isTripEndedOrNot = false,
      vesselAnalytics = false,
      isVesselParticularExpanded = false;

  late CommonProvider commonProvider;

  bool? gyroscopeAvailable,
      accelerometerAvailable,
      magnetometerAvailable,
      userAccelerometerAvailable;

  String totalDistance = '0',
      avgSpeed = '0',
      tripsCount = '0',
      totalDuration = "00:00:00";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tripIsRunningOrNot();

    commonProvider = context.read<CommonProvider>();

    Utils.customPrint('VESSEL Image ${isTripEndedOrNot}');

    checkSensorAvailabelOrNot();

    getVesselAnalytics(widget.vessel!.id!);
  }

  getRunningTripDetails() async {
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');
    Trip tripDetails = await _databaseService.getTrip(tripData![0]);
    if (tripIsRunning)
      Utils.customPrint('VESSEL SINGLE VIEW TRIP ID ${tripDetails.id}');

    if (tripIsRunning) {
      if (tripDetails.vesselId != widget.vessel!.id) {
        setState(() {
          tripIsRunning = false;
        });
      }
    }
  }

  checkSensorAvailabelOrNot() async {
    gyroscopeAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    accelerometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    magnetometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);
  }

  Future<bool> tripIsRunningOrNot() async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      Utils.customPrint('Trip is Running $tripIsRunning');

      if (tripIsRunning) {
        getRunningTripDetails();
      }

      if (!tripIsRunning) {
        setState(() {
          isTripEndedOrNot = false;
        });
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: () async {
        if (widget.isCalledFromSuccessScreen! || tripIsEnded) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              ModalRoute.withName(""));

          return false;
        } else {
          Navigator.of(context).pop(true);
          return false;
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xfff2fffb),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Color(0xfff2fffb),
          centerTitle: true,
          title: Text(
            "${widget.vessel!.name}",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            onPressed: () async {
              await tripIsRunningOrNot();

              if (widget.isCalledFromSuccessScreen! || tripIsEnded) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                    ModalRoute.withName(""));
              } else {
                Navigator.of(context).pop(true);
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/images/home.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              SizedBox(
                height: displayHeight(context),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // your widgets,
                      // Container(height: 900,color: Colors.red,),
                      ExpansionCard(
                          scaffoldKey,
                          widget.vessel,
                          (value) async {
                            var result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddNewVesselScreen(
                                  isEdit: true,
                                  createVessel: widget.vessel,
                                ),
                                fullscreenDialog: true,
                              ),
                            );

                            if (result != null) {
                              Utils.customPrint('RESULT 1 ${result[0]}');
                              Utils.customPrint(
                                  'RESULT 1 ${result[1] as CreateVessel}');
                              setState(() {
                                widget.vessel = result[1] as CreateVessel?;
                                isDataUpdated = result[0];
                              });
                            }
                          },
                          (value) {},
                          (value) {
                            _onDeleteTripsByVesselID(value.id!);
                            _onVesselDelete(value);
                          },
                          false),
                      SizedBox(
                        height: 10,
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.black,
                            ),
                            dividerColor: Colors.transparent),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            onExpansionChanged: ((newState) {
                              setState(() {
                                isVesselParticularExpanded = newState;
                              });

                              Utils.customPrint(
                                  'EXPANSION CHANGE $isVesselParticularExpanded');
                            }),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            title: commonText(
                                context: context,
                                text: 'VESSEL ANALYTICS',
                                fontWeight: FontWeight.w600,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.038,
                                textAlign: TextAlign.start),
                            children: [
                              vesselAnalytics
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    )
                                  : vesselSingleViewVesselAnalytics(
                                      context,
                                      totalDuration,
                                      totalDistance,
                                      tripsCount,
                                      avgSpeed),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      Theme(
                        data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.black,
                            ),
                            dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          onExpansionChanged: ((newState) {
                            Utils.customPrint('CURRENT STAT $newState');
                          }),
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          title: commonText(
                              context: context,
                              text: 'Trip History',
                              fontWeight: FontWeight.w600,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.038,
                              textAlign: TextAlign.start),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: TripViewListing(
                                scaffoldKey: scaffoldKey,
                                vesselId: widget.vessel!.id,
                                calledFrom: 'VesselSingleView',
                                onTripEnded: () async {
                                  Utils.customPrint('SINGLE VIEW TRIP END');
                                  await tripIsRunningOrNot();
                                  setState(() {
                                    tripIsEnded = true;
                                  });
                                  getVesselAnalytics(widget.vessel!.id!);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
                  child: tripIsRunning
                      ? isTripEndedOrNot
                          ? Center(
                              child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  circularProgressColor),
                            ))
                          : CommonButtons.getActionButton(
                              title: 'End Trip',
                              context: context,
                              fontSize: displayWidth(context) * 0.042,
                              textColor: Colors.white,
                              buttonPrimaryColor: buttonBGColor,
                              borderColor: buttonBGColor,
                              width: displayWidth(context),
                              onTap: () async {
                                Utils.customPrint('time stamp:' +
                                    DateTime.now().toUtc().toString());
                                Utils().showEndTripDialog(context, () async {
                                  setState(() {
                                    isTripEndedOrNot = true;
                                  });

                                  List<String>? tripData = sharedPreferences!
                                      .getStringList('trip_data');

                                  String tripId = '';
                                  if (tripData != null) {
                                    tripId = tripData[0];
                                  }

                                  final currentTrip =
                                      await _databaseService.getTrip(tripId);

                                  DateTime createdAtTime =
                                      DateTime.parse(currentTrip.createdAt!);

                                  var durationTime = DateTime.now()
                                      .toUtc()
                                      .difference(createdAtTime);
                                  String tripDuration =
                                      Utils.calculateTripDuration(
                                          ((durationTime.inMilliseconds) / 1000)
                                              .toInt());

                                  Navigator.of(context).pop();

                                  Utils.customPrint(
                                      'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');

                                  EndTrip().endTrip(
                                      context: context,
                                      scaffoldKey: scaffoldKey,
                                      duration: tripDuration,
                                      onEnded: () async {
                                        Utils.customPrint('TRIPPPPPP ENDEDDD:');
                                        setState(() {
                                          isEndTripButton = false;
                                          tripIsEnded = true;
                                          commonProvider.getTripsByVesselId(
                                              widget.vessel!.id);
                                          // isZipFileCreate = true;
                                        });
                                        await tripIsRunningOrNot();
                                        getVesselAnalytics(widget.vessel!.id!);
                                      });
                                }, () {
                                  Navigator.of(context).pop();
                                });
                              })
                      : CommonButtons.getActionButton(
                          title: 'Start Trip',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: buttonBGColor,
                          borderColor: buttonBGColor,
                          width: displayWidth(context),
                          onTap: () async {
                            bool? isTripStarted =
                                sharedPreferences!.getBool('trip_started');

                            if (isTripStarted != null) {
                              if (isTripStarted) {
                                List<String>? tripData = sharedPreferences!
                                    .getStringList('trip_data');
                                Trip tripDetails = await _databaseService
                                    .getTrip(tripData![0]);

                                if (tripDetails.vesselId != widget.vessel!.id) {
                                  showDialogBox();
                                  return;
                                }
                              }
                            }

                            bool isLocationPermitted =
                                await Permission.locationAlways.isGranted;

                            if (isLocationPermitted) {
                              bool isNDPermDenied = await Permission
                                  .bluetoothConnect.isPermanentlyDenied;

                              print('BYEE: $isNDPermDenied');
                              if (isNDPermDenied) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return LocationPermissionCustomDialog(
                                        isLocationDialogBox: false,
                                        text: 'Allow nearby devices',
                                        subText:
                                            'Allow nearby devices to connect to the app',
                                        buttonText: 'OK',
                                        buttonOnTap: () async {
                                          Get.back();

                                          await openAppSettings();
                                        },
                                      );
                                    });
                                return;
                              } else {
// <<<<<<< Report-code-merge
                                if (Platform.isIOS) {
                                  bool isBluetoothEnable =
                                      await FlutterBluePlus.instance.isOn;

                                  if (isBluetoothEnable) {
                                    vessel!.add(widget.vessel!);
                                    await locationPermissions(
                                        widget.vessel!.vesselSize!,
                                        widget.vessel!.name!,
                                        widget.vessel!.id!);
                                  } else {
                                    showBluetoothDialog(context);
                                  }
                                } else {
// =======
//                                if(Platform.isIOS){
//                                  bool isBluetoothEnable =
//                                  await FlutterBluePlus.instance.isOn;

//                                  if (isBluetoothEnable) {
//                                    vessel!.add(widget.vessel!);
//                                    await locationPermissions(
//                                        widget.vessel!.vesselSize!,
//                                        widget.vessel!.name!,
//                                        widget.vessel!.id!);
//                                  } else {
//                                    showBluetoothDialog(context);
//                                  }
//                                }else {
// >>>>>>> Bug_loc_reports
                                  bool isNDPermittedOne = await Permission
                                      .bluetoothConnect.isGranted;

                                  if (isNDPermittedOne) {
                                    bool isBluetoothEnable =
                                        await FlutterBluePlus.instance.isOn;

                                    if (isBluetoothEnable) {
                                      vessel!.add(widget.vessel!);
                                      await locationPermissions(
                                          widget.vessel!.vesselSize!,
                                          widget.vessel!.name!,
                                          widget.vessel!.id!);
                                    } else {
                                      showBluetoothDialog(context);
                                    }
                                  } else {
                                    print('HII: $isNDPermittedOne');

                                    await Permission.bluetoothConnect.request();
                                    bool isNDPermitted = await Permission
                                        .bluetoothConnect.isGranted;
                                    if (isNDPermitted) {
                                      bool isBluetoothEnable =
                                          await FlutterBluePlus.instance.isOn;

                                      if (isBluetoothEnable) {
                                        vessel!.add(widget.vessel!);
                                        await locationPermissions(
                                            widget.vessel!.vesselSize!,
                                            widget.vessel!.name!,
                                            widget.vessel!.id!);
                                      } else {
                                        showBluetoothDialog(context);
                                      }
                                    } else {
                                      if (await Permission
                                              .bluetoothConnect.isDenied ||
                                          await Permission.bluetoothConnect
                                              .isPermanentlyDenied) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return LocationPermissionCustomDialog(
                                                isLocationDialogBox: false,
                                                text: 'Allow nearby devices',
                                                subText:
                                                    'Allow nearby devices to connect to the app',
                                                buttonText: 'OK',
                                                buttonOnTap: () async {
                                                  Get.back();

                                                  await openAppSettings();
                                                },
                                              );
                                            });
                                      }
                                    }
                                  }
                                }
                              }
                            } else {
                              /// WIU
                              bool isWIULocationPermitted =
                                  await Permission.locationWhenInUse.isGranted;

                              if (!isWIULocationPermitted) {
                                await Utils.getLocationPermission(
                                    context, scaffoldKey);
                              }
                              /*setState(() {
                                    isLocationDialogBoxOpen = true;
                                  });*/
                              bool isLocationPermitted =
                                  await Permission.locationAlways.isGranted;
                              if (isLocationPermitted) {
                                bool isNDPermDenied = await Permission
                                    .bluetoothConnect.isPermanentlyDenied;

                                if (isNDPermDenied) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return LocationPermissionCustomDialog(
                                          isLocationDialogBox: false,
                                          text: 'Allow nearby devices',
                                          subText:
                                              'Allow nearby devices to connect to the app',
                                          buttonText: 'OK',
                                          buttonOnTap: () async {
                                            Get.back();

                                            await openAppSettings();
                                          },
                                        );
                                      });
                                  return;
                                } else {
                                  bool isNDPermitted = await Permission
                                      .bluetoothConnect.isGranted;

                                  if (isNDPermitted) {
                                    bool isBluetoothEnable =
                                        await FlutterBluePlus.instance.isOn;

                                    if (isBluetoothEnable) {
                                      vessel!.add(widget.vessel!);
                                      await locationPermissions(
                                          widget.vessel!.vesselSize!,
                                          widget.vessel!.name!,
                                          widget.vessel!.id!);
                                    } else {
                                      showBluetoothDialog(context);
                                    }
                                  } else {
                                    await Permission.bluetoothConnect.request();
                                    bool isNDPermitted = await Permission
                                        .bluetoothConnect.isGranted;
                                    if (isNDPermitted) {
                                      bool isBluetoothEnable =
                                          await FlutterBluePlus.instance.isOn;

                                      if (isBluetoothEnable) {
                                        vessel!.add(widget.vessel!);
                                        await locationPermissions(
                                            widget.vessel!.vesselSize!,
                                            widget.vessel!.name!,
                                            widget.vessel!.id!);
                                      } else {
                                        showBluetoothDialog(context);
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (Platform.isIOS) {
                                  await Permission.locationAlways.request();
                                  bool isLocationAlwaysPermitted =
                                      await Permission.locationAlways.isGranted;

                                  Utils.customPrint(
                                      'IOS PERMISSION GIVEN OUTSIDE');

                                  if (isLocationAlwaysPermitted) {
                                    Utils.customPrint('IOS PERMISSION GIVEN 1');

                                    vessel!.add(widget.vessel!);
                                    await locationPermissions(
                                        widget.vessel!.vesselSize!,
                                        widget.vessel!.name!,
                                        widget.vessel!.id!);
                                  } else {
                                    Utils.showSnackBar(context,
                                        scaffoldKey: scaffoldKey,
                                        message:
                                            'Location permissions are denied without permissions we are unable to start the trip');

                                    Future.delayed(Duration(seconds: 3),
                                        () async {
                                      await openAppSettings();
                                    });
                                  }
                                } else {
                                  if (!isLocationDialogBoxOpen) {
                                    Utils.customPrint("ELSE CONDITION");

                                    showDialog(
                                        context: scaffoldKey.currentContext!,
                                        builder: (BuildContext context) {
                                          isLocationDialogBoxOpen = true;
                                          return LocationPermissionCustomDialog(
                                            isLocationDialogBox: true,
                                            text:
                                                'Always Allow Access to “Location”',
                                            subText:
                                                "To track your trip while you use other apps we need background access to your location",
                                            buttonText: 'Ok',
                                            buttonOnTap: () async {
                                              Get.back();

                                              await openAppSettings();
                                            },
                                          );
                                        }).then((value) {
                                      isLocationDialogBoxOpen = false;
                                    });
                                  }
                                }
                              }
                            }
                          }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  locationPermissions(dynamic size, String vesselName, String weight) async {
    if (Platform.isAndroid) {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        //   await showBluetoothDialog(context);
        //  await showBluetoothListDialog(context);

        /*FlutterBluePlus.instance.isScanning.listen((event) {
          print('SCANNING $event');

          if (event) {
            FlutterBluePlus.instance.stopScan();
            FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          } else {
            FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          }
        });*/

        FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
        FlutterBluePlus.instance.scanResults.listen((results) async {
          // print('SCAN RESULT INSIDE LISTEN');
          for (ScanResult r in results) {
            // print('SCAN RESULT INSIDE FOR EACH');
            // print('${r.device.name} found! rssi: ${r.rssi}');
            if (r.device.name.toLowerCase().contains("lpr")) {
              // print('SCAN RESULT INSIDE IF ${r.device.name}');
              print('FOUND DEVICE AGAIN');

              r.device.connect().catchError((e) {
                r.device.state.listen((event) {
                  if (event == BluetoothDeviceState.connected) {
                    // print('CONNECTION EVENT ${event}');
                    r.device.disconnect().then((value) {
                      r.device.connect().catchError((e) {
                        // print('SCAN RESULT INSIDE IF ${r.device.name}');
                        if (mounted) {
                          setState(() {
                            isBluetoothConnected = true;
                            progress = 1.0;
                            lprSensorProgress = 1.0;
                            isStartButton = true;
                          });
                        }
                      });
                    });
                  }
                });
              });

              bluetoothName = r.device.name;
              setState(() {
                isBluetoothConnected = true;
                progress = 1.0;
                lprSensorProgress = 1.0;
                isStartButton = true;
              });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device
                  .disconnect()
                  .then((value) => print("is device disconnected:"));
            }
          }
        });
        getBottomSheet(context, size, vesselName, weight, isLocationPermitted);
      } else {
        // await showBluetoothDialog(context);
        //  await showBluetoothListDialog(context);
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          FlutterBluePlus.instance.scanResults.listen((results) async {
            // print('SCAN RESULT INSIDE LISTEN');
            for (ScanResult r in results) {
              // print('SCAN RESULT INSIDE FOR EACH');
              // print('${r.device.name} found! rssi: ${r.rssi}');
              if (r.device.name.toLowerCase().contains("lpr")) {
                // print('SCAN RESULT INSIDE IF ${r.device.name}');

                r.device.connect().catchError((e) {
                  r.device.state.listen((event) {
                    if (event == BluetoothDeviceState.connected) {
                      // print('CONNECTION EVENT ${event}');
                      r.device.disconnect().then((value) {
                        r.device.connect().catchError((e) {
                          // print('SCAN RESULT INSIDE IF ${r.device.name}');
                          if (mounted) {
                            setState(() {
                              isBluetoothConnected = true;
                              progress = 1.0;
                              lprSensorProgress = 1.0;
                              isStartButton = true;
                            });
                          }
                        });
                      });
                    }
                  });
                });

                bluetoothName = r.device.name;
                setState(() {
                  isBluetoothConnected = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device
                    .disconnect()
                    .then((value) => print("is device disconnected: "));
              }
            }
          });
          getBottomSheet(
              context, size, vesselName, weight, isLocationPermitted);
        }
      }
    } else {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        //   await showBluetoothDialog(context);
        //  await showBluetoothListDialog(context);

        /*FlutterBluePlus.instance.isScanning.listen((event) {
          print('SCANNING $event');

          if (event) {
            FlutterBluePlus.instance.stopScan();
            FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          } else {
            FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          }
        });*/

        FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
        FlutterBluePlus.instance.scanResults.listen((results) async {
          // print('SCAN RESULT INSIDE LISTEN');
          for (ScanResult r in results) {
            // print('SCAN RESULT INSIDE FOR EACH');
            // print('${r.device.name} found! rssi: ${r.rssi}');
            if (r.device.name.toLowerCase().contains("lpr")) {
              // print('SCAN RESULT INSIDE IF ${r.device.name}');
              print('FOUND DEVICE AGAIN');

              r.device.connect().catchError((e) {
                r.device.state.listen((event) {
                  if (event == BluetoothDeviceState.connected) {
                    // print('CONNECTION EVENT ${event}');
                    r.device.disconnect().then((value) {
                      r.device.connect().catchError((e) {
                        // print('SCAN RESULT INSIDE IF ${r.device.name}');
                        if (mounted) {
                          setState(() {
                            isBluetoothConnected = true;
                            progress = 1.0;
                            lprSensorProgress = 1.0;
                            isStartButton = true;
                          });
                        }
                      });
                    });
                  }
                });
              });

              bluetoothName = r.device.name;
              setState(() {
                isBluetoothConnected = true;
                progress = 1.0;
                lprSensorProgress = 1.0;
                isStartButton = true;
              });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device
                  .disconnect()
                  .then((value) => print("is device disconnected: "));
            }
          }
        });
        getBottomSheet(context, size, vesselName, weight, isLocationPermitted);
      } else {
        // await showBluetoothDialog(context);
        //  await showBluetoothListDialog(context);
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          FlutterBluePlus.instance.scanResults.listen((results) async {
            // print('SCAN RESULT INSIDE LISTEN');
            for (ScanResult r in results) {
              // print('SCAN RESULT INSIDE FOR EACH');
              // print('${r.device.name} found! rssi: ${r.rssi}');
              if (r.device.name.toLowerCase().contains("lpr")) {
                // print('SCAN RESULT INSIDE IF ${r.device.name}');

                r.device.connect().catchError((e) {
                  r.device.state.listen((event) {
                    if (event == BluetoothDeviceState.connected) {
                      // print('CONNECTION EVENT ${event}');
                      r.device.disconnect().then((value) {
                        r.device.connect().catchError((e) {
                          // print('SCAN RESULT INSIDE IF ${r.device.name}');
                          if (mounted) {
                            setState(() {
                              isBluetoothConnected = true;
                              progress = 1.0;
                              lprSensorProgress = 1.0;
                              isStartButton = true;
                            });
                          }
                        });
                      });
                    }
                  });
                });

                bluetoothName = r.device.name;
                setState(() {
                  isBluetoothConnected = true;
                  progress = 1.0;
                  lprSensorProgress = 1.0;
                  isStartButton = true;
                });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device
                    .disconnect()
                    .then((value) => print("is device disconnected: "));
              }
            }
          });
          getBottomSheet(
              context, size, vesselName, weight, isLocationPermitted);
        }
      }
    }
  }

  getBottomSheet(BuildContext context, dynamic size, String vesselName,
      String weight, bool isLocationPermission) async {
    isStartButton = false;
    isEndTripButton = false;
    isSensorDataUploaded = false;
    isZipFileCreate = false;
    addingDataToDB = false;
    selectedVesselWeight = 'Select Current Load';
    isBottomSheetOpened = true;
    isBluetoothConnected = false;
    progress = 0.9;

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            if (!addingDataToDB) {
              Navigator.pop(context);
              return false;
            } else {
              return false;
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent.withOpacity(0.0),
            extendBody: false,
            key: _modelScaffoldKey,
            resizeToAvoidBottomInset: true,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: StatefulBuilder(builder:
                  (BuildContext bottomSheetContext, StateSetter stateSetter) {
                //FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));

                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black,
                          blurRadius: 20.0,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40))),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder(
                                  duration: const Duration(seconds: 3),
                                  tween: Tween(
                                      begin: progressBegin, end: progress),
                                  builder: (context, double value, _) {
                                    return SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CircularProgressIndicator(
                                            value: value,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            strokeWidth: 3,
                                            color: Colors.green,
                                          ),
                                          Center(
                                            child: buildProgress(value, 60),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  onEnd: () {
                                    Utils.customPrint('END');
                                    stateSetter(() {
                                      isStartButton = true;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                          context: context,
                                          text: 'Fetching your device details',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.032,
                                          textAlign: TextAlign.start),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      TweenAnimationBuilder(
                                          duration: const Duration(seconds: 3),
                                          tween: Tween(
                                              begin: deviceProgressBegin,
                                              end: deviceProgress),
                                          builder: (context, double value, _) {
                                            return SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color:
                                                        circularProgressColor,
                                                    value: value,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                            Colors.green),
                                                  ),
                                                  Center(
                                                    child: subTitleProgress(
                                                        value,
                                                        displayWidth(context) *
                                                            0.035),
                                                  )
                                                ],
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: isLocationPermission
                                                  ? 'Location permission granted'
                                                  : 'Location permission is required',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          !isLocationPermission
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.red,
                                                            width: 2),
                                                        shape: BoxShape.circle),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : TweenAnimationBuilder(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  tween: Tween(
                                                      begin:
                                                          sensorProgressBegin,
                                                      end: sensorProgress),
                                                  builder: (context,
                                                      double value, _) {
                                                    return SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color:
                                                                circularProgressColor,
                                                            value: value,
                                                            backgroundColor:
                                                                Colors.grey
                                                                    .shade200,
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                const AlwaysStoppedAnimation(
                                                                    Colors
                                                                        .green),
                                                          ),
                                                          Center(
                                                            child: subTitleProgress(
                                                                value,
                                                                displayWidth(
                                                                        context) *
                                                                    0.035),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                        ],
                                      ),
                                      isLocationPermission
                                          ? SizedBox()
                                          : commonText(
                                              context: context,
                                              text: 'Permission Denied!',
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.red,
                                              textSize:
                                                  displayWidth(context) * 0.028,
                                              textAlign: TextAlign.start),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: 'Connecting with LPR',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                                  displayWidth(context) * 0.032,
                                              textAlign: TextAlign.start),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          TweenAnimationBuilder(
                                              duration:
                                                  const Duration(seconds: 3),
                                              tween: Tween(
                                                  begin: lprSensorProgressBegin,
                                                  end: lprSensorProgress),
                                              builder:
                                                  (context, double value, _) {
                                                return isBluetoothConnected
                                                    ? SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: Stack(
                                                          fit: StackFit.expand,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              color:
                                                                  circularProgressColor,
                                                              value: value,
                                                              backgroundColor:
                                                                  Colors.grey
                                                                      .shade200,
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  const AlwaysStoppedAnimation(
                                                                      Colors
                                                                          .green),
                                                            ),
                                                            Center(
                                                              child: subTitleProgress(
                                                                  value,
                                                                  displayWidth(
                                                                          context) *
                                                                      0.035),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 2),
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                              size: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                              }),
                                        ],
                                      ),
                                      isBluetoothConnected
                                          ? Row(
                                              children: [
                                                commonText(
                                                    context: context,
                                                    text: 'Connected with ',
                                                    fontWeight: FontWeight.w400,
                                                    textColor: Colors.green,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.028,
                                                    textAlign: TextAlign.start),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text: bluetoothName,
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.green,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.028,
                                                    textAlign: TextAlign.start),
                                              ],
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                showBluetoothListDialog(
                                                    context, stateSetter);
                                              },
                                              child: commonText(
                                                  context: context,
                                                  text:
                                                      'Tap to connect LPR manually',
                                                  fontWeight: FontWeight.w400,
                                                  textColor: Colors.red,
                                                  textSize:
                                                      displayWidth(context) *
                                                          0.028,
                                                  textAlign: TextAlign.start),
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: displayWidth(context) * 0.08),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      commonText(
                                          context: context,
                                          text: 'Connecting with sensors',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.032,
                                          textAlign: TextAlign.start),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      TweenAnimationBuilder(
                                          duration: const Duration(seconds: 3),
                                          tween: Tween(
                                              begin: accSensorProgressBegin,
                                              end: accSensorProgress),
                                          builder: (context, double value, _) {
                                            return SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color:
                                                        circularProgressColor,
                                                    value: value,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                            Colors.green),
                                                  ),
                                                  Center(
                                                    child: subTitleProgress(
                                                        value,
                                                        displayWidth(context) *
                                                            0.035),
                                                  )
                                                ],
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                isZipFileCreate
                                    ? InkWell(
                                        onTap: () async {
                                          File copiedFile =
                                              File('${ourDirectory!.path}.zip');

                                          Directory directory;

                                          if (Platform.isAndroid) {
                                            directory = Directory(
                                                "storage/emulated/0/Download/${widget.vessel!.id}.zip");
                                          } else {
                                            directory =
                                                await getApplicationDocumentsDirectory();
                                          }

                                          copiedFile.copy(directory.path);

                                          Utils.customPrint(
                                              'DOES FILE EXIST: ${copiedFile.existsSync()}');
                                          if (copiedFile.existsSync()) {
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                    'File downloaded successfully');
                                          }

                                          // Utils.download(context, scaffoldKey,ourDirectory!.path);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            commonText(
                                                context: context,
                                                text: 'Download File',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.038,
                                                textAlign: TextAlign.start),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                  Icons.file_download_outlined),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                const SizedBox(
                                  height: 40,
                                ),
                                StatefulBuilder(
                                  builder: (context, StateSetter stateSetter) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Container(
                                            height: displayHeight(context) >=
                                                    680
                                                ? displayHeight(context) * 0.056
                                                : displayHeight(context) * 0.07,
                                            alignment: Alignment.centerLeft,
                                            color: Color(0xFFECF3F9),
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                enabledBorder: InputBorder.none,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                0.0))),
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5,
                                                    bottom: 5),
                                              ),
                                              child: commonText(
                                                  context: context,
                                                  text: vesselName,
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.black54,
                                                  textSize:
                                                      displayWidth(context) *
                                                          0.032,
                                                  textAlign: TextAlign.start),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: displayHeight(context) >=
                                                    680
                                                ? displayHeight(context) * 0.056
                                                : displayHeight(context) * 0.07,
                                            color: Color(0xFFECF3F9),
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                enabledBorder: InputBorder.none,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                0.0))),
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 10,
                                                    bottom: 10),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<dynamic>(
                                                  value: null,
                                                  isDense: true,
                                                  hint: commonText(
                                                      context: context,
                                                      text:
                                                          selectedVesselWeight,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: Colors.black54,
                                                      textSize: displayWidth(
                                                              context) *
                                                          0.032,
                                                      textAlign:
                                                          TextAlign.start),
                                                  //  Text(
                                                  //     '${selectedVesselWeight}'),
                                                  isExpanded: true,
                                                  items: [
                                                    DropdownMenuItem(
                                                        value: '1',
                                                        child: Text('Empty')),
                                                    DropdownMenuItem(
                                                        value: '2',
                                                        child: Text('Half')),
                                                    DropdownMenuItem(
                                                        value: '3',
                                                        child: Text('Full')),
                                                    DropdownMenuItem(
                                                        value: '4',
                                                        child:
                                                            Text('Variable')),
                                                  ],
                                                  onChanged: (weightValue) {
                                                    stateSetter(() {
                                                      if (int.parse(
                                                              weightValue) ==
                                                          1) {
                                                        selectedVesselWeight =
                                                            'Empty';
                                                      } else if (int.parse(
                                                              weightValue) ==
                                                          2) {
                                                        selectedVesselWeight =
                                                            'Half';
                                                      } else if (int.parse(
                                                              weightValue) ==
                                                          3) {
                                                        selectedVesselWeight =
                                                            'Full';
                                                      } else {
                                                        selectedVesselWeight =
                                                            'Variable';
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            //height: 50,
                            width: displayWidth(context),
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: 17,
                                  right: 17,
                                  bottom:
                                      isStartButton || isEndTripButton ? 8 : 2),
                              child: isStartButton
                                  ? addingDataToDB
                                      ? Center(
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      circularProgressColor)))
                                      : CommonButtons.getActionButton(
                                          title: 'Start',
                                          context: context,
                                          fontSize:
                                              displayWidth(context) * 0.042,
                                          textColor: Colors.white,
                                          buttonPrimaryColor: buttonBGColor,
                                          borderColor: buttonBGColor,
                                          width: displayWidth(context),
                                          onTap: () async {
                                            Utils.customPrint(
                                                'SELECTED VESSEL WEIGHT $selectedVesselWeight');
                                            if (selectedVesselWeight ==
                                                'Select Current Load') {
                                              Utils.customPrint(
                                                  'SELECTED VESSEL WEIGHT 12 $selectedVesselWeight');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Text(
                                                    "Please select current load"),
                                                duration: Duration(seconds: 1),
                                                backgroundColor: Colors.blue,
                                              ));
                                              return;
                                            }

                                            /*if (!isBluetoothConnected) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Text(
                                                    "Please connect with LPR device"),
                                                duration: Duration(seconds: 1),
                                                backgroundColor: Colors.blue,
                                              ));
                                              return;
                                            }*/

                                            bool isLocationPermitted =
                                                await Permission
                                                    .location.isGranted;

                                            if (isLocationPermitted) {
                                              stateSetter(() {
                                                isLocationPermission = true;
                                              });

                                              if (Platform.isAndroid) {
                                                final androidInfo =
                                                    await DeviceInfoPlugin()
                                                        .androidInfo;

                                                if (androidInfo.version.sdkInt <
                                                    29) {
                                                  var isStoragePermitted =
                                                      await Permission
                                                          .storage.status;
                                                  if (isStoragePermitted
                                                      .isGranted) {
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;

                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    } else {
                                                      await Utils
                                                          .getNotificationPermission(
                                                              context);
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;
                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      }
                                                    }
                                                  } else {
                                                    await Utils
                                                        .getStoragePermission(
                                                            context);
                                                    final androidInfo =
                                                        await DeviceInfoPlugin()
                                                            .androidInfo;

                                                    var isStoragePermitted =
                                                        await Permission
                                                            .storage.status;

                                                    if (isStoragePermitted
                                                        .isGranted) {
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;

                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      } else {
                                                        await Utils
                                                            .getNotificationPermission(
                                                                context);
                                                        bool
                                                            isNotificationPermitted =
                                                            await Permission
                                                                .notification
                                                                .isGranted;
                                                        if (isNotificationPermitted) {
                                                          startWritingDataToDB(
                                                              bottomSheetContext,
                                                              stateSetter);
                                                        }
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  bool isNotificationPermitted =
                                                      await Permission
                                                          .notification
                                                          .isGranted;

                                                  if (isNotificationPermitted) {
                                                    startWritingDataToDB(
                                                        bottomSheetContext,
                                                        stateSetter);
                                                  } else {
                                                    await Utils
                                                        .getNotificationPermission(
                                                            context);
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;
                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    }
                                                  }
                                                }
                                              } else {
                                                bool isNotificationPermitted =
                                                    await Permission
                                                        .notification.isGranted;

                                                if (isNotificationPermitted) {
                                                  startWritingDataToDB(
                                                      bottomSheetContext,
                                                      stateSetter);
                                                } else {
                                                  await Utils
                                                      .getNotificationPermission(
                                                          context);
                                                  bool isNotificationPermitted =
                                                      await Permission
                                                          .notification
                                                          .isGranted;
                                                  if (isNotificationPermitted) {
                                                    startWritingDataToDB(
                                                        bottomSheetContext,
                                                        stateSetter);
                                                  }
                                                }
                                              }
                                            } else {
                                              await Utils.getLocationPermission(
                                                  context, scaffoldKey);
                                              bool isLocationPermitted =
                                                  await Permission
                                                      .location.isGranted;

                                              if (isLocationPermitted) {
                                                stateSetter(() {
                                                  isLocationPermission = true;
                                                });
                                                // service.startService();

                                                if (Platform.isAndroid) {
                                                  final androidInfo =
                                                      await DeviceInfoPlugin()
                                                          .androidInfo;

                                                  if (androidInfo
                                                          .version.sdkInt <
                                                      29) {
                                                    var isStoragePermitted =
                                                        await Permission
                                                            .storage.status;
                                                    if (isStoragePermitted
                                                        .isGranted) {
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;

                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      } else {
                                                        await Utils
                                                            .getNotificationPermission(
                                                                context);
                                                        bool
                                                            isNotificationPermitted =
                                                            await Permission
                                                                .notification
                                                                .isGranted;
                                                        if (isNotificationPermitted) {
                                                          startWritingDataToDB(
                                                              bottomSheetContext,
                                                              stateSetter);
                                                        }
                                                      }
                                                    } else {
                                                      await Utils
                                                          .getStoragePermission(
                                                              context);
                                                      final androidInfo =
                                                          await DeviceInfoPlugin()
                                                              .androidInfo;

                                                      var isStoragePermitted =
                                                          await Permission
                                                              .storage.status;

                                                      if (isStoragePermitted
                                                          .isGranted) {
                                                        bool
                                                            isNotificationPermitted =
                                                            await Permission
                                                                .notification
                                                                .isGranted;

                                                        if (isNotificationPermitted) {
                                                          startWritingDataToDB(
                                                              bottomSheetContext,
                                                              stateSetter);
                                                        } else {
                                                          await Utils
                                                              .getNotificationPermission(
                                                                  context);
                                                          bool
                                                              isNotificationPermitted =
                                                              await Permission
                                                                  .notification
                                                                  .isGranted;
                                                          if (isNotificationPermitted) {
                                                            startWritingDataToDB(
                                                                bottomSheetContext,
                                                                stateSetter);
                                                          }
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;

                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    } else {
                                                      await Utils
                                                          .getNotificationPermission(
                                                              context);
                                                      bool
                                                          isNotificationPermitted =
                                                          await Permission
                                                              .notification
                                                              .isGranted;
                                                      if (isNotificationPermitted) {
                                                        startWritingDataToDB(
                                                            bottomSheetContext,
                                                            stateSetter);
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  bool isNotificationPermitted =
                                                      await Permission
                                                          .notification
                                                          .isGranted;

                                                  if (isNotificationPermitted) {
                                                    startWritingDataToDB(
                                                        bottomSheetContext,
                                                        stateSetter);
                                                  } else {
                                                    await Utils
                                                        .getNotificationPermission(
                                                            context);
                                                    bool
                                                        isNotificationPermitted =
                                                        await Permission
                                                            .notification
                                                            .isGranted;
                                                    if (isNotificationPermitted) {
                                                      startWritingDataToDB(
                                                          bottomSheetContext,
                                                          stateSetter);
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          })
                                  : Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: CommonButtons.getActionButton(
                                          title: 'Cancel',
                                          context: context,
                                          fontSize:
                                              displayWidth(context) * 0.042,
                                          textColor: Colors.white,
                                          buttonPrimaryColor: buttonBGColor,
                                          borderColor: buttonBGColor,
                                          width: displayWidth(context),
                                          onTap: () {
                                            Get.back();
                                          }),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: addingDataToDB
                            ? SizedBox()
                            : Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: backgroundColor),
                                child: IconButton(
                                    onPressed: () async {
                                      isBottomSheetOpened = false;
                                      await tripIsRunningOrNot();
                                      setState(() {
                                        widget.vessel!.id = widget.vessel!.id;
                                      });

                                      stateSetter(() {
                                        addingDataToDB = false;
                                      });

                                      Navigator.of(bottomSheetContext).pop();
                                    },
                                    icon: Icon(Icons.close_rounded,
                                        color: buttonBGColor)),
                              ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
      elevation: 4,
      enableDrag: false,
    ).then((value) async {
      await tripIsRunningOrNot();
      Utils.customPrint('BACK PRESSED');
      isBottomSheetOpened = false;

      addingDataToDB = false;
      isStartButton = false;
      isEndTripButton = true;

      if (tripIsRunning) {
        if (Platform.isAndroid) {
          service.invoke("setAsForeground");
        }
        List<String>? tripData = sharedPreferences!.getStringList('trip_data');
        final tripDetails = await _databaseService.getTrip(tripData![0]);

        var result = Navigator.pushReplacement(
          scaffoldKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => TripAnalyticsScreen(
                    tripId: tripDetails.id,
                    vesselId: widget.vessel!.id,
                    tripIsRunningOrNot: tripIsRunning,
                  )),
        );

        if (result != null) {
          debugPrint('VESSEL SINGLE VIEW RESULT $result');
        }
      }
    });
  }

  Future<void> enableBT() async {
    BluetoothEnable.enableBluetooth.then((value) async {
      //isBluetoothConnected = value;

      Utils.customPrint("BLUETOOTH ENABLE $value");

      if (value == 'true') {
        vessel!.add(widget.vessel!);
        await locationPermissions(widget.vessel!.vesselSize!,
            widget.vessel!.name!, widget.vessel!.id!);
        print(" bluetooth state$value");
      } else {
        bool isNearByDevicePermitted =
            await Permission.bluetoothConnect.isGranted;

        if (!isNearByDevicePermitted) {
          await Permission.bluetoothConnect.request();
        }
      }
    }).catchError((e) {
      print("ENABLE BT$e");
    });
  }

  buildProgress(double progress, double size) {
    return commonText(
        context: context,
        text: '${(progress * 100).toStringAsFixed(0)} %',
        fontWeight: FontWeight.w500,
        textColor: Colors.black,
        textSize: displayWidth(context) * 0.038,
        textAlign: TextAlign.start);
  }

  subTitleProgress(double progress, double size) {
    if (progress == 1) {
      return Icon(
        Icons.done,
        color: Colors.green,
        size: size,
      );
    }
  }

  Future<void> onSave(String file, BuildContext context,
      bool savingDataWhileStartService) async {
    final vesselName = widget.vessel!.name;
    final currentLoad = selectedVesselWeight;
    /*Position? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);*/
    await fetchDeviceData();

    Utils.customPrint(
        'hello device details: ${deviceDetails!.toJson().toString()}');
    /* String latitude = locationData!.latitude.toString();
    String longitude = locationData.longitude.toString();*/

    ReceivePort port = ReceivePort();
    LocationDto? locationDto;
    port.listen((dynamic data) async {
      locationDto = data != null ? LocationDto.fromJson(data) : null;
    });

    String? newLat, newLong;

    if (locationDto != null) {
      newLat = locationDto!.latitude.toString();
      newLong = locationDto!.longitude.toString();
    }

    Utils.customPrint("current lod:$currentLoad");
    Utils.customPrint("current PATH:$file");

    Utils.customPrint("ON SAVE FIRST INSERT :$getTripId");
    Utils.customPrint("ON SAVE FIRST INSERT :$getTripId");

    try {
      await _databaseService.insertTrip(Trip(
          id: getTripId,
          vesselId: widget.vessel!.id,
          vesselName: vesselName,
          currentLoad: currentLoad,
          filePath: file,
          isSync: 0,
          tripStatus: 0,
          createdAt: Utils.getCurrentTZDateTime(),
          updatedAt: Utils.getCurrentTZDateTime(),
          startPosition: [latitude, longitude].join(","),
          endPosition: [latitude, longitude].join(","),
          deviceInfo: deviceDetails!.toJson().toString()));
    } on Exception catch (e) {
      Utils.customPrint('ON SAVE EXE: $e');
    }
    return;
  }

  startWritingDataToDB(
      BuildContext bottomSheetContext, StateSetter stateSetter) async {
    bool isServiceRunning = await service.isRunning();

    Utils.customPrint('ISSSSS XXXXXXX: $isServiceRunning');

    stateSetter(() {
      addingDataToDB = true;
    });

    // if (!isServiceRunning) {
    //   await service.startService();
    //
    //   Utils.customPrint('View Single: $isServiceRunning');
    // }

    getTripId = ObjectId().toString();

    await onSave('', bottomSheetContext, true);

    /*await Future.delayed(Duration(seconds: 4), () {
      Utils.customPrint('Future delayed duration Ended');
    });*/

    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data', [
      getTripId,
      widget.vessel!.id!,
      widget.vessel!.name!,
      selectedVesselWeight
    ]);

    await initPlatformStateBGL();

    StartTrip().startBGLocatorTrip(getTripId, DateTime.now());

    await tripIsRunningOrNot();

    Navigator.pop(bottomSheetContext);
    return;

    /* if (Platform.isAndroid) {
      service.invoke(
          'tripId', {'tripId': getTripId, 'vesselName': widget.vessel!.name});

      // service.invoke("setAsForeground");

      service.invoke("onStartTrip");
    }
    else {
      await sharedPreferences!.setBool('trip_started', true);
      await sharedPreferences!.setStringList('trip_data', [
        getTripId,
        widget.vessel!.id!,
        widget.vessel!.name!,
        selectedVesselWeight
      ]);

      await initPlatformStateBGL();

      StartTrip().startBGLocatorTrip(getTripId, DateTime.now());

      await tripIsRunningOrNot();

      Navigator.pop(bottomSheetContext);
      return;

      startTripPosition = await Geolocator.getCurrentPosition();
      startDateTime = DateTime.now();

      // Position? endTripPosition;
      pref = await SharedPreferences.getInstance();

      await pref!.setBool('trip_started', true);
      await pref!.setStringList('trip_data', [
        getTripId,
        widget.vessel!.id!,
        widget.vessel!.name!,
        selectedVesselWeight
      ]);

      await StartTrip().initIOSTrip();

      // TODO Send sensor data to start trip for ios

      gyroscopeAvailable =
          await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
      accelerometerAvailable =
          await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
      magnetometerAvailable =
          await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
      userAccelerometerAvailable = await s.SensorManager()
          .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

      Position pos = await Geolocator.getCurrentPosition();

      if (pos != null) {
        await StartTrip().startIOSTrip2(
          startDateTime,
          //int.parse(event.content),
          0,
          startTripPosition!,
          pos.latitude,
          pos.longitude,
          getTripId,
          widget.vessel!.name!,
          pos.speed,
          pref!,
          1,
          gyroscopeAvailable!,
          accelerometerAvailable!,
          magnetometerAvailable!,
          userAccelerometerAvailable!,
          */ /*_accelerometerValues! == null ? [0.0] : _accelerometerValues!,
          _gyroscopeValues! == null ? [0.0] : _gyroscopeValues!,
          _userAccelerometerValues == null ? [0.0] : _userAccelerometerValues,
          _magnetometerValues == null ? [0.0] : _magnetometerValues,*/ /*
        );
      }

      // await Future.delayed(const Duration(seconds: 2));
      // Timer timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //   sec = sec++;
      // });

      // bg.BackgroundGeolocation.getCurrentPosition(
      //     persist: true, // <-- do not persist this location
      //     desiredAccuracy: 40, // <-- desire an accuracy of 40 meters or less
      //     maximumAge: 10000, // <-- Up to 10s old is fine.
      //     timeout: 30, // <-- wait 30s before giving up.
      //     samples: 3, // <-- sample just 1 location
      //     extras: {"getCurrentPosition": true}).then((bg.Location location) {
      //   print('[getCurrentPosition] - $location');
      // }).catchError((error) {
      //   print('[getCurrentPosition] ERROR: $error');
      // });

      // callback(bg.State state) async {
      //   print('[start] success: $state');
      //   setState(() {
      //     _enabled = state.enabled;
      //     _isMoving = state.isMoving!;
      //   });
      // }

      // bg.State state = await bg.BackgroundGeolocation.state;
      // if (state.enabled) {
      //   await bg.BackgroundGeolocation.start().then(callback);
      //   // registerEventListeners();
      //   // bg.BackgroundGeolocation.changePace(true).then((bool isMoving) {
      //   //   print('[changePace] success $isMoving');
      //   // }).catchError((e) {
      //   //   print('[changePace] ERROR: ' + e.code.toString());
      //   // });
      // } else {
      //   bg.BackgroundGeolocation.startGeofences().then(callback);
      // }
      //
      // bg.BackgroundGeolocation.changePace(true).then((bool isMoving) {
      //   print('[changePace] success $isMoving');
      // }).catchError((e) {
      //   print('[changePace] ERROR: ' + e.code.toString());
      // });

      // final result = await backgroundExecutor.runImmediatelyBackgroundTask(
      //   callback: immediately,
      //   cancellable: true,
      //   withMessages: true,
      // );
      //
      // result.connector?.messageStream.listen((event) {});
      // backgroundExecutor.createConnector().messageStream.listen((event) async {
      //   // if (!mounted) return;
      //   // setState(() {
      //   //   _message = 'Message from ${event.from}:\n${event.content}';
      //   // });
      //
      //   debugPrint("USER ACC $userAccelerometerAvailable");
      //   // Position endTripPosition = await Geolocator.getCurrentPosition();
      //   //
      //   // Utils.customPrint(endTripPosition == null
      //   //     ? 'Unknown'
      //   //     : 'END POS: ${endTripPosition.latitude.toString()}, ${endTripPosition.longitude.toString()}');
      //
      //   if (endTripPosition != null) {
      //     await StartTrip().startIOSTrip2(
      //         int.parse(event.content),
      //         0,
      //         startTripPosition,
      //         endTripPosition!,
      //         getTripId,
      //         widget.vessel!.name!,
      //         pref,
      //         1,
      //         gyroscopeAvailable,
      //         accelerometerAvailable,
      //         magnetometerAvailable,
      //         userAccelerometerAvailable,
      //         _accelerometerValues == null ? [0.0] : _accelerometerValues,
      //         _gyroscopeValues == null ? [0.0] : _gyroscopeValues,
      //         _userAccelerometerValues == null
      //             ? [0.0]
      //             : _userAccelerometerValues,
      //         _magnetometerValues == null ? [0.0] : _magnetometerValues);
      //   }
      // });
    }
*/
    await sharedPreferences!.setBool('trip_started', true);
    await sharedPreferences!.setStringList('trip_data', [
      getTripId,
      widget.vessel!.id!,
      widget.vessel!.name!,
      selectedVesselWeight
    ]);

    await tripIsRunningOrNot();

    Navigator.pop(bottomSheetContext);
  }

  Future<void> initPlatformStateBGL() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    String logStr = await FileManager.readLogFile();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {
      // isRunning = _isRunning;
    });

    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: bgls.LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: bglas.AndroidSettings(
            accuracy: bgls.LocationAccuracy.NAVIGATION,
            interval: 1,
            distanceFilter: 0,
            //client: bglas.LocationClient.android,
            androidNotificationSettings: bglas.AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Trip is in progress',
                notificationMsg: '',
                notificationBigMsg: '',
                notificationIconColor: Colors.grey,
                notificationIcon: '@drawable/noti_logo',
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
    // print('Running ${isRunning.toString()}');
  }

  showDialogBox() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.3,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                      'There is a trip in progress from another vessel. Please end that trip and come back here.',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Center(
                          child: CommonButtons.getAcceptButton(
                              'OK', context, primaryColor, () async {
                            Navigator.of(context).pop();
                          },
                              displayWidth(context) * 0.4,
                              displayHeight(context) * 0.05,
                              primaryColor,
                              Colors.white,
                              displayHeight(context) * 0.018,
                              buttonBGColor,
                              '',
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  showBluetoothDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(builder: (ctx, setDialogState) {
              return Container(
                width: displayWidth(context),
                height: displayHeight(context) * 0.3,
                decoration: new BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        "Turn Bluetooth On",
                        style: TextStyle(
                            color: blutoothDialogTitleColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "To connect with other devices we require\n you to enable the Bluetooth",
                        style: TextStyle(
                            color: blutoothDialogTxtColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: displayWidth(context) * 0.12,
                          left: 15,
                          right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("Tapped on cancel button");
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bluetoothCancelBtnBackColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              height: displayWidth(context) * 0.12,
                              width: displayWidth(context) * 0.34,
                              // color: HexColor(AppColors.introButtonColor),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: bluetoothCancelBtnTxtColor),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              print("Tapped on enable Bluetooth");
                              Navigator.pop(context);
                              enableBT();
                              //showBluetoothListDialog(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bluetoothConnectBtnBackColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              height: displayWidth(context) * 0.12,
                              width: displayWidth(context) * 0.34,
                              // color: HexColor(AppColors.introButtonColor),
                              child: Center(
                                child: Text(
                                  "Enable Bluetooth",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: bluetoothConnectBtncolor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  showBluetoothListDialog(BuildContext context, StateSetter stateSetter) {
    stateSetter(() {
      progress = 0.9;
      lprSensorProgress = 0.0;
      isStartButton = false;
    });

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: StatefulBuilder(builder: (ctx, setDialogState) {
                return Container(
                  width: displayWidth(context),
                  height: displayHeight(context) * 0.5,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text(
                          "Available Devices",
                          style: TextStyle(
                              color: blutoothDialogTitleColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Tap to connect with LPR Devices to\n track Trip details",
                          style: TextStyle(
                              color: blutoothDialogTxtColor,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Implement listView for bluetooth devices
                      isRefreshList == true
                          ? Container(
                              width: displayWidth(context),
                              height: 230,
                              child: LPRBluetoothList(
                                dialogContext: dialogContext,
                                setDialogSet: setDialogState,
                                onSelected: (value) {
                                  if (mounted) {
                                    stateSetter(() {
                                      bluetoothName = value;
                                    });
                                  }
                                },
                                onBluetoothConnection: (value) {
                                  if (mounted) {
                                    stateSetter(() {
                                      isBluetoothConnected = value;
                                    });
                                  }
                                },
                              ))
                          : Container(
                              width: displayWidth(context),
                              height: 230,
                              child: LPRBluetoothList(
                                dialogContext: dialogContext,
                                setDialogSet: setDialogState,
                                onSelected: (value) {
                                  if (mounted) {
                                    stateSetter(() {
                                      bluetoothName = value;
                                    });
                                  }
                                },
                                onBluetoothConnection: (value) {
                                  if (mounted) {
                                    stateSetter(() {
                                      isBluetoothConnected = value;
                                    });
                                  }
                                },
                              )),

                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // FlutterBluePlus.instance.

                                Navigator.pop(context);
                                stateSetter(() {
                                  progress = 0.9;
                                  lprSensorProgress = 0.0;
                                  isStartButton = true;
                                  bluetoothName = '';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bluetoothCancelBtnBackColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                height: displayWidth(context) * 0.12,
                                width: displayWidth(context) * 0.34,
                                // color: HexColor(AppColors.introButtonColor),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: bluetoothCancelBtnTxtColor),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                print("Tapped on scan button");

                                if (mounted) {
                                  setDialogState(() {
                                    isScanningBluetooth = true;
                                  });
                                }

                                FlutterBluePlus.instance.stopScan();
                                FlutterBluePlus.instance.startScan(
                                    timeout: const Duration(seconds: 2));

                                if (mounted) {
                                  Future.delayed(Duration(seconds: 2), () {
                                    setDialogState(() {
                                      isScanningBluetooth = false;
                                    });
                                  });
                                }
                                /*FlutterBluePlus.instance.isScanning
                                    .listen((event) {
                                  print("Tapped on scan button 1");
                                  if (!event) {
                                    FlutterBluePlus.instance.stopScan();

                                    FlutterBluePlus.instance
                                        .startScan(
                                            timeout: const Duration(seconds: 2))
                                        .then((value) {
                                      if (mounted) {
                                        setState(() {
                                          isScanningBluetooth = false;
                                        });
                                      }
                                    });
                                  }
                                });*/

                                if (mounted) {
                                  stateSetter(() {
                                    isRefreshList = true;
                                    progress = 0.9;
                                    lprSensorProgress = 0.0;
                                    isStartButton = false;
                                    bluetoothName = '';
                                  });
                                }
                              },
                              child: isScanningBluetooth
                                  ? Center(
                                      child: Container(
                                          width: displayWidth(context) * 0.34,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator())),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: bluetoothConnectBtnBackColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      height: displayWidth(context) * 0.12,
                                      width: displayWidth(context) * 0.34,
                                      // color: HexColor(AppColors.introButtonColor),
                                      child: Center(
                                        child: Text(
                                          "Scan",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: bluetoothConnectBtncolor),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }));
        }).then((value) {
      print('DIALOG VALUE $value');

      if (bluetoothName != '') {
        stateSetter(() {
          progress = 1.0;
          lprSensorProgress = 1.0;
          isStartButton = true;
          isBluetoothConnected = true;
        });
      } else {
        stateSetter(() {
          // progress = 1.0;
          // lprSensorProgress = 1.0;
          // isStartButton = true;
          isBluetoothConnected = false;
        });
      }
    });
  }

  void getVesselAnalytics(String vesselId) async {
    if (!tripIsRunning) {
      setState(() {
        vesselAnalytics = true;
      });
    }
    List<String> analyticsData =
        await _databaseService.getVesselAnalytics(vesselId);

    setState(() {
      totalDistance = analyticsData[0];
      avgSpeed = analyticsData[1];
      tripsCount = analyticsData[2];
      totalDuration = analyticsData[3];
      vesselAnalytics = false;
    });

    /// 1. TotalDistanceSum

    /// 2. AvgSpeed

    /// 3. TripsCount
    ///
    print('totalDistance $totalDistance');
    print('avgSpeed $avgSpeed');
    print('COUNT $tripsCount');
  }
}
