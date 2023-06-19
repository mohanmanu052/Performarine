import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_dialog_new.dart';
import '../../common_widgets/widgets/zig_zag_line_widget.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
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
            text: 'Reset Password',
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
                        controller: emailController,
                        focusNode: emailFocusNode,
                        labelText: 'Email/Phone',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 52,
                        prefixIcon: null,
                        requestFocusNode: null,
                        obscureText: false,
                        readOnly: false,
                        onTap: () {},
                        onChanged: (value) {},
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Email or Phone Number';
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

                    SizedBox(height: displayHeight(context) * 0.2),

                    CommonButtons.getActionButton(
                        title: 'Reset Password',
                        context: context,
                        fontSize: displayWidth(context) * 0.044,
                        textColor: Colors.white,
                        buttonPrimaryColor: buttonBGColor,
                        borderColor: buttonBGColor,
                        width: displayWidth(context),
                        onTap: () async {
                        return showDialog(
                            context: context,
                            builder: (context) => CustomDialogNew(
                              imagePath: 'assets/images/mail.png',
                              text: 'A reset password link has been sent to your registered mail id “<user email>”',
                              onPressed: () {
                                Utils.customPrint("Clicked on go to email button");
                                Navigator.pop(context);
                              },
                            ),
                          );
                        /*  if (formKey.currentState!.validate()) {
                            bool check = await Utils().check(scaffoldKey);

                            Utils.customPrint("NETWORK $check");

                            FocusScope.of(context)
                                .requestFocus(FocusNode());

                           /* if (check) {
                              setState(() {
                                isLoginBtnClicked = true;
                              });

                              if (isLoginByEmailId) {
                                commonProvider
                                    .login(
                                    context,
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    false,
                                    "",
                                    scaffoldKey)
                                    .then((value) {
                                  setState(() {
                                    isLoginBtnClicked = false;
                                  });

                                  if (value != null) {
                                    if (value.status!) {
                                      /*Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage(),
                                            ),
                                            ModalRoute.withName(""));*/

                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SyncDataCloudToMobileScreen(),
                                          ),
                                          ModalRoute.withName(""));
                                    }
                                  }
                                }).catchError((e) {
                                  setState(() {
                                    isLoginBtnClicked = false;
                                  });
                                });
                              } else {}
                            } */
                          } */
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
}

