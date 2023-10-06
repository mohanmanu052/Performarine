

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:provider/provider.dart';

import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/constants.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/vessel_builder.dart';
import '../common_widgets/widgets/common_widgets.dart';
import '../models/vessel.dart';
import '../old_ui/old_vessel_single_view.dart';
import '../provider/common_provider.dart';
import '../services/database_service.dart';

class VesselsScreen extends StatefulWidget {
  const VesselsScreen({Key? key}) : super(key: key);

  @override
  State<VesselsScreen> createState() => _VesselsScreenState();
}

class _VesselsScreenState extends State<VesselsScreen> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  late Future<List<CreateVessel>> getVesselFuture;
  late CommonProvider commonProvider;

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    commonProvider = context.read<CommonProvider>();
    getVesselFuture = _databaseService.vessels();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      backgroundColor: backgroundColor,
      key: scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Padding(
            padding: EdgeInsets.only(
              left: displayWidth(context) * 0.06,
              top: displayHeight(context) * 0.01,
              bottom: displayHeight(context) * 0.01,
            ),
            child: SizedBox(
              height: displayHeight(context) * 0.02,
              child: commonText(
                  context: context,
                  text:
                  'Overview',
                  fontWeight: FontWeight.w700,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.04,
                  textAlign: TextAlign.center,
                fontFamily: outfit
              ),
            ),
          ),*/
          Expanded(
            child: VesselBuilder(
              future: getVesselFuture,
              onEdit: (value) async {
                {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => VesselFormPage(vessel: value),
                      fullscreenDialog: true,
                    ),
                  )
                      .then((_) => setState(() {}));
                }
              },
              onTap: (value) async {
                {
                  var result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VesselSingleView(
                        vessel: value,
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                  commonProvider.getTripsCount();
                  if (result != null) {
                    Utils.customPrint('RESULT HOME PAGE $result');
                    if (result) {
                      setState(() {
                        getVesselFuture = _databaseService.vessels();
                        // _getTripsCount();
                        // setState(() {});
                      });
                    }
                  }
                }
              },
              onDelete: _onVesselDelete,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ],
      ),
    );
  }
}
