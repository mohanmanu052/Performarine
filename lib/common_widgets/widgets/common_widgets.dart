import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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

Widget commonText(
    {String? text,
    BuildContext? context,
    double? textSize,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign? textAlign = TextAlign.center,
    TextDecoration textDecoration = TextDecoration.none}) {
  return Text(
    text ?? '',
    textAlign: textAlign!,
    style: TextStyle(
        fontSize: textSize,
        color: textColor,
        fontFamily: poppins,
        fontWeight: fontWeight,
        decoration: textDecoration),
    overflow: TextOverflow.clip,
    softWrap: true,
  );
}

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
                      /* Navigator.pop(context);
                      List<File> list = await Utils.pickCameraImages();
                      onSelectImage(list);*/

                      bool isCameraPermissionGranted =
                          await Permission.camera.isGranted;

                      Utils.customPrint(
                          ' CAM PERMISSION $isCameraPermissionGranted');

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

Widget richText(
    {String? modelName,
    String? builderName,
    BuildContext? context,
    Color? color}) {
  return Row(
    children: [
      Expanded(
        child: RichText(
          text: TextSpan(
              text: modelName,
              style: TextStyle(
                color: Theme.of(context!).brightness == Brightness.dark
                    ? Colors.white
                    : color,
                fontSize: displayWidth(context) * 0.04,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' | ',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: displayWidth(context) * 0.04,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: builderName,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : color,
                      fontSize: displayWidth(context) * 0.04,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // navigate to desired screen
                      })
              ]),
        ),
      ),
    ],
  );
}

Widget dashboardRichText(
    {String? modelName,
    String? builderName,
    BuildContext? context,
    Color? color}) {
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
            fontFamily: poppins,
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
            fontFamily: poppins,
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

Widget vesselSingleViewCard(BuildContext context, CreateVessel vesselData,
    Function(CreateVessel) onTap, GlobalKey<ScaffoldState> scaffoldKey,
    {bool isTripIsRunning = false}) {
  Utils.customPrint("IMAGE FROM HOME SINGLE WIDGET ${vesselData.imageURLs}");

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
                              height: displayHeight(context) * 0.22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Colors.white,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/vessel_default_img.png',
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
                          Image.memory(
                            File(vesselData.imageURLs!).readAsBytesSync(),
                            fit: BoxFit.cover,
                            height: displayHeight(context) * 0.22,
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
                            'Unretire', context, primaryColor, () async {
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
                height: displayHeight(context) * 0.32,
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
                                text: 'Do you want to unretire the vessel?',
                                fontWeight: FontWeight.w600,
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
                                textColor: Colors.grey,
                                textSize: displayWidth(context) * 0.036,
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
                                          builder: (context) => HomePage(),
                                        ),
                                        ModalRoute.withName(""));
                                  });
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

Widget vesselAnalytics(BuildContext context, String duration, String distance,
    String currentSpeed, String avgSpeed, bool isTripIsRunning) {
  //double avgSpeed = int.parse(distance) / int.parse(duration);
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

Widget vesselSingleViewVesselAnalytics(BuildContext context, String duration,
    String distance, String totalCount, String avgSpeed) {
  //double avgSpeed = int.parse(distance) / int.parse(duration);
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
                          text: 'Total Trips Duration',
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
                          text: 'Total Distance',
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
        ),
      ],
    ),
  );
}
