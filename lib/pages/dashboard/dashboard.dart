import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:performarine/old_ui/old_vessel_single_view.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../analytics/end_trip.dart';
import '../../analytics/location_callback_handler.dart';
import '../../analytics/start_trip.dart';
import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/vessel_builder.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_search_field.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../main.dart';
import '../../models/vessel.dart';
import '../../provider/common_provider.dart';
import '../../services/database_service.dart';
import 'package:performarine/pages/auth/reset_password.dart';
import '../vessel_form.dart';
import '../vessel_single_view.dart';

class Dashboard extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isComingFromReset, isAppKilled;
  String token;
  Dashboard({Key? key, this.tripData = const [], this.tabIndex = 0, this.isComingFromReset,this.token = "", this.isAppKilled = false}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin, WidgetsBindingObserver{

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  late CommonProvider commonProvider;
  final controller = ScreenshotController();
  late Future<List<CreateVessel>> getVesselFuture;
  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    commonProvider = context.read<CommonProvider>();
    commonProvider.init();
    commonProvider.getTripsCount();

    getVesselFuture = _databaseService.vessels();

    sharedPreferences!.remove('sp_key_called_from_noti');

    Utils.customPrint("IS APP KILLED FROM BG ${widget.isAppKilled}");

    bool? isTripStarted = sharedPreferences!.getBool('trip_started');

    Utils.customPrint("IS APP KILLED FROM BG 1212 $isTripStarted");
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: () async {
        return Utils.onAppExitCallBack(context, scaffoldKey);
      },
        child: Screenshot(
          controller: controller,
            child: Scaffold(
              backgroundColor: backgroundColor,
              key: scaffoldKey,
              body: Column(
                children: [
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
            ),
        ),
    );
  }
}
