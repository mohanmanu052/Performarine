import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/services/database_service.dart';

class FleetDetailsCard extends StatefulWidget {
  GlobalKey<ScaffoldState>? scaffoldKey;
   FleetDetailsCard({super.key,this.scaffoldKey});
  @override
  State<FleetDetailsCard> createState() => _FleetDetailsCardState();
}

class _FleetDetailsCardState extends State<FleetDetailsCard> {
    final DatabaseService _databaseService = DatabaseService();
  late Future<List<CreateVessel>> getVesselFuture;

  @override
  void initState() {
            getVesselFuture = _databaseService.vessels();

    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return          SingleChildScrollView(
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: backgroundColor,
                  child: FutureBuilder<List<CreateVessel>>(
                    future: getVesselFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(circularProgressColor),
                          ),
                        );
                      }
                      Utils.customPrint('Fleet Vessel HAS DATA: ${snapshot.hasData}');
                      Utils.customPrint('Fleet Vessel Error: ${snapshot.error}');
                      Utils.customPrint('Fleet Vessel IsError: ${snapshot.hasError}');
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(top: displayHeight(context) * 0.43),
                            child: Center(
                              child: commonText(
                                  context: context,
                                  text: 'No vessels available'.toString(),
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.start),
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              Container(
                                // height: displayHeight(context),
                                color: backgroundColor,
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 8, bottom: 10),
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  primary: false,
                                  shrinkWrap: true,
                                  //physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final vessel = snapshot.data![index];
                                    return snapshot.data![index].vesselStatus == 1
                                        ? vesselSingleViewCard(context, vessel,
                                            (CreateVessel value) {
      
                                            }, widget.scaffoldKey!,isOwnerNameVisible: true,ownerName: 'abc456@gmail.com')
                                        : SizedBox();
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      }
                      return Container();
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