import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

class CustomFleetDailog {

  void showFleetDialog({String title='',String subtext='',String description='',String positiveButtonText='',Color? postiveButtonColor,Color? negtiveButtuonColor ,
  
   VoidCallback?onPostiveButtonTap,VoidCallback? onNgeitiveButtonTap,BuildContext? context  })async{

    showDialog(
        context: context!,

        builder: (_) => Dialog(
                   // insetPadding: EdgeInsets.all(20),

             shape: RoundedRectangleBorder(borderRadius: 
                BorderRadius.all(Radius.circular(10.0))),

          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10,),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 8),
                  child: commonText(text: title,
                  fontWeight: FontWeight.w600,
                  textSize: 16
                  
                  ),
                  
                ),
if(subtext.isNotEmpty)

                Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8),

                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 8),
                  child: commonText(text: subtext,
                  fontWeight: FontWeight.w500,
                  textSize: 13,
                  textColor: blueColor
                  
                  ),
                  
                ),
SizedBox(height: 5,),
if(description.isNotEmpty)

                Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8),

                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 8),
                  child: commonText(text: description,
                  fontWeight: FontWeight.w400,
                  textSize: 14,
                  textColor: Colors.grey
                  
                  ),
                  
                ),
                SizedBox(height: 10,),
Container(
  margin: EdgeInsets.only(bottom: 20),
  child: Row(
    children: [

                                  Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: CommonButtons.getAcceptButton(
                                'Cancel',
                                context,
                                Colors.transparent,
                                onNgeitiveButtonTap??(){
                                  Navigator.pop(context);
                                },
                                                        displayWidth(context) * 0.65,
                               displayHeight(context) * 0.054
                                 ,
                              Colors.transparent,
                              
                                  negtiveButtuonColor?? blueColor,
                               displayHeight(context!) * 0.018,
                                  
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

                            Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: CommonButtons.getActionButton(
                                        title: positiveButtonText,
                                        context: context,
                                        fontSize: 15,
                                        
                                        textColor: Colors.white,
                                        buttonPrimaryColor: postiveButtonColor??blueColor,
                                        borderColor:postiveButtonColor?? blueColor,
                                        onTap:onPostiveButtonTap??(){},
                                        width: 200,
                                        height: displayHeight(context)*0.050,
                                        
                                        
                                        ),
                              ),
                            ),
  
      
    ],
  ),
)

              ],
            ),
          ),
        )
    );

  }
}