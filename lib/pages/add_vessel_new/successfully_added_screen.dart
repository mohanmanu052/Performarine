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
        backgroundColor: commonBackgroundColor,
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
          backgroundColor: commonBackgroundColor,
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
          centerTitle: true,
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

                vesselSingleViewCard(context, widget.data!,
                        (CreateVessel value) {
                      CustomLogger().logWithFile(Level.info, "User Navigating to Vessel Single View -> $page");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VesselSingleView(
                              vessel: value,
                              isCalledFromSuccessScreen: true,
                            )),
                      );
                    }, scaffoldKey),

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
                                            'assets/images/free_board.png',
                                            width: displayWidth(context) * 0.045,
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
