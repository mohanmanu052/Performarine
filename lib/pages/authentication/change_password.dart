import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/zig_zag_line_widget.dart';
import '../../main.dart';
import '../../provider/common_provider.dart';

class ChangePassword extends StatefulWidget {
  final String? token;
   ChangePassword({this.token,Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();

  FocusNode currentPasswordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode reenterPasswordFocusNode = FocusNode();
  bool isConfirmPasswordValid = false;

  late CommonProvider commonProvider;
  bool? isBtnClick = false;

  @override
  void initState() {
    super.initState();
    commonProvider = context.read<CommonProvider>();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    reenterPasswordController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: commonBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: commonBackgroundColor,
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
            text: 'Change Password',
            fontWeight: FontWeight.w600,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.05,
            textAlign: TextAlign.start),
      ),
      body: Stack(
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
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            //emailFormFieldKey.currentState!.validate();
                            /* FocusScope.of(context)
                              .requestFocus(passwordFocusNode);*/
                          },
                          onSaved: (String value) {
                            Utils.customPrint(value);
                          }),

                      SizedBox(height: displayWidth(context) * 0.03),

                      CommonTextField(
                        //key: emailFormFieldKey,
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
                          onFieldSubmitted: (value) {
                            //emailFormFieldKey.currentState!.validate();
                            /* FocusScope.of(context)
                              .requestFocus(passwordFocusNode);*/
                          },
                          onSaved: (String value) {
                            Utils.customPrint(value);
                          }),
                      SizedBox(height: displayWidth(context) * 0.03),

                      CommonTextField(
                        //key: emailFormFieldKey,
                          controller: reenterPasswordController,
                          focusNode: reenterPasswordFocusNode,
                          labelText: 'Re-Enter New Password',
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
                              return 'Re-Enter New Password';
                            } else if (reenterPasswordController.text !=
                                newPasswordController.text) {
                              isConfirmPasswordValid = false;
                              return "Passwords don\'t match";
                            }

                            isConfirmPasswordValid = true;

                            return null;
                          },
                          onFieldSubmitted: (value) {
                            //emailFormFieldKey.currentState!.validate();
                            /* FocusScope.of(context)
                              .requestFocus(passwordFocusNode);*/
                          },
                          onSaved: (String value) {
                            Utils.customPrint(value);
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

                              FocusScope.of(context)
                                  .requestFocus(FocusNode());
                              if(check){
                                setState(() {
                                  isBtnClick = true;
                                });

                                commonProvider.changePassword(context, widget.token!, newPasswordController.text, scaffoldKey).then((value){
                                  if(value != null){
                                    setState(() {
                                      isBtnClick = false;
                                    });
                                    print("Status code of change password is: ${value.statusCode}");
                                    if(value.statusCode == 200){
                                      signOut();
                                    }
                                  } else{
                                    setState(() {
                                      isBtnClick = false;
                                    });
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
    );
  }

  signOut() async {

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
}

