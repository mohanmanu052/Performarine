import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/common_widgets/widgets/log_level.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/my_delegate_invite_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';

class SingleMyDelegateInviteCard extends StatefulWidget {
  MyDelegateInvite? myDelegateInvite;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function()? onTap;
  SingleMyDelegateInviteCard(
      {super.key, this.myDelegateInvite, this.scaffoldKey, this.onTap});

  @override
  State<SingleMyDelegateInviteCard> createState() =>
      _SingleMyDelegateInviteCardState();
}

class _SingleMyDelegateInviteCardState
    extends State<SingleMyDelegateInviteCard> {
  MyDelegateInvite? myDelegateInvite;
  late CommonProvider? commonProvider;
  final DatabaseService _databaseService = DatabaseService();

  bool? isAcceptBtnClicked = false, isRejectBtnClicked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    myDelegateInvite = widget.myDelegateInvite;

    commonProvider = context.read<CommonProvider>();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonText(
                        context: context,
                        text: myDelegateInvite!.vesselName,
                        fontWeight: FontWeight.w500,
                        textColor: /*myDelegateInvite!.status ==
                            1
                            ? Colors.grey
                            : */
                            Colors.black,
                        textSize: displayWidth(context) * 0.042,
                        textAlign: TextAlign.start,
                      ),
                      commonText(
                          context: context,
                          text:
                              'Send By ${myDelegateInvite!.invitedBy ?? '-'}',
                          fontWeight: FontWeight.w400,
                          textColor: Colors.grey,
                          textSize: displayWidth(context) * 0.032,
                          textAlign: TextAlign.start),
                      commonText(
                          context: context,
                          text: 'Permissions: ',
                          fontWeight: FontWeight.w400,
                          textColor: /*myDelegateInvite!.status ==
                              1
                              ? Colors.grey
                              : */
                              Colors.black87,
                          textSize: displayWidth(context) * 0.03,
                          textAlign: TextAlign.start),
                      commonText(
                          context: context,
                          text: 'Reports | Manage Trips | Edit ',
                          fontWeight: FontWeight.w400,
                          textColor: /* myDelegateInvite!.status ==
                              1
                              ? Colors.grey
                              :*/
                              Colors.black87,
                          textSize: displayWidth(context) * 0.026,
                          textAlign: TextAlign.start),
                    ],
                  ),
                ),
                SizedBox(
                  width: 4,
                ),

                accepeRejectStatus(myDelegateInvite!.status ?? 0)
                // myDelegateInvite!.status == 1
                //     ? commonText(
                //     context: context,
                //     text: 'Expired',
                //     fontWeight: FontWeight.w300,
                //     textColor:
                //     Colors.red,
                //     textSize:
                //     displayWidth(context) *
                //         0.032,
                //     textAlign: TextAlign.start,
                //     fontFamily: poppins)
                //     : Row(
                //   children: [
                //     InkWell(
                //       onTap: () {
                //         CustomFleetDailog()
                //             .showFleetDialog(
                //             context:
                //             context,
                //             title:
                //             'Are you sure you want to reject the Delegate invite?',
                //             subtext:
                //             myDelegateInvite!.vesselName!,
                //             postiveButtonColor:
                //             deleteTripBtnColor,
                //             positiveButtonText:
                //             'Reject',
                //             onNegativeButtonTap:
                //                 () {
                //               Navigator.of(
                //                   context)
                //                   .pop();
                //             },
                //             onPositiveButtonTap:
                //                 () async {

                //                   Navigator.of(context).pop();

                //                   setState(() {
                //                     isRejectBtnClicked = true;
                //                   });
                //               commonProvider?.delegateAcceptReject(
                //                   context,
                //                   commonProvider?.loginModel?.token ??
                //                       '',
                //                   widget.scaffoldKey!,
                //                   'false',
                //                   myDelegateInvite!.invitationLink!).then((value)
                //               {
                //                 if(value != null)
                //                   {
                //                     if(value.status!)
                //                       {
                //                         setState(() {
                //                           isRejectBtnClicked = false;
                //                         });

                //                         widget.onTap!.call();
                //                       }
                //                     else
                //                       {
                //                         setState(() {
                //                           isRejectBtnClicked = false;
                //                         });
                //                       }
                //                   }
                //                 else
                //                   {
                //                     setState(() {
                //                       isRejectBtnClicked = false;
                //                     });
                //                   }
                //               }).catchError((e){
                //                 setState(() {
                //                   isRejectBtnClicked = false;
                //                 });
                //               });
                //             });
                //       },
                //       child: isRejectBtnClicked!
                //       ? Container(
                //           height: 20,
                //           width: 20,
                //           child: CircularProgressIndicator(color: blueColor, strokeWidth: 2.5,))
                //       : commonText(
                //           context: context,
                //           text: 'Reject',
                //           fontWeight:
                //           FontWeight.w300,
                //           textColor:
                //           userFeedbackBtnColor,
                //           textSize: displayWidth(
                //               context) *
                //               0.032,
                //           textAlign:
                //           TextAlign.start,
                //           fontFamily:
                //           poppins),
                //     ),
                //     SizedBox(
                //       width: displayWidth(
                //           context) *
                //           0.04,
                //     ),
                //     SizedBox(
                //       width: displayWidth(context) * 0.18,
                //       child: InkWell(
                //             onTap: () {
                //               CustomFleetDailog()
                //                   .showFleetDialog(
                //                 context: context,
                //                 title:
                //                 'Are you sure you want to accept the Delegate Invite?',
                //                 subtext:
                //                 myDelegateInvite!.vesselName!,
                //                 postiveButtonColor:
                //                 blueColor,
                //                 positiveButtonText:
                //                 'Accept',
                //                 negtiveButtuonColor:
                //                 primaryColor,
                //                 onNegativeButtonTap:
                //                     () {
                //                   Navigator.of(
                //                       context)
                //                       .pop();
                //                 },
                //                 onPositiveButtonTap:
                //                     () {
                //                       Navigator.of(context).pop();
                //                       setState(() {
                //                         isAcceptBtnClicked = true;
                //                       });
                //                   commonProvider?.delegateAcceptReject(
                //                       context,
                //                       commonProvider
                //                           ?.loginModel
                //                           ?.token ??
                //                           '',
                //                       widget.scaffoldKey!,
                //                       'true',
                //                       myDelegateInvite!.invitationLink!).then((value)
                //                   {
                //                     if(value != null)
                //                       {
                //                         if(value.status!)
                //                           {
                //                             setState(() {
                //                               isAcceptBtnClicked = false;
                //                             });

                //                             widget.onTap!.call();
                //                           }
                //                         else
                //                           {
                //                             setState(() {
                //                               isAcceptBtnClicked = false;
                //                             });
                //                           }
                //                       }
                //                     else
                //                       {
                //                         setState(() {
                //                         isAcceptBtnClicked = false;
                //                       });

                //                       }
                //                   }).catchError((e){
                //                     setState(() {
                //                       isAcceptBtnClicked = false;
                //                     });
                //                   });
                //                   getUserConfigData();
                //                 },
                //               );
                //             },
                //             child: isAcceptBtnClicked!
                //                 ? Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     SizedBox(
                //                     height: 25,
                //                     width: 25,
                //                     child: Center(child: CircularProgressIndicator(color: blueColor, strokeWidth: 2.5,))),
                //                   ],
                //                 )
                //                 : Container(
                //               width: displayWidth(context) * 0.18,
                //               alignment: Alignment.center,
                //               decoration: BoxDecoration(
                //                   color: blueColor,
                //                   borderRadius:
                //                   BorderRadius
                //                       .circular(
                //                       20)),
                //               child: Padding(
                //                 padding:
                //                 const EdgeInsets
                //                     .only(
                //                     top: 4,
                //                     bottom:
                //                     4),
                //                 child: commonText(
                //                     context:
                //                     context,
                //                     text:
                //                     'Accept',
                //                     fontWeight:
                //                     FontWeight
                //                         .w300,
                //                     textColor:
                //                     Colors
                //                         .white,
                //                     textSize:
                //                     displayWidth(
                //                         context) *
                //                         0.032,
                //                     textAlign:
                //                     TextAlign
                //                         .start,
                //                     fontFamily:
                //                     poppins),
                //               ),
                //             ),
                //           ),
                //     ),
                //   ],
                // )
              ],
            ),
            Divider(
              color: Colors.grey.shade200,
              thickness: 2,
            )
          ],
        ),
      ),
    );
  }

  getUserConfigData(BuildContext context, CommonModel value) {
    Utils.customPrint("CLOUDE USER ID ${commonProvider!.loginModel!.userId}");
    CustomLogger().logWithFile(
        Level.info, "CLOUDE USER ID ${commonProvider!.loginModel!.userId} -> ");

    commonProvider!
        .getUserConfigData(context, commonProvider!.loginModel!.userId!,
            commonProvider!.loginModel!.token!, widget.scaffoldKey!)
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
                  .downloadImageFromCloud(
                      context, widget.scaffoldKey!, cloudImage);

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
                hullType: value.vessels![i].hullType != null ? int.parse(value.vessels![i].hullType.toString()) : 0);

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

          if(mounted)
          {
            setState(() {
              widget.onTap!.call();
              isAcceptBtnClicked = false;
              Utils.showSnackBar(context,
                  scaffoldKey: widget.scaffoldKey, message: 'Successfully accepted the invitation');
            });
          }

        }
      }
    });
  }

  Widget accepeRejectStatus(int status) {

    switch (status) {
      case 1:
        return commonText(
            context: context,
            text: 'Accepted',
            fontWeight: FontWeight.w300,
            textColor: blueColor,
            textSize: displayWidth(context) * 0.032,
            textAlign: TextAlign.start,
            fontFamily: poppins);

      case 2:
        return commonText(
            context: context,
            text: 'Rejected',
            fontWeight: FontWeight.w300,
            textColor: Colors.red,
            textSize: displayWidth(context) * 0.032,
            textAlign: TextAlign.start,
            fontFamily: poppins);

      case 3:
        return commonText(
            context: context,
            text: 'Expired',
            fontWeight: FontWeight.w300,
            textColor: Colors.red,
            textSize: displayWidth(context) * 0.032,
            textAlign: TextAlign.start,
            fontFamily: poppins);

      case 0:
        return Row(
          children: [
            InkWell(
              onTap: () {
                CustomFleetDailog().showFleetDialog
                  (
                    context: context,
                    title:
                        'Are you sure you want to reject the Delegate invite?',
                    subtext: myDelegateInvite!.vesselName!,
                    postiveButtonColor: deleteTripBtnColor,
                    positiveButtonText: 'Reject',
                    onNegativeButtonTap: () {
                      Navigator.of(context).pop();
                    },
                    onPositiveButtonTap: () async {
                      Navigator.of(context).pop();

                      setState(() {
                        isRejectBtnClicked = true;
                      });
                      commonProvider
                          ?.delegateAcceptReject(
                              context,
                              commonProvider?.loginModel?.token ?? '',
                              widget.scaffoldKey!,
                              'false',
                              myDelegateInvite!.invitationLink!)
                          .then((value) {
                        if (value != null) {
                          if (value.status!) {
                            setState(() {
                              isRejectBtnClicked = false;
                            });

                            widget.onTap!.call();
                          } else {
                            setState(() {
                              isRejectBtnClicked = false;
                            });
                          }
                        } else {
                          setState(() {
                            isRejectBtnClicked = false;
                          });
                        }
                      }).catchError((e) {
                        setState(() {
                          isRejectBtnClicked = false;
                        });
                      });
                    });
              },
              child: isRejectBtnClicked!
                  ? Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: blueColor,
                        strokeWidth: 2.5,
                      ))
                  : commonText(
                      context: context,
                      text: 'Reject',
                      fontWeight: FontWeight.w300,
                      textColor: userFeedbackBtnColor,
                      textSize: displayWidth(context) * 0.032,
                      textAlign: TextAlign.start,
                      fontFamily: poppins),
            ),
            SizedBox(
              width: displayWidth(context) * 0.04,
            ),
            SizedBox(
              width: displayWidth(context) * 0.18,
              child: InkWell(
                onTap: () {
                  CustomFleetDailog().showFleetDialog(
                    context: context,
                    title:
                        'Are you sure you want to accept the Delegate Invite?',
                    subtext: myDelegateInvite!.vesselName!,
                    postiveButtonColor: blueColor,
                    positiveButtonText: 'Accept',
                    negtiveButtuonColor: primaryColor,
                    onNegativeButtonTap: () {
                      Navigator.of(context).pop();
                    },
                    onPositiveButtonTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        isAcceptBtnClicked = true;
                      });
                      commonProvider
                          ?.delegateAcceptReject(
                              context,
                              commonProvider?.loginModel?.token ?? '',
                              widget.scaffoldKey!,
                              'true',
                              myDelegateInvite!.invitationLink!)
                          .then((value) {
                        if (value != null) {
                          if (value.status!) {

                           setState(() {
                             getUserConfigData(context, value);

                           });

                          } else {
                            setState(() {
                              isAcceptBtnClicked = false;
                            });
                          }
                        } else {
                          setState(() {
                            isAcceptBtnClicked = false;
                          });
                        }
                      }).catchError((e) {
                        setState(() {
                          isAcceptBtnClicked = false;
                        });
                      });
                    },
                  );
                },
                child: isAcceptBtnClicked!
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: blueColor,
                                strokeWidth: 2.5,
                              ))),
                        ],
                      )
                    : Container(
                        width: displayWidth(context) * 0.18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: commonText(
                              context: context,
                              text: 'Accept',
                              fontWeight: FontWeight.w300,
                              textColor: Colors.white,
                              textSize: displayWidth(context) * 0.032,
                              textAlign: TextAlign.start,
                              fontFamily: poppins),
                        ),
                      ),
              ),
            ),
          ],
        );

      default:
        return commonText(
            context: context,
            text: 'Expired ',
            fontWeight: FontWeight.w300,
            textColor: Colors.red,
            textSize: displayWidth(context) * 0.032,
            textAlign: TextAlign.start,
            fontFamily: poppins);
        ;
    }
  }


}
