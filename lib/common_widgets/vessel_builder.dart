import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/single_vessel_card.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

class VesselBuilder extends StatefulWidget {
  const VesselBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
    required this.onTap,
    required this.onDelete,
    required this.scaffoldKey,
  }) : super(key: key);
  final Future<List<CreateVessel>> future;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<VesselBuilder> createState() => _VesselBuilderState();
}

class _VesselBuilderState extends State<VesselBuilder> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<CreateVessel>>(
          future: widget.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(circularProgressColor),
                ),
              );
            }
            print('HAS DATA: ${snapshot.hasData}');
            print('HAS DATA: ${snapshot.error}');
            print('HAS DATA: ${snapshot.hasError}');
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/vessel_default_img.png',
                        height: displayHeight(context) * 0.28,
                      ),
                      commonText(
                          context: context,
                          text: 'No vessels available'.toString(),
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.04,
                          textAlign: TextAlign.start),
                    ],
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 70),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vessel = snapshot.data![index];
                      return vessel.vesselStatus == 1
                          ? SingleVesselCard(vessel, (CreateVessel value) {
                              widget.onTap(value);
                            }, widget.scaffoldKey!)
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
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            // color: Colors.transparent,
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
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const VesselFormPage()),
                  // );
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
}
