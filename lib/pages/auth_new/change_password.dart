import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../provider/common_provider.dart';
import '../../services/database_service.dart';

class ChangePassword extends StatefulWidget {
  bool? isChange;
int? bottomNavIndex;
  ChangePassword({this.isChange = false, Key? key,this.bottomNavIndex}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> currentPassFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> newPassFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> confirmPassFormKey = GlobalKey<FormState>();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();

  FocusNode currentPasswordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode reenterPasswordFocusNode = FocusNode();
  bool isConfirmPasswordValid = false;

  late CommonProvider commonProvider;
  bool? isBtnClick = false;
  final DatabaseService _databaseService = DatabaseService();

  String page = "change_password";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    commonProvider = context.read<CommonProvider>();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    reenterPasswordController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      backgroundColor: backgroundColor,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        actions: [

Container(
margin: EdgeInsets.only(right: 8),
child: IconButton(
onPressed: ()async {

await  SystemChrome.setPreferredOrientations([
      
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => BottomNavigation()),
ModalRoute.withName(""));
},
icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
color: Theme.of(context).brightness == Brightness.dark
? Colors.white
: Colors.black,
),
),
],

      ),
      body: SafeArea(
        child: Form(
            // key: formKey,
            child: Container(
          height: displayHeight(context),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              children: [

                SizedBox(height: displayHeight(context) * 0.1),
                Container(
                  width: displayWidth(context) * 0.36,
                  height: displayHeight(context) * 0.14,
                  child: Image.asset(
                    'assets/images/performarine_logo.png',
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.05),
                commonText(
                    context: context,
                    text: 'Change Password',
                    fontWeight: FontWeight.w600,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.043,
                    textAlign: TextAlign.start,
                    fontFamily: outfit),
                SizedBox(height: displayHeight(context) * 0.025),
                Form(
                  key: currentPassFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      //key: emailFormFieldKey,
                      controller: currentPasswordController,
                      focusNode: currentPasswordFocusNode,
                      labelText: 'Current Password',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 52,
                      prefixIcon: null,
                      requestFocusNode: newPasswordFocusNode,
                      obscureText: true,
                      readOnly: false,
                      onTap: () {},
                      onChanged: (value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Current Password';
                        } else if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$')
                            .hasMatch(value)) {
                          return 'Password must contain at least 8 characters and \n include : \n * At least one lowercase letter (a-z) \n '
                              '* At least one uppercase letter (A-Z) \n * At least one number (0-9) \n * At least one special character (e.g: !.@#\$&*~)';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {},
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "Current Password: $value -> $page");
                      }),
                ),
                SizedBox(height: displayWidth(context) * 0.03),
                Form(
                  key: newPassFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: newPasswordController,
                      focusNode: newPasswordFocusNode,
                      labelText: 'Enter New Password',
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
                      onFieldSubmitted: (value) {},
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(
                            Level.info, "New Password: $value -> $page");
                      }),
                ),
                SizedBox(height: displayWidth(context) * 0.03),
                Form(
                  key: confirmPassFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: CommonTextField(
                      controller: reenterPasswordController,
                      focusNode: reenterPasswordFocusNode,
                      labelText: 'Confirm New Password',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.done,
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
                      onFieldSubmitted: (value) {},
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info,
                            "Confirm New Password: $value -> $page");
                      }),
                ),
                SizedBox(height: displayHeight(context) * 0.2),
                isBtnClick!
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(blueColor),
                      ))
                    : CommonButtons.getActionButton(
                        title: 'Update Password',
                        context: context,
                        fontSize: displayWidth(context) * 0.044,
                        textColor: Colors.white,
                        buttonPrimaryColor: blueColor,
                        borderColor: blueColor,
                        width: displayWidth(context),
                        onTap: () async {
                          if (currentPassFormKey.currentState!.validate() &&
                              newPassFormKey.currentState!.validate() &&
                              confirmPassFormKey.currentState!.validate()) {
                            bool check = await Utils().check(scaffoldKey);
                            // Utils.customPrint("NETWORK $check");
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (check) {
                              setState(() {
                                isBtnClick = true;
                              });
                              commonProvider
                                  .changePassword(
                                      context,
                                      commonProvider.loginModel!.token!,
                                      currentPasswordController.text.trim(),
                                      newPasswordController.text.trim(),
                                      scaffoldKey)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    isBtnClick = false;
                                  });

                                  Utils.customPrint(
                                      "Status code of change password is: ${value.statusCode}");
                                  CustomLogger().logWithFile(Level.info,
                                      "Status code of change password is: ${value.statusCode} -> $page");

                                  if (value.status!) {
                                    if (widget.isChange!) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }
                                } else {
                                  setState(() {
                                    isBtnClick = false;
                                  });
                                }
                              }).catchError((e) {
                                setState(() {
                                  isBtnClick = false;
                                });
                              });
                            } else {
                              setState(() {
                                isBtnClick = false;
                              });
                            }
                          }
                        }),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
