import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:status_stepper/status_stepper.dart';

import '../common_widgets/widgets/log_level.dart';
import '../common_widgets/widgets/user_feed_back.dart';
import 'bottom_navigation.dart';
import 'feedback_report.dart';

class SyncDataCloudToMobileScreen extends StatefulWidget {
  int?bottomNavIndex;

   SyncDataCloudToMobileScreen({Key? key,this.bottomNavIndex}) : super(key: key);

  @override
  State<SyncDataCloudToMobileScreen> createState() =>
      _SyncDataCloudToMobileScreenState();
}

class _SyncDataCloudToMobileScreenState
    extends State<SyncDataCloudToMobileScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final DatabaseService _databaseService = DatabaseService();

  final statuses = List.generate(
    3,
    (index) => SizedBox.square(
      dimension: 14,
      child: Center(child: Text('')),
    ),
  );

  int curIndex = -1;
  int lastIndex = -1;

  late CommonProvider commonProvider;

  bool internetConnectionOn = false;

  final controller = ScreenshotController();
  String page = "Sync_data_cloud_to_mobile_screen";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    commonProvider = context.read<CommonProvider>();

    commonProvider.init();

    getUserData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
if(widget.bottomNavIndex==1){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

}
  }

  /// To get user data from api if internet connection is on
  getUserData() async {
    var bool = await Utils()
        .check(scaffoldKey, userConfig: false, onRetryTap: () => getUserData());

    Utils.customPrint("INTERNET $bool");
    CustomLogger().logWithFile(Level.info, "Internet: $bool-> $page");

    if (bool) {
      getUserConfigData();
    } else {
      setState(() {
        commonProvider.updateExceptionOccurredValue(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Screenshot(
          controller: controller,
          child: Scaffold(
            backgroundColor: Colors.white,
            key: scaffoldKey,
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                children: [
                  SizedBox(
                    height:Platform.isAndroid? MediaQuery.of(context).size.height/27:MediaQuery.of(context).size.height/30,
                  ),
                  Container(
                    width: displayWidth(context) * 0.7,
                    height: MediaQuery.of(context).size.height/5.5,
                    child: Image.asset(
                      'assets/images/sync_cloud.png',
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/24,
                  ),
                  Container(
                    width: displayWidth(context) * 0.36,
                    height: displayHeight(context) * 0.12,
                    child: Image.asset(
                      'assets/icons/performarine_appbar_icon.png',
                    ),
                  ),
                  SizedBox(
                    height:Platform.isAndroid? MediaQuery.of(context).size.height/24:MediaQuery.of(context).size.height/28,
                   // height: displayHeight(context) * 0.04,
                  ),
                  
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: reportTripsListColor
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: commonText(
                              text: 'Restoring your data from cloud',
                              context: context,
                              textSize: displayWidth(context) * 0.054,
                              textColor: Colors.black,
                              fontWeight: FontWeight.w500,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height/25,
                            //height: displayHeight(context) * 0.04,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              child: stepperWidget(),
                            ),
                          ),
                          SizedBox(
                            height:Platform.isAndroid? displayHeight(context) * 0.03:displayHeight(context) * 0.02
                            ,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: commonText(
                              text:
                              'Don’t click back button while restoring data until its fully completed ',
                              context: context,
                              textSize: displayWidth(context) * 0.03,
                              textColor: Colors.black87,
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: displayHeight(context) * 0.03
                            
                          ),
                          !commonProvider.exceptionOccurred
                              ? Container(
                            margin: EdgeInsets.only(
                                bottom: displayHeight(context) * 0.005,
                                top: displayHeight(context) * 0.02),
                            child: CommonButtons.getActionButton(
                                title: 'Skip & Continue',
                                context: context,
                                fontSize: displayWidth(context) * 0.038,
                                textColor: blueColor,
                                buttonPrimaryColor: skipAndContinueBtnColor,
                                borderColor: skipAndContinueBtnColor,
                                width: displayWidth(context) / 1.28,
                                onTap: ()async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());

                                  sharedPreferences!
                                      .setBool('isFirstTimeUser', true);
                                       await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


                                 await Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BottomNavigation()),
                                      ModalRoute.withName(""));
                                }),
                          )
                              : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: displayHeight(context) * 0.005,
                                      top: displayHeight(context) * 0.02),
                                  child: CommonButtons.getActionButton(
                                      title: 'Skip & Continue',
                                      context: context,
                                      fontSize: displayWidth(context) * 0.038,
                                      textColor: Colors.white,
                                      buttonPrimaryColor: Color(0xff889BAB),
                                      borderColor: Color(0xff889BAB),
                                      width: displayWidth(context),
                                      onTap: () async{
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());

                                        sharedPreferences!
                                            .setBool('isFirstTimeUser', true);
 await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => BottomNavigation()),
                                            ModalRoute.withName(""));
                                      }),
                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: displayHeight(context) * 0.005,
                                      top: displayHeight(context) * 0.02),
                                  child: CommonButtons.getActionButton(
                                      title: 'Retry',
                                      context: context,
                                      fontSize: displayWidth(context) * 0.038,
                                      textColor: Colors.white,
                                      buttonPrimaryColor: blueColor,
                                      borderColor: blueColor,
                                      width: displayWidth(context),
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        getUserConfigData();
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/40,
                  ),

                  commonProvider.exceptionOccurred
                  ? 
                  
                  Padding(
                    padding: EdgeInsets.only(
                      top: displayWidth(context) * 0.03,
                    ),
                    child: GestureDetector(
                        onTap: ()async{
                          final image = await controller.capture();   
                          await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


                          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                            imagePath: image.toString(),
                            uIntList: image,)));
                        },
                        child: UserFeedback().getUserFeedback(context)
                    ),
                  )
                  : Container(),

                  // SizedBox(
                  //   height: displayWidth(context) * 0.02,
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// To show the progress
  stepperWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
      child: Column(
        children: [
          StatusStepper(
            connectorCurve: Curves.easeIn,
            itemCurve: Curves.easeOut,
            activeColor: blueColor,
            disabledColor: Colors.grey,
            animationDuration: const Duration(milliseconds: 500),
            children: statuses,
            lastActiveIndex: lastIndex,
            currentIndex: curIndex,
            connectorThickness: 5,
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: commonText(
                        text: 'Downloading\ndata from cloud',
                        context: context,
                        textSize: displayWidth(context) * 0.025,
                        textColor: Colors.black,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      ))),
              Expanded(
                  child: Center(
                      child: commonText(
                text: 'Importing data\nin application',
                context: context,
                textSize: displayWidth(context) * 0.025,
                textColor: Colors.black,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ))),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: commonText(
                        text: 'Completed',
                        context: context,
                        textSize: displayWidth(context) * 0.025,
                        textColor: Colors.black,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      )))
            ],
          )
        ],
      ),
    );
  }

  /// Getting user details from the api
  getUserConfigData() {
    Utils.customPrint("CLOUDE USER ID ${commonProvider.loginModel!.userId}");
    CustomLogger().logWithFile(Level.info, "CLOUDE USER ID ${commonProvider.loginModel!.userId} -> $page");

    setState(() {
      curIndex = 0;
      lastIndex = -1;
    });

    commonProvider
        .getUserConfigData(context, commonProvider.loginModel!.userId!,
            commonProvider.loginModel!.token!, scaffoldKey)
        .then((value) async {
      if (value != null) {
        if (value.status!) {
          setState(() {
            curIndex = 1;
            lastIndex = 0;
          });

      Utils.customPrint('LENGTH: ${value.vessels!.length}');
          CustomLogger().logWithFile(Level.info, "LENGTH: ${value.vessels!.length} -> $page");
          for (int i = 0; i < value.vessels!.length; i++) {
            if (value.vessels![i].name == 'rrrrr 12') {
      Utils.customPrint('RRRRR 12 VESSEL DATA: ${value.vessels![i].toJson()}');
              CustomLogger().logWithFile(Level.info, "RRRRR 12 VESSEL DATA: ${value.vessels![i].toJson()} -> $page");

            }

            Utils.customPrint(
                'USER CONFIG DATA CLOUD IMAGE 1212 ${value.vessels![i].imageURLs!}');
            CustomLogger().logWithFile(Level.info, "USER CONFIG DATA CLOUD IMAGE 1212 ${value.vessels![i].imageURLs!} -> $page");
            String cloudImage;
            if (value.vessels![i].imageURLs!.length > 1) {
              cloudImage = value.vessels![i].imageURLs![0];
            } else {
              cloudImage = value.vessels![i].imageURLs == []
                  ? ''
                  : value.vessels![i].imageURLs
                      .toString()
                      .replaceAll("[", "")
                      .replaceAll("]", "");

              Utils.customPrint(
                  'USER CONFIG DATA CLOUD IMAGE 1212 $cloudImage');
              CustomLogger().logWithFile(Level.info, "USER CONFIG DATA CLOUD IMAGE 1212 $cloudImage -> $page");
            }

            var downloadImageFromCloud;
            var downloadedCompressImageFile;
            if (cloudImage.isNotEmpty) {
              downloadImageFromCloud = await DownloadTrip()
                  .downloadImageFromCloud(context, scaffoldKey, cloudImage);

              Utils.customPrint(
                  'USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud');
              CustomLogger().logWithFile(Level.info, "USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud -> $page");
            } else {
              downloadImageFromCloud = '';
            }

            File downloadedFile = File(downloadImageFromCloud);

            Utils.customPrint('DOWNLOADED FILE PATH ${downloadedFile.path}');
            Utils.customPrint(
                'DOWNLOADED FILE EXIST SYNC ${downloadedFile.existsSync()}');

            CustomLogger().logWithFile(Level.info, "DOWNLOADED FILE PATH ${downloadedFile.path} -> $page");
            CustomLogger().logWithFile(Level.info, "DOWNLOADED FILE EXIST SYNC ${downloadedFile.existsSync()} -> $page");

            bool doesExist = await downloadedFile.exists();

            /// 2MB
            if (doesExist) {
              if (downloadedFile.lengthSync() >= 2000000) {
                String targetPath = '${ourDirectory!.path}/vesselImages';

                Directory vesselDirectory = Directory(targetPath);

                if (!vesselDirectory.existsSync()) {
                  vesselDirectory.createSync();
                }

                FlutterImageCompress.validator.ignoreCheckExtName = true;

                var result = await FlutterImageCompress.compressAndGetFile(
                  downloadedFile.absolute.path,
                  '$targetPath/${downloadedFile.path.split('/').last}',
                  quality: 50,
                );

                downloadedCompressImageFile = result!.path;

                Utils.customPrint(downloadedFile.lengthSync().toString());
                Utils.customPrint(result.lengthSync().toString());

                Utils.customPrint("RESULT N PATH ${result.path}");
                Utils.customPrint(
                    "RESULT N PATH ${downloadedCompressImageFile}");

                CustomLogger().logWithFile(Level.info, "${downloadedFile.lengthSync().toString()} -> $page");
                CustomLogger().logWithFile(Level.info, "${result.lengthSync().toString()} -> $page");
                CustomLogger().logWithFile(Level.info, "RESULT N PATH ${result.path} -> $page");
                CustomLogger().logWithFile(Level.info, "RESULT N PATH ${downloadedCompressImageFile} -> $page");

                downloadedFile.deleteSync();
              } else {
                downloadedCompressImageFile = downloadedFile.path;
              }
            } else {
              bool doesExist = await downloadedFile.exists();
              Utils.customPrint('DOWNLOADED FILE EXIST SYNC @@@ $doesExist');
              CustomLogger().logWithFile(Level.info, "DOWNLOADED FILE EXIST SYNC @@@ $doesExist -> $page");
              if (doesExist) {
                if (downloadedFile.lengthSync() >= 2000000) {
                  String targetPath = '${ourDirectory!.path}/vesselImages';

                  Directory vesselDirectory = Directory(targetPath);

                  if (!vesselDirectory.existsSync()) {
                    vesselDirectory.createSync();
                  }

                  FlutterImageCompress.validator.ignoreCheckExtName = true;

                  var result = await FlutterImageCompress.compressAndGetFile(
                    downloadedFile.absolute.path,
                    '$targetPath/${downloadedFile.path.split('/').last}',
                    quality: 50,
                  );

                  downloadedCompressImageFile = result!.path;

                  Utils.customPrint(downloadedFile.lengthSync().toString());
                  Utils.customPrint(result.lengthSync().toString());

                  Utils.customPrint("RESULT N PATH ${result.path}");
                  Utils.customPrint(
                      "RESULT N PATH ${downloadedCompressImageFile}");

                  CustomLogger().logWithFile(Level.info, "${downloadedFile.lengthSync().toString()} -> $page");
                  CustomLogger().logWithFile(Level.info, "${result.lengthSync().toString()} -> $page");
                  CustomLogger().logWithFile(Level.info, "RESULT N PATH ${result.path} -> $page");
                  CustomLogger().logWithFile(Level.info, "RESULT N PATH ${downloadedCompressImageFile} -> $page");

                  downloadedFile.deleteSync();
                } else {
                  downloadedCompressImageFile = downloadedFile.path;
                }
              }
            }

            Utils.customPrint('FINAL IMAGEEEE: $downloadedCompressImageFile');
            CustomLogger().logWithFile(Level.info, "FINAL IMAGEEEE: $downloadedCompressImageFile -> $page");

            CreateVessel vesselData = CreateVessel(
                id: value.vessels![i].id,
                name: value.vessels![i].name,
                builderName: value.vessels![i].builderName,
                model: value.vessels![i].model,
                regNumber: value.vessels![i].regNumber,
                mMSI: value.vessels![i].mMSI,
                engineType: value.vessels![i].engineType,
                fuelCapacity: value.vessels![i].fuelCapacity.toString(),
                batteryCapacity:value.vessels![i].batteryCapacity.toString(),
                weight: value.vessels![i].weight,
                freeBoard: value.vessels![i].freeBoard!,
                lengthOverall: value.vessels![i].lengthOverall!,
                beam: value.vessels![i].beam!,
                draft: value.vessels![i].depth!,
                vesselSize: value.vessels![i].vesselSize.toString(),
                capacity: int.parse(value.vessels![i].capacity ?? '0'),
                builtYear: int.parse(value.vessels![i].builtYear.toString()),
                vesselStatus: value.vessels![i].vesselStatus == 2
                    ? 0
                    : int.parse(value.vessels![i].vesselStatus.toString()),
                imageURLs: downloadedCompressImageFile,
                createdAt: value.vessels![i].createdAt.toString(),
                createdBy: value.vessels![i].createdBy.toString(),
                updatedAt: value.vessels![i].updatedAt.toString(),
                isSync: 1,
                updatedBy: value.vessels![i].updatedBy.toString(),
                isCloud: 1,
              hullType: int.parse(value.vessels![i].hullType.toString())
            );

            var vesselExist = await _databaseService
                .vesselsExistInCloud(value.vessels![i].id!);

            Utils.customPrint('USER CONFIG DATA CLOUD $vesselExist');
            CustomLogger().logWithFile(Level.info, "USER CONFIG DATA CLOUD $vesselExist -> $page");

            if (vesselExist) {
              await _databaseService.updateVessel(vesselData);
            } else {
              await _databaseService.insertVessel(vesselData);
            }
          }

          for (int i = 0; i < value.trips!.length; i++) {
            Utils.customPrint("TRIPS DATA ${value.trips!.length}");
            Utils.customPrint("TRIPS VESSEL ID ${value.trips![i].vesselId}");
            Utils.customPrint("TRIPS VESSEL ID ${value.trips![i].toJson()}");

            CustomLogger().logWithFile(Level.info, "TRIPS DATA ${value.trips!.length} -> $page");
            CustomLogger().logWithFile(Level.info, "TRIPS VESSEL ID ${value.trips![i].vesselId} -> $page");

            CreateVessel? vesselData = await _databaseService
                .getVesselFromVesselID(value.trips![i].vesselId.toString());

            if (vesselData != null) {
              Trip tripData = Trip(
                  id: value.trips![i].id,
                  vesselId: value.trips![i].vesselId,
                  vesselName: vesselData.name,
                  currentLoad: value.trips![i].load,
                  numberOfPassengers: value.trips![i].numberOfPassengers ?? 0,
                  filePath: value.trips![i].cloudFilePath,
                  isSync: 1,
                  tripStatus: value.trips![i].tripStatus,
                  updatedAt: value.trips![i].updatedAt,
                  createdAt: value.trips![i].createdAt,
                  deviceInfo: value.trips![i].deviceInfo!.toJson().toString(),
                  startPosition: value.trips![i].startPosition!.join(','),
                  endPosition: value.trips![i].endPosition!.join(','),
                  time: value.trips![i].duration,
                  distance: value.trips![i].distance.toString(),
                  speed: value.trips![i].speed.toString(),
                  avgSpeed: value.trips![i].avgSpeed.toString(),
                  isCloud: 1);

              Utils.customPrint('USER CONFIG DATA JSON ${tripData.toJson()}');
              CustomLogger().logWithFile(Level.info, "USER CONFIG DATA JSON ${tripData.toJson()} -> $page");

              await _databaseService.insertTrip(tripData);
            }
          }

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              curIndex = 2;
              lastIndex = 1;
            });
          });

          Future.delayed(Duration(seconds: 2), () async{
            sharedPreferences!.setBool('isFirstTimeUser', true);
  await  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavigation()),
                ModalRoute.withName(""));
          });
        }
      }
    });
  }
}