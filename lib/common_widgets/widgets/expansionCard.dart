import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/trip/trip_list_screen.dart';
import 'package:performarine/pages/vessel_single_view.dart';

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
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Card(
      // clipBehavior: Clip.antiAlias,

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
            //ToDo: vessel image need to be dynamic need to work on it
            SizedBox(
              height: 150,
              child: Stack(
                children: [
                  widget.vessel!.imageURLs == null ||
                          widget.vessel!.imageURLs!.isEmpty ||
                          widget.vessel!.imageURLs == 'string'
                      ? Container(
                          decoration: BoxDecoration(
                            // color: Colors.orange,
                            color: Colors.black,
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                "assets/images/dashboard_bg_image.png",
                              ),
                              // fit: BoxFit.cover
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(widget.vessel!.imageURLs!)),
                              // fit: BoxFit.cover
                            ),
                          ),
                        ),
                  !widget.isSingleView
                      ? Positioned(
                          right: 10,
                          top: 10,
                          child: Row(
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
                              /*CircleAvatar(
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
                                    await widget.onDelete(widget.vessel!);
                                    Utils.showSnackBar(context,
                                        scaffoldKey: widget.scaffoldKey,
                                        message:
                                        'Vessel Deleted Successfully');
                                    //ToDo: @rupali add the timer of 500 ms then navigate
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => HomePage(),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),*/
                            ],
                          ),
                          // Container(
                          //   height: 30,
                          //   width: 30,
                          //   // decoration: BoxDecoration(
                          //   //     shape: BoxShape.circle, color: backgroundColor),
                          //   child: Center(
                          //     child: IconButton(
                          //
                          //         onPressed: () {
                          //
                          //         },
                          //         icon: Icon(Icons.delete, color: buttonBGColor,size: 20,)),
                          //   ),
                          // ),
                        )
                      : Container()
                ],
              ),
            ),

            // ScrollOnExpand(
            //   scrollOnExpand: true,
            //   scrollOnCollapse: false,
            //   child:
            ExpandablePanel(
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
              collapsed: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.vessel!.fuelCapacity != null ||
                          widget.vessel!.fuelCapacity != ""
                      ? Text("Fuel : ${widget.vessel!.fuelCapacity}")
                      : Container(),
                  Text(
                    "|",
                    style: TextStyle(
                        color: letsGetStartedButtonColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text("Battery : ${widget.vessel!.batteryCapacity}"),
                  Text(
                    "|",
                    style: TextStyle(
                        color: letsGetStartedButtonColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text("Engine : ${widget.vessel!.engineType}"),
                ],
              ),
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                        Text("Battery : ${widget.vessel!.batteryCapacity}"),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Length (LOA) : ${widget.vessel!.lengthOverall}"),
                            Text("Freeboard : ${widget.vessel!.freeBoard}")
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Capacity : ${widget.vessel!.capacity}"),
                            Text("Built Year : ${widget.vessel!.builtYear}"),
                            Text("Reg No : ${widget.vessel!.regNumber}")
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Weight : ${widget.vessel!.weight}"),
                            Text("Size (hp) : ${widget.vessel!.vesselSize}"),
                            Text("MMSI : ${widget.vessel!.mMSI}")
                          ],
                        )
                      ],
                    ),
                  ),
                  /*   Row(
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
                      ),*/
                  widget.isSingleView
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              // final DatabaseService _databaseService = DatabaseService();
                              vessel!.add(widget.vessel!);
                              // print(vessel[0].vesselName);
                              /*Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    StartTrip(vessels: vessel, context: context),
                                fullscreenDialog: true,
                              ),
                            );*/

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
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Expandable(
                    collapsed: widget.isSingleView ? collapsed : expanded,
                    expanded: widget.isSingleView ? expanded : collapsed,
                    theme: const ExpandableThemeData(crossFadePoint: 0),
                  ),
                );
              },
            ),
            // ),
          ],
        ),
      ),
    ));
  }
}
