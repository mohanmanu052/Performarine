import 'dart:async';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:performarine/analytics/end_trip.dart';
import 'package:performarine/analytics/start_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/vessel_builder.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/device_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/auth/reset_password.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../analytics/location_callback_handler.dart';
import '../common_widgets/utils/constants.dart';
import '../common_widgets/widgets/user_feed_back.dart';
import 'feedback_report.dart';

class HomePage extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isComingFromReset, isAppKilled;
  String token;
  HomePage({Key? key, this.tripData = const [], this.tabIndex = 0, this.isComingFromReset,this.token = "", this.isAppKilled = false})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late TabController tabController;

  late CommonProvider commonProvider;
  List<Trip> trips = [];
  int tripsCount = 0;
  int currentTabIndex = 0;

  bool isEndTripBtnClicked = false, locationAccuracy = false;

  late Future<List<CreateVessel>> getVesselFuture;

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  DeviceInfo? deviceDetails;

  List<String> tripData = [];

  final controller = ScreenshotController();

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    dynamic arg = Get.arguments;
    if(arg !=  null)
    {
      Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      bool isComingFrom = arguments?['isComingFromReset'] ?? false;
      String updatedToken = arguments?['token'] ?? "";

      setState(() {});


    Utils.customPrint("isComingFromReset: ${isComingFrom}");
      if(mounted){
        if(isComingFrom != null && isComingFrom )
        {

          Future.delayed(Duration(microseconds: 500), (){
            Utils.customPrint("XXXXXXXXX ${_isThereCurrentDialogShowing(context)}");

            if(!_isThereCurrentDialogShowing(context))
            {
              WidgetsBinding.instance.addPostFrameCallback((duration)
              {
                showResetPasswordDialogBox(context,updatedToken);
              });
            }

          });


        }
      }
      Utils.customPrint('HomeScreen did update');
    }
  }

  @override
  void initState() {
    super.initState();
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    WidgetsBinding.instance.addObserver(this);

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

    Utils.customPrint("IS APP KILLED FROM BG ${widget.isAppKilled}");

    bool? isTripStarted = sharedPreferences!.getBool('trip_started');

    Utils.customPrint("IS APP KILLED FROM BG 1212 $isTripStarted");

    if(widget.isAppKilled!)
    {
      if(isTripStarted != null)
      {
        if(isTripStarted)
        {
          Future.delayed(Duration(microseconds: 500), (){
            showEndTripDialogBox(context);
          });

        }
      }

    }

    if(widget.isComingFromReset != null)
    {
      if(widget.isComingFromReset!)
      {
        Future.delayed(Duration(microseconds: 500), (){
          showResetPasswordDialogBox(context, widget.token);
        });
      }
    }

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Utils.customPrint("APP STATE - app in resumed");
        dynamic arg = Get.arguments;
        if(arg !=  null)
        {
          Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
          bool isComingFrom = arguments?['isComingFromReset'] ?? false;
          String updatedToken = arguments?['token'] ?? "";

          if(mounted){
            setState(() {});
          }
          Utils.customPrint("isComingFromReset: ${isComingFrom}");
          if(mounted){
            if(isComingFrom != null && isComingFrom )
            {
              Future.delayed(Duration(microseconds: 500), (){
                Utils.customPrint("XXXXXXXXX ${_isThereCurrentDialogShowing(context)}");
                bool? result;
                if(sharedPreferences != null){
                  result = sharedPreferences!.getBool('reset_dialog_opened');
                }

                if(!_isThereCurrentDialogShowing(context))
                {
                  WidgetsBinding.instance.addPostFrameCallback((duration)
                  {
                    if(result != null){
                      if(!result){
                        showResetPasswordDialogBox(context,updatedToken);
                      }
                    }
                  });
                  setState(() {});
                }
              });
            }
          }
          Utils.customPrint('HomeScreen did update');
        }
        break;
      case AppLifecycleState.inactive:
        Utils.customPrint("APP STATE - app in inactive");
        break;
      case AppLifecycleState.paused:
        Utils.customPrint("APP STATE - app in paused");
        break;
      case AppLifecycleState.detached:
        Utils.customPrint("APP STATE - app in detached");
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
        child: Screenshot(
          controller: controller,
          child: Scaffold(
            backgroundColor: commonBackgroundColor,
            key: scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  scaffoldKey.currentState!.openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/icons/menu.png',
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
                        color: currentTabIndex == 0
                            ? buttonBGColor
                            : commonBackgroundColor,
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
                        color: currentTabIndex == 1
                            ? buttonBGColor
                            : commonBackgroundColor,
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
                    ),
                  ),
                ],
              ),
              backgroundColor: commonBackgroundColor,
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
                  child: Column(
                    children: [
                      TripViewListing(
                        scaffoldKey: scaffoldKey,
                        calledFrom: 'HomePage',
                        isTripDeleted: ()async{
                        },
                        onTripEnded: (){
                          commonProvider.getTripsByVesselId('');
                        },
                      ),

                      commonProvider.tripsCount == 0
                      ? Container()
                      : Padding(
                        padding: EdgeInsets.only(
                          bottom : displayWidth(context) * 0.02,
                        ),
                        child: GestureDetector(
                            onTap: ()async{
                              final image = await controller.capture();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                                imagePath: image.toString(),
                                uIntList: image,)));
                            },
                            child: UserFeedback().getUserFeedback(context)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showResetPasswordDialogBox(BuildContext context,String token) {
    if(sharedPreferences != null){
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),

                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(context) * 0.1,
                                width: displayWidth(context),
                                fit: BoxFit.contain,
                              ),
                            )),

                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                  'You are already logged in, Click OK to reset password.',
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Center(
                            child: CommonButtons.getAcceptButton(
                                'OK', context, buttonBGColor,
                                    () async {
                                  Navigator.pop(dialogContext);

                                     var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ResetPassword(token: token,isCalledFrom:  "HomePage",)),);
                                     },
                                displayWidth(context) * 0.65,
                                displayHeight(context) * 0.054,
                                primaryColor,
                                Colors.white,
                                displayHeight(context) * 0.015,
                                buttonBGColor,
                                '',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) {

    });
  }

  _isThereCurrentDialogShowing(BuildContext context) => ModalRoute.of(context)?.isCurrent != true;

  showEndTripDialogBox(BuildContext context) {
    if(sharedPreferences != null){
      sharedPreferences!.setBool('reset_dialog_opened', true);
    }
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),

                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(context) * 0.1,
                                width: displayWidth(context),
                                fit: BoxFit.contain,
                              ),
                            )),

                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text:
                                  lastTimeUsedText,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.04,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.012,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: isEndTripBtnClicked
                                    ? CircularProgressIndicator()
                                    : CommonButtons.getAcceptButton(
                                    'End Trip', context, Colors.transparent,
                                        () async {
                                          setDialogState(() {
                                         isEndTripBtnClicked = true;
                                       });
                                      List<String>? tripData = sharedPreferences!
                                          .getStringList('trip_data');

                                      String tripId = '';
                                      if (tripData != null) {
                                        tripId = tripData[0];
                                      }

                                      final currentTrip =
                                      await _databaseService.getTrip(tripId);

                                      DateTime createdAtTime =
                                      DateTime.parse(currentTrip.createdAt!);

                                      var durationTime = DateTime.now()
                                          .toUtc()
                                          .difference(createdAtTime);
                                      String tripDuration =
                                      Utils.calculateTripDuration(
                                          ((durationTime.inMilliseconds) / 1000)
                                              .toInt());

                                      Utils.customPrint("DURATION !!!!!! $tripDuration");

                                      bool isSmallTrip =  Utils().checkIfTripDurationIsGraterThan10Seconds(tripDuration.split(":"));

                                      if(!isSmallTrip)
                                      {
                                        Navigator.pop(context);

                                        Utils().showDeleteTripDialog(context, endTripBtnClick: (){
                                          EasyLoading.show(
                                              status: 'Please wait...',
                                              maskType: EasyLoadingMaskType.black);
                                          endTripMethod(setDialogState);
                                          Utils.customPrint("SMALL TRIPP IDDD ${tripId}");

                                          Utils.customPrint("SMALL TRIPP IDDD ${tripId}");

                                          Future.delayed(Duration(seconds: 1), (){
                                            if(!isSmallTrip)
                                            {
                                              Utils.customPrint("SMALL TRIPP IDDD 11 ${tripId}");
                                              DatabaseService().deleteTripFromDB(tripId);
                                            }
                                          });
                                        }, onCancelClick: (){
                                          endTripMethod(setDialogState);
                                        }
                                        );
                                      }
                                      else
                                      {
                                        endTripMethod(setDialogState);
                                      }

                                    },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    primaryColor,
                                    Colors.white,
                                    displayHeight(context) * 0.02,
                                    endTripBtnColor,
                                    '',
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 10,),
                              Center(
                                child: CommonButtons.getAcceptButton(
                                    'Continue Trip', context, Colors.transparent,
                                        () async {
                                      final _isRunning = await BackgroundLocator();

                                      Utils.customPrint('INTRO TRIP IS RUNNING 1212 $_isRunning');

                                      List<String>? tripData = sharedPreferences!.getStringList('trip_data');

                                      reInitializeService();

                                          StartTrip().startBGLocatorTrip(tripData![0], DateTime.now(), true);


                                      final isRunning2 = await BackgroundLocator.isServiceRunning();

                                      Utils.customPrint('INTRO TRIP IS RUNNING 22222 $isRunning2');
                                      Navigator.of(context).pop();
                                    },
                                    displayWidth(context) * 0.65,
                                    displayHeight(context) * 0.054,
                                    Colors.transparent,
                                    blueColor,
                                    displayHeight(context) * 0.018,
                                    Colors.transparent,
                                    '',
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).then((value) {

    });
  }

  /// Reinitialized service after user killed app while trip is running
  reInitializeService() async {

    await BackgroundLocator.initialize();

    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy:  LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 1,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Trip is in progress',
                notificationMsg: '',
                notificationBigMsg: '',
                notificationIconColor: Colors.grey,
                notificationIcon: '@drawable/noti_logo',
                notificationTapCallback:
                LocationCallbackHandler.notificationCallback)));
  }

  endTripMethod(StateSetter setDialogState)async
  {

    Utils.customPrint("Set Dialog set ${setDialogState == null}");
    List<String>? tripData = sharedPreferences!
        .getStringList('trip_data');

    String tripId = '';
    if (tripData != null) {
      tripId = tripData[0];
    }

    final currentTrip =
    await _databaseService.getTrip(tripId);

    DateTime createdAtTime =
    DateTime.parse(currentTrip.createdAt!);

    var durationTime = DateTime.now()
        .toUtc()
        .difference(createdAtTime);
    String tripDuration =
    Utils.calculateTripDuration(
        ((durationTime.inMilliseconds) / 1000)
            .toInt());

    Utils.customPrint(
        'FINAL PATH: ${sharedPreferences!.getStringList('trip_data')}');

    EndTrip().endTrip(
        context: context,
        scaffoldKey: scaffoldKey,
        duration: tripDuration,
        onEnded: () async {

          Future.delayed(Duration(seconds: 1), (){

            EasyLoading.dismiss();

            Navigator.of(context).pop();
          });

          Utils.customPrint('TRIPPPPPP ENDEDDD:');
          setState(() {
            getVesselFuture = _databaseService.vessels();
          });
        });
  }
}