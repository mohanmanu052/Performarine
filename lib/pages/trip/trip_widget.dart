import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart'
    as pos;
import 'dart:developer' as developer;
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:location/location.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/date_formatter.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/location_permission_dialog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/widgets/status_tage.dart';

class TripWidget extends StatefulWidget {
  //final Color? statusColor;
  //final String? status;
  //final String? vesselName;
  final VoidCallback? onTap;
  final VoidCallback? tripUploadedSuccessfully;
  final Trip? tripList;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const TripWidget(
      {super.key,
      //this.statusColor,
      //this.status,
      this.tripList,
      this.onTap,
      this.tripUploadedSuccessfully,
      this.scaffoldKey
      //this.vesselName
      });

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  //GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  FlutterBackgroundService service = FlutterBackgroundService();

  List<File?> finalSelectedFiles = [];

  late CommonProvider commonProvider;

  bool vesselIsSync = false,
      isTripUploaded = false,
      isTripEndedOrNot = false,
      tripIsRunning = false;
  late DeviceInfoPlugin deviceDetails;

  int progress = 0;
  Timer? progressTimer;
  double finalProgress = 0;

  List<CreateVessel> getVesselById = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
    deviceDetails = DeviceInfoPlugin();

    tripIsRunningOrNot();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    // double height = 150;
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 6),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: size.width - 60,
          //height: 110,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              //  borderRadius: BorderRadius.circular(8),
              //color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 2)
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonText(
                      context: context,
                      text: 'Trip ID - ${widget.tripList?.id ?? ''}',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.022,
                      textAlign: TextAlign.start),
                  widget.tripList?.tripStatus == 0
                      ? commonText(
                          context: context,
                          text:
                              '${DateFormat('dd/MM/yyyy hh:mm').format(DateTime.parse(widget.tripList!.createdAt!))}',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.018,
                        )
                      : commonText(
                          context: context,
                          text:
                              '${DateFormat('dd/MM/yyyy hh:mm').format(DateTime.parse(widget.tripList!.createdAt!))}  ${widget.tripList?.updatedAt != null ? '-${DateFormat('dd/MM/yyyy hh:mm').format(DateTime.parse(widget.tripList!.updatedAt!))}' : ''}',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.018,
                        ),
                ],
              ),

              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${widget.tripList!.vesselName}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: displayWidth(context) * 0.034,
                        fontFamily: poppins,
                      ),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      softWrap: true,
                    ),
                  ),
                  CustomPaint(
                    painter: StatusTag(
                        color: widget.tripList?.isSync != 0
                            ? buttonBGColor
                            : primaryColor),
                    child: Container(
                      margin:
                          EdgeInsets.only(left: displayWidth(context) * 0.05),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: commonText(
                            context: context,
                            text: widget.tripList?.isSync != 0
                                ? "Completed"
                                : "Pending Upload ",
                            fontWeight: FontWeight.w500,
                            textColor: Colors.white,
                            textSize: displayWidth(context) * 0.03,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              /*const SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          dashboardRichText(
                              modelName: widget.tripList,
                              builderName: vesselData.builderName,
                              context: context,
                              color: Colors.white.withOpacity(0.8))
                        ],
                      ),*/

              // const SizedBox(
              //   height: 4,
              // ),
              // commonText(
              //     context: context,
              //     text: '${widget.tripList!.currentLoad}',
              //     fontWeight: FontWeight.w500,
              //     textColor: Colors.grey,
              //     textSize: displayWidth(context) * 0.034,
              //     textAlign: TextAlign.start),
              // SizedBox(
              //   width: displayWidth(context) * 0.0,
              // ),
              /*Row(
                        children: [
                          commonText(
                              context: context,
                              text: 'widget.tripList.model',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.grey,
                              textSize: displayWidth(context) * 0.034,
                              textAlign: TextAlign.start),
                          SizedBox(
                            width: displayWidth(context) * 0.05,
                          ),
                          commonText(
                              context: context,
                              text: */
              /*widget.tripList?.deviceInfo?.make == null
                                  ? 'Empty'
                                  :*/ /*
                                  'widget.tripList?.deviceInfo?.make',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.grey,
                              textSize: displayWidth(context) * 0.034,
                              textAlign: TextAlign.start),
                        ],
                      ),*/
              const SizedBox(
                height: 12,
              ),
              widget.tripList?.tripStatus != 0
                  ? Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: widget.tripList?.isSync != 0
                              ? SizedBox(
                                  height: displayHeight(context) * 0.038,
                                  child: CommonButtons.getRichTextActionButton(
                                      buttonPrimaryColor: buttonBGColor,
                                      fontSize: displayWidth(context) * 0.026,
                                      onTap: () async {
                                        getVesselById = await _databaseService
                                            .getVesselNameByID(widget
                                                .tripList!.vesselId
                                                .toString());

                                        debugPrint(
                                            'VESSEL DATA ${getVesselById[0].name}');

                                        /* Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TripAnalyticsScreen(
                                                    tripList: widget.tripList!,
                                                    vessel: getVesselById[0]),
                                          ),
                                        );*/
                                      },
                                      icon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Icon(
                                          Icons.analytics_outlined,
                                          size: 18,
                                        ),
                                      ),
                                      context: context,
                                      width: displayWidth(context) * 0.38,
                                      title: 'Trip Analytics'))
                              : SizedBox(
                                  height: displayHeight(context) * 0.038,
                                  child: isTripUploaded
                                      ? Center(
                                          child: SizedBox(
                                              height: 28,
                                              width: 28,
                                              child:
                                                  CircularProgressIndicator()))
                                      : CommonButtons.getRichTextActionButton(
                                          buttonPrimaryColor: primaryColor,
                                          fontSize:
                                              displayWidth(context) * 0.026,
                                          onTap: () async {
                                            Utils().check(widget.scaffoldKey!);

                                            var connectivityResult =
                                                await (Connectivity()
                                                    .checkConnectivity());
                                            if (connectivityResult ==
                                                ConnectivityResult.mobile) {
                                              print('Mobile');
                                              showDialogBox();
                                            } else if (connectivityResult ==
                                                ConnectivityResult.wifi) {
                                              setState(() {
                                                isTripUploaded = true;
                                              });
                                              uploadDataIfDataIsNotSync();

                                              print('WIFI');
                                            }
                                          },
                                          icon: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 18,
                                            ),
                                          ),
                                          context: context,
                                          width: displayWidth(context) * 0.38,
                                          title: 'Upload Trip')),
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: SizedBox(
                              height: displayHeight(context) * 0.038,
                              child: CommonButtons.getRichTextActionButton(
                                  buttonPrimaryColor:
                                      buttonBGColor.withOpacity(.5),
                                  borderColor: buttonBGColor.withOpacity(.5),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.download_for_offline_outlined,
                                      size: 18,
                                    ),
                                  ),
                                  fontSize: displayWidth(context) * 0.026,
                                  onTap: () async {
                                    debugPrint('DOWLOAD Started!!!');

                                    final androidInfo =
                                        await DeviceInfoPlugin().androidInfo;

                                    var isStoragePermitted =
                                        androidInfo.version.sdkInt > 32
                                            ? await Permission.photos.status
                                            : await Permission.storage.status;
                                    if (isStoragePermitted.isGranted) {
                                      //File copiedFile = File('${ourDirectory!.path}.zip');
                                      File copiedFile = File(
                                          '${ourDirectory!.path}/${widget.tripList!.id}.zip');

                                      print('DIR PATH R ${ourDirectory!.path}');

                                      Directory directory;

                                      if (Platform.isAndroid) {
                                        directory = Directory(
                                            "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                      } else {
                                        directory =
                                            await getApplicationDocumentsDirectory();
                                      }

                                      copiedFile.copy(directory.path);

                                      print(
                                          'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                      if (copiedFile.existsSync()) {
                                        Utils.showSnackBar(
                                          context,
                                          scaffoldKey: widget.scaffoldKey,
                                          message:
                                              'File downloaded successfully',
                                        );
                                        /*Utils.showActionSnackBar(
                                                        context,
                                                        scaffoldKey,
                                                        'File downloaded successfully',
                                                        () async {
                                                      print(
                                                          'Open Btn clicked ttttt');
                                                      var result =
                                                          await OpenFile.open(
                                                              directory.path);

                                                      print(
                                                          "dataaaaa: ${result.message} ggg ${result.type}");
                                                    });*/
                                      }
                                    } else {
                                      await Utils.getStoragePermission(context);
                                      var isStoragePermitted =
                                          await Permission.storage.status;

                                      if (isStoragePermitted.isGranted) {
                                        File copiedFile =
                                            File('${ourDirectory!.path}.zip');

                                        Directory directory;

                                        if (Platform.isAndroid) {
                                          directory = Directory(
                                              "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                        } else {
                                          directory =
                                              await getApplicationDocumentsDirectory();
                                        }

                                        copiedFile.copy(directory.path);

                                        print(
                                            'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                        if (copiedFile.existsSync()) {
                                          Utils.showSnackBar(
                                            context,
                                            scaffoldKey: widget.scaffoldKey,
                                            message:
                                                'File downloaded successfully',
                                          );

                                          /*Utils.showActionSnackBar(
                                                          context,
                                                          scaffoldKey,
                                                          'File downloaded successfully',
                                                          () {
                                                        print(
                                                            'Open Btn clicked');
                                                        OpenFile.open(
                                                                directory.path)
                                                            .catchError(
                                                                (onError) {
                                                          print(onError);
                                                        });
                                                      });*/
                                        }
                                      }
                                    }
                                  },
                                  context: context,
                                  width: displayWidth(context) * 0.38,
                                  title: 'Download Trip')),
                        )
                      ],
                    )
                  : /*widget.tripList!.isEndTripClicked!
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      :*/
                  commonProvider.tripStatus
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: displayHeight(context) * 0.038,
                          child: CommonButtons.getActionButton(
                              buttonPrimaryColor: buttonBGColor.withOpacity(.7),
                              borderColor: buttonBGColor.withOpacity(.7),
                              fontSize: displayWidth(context) * 0.03,
                              onTap: () async {
                                widget.onTap!.call();

                                debugPrint(
                                    'TRIP STATUS ${commonProvider.tripStatus}');

                                // service.invoke('stopService');

                                /*onSave(
                                        file,
                                        context,
                                        widget.tripList!.id!,
                                        widget.tripList!.vesselId,
                                        widget.tripList!.vesselName,
                                        widget.tripList!.currentLoad);*/

                                //await tripIsRunningOrNot();
                              },
                              context: context,
                              width: displayWidth(context) * 0.8,
                              title: 'End Trip'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSave(File file, BuildContext context, String tripId, vesselId,
      vesselName, vesselWeight) async {
    pos.Position? locationData =
        await Utils.getLocationPermission(context, widget.scaffoldKey!);
    // await fetchDeviceInfo();

    //debugPrint('hello device details: ${deviceDetails!.toJson().toString()}');
    // debugPrint(" locationData!.latitude!.toString():${ locationData!.latitude!.toString()}");
    String latitude = locationData!.latitude.toString();
    String longitude = locationData.longitude.toString();

    debugPrint("current lod:$tripId");

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

    int? tripDuration = sharedPreferences!.getInt("tripDuration") ?? 1;
    int? tripDistance = sharedPreferences!.getInt("tripDistance") ?? 1;
    String? tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '1';

    String finalTripDuration =
        Utils.calculateTripDuration((tripDuration / 1000).toInt());
    String finalTripDistance = tripDistance.toStringAsFixed(2);
    Position? currentLocationData =
        await Utils.getLocationPermission(context, widget.scaffoldKey!);

    await _databaseService.updateTripStatus(
        1,
        file.path,
        DateTime.now().toUtc().toString(),
        json.encode(
            [currentLocationData!.latitude, currentLocationData.longitude]),
        finalTripDuration,
        finalTripDistance,
        tripSpeed.toString(),
        tripId);

    _databaseService.updateVesselDataWithDurationSpeedDistance(
        finalTripDuration, finalTripDistance, tripSpeed.toString(), vesselId!);
    //Navigator.pop(context);
  }

  Future<bool> vesselIsSyncOrNot(String vesselId) async {
    bool result = await _databaseService.getVesselIsSyncOrNot(vesselId);

    setState(() {
      vesselIsSync = result;
      print('Vessel isSync $vesselIsSync');
    });

    /*setState(() {
      isEndTripButton = tripIsRunning;
      isStartButton = !tripIsRunning;
    });*/
    return result;
  }

  startSensorFunctionality(Trip tripData) async {
    //fileName = '$fileIndex.csv';

    // flutterLocalNotificationsPlugin.cancel(9988);
    AndroidDeviceInfo androidDeviceInfo = await deviceDetails.androidInfo;

    var queryParameters;
    queryParameters = {
      "id": tripData.id,
      "load": tripData.currentLoad,
      "sensorInfo": [
        {"make": "qualicom", "name": "gps"}
      ],
      "deviceInfo": {
        "deviceId": androidDeviceInfo.id,
        "model": androidDeviceInfo.model,
        "version": androidDeviceInfo.version.release,
        "make": androidDeviceInfo.manufacturer,
        "board": androidDeviceInfo.board,
        "deviceType": Platform.isAndroid ? 'Android' : 'IOS'
      },
      "lat": tripData.startPosition,
      "long": tripData.endPosition,
      "vesselId": tripData.vesselId,
      "filePath": 'storage/emulated/0/Download/${widget.tripList!.id}.zip',
      "createdAt": tripData.createdAt,
      "updatedAt": tripData.updatedAt,
      //"userID": commonProvider.loginModel!.userId!
    };

    debugPrint('CREATE TRIP: $queryParameters');

    commonProvider
        .sendSensorInfo(
            context,
            commonProvider.loginModel!.token!,
            File('${tripData.filePath}'),
            queryParameters,
            tripData.id!,
            widget.scaffoldKey!)
        .then((value) async {
      if (value != null) {
        if (value.status!) {
          await cancelOnGoingProgressNotification(tripData.id!);

          setState(() {
            isTripUploaded = false;
          });
          print("widget.tripList!.id: ${widget.tripList!.id}");
          _databaseService.updateTripIsSyncStatus(1, tripData.id.toString());

          showSuccessNoti();

          widget.tripUploadedSuccessfully!.call();
        } else {
          setState(() {
            isTripUploaded = false;
          });
          showFailedNoti(tripData.id!);
        }
      } else {
        setState(() {
          isTripUploaded = false;
        });
        showFailedNoti(tripData.id!);
      }
    }).catchError((onError, s) {
      if (mounted) {
        setState(() {
          isTripUploaded = false;
        });
      }
      // showFailedNoti(tripData.id!);
      debugPrint('ON ERROR $onError \n $s');
    });
  }

  Future<void> cancelOnGoingProgressNotification(String id) async {
    //progressTimer!.cancel();
    flutterLocalNotificationsPlugin.cancel(9989);
    // setState(() {
    //   progress = 100;
    // });
    return;
  }

  showFailedNoti(String id) async {
    progressTimer!.cancel();
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: false);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(9987, id,
        'Failed to upload. Please try again', platformChannelSpecifics,
        payload: 'item x');
  }

  showSuccessNoti() async {
    // progressTimer!.cancel();
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            progress: 100,
            maxProgress: 100);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        9989, 'Trip uploaded successfully', '', platformChannelSpecifics,
        payload: 'item x');
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
                                      'Your carrier may charge for Data Usage to upload trip data do you want to proceed?',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                              /* SizedBox(
                                height: displayHeight(context) * 0.015,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                      'The vessel will be visible in your vessel list and you can record trips with it again',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.grey,
                                  textSize: displayWidth(context) * 0.036,
                                  textAlign: TextAlign.center),*/
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.grey)),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Cancel', context, primaryColor, () {
                                    Navigator.of(context).pop();
                                  },
                                      displayWidth(context) * 0.4,
                                      displayHeight(context) * 0.05,
                                      Colors.grey.shade400,
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      displayHeight(context) * 0.018,
                                      Colors.grey.shade400,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'OK', context, primaryColor, () async {
                                    setState(() {
                                      isTripUploaded = true;
                                    });
                                    setDialogState(() {
                                      uploadDataIfDataIsNotSync();
                                    });

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
                              ),
                            ),
                          ],
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

  uploadDataIfDataIsNotSync() async {
    await vesselIsSyncOrNot(widget.tripList!.vesselId.toString());
    debugPrint('VESSEL STATUS isSync $vesselIsSync');

    const int maxProgress = 10;
    progress = 0;

    /*progressTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      progress = progress + 100;
      //progress = timer.tick;
      int fileLength = 0;
      try {
        fileLength =
            File('storage/emulated/0/Download/${widget.tripList!.id}.zip')
                .lengthSync();
      } catch (e) {
        showFailedNoti(widget.tripList!.id!);
        setState(() {
          isTripUploaded = false;
        });
      }

      var value = progress / fileLength;

      finalProgress = value * 100;

      finalProgress = finalProgress > 100 ? 100 : finalProgress;

      if (finalProgress == 100) {
        progressTimer!.cancel();
      }

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('progress channel', 'progress channel',
              channelDescription: 'progress channel description',
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true,
              showProgress: true,
              ongoing: true,
              indeterminate: false,
              progress: finalProgress.toInt(),
              maxProgress: 100);
      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      flutterLocalNotificationsPlugin.show(
          9986,
          '${widget.tripList!.id} ${finalProgress.toStringAsFixed(0)}/100%',
          '${finalProgress.toStringAsFixed(0)}/100%',
          platformChannelSpecifics,
          payload: 'item x');
    });*/

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'progress channel',
      'progress channel',
      channelDescription: 'progress channel description',
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: false,
      ongoing: true,
      indeterminate: false,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        9989, 'Uploading vessel details...', '', platformChannelSpecifics,
        payload: 'item x');

    if (!vesselIsSync) {
      CreateVessel vesselData = await _databaseService
          .getVesselFromVesselID((widget.tripList!.vesselId.toString()));

      debugPrint('VESSEL DATA ${vesselData.id}');

      commonProvider.addVesselRequestModel = CreateVessel();
      commonProvider.addVesselRequestModel!.id = vesselData.id;
      commonProvider.addVesselRequestModel!.name = vesselData.name;
      commonProvider.addVesselRequestModel!.model = vesselData.model;
      commonProvider.addVesselRequestModel!.builderName =
          vesselData.builderName;
      commonProvider.addVesselRequestModel!.regNumber = vesselData.regNumber;
      commonProvider.addVesselRequestModel!.mMSI = vesselData.mMSI;
      commonProvider.addVesselRequestModel!.engineType = vesselData.engineType;
      commonProvider.addVesselRequestModel!.fuelCapacity =
          vesselData.fuelCapacity;
      commonProvider.addVesselRequestModel!.weight = vesselData.weight;
      commonProvider.addVesselRequestModel!.freeBoard = vesselData.freeBoard;
      commonProvider.addVesselRequestModel!.lengthOverall =
          vesselData.lengthOverall;
      commonProvider.addVesselRequestModel!.beam = vesselData.beam;
      commonProvider.addVesselRequestModel!.draft = vesselData.draft;
      commonProvider.addVesselRequestModel!.vesselSize = vesselData.vesselSize;
      commonProvider.addVesselRequestModel!.capacity = vesselData.capacity;
      commonProvider.addVesselRequestModel!.builtYear = vesselData.builtYear;
      commonProvider.addVesselRequestModel!.createdAt = vesselData.createdAt;
      commonProvider.addVesselRequestModel!.batteryCapacity =
          vesselData.batteryCapacity;
      //commonProvider.addVesselRequestModel!.imageURLs = vesselData.imageURLs!;

      if (vesselData.imageURLs!.isNotEmpty) {
        finalSelectedFiles.add(File(vesselData.imageURLs!));
        commonProvider.addVesselRequestModel!.selectedImages =
            finalSelectedFiles;

        debugPrint('VESSEL Data ${File(vesselData.imageURLs!)}');
      } else {
        commonProvider.addVesselRequestModel!.selectedImages = [];
      }

      commonProvider
          .addVessel(
              context,
              commonProvider.addVesselRequestModel,
              commonProvider.loginModel!.userId!,
              commonProvider.loginModel!.token!,
              widget.scaffoldKey!)
          .then((value) async {
        if (value != null) {
          if (value.status!) {
            // print('DATA');
            _databaseService.updateIsSyncStatus(
                1, widget.tripList!.vesselId.toString());

            /*setState(() {
              isTripUploaded = false;
            });*/

            startSensorFunctionality(widget.tripList!);
          } /* else if (value.statusCode == 400) {
            setState(() {
              isTripUploaded = false;
            });
          } */
          else {
            await cancelOnGoingProgressNotification(widget.tripList!.id!);
            showFailedNoti(widget.tripList!.id!);
            setState(() {
              isTripUploaded = false;
            });
          }
        } else {
          await cancelOnGoingProgressNotification(widget.tripList!.id!);
          showFailedNoti(widget.tripList!.id!);
          setState(() {
            isTripUploaded = false;
          });
        }
      });
    } else {
      setState(() {
        isTripUploaded = false;
      });
      startSensorFunctionality(widget.tripList!);
    }
  }

  Future<bool> tripIsRunningOrNot() async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      print('Trip is Running $tripIsRunning');
      setState(() {
        isTripEndedOrNot = false;
      });
    });

    /*setState(() {
      isEndTripButton = tripIsRunning;
      isStartButton = !tripIsRunning;
    });*/
    return result;
  }
}
