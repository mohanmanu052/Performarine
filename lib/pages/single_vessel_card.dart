import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/services/database_service.dart';

class SingleVesselCard extends StatefulWidget {
  final CreateVessel? vessel;
  final Function(CreateVessel)? onTap;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SingleVesselCard(this.vessel, this.onTap, this.scaffoldKey, {Key? key})
      : super(key: key);

  @override
  State<SingleVesselCard> createState() => _SingleVesselCardState();
}

class _SingleVesselCardState extends State<SingleVesselCard> {
  DatabaseService databaseService = DatabaseService();

  bool isTripRunning = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkTripRunning();
  }

  /// To Check trip is running or not
  checkTripRunning() async {
    bool result = await databaseService
        .checkIfTripIsRunningForSpecificVessel(widget.vessel!.id!);
    if (mounted) {
      setState(() {
        isTripRunning = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return vesselSingleViewCard(
      context,
      widget.vessel!,
      (CreateVessel value) {
        widget.onTap!(value);
      },
      widget.scaffoldKey,
      isTripIsRunning: isTripRunning,
    );
  }
}
