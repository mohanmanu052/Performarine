import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/status_tage.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../pages/bottom_navigation.dart';
import 'log_level.dart';

//custom text widget
Widget commonText(
    {String? text,
    BuildContext? context,
    double? textSize,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign? textAlign = TextAlign.center,
    TextDecoration textDecoration = TextDecoration.none,String fontFamily = outfit
    }) {
  return Text(
    text ?? '',
    textAlign: textAlign!,
    textScaleFactor: 1,
    style: TextStyle(
        fontSize: textSize,
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        decoration: textDecoration),
    overflow: TextOverflow.clip,
    softWrap: true,
  );
}

//select images from gallery
Widget? selectImage(
  context,
  Color buttonPrimaryColor,
  Function(List<File?>) onSelectImage,
) {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return Wrap(
              children: <Widget>[
                const ListTile(
                  title: Text(
                    'Choose Files',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                    dense: true,
                    horizontalTitleGap: 0.5,
                    leading: Icon(
                      Icons.photo_album,
                      color: buttonPrimaryColor,
                    ),
                    title: const Text(
                      'Gallery',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      List<File?>? list = [];

                      // list = await Utils.pickFileFromGallery();
                      list = await Utils.pickImages();

                      onSelectImage(list);
                    }),
                ListTile(
                    dense: true,
                    horizontalTitleGap: 0.5,
                    leading: Icon(
                      Icons.camera_enhance,
                      color: buttonPrimaryColor,
                    ),
                    title: const Text(
                      'Camera',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    onTap: () async {
                      bool isCameraPermissionGranted =
                          await Permission.camera.isGranted;

                      Utils.customPrint(
                          ' CAM PERMISSION $isCameraPermissionGranted');
                      CustomLogger().logWithFile(Level.warning, "CAM PERMISSION $isCameraPermissionGranted  while selecting image");

                      if (!isCameraPermissionGranted) {
                        await Utils.getStoragePermission(
                            context, Permission.camera);
                        bool isCameraPermissionGranted =
                            await Permission.camera.isGranted;

                        if (isCameraPermissionGranted) {
                          Navigator.pop(context);
                          List<File> list = await Utils.pickCameraImages();
                          onSelectImage(list);
                        }
                      } else {
                        Navigator.pop(context);
                        List<File> list = await Utils.pickCameraImages();
                        onSelectImage(list);
                      }
                    }),
              ],
            );
          },
        );
      });
}


// Dashboard rich text on vesselSingleViewCard
Widget dashboardRichText(
    {String? modelName,
    String? builderName,
    BuildContext? context,
    Color? color,}) {

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Flexible(
        child: Text(
          modelName!,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: displayWidth(context!) * 0.034,
            color: color,
            fontFamily: outfit,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
      ),
      SizedBox(
        width: displayWidth(context) * 0.02,
      ),
      Container(
        height: displayHeight(context) * 0.02,
        color: Colors.grey,
        width: displayWidth(context) * 0.0045,
      ),
      SizedBox(
        width: displayWidth(context) * 0.02,
      ),
      Flexible(
        child: Text(
          builderName!,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: displayWidth(context) * 0.034,
            color: color,
            fontFamily: outfit,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
      ),
    ],
  );
}


Widget vesselSingleViewRichText(
    {String? capacity,
      String? built,
      String regNo = '',
      BuildContext? context,
      Color? color,}) {

  Utils.customPrint("EXPANSION CARD ${regNo}");

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Flexible(
        child: Column(
          children: [

            Text(
              '${capacity!}CC',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: displayWidth(context!) * 0.038,
                color: color,
                fontFamily: outfit,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),

            Text(
              'Capacity',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: displayWidth(context) * 0.03,
                color: Colors.black87,
                fontFamily: poppins,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
          ],
        ),
      ),
      SizedBox(
        width: displayWidth(context) * 0.02,
      ),
      Container(
        height: displayHeight(context) * 0.03,
        color: Colors.grey,
        width: displayWidth(context) * 0.0045,
      ),
      SizedBox(
        width: displayWidth(context) * 0.025,
      ),
      Flexible(
        child: Column(
          children: [
            Text(
              built!,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: displayWidth(context) * 0.038,
                color: color,
                fontFamily: outfit,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
            Text(
              'Built',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: displayWidth(context) * 0.03,
                color: Colors.black87,
                fontFamily: poppins,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
          ],
        ),
      ),

       regNo != null && regNo != ''
          ? Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: displayWidth(context) * 0.025,
          ),
          Container(
            height: displayHeight(context) * 0.03,
            color: Colors.grey,
            width: displayWidth(context) * 0.0045,
          ),
          SizedBox(
            width: displayWidth(context) * 0.02,
          ),
        ],
      )
          : SizedBox(),

      regNo != null && regNo != ''
          ? Flexible(
        child: Column(
          children: [
            Text(
              regNo,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: displayWidth(context) * 0.038,
                color: color,
                fontFamily: outfit,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),

            Text(
              'Registration Number',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: displayWidth(context) * 0.03,
                color: Colors.black87,
                fontFamily: poppins,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
          ],
        ),
      )
          : SizedBox(),
    ],
  );
}


// Vessel single view card
Widget vesselSingleViewCard(BuildContext context, CreateVessel vesselData,
    Function(CreateVessel) onTap, GlobalKey<ScaffoldState> scaffoldKey,
    {bool isTripIsRunning = false}) {
  Utils.customPrint("IMAGE FROM HOME SINGLE WIDGET ${vesselData.imageURLs}");
  CustomLogger().logWithFile(Level.info, "IMAGE FROM HOME SINGLE WIDGET ${vesselData.imageURLs}");

  return GestureDetector(
    onTap: () {
      onTap(vesselData);
    },
    child: Card(
      //color: Colors.black,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: [
          SizedBox(
            width: displayWidth(context),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: vesselData.imageURLs == null ||
                        vesselData.imageURLs!.isEmpty ||
                        vesselData.imageURLs == 'string' ||
                        vesselData.imageURLs == ''
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Center(
                              child: Container(
                               // height: displayHeight(context) * 0.22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  //color: Colors.white,
                                ),
                                child: Image.asset(
                                  'assets/images/vessel_default_img.png',
                                  width: displayWidth(context) * 0.65,
                                  height: displayHeight(context) * 0.24,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: displayHeight(context) * 0.14,
                                width: displayWidth(context),
                                padding: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 50,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 50))
                                ]),
                              ))
                        ],
                      )
                    : Stack(
                        children: [
                          //Image.memory(bytes)
                          Image.file(
                            File(vesselData.imageURLs!),
                            fit: BoxFit.cover,
                            height: displayHeight(context) * 0.24,
                            width: displayWidth(context),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: displayHeight(context) * 0.14,
                                width: displayWidth(context),
                                padding: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 50,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 50))
                                ]),
                              ))
                        ],
                      )),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                 isTripIsRunning
                        ? CustomPaint(
                          painter: StatusTag(color: Color(0XFFFDBF21)),
                          child: Container(
                            margin: EdgeInsets.only(
                                left: displayWidth(context) * 0.05),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: commonText(
                                  context: context,
                                  text: "In Progress",
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                  textSize: displayWidth(context) * 0.03,
                                  fontFamily: poppins
                                ),
                              ),
                            ),
                          ),
                        )
                        : SizedBox(),

                Container(
                  padding: EdgeInsets.only(right: 10, top: 5),
                  //width: displayWidth(context) * 0.28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      vesselData.engineType!.isEmpty
                          ? const SizedBox()
                          : vesselData.engineType!.toLowerCase() ==
                          'combustion'
                          ? vesselData.fuelCapacity == null
                          ? const SizedBox()
                          : Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/fuel.png',
                                width: displayWidth(context) *
                                    0.045,
                                color: backgroundColor,
                              ),
                              SizedBox(
                                width: displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                  '${vesselData.fuelCapacity!}gal'
                                      .toString(),
                                  fontWeight: FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize:
                                  displayWidth(context) *
                                      0.03,
                                  textAlign: TextAlign.start,
                                  fontFamily: poppins),
                            ],
                          ),
                          SizedBox(
                            height:
                            displayHeight(context) * 0.005,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/combustion_engine.png',
                                width: displayWidth(context) * 0.045,
                                color: backgroundColor,
                              ),
                              SizedBox(
                                width: displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text: vesselData.engineType!,
                                  fontWeight: FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize:
                                  displayWidth(context) *
                                      0.03,
                                  textAlign: TextAlign.start),
                            ],
                          )
                        ],
                      )
                          : vesselData.engineType!.toLowerCase() ==
                          'electric'
                          ? vesselData.batteryCapacity == null
                          ? const SizedBox()
                          : Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin:
                                  const EdgeInsets.only(
                                      left: 4),
                                  child: Image.asset(
                                    'assets/images/battery.png',
                                    width: displayWidth(
                                        context) *
                                        0.027,
                                    color: backgroundColor,
                                  )),
                              SizedBox(
                                width:
                                displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                  ' ${vesselData.batteryCapacity!} kw'
                                      .toString(),
                                  fontWeight:
                                  FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize: displayWidth(
                                      context) *
                                      0.03,
                                  textAlign:
                                  TextAlign.start, fontFamily: poppins),
                            ],
                          ),
                          SizedBox(
                            height: displayHeight(context) *
                                0.005,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/electric_engine.png',
                                width:
                                displayWidth(context) *
                                    0.045,
                                color: backgroundColor,
                              ),
                              SizedBox(
                                width:
                                displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text: vesselData
                                      .engineType!,
                                  fontWeight:
                                  FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize: displayWidth(
                                      context) *
                                      0.03,
                                  textAlign:
                                  TextAlign.start,
                                  fontFamily: poppins),
                            ],
                          )
                        ],
                      )
                          : Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/fuel.png',
                                width: displayWidth(context) *
                                    0.045,
                                color: backgroundColor,
                              ),
                              SizedBox(
                                width: displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text: vesselData
                                      .fuelCapacity ==
                                      null
                                      ? '-'
                                      : '${vesselData.fuelCapacity!}gal'
                                      .toString(),
                                  fontWeight: FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize:
                                  displayWidth(context) *
                                      0.03,
                                  textAlign: TextAlign.start,
                                  fontFamily: poppins),
                            ],
                          ),
                          SizedBox(
                            height:
                            displayHeight(context) * 0.005,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 4),
                                  child: Image.asset(
                                    'assets/images/battery.png',
                                    width:
                                    displayWidth(context) *
                                        0.027,
                                    color: backgroundColor,
                                  )),
                              SizedBox(
                                width: displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                  ' ${vesselData.batteryCapacity!} kw'
                                      .toString(),
                                  fontWeight: FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize:
                                  displayWidth(context) *
                                      0.03,
                                  textAlign: TextAlign.start,
                                  fontFamily: poppins),
                            ],
                          ),
                          SizedBox(
                            height:
                            displayHeight(context) * 0.005,
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/hybrid_engine.png',
                                width: displayWidth(context) *
                                    0.045,
                                color: backgroundColor,
                              ),
                              SizedBox(
                                width: displayWidth(context) *
                                    0.02,
                              ),
                              commonText(
                                  context: context,
                                  text: vesselData.engineType!,
                                  fontWeight: FontWeight.w500,
                                  textColor: backgroundColor,
                                  textSize:
                                  displayWidth(context) *
                                      0.03,
                                  textAlign: TextAlign.start,fontFamily: poppins),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Container(
              width: displayWidth(context),
              //color: Colors.red,
              margin: const EdgeInsets.only(left: 8, right: 0, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vesselData.name == "" ? '-' : vesselData.name!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.045,
                            color: Colors.white,
                            fontFamily: outfit,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 2,
                        ),
                        /*dashboardRichText(
                            modelName: vesselData.model,
                            builderName: vesselData.builderName,
                            context: context,
                            color: Colors.white.withOpacity(0.8))*/
                      ],
                    ),
                  ),
                  SizedBox(
                    width: displayWidth(context) * 0.04,
                  ),
                  vesselData.vesselStatus == 0
                      ? Container(
                    margin: EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Card(
                      color: primaryColor,
                      elevation: 6,
                      shadowColor: Colors.black,
                      child: Center(
                        child: CommonButtons.getAcceptButton(
                            'Unretire', context, endTripBtnColor, () async {
                          showDialogBox(context, vesselData, scaffoldKey);
                        },
                            displayWidth(context) * 0.18,
                            displayHeight(context) * 0.04,
                            primaryColor,
                            Colors.white,
                            displayHeight(context) * 0.014,
                            endTripBtnColor,
                            '',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                      : CommonButtons.getActionButton(
                      title: 'View Details',
                      context: context,
                      fontSize: displayWidth(context) * 0.03,
                      textColor: Colors.white,
                      buttonPrimaryColor: blueColor,
                      borderColor: blueColor,
                      width: displayWidth(context) * 0.26,
                      height: displayHeight(context) * 0.045,
                      onTap: () async {
                        onTap(vesselData);
                      }),
                  SizedBox(
                    width: displayWidth(context) * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Vessel single view card
Widget OldVesselSingleViewCard(BuildContext context, CreateVessel vesselData,
    Function(CreateVessel) onTap, GlobalKey<ScaffoldState> scaffoldKey,
    {bool isTripIsRunning = false}) {
  Utils.customPrint("IMAGE FROM HOME SINGLE WIDGET ${vesselData.imageURLs}");
  CustomLogger().logWithFile(Level.info, "IMAGE FROM HOME SINGLE WIDGET ${vesselData.imageURLs}");

  return GestureDetector(
    onTap: () {
      onTap(vesselData);
    },
    child: Card(
      //color: Colors.black,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: [
          SizedBox(
            width: displayWidth(context),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: vesselData.imageURLs == null ||
                    vesselData.imageURLs!.isEmpty ||
                    vesselData.imageURLs == 'string' ||
                    vesselData.imageURLs == ''
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        //height: displayHeight(context) * 0.22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.white,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/vessel_default_img.png',
                            height: displayHeight(context) * 0.24,
                            width: displayWidth(context) * 0.65,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: displayHeight(context) * 0.14,
                          width: displayWidth(context),
                          padding: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 50,
                                spreadRadius: 5,
                                offset: const Offset(0, 50))
                          ]),
                        ))
                  ],
                )
                    : Stack(
                  children: [
                    //Image.memory(bytes)
                    Image.file(
                      File(vesselData.imageURLs!),
                      fit: BoxFit.cover,
                      height: displayHeight(context) * 0.24,
                      width: displayWidth(context),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: displayHeight(context) * 0.14,
                          width: displayWidth(context),
                          padding: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 50,
                                spreadRadius: 5,
                                offset: const Offset(0, 50))
                          ]),
                        ))
                  ],
                )),
          ),
          vesselData.vesselStatus == 0
              ? Positioned(
            top: 5,
            right: 10,
            child: Container(
              margin: EdgeInsets.only(
                top: 8.0,
              ),
              child: Card(
                color: primaryColor,
                elevation: 6,
                shadowColor: Colors.black,
                child: Center(
                  child: CommonButtons.getAcceptButton(
                      'Unretire', context, buttonBGColor, () async {
                    showDialogBox(context, vesselData, scaffoldKey);
                  },
                      displayWidth(context) * 0.18,
                      displayHeight(context) * 0.04,
                      primaryColor,
                      Colors.white,
                      displayHeight(context) * 0.014,
                      buttonBGColor,
                      '',
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
              : isTripIsRunning
              ? Positioned(
            top: 15,
            right: 0,
            child: CustomPaint(
              painter: StatusTag(color: Color(0XFF41C1C8)),
              child: Container(
                margin: EdgeInsets.only(
                    left: displayWidth(context) * 0.05),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: commonText(
                      context: context,
                      text: "In Progress",
                      fontWeight: FontWeight.w500,
                      textColor: Colors.white,
                      textSize: displayWidth(context) * 0.03,
                    ),
                  ),
                ),
              ),
            ),
          )
              : SizedBox(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: displayWidth(context),
              //color: Colors.red,
              margin: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vesselData.name == "" ? '-' : vesselData.name!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.045,
                            color: Colors.white,
                            fontFamily: poppins,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 2,
                        ),
                        dashboardRichText(
                            modelName: vesselData.model,
                            builderName: vesselData.builderName,
                            context: context,
                            color: Colors.white.withOpacity(0.8))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: displayWidth(context) * 0.04,
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    //width: displayWidth(context) * 0.28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        vesselData.engineType!.isEmpty
                            ? const SizedBox()
                            : vesselData.engineType!.toLowerCase() ==
                            'combustion'
                            ? vesselData.fuelCapacity == null
                            ? const SizedBox()
                            : Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/fuel.png',
                                  width: displayWidth(context) *
                                      0.045,
                                ),
                                SizedBox(
                                  width: displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text:
                                    '${vesselData.fuelCapacity!}gal'
                                        .toString(),
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize:
                                    displayWidth(context) *
                                        0.03,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              height:
                              displayHeight(context) * 0.005,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/combustion_engine.png',
                                  width: displayWidth(context) *
                                      0.045,
                                ),
                                SizedBox(
                                  width: displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData.engineType!,
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize:
                                    displayWidth(context) *
                                        0.03,
                                    textAlign: TextAlign.start),
                              ],
                            )
                          ],
                        )
                            : vesselData.engineType!.toLowerCase() ==
                            'electric'
                            ? vesselData.batteryCapacity == null
                            ? const SizedBox()
                            : Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                    const EdgeInsets.only(
                                        left: 4),
                                    child: Image.asset(
                                      'assets/images/battery.png',
                                      width: displayWidth(
                                          context) *
                                          0.027,
                                    )),
                                SizedBox(
                                  width:
                                  displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text:
                                    ' ${vesselData.batteryCapacity!} kw'
                                        .toString(),
                                    fontWeight:
                                    FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize: displayWidth(
                                        context) *
                                        0.03,
                                    textAlign:
                                    TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              height: displayHeight(context) *
                                  0.005,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/electric_engine.png',
                                  width:
                                  displayWidth(context) *
                                      0.045,
                                ),
                                SizedBox(
                                  width:
                                  displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData
                                        .engineType!,
                                    fontWeight:
                                    FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize: displayWidth(
                                        context) *
                                        0.03,
                                    textAlign:
                                    TextAlign.start),
                              ],
                            )
                          ],
                        )
                            : Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/fuel.png',
                                  width: displayWidth(context) *
                                      0.045,
                                ),
                                SizedBox(
                                  width: displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData
                                        .fuelCapacity ==
                                        null
                                        ? '-'
                                        : '${vesselData.fuelCapacity!}gal'
                                        .toString(),
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize:
                                    displayWidth(context) *
                                        0.03,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              height:
                              displayHeight(context) * 0.005,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(
                                        left: 4),
                                    child: Image.asset(
                                      'assets/images/battery.png',
                                      width:
                                      displayWidth(context) *
                                          0.027,
                                    )),
                                SizedBox(
                                  width: displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text:
                                    ' ${vesselData.batteryCapacity!} kw'
                                        .toString(),
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize:
                                    displayWidth(context) *
                                        0.03,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              height:
                              displayHeight(context) * 0.005,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/hybrid_engine.png',
                                  width: displayWidth(context) *
                                      0.045,
                                ),
                                SizedBox(
                                  width: displayWidth(context) *
                                      0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData.engineType!,
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.white,
                                    textSize:
                                    displayWidth(context) *
                                        0.03,
                                    textAlign: TextAlign.start),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// To show dialog box
showDialogBox(BuildContext context, CreateVessel vesselData,
    GlobalKey<ScaffoldState> scaffoldKey) {
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
                height: displayHeight(context) * 0.45,
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
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            //color: Color(0xfff2fffb),
                            child: Image.asset(
                              'assets/images/boat.gif',
                              height: displayHeight(context) * 0.1,
                              width: displayWidth(context),
                              fit: BoxFit.contain,
                            ),
                          )),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: Column(
                          children: [
                            commonText(
                                context: context,
                                text: 'Do you want to unretire the vessel?',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.042,
                                textAlign: TextAlign.center),
                            SizedBox(
                              height: displayHeight(context) * 0.015,
                            ),
                            commonText(
                                context: context,
                                text:
                                    'The vessel will be visible in your vessel list and you can record trips with it again',
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black54,
                                textSize: displayWidth(context) * 0.036,
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      Column(
                        children: [
                          Container(
                          margin: EdgeInsets.only(
                              left: 15,
                              right: 15
                          ),
                          child: Center(
                            child: CommonButtons.getAcceptButton(
                                'Confirm Unretire', context, endTripBtnColor, () async {
                              DatabaseService()
                                  .updateIsSyncStatus(0, vesselData.id!);
                              await DatabaseService()
                                  .updateVesselStatus(1, vesselData.id!)
                                  .then((value) {
                                Utils.showSnackBar(context,
                                    scaffoldKey: scaffoldKey,
                                    message:
                                    'Vessel unretired successfully.');
                                Navigator.of(dialogContext).pop();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BottomNavigation(),
                                    ),
                                    ModalRoute.withName(""));
                              });
                            },
                                displayWidth(context) ,
                                displayHeight(context) * 0.05,
                                primaryColor,
                                Colors.white,
                                displayHeight(context) * 0.02,
                                endTripBtnColor,
                                '',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: Center(
                              child: CommonButtons.getAcceptButton(
                                  'Cancel', context, Colors.transparent, () {
                                Navigator.of(context).pop();
                              },
                                  displayWidth(context) * 0.4,
                                  displayHeight(context) * 0.05,
                                  Colors.grey.shade400,
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : blueColor,
                                  displayHeight(context) * 0.018,
                                  Colors.transparent,
                                  '',
                                  fontWeight: FontWeight.w500),
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

//Widget for vessel Analytics on vessel analytics screen
Widget vesselAnalytics(BuildContext context, String duration, String distance,
    String currentSpeed, String avgSpeed, bool isTripIsRunning) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0XFFE4F5F5)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: duration,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Trips Duration',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0XFFE4F5F5)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '$distance $nauticalMile',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Distance',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        isTripIsRunning
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0XFFE4F5F5)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            commonText(
                                context: context,
                                text: '$currentSpeed $knot',
                                fontWeight: FontWeight.w600,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.044,
                                textAlign: TextAlign.start),
                            SizedBox(
                              height: 4,
                            ),
                            commonText(
                                context: context,
                                text: 'Current speed',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.grey,
                                textSize: displayWidth(context) * 0.03,
                                textAlign: TextAlign.start),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0XFFE4F5F5)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            commonText(
                                context: context,
                                text: '$avgSpeed $knot',
                                fontWeight: FontWeight.w600,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.044,
                                textAlign: TextAlign.start),
                            SizedBox(
                              height: 4,
                            ),
                            commonText(
                                context: context,
                                text: 'Avg. Speed',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.grey,
                                textSize: displayWidth(context) * 0.03,
                                textAlign: TextAlign.start),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                width: displayWidth(context),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0XFFE4F5F5)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '$avgSpeed$knot',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Avg. Speed',
                          fontWeight: FontWeight.w500,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start),
                    ],
                  ),
                ),
              ),
      ],
    ),
  );
}

//Vessel single view analytics on vessel single view screen
Widget vesselSingleViewVesselAnalytics(BuildContext context, String duration,
    String distance, String totalCount, String avgSpeed) {
  double finalAvgSpeed = double.parse(avgSpeed);
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 0,),
    child: Column(
      children: [
        Container(
          width: displayWidth(context),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: backgroundColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
            child: Column(
              children: [
                commonText(
                    context: context,
                    text: '$distance $nauticalMile',
                    fontWeight: FontWeight.w600,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.044,
                    textAlign: TextAlign.start),
                SizedBox(
                  height: 4,
                ),
                commonText(
                    context: context,
                    text: 'Total Distance',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.grey,
                    textSize: displayWidth(context) * 0.028,
                    textAlign: TextAlign.start,
                    fontFamily: poppins),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: duration,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total Recorded Time',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,
                          fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '$totalCount',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total Trips',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,
                          fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: finalAvgSpeed.isNaN
                              ? '0'
                              : '$finalAvgSpeed $speedKnot',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Average Speed',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '803 Ltr',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total Fuel Consumed',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '23 kg',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total CO2 Emissions',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: backgroundColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '10 kg',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total NO2 Emissions',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget oldVesselSingleViewVesselAnalytics(BuildContext context, String duration,
    String distance, String totalCount, String avgSpeed) {
  double finalAvgSpeed = double.parse(avgSpeed);
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10,),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: selectDayBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: duration,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total Trips Duration',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,
                          fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: selectDayBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '$distance $nauticalMile',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total Distance',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,
                          fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: selectDayBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: '$totalCount',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Total no of Trips',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,
                          fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: selectDayBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      commonText(
                          context: context,
                          text: finalAvgSpeed.isNaN
                              ? '0'
                              : '$finalAvgSpeed $knot',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.044,
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: 4,
                      ),
                      commonText(
                          context: context,
                          text: 'Avg. Speed',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start,fontFamily: poppins),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
