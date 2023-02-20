import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/trip/trip_list_screen.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/services/database_service.dart';

class ExpansionCard extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CreateVessel? vessel;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;
  final bool isSingleView;
  ExpansionCard(this.scaffoldKey, this.vessel, this.onEdit, this.onTap,
      this.onDelete, this.isSingleView);

  @override
  State<ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  List<CreateVessel>? vessel = [];
  final DatabaseService _databaseService = DatabaseService();

  bool tripIsRunning = false, isVesselParticularExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: GestureDetector(
      onTap: () {
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
            color: Color(0xfff2fffb),
            child: SizedBox(
              child: Container(
                margin: EdgeInsets.only(left: 17, right: 17, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: displayHeight(context) * 0.01,
                    ),
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
                                      /*Utils.showSnackBar(context,
                                          scaffoldKey: widget.scaffoldKey,
                                          message:
                                              'Please end the trip which is already running');*/
                                    } else {
                                      showDialogBox();
                                    }

                                    //await widget.onDelete(widget.vessel!);
                                    /*Utils.showSnackBar(context,
                                        scaffoldKey: widget.scaffoldKey,
                                        message: 'Vessel Deleted Successfully');
                                    //ToDo: @rupali add the timer of 500 ms then navigate*/
                                    /*Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => HomePage(),
                                        fullscreenDialog: true,
                                      ),
                                    );*/
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
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 17, right: 17),
              child: Column(
                children: [
                  SizedBox(
                    height: displayHeight(context) * 0.01,
                  ),
                  Container(
                      child: widget.vessel!.engineType!.toLowerCase() ==
                              'combustion'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                        textSize: displayWidth(context) * 0.038,
                                        textAlign: TextAlign.start),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                        Image.asset('assets/images/battery.png',
                                            width: displayWidth(context) * 0.04,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
                                        ),
                                        commonText(
                                            context: context,
                                            text:
                                                '${widget.vessel!.batteryCapacity} kw',
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
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/fuel.png',
                                            width: displayWidth(context) * 0.07,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
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
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/battery.png',
                                            width:
                                                displayWidth(context) * 0.045,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
                                        ),
                                        commonText(
                                            context: context,
                                            text:
                                                '${widget.vessel!.batteryCapacity} kw',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.038,
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
                                            width: displayWidth(context) * 0.08,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.018,
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
                                )),
                  SizedBox(
                    height: displayHeight(context) * 0.01,
                  ),
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
                      //color: Colors.red,
                      /*height: isVesselParticularExpanded
                          ? displayHeight(context) * 0.25
                          : displayHeight(context) * 0.09,*/
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        onExpansionChanged: ((newState) {
                          setState(() {
                            isVesselParticularExpanded = newState;
                          });

                          Utils.customPrint(
                              'EXPANSION CHANGE $isVesselParticularExpanded');
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
                                                '${widget.vessel!.weight} Kgs',
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
                  /* ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapBodyToCollapse: true,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "${widget.vessel!.name!.toUpperCase()}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    collapsed: Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                        textSize: displayWidth(context) * 0.038,
                                        textAlign: TextAlign.start),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                        Image.asset('assets/images/battery.png',
                                            width: displayWidth(context) * 0.04,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
                                        ),
                                        commonText(
                                            context: context,
                                            text:
                                                '${widget.vessel!.batteryCapacity} kw',
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
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/fuel.png',
                                            width: displayWidth(context) * 0.07,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
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
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/battery.png',
                                            width:
                                                displayWidth(context) * 0.045,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.02,
                                        ),
                                        commonText(
                                            context: context,
                                            text:
                                                '${widget.vessel!.batteryCapacity} kw',
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.black,
                                            textSize:
                                                displayWidth(context) * 0.038,
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
                                            width: displayWidth(context) * 0.08,
                                            color: Colors.black),
                                        SizedBox(
                                          width: displayWidth(context) * 0.018,
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
                                ),
                    ),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        singleViewOfShip(widget.vessel!),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Fuel : ${widget.vessel!.fuelCapacity}"),
                              Text(
                                "|",
                                style: TextStyle(
                                    color: letsGetStartedButtonColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  "Battery : ${widget.vessel!.batteryCapacity}"),
                              Text(
                                "|",
                                style: TextStyle(
                                    color: letsGetStartedButtonColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("Engine : ${widget.vessel!.engineType}"),
                            ],
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text("Measurements"),
                          subtitle: Column(
                            children: [
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Length (LOA) : ${widget.vessel!.lengthOverall}"),
                                  Text(
                                      "Freeboard : ${widget.vessel!.freeBoard}")
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Beam : ${widget.vessel!.beam}"),
                                  Text("Draft : ${widget.vessel!.draft}")
                                ],
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text("Vessel Particulars"),
                          subtitle: Column(
                            children: [
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Capacity : ${widget.vessel!.capacity}"),
                                  Text(
                                      "Built Year : ${widget.vessel!.builtYear}"),
                                  Text("Reg No : ${widget.vessel!.regNumber}")
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Weight : ${widget.vessel!.weight}"),
                                  Text(
                                      "Size (hp) : ${widget.vessel!.vesselSize}"),
                                  Text("MMSI : ${widget.vessel!.mMSI}")
                                ],
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // SizedBox(width: 20.0),
                            GestureDetector(
                              onTap: () => widget.onEdit(widget.vessel!),
                              child: Container(
                                height: 40.0,
                                width: MediaQuery.of(context).size.width * .4,
                                color: letsGetStartedButtonColor,
                                // decoration: BoxDecoration(
                                //   shape: BoxShape.circle,
                                //   color: Colors.grey[200],
                                // ),
                                alignment: Alignment.center,
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                            // SizedBox(width: 20.0),
                            GestureDetector(
                              onTap: () => widget.onDelete(widget.vessel!),
                              child: Container(
                                height: 40.0,
                                width: MediaQuery.of(context).size.width * .4,
                                color: letsGetStartedButtonColor,
                                alignment: Alignment.center,
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        widget.isSingleView
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    // final DatabaseService _databaseService = DatabaseService();
                                    vessel!.add(widget.vessel!);
                                    // prUtils.customPrintint(vessel[0].vesselName);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => StartTrip(
                                            vessels: vessel, context: context),
                                        fullscreenDialog: true,
                                      ),
                                    );

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TripListScreen(
                                          vesselId: widget.vessel!.id,
                                          vesselName: widget.vessel!.name,
                                          vesselSize: widget.vessel!.vesselSize,
                                        ),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40.0,
                                    width: MediaQuery.of(context).size.width,
                                    color: letsGetStartedButtonColor,
                                    // decoration: BoxDecoration(
                                    //   shape: BoxShape.circle,
                                    //   color: Colors.grey[200],
                                    // ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Start Trip",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Expandable(
                          collapsed: widget.isSingleView ? collapsed : expanded,
                          expanded: widget.isSingleView ? expanded : collapsed,
                          theme: const ExpandableThemeData(crossFadePoint: 0),
                        ),
                      );
                    },
                  ),*/
                ],
              ),
            ),
          )

          // ),
        ],
      ),
    ));
  }

  singleViewOfShip(CreateVessel vessel) {
    return Container(
      height: displayHeight(context) >= 700
          ? isVesselParticularExpanded
              ? displayHeight(context) / 2.2
              : displayHeight(context) / 3.4
          : displayHeight(context) / 0.03,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vessel.engineType!.toLowerCase() == 'combustion'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/fuel.png',
                                width: displayWidth(context) * 0.04,
                                color: Colors.black),
                            SizedBox(
                              width: displayWidth(context) * 0.018,
                            ),
                            commonText(
                                context: context,
                                text: '${vessel.fuelCapacity} gal',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.038,
                                textAlign: TextAlign.start),
                          ],
                        ),
                        /* const SizedBox(
                                                              height: 14,
                                                            ),
                                                            StepProgressIndicator(
                                                              totalSteps: 16,
                                                              currentStep: 10,
                                                              padding: 1,
                                                              size: 9,
                                                              selectedColor: Colors
                                                                  .lightGreen.shade200,
                                                              unselectedColor:
                                                                  Colors.grey.shade200,
                                                            )*/
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                                vessel.engineType!.toLowerCase() == 'hybrid'
                                    ? 'assets/images/hybrid_engine.png'
                                    : vessel.engineType!.toLowerCase() ==
                                            'electric'
                                        ? 'assets/images/electric_engine.png'
                                        : 'assets/images/combustion_engine.png',
                                width: displayWidth(context) * 0.07,
                                color: Colors.black),
                            SizedBox(
                              width: displayWidth(context) * 0.02,
                            ),
                            Text(
                              vessel.engineType!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: displayWidth(context) * 0.038,
                                  fontFamily: poppins),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : vessel.engineType!.toLowerCase() == 'electric'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/battery.png',
                                    width: displayWidth(context) * 0.04,
                                    color: Colors.black),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: '${vessel.batteryCapacity} kw',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            /*const SizedBox(
                                                                  height: 14,
                                                                ),
                                                                StepProgressIndicator(
                                                                  totalSteps: 16,
                                                                  currentStep: 10,
                                                                  padding: 1,
                                                                  size: 9,
                                                                  selectedColor: Colors
                                                                      .lightGreen
                                                                      .shade200,
                                                                  unselectedColor:
                                                                      Colors.grey
                                                                          .shade200,
                                                                )*/
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                    vessel.engineType!.toLowerCase() == 'hybrid'
                                        ? 'assets/images/hybrid_engine.png'
                                        : vessel.engineType!.toLowerCase() ==
                                                'electric'
                                            ? 'assets/images/electric_engine.png'
                                            : 'assets/images/combustion_engine.png',
                                    width: displayWidth(context) * 0.07,
                                    color: Colors.black),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Text(
                                  vessel.engineType!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: displayWidth(context) * 0.038,
                                      fontFamily: poppins),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/fuel.png',
                                    width: displayWidth(context) * 0.07,
                                    color: Colors.black),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: '${vessel.fuelCapacity} gal',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            /*const SizedBox(
                                                                  height: 14,
                                                                ),
                                                                StepProgressIndicator(
                                                                  totalSteps: 16,
                                                                  currentStep: 10,
                                                                  padding: 1,
                                                                  size: 9,
                                                                  selectedColor: Colors
                                                                      .lightGreen
                                                                      .shade200,
                                                                  unselectedColor:
                                                                      Colors.grey
                                                                          .shade200,
                                                                )*/
                          ],
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/battery.png',
                                    width: displayWidth(context) * 0.045,
                                    color: Colors.black),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: '${vessel.batteryCapacity} kw',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start),
                              ],
                            ),

                            /*StepProgressIndicator(
                                                                  totalSteps: 16,
                                                                  currentStep: 10,
                                                                  padding: 1,
                                                                  size: 9,
                                                                  selectedColor:
                                                                      primaryColor,
                                                                  unselectedColor:
                                                                      Colors.grey
                                                                          .shade200,
                                                                )*/
                          ],
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                    vessel.engineType!.toLowerCase() == 'hybrid'
                                        ? 'assets/images/hybrid_engine.png'
                                        : vessel.engineType!.toLowerCase() ==
                                                'electric'
                                            ? 'assets/images/electric_engine.png'
                                            : 'assets/images/combustion_engine.png',
                                    width: displayWidth(context) * 0.08,
                                    color: Colors.black),
                                SizedBox(
                                  width: displayWidth(context) * 0.018,
                                ),
                                Text(
                                  vessel.engineType!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: displayWidth(context) * 0.038,
                                      fontFamily: poppins),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
          SizedBox(height: displayHeight(context) * 0.005),
          /*Theme(
                                                data: Theme.of(context).copyWith(
                                                    dividerColor: Colors.transparent),
                                                child: ExpansionTile(
                                                  initiallyExpanded: true,
                                                  tilePadding: EdgeInsets.zero,
                                                  childrenPadding: EdgeInsets.zero,
                                                  title: commonText(
                                                      context: context,
                                                      text: 'WEATHER',
                                                      fontWeight: FontWeight.w500,
                                                      textColor: Colors.black,
                                                      textSize:
                                                          displayWidth(context) * 0.04,
                                                      textAlign: TextAlign.start),
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceAround,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/temperature.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.1,
                                                                color: Colors.black),
                                                            SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.01),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                commonText(
                                                                    context: context,
                                                                    text: '23 C',
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    textColor:
                                                                        Colors.black,
                                                                    textSize:
                                                                        displayWidth(
                                                                                context) *
                                                                            0.04,
                                                                    textAlign: TextAlign
                                                                        .start),
                                                                commonText(
                                                                    context: context,
                                                                    text: '73 F',
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    textColor:
                                                                        Colors.black,
                                                                    textSize:
                                                                        displayWidth(
                                                                                context) *
                                                                            0.04,
                                                                    textAlign: TextAlign
                                                                        .start),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/gps.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.1,
                                                                color: Colors.black),
                                                            SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                commonText(
                                                                    context: context,
                                                                    text: '15.9 kn',
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    textColor:
                                                                        Colors.black,
                                                                    textSize:
                                                                        displayWidth(
                                                                                context) *
                                                                            0.04,
                                                                    textAlign: TextAlign
                                                                        .start),
                                                                commonText(
                                                                    context: context,
                                                                    text: '8.2 m/s',
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    textColor:
                                                                        Colors.black,
                                                                    textSize:
                                                                        displayWidth(
                                                                                context) *
                                                                            0.04,
                                                                    textAlign: TextAlign
                                                                        .start),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/depth_bold.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.1,
                                                                color: Colors.black),
                                                            SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                commonText(
                                                                    context: context,
                                                                    text: '1.7 m',
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    textColor:
                                                                        Colors.black,
                                                                    textSize:
                                                                        displayWidth(
                                                                                context) *
                                                                            0.04,
                                                                    textAlign: TextAlign
                                                                        .start),
                                                                commonText(
                                                                    context: context,
                                                                    text: '5.6 ft',
                                                                    fontWeight:
                                                                        FontWeight.w500,
                                                                    textColor:
                                                                        Colors.black,
                                                                    textSize:
                                                                        displayWidth(
                                                                                context) *
                                                                            0.04,
                                                                    textAlign: TextAlign
                                                                        .start),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      displayHeight(context) * 0.02),*/
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              onExpansionChanged: ((newState) {
                /* if (newState)
                 */ /* setState(() {
                    isSelectedTileOpen = true;
                  });*/ /*
                else
                  setState(() {
                    isSelectedTileOpen = false;
                  });*/
              }),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: commonText(
                  context: context,
                  text: 'MEASUREMENTS',
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.04,
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
                              SizedBox(width: displayWidth(context) * 0.018),
                              Flexible(
                                child: commonText(
                                  context: context,
                                  text: '${vessel.lengthOverall} ft',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: displayHeight(context) * 0.006),
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
                              Image.asset('assets/images/free_board.png',
                                  width: displayWidth(context) * 0.06,
                                  color: Colors.black),
                              SizedBox(width: displayWidth(context) * 0.01),
                              Flexible(
                                child: commonText(
                                    context: context,
                                    text: '${vessel.freeBoard} ft',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          SizedBox(height: displayHeight(context) * 0.006),
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
                              Image.asset('assets/images/free_board.png',
                                  width: displayWidth(context) * 0.06,
                                  color: Colors.black),
                              SizedBox(width: displayWidth(context) * 0.02),
                              Flexible(
                                child: commonText(
                                    context: context,
                                    text: '${vessel.beam} ft',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          SizedBox(height: displayHeight(context) * 0.006),
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
                              SizedBox(width: displayWidth(context) * 0.02),
                              Flexible(
                                child: commonText(
                                    context: context,
                                    text: '${vessel.draft} ft',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.038,
                                    textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          SizedBox(height: displayHeight(context) * 0.006),
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
          SizedBox(height: displayHeight(context) * 0.005),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              color: Colors.red,
              height: isVesselParticularExpanded
                  ? displayHeight(context) * 0.25
                  : displayHeight(context) * 0.09,
              child: ExpansionTile(
                initiallyExpanded: true,
                onExpansionChanged: ((newState) {
                  setState(() {
                    isVesselParticularExpanded = newState;
                  });

                  Utils.customPrint(
                      'EXPANSION CHANGE $isVesselParticularExpanded');

                  /*if (newState)
                    setState(() {
                      isSelectedTileOpen1 = true;
                    });
                  else
                    setState(() {
                      isSelectedTileOpen1 = false;

                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                    });*/
                }),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: commonText(
                    context: context,
                    text: 'VESSEL PARTICULARS',
                    fontWeight: FontWeight.w500,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.04,
                    textAlign: TextAlign.start),
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(
                                    context: context,
                                    text: '${vessel.capacity}cc',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.048,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Capacity',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.024,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(
                                    context: context,
                                    text: vessel.builtYear.toString(),
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.048,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Built',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.024,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                vessel.regNumber! == ""
                                    ? commonText(
                                        context: context,
                                        text: '-',
                                        fontWeight: FontWeight.w600,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.048,
                                        textAlign: TextAlign.start)
                                    : commonText(
                                        context: context,
                                        text: vessel.regNumber,
                                        fontWeight: FontWeight.w600,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.048,
                                        textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Registration Number',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.024,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        child: const Divider(
                          color: Colors.grey,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(
                                    context: context,
                                    text: '${vessel.weight} Kgs',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.048,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Weight',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.024,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(
                                    context: context,
                                    text: '${vessel.vesselSize} hp',
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.048,
                                    textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'Size (hp)',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.024,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                vessel.mMSI! == ""
                                    ? commonText(
                                        context: context,
                                        text: '-',
                                        fontWeight: FontWeight.w600,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.048,
                                        textAlign: TextAlign.start)
                                    : commonText(
                                        context: context,
                                        text: vessel.mMSI,
                                        fontWeight: FontWeight.w600,
                                        textColor: Colors.black,
                                        textSize: displayWidth(context) * 0.048,
                                        textAlign: TextAlign.start),
                                commonText(
                                    context: context,
                                    text: 'MMSI',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.grey,
                                    textSize: displayWidth(context) * 0.024,
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
          SizedBox(height: displayHeight(context) * 0.02),
        ],
      ),
    );
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
                                      'OK', context, primaryColor, () {
                                    _databaseService.updateVesselStatus(
                                        0, widget.vessel!.id!);

                                    Utils.showSnackBar(context,
                                        scaffoldKey: widget.scaffoldKey,
                                        message:
                                            'Vessel retired successfully.');

                                    Navigator.of(dialogContext).pop();

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => HomePage(),
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

  Future<bool> tripIsRunningOrNot() async {
    bool result = await _databaseService.tripIsRunning();

    setState(() {
      tripIsRunning = result;
      Utils.customPrint('Trip is Running $tripIsRunning');
    });

    /*setState(() {
      isEndTripButton = tripIsRunning;
      isStartButton = !tripIsRunning;
    });*/
    return result;
  }
}
