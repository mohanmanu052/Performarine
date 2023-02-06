import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/retired_vessels_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
    // debugPrint('X-TOKEN ${commonProvider.loginModel!.userEmail}');

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
                    onTap: () {
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
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()),
                          ModalRoute.withName(""));
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
}
