import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/fleet_details_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

class FleetDetailsCard extends StatefulWidget {
  List<FleetVessels>? fleetVesselsList;
  GlobalKey<ScaffoldState>? scaffoldKey;
   FleetDetailsCard({super.key,this.scaffoldKey, this.fleetVesselsList});
  @override
  State<FleetDetailsCard> createState() => _FleetDetailsCardState();
}

class _FleetDetailsCardState extends State<FleetDetailsCard> {
    final DatabaseService _databaseService = DatabaseService();
  late Future<List<CreateVessel>> getVesselFuture;

  late CommonProvider commonProvider;

  @override
  void initState() {
   // getVesselFuture = _databaseService.vessels();
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
  }
  @override
  Widget build(BuildContext context) {

    commonProvider = context.watch<CommonProvider>();

    debugPrint("FLEET VESSEL LIST LENGTH ${widget.fleetVesselsList!.length}");
    return widget.fleetVesselsList == null || widget.fleetVesselsList!.isEmpty
        ? Center(
      child: commonText(
          context: context,
          text: 'No data found',
          fontWeight: FontWeight.w500,
          textColor: Colors.black,
          textSize: displayWidth(context) * 0.045,
          textAlign: TextAlign.start),
    )
        : SingleChildScrollView(
      child:   Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: backgroundColor,
                  child: ListView.builder(
                    itemCount: widget.fleetVesselsList!.length,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      debugPrint("FLEETS I M IN LENGTH ${widget.fleetVesselsList!.length}");
                      final vessel = widget.fleetVesselsList![index];
                      debugPrint("FLEETS I M IN LENGTH 1 ${vessel.vesselInfo!.mMSI == ''}");
                      return fleetVesselSingleViewCard(
                          context, vessel,
                            (FleetVessels value) {
                              CreateVessel vesselData = CreateVessel(
                                  id: value.vesselInfo!.sId,
                                  name: value.vesselInfo!.name ?? '',
                                  builderName: value.vesselInfo!.builderName ?? '',
                                  model: value.vesselInfo!.model ?? '',
                                  regNumber: value.vesselInfo!.regNumber ?? '',
                                  mMSI: value.vesselInfo!.mMSI ?? '',
                                  engineType: value.vesselInfo!.engineType ?? '',
                                  fuelCapacity: value.vesselInfo!.fuelCapacity.toString(),
                                  batteryCapacity:value.vesselInfo!.batteryCapacity.toString(),
                                  weight: value.vesselInfo!.weight ?? '',
                                  freeBoard: value.vesselInfo!.freeBoard!,
                                  lengthOverall: value.vesselInfo!.lengthOverall!,
                                  beam: value.vesselInfo!.beam!,
                                  draft: value.vesselInfo!.depth!,
                                  vesselSize: value.vesselInfo!.vesselSize.toString() ?? '',
                                  capacity: int.parse(value.vesselInfo!.capacity ?? '0'),
                                  builtYear: int.parse(value.vesselInfo!.builtYear.toString()),
                                  vesselStatus: int.parse(value.vesselInfo!.vesselStatus.toString()),
                                  imageURLs:  '',
                                  createdAt: value.vesselInfo!.createdAt.toString(),
                                  createdBy: value.vesselInfo!.createdBy.toString(),
                                  updatedAt: value.vesselInfo!.updatedAt.toString(),
                                  isSync: 1,
                                  updatedBy: value.vesselInfo!.updatedBy.toString(),
                                  isCloud: 1,
                                  hullType: value.vesselInfo!.hullShape
                              );
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> VesselSingleView(
                          //   vessel: vesselData,
                          //   isCalledFromFleetScreen: true,
                          // )));
                        }, widget.scaffoldKey!,
                        commonProvider.loginModel!.userId!,
                      );
                    },
                  ),
                ),
      
                SizedBox(
                  height: displayWidth(context) * 0.04,
                )
              ],
            ),
    );

  }
}