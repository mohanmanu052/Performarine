import 'dart:io';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/services/database_service.dart';

import '../../pages/bottom_navigation.dart';
import 'log_level.dart';

//Expansion card on vessel Single viw
class ExpansionCard extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CreateVessel? vessel;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;
  final bool isSingleView;
  final bool? isCalledFromVesselSingleView;
  ExpansionCard(this.scaffoldKey, this.vessel, this.onEdit, this.onTap,
      this.onDelete, this.isSingleView,
      {this.isCalledFromVesselSingleView = false});

  @override
  State<ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  List<CreateVessel>? vessel = [];
  final DatabaseService _databaseService = DatabaseService();

  bool tripIsRunning = false,
      isVesselParticularExpanded = false,
      vesselAnalytics = false;

  String totalDistance = '0',
      avgSpeed = '0',
      tripsCount = '0',
      totalDuration = "00:00:00",
      page = "Expansion card";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    getVesselAnalytics(widget.vessel!.id!);
  }

  @override
  Widget build(BuildContext context) {
    print('FFFFF: ${widget.vessel!.engineType}');
    return ExpandableNotifier(
        child: GestureDetector(
          onTap: () {
            CustomLogger().logWithFile(Level.info, "User navigating to VesselSingleView -> $page");
            if (widget.isSingleView) {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (_) => VesselSingleView(
                    vessel: widget.vessel,
                  ),
                  fullscreenDialog: true,
                ),
              )
                  .then((_) => setState(() {}));
            }
          },
          child: Column(
            children: <Widget>[
              Container(
                color: backgroundColor,
                child: SizedBox(
                  child: Container(
                    margin: EdgeInsets.only(left: 17, right: 17, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Stack(
                          children: [
                            SizedBox(
                              width: displayWidth(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: widget.vessel!.imageURLs == null ||
                                    widget.vessel!.imageURLs!.isEmpty ||
                                    widget.vessel!.imageURLs == 'string' ||
                                    widget.vessel!.imageURLs == '[]'
                                    ? Stack(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/icons/default_boat.png',
                                        // height: displayHeight(context) * 0.22,
                                        width: displayWidth(context),
                                        fit: BoxFit.contain,
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
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                width: displayWidth(context),
                                //color: Colors.red,
                                margin: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
                                child: Container(
                                  padding: EdgeInsets.only(right: 10),
                                  //width: displayWidth(context) * 0.28,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      if(widget.vessel!.engineType!.isEmpty)
                                        SizedBox(),

                                      if(widget.vessel!.engineType!.toLowerCase() ==
                                          'combustion' && widget.vessel!.fuelCapacity != null)
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
                                                      0.045,
                                                ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text:
                                                    '${widget.vessel!.fuelCapacity!}gal'
                                                        .toString(),
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize:
                                                    displayWidth(context) *
                                                        0.03,
                                                    textAlign: TextAlign.start,
                                                    fontFamily: outfit),
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
                                                      0.045,
                                                ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text: widget.vessel!.engineType!,
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize:
                                                    displayWidth(context) *
                                                        0.03,
                                                    textAlign: TextAlign.start,
                                                    fontFamily: outfit),
                                              ],
                                            )
                                          ],
                                        ),

                                      if(widget.vessel!.engineType!.toLowerCase() ==
                                          'electric' && widget.vessel!.batteryCapacity != null)
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
                                                    ' ${widget.vessel!.batteryCapacity!} kw'
                                                        .toString(),
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize: displayWidth(
                                                        context) *
                                                        0.03,
                                                    textAlign:
                                                    TextAlign.start,
                                                    fontFamily: outfit),
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
                                                      0.045,
                                                ),
                                                SizedBox(
                                                  width:
                                                  displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text: widget.vessel!
                                                        .engineType!,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize: displayWidth(
                                                        context) *
                                                        0.03,
                                                    textAlign:
                                                    TextAlign.start,
                                                    fontFamily: outfit),
                                              ],
                                            )
                                          ],
                                        ),

                                      if(widget.vessel!.engineType!.toLowerCase() ==
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
                                                      0.045,
                                                ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text: widget.vessel!
                                                        .fuelCapacity ==
                                                        null
                                                        ? '-'
                                                        : '${widget.vessel!.fuelCapacity!}gal'
                                                        .toString(),
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize:
                                                    displayWidth(context) *
                                                        0.03,
                                                    textAlign: TextAlign.start,
                                                    fontFamily: outfit),
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
                                                          0.027,
                                                    )),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text:
                                                    ' ${widget.vessel!.batteryCapacity!} kw'
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
                                                      0.045,
                                                ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text: widget.vessel!.engineType!,
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

                                      // widget.vessel!.engineType!.isEmpty
                                      //     ? const SizedBox()
                                      //     : widget.vessel!.engineType!.toLowerCase() ==
                                      //     'combustion'
                                      //     ? widget.vessel!.fuelCapacity == null
                                      //     ? const SizedBox()
                                      //     : Row(
                                      //   crossAxisAlignment:
                                      //   CrossAxisAlignment.center,
                                      //   children: [
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //       children: [
                                      //         Image.asset(
                                      //           'assets/images/fuel.png',
                                      //           width: displayWidth(context) *
                                      //               0.045,
                                      //         ),
                                      //         SizedBox(
                                      //           width: displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text:
                                      //             '${widget.vessel!.fuelCapacity!}gal'
                                      //                 .toString(),
                                      //             fontWeight: FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize:
                                      //             displayWidth(context) *
                                      //                 0.03,
                                      //             textAlign: TextAlign.start),
                                      //       ],
                                      //     ),
                                      //     SizedBox(
                                      //       width:
                                      //       displayWidth(context) * 0.05,
                                      //     ),
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //       children: [
                                      //         Image.asset(
                                      //           'assets/images/combustion_engine.png',
                                      //           width: displayWidth(context) *
                                      //               0.045,
                                      //         ),
                                      //         SizedBox(
                                      //           width: displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text: widget.vessel!.engineType!,
                                      //             fontWeight: FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize:
                                      //             displayWidth(context) *
                                      //                 0.03,
                                      //             textAlign: TextAlign.start),
                                      //       ],
                                      //     )
                                      //   ],
                                      // )
                                      //     : widget.vessel!.engineType!.toLowerCase() ==
                                      //     'electric'
                                      //     ? widget.vessel!.batteryCapacity == null
                                      //     ? const SizedBox()
                                      //     : Row(
                                      //   crossAxisAlignment:
                                      //   CrossAxisAlignment.center,
                                      //   mainAxisAlignment: MainAxisAlignment.center,
                                      //   children: [
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.center,
                                      //       children: [
                                      //         Container(
                                      //             margin:
                                      //             const EdgeInsets.only(
                                      //                 left: 4),
                                      //             child: Image.asset(
                                      //               'assets/images/battery.png',
                                      //               width: displayWidth(
                                      //                   context) *
                                      //                   0.027,
                                      //             )),
                                      //         SizedBox(
                                      //           width:
                                      //           displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text:
                                      //             ' ${widget.vessel!.batteryCapacity!} kw'
                                      //                 .toString(),
                                      //             fontWeight:
                                      //             FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize: displayWidth(
                                      //                 context) *
                                      //                 0.03,
                                      //             textAlign:
                                      //             TextAlign.start),
                                      //       ],
                                      //     ),
                                      //     SizedBox(
                                      //       width: displayWidth(context) *
                                      //           0.05,
                                      //     ),
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.center,
                                      //       children: [
                                      //         Image.asset(
                                      //           'assets/images/electric_engine.png',
                                      //           width:
                                      //           displayWidth(context) *
                                      //               0.045,
                                      //         ),
                                      //         SizedBox(
                                      //           width:
                                      //           displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text: widget.vessel!
                                      //                 .engineType!,
                                      //             fontWeight:
                                      //             FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize: displayWidth(
                                      //                 context) *
                                      //                 0.03,
                                      //             textAlign:
                                      //             TextAlign.start),
                                      //       ],
                                      //     )
                                      //   ],
                                      // )
                                      //     : Row(
                                      //   crossAxisAlignment:
                                      //   CrossAxisAlignment.center,
                                      //   children: [
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //       children: [
                                      //         Image.asset(
                                      //           'assets/images/fuel.png',
                                      //           width: displayWidth(context) *
                                      //               0.045,
                                      //         ),
                                      //         SizedBox(
                                      //           width: displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text: widget.vessel!
                                      //                 .fuelCapacity ==
                                      //                 null
                                      //                 ? '-'
                                      //                 : '${widget.vessel!.fuelCapacity!}gal'
                                      //                 .toString(),
                                      //             fontWeight: FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize:
                                      //             displayWidth(context) *
                                      //                 0.03,
                                      //             textAlign: TextAlign.start),
                                      //       ],
                                      //     ),
                                      //     SizedBox(
                                      //       width:
                                      //       displayWidth(context) * 0.05,
                                      //     ),
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //       children: [
                                      //         Container(
                                      //             margin: const EdgeInsets.only(
                                      //                 left: 4),
                                      //             child: Image.asset(
                                      //               'assets/images/battery.png',
                                      //               width:
                                      //               displayWidth(context) *
                                      //                   0.027,
                                      //             )),
                                      //         SizedBox(
                                      //           width: displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text:
                                      //             ' ${widget.vessel!.batteryCapacity!} kw'
                                      //                 .toString(),
                                      //             fontWeight: FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize:
                                      //             displayWidth(context) *
                                      //                 0.03,
                                      //             textAlign: TextAlign.start),
                                      //       ],
                                      //     ),
                                      //     SizedBox(
                                      //       height:
                                      //       displayHeight(context) * 0.5,
                                      //     ),
                                      //     Row(
                                      //       mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //       children: [
                                      //         Image.asset(
                                      //           'assets/images/hybrid_engine.png',
                                      //           width: displayWidth(context) *
                                      //               0.045,
                                      //         ),
                                      //         SizedBox(
                                      //           width: displayWidth(context) *
                                      //               0.02,
                                      //         ),
                                      //         commonText(
                                      //             context: context,
                                      //             text: widget.vessel!.engineType!,
                                      //             fontWeight: FontWeight.w500,
                                      //             textColor: Colors.white,
                                      //             textSize:
                                      //             displayWidth(context) *
                                      //                 0.03,
                                      //             textAlign: TextAlign.start),
                                      //       ],
                                      //     )
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                        Container(
                          margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: commonText(
                                        context: context,
                                        text: '${widget.vessel!.name}',
                                        fontWeight: FontWeight.w700,
                                        textColor: Colors.black87,
                                        textSize: displayWidth(context) * 0.045,
                                        textAlign: TextAlign.start),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          widget.onEdit(widget.vessel!);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                              BorderRadius.circular(20)),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 11,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              commonText(
                                                  context: context,
                                                  text: 'Edit',
                                                  fontWeight: FontWeight.w500,
                                                  textColor: Colors.white,
                                                  textSize:
                                                  displayWidth(context) * 0.034,
                                                  textAlign: TextAlign.center),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: displayHeight(context) * 0.01,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child: widget.isCalledFromVesselSingleView!
                                        ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: vesselSingleViewRichText(
                                        capacity:
                                        '${widget.vessel!.capacity}',
                                        built: '${widget.vessel!.builtYear}',
                                        regNo: widget.vessel!.regNumber!,
                                        context: context,
                                        color: Colors.black87,
                                      ),
                                    )
                                        : dashboardRichText(
                                      modelName: '${widget.vessel!.model}',
                                      builderName:
                                      '${widget.vessel!.builderName}',
                                      context: context,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      bool result = await _databaseService
                                          .checkIfTripIsRunningForSpecificVessel(
                                          widget.vessel!.id!);

                                      if (result) {
                                        Utils.showSnackBar(context,
                                            status: false,
                                            scaffoldKey: widget.scaffoldKey,
                                            message:
                                            'Please end the trip which is already running');
                                      } else {
                                        showDialogBox();
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: displayHeight(context) * 0.01),
                                      decoration:
                                      BoxDecoration(color: Colors.transparent),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: displayHeight(context) * 0.02,
                                            child: Image.asset(
                                              'assets/images/Trash.png',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          commonText(
                                              context: context,
                                              text: 'Delete',
                                              fontWeight: FontWeight.w500,
                                              textColor: userFeedbackBtnColor,
                                              textSize:
                                              displayWidth(context) * 0.034,
                                              textAlign: TextAlign.center,
                                              fontFamily: poppins
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),

              // ),
            ],
          ),
        ));
  }

//Dialog box to end the trip
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
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

                              commonText(
                                  context: context,
                                  text: 'Do you want to retire the vessel?',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.044,
                                  textAlign: TextAlign.center),
                              SizedBox(
                                height: displayHeight(context) * 0.015,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                  'This will archive the vessel and removed it from your My Vessel list. You can always unretire a vessel',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.black54,
                                  textSize: displayWidth(context) * 0.038,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 8.0,
                                  left: 10, right: 10
                              ),
                              child: Center(
                                child: CommonButtons.getAcceptButton(
                                    'Confirm Retire', context, endTripBtnColor, () {
                                  _databaseService.updateVesselStatus(
                                      0, widget.vessel!.id!);

                                  _databaseService.updateIsSyncStatus(
                                      0, widget.vessel!.id!);

                                  Utils.showSnackBar(context,
                                      scaffoldKey: widget.scaffoldKey,
                                      message:
                                      'Vessel retired successfully.');

                                  Navigator.of(dialogContext).pop();

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BottomNavigation(),
                                      fullscreenDialog: true,
                                    ),
                                  );
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
                                  left: 10, right: 10
                              ),
                              child: Center(
                                child: CommonButtons.getAcceptButton(
                                    'Cancel', context, Colors.transparent, () {
                                  Navigator.of(context).pop();
                                },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    primaryColor,
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : blueColor,
                                    displayHeight(context) * 0.018,
                                    Colors.white,
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

// To get vessel analytics by vessel Id
  void getVesselAnalytics(String vesselId) async {
    if (!tripIsRunning) {
      setState(() {
        vesselAnalytics = true;
      });
    }
    List<String> analyticsData =
    await _databaseService.getVesselAnalytics(vesselId);

    setState(() {
      totalDistance = analyticsData[0];
      avgSpeed = analyticsData[1];
      tripsCount = analyticsData[2];
      totalDuration = analyticsData[3];
      vesselAnalytics = false;
    });

    /// 1. TotalDistanceSum

    /// 2. AvgSpeed

    /// 3. TripsCount
    ///
    Utils.customPrint('totalDistance $totalDistance');
    Utils.customPrint('avgSpeed $avgSpeed');
    Utils.customPrint('COUNT $tripsCount');
    CustomLogger().logWithFile(Level.info, "totalDistance $totalDistance -> $page");
    CustomLogger().logWithFile(Level.info, "avgSpeed $avgSpeed -> $page");
    CustomLogger().logWithFile(Level.info, "COUNT $tripsCount -> $page");
  }
}