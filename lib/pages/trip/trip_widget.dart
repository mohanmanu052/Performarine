import 'package:flutter/material.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/colors.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/common_size_helper.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/date_formatter.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/common_buttons.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/common_widgets.dart';
import 'package:flutter_sqflite_example/models/trip.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                              text: */ /*widget.tripList?.deviceInfo?.make == null
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
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.tripList?.updatedAt != null
                              ? SizedBox(
                                  height: displayHeight(context) * 0.038,
                                  child: CommonButtons.getActionButton(
                                      buttonPrimaryColor: buttonBGColor,
                                      fontSize: displayWidth(context) * 0.03,
                                      onTap: () {},
                                      context: context,
                                      width: displayWidth(context) * 0.35,
                                      title: 'View Details'))
                              : SizedBox(
                                  height: displayHeight(context) * 0.038,
                                  child: CommonButtons.getActionButton(
                                      buttonPrimaryColor: primaryColor,
                                      fontSize: displayWidth(context) * 0.03,
                                      onTap: () {},
                                      context: context,
                                      width: displayWidth(context) * 0.35,
                                      title: 'Upload Trip Data')),
                          commonText(
                              context: context,
                              text:
                                  '${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.tripList!.createdAt!))}  ${widget.tripList?.updatedAt != null ? '-${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.tripList!.updatedAt!))}' : ''}',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black,
                              textSize: displayWidth(context) * 0.026,
                              textAlign: TextAlign.start),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 30,
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
                          text: widget.tripList?.updatedAt != null
                              ? "Completed"
                              : " Pending Upload ",
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
}
