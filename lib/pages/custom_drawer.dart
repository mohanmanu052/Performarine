import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_dialog.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/retired_vessels_screen.dart';
import 'package:performarine/pages/sync_data_cloud_to_mobile_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const CustomDrawer({Key? key, this.scaffoldKey}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final DatabaseService _databaseService = DatabaseService();
  late double textSize;

  String? currentVersion;
  late CommonProvider commonProvider;

  @override
  void initState() {
    commonProvider = context.read<CommonProvider>();

    super.initState();

    getVersion();
  }

  @override
  Widget build(BuildContext context) {
    textSize = displayWidth(context) * 0.038;
    // Utils.customPrint('X-TOKEN ${commonProvider.loginModel!.userEmail}');

    return Drawer(
      child: Container(
        margin: const EdgeInsets.only(left: 30, right: 10.0, top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: displayHeight(context) * 0.05,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text: "Hey ",
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: displayWidth(context) * 0.04,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        "${commonProvider.loginModel!.userEmail} !",
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: displayWidth(context) * 0.04,
                                    ),
                                  )
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: displayHeight(context) * 0.06,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                              ModalRoute.withName(""));
                        },
                        child: commonText(
                            context: context,
                            text: 'My Vessels',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddNewVesselScreen()),
                          );
                        },
                        child: commonText(
                            context: context,
                            text: 'Create Vessels',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RetiredVesselsScreen()),
                          );
                        },
                        child: commonText(
                            context: context,
                            text: 'Retried vessels',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SyncDataCloudToMobileScreen()),
                          );
                        },
                        child: commonText(
                            context: context,
                            text: 'Sync from Cloud',
                            fontWeight: FontWeight.w500,
                            textColor: Colors.black54,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      bool? isTripStarted =
                          sharedPreferences!.getBool('trip_started');

                      var tripSyncDetails =
                          await _databaseService.tripSyncDetails();
                      var vesselsSyncDetails =
                          await _databaseService.vesselsSyncDetails();

                      Utils.customPrint(
                          "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails"); /*

                      vesselsSyncDetails = true;
                      tripSyncDetails = true;

                      Utils.customPrint(
                          "TRIP SYNC DATA ${tripSyncDetails} $vesselsSyncDetails");*/

                      /*if (vesselsSyncDetails && tripSyncDetails) {
                        showDialogBox(context, widget.scaffoldKey!);
                      } else if (vesselsSyncDetails) {
                        showDialogBox(context, widget.scaffoldKey!);
                      }*/

                      if (isTripStarted != null) {
                        if (isTripStarted) {
                          Navigator.of(context).pop();
                          Utils.showSnackBar(context,
                              scaffoldKey: widget.scaffoldKey,
                              message:
                                  'Please end the trip which is already running');
                        } else {
                          if (vesselsSyncDetails || tripSyncDetails) {
                            showDialogBox(context, widget.scaffoldKey!);
                          } else {
                            signOut();
                          }
                        }
                      } else {
                        if (vesselsSyncDetails || tripSyncDetails) {
                          showDialogBox(context, widget.scaffoldKey!);
                        } else {
                          signOut();
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        commonText(
                            context: context,
                            text: 'Sign Out',
                            fontWeight: FontWeight.w600,
                            textColor: Colors.black,
                            textSize: textSize,
                            textAlign: TextAlign.start),
                        Icon(Icons.logout, color: Colors.black54),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      commonText(
                          text: 'Powered by ',
                          context: context,
                          textSize: displayWidth(context) * 0.03,
                          textColor: Colors.grey,
                          fontWeight: FontWeight.w400),
                      TextButton(
                        onPressed: () {
                          Utils.launchURL('https://www.paccore.com/');
                        },
                        child: Text('paccore.com',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: displayWidth(context) * 0.035,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                  commonText(
                      text: 'Version $currentVersion',
                      context: context,
                      textSize: displayWidth(context) * 0.03,
                      textColor: Colors.black54,
                      fontWeight: FontWeight.w400),
                  commonText(
                      text: 'Release Date - 1 Dec 2022',
                      //${DateFormat('dd MMM yyyy').format(DateTime.now())}
                      context: context,
                      textSize: displayWidth(context) * 0.03,
                      textColor: Colors.black54,
                      fontWeight: FontWeight.w400),
                ],
              ),
            ),
            SizedBox(height: displayHeight(context) * 0.05)
          ],
        ),
      ),
    );
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });
  }

  signOut() {
    sharedPreferences!.clear();
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );

    googleSignIn.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        ModalRoute.withName(""));
  }

  showDialogBox(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
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
                  height: displayHeight(context) * 0.32,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              commonText(
                                  context: context,
                                  text: 'Sign Out?',
                                  fontWeight: FontWeight.w600,
                                  textColor: Colors.black,
                                  textSize: displayWidth(context) * 0.042,
                                  textAlign: TextAlign.center),
                              SizedBox(
                                height: displayHeight(context) * 0.015,
                              ),
                              commonText(
                                  context: context,
                                  text:
                                      'You have data which is not uploaded to cloud, if you sign out you may loose data',
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.grey,
                                  textSize: displayWidth(context) * 0.036,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.grey)),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Cancel', context, primaryColor, () {
                                    Navigator.of(context).pop();
                                  },
                                      displayWidth(context) * 0.4,
                                      displayHeight(context) * 0.05,
                                      Colors.grey.shade400,
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      displayHeight(context) * 0.018,
                                      Colors.grey.shade400,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Center(
                                  child: CommonButtons.getAcceptButton(
                                      'Sign Out', context, primaryColor,
                                      () async {
                                    Navigator.of(context).pop();

                                    signOut();

                                    var vesselDelete = await _databaseService
                                        .deleteDataFromVesselTable();
                                    var tripsDelete = await _databaseService
                                        .deleteDataFromTripTable();

                                    Utils.customPrint('DELETE $vesselDelete');
                                    Utils.customPrint('DELETE $tripsDelete');
                                  },
                                      displayWidth(context) * 0.4,
                                      displayHeight(context) * 0.05,
                                      primaryColor,
                                      Colors.white,
                                      displayHeight(context) * 0.018,
                                      buttonBGColor,
                                      '',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
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
        });
  }
}
