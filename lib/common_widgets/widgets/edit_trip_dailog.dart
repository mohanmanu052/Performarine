import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

class EditTripDailog {
  void showEditTripDialog(
      {String title = '',
      String positiveButtonText = '',
      Color? postiveButtonColor,
      Color? negtiveButtuonColor,
      Function(String?)? onPositiveButtonTap,
      VoidCallback? onNegativeButtonTap,
      BuildContext? context,
      String? initalvalue,
      }) async {
    TextEditingController nameController = TextEditingController();
   //flut FocusNode nameFocusNode = FocusNode();
nameController.text=initalvalue??'';
    showDialog(
        context: context!,
        builder: (_) => Dialog(
              // insetPadding: EdgeInsets.all(20),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),

              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 10,
                    ),

                    Container(
                      child: Image.asset(
                        'assets/images/edit_trip_image.png',
                        height: 100,
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: commonText(
                          text: title,
                          fontWeight: FontWeight.w600,
                          textSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: CommonTextField(
                          controller: nameController,
                         // focusNode: nameFocusNode,
                          labelText: 'Name Of Trip',
                          hintText: 'Name Of Trip',
                          suffixText: null,
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 50,
                          prefixIcon: null,
                          requestFocusNode: null,
                          obscureText: false,
                          onTap: () {},
                          onChanged: (String value) {},
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Enter Trip Name';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            // CustomLogger().logWithFile(Level.info, "vessel name $value -> $page");
                            // Utils.customPrint(value);
                          }),
                    ),

                    //hintText: 'Name Of Trip',

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: CommonButtons.getActionButton(
                        title: positiveButtonText,
                        context: context,
                        fontSize: 15,
                        textColor: Colors.white,
                        buttonPrimaryColor: postiveButtonColor ?? blueColor,
                        borderColor: postiveButtonColor ?? blueColor,
                        onTap: (){
                          if(onPositiveButtonTap != null)
                            {
                              onPositiveButtonTap(nameController.text);
                            }
                        },
                        //  width: 170,
                        height: displayHeight(context) * 0.050,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 20, right: 15),
                      child: CommonButtons.getAcceptButton(
                          'Cancel',
                          context,
                          Colors.transparent,
                          onNegativeButtonTap ??
                              () {
                                Navigator.pop(context);
                              },
                          displayWidth(context) * 0.65,
                          displayHeight(context) * 0.054,
                          Colors.transparent,
                          negtiveButtuonColor ?? blueColor,
                          displayHeight(context) * 0.018,
                          Colors.transparent,
                          '',
                          fontWeight: FontWeight.w500

                          // title: 'Cancel',
                          // context: context,
                          // fontSize: displayWidth(context) * 0.044,
                          // textColor: blueColor,
                          // buttonPrimaryColor: Colors.white,
                          // borderColor: Colors.white,
                          // onTap: (){

                          // },
                          // width: displayWidth(context)/1.3,
                          // height: displayHeight(context)*0.050

                          ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
