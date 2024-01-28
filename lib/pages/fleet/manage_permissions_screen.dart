import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../bottom_navigation.dart';
import '../feedback_report.dart';

class ManagePermissionsScreen extends StatefulWidget {
  const ManagePermissionsScreen({super.key});

  @override
  State<ManagePermissionsScreen> createState() => _ManagePermissionsScreenState();
}

class _ManagePermissionsScreenState extends State<ManagePermissionsScreen> {

  final controller = ScreenshotController();

  List multipleSelected = [];
  bool isSelectAllEnabled = false;
List<String> fleetData=['Fleet1','Fleet2','Fleet3','Fleet4'];
String? fleetItem='Fleet1';
  List<ManageVesselModel> manageVesselList = [
    ManageVesselModel(vesselName: 'Vessel Name', id: 'ID: #165161656', type: 'Hybrid'),
    ManageVesselModel(vesselName: 'Vessel Name', id: 'ID: #116165645', type: 'Electric'),
    ManageVesselModel(vesselName: 'Vessel Name', id: 'ID: #165116566', type: 'Combustion'),
  ];

  List checkListItems = [
    {
      "id": 0,
      "value": false,
      "title": "Sunday",
    },
    {
      "id": 1,
      "value": false,
      "title": "Monday",
    },
    {
      "id": 2,
      "value": false,
      "title": "Tuesday",
    },
    {
      "id": 3,
      "value": false,
      "title": "Wednesday",
    },
    {
      "id": 4,
      "value": false,
      "title": "Thursday",
    },
    {
      "id": 5,
      "value": false,
      "title": "Friday",
    },
    {
      "id": 6,
      "value": false,
      "title": "Saturday",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: false,
          title: commonText(
              context: context,
              
              text: 'Assign Vessels',
              fontWeight: FontWeight.w600,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
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
            )
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: displayHeight(context),
                margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<String>(
                            value: fleetItem,
    selectedItemBuilder: (BuildContext context) {
      return fleetData!.map<Widget>((String item) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display selected item
            commonText(
             text: item,
              fontWeight: FontWeight.w400,
              textSize: 16,
              textColor: buttonBGColor
            ),
            // Add any additional information or text here
            Container(
              child: Row(
                children: [
                  commonText(text: 'Created By:',
                  textSize: 11,
                  fontWeight: FontWeight.w400,
                  textColor: Colors.grey
                  ),

                                    commonText(text: 'Abhiram',
                  textSize: 11,
                  fontWeight: FontWeight.w500,
                  textColor: buttonBGColor
                  ),

                  
                ],
              )
            ),
          ],
        );
      }).toList();
                            },
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
                                                                color:  
                                                                     Colors.black,
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
fleetItem=newValue;
                                });
                            },
                        ),
                    ),
                                  ),
                    // SizedBox(height: displayHeight(context) * 0.05,),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: commonText(
                    //       context: context,
                    //       text: 'Assign Vessels',
                    //       fontWeight: FontWeight.w600,
                    //       textColor: Colors.black,
                    //       textSize: displayWidth(context) * 0.05,
                    //       textAlign: TextAlign.start),
                    // ),

                    // SizedBox(height: displayHeight(context) * 0.03,),

                    // Container(
                    //   width: displayWidth(context),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.withOpacity(.1),
                    //     borderRadius: BorderRadius.circular(18)
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 18),
                    //     child: commonText(
                    //         context: context,
                    //         text: 'abhiram90@gmail.com',
                    //         fontWeight: FontWeight.w500,
                    //         textColor: Colors.black87,
                    //         textSize: displayWidth(context) * 0.038,
                    //         textAlign: TextAlign.start),
                    //   ),
                    // ),

                    SizedBox(height: displayHeight(context) * 0.02,),

                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15,
                      
                      
                      ),
                      color: reportTripsListBackColor
                      
                      ),
                      child: Column(
                        children: [
                          CustomLabeledCheckbox(
                            label: 'Select All',
                            value: isSelectAllEnabled,
                            onChanged: (value) {
                              setState(() {
                                isSelectAllEnabled = !isSelectAllEnabled;
                                if(isSelectAllEnabled){
                                  for (var element in checkListItems){
                                    element["value"] = true;
                                    multipleSelected.add(element);
                                  }
                                }
                                else{
                                  for (var element in checkListItems){
                                    element["value"] = false;
                                    multipleSelected.remove(element);
                                  }
                                }
                                return;
                                multipleSelected.clear();
                                for (var element in checkListItems) {
                                  if (element["value"] == false) {
                                    element["value"] = true;
                                    multipleSelected.add(element);
                                  } else {
                                    element["value"] = false;
                                    multipleSelected.remove(element);
                                  }
                                }
                              });
                            },
                            checkboxType: CheckboxType.Parent,
                            activeColor: blueColor,
                          ),
                       
                       ListView.builder(
                        shrinkWrap: true,
                        itemCount:manageVesselList.length ,
                          itemBuilder:(context,index){
                         // manageVesselList.length,
                              //(index) =>
                              
                              
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                                                  color: reportTripsListColor,

                                ),
                                child: CheckboxListTile(
                                  activeColor: blueColor,
                                                            controlAffinity: ListTileControlAffinity.leading,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                                            dense: true,
                                                            title: checkBoxCard(manageVesselList[index]),
                                                            value: checkListItems[index]["value"],
                                                            onChanged: (value) {
                                setState(() {
                                  checkListItems[index]["value"] = value;
                                  if (multipleSelected.contains(checkListItems[index])) {
                                    multipleSelected.remove(checkListItems[index]);
                                  } else {
                                    multipleSelected.add(checkListItems[index]);
                                  }
                                });
                                                            },
                                                                            ),
                              );
                          })
                        
                      
                      
                                        ],
                                        ),
                    ),
                  ]
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(

                color: Colors.white,
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 17, right: 17, top: 8),
                      child: CommonButtons.getActionButton(
                          title: 'Grand Access',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          width: displayWidth(context),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ManagePermissionsScreen()),
                            );
                          }),
                    ),
                    GestureDetector(
                        onTap: ()async{
                          final image = await controller.capture();

                          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                            imagePath: image.toString(),
                            uIntList: image,)));
                        },
                        child: UserFeedback().getUserFeedback(context)
                    ),
                    SizedBox(height: 4,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkBoxCard(ManageVesselModel manageVesselList){

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height:displayHeight(context) * 0.06,
              width: displayWidth(context) * 0.12,
              decoration: BoxDecoration(
                color: reportTripsListColor,
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/vessel_default_img.png",
                    )),
              )),
          SizedBox(width: 8,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              commonText(
                  context: context,
                  text: manageVesselList.vesselName,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.038,
                  textAlign: TextAlign.start),
              commonText(
                  context: context,
                  text: manageVesselList.id,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.grey,
                  textSize: displayWidth(context) * 0.028,
                  textAlign: TextAlign.start),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: VerticalDivider(
              color: Colors.black,
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              commonText(
                  context: context,
                  text: manageVesselList.type,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.038,
                  textAlign: TextAlign.start),
              commonText(
                  context: context,
                  text: 'Type',
                  fontWeight: FontWeight.w500,
                  textColor: Colors.grey,
                  textSize: displayWidth(context) * 0.028,
                  textAlign: TextAlign.start),
            ],
          ),
        ],
      ),
    );

  }

}

class ManageVesselModel
{
  String? vesselName, id, type;
  ManageVesselModel({this.vesselName, this.id, this.type});
}
