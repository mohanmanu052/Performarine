import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';

import 'package:provider/provider.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_dialog_new.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/zig_zag_line_widget.dart';
import '../../provider/common_provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  late CommonProvider commonProvider;
  bool? isBtnClick = false;

  String page = "forgot_password";

  @override
  void initState() {
    super.initState();

    commonProvider = context.read<CommonProvider>();
    emailController = TextEditingController();
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
            text: 'Forgot Password',
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
                        labelText: 'Email\*',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.done,
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
                            return 'Enter Email';
                          }else if (!EmailValidator.validate(value)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Email $value -> $page");
                        }),

                    SizedBox(height: displayHeight(context) * 0.27),

                  isBtnClick! ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            circularProgressColor),
                      ))
                      :   CommonButtons.getActionButton(
                        title: 'Send Reset link',
                        context: context,
                        fontSize: displayWidth(context) * 0.044,
                        textColor: Colors.white,
                        buttonPrimaryColor: buttonBGColor,
                        borderColor: buttonBGColor,
                        width: displayWidth(context),
                        onTap: () async {
                          if(formKey.currentState!.validate()){
                            bool check = await Utils().check(scaffoldKey);
                            if(check){
                              setState(() {
                                isBtnClick = true;
                              });
                              commonProvider.forgotPassword(context, emailController.text.toLowerCase().trim(), scaffoldKey).then((value){
                                if(value != null && value.status!){
                                  setState(() {
                                    isBtnClick = false;
                                  });
                                Utils.customPrint("status code of forgot password: ${value.statusCode}");
                                  CustomLogger().logWithFile(Level.info, "status code of forgot password: ${value.statusCode} -> $page");

                                  if(value.statusCode == 200){
                                    CustomLogger().logWithFile(Level.info, "User navigating to Sign in Screen -> $page");
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SignInScreen(),
                                        ),
                                        ModalRoute.withName(""));
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
}

