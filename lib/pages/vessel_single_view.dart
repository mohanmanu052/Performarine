import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sqflite_example/models/vessel.dart';
import 'package:flutter_sqflite_example/pages/tripStart.dart';
import 'package:flutter_sqflite_example/services/database_service.dart';
import 'package:flutter_sqflite_example/widgets/common_widgets.dart';
import 'package:flutter_sqflite_example/widgets/status_tag.dart';

class VesselSingleView extends StatefulWidget {
 final CreateVessel? vessel;
  VesselSingleView({this.vessel});
  @override
  State createState() {
    return VesselSingleViewState();
  }
}

class VesselSingleViewState extends State<VesselSingleView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.vessel!.name}"),
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          // physics: const BouncingScrollPhysics(),
          children: <Widget>[
            ExpansionCard(widget.vessel,
                  (value) {
              },
                (value) {
            },(value) {
                },
              false
            ),
          ],
        ),
      ),
    );
  }
}

class ExpansionCard extends StatefulWidget {
  final CreateVessel? vessel;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;
  final bool isSingleView;
  ExpansionCard(this.vessel,this.onEdit,this.onTap,this.onDelete,this.isSingleView);

  @override
  State<ExpansionCard> createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  List<CreateVessel>? vessel=[];
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            // clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: (){

                 if (widget.isSingleView){
                   Navigator.of(context)
                       .push(
                     MaterialPageRoute(
                       builder: (_) => VesselSingleView(vessel: widget.vessel,),
                       fullscreenDialog: true,
                     ),
                   ).then((_) => setState(() {}));
                 }

              },
              child: Column(
                children: <Widget>[
                  //ToDo: vessel image need to be dynamic need to work on it
                  SizedBox(
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.rectangle,
                        image: DecorationImage(image: NetworkImage('https://thumbs.dreamstime.com/z/fisherman-boat-blue-sea-sky-clouds-landscape-background-close-up-beautiful-seascape-red-wooden-fishing-vessel-thailand-162902543.jpg'),
                        fit: BoxFit.cover
                      ),
                      ),
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
                          widget.vessel!.fuelCapacity!=null||widget.vessel!.fuelCapacity!=""?Text("Fuel : ${widget.vessel!.fuelCapacity}"):Container(),
                          Text("|",style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold),),
                          Text("Battery : ${widget.vessel!.batteryCapacity}"),
                          Text("|",style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold),),
                          Text("Engine : ${widget.vessel!.engineType}"),
                        ],
                      ),
                      expanded: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Container(
                            padding:EdgeInsets.symmetric(vertical:10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("Fuel : ${widget.vessel!.fuelCapacity}"),
                                Text("|",style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold),),
                                Text("Battery : ${widget.vessel!.batteryCapacity}"),
                                Text("|",style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold),),
                                Text("Engine : ${widget.vessel!.engineType}"),
                              ],
                            ),
                          ),

                          ListTile(
                            contentPadding: EdgeInsets.all(10),
                            title:Text("Measurements"),
                            subtitle: Column(
                              children: [
                                SizedBox(height: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Length (LOA) : ${widget.vessel!.lengthOverall}"),
                                    Text("Freeboard : ${widget.vessel!.freeBoard}")
                                  ],
                                ),
                                SizedBox(height: 10,),
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
                            title:Text("Vessel Particulars"),
                            subtitle: Column(
                              children: [
                                SizedBox(height: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Capacity : ${widget.vessel!.capacity}"),
                                    Text("Built Year : ${widget.vessel!.builtYear}"),
                                    Text("Reg No : ${widget.vessel!.regNumber}")
                                  ],
                                ),
                                SizedBox(height: 10,),
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



                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            // SizedBox(width: 20.0),
                            GestureDetector(
                              onTap: () => widget.onEdit(widget.vessel!),
                              child: Container(
                                height: 40.0,
                                width: MediaQuery.of(context).size.width*.4,
                                color: Colors.teal,
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
                              onTap: () =>widget.onDelete(widget.vessel!),
                              child: Container(
                                height: 40.0,
                                width: MediaQuery.of(context).size.width*.4,
                                color: Colors.teal,
                                alignment: Alignment.center,
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                          ],),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                // final DatabaseService _databaseService = DatabaseService();
                                vessel!.add(widget.vessel!);
                                // print(vessel[0].vesselName);
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (_) => StartTrip(vessels: vessel,context: context),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                              child: Container(

                                height: 40.0,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.teal,
                                // decoration: BoxDecoration(
                                //   shape: BoxShape.circle,
                                //   color: Colors.grey[200],
                                // ),
                                alignment: Alignment.center,
                                child: Text("Start Trip",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),

                        ],
                      ),
                      builder: (_, collapsed, expanded) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Expandable(
                            collapsed: widget.isSingleView?collapsed:expanded,
                            expanded: widget.isSingleView?expanded:collapsed,
                            theme: const ExpandableThemeData(crossFadePoint: 0),
                          ),
                        );
                      },
                    ),
                  // ),
                ],
              ),
            ),
          ),
        ));
  }
}
