import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';
import 'package:performarine/services/database_service.dart';

class SuccessfullyDeletedAccountScreen extends StatefulWidget {
  const SuccessfullyDeletedAccountScreen({super.key});

  @override
  State<SuccessfullyDeletedAccountScreen> createState() => _SuccessfullyDeletedAccountScreenState();
}

class _SuccessfullyDeletedAccountScreenState extends State<SuccessfullyDeletedAccountScreen> {

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 3),(){
      signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if(didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: displayHeight(context),
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: displayHeight(context) * 0.08,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    'assets/images/success_image.png',
                    height: displayHeight(context) * 0.25
                  ),),
                SizedBox(height: displayHeight(context) * 0.02,),
                commonText(
                    context: context,
                    text: 'Your account has been\ndeleted successfully',
                    fontWeight: FontWeight.w600,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.05,
                    textAlign: TextAlign.start),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Normal Sign out without uploading data
  signOut() async {
    var vesselDelete = await _databaseService.deleteDataFromVesselTable();
    var tripsDelete = await _databaseService.deleteDataFromTripTable();

    Utils.customPrint('DELETE $vesselDelete');
    Utils.customPrint('DELETE $tripsDelete');

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
            builder: (context) => const SignInScreen(
              calledFrom: 'sideMenu',
            )),
        ModalRoute.withName(""));
  }
}
