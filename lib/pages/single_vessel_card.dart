import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

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

  late CommonProvider commonProvider;

  @override
  void initState() {
    //     SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);

    // TODO: implement initState
    super.initState();

    checkTripRunning();

    commonProvider = context.read<CommonProvider>();
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
    commonProvider = context.watch<CommonProvider>();
    return vesselSingleViewCard(
      context,
      widget.vessel!,
      commonProvider.loginModel!.userId!,
      (CreateVessel value) {
        widget.onTap!(value);
      },
      widget.scaffoldKey,
      isTripIsRunning: isTripRunning,
    );
  }
}
