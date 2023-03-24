import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_dialog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:status_stepper/status_stepper.dart';

class SyncDataCloudToMobileScreen extends StatefulWidget {
  const SyncDataCloudToMobileScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();

    commonProvider.init();

    getUserData();
  }

  getUserData() async {
    var bool = await Utils()
        .check(scaffoldKey, userConfig: true, onRetryTap: () => getUserData());

    Utils.customPrint("INTERNET $bool");

    if (bool) {
      getUserConfigData();
    } else {
      setState(() {
        commonProvider.updateExceptionOccurredValue(true);
      });
      /* Future.delayed(Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            ModalRoute.withName(""));
      }); */
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            children: [
              SizedBox(
                height: displayHeight(context) * 0.1,
              ),
              Image.asset(
                'assets/images/cloud.png',
                height: displayHeight(context) * 0.3,
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: commonText(
                  text: 'Restoring your data from cloud',
                  context: context,
                  textSize: displayWidth(context) * 0.055,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.08,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  child: stepperWidget(),
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.08,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: commonText(
                  text:
                      'Don’t click back button while restoring data until its fully completed ',
                  context: context,
                  textSize: displayWidth(context) * 0.03,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.02,
              ),
              !commonProvider.exceptionOccurred
                  ? Container(
                      margin: EdgeInsets.only(
                          bottom: displayHeight(context) * 0.02,
                          top: displayHeight(context) * 0.02),
                      child: CommonButtons.getActionButton(
                          title: 'Skip & Continue',
                          context: context,
                          fontSize: displayWidth(context) * 0.038,
                          textColor: Colors.white,
                          buttonPrimaryColor: buttonBGColor,
                          borderColor: buttonBGColor,
                          width: displayWidth(context),
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());

                            sharedPreferences!.setBool('isFirstTimeUser', true);

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                                ModalRoute.withName(""));
                          }),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                bottom: displayHeight(context) * 0.02,
                                top: displayHeight(context) * 0.02),
                            child: CommonButtons.getActionButton(
                                title: 'Skip & Continue',
                                context: context,
                                fontSize: displayWidth(context) * 0.038,
                                textColor: Colors.white,
                                buttonPrimaryColor: Color(0xff889BAB),
                                borderColor: Color(0xff889BAB),
                                width: displayWidth(context),
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());

                                  sharedPreferences!
                                      .setBool('isFirstTimeUser', true);

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
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
                                bottom: displayHeight(context) * 0.02,
                                top: displayHeight(context) * 0.02),
                            child: CommonButtons.getActionButton(
                                title: 'Retry',
                                context: context,
                                fontSize: displayWidth(context) * 0.038,
                                textColor: Colors.white,
                                buttonPrimaryColor: buttonBGColor,
                                borderColor: buttonBGColor,
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
    );
  }

  stepperWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
      child: Column(
        children: [
          StatusStepper(
            connectorCurve: Curves.easeIn,
            itemCurve: Curves.easeOut,
            activeColor: Colors.black,
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

  getUserConfigData() {
    Utils.customPrint("CLOUDE USER ID ${commonProvider.loginModel!.userId}");

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
          for (int i = 0; i < value.vessels!.length; i++) {
            if (value.vessels![i].name == 'rrrrr 12') {
              print('RRRRR 12 VESSEL DATA: ${value.vessels![i].toJson()}');
            }

            Utils.customPrint(
                'USER CONFIG DATA CLOUD IMAGE 1212 ${value.vessels![i].imageURLs!}');
            String cloudImage;
            if (value.vessels![i].imageURLs!.length > 1) {
              cloudImage = value.vessels![i].imageURLs![0];

              // Utils.customPrint('USER CONFIG DATA CLOUD IMAGE ARRAY $cloudImage');
            } else {
              cloudImage = value.vessels![i].imageURLs == []
                  ? ''
                  : value.vessels![i].imageURLs
                      .toString()
                      .replaceAll("[", "")
                      .replaceAll("]", "");

              Utils.customPrint(
                  'USER CONFIG DATA CLOUD IMAGE 1212 $cloudImage');
            }

            var downloadImageFromCloud;
            var downloadedCompressImageFile;
            if (cloudImage.isNotEmpty) {
              downloadImageFromCloud = await DownloadTrip()
                  .downloadImageFromCloud(context, scaffoldKey, cloudImage);

              Utils.customPrint(
                  'USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud');
            } else {
              downloadImageFromCloud = '';
            }

            File downloadedFile = File(downloadImageFromCloud);

            Utils.customPrint('DOWNLOADED FILE PATH ${downloadedFile.path}');
            Utils.customPrint(
                'DOWNLOADED FILE EXIST SYNC ${downloadedFile.existsSync()}');

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
                  //format: CompressFormat.jpeg
                );

                downloadedCompressImageFile = result!.path;

                Utils.customPrint(downloadedFile.lengthSync().toString());
                Utils.customPrint(result.lengthSync().toString());

                Utils.customPrint("RESULT N PATH ${result.path}");
                Utils.customPrint(
                    "RESULT N PATH ${downloadedCompressImageFile}");

                downloadedFile.deleteSync();
              } else {
                downloadedCompressImageFile = downloadedFile.path;
              }
            } else {
              bool doesExist = await downloadedFile.exists();
              Utils.customPrint('DOWNLOADED FILE EXIST SYNC @@@ $doesExist');
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
                    //format: CompressFormat.jpeg
                  );

                  downloadedCompressImageFile = result!.path;

                  Utils.customPrint(downloadedFile.lengthSync().toString());
                  Utils.customPrint(result.lengthSync().toString());

                  Utils.customPrint("RESULT N PATH ${result.path}");
                  Utils.customPrint(
                      "RESULT N PATH ${downloadedCompressImageFile}");

                  downloadedFile.deleteSync();
                } else {
                  downloadedCompressImageFile = downloadedFile.path;
                }
              }
            }

            Utils.customPrint('FINAL IMAGEEEE: $downloadedCompressImageFile');

            CreateVessel vesselData = CreateVessel(
                id: value.vessels![i].id,
                name: value.vessels![i].name,
                builderName: value.vessels![i].builderName,
                model: value.vessels![i].model,
                regNumber: value.vessels![i].regNumber,
                mMSI: value.vessels![i].mMSI,
                engineType: value.vessels![i].engineType,
                fuelCapacity: value.vessels![i].fuelCapacity.toString(),
                batteryCapacity: value.vessels![i].batteryCapacity.toString(),
                weight: value.vessels![i].weight,
                freeBoard: value.vessels![i].freeBoard!,
                lengthOverall: value.vessels![i].lengthOverall!,
                beam: value.vessels![i].beam!,
                draft: value.vessels![i].depth!,
                vesselSize: value.vessels![i].vesselSize!,
                capacity: int.parse(value.vessels![i].capacity!),
                builtYear: int.parse(value.vessels![i].builtYear.toString()),
                vesselStatus: value.vessels![i].vesselStatus == '2'
                    ? 0
                    : int.parse(value.vessels![i].vesselStatus.toString()),
                imageURLs: downloadedCompressImageFile,
                createdAt: value.vessels![i].createdAt.toString(),
                createdBy: value.vessels![i].createdBy.toString(),
                updatedAt: value.vessels![i].updatedAt.toString(),
                isSync: 1,
                updatedBy: value.vessels![i].updatedBy.toString(),
                isCloud: 1);

            var vesselExist = await _databaseService
                .vesselsExistInCloud(value.vessels![i].id!);

            Utils.customPrint('USER CONFIG DATA CLOUD $vesselExist');

            if (vesselExist) {
              await _databaseService.updateVessel(vesselData);
            } else {
              await _databaseService.insertVessel(vesselData);
            }
          }

          for (int i = 0; i < value.trips!.length; i++) {
            Utils.customPrint("TRIPS DATA ${value.trips!.length}");
            Utils.customPrint("TRIPS VESSEL ID ${value.trips![i].vesselId}");

            CreateVessel? vesselData = await _databaseService
                .getVesselFromVesselID(value.trips![i].vesselId.toString());

            Utils.customPrint("TRIPS VESSEL ID ${value.trips![i].vesselId}");
            Utils.customPrint("VESSEL NAME ${vesselData!.name}");

            if (vesselData != null) {
              Trip tripData = Trip(
                  id: value.trips![i].id,
                  vesselId: value.trips![i].vesselId,
                  vesselName: vesselData.name,
                  currentLoad: value.trips![i].load,
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

              await _databaseService.insertTrip(tripData);
            }
          }

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              curIndex = 2;
              lastIndex = 1;
            });
          });

          Future.delayed(Duration(seconds: 2), () {
            sharedPreferences!.setBool('isFirstTimeUser', true);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                ModalRoute.withName(""));
          });
        }
      }
    });
  }
}
