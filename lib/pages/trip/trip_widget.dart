import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/widgets/status_tage.dart';

class TripWidget extends StatefulWidget {
  final String? calledFrom;
  final VoidCallback? onTap;
  final VoidCallback? tripUploadedSuccessfully;
  final Function()? onTripEnded;
  final Trip? tripList;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const TripWidget(
      {super.key,
      this.calledFrom,
      this.tripList,
      this.onTap,
      this.tripUploadedSuccessfully,
      this.onTripEnded,
      this.scaffoldKey});

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  final DatabaseService _databaseService = DatabaseService();
  FlutterBackgroundService service = FlutterBackgroundService();

  List<File?> finalSelectedFiles = [];

  late CommonProvider commonProvider;

  bool vesselIsSync = false,
      isTripUploaded = false,
      isTripEndedOrNot = false,
      tripIsRunning = false,
      tripIsUploading = false;
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
    return InkWell(
      onTap: () async {
        getVesselById = await _databaseService
            .getVesselNameByID(widget.tripList!.vesselId.toString());

        Utils.customPrint('VESSEL DATA ${getVesselById[0].imageURLs}');
        Utils.customPrint('VESSEL DATA 1212 ${commonProvider.tripStatus}');

        if (!isTripUploaded) {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripAnalyticsScreen(
                tripId: widget.tripList!.id,
                vesselId: getVesselById[0].id,
                tripIsRunningOrNot:
                    widget.tripList!.tripStatus == 0 ? true : false,
                calledFrom: widget.calledFrom,
                // vessel: getVesselById[0]
              ),
            ),
          );

          if (result != null) {
            if (result) {
              widget.tripUploadedSuccessfully!.call();
              if (widget.onTripEnded != null) {
                widget.onTripEnded!.call();
              }
            }
          }
        }
      },
      child: Container(
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
                  BoxShadow(
                      color: Colors.black.withOpacity(0.09), blurRadius: 2)
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
                              : widget.tripList?.tripStatus != 0
                                  ? primaryColor
                                  : Color(0xFF41C1C8)),
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
                                  : widget.tripList?.tripStatus != 0
                                      ? "Pending Upload "
                                      : "In Progress",
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
                const SizedBox(
                  height: 12,
                ),
                widget.tripList?.tripStatus != 0
                    ? widget.tripList!.isCloud != 0
                        ? SizedBox(
                            height: displayHeight(context) * 0.038,
                            width: displayWidth(context),
                            child: CommonButtons.getRichTextActionButton(
                                buttonPrimaryColor: buttonBGColor,
                                fontSize: displayWidth(context) * 0.026,
                                onTap: () async {
                                  getVesselById =
                                      await _databaseService.getVesselNameByID(
                                          widget.tripList!.vesselId.toString());

                                  Utils.customPrint(
                                      'VESSEL DATA ${getVesselById[0].imageURLs}');

                                  if (!isTripUploaded) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TripAnalyticsScreen(
                                                tripId: widget.tripList!.id,
                                                vesselId: getVesselById[0].id,
                                                tripIsRunningOrNot: false,
                                                calledFrom: widget.calledFrom
                                                // vessel: getVesselById[0]
                                                ),
                                      ),
                                    );
                                  }
                                },
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.analytics_outlined,
                                    size: 18,
                                  ),
                                ),
                                context: context,
                                width: displayWidth(context) * 0.38,
                                title: 'Trip Analytics'))
                        : Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                    height: displayHeight(context) * 0.038,
                                    child:
                                        CommonButtons.getRichTextActionButton(
                                            buttonPrimaryColor: buttonBGColor,
                                            fontSize:
                                                displayWidth(context) * 0.026,
                                            onTap: () async {
                                              getVesselById =
                                                  await _databaseService
                                                      .getVesselNameByID(widget
                                                          .tripList!.vesselId
                                                          .toString());

                                              Utils.customPrint(
                                                  'VESSEL DATA ${getVesselById[0].imageURLs}');

                                              if (!isTripUploaded) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TripAnalyticsScreen(
                                                            tripId: widget
                                                                .tripList!.id,
                                                            vesselId:
                                                                getVesselById[0]
                                                                    .id,
                                                            tripIsRunningOrNot:
                                                                false,
                                                            calledFrom: widget
                                                                .calledFrom
                                                            // vessel: getVesselById[0]
                                                            ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Icon(
                                                Icons.analytics_outlined,
                                                size: 18,
                                              ),
                                            ),
                                            context: context,
                                            width: displayWidth(context) * 0.38,
                                            title: 'Trip Analytics')),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Expanded(
                                child: widget.tripList?.isSync != 0
                                    ? SizedBox(
                                        height: displayHeight(context) * 0.038,
                                        child: CommonButtons
                                            .getRichTextActionButton(
                                                buttonPrimaryColor:
                                                    buttonBGColor
                                                        .withOpacity(.5),
                                                borderColor: buttonBGColor
                                                    .withOpacity(.5),
                                                icon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8),
                                                  child: Icon(
                                                    Icons
                                                        .download_for_offline_outlined,
                                                    size: 18,
                                                  ),
                                                ),
                                                fontSize:
                                                    displayWidth(context) *
                                                        0.026,
                                                onTap: () async {
                                                  DownloadTrip().downloadTrip(
                                                      context,
                                                      widget.scaffoldKey!,
                                                      widget.tripList!.id!);
                                                },
                                                context: context,
                                                width: displayWidth(context) *
                                                    0.38,
                                                title: 'Download Trip'))
                                    : SizedBox(
                                        height: displayHeight(context) * 0.038,
                                        child: isTripUploaded
                                            ? Center(
                                                child: SizedBox(
                                                    height: 28,
                                                    width: 28,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              circularProgressColor),
                                                    )))
                                            : CommonButtons
                                                .getRichTextActionButton(
                                                    buttonPrimaryColor:
                                                        primaryColor,
                                                    fontSize:
                                                        displayWidth(context) *
                                                            0.026,
                                                    onTap: () async {
                                                      await Utils().check(
                                                          widget.scaffoldKey!);

                                                      var connectivityResult =
                                                          await (Connectivity()
                                                              .checkConnectivity());
                                                      if (connectivityResult ==
                                                          ConnectivityResult
                                                              .mobile) {
                                                        Utils.customPrint(
                                                            'Mobile');
                                                        showDialogBox();
                                                      } else if (connectivityResult ==
                                                          ConnectivityResult
                                                              .wifi) {
                                                        setState(() {
                                                          isTripUploaded = true;
                                                        });

                                                        // downloadTrip(true);

                                                        uploadDataIfDataIsNotSync();

                                                        Utils.customPrint(
                                                            'WIFI');
                                                      }
                                                    },
                                                    icon: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8),
                                                      child: Icon(
                                                        Icons
                                                            .cloud_upload_outlined,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    context: context,
                                                    width:
                                                        displayWidth(context) *
                                                            0.38,
                                                    title: 'Upload Trip')),
                              )
                            ],
                          )
                    : commonProvider.tripStatus
                        ? Center(
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                circularProgressColor),
                          ))
                        : SizedBox(
                            height: displayHeight(context) * 0.038,
                            child: CommonButtons.getActionButton(
                                buttonPrimaryColor:
                                    buttonBGColor.withOpacity(.7),
                                borderColor: buttonBGColor.withOpacity(.7),
                                fontSize: displayWidth(context) * 0.03,
                                onTap: () {
                                  widget.onTap!.call();

                                  Utils.customPrint(
                                      'TRIP STATUS ${commonProvider.tripStatus}');
                                },
                                context: context,
                                width: displayWidth(context) * 0.8,
                                title: 'End Trip'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> vesselIsSyncOrNot(String vesselId) async {
    bool result = await _databaseService.getVesselIsSyncOrNot(vesselId);

    setState(() {
      vesselIsSync = result;
      Utils.customPrint('Vessel isSync $vesselIsSync');
    });

    return result;
  }

  startSensorFunctionality(Trip tripData) async {
    //fileName = '$fileIndex.csv';

    // flutterLocalNotificationsPlugin.cancel(9988);
    AndroidDeviceInfo androidDeviceInfo = await deviceDetails.androidInfo;

    String? tripDuration =
        sharedPreferences!.getString("tripDuration") ?? '00:00:00';
    String? tripDistance = sharedPreferences!.getString("tripDistance") ?? '1';
    String? tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '1';
    String? tripAvgSpeed = sharedPreferences!.getString("tripAvgSpeed") ?? '1';

    var startPosition = tripData.startPosition!.split(",");
    var endPosition = tripData.endPosition!.split(",");
    Utils.customPrint('START POSITION 0 ${startPosition}');

    //'storage/emulated/0/Download/${widget.tripList!.id}.zip',
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
      "startPosition": startPosition,
      "endPosition": endPosition,
      "vesselId": tripData.vesselId,
      "filePath":
          '/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip',
      "createdAt": tripData.createdAt,
      "updatedAt": tripData.updatedAt,
      "duration": tripDuration,
      "distance": double.parse(tripDistance),
      "speed": double.parse(tripSpeed),
      "avgSpeed": double.parse(tripAvgSpeed),
      //"userID": commonProvider.loginModel!.userId!
    };

    Utils.customPrint('CREATE TRIP: $queryParameters');
    //Utils.customPrint('CREATE TRIP FILE PATH: ${tripData.filePath}');
    Utils.customPrint(
        'CREATE TRIP FILE PATH: ${'/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'}');

    commonProvider
        .sendSensorInfo(
            Get.context!,
            commonProvider.loginModel!.token!,
            File(
                '/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'),
            queryParameters,
            tripData.id!,
            widget.scaffoldKey!)
        .then((value) async {
      if (value != null) {
        commonProvider.updateTripUploadingStatus(false);
        if (value.status!) {
          await cancelOnGoingProgressNotification(tripData.id!);

          if (mounted) {
            setState(() {
              isTripUploaded = false;
            });
          }
          Utils.customPrint("widget.tripList!.id: ${widget.tripList!.id}");
          Utils.customPrint("UPLOAD TRIP STATUS CODE : ${value.statusCode}");
          _databaseService.updateTripIsSyncStatus(1, tripData.id.toString());

          showSuccessNoti();

          widget.tripUploadedSuccessfully!.call();
        } else {
          if (mounted) {
            setState(() {
              isTripUploaded = false;
            });
          }
          _databaseService.updateTripIsSyncStatus(0, tripData.id.toString());
          await cancelOnGoingProgressNotification(tripData.id!);
          showFailedNoti(tripData.id!, value.message);
        }
      } else {
        commonProvider.updateTripUploadingStatus(false);
        if (mounted) {
          setState(() {
            isTripUploaded = false;
          });
        }
        _databaseService.updateTripIsSyncStatus(0, tripData.id.toString());
        await cancelOnGoingProgressNotification(tripData.id!);
        showFailedNoti(tripData.id!);
      }
    }).catchError((onError, s) {
      if (mounted) {
        setState(() {
          isTripUploaded = false;
        });
      }
      // showFailedNoti(tripData.id!);
      Utils.customPrint('ON ERROR $onError \n $s');
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

  showFailedNoti(String id, [String? message]) async {
    // progressTimer!.cancel();
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
    flutterLocalNotificationsPlugin.show(
        9987,
        id,
        message ?? 'Failed to upload. Please try again',
        platformChannelSpecifics,
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
    commonProvider.updateTripUploadingStatus(true);
    await vesselIsSyncOrNot(widget.tripList!.vesselId.toString());
    Utils.customPrint('VESSEL STATUS isSync $vesselIsSync');

    const int maxProgress = 10;
    progress = 0;

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
      CreateVessel? vesselData = await _databaseService
          .getVesselFromVesselID((widget.tripList!.vesselId.toString()));

      Utils.customPrint('VESSEL DATA ${vesselData!.id}');

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
      commonProvider.addVesselRequestModel!.vesselStatus =
          vesselData.vesselStatus;
      commonProvider.addVesselRequestModel!.batteryCapacity =
          vesselData.batteryCapacity;
      //commonProvider.addVesselRequestModel!.imageURLs = vesselData.imageURLs!;

      if (vesselData.imageURLs != null && vesselData.imageURLs!.isNotEmpty) {
        if (vesselData.imageURLs!.startsWith("https")) {
          commonProvider.addVesselRequestModel!.selectedImages = [];
        } else {
          finalSelectedFiles.add(File(vesselData.imageURLs!));
          commonProvider.addVesselRequestModel!.selectedImages =
              finalSelectedFiles;
        }

        Utils.customPrint('VESSEL Data ${File(vesselData.imageURLs!)}');
      } else {
        commonProvider.addVesselRequestModel!.selectedImages = [];
      }

      Utils.customPrint(
          'VESSEL IMAGE URL ${File(commonProvider.addVesselRequestModel!.selectedImages!.toString())}');

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
            _databaseService.updateIsSyncStatus(
                1, widget.tripList!.vesselId.toString());

            startSensorFunctionality(widget.tripList!);
          } else {
            commonProvider.updateTripUploadingStatus(false);
            await cancelOnGoingProgressNotification(widget.tripList!.id!);
            showFailedNoti(widget.tripList!.id!);
            setState(() {
              isTripUploaded = false;
            });
          }
        } else {
          commonProvider.updateTripUploadingStatus(false);
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

    if (mounted) {
      setState(() {
        tripIsRunning = result;
        Utils.customPrint('Trip is Running $tripIsRunning');
        setState(() {
          isTripEndedOrNot = false;
        });
      });
    }

    return result;
  }

  /*downloadTrip(bool isuploadTrip) async {
    Utils.customPrint('DOWLOAD Started!!!');

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    var isStoragePermitted;
    if (androidInfo.version.sdkInt < 29) {
      isStoragePermitted = await Permission.storage.status;

      if (isStoragePermitted.isGranted) {
        //File copiedFile = File('${ourDirectory!.path}.zip');
        File copiedFile =
            File('${ourDirectory!.path}/${widget.tripList!.id}.zip');

        Utils.customPrint('DIR PATH R ${ourDirectory!.path}');

        Directory directory;

        if (Platform.isAndroid) {
          directory = Directory(
              "storage/emulated/0/Download/${widget.tripList!.id}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);

        Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

        if (copiedFile.existsSync()) {
          if (!isuploadTrip) {
            Utils.showSnackBar(
              context,
              scaffoldKey: widget.scaffoldKey,
              message: 'File downloaded successfully',
            );
          }
        }
      } else {
        await Utils.getStoragePermission(context);
        var isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          File copiedFile = File('${ourDirectory!.path}.zip');

          Directory directory;

          if (Platform.isAndroid) {
            directory = Directory(
                "storage/emulated/0/Download/${widget.tripList!.id}.zip");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          copiedFile.copy(directory.path);

          Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

          if (copiedFile.existsSync()) {
            Utils.showSnackBar(
              context,
              scaffoldKey: widget.scaffoldKey,
              message: 'File downloaded successfully',
            );
          }
        }
      }
    } else {
      //File copiedFile = File('${ourDirectory!.path}.zip');
      File copiedFile =
          File('${ourDirectory!.path}/${widget.tripList!.id}.zip');

      Utils.customPrint('DIR PATH R ${ourDirectory!.path}');

      Directory directory;

      if (Platform.isAndroid) {
        directory =
            Directory("storage/emulated/0/Download/${widget.tripList!.id}.zip");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      copiedFile.copy(directory.path);

      Utils.customPrint('DOES FILE EXIST: ${copiedFile.existsSync()}');

      if (copiedFile.existsSync()) {
        if (!isuploadTrip) {
          Utils.showSnackBar(
            context,
            scaffoldKey: widget.scaffoldKey,
            message: 'File downloaded successfully',
          );
        }
      }
    }
  }*/
}
