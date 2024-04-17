import 'dart:io';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/models/vessel_delegate_model.dart';

class DelegateVesselInfoCard extends StatelessWidget {
  VesselInfo? vesselData;
  DelegateVesselInfoCard({super.key, this.vesselData});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: displayWidth(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: vesselData!.imageURLs == null ||
                vesselData!.imageURLs!.isEmpty ||
                vesselData!.imageURLs == 'string' ||
                vesselData!.imageURLs == '[]'
                ? Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/vessel_default_img.png',
                    height: displayHeight(context) * 0.24,
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
                Container(
                  height: displayHeight(context) * 0.22,
                  width: displayWidth(context),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(vesselData!.imageURLs![0].toString()),
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
                    '${vesselData!.name}',
                    style: TextStyle(
                      fontFamily: outfit,
                        color: Colors.white,
                        fontSize: displayWidth(context) * 0.05,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.clip),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: displayHeight(context) * 0.015,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: displayWidth(context) * 0.05,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          commonText(
                              context: context,
                              text: vesselData!.builtYear.toString(),
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.038,
                              textAlign: TextAlign.start),
                          commonText(
                              context: context,
                              text: 'Built',
                              fontWeight: FontWeight.w400,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.024,
                              textAlign: TextAlign.start),
                        ],
                      ),
                      SizedBox(
                        width: displayWidth(context) * 0.05,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          vesselData!.regNumber! == ""
                              ? commonText(
                              context: context,
                              text: '-',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.04,
                              textAlign: TextAlign.start)
                              : commonText(
                              context: context,
                              text: vesselData!.regNumber,
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.038,
                              textAlign: TextAlign.start),
                          commonText(
                              context: context,
                              text: 'Registration Number',
                              fontWeight: FontWeight.w400,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.024,
                              textAlign: TextAlign.start),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: displayHeight(context) * 0.015,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (vesselData!.engineType!.isEmpty) SizedBox(),
                      if (vesselData!.engineType!.toLowerCase() ==
                          'combustion' &&
                          vesselData!.fuelCapacity != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/fuel.png',
                                  width: displayWidth(context) * 0.04,
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: '${vesselData!.fuelCapacity!} $liters'
                                        .toString(),
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              width: displayWidth(context) * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/combustion_engine.png',
                                  width: displayWidth(context) * 0.04,
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData!.engineType!,
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
                                    textAlign: TextAlign.start),
                              ],
                            )
                          ],
                        ),
                      if (vesselData!.engineType!.toLowerCase() == 'electric' &&
                          vesselData!.batteryCapacity != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    child: Image.asset(
                                      'assets/images/battery.png',
                                      width: displayWidth(context) * 0.026,
                                    )),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text:
                                    ' ${vesselData!.batteryCapacity!} $kiloWattHour'
                                        .toString(),
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              width: displayWidth(context) * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/electric_engine.png',
                                  width: displayWidth(context) * 0.04,
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData!.engineType!,
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
                                    textAlign: TextAlign.start),
                              ],
                            )
                          ],
                        ),
                      if (vesselData!.engineType!.toLowerCase() == 'hybrid')
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/fuel.png',
                                  width: displayWidth(context) * 0.04,
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData!.fuelCapacity == null
                                        ? '-'
                                        : '${vesselData!.fuelCapacity!} $liters'
                                        .toString(),
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              width: displayWidth(context) * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    child: Image.asset(
                                      'assets/images/battery.png',
                                      width: displayWidth(context) * 0.026,
                                    )),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text:
                                    ' ${vesselData!.batteryCapacity!} $kiloWattHour'
                                        .toString(),
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
                                    textAlign: TextAlign.start),
                              ],
                            ),
                            SizedBox(
                              width: displayWidth(context) * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/hybrid_engine.png',
                                  width: displayWidth(context) * 0.04,
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                commonText(
                                    context: context,
                                    text: vesselData!.engineType!,
                                    fontWeight: FontWeight.w400,
                                    textColor: Colors.white,
                                    textSize: displayWidth(context) * 0.028,
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
    );
    ;
  }
}
