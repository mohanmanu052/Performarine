import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/constants.dart';

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

import 'add_new_vessel_screen.dart';

class SuccessfullyAddedScreen extends StatefulWidget {
  final bool? isEdit;
   CreateVessel? data;
  SuccessfullyAddedScreen({Key? key, this.data, this.isEdit = false}) : super(key: key);

  @override
  State<SuccessfullyAddedScreen> createState() => _SuccessfullyAddedScreenState();
}

class _SuccessfullyAddedScreenState extends State<SuccessfullyAddedScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String page = "Successfully_added_screen";

  bool isVesselParticularExpanded = true,
      isVesselDimensionsExpanded = true,
      isDataUpdated = false;


      @override
  void initState() {
                     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,

      
      ]);

    // TODO: implement initState
    super.initState();
  }
@override
  void dispose() {
    // TODO: implement dispose
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      ]);
    super.dispose();
  }
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
              vertical: displayHeight(context) * 0.01),
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
                            VesselSingleView(vessel: widget.data!,isCalledFromSuccessScreen: true,)),
                  );
                } else {
                  CustomLogger().logWithFile(Level.info, "User Navigating to VesselSingleView -> $page");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VesselSingleView(vessel: widget.data!,isCalledFromSuccessScreen: true,)),
                  );
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
                  ? 'Vessel Updated'
                  : 'Vessel Added',
              fontWeight: FontWeight.w700,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: ()async {
                                   await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: SingleChildScrollView(
            child: Column(
              children: [

                SizedBox(
                  height: displayHeight(context) * 0.04,
                ),

                Container(
                    height: displayHeight(context) * 0.09,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      'assets/images/success_image.png',
                      height: displayHeight(context) * 0.24,
                    ),),

                SizedBox(
                  height: displayHeight(context) * 0.03,
                ),

                commonText(
                    context: context,
                    text: widget.isEdit!
                        ? 'Vessel Updated Successfully'
                        : 'Vessel Added Successfully',
                    fontWeight: FontWeight.w400,
                    textColor: blueColor,
                    textSize: displayWidth(context) * 0.05,
                    textAlign: TextAlign.start),

                SizedBox(
                  height: displayHeight(context) * 0.03,
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
                            Center(
                              child: Container(
                                color: Colors.white,
                                child: Image.asset(
                                  'assets/images/vessel_default_img.png',
                                  width: displayWidth(context) * 0.65,
                                  height: displayHeight(context) * 0.22,
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
                                      File(widget.data!.imageURLs!)),
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
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 50,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 50))
                                      ]),
                                    ))
                              ],
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
                                  // Column(
                                  //   crossAxisAlignment:
                                  //   CrossAxisAlignment.start,
                                  //   children: [
                                  //     commonText(
                                  //         context: context,
                                  //         text:
                                  //         '${widget.data!.capacity}$cubicCapacity',
                                  //         fontWeight: FontWeight.w500,
                                  //         textColor: Colors.white,
                                  //         textSize:
                                  //         displayWidth(context) * 0.038,
                                  //         textAlign: TextAlign.start),
                                  //     commonText(
                                  //         context: context,
                                  //         text: 'Capacity',
                                  //         fontWeight: FontWeight.w400,
                                  //         textColor: Colors.white,
                                  //         textSize:
                                  //         displayWidth(context) * 0.024,
                                  //         textAlign: TextAlign.start),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   width:
                                  //   displayWidth(context) * 0.05,
                                  // ),
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
                                                '${widget.data!.fuelCapacity!} L'
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
                                                ' ${widget.data!.batteryCapacity!} $kiloWattHour'
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
                                                    : '${widget.data!.fuelCapacity!} L'
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
                                                ' ${widget.data!.batteryCapacity!} $kiloWattHour'
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
                  height: displayHeight(context) * 0.015,
                ),

            Container(
              decoration: BoxDecoration(
                  color: Color(0xFFECF3F9),
                  borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                child: Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                          ),
                          dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        trailing: Container(
                          width: displayWidth(context) * 0.12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap:()async{
                                  var result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddNewVesselPage(
                                        isEdit: true,
                                        createVessel: widget.data,
                                      ),
                                      fullscreenDialog: true,
                                    ),
                                  );

                                  if (result != null) {
                                    Utils.customPrint('RESULT 1 ${result[0]}');
                                    Utils.customPrint(
                                        'RESULT 1 ${result[1] as CreateVessel}');
                                    setState(() {
                                      widget.data = result[1] as CreateVessel?;
                                      isDataUpdated = result[0];
                                    });
                                  }
                                },
                                child: Image.asset('assets/icons/Edit.png',
                                    width: displayWidth(context) * 0.045,
                                    color: Colors.black),
                              ),
                              !isVesselDimensionsExpanded ? Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.black,
                              ) : Icon(
                                Icons.keyboard_arrow_up_outlined,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        initiallyExpanded: true,
                        onExpansionChanged: ((newState) {
                          setState(() {
                            isVesselDimensionsExpanded = newState;
                          });

                          Utils.customPrint(
                              'EXPANSION CHANGE $isVesselDimensionsExpanded');
                          CustomLogger().logWithFile(Level.info, "EXPANSION CHANGE $isVesselDimensionsExpanded -> $page");
                        }),
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
                                            '${widget.data!.lengthOverall} $feet',
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
                                              '${widget.data!.freeBoard} $feet',
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
                                              text: '${widget.data!.beam} $feet',
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
                                              text: '${widget.data!.draft} $feet',
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
                      height: displayHeight(context) * 0.00,
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
                          trailing: Container(
                            width: displayWidth(context) * 0.12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap:()async{
                                    var result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddNewVesselPage(
                                          isEdit: true,
                                          createVessel: widget.data,
                                        ),
                                        fullscreenDialog: true,
                                      ),
                                    );

                                    if (result != null) {
                                      Utils.customPrint('RESULT 1 ${result[0]}');
                                      Utils.customPrint(
                                          'RESULT 1 ${result[1] as CreateVessel}');
                                      setState(() {
                                        widget.data = result[1] as CreateVessel?;
                                        isDataUpdated = result[0];
                                      });
                                    }
                                  },
                                  child: Image.asset('assets/icons/Edit.png',
                                      width: displayWidth(context) * 0.045,
                                      color: Colors.black),
                                ),
                                !isVesselParticularExpanded ? Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.black,
                                ) : Icon(
                                  Icons.keyboard_arrow_up_outlined,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              '130 $hp',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start),
                                          SizedBox(height: 2,),
                                          commonText(
                                              context: context,
                                              text: 'Diesel Engine\nPower' ,
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
                                              text: '320 $kiloWattHour',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start),
                                          SizedBox(height: 2,),
                                          commonText(
                                              context: context,
                                              text: 'Electric Engine\nPower',
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
                                              text: widget.data!.displacement!.isEmpty ? '0 $pound': '${widget.data!.displacement} $pound',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) *
                                                  0.04,
                                              textAlign: TextAlign.start),
                                          SizedBox(height: 2,),
                                          commonText(
                                              context: context,
                                              text: 'Displacement',
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
                                SizedBox(
                                  height: displayHeight(context) * 0.012,
                                ),
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      //flex: 01,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          commonText(
                                              context: context,
                                              text:
                                              'Planning',
                                              fontWeight: FontWeight.w700,
                                              textColor: Colors.black,
                                              textSize:
                                              displayWidth(context) * 0.04,
                                              textAlign: TextAlign.start),
                                          SizedBox(height: 2,),
                                          commonText(
                                              context: context,
                                              text: 'Hull Type',
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.grey,
                                              textSize:
                                              displayWidth(context) * 0.024,
                                              textAlign: TextAlign.start),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 02,
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
                                          SizedBox(height: 2,),
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
                    SizedBox(
                      height: displayHeight(context) * 0.022,
                    ),
                  ],
                ),
              ),
            ),
                SizedBox(
                  height: displayHeight(context) * 0.01,
                ),
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
