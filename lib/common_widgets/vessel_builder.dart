import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/services/database_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VesselBuilder extends StatefulWidget {
  const VesselBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);
  final Future<List<CreateVessel>> future;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;

  @override
  State<VesselBuilder> createState() => _VesselBuilderState();
}

class _VesselBuilderState extends State<VesselBuilder> {
  Future<String> getTripName(String id) async {
    final DatabaseService _databaseService = DatabaseService();
    final Trip = await _databaseService.getTrip(id);
    return Trip.vesselId!;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<CreateVessel>>(
          future: widget.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              // CreateVessel vessel= snapshot.data![0];
              // print("hello world: ${vessel.model.toString()}");
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final vessel = snapshot.data![index];
                    return vesselSingleViewCard(
                      vessel,
                    );

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
            return Container();
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
            child: CommonButtons.getActionButton(
                title: 'Add Vessel',
                context: context,
                fontSize: displayWidth(context) * 0.042,
                textColor: Colors.white,
                buttonPrimaryColor: buttonBGColor,
                borderColor: buttonBGColor,
                width: displayWidth(context),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewVesselScreen()),
                  );
                }),
          ),
        )
      ],
    );
  }

  Widget _buildVesselCard(CreateVessel vessel, BuildContext context) {
    return Card(
      color: Colors.red,
      child: GestureDetector(
        onTap: () => widget.onTap(vessel),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: FaIcon(FontAwesomeIcons.ship,
                    color: Colors.teal, size: 18.0),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vessel.name.toString(),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    //ToDo: dynamic query featch from table
                    // FutureBuilder<String>(
                    //   future: getTripName(),
                    //   builder: (context, snapshot) {
                    //     return Text('Trip: ${snapshot.data}');
                    //   },
                    // ),
                    SizedBox(height: 4.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MMSI: ${vessel.mMSI.toString()}}'),
                        Text('Builder:  ${vessel.builderName.toString()}'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.0),
              GestureDetector(
                onTap: () => widget.onEdit(vessel),
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.edit, color: Colors.orange[800]),
                ),
              ),
              SizedBox(width: 20.0),
              GestureDetector(
                onTap: () => widget.onDelete(vessel),
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.delete, color: Colors.red[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget vesselSingleViewCard(CreateVessel vesselData) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VesselSingleView(
              vessel: vesselData,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      child: Card(
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
                  : CachedNetworkImage(
                      height: displayHeight(context) * 0.22,
                      width: displayWidth(context),
                      imageUrl: vesselData.imageURLs![0],
                      imageBuilder: (context, imageProvider) => Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
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
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
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
}
