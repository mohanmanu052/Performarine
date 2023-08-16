import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/utils/urls.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/status_tage.dart';

class TripWidget extends StatefulWidget {
  final String? calledFrom;
  final VoidCallback? onTap;
  final VoidCallback? tripUploadedSuccessfully;
  final Function()? onTripEnded;
  final Trip? tripList;
  VoidCallback? isTripDeleted;
  final GlobalKey<ScaffoldState>? scaffoldKey;

   TripWidget(
      {super.key,
      this.calledFrom,
      this.tripList,
      this.onTap,
      this.tripUploadedSuccessfully,
      this.onTripEnded,
      this.scaffoldKey,
        this.isTripDeleted
      });

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  final DatabaseService _databaseService = DatabaseService();

  List<File?> finalSelectedFiles = [];

  late CommonProvider commonProvider;

  bool vesselIsSync = false,
      isTripUploaded = false,
      isTripEndedOrNot = false,
      tripIsRunning = false,
      tripIsUploading = false,
      isDeleteTripBtnClicked = false;
  late DeviceInfoPlugin deviceDetails;

  int progress = 0;
  Timer? progressTimer;
  double finalProgress = 0;

  List<CreateVessel> getVesselById = [];

  String page = "Trip_widget";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
    deviceDetails = DeviceInfoPlugin();

    Utils.customPrint("###### DATA ###### ${widget.tripList!.id}");
    CustomLogger().logWithFile(Level.info, "###### DATA ###### ${widget.tripList!.id} -> $page");

    tripIsRunningOrNot();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () async {
        getVesselById = await _databaseService
            .getVesselNameByID(widget.tripList!.vesselId.toString());

        if (!isTripUploaded) {
          /*var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripAnalyticsScreen(
                tripId: widget.tripList!.id,
                vesselId: getVesselById[0].id,
                tripIsRunningOrNot:
                    widget.tripList!.tripStatus == 0 ? true : false,
                calledFrom: widget.calledFrom,
              ),
            ),
          );*/

          /*var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTripAnalyticsScreen(
                tripId: widget.tripList!.id,
                vesselId: getVesselById[0].id,
                tripIsRunningOrNot: widget.tripList!.tripStatus == 0 ? true : false,
                calledFrom: widget.calledFrom,
                vessel: getVesselById[0],
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
          }*/
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, right: 5, top: 6),
        child: Card(
          elevation: 3,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            //width: size.width - 40,
            //height: 110,
            //padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: backgroundColor,
                boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 2)
            ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      commonText(
                          context: context,
                          text: 'Trip ID - #${widget.tripList?.id ?? ''}',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.022,
                          textAlign: TextAlign.start,
                          fontFamily: poppins),
                      widget.tripList?.tripStatus == 0
                          ? commonText(
                              context: context,
                              text:
                                  '${DateFormat('MM/dd/yyyy hh:mm').format(DateTime.parse(widget.tripList!.createdAt!))}',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.018,
                          fontFamily: poppins
                            )
                          : commonText(
                              context: context,
                              text:
                                  '${DateFormat('MM/dd/yyyy hh:mm').format(DateTime.parse(widget.tripList!.createdAt!))}  ${widget.tripList?.updatedAt != null ? '-${DateFormat('MM/dd/yyyy hh:mm').format(DateTime.parse(widget.tripList!.updatedAt!))}' : ''}',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.018,
                          fontFamily: poppins
                            ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left:10.0),
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
                    ),
                    CustomPaint(
                      painter: StatusTag(
                          color: widget.tripList?.isSync != 0
                              ? blueColor
                              : widget.tripList?.tripStatus != 0
                                  ? routeMapBtnColor
                                  : inProgressTrip),
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
                                fontFamily: poppins
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
                        ? Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                          child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    height: displayHeight(context) * 0.038,
                                    width: displayWidth(context) * .385,
                                    child: CommonButtons.getTextActionButton(
                                        buttonPrimaryColor: routeMapBtnColor,
                                        fontSize: displayWidth(context) * 0.026,
                                        onTap: () async {
                                          _launchURL();
                                        },
                                        context: context,
                                        width: displayWidth(context) * 0.38,
                                        title: 'Route Map')),
                                SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                    height: displayHeight(context) * 0.038,
                                    width: displayWidth(context) * .39,
                                    child: CommonButtons.getTextActionButton(
                                        buttonPrimaryColor: blueColor,
                                        fontSize: displayWidth(context) * 0.026,
                                        onTap: () async {
                                          getVesselById = await _databaseService
                                              .getVesselNameByID(widget
                                                  .tripList!.vesselId
                                                  .toString());

                                          Utils.customPrint(
                                              'VESSEL DATA ${getVesselById[0].imageURLs}');
                                          CustomLogger().logWithFile(Level.info, "VESSEL DATA ${getVesselById[0].imageURLs} -> $page");

                                          if (!isTripUploaded) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NewTripAnalyticsScreen(
                                                        tripId:
                                                            widget.tripList!.id,
                                                        vesselId:
                                                            getVesselById[0].id,
                                                        tripIsRunningOrNot: false,
                                                        calledFrom:
                                                            widget.calledFrom,
                                                      tripData: widget.tripList,
                                                        ),
                                              ),
                                            );
                                          }
                                        },
                                        context: context,
                                        width: displayWidth(context) * 0.38,
                                        title: 'Trip Analytics'))
                              ],
                            ),
                        )
                        : Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                          child: Row(
                              children: [
                                Expanded(
                                  child: widget.tripList?.isSync != 0
                                      ? SizedBox(
                                      height: displayHeight(context) * 0.038,
                                      child: CommonButtons
                                          .getTextActionButton(
                                          buttonPrimaryColor:
                                          blueColor,
                                          borderColor: buttonBGColor
                                              .withOpacity(.5),
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
                                          title: 'Download Trip Data'))
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
                                          .getTextActionButton(
                                        buttonPrimaryColor:
                                        uploadTripBtnColor,
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
                                            CustomLogger().logWithFile(Level.info, "Mobile -> $page");
                                            showDialogBox();
                                          } else if (connectivityResult ==
                                              ConnectivityResult
                                                  .wifi) {
                                            setState(() {
                                              isTripUploaded = true;
                                            });

                                            uploadDataIfDataIsNotSync();

                                            Utils.customPrint(
                                                'WIFI');
                                            CustomLogger().logWithFile(Level.info, "Wifi -> $page");
                                          }
                                        },
                                        context: context,
                                        width:
                                        displayWidth(context) *
                                            0.38,
                                        title: 'Upload trip Data ',)),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child: SizedBox(
                                      height: displayHeight(context) * 0.038,
                                      child:
                                          CommonButtons.getTextActionButton(
                                              buttonPrimaryColor: blueColor,
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
                                                CustomLogger().logWithFile(Level.info, "VESSEL DATA ${getVesselById[0].imageURLs} -> $page");

                                                if (!isTripUploaded) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          NewTripAnalyticsScreen(
                                                              tripId: widget
                                                                  .tripList!.id,
                                                              vesselId:
                                                                  getVesselById[0]
                                                                      .id,
                                                              tripIsRunningOrNot:
                                                                  false,
                                                              calledFrom: widget
                                                                  .calledFrom,
                                                            tripData: widget.tripList,
                                                            isTripDeleted: widget.isTripDeleted,
                                                              ),
                                                    ),
                                                  );
                                                }
                                              },

                                              context: context,
                                              width: displayWidth(context) * 0.38,
                                              title: 'Trip Analytics')),
                                ),
                              ],
                            ),
                        )
                    : commonProvider.tripStatus
                        ? Center(
                            child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                circularProgressColor),
                          ))
                        : Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                          child: SizedBox(
                              height: displayHeight(context) * 0.038,
                              child: CommonButtons.getTextActionButton(
                                  buttonPrimaryColor: endTripBtnColor,
                                  borderColor: endTripBtnColor,
                                  fontSize: displayWidth(context) * 0.03,
                                  onTap: () {
                                    widget.onTap!.call();

                                    Utils.customPrint(
                                        'TRIP STATUS ${commonProvider.tripStatus}');
                                    CustomLogger().logWithFile(Level.info, "TRIP STATUS ${commonProvider.tripStatus} -> $page");
                                  },
                                  context: context,
                                  width: displayWidth(context) * 0.8,
                                  title: 'End Trip')),
                        )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Will get Sync value of Vessel
  Future<bool> vesselIsSyncOrNot(String vesselId) async {
    bool result = await _databaseService.getVesselIsSyncOrNot(vesselId);

    setState(() {
      vesselIsSync = result;
      Utils.customPrint('Vessel isSync $vesselIsSync');
      CustomLogger().logWithFile(Level.info, "Vessel isSync $vesselIsSync -> $page");
    });

    return result;
  }

  /// TO Launch Route Map of the Trip
  _launchURL() async {
    final Uri url =
        Uri.parse('https://${Urls.baseUrl}/goeMaps/${widget.tripList!.id}');
    if (!await launchUrl(url)) {
      throw Exception(
          'Could not launch https://+"${Urls.baseUrl}/goeMaps/646651f3bc96c02b13879ac9');
    }
  }

  /// Send Data to SendSensor api
  startSensorFunctionality(Trip tripData) async {
    AndroidDeviceInfo? androidDeviceInfo;
    IosDeviceInfo? iosDeviceInfo;

    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceDetails.androidInfo;
    } else {
      iosDeviceInfo = await deviceDetails.iosInfo;
    }

    String? tripDuration = tripData.time ?? '00:00:00';
    String? tripDistance = tripData.distance ?? '1';
    String? tripSpeed = tripData.speed ?? '1';
    String? tripAvgSpeed = tripData.avgSpeed ?? '1';



    var startPosition = tripData.startPosition!.split(",");
    var endPosition = tripData.endPosition!.split(",");
    Utils.customPrint('START POSITION R ${tripData.distance}');
    CustomLogger().logWithFile(Level.info, "START POSITION R ${tripData.distance} -> $page");

    Directory tripDir = await getApplicationDocumentsDirectory();

    var queryParameters;
    queryParameters = {
      "id": tripData.id,
      "load": tripData.currentLoad,
      "sensorInfo": [
        {"make": "qualicom", "name": "gps"}
      ],
      "deviceInfo": {
        "deviceId": Platform.isAndroid ? androidDeviceInfo!.id : '',
        "model": Platform.isAndroid
            ? androidDeviceInfo!.model
            : iosDeviceInfo!.model,
        "version": Platform.isAndroid
            ? androidDeviceInfo!.version.release
            : iosDeviceInfo!.utsname.release,
        "make": Platform.isAndroid
            ? androidDeviceInfo!.manufacturer
            : iosDeviceInfo?.utsname.machine,
        "board": Platform.isAndroid
            ? androidDeviceInfo!.board
            : iosDeviceInfo!.utsname.machine,
        "deviceType": Platform.isAndroid ? 'Android' : 'IOS'
      },
      "startPosition": startPosition,
      "endPosition": endPosition,
      "vesselId": tripData.vesselId,
      "filePath": Platform.isAndroid
          ? '/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'
          : '${tripDir.path}/${tripData.id}.zip',
      "createdAt": tripData.createdAt,
      "duration": tripDuration,
      "distance": double.parse(tripDistance),
      "speed": double.parse(tripSpeed),
      "avgSpeed": double.parse(tripAvgSpeed),
    };

    Utils.customPrint('CREATE TRIP: $queryParameters');
    Utils.customPrint(
        'CREATE TRIP FILE PATH: ${'/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'}');
    CustomLogger().logWithFile(Level.info, "CREATE TRIP FILE PATH: ${'/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'}-> $page");

    commonProvider
        .sendSensorInfo(
            Get.context!,
            commonProvider.loginModel!.token!,
            File(Platform.isAndroid
                ? '/data/user/0/com.performarine.app/app_flutter/${tripData.id}.zip'
                : '${tripDir.path}/${tripData.id}.zip'),
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

          CustomLogger().logWithFile(Level.info, "widget.tripList!.id: ${widget.tripList!.id}-> $page");
          CustomLogger().logWithFile(Level.info, "UPLOAD TRIP STATUS CODE : ${value.statusCode}-> $page");

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
      Utils.customPrint('ON ERROR $onError \n $s');
      CustomLogger().logWithFile(Level.error, "ON ERROR $onError \n $s-> $page");
    });
  }

  /// To cancel Ongoing Notification
  Future<void> cancelOnGoingProgressNotification(String id) async {
    flutterLocalNotificationsPlugin.cancel(9989);

    return;
  }

  /// If Upload trip failed then to show the progress
  showFailedNoti(String id, [String? message]) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: false);
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    flutterLocalNotificationsPlugin.show(
        9987,
        id,
        message ?? 'Failed to upload. Please try again',
        platformChannelSpecifics,
        payload: 'item x');
  }

  /// if trip uploaded successfully
  showSuccessNoti() async {
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
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    flutterLocalNotificationsPlugin.show(
        9989, 'Trip uploaded successfully', '', platformChannelSpecifics,
        payload: 'item x');
  }

  /// If user using own internet then shown dialog box
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

  /// If data is not sync then using this function we can upload data
  /// First it will add vessel if its new and then trip
  uploadDataIfDataIsNotSync() async {
    Utils.customPrint('VESSEL STATUS DATA ${widget.tripList!.toJson()}');
    CustomLogger().logWithFile(Level.info, "VESSEL STATUS DATA ${widget.tripList!.toJson()} -> $page");
    commonProvider.updateTripUploadingStatus(true);
    await vesselIsSyncOrNot(widget.tripList!.vesselId.toString());
    Utils.customPrint('VESSEL STATUS isSync $vesselIsSync');
    CustomLogger().logWithFile(Level.info, "VESSEL STATUS isSync $vesselIsSync -> $page");

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
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    flutterLocalNotificationsPlugin.show(
        9989, 'Uploading vessel details...', '', platformChannelSpecifics,
        payload: 'item x');

    if (!vesselIsSync) {
      CreateVessel? vesselData = await _databaseService
          .getVesselFromVesselID((widget.tripList!.vesselId.toString()));

      Utils.customPrint('VESSEL DATA ${vesselData!.id}');
      CustomLogger().logWithFile(Level.info, "VESSEL DATA ${vesselData.id} -> $page");

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

      if (vesselData.imageURLs != null && vesselData.imageURLs!.isNotEmpty) {
        if (vesselData.imageURLs!.startsWith("https")) {
          commonProvider.addVesselRequestModel!.selectedImages = [];
        } else {
          finalSelectedFiles.add(File(vesselData.imageURLs!));
          commonProvider.addVesselRequestModel!.selectedImages =
              finalSelectedFiles;
        }

        Utils.customPrint('VESSEL Data ${File(vesselData.imageURLs!)}');
        CustomLogger().logWithFile(Level.info, "VESSEL Data ${File(vesselData.imageURLs!)} -> $page");
      } else {
        commonProvider.addVesselRequestModel!.selectedImages = [];
      }

      Utils.customPrint(
          'VESSEL IMAGE URL ${File(commonProvider.addVesselRequestModel!.selectedImages!.toString())}');
      CustomLogger().logWithFile(Level.info, "VESSEL IMAGE URL ${File(commonProvider.addVesselRequestModel!.selectedImages!.toString())}-> $page");

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

        Utils.customPrint("Add Vessel R ${value.status}");
            CustomLogger().logWithFile(Level.info, "Add Vessel R ${value.status}-> $page");

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

  /// To Check trip is Running or not
  Future<bool> tripIsRunningOrNot() async {
    bool result = await _databaseService.tripIsRunning();

    if (mounted) {
      setState(() {
        tripIsRunning = result;
        Utils.customPrint('Trip is Running $tripIsRunning');
        CustomLogger().logWithFile(Level.info, "Trip is Running $tripIsRunning-> $page");
        setState(() {
          isTripEndedOrNot = false;
        });
      });
    }

    return result;
  }

}
