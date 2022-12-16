import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/vessel_single_view.dart';

class SuccessfullyAddedScreen extends StatefulWidget {
  final bool? isEdit;
  final CreateVessel? data;
  const SuccessfullyAddedScreen({Key? key, this.data, this.isEdit = false})
      : super(key: key);

  @override
  State<SuccessfullyAddedScreen> createState() =>
      _SuccessfullyAddedScreenState();
}

class _SuccessfullyAddedScreenState extends State<SuccessfullyAddedScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isEdit!) {
          Navigator.of(context).pop(true);
        } else {
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const AddNewVesselScreen(calledFrom: 'SuccessFullScreen')),
          );*/

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              ModalRoute.withName("SuccessFullScreen"));
        }

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Container(
          margin: EdgeInsets.symmetric(
              horizontal: displayHeight(context) * 0.03,
              vertical: displayHeight(context) * 0.02),
          child: CommonButtons.getActionButton(
              title: widget.isEdit! ? 'View Vessel' : 'Add More',
              context: context,
              fontSize: displayWidth(context) * 0.042,
              textColor: Colors.white,
              buttonPrimaryColor: buttonBGColor,
              borderColor: buttonBGColor,
              width: displayWidth(context),
              onTap: () {
                if (widget.isEdit!) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VesselSingleView(
                              vessel: widget.data!
                              // isCalledFromSuccessScreen: true,
                            )),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewVesselScreen(
                            calledFrom: 'SuccessFullScreen')),
                  );
                  /* Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                      ModalRoute.withName("SuccessFullScreen"));*/
                }
              }),
        ),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              if (widget.isEdit!) {
                Navigator.of(context).pop(true);
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
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
                  : 'Successfully Added',
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
                Container(
                    height: displayHeight(context) / 2,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: Lottie.asset('assets/lottie/done.json')),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VesselSingleView(
                                vessel: widget.data!,
                                // isCalledFromSuccessScreen: true,
                              )),
                    );
                  },
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
                    child: Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: widget.data!.imageURLs == null ||
                                    widget.data!.imageURLs!.isEmpty ||
                                    widget.data!.imageURLs == 'string'
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
                                            height:
                                                displayHeight(context) * 0.14,
                                            width: displayWidth(context),
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            decoration:
                                                BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
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
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: FileImage(File(widget.data!.imageURLs!)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      height:
                                      displayHeight(context) * 0.14,
                                      width: displayWidth(context),
                                      padding: const EdgeInsets.only(
                                          top: 20),
                                      decoration:
                                      BoxDecoration(boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.5),
                                            blurRadius: 50,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 50))
                                      ]),
                                    ))
                              ],
                            )
                            // CachedNetworkImage(
                            //         height: displayHeight(context) * 0.22,
                            //         width: displayWidth(context),
                            //         imageUrl: widget.data!.imageURLs![0],
                            //         imageBuilder: (context, imageProvider) =>
                            //             Stack(
                            //           children: [
                            //             Container(
                            //               decoration: BoxDecoration(
                            //                 borderRadius:
                            //                     BorderRadius.circular(10),
                            //                 image: DecorationImage(
                            //                   image: imageProvider,
                            //                   fit: BoxFit.fill,
                            //                 ),
                            //               ),
                            //             ),
                            //             Positioned(
                            //                 bottom: 0,
                            //                 right: 0,
                            //                 left: 0,
                            //                 child: Container(
                            //                   height:
                            //                       displayHeight(context) * 0.14,
                            //                   width: displayWidth(context),
                            //                   padding: const EdgeInsets.only(
                            //                       top: 20),
                            //                   decoration:
                            //                       BoxDecoration(boxShadow: [
                            //                     BoxShadow(
                            //                         color: Colors.black
                            //                             .withOpacity(0.5),
                            //                         blurRadius: 50,
                            //                         spreadRadius: 5,
                            //                         offset: const Offset(0, 50))
                            //                   ]),
                            //                 ))
                            //           ],
                            //         ),
                            //         progressIndicatorBuilder:
                            //             (context, url, downloadProgress) =>
                            //                 Center(
                            //           child: CircularProgressIndicator(
                            //               value: downloadProgress.progress),
                            //         ),
                            //         errorWidget: (context, url, error) =>
                            //             Icon(Icons.error),
                            //       ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              width: displayWidth(context),
                              //color: Colors.red,
                              margin: const EdgeInsets.only(
                                  left: 8, right: 0, bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        commonText(
                                            context: context,
                                            text: widget.data!.name!,
                                            fontWeight: FontWeight.w600,
                                            textColor: Colors.white,
                                            textSize:
                                                displayWidth(context) * 0.045,
                                            textAlign: TextAlign.start),
                                        dashboardRichText(
                                            modelName: widget.data!.model,
                                            builderName:
                                                widget.data!.builderName,
                                            context: context,
                                            color:
                                                Colors.white.withOpacity(0.8))
                                        /* Row(
                                          children: [
                                            commonText(
                                                context: context,
                                                text: widget.data!.model!,
                                                fontWeight: FontWeight.w500,
                                                textColor:
                                                    Colors.white.withOpacity(0.8),
                                                textSize:
                                                    displayWidth(context) * 0.034,
                                                textAlign: TextAlign.start),
                                            SizedBox(
                                              width: displayWidth(context) * 0.02,
                                            ),
                                            Container(
                                              height: displayHeight(context) * 0.02,
                                              color: Colors.white,
                                              width: displayWidth(context) * 0.0045,
                                            ),
                                            SizedBox(
                                              width: displayWidth(context) * 0.02,
                                            ),
                                            commonText(
                                                context: context,
                                                text: widget.data!.builderName!,
                                                fontWeight: FontWeight.w500,
                                                textColor:
                                                    Colors.white.withOpacity(0.8),
                                                textSize:
                                                    displayWidth(context) * 0.034,
                                                textAlign: TextAlign.start),
                                          ],
                                        )*/
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    //width: displayWidth(context) * 0.28,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        widget.data!.engineType!.isEmpty
                                            ? const SizedBox()
                                            : widget.data!.engineType!
                                                        .toLowerCase() ==
                                                    'combustion'
                                                ? widget.data!.fuelCapacity ==
                                                        null
                                                    ? const SizedBox()
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/fuel.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.045,
                                                              ),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02,
                                                              ),
                                                              commonText(
                                                                  context:
                                                                      context,
                                                                  text: '${widget.data!.fuelCapacity!}gal'
                                                                      .toString(),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  textSize:
                                                                      displayWidth(
                                                                              context) *
                                                                          0.03,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: displayHeight(
                                                                    context) *
                                                                0.005,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/combustion_engine.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.045,
                                                              ),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02,
                                                              ),
                                                              commonText(
                                                                  context:
                                                                      context,
                                                                  text: widget
                                                                      .data!
                                                                      .engineType!,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  textSize:
                                                                      displayWidth(
                                                                              context) *
                                                                          0.03,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start),
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                : widget.data!.engineType!
                                                            .toLowerCase() ==
                                                        'electric'
                                                    ? widget.data!
                                                                .batteryCapacity ==
                                                            null
                                                        ? const SizedBox()
                                                        : Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              4),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/battery.png',
                                                                        width: displayWidth(context) *
                                                                            0.027,
                                                                      )),
                                                                  SizedBox(
                                                                    width: displayWidth(
                                                                            context) *
                                                                        0.02,
                                                                  ),
                                                                  commonText(
                                                                      context:
                                                                          context,
                                                                      text: ' ${widget.data!.batteryCapacity!} kw'
                                                                          .toString(),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      textSize:
                                                                          displayWidth(context) *
                                                                              0.03,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: displayHeight(
                                                                        context) *
                                                                    0.005,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/electric_engine.png',
                                                                    width: displayWidth(
                                                                            context) *
                                                                        0.045,
                                                                  ),
                                                                  SizedBox(
                                                                    width: displayWidth(
                                                                            context) *
                                                                        0.02,
                                                                  ),
                                                                  commonText(
                                                                      context:
                                                                          context,
                                                                      text: widget
                                                                          .data!
                                                                          .engineType!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      textSize:
                                                                          displayWidth(context) *
                                                                              0.03,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start),
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/fuel.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.045,
                                                              ),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02,
                                                              ),
                                                              commonText(
                                                                  context:
                                                                      context,
                                                                  text: '${widget.data!.fuelCapacity!}gal'
                                                                      .toString(),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  textSize:
                                                                      displayWidth(
                                                                              context) *
                                                                          0.03,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: displayHeight(
                                                                    context) *
                                                                0.005,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 4),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/battery.png',
                                                                    width: displayWidth(
                                                                            context) *
                                                                        0.027,
                                                                  )),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02,
                                                              ),
                                                              commonText(
                                                                  context:
                                                                      context,
                                                                  text: ' ${widget.data!.batteryCapacity!} kw'
                                                                      .toString(),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  textSize:
                                                                      displayWidth(
                                                                              context) *
                                                                          0.03,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: displayHeight(
                                                                    context) *
                                                                0.005,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/hybrid_engine.png',
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.045,
                                                              ),
                                                              SizedBox(
                                                                width: displayWidth(
                                                                        context) *
                                                                    0.02,
                                                              ),
                                                              commonText(
                                                                  context:
                                                                      context,
                                                                  text: widget
                                                                      .data!
                                                                      .engineType!,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  textSize:
                                                                      displayWidth(
                                                                              context) *
                                                                          0.03,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start),
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
                  ),
                ),
                widget.isEdit!
                    ? SizedBox()
                    : Column(
                        children: [
                          SizedBox(
                            height: displayHeight(context) * 0.03,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePage(),
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
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
