import 'dart:io';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/services/database_service.dart';

class RetiredVesselsScreen extends StatefulWidget {
  const RetiredVesselsScreen({Key? key}) : super(key: key);

  @override
  State<RetiredVesselsScreen> createState() => _RetiredVesselsScreenState();
}

class _RetiredVesselsScreenState extends State<RetiredVesselsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late Future<List<CreateVessel>> getVesselFuture;

  bool isUnretire = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getVesselFuture = _databaseService.getRetiredVesselsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          text: 'Retried Vessels',
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
          textSize: displayWidth(context) * 0.045,
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<CreateVessel>>(
          future: getVesselFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            print('HAS DATA: ${snapshot.hasData}');
            print('HAS DATA: ${snapshot.error}');
            print('HAS DATA: ${snapshot.hasError}');
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: commonText(
                      context: context,
                      text: 'No vessels available'.toString(),
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.start),
                );
              } else {
                return Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 70),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vessel = snapshot.data![index];
                      return snapshot.data![index].isRetire == 1
                          ? vesselSingleViewCard(
                              vessel,
                            )
                          : SizedBox();

                      /*  ExpansionCard(
                        snapshot.data![index],
                        widget.onEdit,
                        widget.onTap,
                        widget.onDelete,
                        true);*/ //_buildVesselCard(vessel, context);
                    },
                  ),
                );
              }
              // CreateVessel vessel= snapshot.data![0];
              // print("hello world: ${vessel.model.toString()}");

            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget vesselSingleViewCard(CreateVessel vesselData) {
    return GestureDetector(
      onTap: () {
        //widget.onTap(vesselData);
      },
      child: Card(
        color: Colors.black,
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: vesselData.imageURLs == null ||
                        vesselData.imageURLs!.isEmpty ||
                        vesselData.imageURLs == 'string'
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
                          Image.file(
                            File(vesselData.imageURLs!),
                            fit: BoxFit.cover,
                            height: displayHeight(context) * 0.22,
                            width: displayWidth(context),
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
                // CachedNetworkImage(
                //         height: displayHeight(context) * 0.22,
                //         width: displayWidth(context),
                //         imageUrl: vesselData.imageURLs!,
                //
                //         imageBuilder: (context, imageProvider) => Stack(
                //           children: [
                //             Container(
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(14),
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
                //                   height: displayHeight(context) * 0.14,
                //                   width: displayWidth(context),
                //                   padding: const EdgeInsets.only(top: 20),
                //                   decoration: BoxDecoration(boxShadow: [
                //                     BoxShadow(
                //                         color: Colors.black.withOpacity(0.5),
                //                         blurRadius: 50,
                //                         spreadRadius: 5,
                //                         offset: const Offset(0, 50))
                //                   ]),
                //                 ))
                //           ],
                //         ),
                //         progressIndicatorBuilder:
                //             (context, url, downloadProgress) => Center(
                //           child: CircularProgressIndicator(
                //               value: downloadProgress.progress),
                //         ),
                //         errorWidget: (context, url, error) => Icon(Icons.error),
                //       ),
                ),
            Positioned(
              top: 5,
              right: 10,
              child: CommonButtons.getTextButton(
                  title: 'Unretire',
                  context: context,
                  textColor: Colors.white,
                  textSize: displayWidth(context) * 0.04,
                  isClickLink: false,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    showDialogBox(vesselData);
                  }),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: displayWidth(context),
                //color: Colors.red,
                margin: const EdgeInsets.only(left: 8, right: 0, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vesselData.name == "" ? '-' : vesselData.name!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: displayWidth(context) * 0.045,
                              color: Colors.white,
                              fontFamily: poppins,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                          ),
                          dashboardRichText(
                              modelName: vesselData.model,
                              builderName: vesselData.builderName,
                              context: context,
                              color: Colors.white.withOpacity(0.8))
                        ],
                      ),
                    ),
                    SizedBox(
                      width: displayWidth(context) * 0.04,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      //width: displayWidth(context) * 0.28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          vesselData.engineType!.isEmpty
                              ? const SizedBox()
                              : vesselData.engineType!.toLowerCase() ==
                                      'combustion'
                                  ? vesselData.fuelCapacity == null
                                      ? const SizedBox()
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                        '${vesselData.fuelCapacity!}gal'
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
                                              height: displayHeight(context) *
                                                  0.005,
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
                                                    text:
                                                        vesselData.engineType!,
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.white,
                                                    textSize:
                                                        displayWidth(context) *
                                                            0.03,
                                                    textAlign: TextAlign.start),
                                              ],
                                            )
                                          ],
                                        )
                                  : vesselData.engineType!.toLowerCase() ==
                                          'electric'
                                      ? vesselData.batteryCapacity == null
                                          ? const SizedBox()
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 4),
                                                        child: Image.asset(
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
                                                        context: context,
                                                        text:
                                                            ' ${vesselData.batteryCapacity!} kw'
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
                                                  height:
                                                      displayHeight(context) *
                                                          0.005,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
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
                                                        context: context,
                                                        text: vesselData
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
                                            )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                    text: vesselData
                                                                .fuelCapacity ==
                                                            null
                                                        ? '-'
                                                        : '${vesselData.fuelCapacity!}gal'
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
                                              height: displayHeight(context) *
                                                  0.005,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                  width: displayWidth(context) *
                                                      0.02,
                                                ),
                                                commonText(
                                                    context: context,
                                                    text:
                                                        ' ${vesselData.batteryCapacity!} kw'
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
                                              height: displayHeight(context) *
                                                  0.005,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                    text:
                                                        vesselData.engineType!,
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
    );
  }

  showDialogBox(CreateVessel vesselData) {
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
                  height: displayHeight(context) * 0.3,
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
                                  text: 'Do you want to unretire the vessel?',
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
                                      'The vessel will be visible in your vessel list and you can record trips with it again',
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
                                    setState(() {
                                      isUnretire = false;
                                    });
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
                                      'OK', context, primaryColor, () async {
                                    await _databaseService
                                        .updateRetireStatus(0, vesselData.id!)
                                        .then((value) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                          ModalRoute.withName(""));
                                    });
                                  },
                                      displayWidth(context) * 0.4,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.018,
                                      primaryColor,
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
}
