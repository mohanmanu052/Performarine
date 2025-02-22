import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:performarine/pages/auth_new/sign_in_screen.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/zig_zag_line_widget.dart';
import '../../main.dart';
import '../../provider/common_provider.dart';
import '../../services/database_service.dart';

class ResetPassword extends StatefulWidget {
  final String? token;
  String isCalledFrom;
  ResetPassword({this.token,this.isCalledFrom = "",Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();

  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode reenterPasswordFocusNode = FocusNode();
  bool isConfirmPasswordValid = false;

  late CommonProvider commonProvider;
  bool? isBtnClick = false;
  final DatabaseService _databaseService = DatabaseService();

  String page = "reset_password";

  @override
  void initState() {
    super.initState();
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    commonProvider = context.read<CommonProvider>();
    newPasswordController = TextEditingController();
    reenterPasswordController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return PopScope(
      canPop: false,
     onPopInvoked: (didPop)
      {
        if(didPop)  return;
        if(widget.isCalledFrom == "Main")
        {
          Get.offAll(SignInScreen(calledFrom:'ResetPassword'));
        }
        else if(widget.isCalledFrom == 'Dashboard'){
          isComingFromUnilinkMain = true;
          Get.offAll(BottomNavigation(isComingFromReset: false,));

        }
        else
        {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: commonBackgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: commonBackgroundColor,
          leading: IconButton(
            onPressed: () {
              if(widget.isCalledFrom == "Main")
              {
                Get.offAll(SignInScreen(calledFrom:'ResetPassword'));
              }
              else if(widget.isCalledFrom == 'Dashboard'){
                print("else new in reset password--");
                isComingFromUnilinkMain = true;
                if(sharedPreferences != null){
                  sharedPreferences!.setBool('reset_dialog_opened',true);
                }
                Get.offAll(BottomNavigation(isComingFromReset: false,));
              }
              else
              {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: true,
          title: commonText(
              context: context,
              text: 'Reset Password',
              fontWeight: FontWeight.w600,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop)async{
            if(didPop) return;
            if(sharedPreferences != null){
              sharedPreferences!.setBool('reset_dialog_opened',true);
            }
          },
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  bottom: displayHeight(context) * 0.06,
                  child: ZigZagLineWidget()),
              Form(
                  key: formKey,
                  child: Container(
                    height: displayHeight(context),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: displayHeight(context) * 0.08),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 25),
                            child: Image.asset(
                              'assets/images/sign_in_img.png',
                            ),
                          ),

                          SizedBox(height: displayHeight(context) * 0.1),

                          CommonTextField(
                            //key: emailFormFieldKey,
                              controller: newPasswordController,
                              focusNode: newPasswordFocusNode,
                              labelText: 'Enter New Password\*',
                              hintText: '',
                              suffixText: null,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 52,
                              prefixIcon: null,
                              requestFocusNode: reenterPasswordFocusNode,
                              obscureText: true,
                              readOnly: false,
                              onTap: () {},
                              onChanged: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter New Password';
                                } else if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                                    .hasMatch(value)) {
                                  return 'Password must contain at least 8 characters and \n include : \n * At least one lowercase letter (a-z) \n '
                                      '* At least one uppercase letter (A-Z) \n * At least one number (0-9) \n * At least one special character (e.g: !.@#\$&*~)';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                              },
                              onSaved: (String value) {
                                Utils.customPrint(value);
                                CustomLogger().logWithFile(Level.info, "New password $value -> $page");
                              }),
                          SizedBox(height: displayWidth(context) * 0.03),

                          CommonTextField(
                              controller: reenterPasswordController,
                              focusNode: reenterPasswordFocusNode,
                              labelText: 'Confirm New Password\*',
                              hintText: '',
                              suffixText: null,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 52,
                              prefixIcon: null,
                              requestFocusNode: null,
                              obscureText: true,
                              readOnly: false,
                              onTap: () {},
                              onChanged: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  isConfirmPasswordValid = false;
                                  return 'Enter Confirm New Password';
                                } else if (reenterPasswordController.text !=
                                    newPasswordController.text) {
                                  isConfirmPasswordValid = false;
                                  return "Passwords don\'t match";
                                }

                                isConfirmPasswordValid = true;

                                return null;
                              },
                              onFieldSubmitted: (value) {
                              },
                              onSaved: (String value) {
                                Utils.customPrint(value);
                                CustomLogger().logWithFile(Level.info, "Confirm New password $value -> $page");
                              }),

                          SizedBox(height: displayHeight(context) * 0.2),

                          isBtnClick! ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    circularProgressColor),
                              ))
                              :     CommonButtons.getActionButton(
                              title: 'Update Password',
                              context: context,
                              fontSize: displayWidth(context) * 0.044,
                              textColor: Colors.white,
                              buttonPrimaryColor: buttonBGColor,
                              borderColor: buttonBGColor,
                              width: displayWidth(context),
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  bool check = await Utils().check(scaffoldKey);

                                  Utils.customPrint("NETWORK $check");
                                  CustomLogger().logWithFile(Level.info, "NETWORK$check  -> $page");

                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  if(check){
                                    setState(() {
                                      isBtnClick = true;
                                    });

                                    commonProvider.resetPassword(context, widget.token! != null ? widget.token! : "", newPasswordController.text.trim(), scaffoldKey).then((value){
                                      setState(() {
                                        isBtnClick = false;
                                      });
                                    Utils.customPrint("Status code of change password is: ${value.statusCode}");
                                      CustomLogger().logWithFile(Level.info, "Status code of change password is: ${value.statusCode}  -> $page");

                                      if(value.statusCode == 200 && value.message == "Password reset was successfully completed!"){
                                        if(widget.isCalledFrom == "Dashboard"){
                                            Navigator.pop(context);
                                        } else{
                                          signOut();
                                        }

                                      } else if(value.message == "link Expired !!"){
                                        if(widget.isCalledFrom == "Dashboard"){
                                          Navigator.pop(context);
                                        } else{
                                          CustomLogger().logWithFile(Level.info, "User navigating into sign in scren -> $page");
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => const SignInScreen(calledFrom:'ResetPassword')),
                                              ModalRoute.withName(""));
                                        }

                                      }
                                                                        }).catchError((e){
                                      setState(() {
                                        isBtnClick = false;
                                      });
                                    });
                                  } else{
                                    setState(() {
                                      isBtnClick = false;
                                    });
                                  }
                                }
                              }),
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  signOut() async {
    var vesselDelete = await _databaseService.deleteDataFromVesselTable();
    var tripsDelete = await _databaseService.deleteDataFromTripTable();

    Utils.customPrint('DELETE $vesselDelete');
    Utils.customPrint('DELETE $tripsDelete');
    CustomLogger().logWithFile(Level.info, "DELETE $tripsDelete -> $page");
    CustomLogger().logWithFile(Level.info, "DELETE $tripsDelete -> $page");

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
        MaterialPageRoute(builder: (context) => const SignInScreen(calledFrom:'ResetPassword')),
        ModalRoute.withName(""));
  }
}

