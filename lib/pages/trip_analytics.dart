import 'dart:io';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/services/database_service.dart';

class TripAnalyticsScreen extends StatefulWidget {
  final Trip? tripList;
  final CreateVessel? vessel;
  const TripAnalyticsScreen({Key? key, this.tripList, this.vessel})
      : super(key: key);

  @override
  State<TripAnalyticsScreen> createState() => _TripAnalyticsScreenState();
}

class _TripAnalyticsScreenState extends State<TripAnalyticsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  List<CreateVessel> getVesselById = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVesselDataById();
  }

  getVesselDataById() async {
    getVesselById = await _databaseService
        .getVesselNameByID(widget.tripList!.vesselId.toString());

    debugPrint('VESSEL DATA ${getVesselById[0].name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2fffb),
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xfff2fffb),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: commonText(
          context: context,
          text: 'Trip Id - ${widget.tripList!.id}',
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
          textSize: displayWidth(context) * 0.032,
        ),
        //backgroundColor: Colors.white,
      ),
      body: Container(
        //margin: EdgeInsets.symmetric(horizontal: 17),
        child: Stack(
          children: [
            SizedBox(
              height: displayHeight(context),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: displayHeight(context) * 0.01,
                    ),
                    commonText(
                      context: context,
                      text: '${widget.vessel!.name}',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black87,
                      textSize: displayWidth(context) * 0.045,
                    ),
                    SizedBox(
                      height: displayHeight(context) * 0.01,
                    ),
                    dashboardRichText(
                        modelName: '${widget.vessel!.model}',
                        builderName: '${widget.vessel!.builderName}',
                        context: context,
                        color: Colors.grey),
                    SizedBox(
                      height: displayHeight(context) * 0.01,
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.vessel!.imageURLs == null ||
                                widget.vessel!.imageURLs!.isEmpty ||
                                widget.vessel!.imageURLs == 'string'
                            ? Stack(
                                children: [
                                  Image.asset(
                                    'assets/images/dashboard_bg_image.png',
                                    height: displayHeight(context) * 0.22,
                                    width: displayWidth(context),
                                    fit: BoxFit.cover,
                                  ),
                                  /*Image.asset(
                                                    'assets/images/shadow_img.png',
                                                    height: displayHeight(context) * 0.22,
                                                    width: displayWidth(context),
                                                    fit: BoxFit.cover,
                                                  ),*/

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
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 50,
                                              spreadRadius: 5,
                                              offset: const Offset(0, 50))
                                        ]),
                                      ))
                                ],
                              )
                            : Stack(
                                children: [
                                  Container(
                                    height: displayHeight(context) * 0.22,
                                    width: displayWidth(context),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(
                                            File(widget.vessel!.imageURLs!)),
                                        fit: BoxFit.cover,
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
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 50,
                                              spreadRadius: 5,
                                              offset: const Offset(0, 50))
                                        ]),
                                      ))
                                ],
                              )),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: displayHeight(context) / 1.8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  child: Container(
                    margin: EdgeInsets.only(top: 40, left: 17, right: 17),
                    child: Column(
                      children: [
                        Container(
                          width: displayWidth(context),
                          padding: widget.vessel!.engineType!.toLowerCase() ==
                                  'combustion'
                              ? EdgeInsets.symmetric(horizontal: 50)
                              : widget.vessel!.engineType!.toLowerCase() ==
                                      'electric'
                                  ? EdgeInsets.symmetric(horizontal: 0)
                                  : EdgeInsets.symmetric(horizontal: 16),
                          //color: Colors.red,
                          child: widget.vessel!.engineType!.toLowerCase() ==
                                  'combustion'
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/fuel.png',
                                            width: displayWidth(context) * 0.04,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.018,
                                        ),
                                        commonText(
                                            context: context,
                                            text:
                                                '${widget.vessel!.fuelCapacity} gal',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.038,
                                            textAlign: TextAlign.start),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                            widget.vessel!.engineType!
                                                        .toLowerCase() ==
                                                    'hybrid'
                                                ? 'assets/images/hybrid_engine.png'
                                                : widget.vessel!.engineType!
                                                            .toLowerCase() ==
                                                        'electric'
                                                    ? 'assets/images/electric_engine.png'
                                                    : 'assets/images/combustion_engine.png',
                                            width: displayWidth(context) * 0.07,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
                                        ),
                                        Text(
                                          widget.vessel!.engineType!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize:
                                                  displayWidth(context) * 0.038,
                                              fontFamily: poppins),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : widget.vessel!.engineType!.toLowerCase() ==
                                      'electric'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/battery.png',
                                                width: displayWidth(context) *
                                                    0.04,
                                                color: Colors.black),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text:
                                                    '${widget.vessel!.batteryCapacity} kw',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.038,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                widget.vessel!.engineType!
                                                            .toLowerCase() ==
                                                        'hybrid'
                                                    ? 'assets/images/hybrid_engine.png'
                                                    : widget.vessel!.engineType!
                                                                .toLowerCase() ==
                                                            'electric'
                                                        ? 'assets/images/electric_engine.png'
                                                        : 'assets/images/combustion_engine.png',
                                                width: displayWidth(context) *
                                                    0.07,
                                                color: Colors.black),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.02,
                                            ),
                                            Text(
                                              widget.vessel!.engineType!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.038,
                                                  fontFamily: poppins),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/fuel.png',
                                                width: displayWidth(context) *
                                                    0.07,
                                                color: Colors.black),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text:
                                                    '${widget.vessel!.fuelCapacity} gal',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.038,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/battery.png',
                                                width: displayWidth(context) *
                                                    0.045,
                                                color: Colors.black),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text:
                                                    '${widget.vessel!.batteryCapacity} kw',
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.038,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                widget.vessel!.engineType!
                                                            .toLowerCase() ==
                                                        'hybrid'
                                                    ? 'assets/images/hybrid_engine.png'
                                                    : widget.vessel!.engineType!
                                                                .toLowerCase() ==
                                                            'electric'
                                                        ? 'assets/images/electric_engine.png'
                                                        : 'assets/images/combustion_engine.png',
                                                width: displayWidth(context) *
                                                    0.08,
                                                color: Colors.black),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.018,
                                            ),
                                            Text(
                                              widget.vessel!.engineType!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.038,
                                                  fontFamily: poppins),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.04,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                commonText(
                                    context: context,
                                    text: '${widget.tripList!.time}',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.036,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Time',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.026,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: displayHeight(context) * 0.05,
                                color: Colors.grey),
                            Column(
                              children: [
                                commonText(
                                    context: context,
                                    text: '${widget.tripList!.speed}',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.036,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Speed',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.026,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: displayHeight(context) * 0.05,
                                color: Colors.grey),
                            Column(
                              children: [
                                commonText(
                                    context: context,
                                    text: '${widget.tripList!.distance}m',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.036,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Distance',
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.026,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
