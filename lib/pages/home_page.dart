import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/vessel_builder.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  HomePage({Key? key, this.tripData = const [], this.tabIndex = 0})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late TabController tabController;

  late CommonProvider commonProvider;
  List<Trip> trips = [];
  int tripsCount = 0;
  int currentTabIndex = 0;

  late Future<List<CreateVessel>> getVesselFuture;

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  DeviceInfo? deviceDetails;

  List<String> tripData = [];

  @override
  void initState() {
    super.initState();

    commonProvider = context.read<CommonProvider>();
    commonProvider.init();
    commonProvider.getTripsCount();

    getVesselFuture = _databaseService.vessels();

    sharedPreferences!.remove('sp_key_called_from_noti');

    tabController =
        TabController(initialIndex: widget.tabIndex, length: 2, vsync: this);
    currentTabIndex = widget.tabIndex;
    tabController.addListener(() {
      setState(() {
        currentTabIndex = tabController.index;
      });
    });
  }

  checkNotificationPermission() async {
    bool isNotificationPermitted = await Permission.notification.isGranted;

    if (!isNotificationPermitted) {
      await Utils.getNotificationPermission(context);
    }
  }

  //TODO future reference code
  /*@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    tripData = widget.tripData;

    if (tripData.isNotEmpty) {
      String tripId = tripData[0];
      String vesselId = tripData[1];
      String vesselName = tripData[2];
      String vesselWeight = tripData[3];

      Utils.customPrint('TRIP DATA: $tripId * $vesselId * $vesselName');

      widget.tripData = [];
      Future.delayed(Duration(milliseconds: 300), () {
        widget.tripData = [];
        Utils().showEndTripDialog(context, () async {
          CreateTrip().endTrip(
              context: context,
              scaffoldKey: scaffoldKey,
              onEnded: () {
                widget.tripData = [];
                Navigator.pop(context);
              });
        }, () {
          widget.tripData = [];
          Navigator.of(context).pop();
        });
        // showAlertDialog(context, tripId, vesselId, vesselName, vesselWeight);
      });
    }
  }*/

  fetchDeviceData() async {
    await fetchDeviceInfo();

    deviceDetails = Platform.isAndroid
        ? DeviceInfo(
            board: androidDeviceInfo?.board,
            deviceId: androidDeviceInfo?.id,
            deviceType: androidDeviceInfo?.type,
            make: androidDeviceInfo?.manufacturer,
            model: androidDeviceInfo?.model,
            version: androidDeviceInfo?.version.release)
        : DeviceInfo(
            board: iosDeviceInfo?.utsname.machine,
            deviceId: '',
            deviceType: iosDeviceInfo?.utsname.machine,
            make: iosDeviceInfo?.utsname.machine,
            model: iosDeviceInfo?.model,
            version: iosDeviceInfo?.utsname.release);
    Utils.customPrint("deviceDetails:${deviceDetails!.toJson().toString()}");
  }

  fetchDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("APP STATE - app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("APP STATE - app in inactive");
        break;
      case AppLifecycleState.paused:
        print("APP STATE - app in paused");
        break;
      case AppLifecycleState.detached:
        print("APP STATE - app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return WillPopScope(
      onWillPop: () async {
        return Utils.onAppExitCallBack(context, scaffoldKey);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            leading: InkWell(
              onTap: () {
                scaffoldKey.currentState!.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Image.asset(
                  'assets/images/menu.png',
                ),
              ),
            ),
            title: Container(
              width: MediaQuery.of(context).size.width / 2,
              // color: Colors.yellow,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    WidgetSpan(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/lognotitle.png",
                          height: 50,
                          width: 50,
                        ),
                        commonText(
                          context: context,
                          text: 'PerforMarine',
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black87,
                          textSize: displayWidth(context) * 0.045,
                        ),
                      ],
                    )),
                    // TextSpan(
                    //   text: " to add",
                    // ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: tabController,
              padding: EdgeInsets.all(0),
              labelPadding: EdgeInsets.zero,
              isScrollable: true,
              indicatorColor: Colors.white,
              onTap: (int value) {
                setState(() {
                  currentTabIndex = value;
                });
              },
              tabs: [
                Container(
                  margin: EdgeInsets.only(right: 2),
                  width: displayWidth(context) * 0.45,
                  decoration: BoxDecoration(
                      color:
                          currentTabIndex == 0 ? buttonBGColor : Colors.white,
                      border: Border.all(color: buttonBGColor),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9.0),
                    child: commonText(
                      context: context,
                      text: 'Vessels',
                      fontWeight: FontWeight.w500,
                      textColor:
                          currentTabIndex == 0 ? Colors.white : Colors.black,
                      textSize: displayWidth(context) * 0.036,
                    ),
                    // Text('Vessels'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 2),
                  width: displayWidth(context) * 0.45,
                  decoration: BoxDecoration(
                      color:
                          currentTabIndex == 1 ? buttonBGColor : Colors.white,
                      border: Border.all(color: buttonBGColor),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9.0),
                    child: commonText(
                      context: context,
                      text:
                          'Activity (${commonProvider.tripsCount.toString()})',
                      fontWeight: FontWeight.w500,
                      textColor:
                          currentTabIndex == 1 ? Colors.white : Colors.black,
                      textSize: displayWidth(context) * 0.036,
                    ),
                    // Text('Activity (${tripsCount.toString()})'),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
          ),
          drawer: CustomDrawer(
            scaffoldKey: scaffoldKey,
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              VesselBuilder(
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
              SingleChildScrollView(
                child: TripViewListing(
                  scaffoldKey: scaffoldKey,
                  calledFrom: 'HomePage',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
