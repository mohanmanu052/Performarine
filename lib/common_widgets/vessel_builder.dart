import 'package:flutter/material.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
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
    return FutureBuilder<List<CreateVessel>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(snapshot.hasData){
          // CreateVessel vessel= snapshot.data![0];
          // print("hello world: ${vessel.model.toString()}");
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final vessel = snapshot.data![index];
                return ExpansionCard(snapshot.data![index],widget.onEdit,widget.onTap,widget.onDelete,true);//_buildVesselCard(vessel, context);
              },
            ),
          );

        }
        return Container();
      },
    );
  }

  Widget _buildVesselCard(CreateVessel vessel, BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: ()=> widget.onTap(vessel),
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
                child: FaIcon(FontAwesomeIcons.ship,color: Colors.teal, size: 18.0),
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
