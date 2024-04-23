import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/common_widgets/widgets/delegate_vessel_info_card.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/common_widgets/widgets/vessel_info_card.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/models/vessel_delegate_model.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/delegate/single_delegate_card.dart';
import 'package:performarine/pages/delegate/update_delegate_access_screen.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/pages/delegate/invite_delegate.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class DelegatesScreen extends StatefulWidget {
  String? vesselID;
  bool? isComingFromUnilink;
  Uri? uri;
  String? ownerId;
  DelegatesScreen(
      {super.key,
      this.vesselID,
      this.isComingFromUnilink,
      this.uri,
      this.ownerId});

  @override
  State<DelegatesScreen> createState() => _DelegatesScreenState();
}

class _DelegatesScreenState extends State<DelegatesScreen> {
  final controller = ScreenshotController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
  CommonProvider? commonProvider;

  late Future<VesselDelegateModel> future;

  @override
  void initState() {

    debugPrint("VESSEL ID FROM UNILINK ${widget.vesselID}");

    commonProvider = context.read<CommonProvider>();

    if(widget.isComingFromUnilink??false){
      debugPrint("COMING FROM UNILINK ");
      debugPrint("COMING FROM UNILINK ${widget.vesselID}");
      adddelegateInvitation();
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       getUserConfigData();
       future = commonProvider!.vesselDelegateData(context, commonProvider!.loginModel!.token!, widget.vesselID!, scaffoldKey);
     });
    }

    debugPrint("COMING FROM UNILINK");
    future = commonProvider!.vesselDelegateData(context, commonProvider!.loginModel!.token!, widget.vesselID!, scaffoldKey);

    // TODO: implement initState
    super.initState();
  }

  void adddelegateInvitation() async {
    if (widget.isComingFromUnilink ?? false) {
      var res = await commonProvider?.acceptDelegateInvite(widget.uri ?? Uri());
      if (res!.statusCode == 200) {
        Future.delayed(Duration(milliseconds: 500)).then((value) {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (widget.isComingFromUnilink ?? false) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigation()),
              ModalRoute.withName(""));
        } else {
          Navigator.pop(context);
        };
      },
      child: Screenshot(
        controller: controller,
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
                if (widget.isComingFromUnilink ?? false) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: commonText(
                context: context,
                text: 'Delegate’s',
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                textSize: displayWidth(context) * 0.042,
                fontFamily: outfit),
            actions: [
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
          body: Container(
            child: Stack(
              children: [
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: displayHeight(context) / 8.5,
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          CommonButtons.getActionButton(
                              title: 'Invite Delegate',
                              context: context,
                              fontSize: displayWidth(context) * 0.044,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              onTap: () async {
                                debugPrint(
                                    "VESSEL ID DELEGATE SCREEN 1 - ${widget.vesselID}");
                                var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => InviteDelegate(
                                              vesselID: widget.vesselID,
                                            ))));

                                if (result != null) {
                                  if (result) {
                                    future = commonProvider!.vesselDelegateData(context, commonProvider!.loginModel!.token!, widget.vesselID!, scaffoldKey);
                                    setState(() {

                                    });
                                  }
                                }
                              },
                              width: displayWidth(context) / 1.3,
                              height: displayHeight(context) * 0.053),
                          GestureDetector(
                              onTap: (() async {
                                final image = await controller.capture();
                                await SystemChrome.setPreferredOrientations(
                                    [DeviceOrientation.portraitUp]);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FeedbackReport(
                                              imagePath: image.toString(),
                                              uIntList: image,
                                            )));
                              }),
                              child: UserFeedback().getUserFeedback(
                                context,
                              )),
                        ],
                      ),
                    )),
                Container(
                  margin: EdgeInsets.only(bottom: displayHeight(context) / 7.1),
                  height: displayHeight(context) / 0.8,
                  child: SingleChildScrollView(
                    child: FutureBuilder<VesselDelegateModel>(
                        future: future,
                        builder: (context, snapShot) {
                          if (snapShot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                                height: displayHeight(context) / 1.5,
                                child: Center(
                                    child: const CircularProgressIndicator(
                                        color: blueColor)));
                          } else if (snapShot.data == null || snapShot.data!.myVesselDelegaties!.isEmpty) {
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
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        if (snapShot.data!.myVesselDelegaties != null)
                                          Container(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 15,
                                              ),
                                              width: displayWidth(context),
                                              child: DelegateVesselInfoCard(
                                                vesselData: snapShot.data!.myVesselDelegaties![0].vesselInfo!,
                                              )),

                                        SizedBox(
                                          height: 10,
                                        ),
                                        ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: snapShot.data!.myVesselDelegaties![0].delegates!.length,
                                            itemBuilder: (context, index) {

                                              return SingleDelegateCard(
                                                  delegates: snapShot.data!.myVesselDelegaties![0].delegates![index],
                                                  vesselID: snapShot.data!.myVesselDelegaties![0].vesselId,
                                                scaffoldKey: scaffoldKey,
                                                onTap: (){

                                                  debugPrint("REMOVE VESSEL ID ${snapShot.data!.myVesselDelegaties![0].vesselId}");
                                                  debugPrint("REMOVE DELEGATE ID ${snapShot.data!.myVesselDelegaties![0].delegates![index].id}");

                                                  future = commonProvider!.vesselDelegateData(context, commonProvider!.loginModel!.token!, widget.vesselID!, scaffoldKey);
                                                  setState(() {});
                                                },
                                              );
                                            })

                                        //vesselSingleViewCard(context, vesselData!, (p0) => null, scaffoldKey)
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        })

                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tag(Color tagColor, String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: commonText(
          text: text,
          fontWeight: FontWeight.w300,
          textSize: 8,
          textColor: blutoothDialogTitleColor),
    );
  }

  getUserConfigData() {
    Utils.customPrint("CLOUDE USER ID ${commonProvider!.loginModel!.userId}");
    CustomLogger().logWithFile(
        Level.info, "CLOUDE USER ID ${commonProvider!.loginModel!.userId} -> ");

    commonProvider!
        .getUserConfigData(context, commonProvider!.loginModel!.userId!,
            commonProvider!.loginModel!.token!, scaffoldKey)
        .then((value) async {
      if (value != null) {
        if (value.status!) {
          Utils.customPrint('LENGTH: ${value.vessels!.length}');
          CustomLogger()
              .logWithFile(Level.info, "LENGTH: ${value.vessels!.length} -> ");
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
                  .downloadImageFromCloud(context, scaffoldKey, cloudImage);

              Utils.customPrint(
                  'USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud');
              CustomLogger().logWithFile(Level.info,
                  "USER CONFIG DATA CLOUD IMAGE $downloadImageFromCloud -> ");
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
                hullType: value.vessels![i].hullType != null ? int.parse(value.vessels![i].hullType.toString()): 0);

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
