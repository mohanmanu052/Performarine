import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:performarine/pages/authentication/reset_password.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  List<String> tripData;
  final int tabIndex;
  final bool? isComingFromReset;
  String token;
  HomePage({Key? key, this.tripData = const [], this.tabIndex = 0, this.isComingFromReset,this.token = ""})
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
  File? imageFile;

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

        print("isComingFromReset: ${isComingFrom}");
        if(mounted){
          if(isComingFrom != null && isComingFrom )
          {

            Future.delayed(Duration(microseconds: 500), (){
              print("XXXXXXXXX ${_isThereCurrentDialogShowing(context)}");

              if(!_isThereCurrentDialogShowing(context))
              {
                WidgetsBinding.instance.addPostFrameCallback((duration)
                {
                  showEndTripDialogBox(context,updatedToken);

                });
              }

            });


          }
        }
        print('HomeScreen did update');
      }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    commonProvider = context.read<CommonProvider>();
    commonProvider.init();
    commonProvider.getTripsCount();
   // commonProvider.checkIfBluetoothIsEnabled(scaffoldKey);

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

    if(widget.isComingFromReset != null)
      {
        if(widget.isComingFromReset!)
          {
            Future.delayed(Duration(microseconds: 500), (){
              showEndTripDialogBox(context, widget.token);
            });
          }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("APP STATE - app in resumed");
        dynamic arg = Get.arguments;
        if(arg !=  null)
        {
          Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
          bool isComingFrom = arguments?['isComingFromReset'] ?? false;
          String updatedToken = arguments?['token'] ?? "";

          if(mounted){
            setState(() {});
          }
          print("isComingFromReset: ${isComingFrom}");
          if(mounted){
            if(isComingFrom != null && isComingFrom )
            {

              Future.delayed(Duration(microseconds: 500), (){
                print("XXXXXXXXX ${_isThereCurrentDialogShowing(context)}");
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
                        showEndTripDialogBox(context,updatedToken);
                      }
                    }
                  });
                  setState(() {});
                }

              });


            }
          }
          print('HomeScreen did update');
        }
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
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(onPressed: (){
                  final image = controller.capture();
                  print("Image is: ${image.toString()}");
                  captureAndSaveScreenshot();
                }, icon: Icon(
                    Icons.help,
                  size: 25,
                  color: Colors.grey,
                ))
              ],
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
                  child: TripViewListing(
                    scaffoldKey: scaffoldKey,
                    calledFrom: 'HomePage',
                    onTripEnded: (){
                      commonProvider.getTripsByVesselId('');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showEndTripDialogBox(BuildContext context,String token) {
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
                              //color: Color(0xfff2fffb),
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
                                  //Navigator.pop(dialogContext);
                                     var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ResetPassword(token: token,isCalledFrom:  "HomePage",)),);
                                 // Navigator.pop(scaffoldKey.currentContext!);
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

  Future<String> captureAndSaveScreenshot() async {
    final Uint8List? imageBytes = await controller.capture();

    final Directory appDir = await getApplicationDocumentsDirectory();

    final String fileName = DateTime.now().toIso8601String() + '.png';
    imageFile = File('${appDir.path}/$fileName');
    print("file path is: ${imageFile!.path}");

    await imageFile!.writeAsBytes(imageBytes!);

    deleteImageAfterDelay(imageFile!.path);

    return imageFile!.path;
  }

  void deleteImageAfterDelay(String imagePath) {
    const delayDuration = Duration(seconds: 2);

    Timer(delayDuration, () {
      print("delete confirmation");
      deleteImageFile(imagePath);
    });
  }

  Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

}
