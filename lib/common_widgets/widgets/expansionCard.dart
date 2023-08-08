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
                                          'assets/images/vessel_default_img.png',
                                          height: displayHeight(context) * 0.22,
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
                                : Container(
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
                                                TextAlign.start),
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
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: commonText(
                                    context: context,
                                    text: '${widget.vessel!.name}',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black87,
                                    textSize: displayWidth(context) * 0.045,
                                    textAlign: TextAlign.start),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: letsGetStartedButtonColor,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          widget.onEdit(widget.vessel!);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: letsGetStartedButtonColor,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
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
                          widget.isCalledFromVesselSingleView!
                          ? Align(
                            alignment: Alignment.centerLeft,
                            child: vesselSingleViewRichText(
                                capacity: '${widget.vessel!.capacity}',
                                built: '${widget.vessel!.builtYear}',
                                regNo: widget.vessel!.regNumber!,
                                context: context,
                                color: Colors.black87,),
                          )
                          : dashboardRichText(
                              modelName: '${widget.vessel!.model}',
                              builderName: '${widget.vessel!.builderName}',
                              context: context,
                              color: Colors.grey,),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          /*Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 17, right: 17),
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
                          text: 'MEASUREMENTS',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.038,
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
                                          width: displayWidth(context) * 0.05,
                                          color: Colors.black),
                                      SizedBox(
                                          width: displayWidth(context) * 0.018),
                                      Flexible(
                                        child: commonText(
                                          context: context,
                                          text:
                                              '${widget.vessel!.lengthOverall} ft',
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.black,
                                          textSize:
                                              displayWidth(context) * 0.038,
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
                                      textSize: displayWidth(context) * 0.026,
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
                                          width: displayWidth(context) * 0.06,
                                          color: Colors.black),
                                      SizedBox(
                                          width: displayWidth(context) * 0.01),
                                      Flexible(
                                        child: commonText(
                                            context: context,
                                            text:
                                                '${widget.vessel!.freeBoard} ft',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.038,
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
                                      textSize: displayWidth(context) * 0.026,
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
                                          width: displayWidth(context) * 0.06,
                                          color: Colors.black),
                                      SizedBox(
                                          width: displayWidth(context) * 0.02),
                                      Flexible(
                                        child: commonText(
                                            context: context,
                                            text: '${widget.vessel!.beam} ft',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.038,
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
                                      textSize: displayWidth(context) * 0.026,
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
                                            width: displayWidth(context) * 0.06,
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                          width: displayWidth(context) * 0.02),
                                      Flexible(
                                        child: commonText(
                                            context: context,
                                            text: '${widget.vessel!.draft} ft',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.038,
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
                                      textSize: displayWidth(context) * 0.026,
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
                            text: 'VESSEL PARTICULARS',
                            fontWeight: FontWeight.w600,
                            textColor: Colors.black,
                            textSize: displayWidth(context) * 0.038,
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
                                                '${widget.vessel!.capacity}cc',
                                            fontWeight: FontWeight.w600,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.042,
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
                                            text: widget.vessel!.builtYear
                                                .toString(),
                                            fontWeight: FontWeight.w600,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.042,
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
                                        widget.vessel!.regNumber! == ""
                                            ? commonText(
                                                context: context,
                                                text: '-',
                                                fontWeight: FontWeight.w600,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.042,
                                                textAlign: TextAlign.start)
                                            : commonText(
                                                context: context,
                                                text: widget.vessel!.regNumber,
                                                fontWeight: FontWeight.w600,
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
                                                '${widget.vessel!.weight} Lbs',
                                            fontWeight: FontWeight.w600,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.042,
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
                                                '${widget.vessel!.vesselSize} hp',
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
                                        widget.vessel!.mMSI! == ""
                                            ? commonText(
                                                context: context,
                                                text: '-',
                                                fontWeight: FontWeight.w600,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
                                                textAlign: TextAlign.start)
                                            : commonText(
                                                context: context,
                                                text: widget.vessel!.mMSI,
                                                fontWeight: FontWeight.w600,
                                                textColor: Colors.black,
                                                textSize:
                                                    displayWidth(context) *
                                                        0.048,
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
                  SizedBox(
                    height: displayHeight(context) * 0.01,
                  ),
                ],
              ),
            ),
          )*/

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
                  height: displayHeight(context) * 0.28,
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
                                  text: 'Do you want to retire the vessel?',
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
                                      'This will archive the vessel and removed it from your My Vessel list. You can always unretire a vessel',
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
                                      'Cancel', context, Colors.grey.shade400, () {
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
                                      'OK', context, buttonBGColor, () {
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
