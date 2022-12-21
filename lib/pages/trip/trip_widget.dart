import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:location/location.dart';
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
import 'package:performarine/services/database_service.dart';

import '../../common_widgets/widgets/status_tage.dart';

class TripWidget extends StatefulWidget {
  //final Color? statusColor;
  //final String? status;
  //final String? vesselName;
  final Trip? tripList;

  const TripWidget({
    super.key,
    //this.statusColor,
    //this.status,
    this.tripList,
    //this.vesselName
  });

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  FlutterBackgroundService service = FlutterBackgroundService();

  @override
  Widget build(BuildContext context) {
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
                                          child: CommonButtons
                                              .getRichTextActionButton(
                                                  buttonPrimaryColor:
                                                      primaryColor,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.026,
                                                  onTap: () {},
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
                                                  width: displayWidth(context) *
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
                                              onTap: () {},
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
                                    bool isServiceRunning =
                                        await service.isRunning();

                                    print(
                                        'IS SERVICE RUNNING: $isServiceRunning');

                                    try {
                                      service.invoke('stopService');
                                      // instan.stopSelf();
                                    } on Exception catch (e) {
                                      print('SERVICE STOP BG EXE: $e');
                                    }

                                    File? zipFile;
                                    if (timer != null) timer!.cancel();
                                    print(
                                        'TIMER STOPPED ${ourDirectory!.path}/${widget.tripList!.id}');
                                    final dataDir = Directory(
                                        '${ourDirectory!.path}/${widget.tripList!.id}');

                                    try {
                                      zipFile = File(
                                          '${ourDirectory!.path}/${widget.tripList!.id}.zip');

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

                                    await _databaseService.updateTripStatus(
                                        1, file.path, widget.tripList!.id!);

                                    sharedPreferences!.remove('trip_data');

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
    LocationData? locationData =
        await Utils.getLocationPermission(context, scaffoldKey);
    // await fetchDeviceInfo();

    //debugPrint('hello device details: ${deviceDetails!.toJson().toString()}');
    // debugPrint(" locationData!.latitude!.toString():${ locationData!.latitude!.toString()}");
    String latitude = locationData!.latitude!.toString();
    String longitude = locationData.longitude!.toString();

    debugPrint("current lod:$tripId");

    /*await _databaseService.insertTrip(Trip(
        id: tripId,
        vesselId: vesselId,
        vesselName: vesselName,
        currentLoad: vesselWeight,
        filePath: file.path,
        isSync: 0,
        tripStatus: 0,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        lat: latitude,
        long: longitude,
        deviceInfo: deviceDetails!.toJson().toString()));*/

    await _databaseService.updateTripStatus(1, file.path, tripId);
    //Navigator.pop(context);
  }
}
