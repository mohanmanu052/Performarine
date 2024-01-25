import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/fleet/widgets/fleet_details_card.dart';
import 'package:performarine/pages/fleet/widgets/member_details_widget.dart';
import 'package:performarine/services/database_service.dart';
import 'package:screenshot/screenshot.dart';

class FleetVesselScreen extends StatefulWidget {
  const FleetVesselScreen({super.key});

  @override
  State<FleetVesselScreen> createState() => _FleetVesselScreenState();
}

class _FleetVesselScreenState extends State<FleetVesselScreen> with TickerProviderStateMixin{
GlobalKey<ScaffoldState> _scafoldKey=GlobalKey();
  final DatabaseService _databaseService = DatabaseService();
List<String> fleetData=['Fleet1','Fleet2','Fleet3','Fleet4'];
  late Future<List<CreateVessel>> getVesselFuture;
  TabController?  _tabController;

int currentTabIndex=0;
@override
  void initState() {
 _tabController=    TabController(length: 2, vsync: this);
 _tabController!.addListener(_handleTabSelection);
        getVesselFuture = _databaseService.vessels();

    // TODO: implement initState
    super.initState();
  }

    void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      switch (_tabController!.index) {
        case 0:
currentTabIndex=0;
setState(() {
  
});
break;
        case 1:
        currentTabIndex=1;
        setState(() {
          
        });
          break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        key: _scafoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
            context: context,
            text: 'Fleet Vessels',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.045,
          ),
          actions: [
Container(
  margin: EdgeInsets.only(right: 10),
  alignment: Alignment.center,
  child: commonText(text: 'Edit Fleet',
  textColor: blueColor,
  fontWeight: FontWeight.w500,
  textSize: 13
  ),
),

            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async{
                await  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          margin: EdgeInsets.symmetric(horizontal: 15,),
          child: Column(
            children: [
              SizedBox(height: 20,),
          
          DropdownButtonHideUnderline(
                  child: DropdownButtonFormField2<String>(
                      value: 'Fleet1',
                      
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
                      items:fleetData
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
          
          SizedBox(height: 20,),
           
           TabBar(
             unselectedLabelColor: Colors.black,
             labelColor: Colors.white,
             
           indicator: ShapeDecoration(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:currentTabIndex==0? Radius.circular(20):Radius.circular(0),
              bottomLeft:currentTabIndex==0? Radius.circular(20):Radius.circular(0),
             topRight: currentTabIndex==1? Radius.circular(20):Radius.circular(0),
             bottomRight: currentTabIndex==1? Radius.circular(20):Radius.circular(0)
             )),
             color: blueColor
           ),
             tabs: [
           
               Tab(
           child: Container(child: commonText(text: 'Members'),),
               ),
               Tab(
           child: Container(child: commonText(text: 'Vessels'),),
               ),
             ],
             controller: _tabController,
             indicatorSize: TabBarIndicatorSize.tab,
           ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  MemberDetailsWidget(),
                  FleetDetailsCard(
                    scaffoldKey: _scafoldKey,
                  )
                  //Container(child: Center(child: Text('people'))),
                 // Text('Person')
                ],
                controller: _tabController,
              ),
            ),
        //  ],
      //  ),
    //  ),
          
              // TabBarView(
                
              //   children: [
              //   MemberDetailsWidget(),
              //   Container(
              //     color: Colors.red,
              //   )
              // ],),
            ],
          ),
        )
        
        
        // SingleChildScrollView(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Container(
        //         color: backgroundColor,
        //         child: FutureBuilder<List<CreateVessel>>(
        //           future: getVesselFuture,
        //           builder: (context, snapshot) {
        //             if (snapshot.connectionState == ConnectionState.waiting) {
        //               return Center(
        //                 child: CircularProgressIndicator(
        //                   valueColor:
        //                       AlwaysStoppedAnimation<Color>(circularProgressColor),
        //                 ),
        //               );
        //             }
        //             Utils.customPrint('Fleet Vessel HAS DATA: ${snapshot.hasData}');
        //             Utils.customPrint('Fleet Vessel Error: ${snapshot.error}');
        //             Utils.customPrint('Fleet Vessel IsError: ${snapshot.hasError}');
        //             if (snapshot.hasData) {
        //               if (snapshot.data!.isEmpty) {
        //                 return Padding(
        //                   padding: EdgeInsets.only(top: displayHeight(context) * 0.43),
        //                   child: Center(
        //                     child: commonText(
        //                         context: context,
        //                         text: 'No vessels available'.toString(),
        //                         fontWeight: FontWeight.w500,
        //                         textColor: Colors.black,
        //                         textSize: displayWidth(context) * 0.04,
        //                         textAlign: TextAlign.start),
        //                   ),
        //                 );
        //               } else {
        //                 return Column(
        //                   children: [
        //                     Container(
        //                       // height: displayHeight(context),
        //                       color: backgroundColor,
        //                       padding: const EdgeInsets.only(
        //                           left: 8.0, right: 8.0, top: 8, bottom: 10),
        //                       child: ListView.builder(
        //                         itemCount: snapshot.data!.length,
        //                         primary: false,
        //                         shrinkWrap: true,
        //                         //physics: NeverScrollableScrollPhysics(),
        //                         itemBuilder: (context, index) {
        //                           final vessel = snapshot.data![index];
        //                           return snapshot.data![index].vesselStatus == 1
        //                               ? vesselSingleViewCard(context, vessel,
        //                                   (CreateVessel value) {

        //                                   }, _scafoldKey)
        //                               : SizedBox();
        //                         },
        //                       ),
        //                     ),
        //                   ],
        //                 );
        //               }
        //             }
        //             return Container();
        //           },
        //         ),
        //       ),

        //       SizedBox(
        //         height: displayWidth(context) * 0.04,
        //       )
        //     ],
        //   ),
        // ),
        

          );

  }
}