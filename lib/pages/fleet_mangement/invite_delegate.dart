import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_time_picker.dart';
import 'package:performarine/common_widgets/widgets/user_feed_back.dart';
import 'package:performarine/common_widgets/widgets/vessel_info_card.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/feedback_report.dart';
import 'package:performarine/services/database_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:table_calendar/table_calendar.dart';

class InviteDelegate extends StatefulWidget {
  const InviteDelegate({super.key});

  @override
  State<InviteDelegate> createState() => _InviteDelegateState();
}

class _InviteDelegateState extends State<InviteDelegate> {
    final controller = ScreenshotController();
  GlobalKey<ScaffoldState>  scaffoldKey = GlobalKey();
  String selectedDuration = '24 hrs';
    late Future<List<CreateVessel>> getVesselFuture;
    CreateVessel? vesselData;
  final DatabaseService _databaseService = DatabaseService();
  DateTime firstDate = DateTime(1980);
  DateTime lastDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime startDate=DateTime.now();
  String startDateText='';
  Duration duration = const Duration();
  bool isCustomTime=false;
String startTime='01:00 AM';
String endTime='01:00 AM';
int calenderType=0;
String endDate='';
  @override
  void initState() {
                getVesselFuture = _databaseService.vessels();
          getVesselFuture.then((value)  {
           vesselData=   value[1];
           setState(() {
             
           });
           
            });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
        controller: controller,
        child: Scaffold(
          backgroundColor: backgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
          Navigator.pop(context);

        
              },
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: commonText(
                context: context,
                text: 'Send Invite',
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                textSize: displayWidth(context) * 0.042,
                fontFamily: outfit
            ),
            actions: [
      
              InkWell(
                onTap: ()async{
                },
                child: Image.asset(
                  'assets/images/Trash.png',
                  width: Platform.isAndroid ? displayWidth(context) * 0.065 : displayWidth(context) * 0.05,
                ),
              ),
      
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () async{
                   await   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
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
          body: Container(
            child: Stack(
              children: [
//vesselSingleViewCard(context,CreateVessel(),((p0) {} ),scaffoldKey),

Container(
  margin: EdgeInsets.only(left: 12,right: 12,bottom:                     displayHeight(context)/7,
 ),
child: SingleChildScrollView(
  scrollDirection: Axis.vertical,
  child: Column(
    children: [
                                              if(vesselData!=null)
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 15,),
                                      width: displayWidth(context),
                                      //height: displayHeight(context)*0.2,
                                      
                                      child: VesselinfoCard(vesselData: vesselData,)),
                                      SizedBox(height: 10,),
  
  
  commonText(text:'Invite Delegate',
  fontWeight: FontWeight.w700,
  textSize: 20
  
  ),
  SizedBox(height: 10,),
  
  SizedBox(
  width: displayWidth(context)/1.1,
  child: CommonTextField(
                     // controller: nameController,
                     // focusNode: nameFocusNode,
                      labelText: 'Email ID',
                      hintText: '',
                      circularRadius: 20,
                      suffixText: null,
                      fillColor: dropDownBackgroundColor,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 32,
                      prefixIcon: null,
                      suffixIcon: Icon(Icons.close),
                     // requestFocusNode: modelFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {
                      },
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Valid Email';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                      }),
  ) ,
  
  SizedBox(height: 10,),
  Container(
  padding: EdgeInsets.all(8),
  alignment: Alignment.centerLeft,
  child: commonText(text: 'Share Access upto',
  textSize: 13,
  fontWeight: FontWeight.w400
  ),
  ),
  SizedBox(height: 10,),
  
  Column(
      children: [
        Row(
          children: [
        radioButton('24 hrs',false),
            radioButton('7 days',false),
            radioButton('1 month',false)
          ],
        ),
          
          Row(
            children: [
  radioButton('Always',false),
  radioButton('Custom time',true),
  Flexible(
  flex:   1,
  fit: FlexFit.tight,
  child: SizedBox())
  
            ],
          ),



Visibility(
  visible: isCustomTime,
  child: Column(
    children: [
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Flexible(
        flex: 6,
        fit: FlexFit.tight,

        child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
        child: InkWell(
          onTap: () {
            calenderType=0;
            setState(() {
              
            });
          },
          
          child: fromToDate('From Date: ',startDateText))),
      ),
      Flexible(
        flex: 4,
        fit: FlexFit.tight,
        child: Container(
          alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
        
        child: InkWell(
          onTap: () {
            calenderType=1;
            setState(() {
              
            });
        
          },
          
          child: fromToDate('To Date: ',endDate))),
      ),
      
      ],
      ),
    
  
  
  
  
                                        Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.045,
                          right: displayWidth(context) * 0.045,
                          top: 8,
                          bottom: 8
                          ),
                          
                      child: Container(
                        width: displayWidth(context),
                        height: 50,
                        decoration: BoxDecoration(
                            color: calenderHeaderBackgroundColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                30,
                              ),
                              topLeft: Radius.circular(
                                30,
                              ),
                            )),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: displayWidth(context) * 0.03,
                              top:  displayWidth(context) * 0.05),
                                 
                          child: Text(
                          calenderType==0?  "Select Start Date":'Select End Date',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DM Sans'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.045,
                          right: displayWidth(context) * 0.045),
                      child: Container(
                        decoration: BoxDecoration(
                            color: calenderBackgroundColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))),
                        child: Visibility(
                         // visible: !isEndDateSected!,
                          child: TableCalendar(
                            daysOfWeekVisible: true,
                            focusedDay: startDate,
                            firstDay: firstDate,
                            lastDay: lastDate,
                            onFormatChanged: (CalendarFormat _format) {},
                            calendarBuilders: CalendarBuilders(
                              selectedBuilder: (context, date, events) =>
                                  Container(
                                      margin: const EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: blueColor,
                                          borderRadius:
                                              BorderRadius.circular(15)
                                          //shape: BoxShape.circle
                          
                                          ),
                                      child: Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: dmsans),
                                      )),
                            ),
                            calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: blueColor,
                                    )),
                                isTodayHighlighted: true,
                                selectedDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                          
                                  // color: blueColor,
                                  shape: BoxShape.rectangle,
                                ),
                                selectedTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.0,
                                    fontFamily: dmsans,
                                    color: Colors.pink),
                                todayTextStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                    fontFamily: dmsans,
                                    color:focusedDay==
                          DateTime.now()
                                            ? Colors.white
                                            : blueColor                                        
                                        )),
                                selectedDayPredicate: (DateTime date) {
                                  return isSameDay(
                                      startDate, date);
                                },
                            startingDayOfWeek: StartingDayOfWeek.monday,
                                onDaySelected:
                                    (DateTime? selectDay, DateTime? focusDay) {
                                  setState(() {
                                  focusedDay=focusDay!;
                                  startDate=selectDay!;
                                  if(calenderType==0){
                                    startDateText=convertIntoMonthDayYear(selectDay);
                                    calenderType=1;
                                    setState(() {
                                      
                                    });
                                  }else{
                                    endDate=convertIntoMonthDayYear(selectDay);
                                  }
                                  
                                  
                                  });
                          
                                },
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                          
                              titleTextStyle: TextStyle(
                                  fontSize: 17,
                                  fontFamily: dmsans,
                                  fontWeight: FontWeight.w600,
                                  color: blackcolorCalender),
                              // Center the month title
                          
                              formatButtonVisible: false,
                              formatButtonDecoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                              formatButtonTextStyle:
                                  TextStyle(color: Colors.white),
                              formatButtonShowsNext: false,
                            ),
                          ),
                        ),
                      ),
                    ),
  
  SizedBox(height: 20,),
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Container(
    margin: EdgeInsets.only(left: 8),
      alignment: Alignment.centerRight,
  
  padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
  child: fromToDate('Start Time: ',startTime),
  
  
  ),
  Container(
    margin: EdgeInsets.only(right: 8),
    alignment: Alignment.centerLeft,
  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
  
  child: fromToDate('End Time: ',endTime)),
  
  ],
  ),
  
  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
  
    children: [
  CustomTimePicker(
    getTime: (time) {
      startTime=time;
        setState(() {
      
    });
  
      Utils.customPrint('the start time was $time');
    },
  ),
  CustomTimePicker(
  getTime: (time) {
    endTime=time;
    setState(() {
      
    });
        Utils.customPrint('the end time was $time');
  
  },
  
  )
  
    ],
  )
  
                      
    
      ]),
)
      ])
   ],
  ),
),
),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: displayHeight(context)/7.9,
                    padding: EdgeInsets.all(8),
                  
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CommonButtons.getActionButton(
                              title: 'Invite Delegate',
                              context: context,
                              fontSize: displayWidth(context) * 0.044,
                              textColor: Colors.white,
                              buttonPrimaryColor: blueColor,
                              borderColor: blueColor,
                              onTap: (){
                  
                              },
                              width: displayWidth(context)/1.3,
                              
                              ),
                  
                              SizedBox(height: 10,),
                              GestureDetector(
                                onTap: (()async {
                                          final image = await controller.capture();
                          await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                  
                  
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackReport(
                            imagePath: image.toString(),
                            uIntList: image,)));
                  
                                }),
                                      child: UserFeedback().getUserFeedback(
                                          context,
                                          )),
                   
                   
                   
                   
                   
                   
                   
                    ],
                  
                  ),
                                  ),
                ),
                
            ]))
            
            
            ));
  }

  Widget radioButton(String text,bool isCustomTime1){
    return Flexible(
      fit: FlexFit.tight,
      flex: 1,
        child:  Row(children: [
                        Radio(
              value: text,
              groupValue: selectedDuration,
              onChanged: (value) {
                setState(() {
                  if(isCustomTime1){
                    isCustomTime=true;
                  }else{
                                        isCustomTime=false;

                  }
                  selectedDuration = value.toString();
                });
              },
            ),
            commonText(text: text,
            fontWeight: FontWeight.w400,
            textSize: 12
            
            ),

    ]));


        }
        Widget fromToDate(String title,String date){
          return Container(
           // color: Colors.amber,
            child: RichText(
              
              text: TextSpan(
              children: [
                TextSpan(
                text: title, style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,fontFamily: outfit,
                color: Colors.black
                
                )),
                WidgetSpan(child: SizedBox(width: 5,)),
                
                TextSpan(
                text: date, style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12,fontFamily: outfit,
                color: blueColor
                
                )),
              ]
            )),
          );
        }
          String convertIntoMonthDayYear(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    Utils.customPrint(dateString);

    return dateString;
  }

}