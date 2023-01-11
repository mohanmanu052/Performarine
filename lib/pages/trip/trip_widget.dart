import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart'
    as pos;
import 'dart:developer' as developer;
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:location/location.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/date_formatter.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
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
  final Trip? tripList;

  const TripWidget(
      {super.key,
      //this.statusColor,
      //this.status,
      this.tripList,
      this.onTap
      //this.vesselName
      });

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  FlutterBackgroundService service = FlutterBackgroundService();

  List<File?> finalSelectedFiles = [];

  late CommonProvider commonProvider;

  bool vesselIsSync = false, isTripUploaded = false;
  late DeviceInfoPlugin deviceDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
    deviceDetails = DeviceInfoPlugin();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    // double height = 150;
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            children: [
              Container(
                height: 60,
                width: 6,
                color: const Color.fromARGB(255, 8, 25, 39),
              ),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                    color: /*widget.tripList?.endDate != null
                        ? buttonBGColor
                        : */
                        primaryColor,
                    shape: BoxShape.circle),
              ),
              Container(
                height: 60,
                width: 6,
                color: const Color.fromARGB(255, 8, 25, 39),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Stack(
            children: [
              Card(
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
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 2)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonText(
                          context: context,
                          text: 'Trip ID - ${widget.tripList?.id ?? ''}',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.022,
                          textAlign: TextAlign.start),

                      const SizedBox(
                        height: 2,
                      ),
                      commonText(
                          context: context,
                          text: '${widget.tripList!.vesselName}',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.034,
                          textAlign: TextAlign.start),
                      const SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text:
                              '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(widget.tripList!.createdAt!))}  ${widget.tripList?.updatedAt != null ? '-${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(widget.tripList!.updatedAt!))}' : ''}',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.020,
                          textAlign: TextAlign.start),

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
                        height: 8,
                      ),
                      widget.tripList?.tripStatus != 0
                          ? Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: widget.tripList?.isSync != 0
                                      ? SizedBox(
                                          height:
                                              displayHeight(context) * 0.038,
                                          child: CommonButtons
                                              .getRichTextActionButton(
                                                  buttonPrimaryColor:
                                                      buttonBGColor,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.026,
                                                  onTap: () {},
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    child: Icon(
                                                      Icons.analytics_outlined,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  context: context,
                                                  width: displayWidth(context) *
                                                      0.38,
                                                  title: 'Trip Analytics'))
                                      : SizedBox(
                                          height:
                                              displayHeight(context) * 0.038,
                                          child: isTripUploaded
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : CommonButtons
                                                  .getRichTextActionButton(
                                                      buttonPrimaryColor:
                                                          primaryColor,
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.026,
                                                      onTap: () async {
                                                        setState(() {
                                                          isTripUploaded = true;
                                                        });
                                                        var connectivityResult =
                                                            await (Connectivity()
                                                                .checkConnectivity());
                                                        if (connectivityResult ==
                                                            ConnectivityResult
                                                                .mobile) {
                                                          print('Mobile');
                                                          showDialogBox();
                                                        } else if (connectivityResult ==
                                                            ConnectivityResult
                                                                .wifi) {
                                                          uploadDataIfDataIsNotSync();
                                                          print('WIFI');
                                                        }
                                                      },
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Icon(
                                                          Icons
                                                              .cloud_upload_outlined,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      context: context,
                                                      width: displayWidth(
                                                              context) *
                                                          0.38,
                                                      title: 'Upload Trip')),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child: SizedBox(
                                      height: displayHeight(context) * 0.038,
                                      child:
                                          CommonButtons.getRichTextActionButton(
                                              buttonPrimaryColor:
                                                  buttonBGColor.withOpacity(.5),
                                              borderColor:
                                                  buttonBGColor.withOpacity(.5),
                                              icon: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Icon(
                                                  Icons
                                                      .download_for_offline_outlined,
                                                  size: 18,
                                                ),
                                              ),
                                              fontSize:
                                                  displayWidth(context) * 0.026,
                                              onTap: () async {
                                                debugPrint(
                                                    'DOWLOAD Started!!!');

                                                final androidInfo =
                                                    await DeviceInfoPlugin()
                                                        .androidInfo;

                                                var isStoragePermitted =
                                                    androidInfo.version.sdkInt >
                                                            32
                                                        ? await Permission
                                                            .photos.status
                                                        : await Permission
                                                            .storage.status;
                                                if (isStoragePermitted
                                                    .isGranted) {
                                                  //File copiedFile = File('${ourDirectory!.path}.zip');
                                                  File copiedFile = File(
                                                      '${ourDirectory!.path}/${widget.tripList!.id}.zip');

                                                  print(
                                                      'DIR PATH R ${ourDirectory!.path}');

                                                  Directory directory;

                                                  if (Platform.isAndroid) {
                                                    directory = Directory(
                                                        "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                                  } else {
                                                    directory =
                                                        await getApplicationDocumentsDirectory();
                                                  }

                                                  copiedFile
                                                      .copy(directory.path);

                                                  print(
                                                      'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                                  if (copiedFile.existsSync()) {
                                                    Utils.showSnackBar(
                                                      context,
                                                      scaffoldKey: scaffoldKey,
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
                                                  await Utils
                                                      .getStoragePermission(
                                                          context);
                                                  var isStoragePermitted =
                                                      await Permission
                                                          .storage.status;

                                                  if (isStoragePermitted
                                                      .isGranted) {
                                                    File copiedFile = File(
                                                        '${ourDirectory!.path}.zip');

                                                    Directory directory;

                                                    if (Platform.isAndroid) {
                                                      directory = Directory(
                                                          "storage/emulated/0/Download/${widget.tripList!.id}.zip");
                                                    } else {
                                                      directory =
                                                          await getApplicationDocumentsDirectory();
                                                    }

                                                    copiedFile
                                                        .copy(directory.path);

                                                    print(
                                                        'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                                    if (copiedFile
                                                        .existsSync()) {
                                                      Utils.showSnackBar(
                                                        context,
                                                        scaffoldKey:
                                                            scaffoldKey,
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
                                              width:
                                                  displayWidth(context) * 0.38,
                                              title: 'Download Trip')),
                                )
                              ],
                            )
                          : SizedBox(
                              height: displayHeight(context) * 0.038,
                              child: CommonButtons.getActionButton(
                                  buttonPrimaryColor:
                                      buttonBGColor.withOpacity(.7),
                                  borderColor: buttonBGColor.withOpacity(.7),
                                  fontSize: displayWidth(context) * 0.03,
                                  onTap: () async {
                                    widget.onTap!.call();

                                    // service.invoke('stopService');

                                    /*onSave(
                                        file,
                                        context,
                                        widget.tripList!.id!,
                                        widget.tripList!.vesselId,
                                        widget.tripList!.vesselName,
                                        widget.tripList!.currentLoad);*/
                                  },
                                  context: context,
                                  width: displayWidth(context) * 0.8,
                                  title: 'End Trip'))
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 3,
                child: CustomPaint(
                  painter: StatusTag(
                      color: widget.tripList?.updatedAt != null
                          ? buttonBGColor
                          : primaryColor),
                  child: Container(
                    margin: EdgeInsets.only(left: displayWidth(context) * 0.05),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: commonText(
                          context: context,
                          text: widget.tripList?.tripStatus != 0
                              ? "Completed"
                              : " Ongoing ",
                          fontWeight: FontWeight.w500,
                          textColor: Colors.white,
                          textSize: displayWidth(context) * 0.03,
                        ),
                      ),
                    ),
                  ),
                ),

                /*Container(
                  padding: const EdgeInsets.only(
                      right: 5, left: 20, top: 5, bottom: 5),
                  color:
                      statusColor ?? const Color.fromARGB(255, 19, 49, 73),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),*/
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onSave(File file, BuildContext context, String tripId, vesselId,
      vesselName, vesselWeight) async {
    pos.Position? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);
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

    await _databaseService.updateTripStatus(
        1, file.path, DateTime.now().toUtc().toString(), tripId);
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
      "lat": tripData.lat,
      "long": tripData.long,
      "vesselId": tripData.vesselId,
      "filePath": 'storage/emulated/0/Download/${widget.tripList!.id}.zip',
      "createdAt": tripData.createdAt,
      "updatedAt": tripData.updatedAt,
      //"userID": commonProvider.loginModel!.userId!
    };

    debugPrint('CREATE TRIP $queryParameters');

    commonProvider
        .sendSensorInfo(
            context,
            commonProvider.loginModel!.token!,
            File('storage/emulated/0/Download/${widget.tripList!.id}.zip'),
            queryParameters,
            scaffoldKey)
        .then((value) async {
      if (value != null) {
        if (value.status!) {
          //TODO
          setState(() {
            isTripUploaded = false;
          });
        }
      }
    }).catchError((onError) {
      debugPrint('ON ERROR $onError');
    });
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
                                      primaryColor,
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
    vesselIsSyncOrNot(widget.tripList!.vesselId.toString());
    debugPrint('VESSEL STATUS $vesselIsSync');

    if (!vesselIsSync) {
      CreateVessel vesselData = await _databaseService
          .getVesselFromVesselID((widget.tripList!.vesselId.toString()));

      debugPrint('VESSEL DATA ${vesselData.id}');

      commonProvider.addVesselRequestModel = CreateVessel();

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
      commonProvider.addVesselRequestModel!.selectedImages = finalSelectedFiles;

      finalSelectedFiles.add(File(vesselData.imageURLs!));

      debugPrint('VESSEL Data ${File(vesselData.imageURLs!)}');
      /*debugPrint(
          'VESSEL Data ${commonProvider.addVesselRequestModel!.imageURLs}');*/

      commonProvider
          .addVessel(
              context,
              commonProvider.addVesselRequestModel,
              commonProvider.loginModel!.userId!,
              commonProvider.loginModel!.token!,
              scaffoldKey)
          .then((value) {
        if (value != null) {
          if (value.status!) {
            print('DATA');
            _databaseService.updateIsSyncStatus(
                1, widget.tripList!.vesselId.toString());

            setState(() {
              isTripUploaded = false;
            });

            startSensorFunctionality(widget.tripList!);
          }
        }
      });
    } else {
      startSensorFunctionality(widget.tripList!);
    }
  }
}
