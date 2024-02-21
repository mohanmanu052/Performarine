import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
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
  margin: EdgeInsets.only(bottom: 20,right:15),
  child: Row(
    children: [

                                  Flexible(
                              flex: 3,
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
                              flex: 4,
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
                                        onTap:onPostiveButtonTap,
                                        width: 170,
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


    void showEditFleetDialog({List<String>? fleetData,BuildContext? context  })async{
  String selectedStatus= 'Active';
  final _formKey = GlobalKey<FormState>();
    showDialog(
        context: context!,

        builder: (_) => StatefulBuilder(
          builder: (context,setState) {
            return Dialog(
                       // insetPadding: EdgeInsets.all(20),
            
                 shape: RoundedRectangleBorder(borderRadius: 
                    BorderRadius.all(Radius.circular(15.0))),
            
              child: Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    commonText(text: 'Edit Fleet Details',
                    fontWeight: FontWeight.w600,
                  textSize: 16
                    
                    ),SizedBox(
                      height: 10,
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                            value: fleetData![0],
                            
                          iconStyleData: IconStyleData(
                            icon: Icon(Icons.keyboard_arrow_down,
                            size: 30,
                            )
                          ),
                                                          isExpanded: true,
                                                          buttonStyleData: ButtonStyleData(
                                                            height: 40,width: 40,
                            
                                                            padding: EdgeInsets.only(left: 20,right: 40)
                                                          ),
                                                          decoration: InputDecoration(
                                                            //errorText: _showDropdownError1 ? 'Select Vessel' : null,
                            
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal: 0,
                                                                    vertical:  10
                                                                        ),
                            
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1.5,
                                                                    color: Colors
                                                                        .transparent),
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius
                                                                            .circular(
                                                                                15))),
                                                            enabledBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1.5,
                                                                    color: Colors
                                                                        .transparent),
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius
                                                                            .circular(
                                                                                15))),
                                                            errorBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1.5,
                                                                    color: Colors
                                                                        .red.shade300
                                                                        .withOpacity(
                                                                            0.7)),
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius
                                                                            .circular(
                                                                                15))),
                                                            errorStyle: TextStyle(
                                                                fontFamily: inter,
                                                                fontSize: displayWidth(
                                                                            context) *
                                                                        0.025
                                                            ),
                                                            focusedErrorBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1.5,
                                                                    color: Colors
                                                                        .red.shade300
                                                                        .withOpacity(
                                                                            0.7)),
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius
                                                                            .circular(
                                                                                15))),
                                                            fillColor:
                                                                dropDownBackgroundColor,
                                                            filled: true,
                            
                                                            hintStyle: TextStyle(
                                                                color: Theme.of(context)
                                                                            .brightness ==
                                                                        Brightness
                                                                            .dark
                                                                    ? "Filter By" ==
                                                                            'User SubRole'
                                                                        ? Colors
                                                                            .black54
                                                                        : Colors.white
                                                                    : Colors.black,
                                                                fontSize:  displayWidth(
                                                                            context) *
                                                                        0.034
                                                                    ,
                                                                fontFamily: outfit,
                                                                fontWeight:
                                                                    FontWeight.w300),
                                                          ),
                                                          hint: Container(
                                                            alignment:
                                                                Alignment.centerLeft,
                                                            margin: EdgeInsets.only(
                                                              left: 15,
                                                            ),
                                                            child:
                                                             Text(
                                                              'Select Fleet',
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize:  displayWidth(
                                                                              context) *
                                                                          0.032,
                                                                  fontFamily: outfit,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                            ),
                                                          ),
                            items:fleetData!
                        .map((value) => DropdownMenuItem(
                              child: commonText(text: value,
                              fontWeight: FontWeight.w400,
                              textSize: 16,
                              textColor: buttonBGColor
                              
                              ),
                              value: value,
                            ))
                        .toList(),
                
                            onChanged: (newValue) {
                                setState(() {
                                });
                            },
                        ),
                    ),
              ),
              
            SizedBox(height: 10,),


Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
  child: Form(
    key: _formKey,
    child: CommonTextField(
                        //controller: nameController,
                       // focusNode: nameFocusNode,
                        labelText: 'Fleet Name',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 32,
                        prefixIcon: null,
                       // requestFocusNode: modelFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter Fleet Name';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          // CustomLogger().logWithFile(Level.info, "vessel name $value -> $page");
                          // Utils.customPrint(value);
                        }),
  ),
), 

                    // SizedBox(
                    //   height: 10,
                    // ),

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: CommonTextField(
                    //   //controller: nameController,
                    //                      // focusNode: nameFocusNode,
                    //   labelText: 'Name of the owner',
                    //   hintText: '',
                    //   suffixText: null,
                    //   textInputAction: TextInputAction.next,
                    //   textInputType: TextInputType.text,
                    //   textCapitalization: TextCapitalization.words,
                    //   maxLength: 32,
                    //   prefixIcon: null,
                    //                      // requestFocusNode: modelFocusNode,
                    //   obscureText: false,
                    //   onTap: () {},
                    //   onChanged: (String value) {
                    //   },
                    //   validator: (value) {
                    //     if (value!.trim().isEmpty) {
                    //       return 'Enter Owner Name';
                    //     }
                    //     return null;
                    //   },
                    //   onSaved: (String value) {
                    //     // CustomLogger().logWithFile(Level.info, "vessel name $value -> $page");
                    //     // Utils.customPrint(value);
                    //   }),
                    // ),  

//                     SizedBox(height: 10,),

//                     Row(
                      
// children: [
//                           Flexible(
//                             flex: 1,
//                             fit: FlexFit.tight,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Radio(
//                                               value: 'Active',
//                                               groupValue: selectedStatus,
//                                               onChanged: (value) {
//                                                 setState(() {
//                                                   selectedStatus = value.toString();
//                                                 });
//                                               },
//                                             ),
//                                                         commonText(text: 'Active',
//                                         fontWeight: FontWeight.w400,
//                                         textSize: 16
                                        
//                                         ),
                            
//                               ],
//                             ),
//                           ),

//                           Flexible(
//                             flex: 1,
//                             fit: FlexFit.tight,
//                             child: Row(
//                               children: [
//                                 Radio(
//                                               value: 'Inactive',
//                                               groupValue: selectedStatus,
//                                               onChanged: (value) {
//                                                 setState(() {
//                                                   selectedStatus = value.toString();
//                                                 });
//                                               },
//                                             ),
//                                                         commonText(text: 'Inactive',
//                                         fontWeight: FontWeight.w400,
//                                         textSize: 16
                                        
//                                         ),
                            
//                               ],
//                             ),
//                           ),

// ],
//                     ),

                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: CommonButtons.getActionButton(
                                        title: 'Update Changes',
                                        context: context,
                                        fontSize: 15,
                                        
                                        textColor: Colors.white,
                                        buttonPrimaryColor: blueColor,
                                        borderColor: blueColor,
                                        onTap:(){
                                          if(_formKey.currentState!.validate()){

                                          }

                                        },
                                        width: displayWidth(context)/1.3,
                                        height: displayHeight(context)*0.050,
                                        
                                        
                                        ),
                    ),
                    
Container(
  child: CommonButtons.getAcceptButton(
                                'Cancel',
                                context,
                                Colors.transparent,
                                (){
                                  Navigator.pop(context);
                                },
                                                        displayWidth(context) * 0.65,
                               displayHeight(context) * 0.054
                                 ,
                              Colors.transparent,
                              
                                   primaryColor,
                               displayHeight(context!) * 0.018,
                                  
                              Colors.transparent,
                              '',
                              fontWeight: FontWeight.w500

                                      
                                      ),
)

                  ])));
          }
        ));}
              }
