import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../models/vessel.dart';
import '../bottom_navigation.dart';
import '../vessel_single_view.dart';
import 'dart:io';

class SuccessfullyAddedScreen extends StatefulWidget {
  final bool? isEdit;
  final CreateVessel? data;
  SuccessfullyAddedScreen({Key? key, this.data, this.isEdit = false}) : super(key: key);

  @override
  State<SuccessfullyAddedScreen> createState() => _SuccessfullyAddedScreenState();
}

class _SuccessfullyAddedScreenState extends State<SuccessfullyAddedScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String page = "Successfully_added_screen";

  bool? isVesselParticularExpanded = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isEdit!) {
         Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VesselSingleView(
                  vessel: widget.data,
                  isCalledFromSuccessScreen: true,
                )),
          );
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavigation(),
              ),
              ModalRoute.withName("SuccessFullScreen"));
        }

        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        bottomNavigationBar: Container(
          margin: EdgeInsets.symmetric(
              horizontal: displayHeight(context) * 0.03,
              vertical: displayHeight(context) * 0.02),
          child: CommonButtons.getActionButton(
              title: 'View Full Details',
              context: context,
              fontSize: displayWidth(context) * 0.042,
              textColor: Colors.white,
              buttonPrimaryColor: blueColor,
              borderColor: blueColor,
              width: displayWidth(context),
              onTap: () {
                if (widget.isEdit!) {
                  CustomLogger().logWithFile(Level.info, "User Navigating to VesselSingleView -> $page");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VesselSingleView(vessel: widget.data!)),
                  );
                } else {
                  CustomLogger().logWithFile(Level.info, "User Navigating to AddNewVesselScreen -> $page");
               /*   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewVesselScreen(
                            calledFrom: 'SuccessFullScreen')),
                  ); */
                }
              }),
        ),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: backgroundColor,
          leading: IconButton(
            onPressed: () {
              if (widget.isEdit!) {
                CustomLogger().logWithFile(Level.info, "User Navigating to VesselSingleView -> $page");
                // Navigator.of(context).pop([true, widget.data]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VesselSingleView(
                        vessel: widget.data,
                        isCalledFromSuccessScreen: true,
                      )),
                );
              } else {
                CustomLogger().logWithFile(Level.info, "User Navigating to Home Page -> $page");
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavigation(),
                    ),
                    ModalRoute.withName(""));
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: false,
          title: commonText(
              context: context,
              text: widget.isEdit!
                  ? 'Successfully Updated'
                  : 'Vessel Added',
              fontWeight: FontWeight.w700,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: SingleChildScrollView(
            child: Column(
              children: [

                SizedBox(
                  height: displayHeight(context) * 0.05,
                ),

                Container(
                    height: displayHeight(context) * 0.1,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      'assets/images/success_image.png',
                      height: displayHeight(context) * 0.28,
                    ),),

                SizedBox(
                  height: displayHeight(context) * 0.03,
                ),

                commonText(
                    context: context,
                    text: widget.isEdit!
                        ? 'Vessel Updated Successfully'
                        : 'Vessel Added Successfully',
                    fontWeight: FontWeight.w600,
                    textColor: blueColor,
                    textSize: displayWidth(context) * 0.05,
                    textAlign: TextAlign.start),

                SizedBox(
                  height: displayHeight(context) * 0.02,
                ),

                Stack(
                  children: [
                    SizedBox(
                      width: displayWidth(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.data!.imageURLs == null ||
                            widget.data!.imageURLs!.isEmpty ||
                            widget.data!.imageURLs == 'string' ||
                            widget.data!.imageURLs == '[]'
                            ? Stack(
                          children: [
                            Container(
                              color: Colors.white,
                              child: Image.asset(
                                'assets/icons/default_boat.png',
                                height: displayHeight(context) * 0.22,
                                width: displayWidth(context),
                                fit: BoxFit.cover,
                              ),
                            ),
                            /* Positioned(
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
                                      ))*/
                          ],
                        )
                            : Container(
                          height: displayHeight(context) * 0.22,
                          width: displayWidth(context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(
                                  File(widget.data!.imageURLs!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        width: displayWidth(context),
                        //color: Colors.red,
                        margin: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
                        child: Container(
                          padding: EdgeInsets.only(right: 10),
                          //width: displayWidth(context) * 0.28,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.data!.name}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: displayWidth(context) * 0.05,
                                    fontWeight: FontWeight.w700,
                                    overflow: TextOverflow.clip),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: displayHeight(context) * 0.015,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                          context: context,
                                          text:
                                          '${widget.data!.capacity}cc',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) * 0.038,
                                          textAlign: TextAlign.start),
                                      commonText(
                                          context: context,
                                          text: 'Capacity',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) * 0.024,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                  SizedBox(
                                    width:
                                    displayWidth(context) * 0.05,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      commonText(
                                          context: context,
                                          text: widget.data!.builtYear
                                              .toString(),
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) * 0.038,
                                          textAlign: TextAlign.start),
                                      commonText(
                                          context: context,
                                          text: 'Built',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) * 0.024,
                                          textAlign: TextAlign.start),
                                    ],
                                  ),
                                  SizedBox(
                                    width:
                                    displayWidth(context) * 0.05,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      widget.data!.regNumber! == ""
                                          ? commonText(
                                          context: context,
                                          text: '-',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) *
                                              0.04,
                                          textAlign: TextAlign.start)
                                          : commonText(
                                          context: context,
                                          text: widget.data!.regNumber,
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) *
                                              0.038,
                                          textAlign: TextAlign.start),
                                      commonText(
                                          context: context,
                                          text: 'Registration Number',
                                          fontWeight: FontWeight.w400,
                                          textColor: Colors.white,
                                          textSize:
                                          displayWidth(context) * 0.024,
                                          textAlign: TextAlign.start),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: displayHeight(context) * 0.015,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  if(widget.data!.engineType!.isEmpty)
                                    SizedBox(),

                                  if(widget.data!.engineType!.toLowerCase() ==
                                      'combustion' && widget.data!.fuelCapacity != null)
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              'assets/images/fuel.png',
                                              width: displayWidth(context) *
                                                  0.04,
                                            ),
                                            SizedBox(
                                              width: displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text:
                                                '${widget.data!.fuelCapacity!}gal'
                                                    .toString(),
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width:
                                          displayWidth(context) * 0.05,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              'assets/images/combustion_engine.png',
                                              width: displayWidth(context) *
                                                  0.04,
                                            ),
                                            SizedBox(
                                              width: displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text: widget.data!.engineType!,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                          ],
                                        )
                                      ],
                                    ),

                                  if(widget.data!.engineType!.toLowerCase() ==
                                      'electric' && widget.data!.batteryCapacity != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    left: 4),
                                                child: Image.asset(
                                                  'assets/images/battery.png',
                                                  width: displayWidth(
                                                      context) *
                                                      0.026,
                                                )),
                                            SizedBox(
                                              width:
                                              displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text:
                                                ' ${widget.data!.batteryCapacity!} kw'
                                                    .toString(),
                                                fontWeight:
                                                FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.028,
                                                textAlign:
                                                TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width: displayWidth(context) *
                                              0.05,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/electric_engine.png',
                                              width:
                                              displayWidth(context) *
                                                  0.04,
                                            ),
                                            SizedBox(
                                              width:
                                              displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text: widget.data!
                                                    .engineType!,
                                                fontWeight:
                                                FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize: displayWidth(
                                                    context) *
                                                    0.028,
                                                textAlign:
                                                TextAlign.start),
                                          ],
                                        )
                                      ],
                                    ),

                                  if(widget.data!.engineType!.toLowerCase() ==
                                      'hybrid')
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/fuel.png',
                                              width: displayWidth(context) *
                                                  0.04,
                                            ),
                                            SizedBox(
                                              width: displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text: widget.data!
                                                    .fuelCapacity ==
                                                    null
                                                    ? '-'
                                                    : '${widget.data!.fuelCapacity!}gal'
                                                    .toString(),
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width:
                                          displayWidth(context) * 0.05,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    left: 4),
                                                child: Image.asset(
                                                  'assets/images/battery.png',
                                                  width:
                                                  displayWidth(context) *
                                                      0.026,
                                                )),
                                            SizedBox(
                                              width: displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text:
                                                ' ${widget.data!.batteryCapacity!} kw'
                                                    .toString(),
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                          ],
                                        ),
                                        SizedBox(
                                          width:
                                          displayWidth(context) * 0.05,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/hybrid_engine.png',
                                              width: displayWidth(context) *
                                                  0.04,
                                            ),
                                            SizedBox(
                                              width: displayWidth(context) *
                                                  0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text: widget.data!.engineType!,
                                                fontWeight: FontWeight.w400,
                                                textColor: Colors.white,
                                                textSize:
                                                displayWidth(context) *
                                                    0.028,
                                                textAlign: TextAlign.start),
                                          ],
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),

                SizedBox(
                  height: displayHeight(context) * 0.02,
                ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color(0xFFECF3F9),
                  borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child: Padding(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                          ),
                          dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        onExpansionChanged: ((newState) {}),
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: commonText(
                            context: context,
                            text: 'Vessel Dimensions',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.036,
                            textAlign: TextAlign.start),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset('assets/images/length.png',
                                            width: displayWidth(context) * 0.045,
                                            color: Colors.black),
                                        SizedBox(
                                            width: displayWidth(context) * 0.016),
                                        Flexible(
                                          child: commonText(
                                            context: context,
                                            text:
                                            '${widget.data!.lengthOverall} ft',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                            displayWidth(context) * 0.034,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: displayHeight(context) * 0.006),

                                    commonText(
                                        context: context,
                                        text: 'Length(LOA)',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.grey,
                                        textSize: displayWidth(context) * 0.024,
                                        textAlign: TextAlign.start),
                                  ],
                                ),
                              ),
                              SizedBox(width: displayWidth(context) * 0.015),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                            'assets/images/free_board.png',
                                            width: displayWidth(context) * 0.045,
                                            color: Colors.black),
                                        SizedBox(
                                            width: displayWidth(context) * 0.016),
                                        Flexible(
                                          child: commonText(
                                              context: context,
                                              text:
                                              '${widget.data!.freeBoard} ft',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.034,
                                              textAlign: TextAlign.start),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: displayHeight(context) * 0.006),
                                    commonText(
                                        context: context,
                                        text: 'Freeboard',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.grey,
                                        textSize: displayWidth(context) * 0.024,
                                        textAlign: TextAlign.start),
                                  ],
                                ),
                              ),
                              SizedBox(width: displayWidth(context) * 0.015),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                            'assets/icons/beam.png',
                                            width: displayWidth(context) * 0.048,
                                            color: Colors.black),
                                        SizedBox(
                                            width: displayWidth(context) * 0.016),
                                        Flexible(
                                          child: commonText(
                                              context: context,
                                              text: '${widget.data!.beam} ft',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.034,
                                              textAlign: TextAlign.start),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: displayHeight(context) * 0.006),
                                    commonText(
                                        context: context,
                                        text: 'Beam',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.grey,
                                        textSize: displayWidth(context) * 0.024,
                                        textAlign: TextAlign.start),
                                  ],
                                ),
                              ),
                              SizedBox(width: displayWidth(context) * 0.015),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        RotatedBox(
                                          quarterTurns: 2,
                                          child: Image.asset(
                                              'assets/images/free_board.png',
                                              width: displayWidth(context) * 0.045,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                            width: displayWidth(context) * 0.016),
                                        Flexible(
                                          child: commonText(
                                              context: context,
                                              text: '${widget.data!.draft} ft',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.034,
                                              textAlign: TextAlign.start),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: displayHeight(context) * 0.006),
                                    commonText(
                                        context: context,
                                        text: 'Draft',
                                        fontWeight: FontWeight.w500,
                                        textColor: Colors.grey,
                                        textSize: displayWidth(context) * 0.024,
                                        textAlign: TextAlign.start),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: displayHeight(context) * 0.01,
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                          ),
                          dividerColor: Colors.transparent),
                      child: Container(
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          onExpansionChanged: ((newState) {
                            setState(() {
                              isVesselParticularExpanded = newState;
                            });

                            Utils.customPrint(
                                'EXPANSION CHANGE $isVesselParticularExpanded');
                            CustomLogger().logWithFile(Level.info, "EXPANSION CHANGE $isVesselParticularExpanded -> $page");
                          }),
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: commonText(
                              context: context,
                              text: 'Propulsion Details',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.036,
                              textAlign: TextAlign.start),
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                              context: context,
                                              text:
                                              '${widget.data!.capacity}cc',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: 'Capacity',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                              context: context,
                                              text: widget.data!.builtYear
                                                  .toString(),
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: 'Built',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          widget.data!.regNumber! == ""
                                              ? commonText(
                                              context: context,
                                              text: '-',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) *
                                                  0.04,
                                              textAlign: TextAlign.start)
                                              : commonText(
                                              context: context,
                                              text: widget.data!.regNumber,
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) *
                                                  0.048,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: 'Registration Number',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    indent: 1,
                                    endIndent: 2,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                              context: context,
                                              text:
                                              '${widget.data!.weight} Lbs',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: 'Weight',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                              context: context,
                                              text:
                                              '${widget.data!.vesselSize} hp',
                                              fontWeight: FontWeight.w600,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.042,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: 'Size (hp)',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          widget.data!.mMSI! == ""
                                              ? commonText(
                                              context: context,
                                              text: '-',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) *
                                                  0.04,
                                              textAlign: TextAlign.start)
                                              : commonText(
                                              context: context,
                                              text: widget.data!.mMSI,
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) *
                                                  0.04,
                                              textAlign: TextAlign.start),
                                          commonText(
                                              context: context,
                                              text: 'MMSI',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            /*    Column(
                  children: [
                    SizedBox(
                      height: displayHeight(context) * 0.03,
                    ),
                    InkWell(
                      onTap: () {
                        CustomLogger().logWithFile(Level.info, "User Navigating to Home Page -> $page");
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavigation(),
                            ),
                            ModalRoute.withName(""));
                      },
                      child: commonText(
                          context: context,
                          text: 'View all Vessels',
                          fontWeight: FontWeight.w500,
                          textColor: primaryColor,
                          textSize: displayWidth(context) * 0.05,
                          textAlign: TextAlign.start),
                    ),
                  ],
                ) */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
