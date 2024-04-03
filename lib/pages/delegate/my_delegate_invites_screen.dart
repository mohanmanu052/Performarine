import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/my_delegate_invite_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/delegate/single_my_delegate_invite_card.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../bottom_navigation.dart';
import '../feedback_report.dart';

class MyDelegateInvitesScreen extends StatefulWidget {
  const MyDelegateInvitesScreen({super.key});

  @override
  State<MyDelegateInvitesScreen> createState() =>
      _MyDelegateInvitesScreenState();
}

class _MyDelegateInvitesScreenState extends State<MyDelegateInvitesScreen> {
  final controller = ScreenshotController();
  final DatabaseService _databaseService = DatabaseService();

  GlobalKey<ScaffoldState> scfoldKey = GlobalKey();
  CommonProvider? commonProvider;
  Future<MyDelegateInviteModel>? future;

  List<MyDelegateInvite>? myDelegateInvite;

  @override
  void initState() {
    commonProvider = context.read<CommonProvider>();
    getDelgateInvites();
    // TODO: implement initState
    super.initState();
  }

  void getDelgateInvites() async {
    future = commonProvider?.getDelegateInvites(context, commonProvider!.loginModel!.token!, scfoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
        controller: controller,
        child: Scaffold(
          key: scfoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            centerTitle: true,
            title: commonText(
                context: context,
                text: 'My Delegate Invites',
                fontWeight: FontWeight.w600,
                textColor: Colors.black,
                textSize: displayWidth(context) * 0.05,
                textAlign: TextAlign.start),
            actions: [
              InkWell(
                onTap: () async {},
                child: Image.asset(
                  'assets/images/Trash.png',
                  width: Platform.isAndroid
                      ? displayWidth(context) * 0.05
                      : displayWidth(context) * 0.05,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async {
                    await SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp]);

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavigation()),
                        ModalRoute.withName(""));
                  },
                  icon:
                      Image.asset('assets/icons/performarine_appbar_icon.png'),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.only(bottom: 4),
            child: GestureDetector(
                onTap: () async {
                  final image = await controller.capture();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeedbackReport(
                                imagePath: image.toString(),
                                uIntList: image,
                              )));
                },
                child: UserFeedback().getUserFeedback(context)),
          ),
          body: SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                child: FutureBuilder<MyDelegateInviteModel>(
                    future: future,
                    builder: (context, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                            height: displayHeight(context) / 1.5,
                            child: Center(
                                child: const CircularProgressIndicator(
                                    color: blueColor)));
                      } else if (snapShot.data == null ||
                          snapShot.data!.myDelegateInvities!.isEmpty) {
                        return Container(
                          height: displayHeight(context) / 1.4,
                          child: Center(
                            child: commonText(
                                context: context,
                                text: 'No data found',
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.05,
                                textAlign: TextAlign.start),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              height: displayHeight(context) * 0.01,
                            ),
                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                snapShot.data!.myDelegateInvities!.length,
                                itemBuilder: (context, index) {
                                  debugPrint("RESPONSE DELEGATE ${snapShot.data!.myDelegateInvities![index].status}");
                                  return SingleMyDelegateInviteCard(
                                    myDelegateInvite: snapShot.data!.myDelegateInvities![index],
                                  scaffoldKey: scfoldKey,
                                  onTap: (){
                                    future = commonProvider?.getDelegateInvites(context, commonProvider!.loginModel!.token!, scfoldKey);
                                    //myDelegateInvite!.removeAt(index);
                                    setState(() {});
                                    //myDelegateInvite![index].removeWhere((item) => item == 'Item 3');
                                  },);

                                }),
                          ],
                        );
                      }
                    })),
          ),
        ));
  }

  getUserConfigData() {
    Utils.customPrint("CLOUDE USER ID ${commonProvider!.loginModel!.userId}");
    CustomLogger().logWithFile(
        Level.info, "CLOUDE USER ID ${commonProvider!.loginModel!.userId} -> ");

    commonProvider!
        .getUserConfigData(context, commonProvider!.loginModel!.userId!,
            commonProvider!.loginModel!.token!, scfoldKey)
        .then((value) async {
      if (value != null) {
        if (value.status!) {
          Utils.customPrint('LENGTH: ${value.vessels!.length}');
          CustomLogger().logWithFile(
              Level.info, "LENGTH: ${value.vessels!.length} -> $page");
          for (int i = 0; i < value.vessels!.length; i++) {
            if (value.vessels![i].name == 'rrrrr 12') {
              Utils.customPrint(
                  'RRRRR 12 VESSEL DATA: ${value.vessels![i].toJson()}');
              CustomLogger().logWithFile(Level.info,
                  "RRRRR 12 VESSEL DATA: ${value.vessels![i].toJson()} -> $page");
            }

            Utils.customPrint(
                'USER CONFIG DATA CLOUD IMAGE 1212 ${value.vessels![i].imageURLs!}');
            CustomLogger().logWithFile(Level.info,
                "USER CONFIG DATA CLOUD IMAGE 1212 ${value.vessels![i].imageURLs!} -> $page");
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
              CustomLogger().logWithFile(Level.info,
                  "USER CONFIG DATA CLOUD IMAGE 1212 $cloudImage -> $page");
            }

            var downloadImageFromCloud;
            var downloadedCompressImageFile;
            if (cloudImage.isNotEmpty) {
              downloadImageFromCloud = await DownloadTrip()
                  .downloadImageFromCloud(context, scfoldKey, cloudImage);

              Utils.customPrint(
                  'USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud');
              CustomLogger().logWithFile(Level.info,
                  "USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud -> $page");
            } else {
              downloadImageFromCloud = '';
            }

            File downloadedFile = File(downloadImageFromCloud);

            Utils.customPrint('DOWNLOADED FILE PATH ${downloadedFile.path}');
            Utils.customPrint(
                'DOWNLOADED FILE EXIST SYNC ${downloadedFile.existsSync()}');

            CustomLogger().logWithFile(
                Level.info, "DOWNLOADED FILE PATH ${downloadedFile.path} -> ");
            CustomLogger().logWithFile(Level.info,
                "DOWNLOADED FILE EXIST SYNC ${downloadedFile.existsSync()} -> ");

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

                CustomLogger().logWithFile(Level.info,
                    "${downloadedFile.lengthSync().toString()} -> $page");
                CustomLogger().logWithFile(
                    Level.info, "${result.lengthSync().toString()} -> $page");
                CustomLogger().logWithFile(
                    Level.info, "RESULT N PATH ${result.path} -> $page");
                CustomLogger().logWithFile(Level.info,
                    "RESULT N PATH ${downloadedCompressImageFile} -> $page");

                downloadedFile.deleteSync();
              } else {
                downloadedCompressImageFile = downloadedFile.path;
              }
            } else {
              bool doesExist = await downloadedFile.exists();
              Utils.customPrint('DOWNLOADED FILE EXIST SYNC @@@ $doesExist');
              CustomLogger().logWithFile(Level.info,
                  "DOWNLOADED FILE EXIST SYNC @@@ $doesExist -> $page");
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

                  CustomLogger().logWithFile(Level.info,
                      "${downloadedFile.lengthSync().toString()} -> $page");
                  CustomLogger().logWithFile(
                      Level.info, "${result.lengthSync().toString()} -> $page");
                  CustomLogger().logWithFile(
                      Level.info, "RESULT N PATH ${result.path} -> $page");
                  CustomLogger().logWithFile(Level.info,
                      "RESULT N PATH ${downloadedCompressImageFile} -> $page");

                  downloadedFile.deleteSync();
                } else {
                  downloadedCompressImageFile = downloadedFile.path;
                }
              }
            }

            Utils.customPrint('FINAL IMAGEEEE: $downloadedCompressImageFile');
            CustomLogger().logWithFile(Level.info,
                "FINAL IMAGEEEE: $downloadedCompressImageFile -> $page");

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
                hullType: int.parse(value.vessels![i].hullType.toString()));

            var vesselExist = await _databaseService
                .vesselsExistInCloud(value.vessels![i].id!);

            Utils.customPrint('USER CONFIG DATA CLOUD $vesselExist');
            CustomLogger().logWithFile(
                Level.info, "USER CONFIG DATA CLOUD $vesselExist -> $page");

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

            CustomLogger().logWithFile(
                Level.info, "TRIPS DATA ${value.trips!.length} -> $page");
            CustomLogger().logWithFile(Level.info,
                "TRIPS VESSEL ID ${value.trips![i].vesselId} -> $page");

            CreateVessel? vesselData = await _databaseService
                .getVesselFromVesselID(value.trips![i].vesselId.toString());

            if (vesselData != null) {
              if (value.trips![i].createdBy ==
                  commonProvider!.loginModel!.userId) {
                Trip tripData = Trip(
                    id: value.trips![i].id,
                    vesselId: value.trips![i].vesselId,
                    vesselName: vesselData.name,
                    currentLoad: value.trips![i].load,
                    numberOfPassengers: value.trips![i].numberOfPassengers ?? 0,
                    filePath: value.trips![i].cloudFilePath,
                    isSync: 1,
                    tripStatus: value.trips![i].tripStatus,
                    createdBy: commonProvider!.loginModel?.userEmail ?? "",
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
                CustomLogger().logWithFile(Level.info,
                    "USER CONFIG DATA JSON ${tripData.toJson()} -> $page");
                await _databaseService.insertTrip(tripData);
              }
            }
          }

          // Future.delayed(Duration(seconds: 1), () {
          //   setState(() {
          //     curIndex = 2;
          //     lastIndex = 1;
          //   });
          // });

          // Future.delayed(Duration(seconds: 2), () async{
          //   sharedPreferences!.setBool('isFirstTimeUser', true);
          //   await  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

          //   Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(builder: (context) => BottomNavigation()),
          //       ModalRoute.withName(""));
          // });
        }
      }
    });
  }
}

class InvitesModel {
  String? fleetName, sendBy, status;

  InvitesModel({this.fleetName, this.sendBy, this.status});
}
