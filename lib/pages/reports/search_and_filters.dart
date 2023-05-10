import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/widgets/common_drop_down_one.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
import '../../models/reports_model.dart';
import '../../provider/common_provider.dart';
import '../home_page.dart';
import 'package:table_calendar/table_calendar.dart';

class SearchAndFilters extends StatefulWidget {
  const SearchAndFilters({Key? key}) : super(key: key);

  @override
  State<SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<SearchAndFilters> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late CommonProvider commonProvider;

  bool? isExpansionCollapse = false;
  String? selectedVessel;
  String? selectedTrip;
  int _selectedOption = 1;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime firstDate = DateTime(1980);
  DateTime lastDate = DateTime(2050);
  List<String> items = ["Start Date", "End Date"];
  DateTime lastDayFocused = DateTime.now();

  bool? parentValue = false;
  List<String>? children = [];
  List<bool>? childrenValue = [];
  List<String>? tripIdList = [];
  List<String>? dateTimeList = [];
  bool? isStartDate = false;
  bool? isEndDate = false;
  CalendarFormat format = CalendarFormat.month;

  var avgDurations;
  String selectedButton = 'trip duration';
  String? selectedCaseType = "0";
  int? selectDateOption;

  String formatYearMonthDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  DateTime startDateAndEndDateConvert(String date){
    String inputDate = date;
    DateTime dateTime = DateTime.parse(inputDate);
    final yearMonthDayFormat = DateFormat('yyyy-MM-dd');
    final formattedDateTimeString = yearMonthDayFormat.format(dateTime);
   // DateTime formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return yearMonthDayFormat.parse(formattedDateTimeString);
  }

  void manageTristate(int index, bool value) {
    setState(() {
      if (value) {
        childrenValue![index] = true;
        if (childrenValue!.contains(false)) {
          parentValue = null;
        } else {
          _checkAll(true);
        }
      } else {
        childrenValue![index] = false;
        if (childrenValue!.contains(true)) {
          parentValue = null;
        } else {
          _checkAll(false);
        }
      }
    });
  }

  void _checkAll(bool value) {
    setState(() {
      parentValue = value;

      for (int i = 0; i < children!.length; i++) {
        childrenValue![i] = value;
      }
    });
  }

  final List<Map<String, dynamic>> finalChartData = [];

  List<Map<String, dynamic>> tripList = [];

  List<Map<String, dynamic>> tripAvgList = [];

  List<TripData> tripDataList = [];
  List<TripModel> triSpeedList = [];
  ReportModel? reportModel;
  dynamic avgSpeed;
  dynamic avgDuration = 0;
  dynamic avgFuelConsumption;
  dynamic avgPower;

  bool? tripDurationButtonColor = false;
  bool? avgSpeedButtonColor = false;
  bool? fuelUsageButtonColor = false;
  bool? powerUsageButtonColor = false;

  bool? isReportDataLoading = false;

  List<Map<String, String>> finalData = [];


  List<Vessels> vesselList = [];
  List<DropdownItem> vesselData = [];

  List<DropdownItem> tripData = [];

  bool? isVesselDataLoading = false;

  List<String>? selectedTripIdList = [];

  bool? isTripIdListLoading = false;

  getTripListData(String vesselID)async{
    try{
      commonProvider.tripListData(vesselID, context, commonProvider.loginModel!.token!, scaffoldKey).then((value) {
        if(value != null){
          setState(() {
            isTripIdListLoading = true;
          });
          print("value of trip list: ${value.data}");
          //debugger();
          dateTimeList!.clear();
          for(int i = 0; i < value.data!.length; i++){
            tripIdList!.add(value.data![i].id!);
            dateTimeList!.add(value.data![i].createdAt != null && value.data![i].createdAt!.isNotEmpty ? tripDate(value.data![i].createdAt!) : "");
            children!.add("Trip ${i.toString()}");
          }
          childrenValue = List.generate(children!.length, (index) => false);

          print("trip id list: $tripIdList");
          print("children: ${children}");
          print("dateTimeList: $dateTimeList");
        } else{
          setState(() {
            isTripIdListLoading = false;
          });
        }
      }
      );
    }catch(e){
      print("issue while getting trip list data: $e");
    }
  }

  getVesselAndTripsData()async{
    try{
      commonProvider
          .getUserConfigData(context, commonProvider.loginModel!.userId!,
          commonProvider.loginModel!.token!, scaffoldKey).then((value){
         if(value != null){
           setState(() {
             isVesselDataLoading = true;
           });
           print("value of get user config by id: ${value.vessels}");
           vesselData = List<DropdownItem>.from(value.vessels!.map((vessel) => DropdownItem(id: vessel.id,name: vessel.name)));

        //   tripData = List<DropdownItem>.from(value.trips!.map((trip) => DropdownItem(id: )));

           print("vesselData: ${vesselData.length}");
         } else{
           setState(() {
             isVesselDataLoading = false;
           });
         }
      }).catchError((e){
        setState(() {
          isVesselDataLoading = false;
        });
      });
    }catch(e){
      setState(() {
        isVesselDataLoading = false;
      });
      print("Error while fetching data from getUserConfigById: $e");
    }
  }

  void _collapseExpansionTile() {
    setState(() {
      isExpansionCollapse = true;
    });
  }

  String tripDate(String date){
    String inputDate = date;
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
  }


  getReportsData(String caseType,{DateTime? startDate,DateTime? endDate,String? vesselID,List<String>? selectedTripListID}) async {
    try{
      await commonProvider.getReportData(startDate! ?? DateTime(0),endDate! ?? DateTime(0),caseType,vesselID,commonProvider.loginModel!.token!,selectedTripListID!, context, scaffoldKey).then((value) {
        setState(() {
          isReportDataLoading = true;
        });
        if(value != null){
          print("value is: $value");
          avgSpeed = value.data!.avgInfo!.avgSpeed;
          avgDuration = durationWithMilli(value.data!.avgInfo!.avgDuration);
          avgFuelConsumption = value.data!.avgInfo!.avgFuelConsumption;
          avgPower = value.data!.avgInfo!.avgPower!.toInt();
          print("avgPower : $avgPower");
          triSpeedList =  List<TripModel>.from(value.data!.trips!.map((tripData) => TripModel(date: tripData.date, tripsByDate: tripData.tripsByDate)));

          tripList = value.data!.trips!
              .map((trip) => {
            'date': trip.date!,
            'tripDetails': trip.tripsByDate![0].id,
            'duration': trip.tripsByDate![0].duration,
            'avgSpeed': '${trip.tripsByDate![0].avgSpeed} nm',
            'fuelUsage': trip.tripsByDate![0].fuelConsumption ?? "0",
            'powerUsage': trip.tripsByDate![0].avgPower ?? "0"
          })
              .toList();
          print("tripList: $tripList");

          int duration1 = durationWithMilli(value.data!.avgInfo!.avgDuration);
          String avgSpeed1 = value.data!.avgInfo!.avgSpeed!.toStringAsFixed(1) + " nm";
          String fuelUsage = value.data!.avgInfo!.avgFuelConsumption!.toStringAsFixed(2) + " g";
          String powerUsage = value.data!.avgInfo!.avgPower!.toStringAsFixed(2) + " w";

          print("duration: $duration,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage  ");

           finalData = [
            {
              'date': '',
              'tripDetails': 'Total',
              'duration': "$duration1",
              'avgSpeed': avgSpeed1,
              'fuelUsage': fuelUsage,
              'powerUsage': powerUsage
            },
            {
              'date': '',
              'tripDetails': 'Average',
              'duration': "$duration1",
              'avgSpeed': avgSpeed1,
              'fuelUsage': fuelUsage,
              'powerUsage': powerUsage
            }
          ];

          print("finalData: $finalData");


        } else{
          setState(() {
            isReportDataLoading = false;
          });
        }
      });
    }catch(e){
      print("Error while getting data from report api : $e");
    }
/*
    var response = await rootBundle.loadString('assets/reports/reports.json');
    reportModel = ReportModel.fromJson(json.decode(response));
    avgSpeed = reportModel!.data.avgInfo.avgSpeed;
    avgDuration = durationWithMilli(reportModel!.data.avgInfo.avgDuration);
    avgFuelConsumption = reportModel!.data.avgInfo.avgFuelConsumption;

    triSpeedList = await List<Trip>.from(reportModel!.data.trips.map((speed) => Trip(date: speed.date, tripsByDate: speed.tripsByDate)));
  */
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    seconds = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  dynamic duration(String duration) {
    String timeString = duration;
    List<String> parts = timeString.split(':');
    DateTime dateTime = DateTime(
        0,
        0,
        0,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(
          parts[2],
        ));
    int totalMinutes = dateTime.hour * 60 + dateTime.minute;
    print(totalMinutes);
    return totalMinutes;
  }

  dynamic durationWithMilli(String timeString) {
    String time = timeString;
    Duration duration = Duration(
      hours: int.parse(time.split(':')[0]),
      minutes: int.parse(timeString.split(':')[1]),
      seconds: int.parse(timeString.split(':')[2].split('.')[0]),
      milliseconds: int.parse(timeString.split(':')[2].split('.')[1]),
    );
    int durationInMinutes = duration.inMinutes;
    return durationInMinutes;
  }

  DropdownItem? selectedValue;

  @override
  void initState() {
    super.initState();
    commonProvider = context.read<CommonProvider>();
    parentValue = false;
    //commonProvider = Provider.of<CommonProvider>(context,listen: false);
    Future.delayed(Duration.zero, () {
      getVesselAndTripsData();
    });

   // getReportsData();

    tripDurationButtonColor = true;

   // dateTimeList = ["23-Jan-2023", "24-Jan-2023", "25-Jan-2023", "26-Jan-2023"];


   /* WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        selectedButton = 'trip duration';
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: reportBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: displayWidth(context) * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8, left: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 28,
                                ),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              SizedBox(
                                width: displayWidth(context) * 0.03,
                              ),
                              Text(
                                "Reports",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: inter),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                    ModalRoute.withName(""));
                              },
                              icon: Image.asset('assets/images/home.png'),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding:  EdgeInsets.only(left: displayWidth(context) * 0.05,
                          right: displayWidth(context) * 0.05),
                      child: ExpansionTile(
                        onExpansionChanged: (isExpanded){
                          setState(() {
                            print("isExpansionCollapse : $isExpanded");
                            isExpansionCollapse = isExpanded;
                          });
                        },
                        collapsedBackgroundColor: dateBackgroundColor,
                        title: Text(
                          "Search & Filters",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              fontFamily: inter),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                        children: [
                          isVesselDataLoading! ?  Padding(
                            padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: displayWidth(context) * 0.025),
                            child: Container(
                              // margin: EdgeInsets.only(bottom: displayHeight(context) * 0.005),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  focusColor: dropDownBackgroundColor,
                                  fillColor: dropDownBackgroundColor,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(3),
                                  focusedBorder:  OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide:
                                    BorderSide(width: 1, color: Colors.transparent),
                                  ),
                                  enabledBorder:  OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    borderSide:
                                    BorderSide(width: 1, color: Colors.transparent),
                                  ),
                                  errorBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(width: 1, color: Colors.red),
                                  ),
                                  errorStyle: TextStyle(
                                      fontFamily: "", fontSize: displayWidth(context) * 0.025),
                                  focusedErrorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(width: 1, color: Colors.red),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 13, right: displayWidth(context) * 0.45),
                                  child: DropdownButtonFormField<DropdownItem>(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    dropdownColor:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? "Select Vessel" == 'User SubRole'
                                        ? Colors.white
                                        : Colors.transparent
                                        : Colors.white,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: "Select Vessel*",
                                      hintStyle: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? "Select Vessel" == 'User SubRole'
                                              ? Colors.black
                                              : Colors.white
                                              : Colors.black,
                                          fontSize: displayWidth(context) * 0.034,
                                          fontFamily: inter,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    isExpanded: true,
                                    isDense: true,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Select Vessel';
                                      }
                                      return null;
                                    },
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? "Select Vessel" == 'User SubRole'
                                            ? Colors.black
                                            : Colors.white
                                            : Colors.black),
                                    value: selectedValue,
                                    // value: selectState,
                                    items: vesselData.map((item) {
                                      return DropdownMenuItem<DropdownItem>(
                                        value: item,
                                        child: Text(
                                          item.name!,
                                          style: TextStyle(
                                              fontSize: displayWidth(context) * 0.0346,
                                              color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                                  ? "Select Vessel" == 'User SubRole'
                                                  ? Colors.black
                                                  : Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (item) {
                                      print("id is: ${item?.id} ");
                                      selectedVessel = item!.id;
                                      getTripListData(item.id!);

                                      // state.didChange(item);
                                      // onChanged!(item);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ) : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  circularProgressColor),
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: Text(
                                    "Filter By Date",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: 1,
                                  groupValue: _selectedOption,
                                  onChanged: (int? value) {
                                    setState(() {
                                      selectedCaseType = "1";
                                      print("selectedCaseType: $selectedCaseType ");
                                      _selectedOption = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: Text("Filter By Trip",
                                      style: TextStyle(fontSize: 14)),
                                  value: 2,
                                  groupValue: _selectedOption,
                                  onChanged: (int? value) {
                                    setState(() {
                                      selectedCaseType = "2";
                                      print("selectedCaseType: $selectedCaseType ");
                                      _selectedOption = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          _selectedOption == 1
                              ? filterByDate(context)!
                              : filterByTrip(context)!,
                          SizedBox(
                            height: displayWidth(context) * 0.08,
                          ),
                          CommonButtons.getAcceptButton(
                              "Search", context, primaryColor, () {
                            _collapseExpansionTile();
                          DateTime startDate = startDateAndEndDateConvert(focusedDay.toString());
                          DateTime endDate =  startDateAndEndDateConvert(lastDayFocused.toString());

                            //getReportsData(selectedVessel,selectedTripIdList!);
                            // Navigator.of(context).pop();
                                if(selectedCaseType == "1"){
                                  getReportsData(selectedCaseType!,startDate: startDate,endDate: endDate,vesselID: selectedVessel);
                                }else if(selectedCaseType == "2"){
                                  getReportsData(selectedCaseType!,selectedTripListID: selectedTripIdList);
                                }

                          },
                              displayWidth(context) * 0.8,
                              displayHeight(context) * 0.065,
                              Colors.grey.shade400,
                              Theme.of(context).brightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.white,
                              displayHeight(context) * 0.021,
                              buttonBGColor,
                              '',
                              fontWeight: FontWeight.w500),
                          SizedBox(
                            height: displayWidth(context) * 0.1,
                          )
                        ],
                      ),
                    ),

                    isReportDataLoading! ?  Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: displayWidth(context) * 0.05,
                              right: displayWidth(context) * 0.05,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: displayWidth(context) * 0.07,
                                ),
                                Text(
                                  "Sea Cucumber",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: inter),
                                ),
                                SizedBox(
                                  height: displayWidth(context) * 0.04,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Selected Trips",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: inter),
                                    ),
                                    SizedBox(
                                      width: displayWidth(context) * 0.05,
                                    ),
                                    Text(
                                      ":  Trip A, Trip B, Trip C",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: inter),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: displayWidth(context) * 0.06,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedButton = 'trip duration';
                                          tripDurationButtonColor = true;
                                          avgSpeedButtonColor = false;
                                          fuelUsageButtonColor = false;
                                          powerUsageButtonColor = false;
                                        });
                                      },
                                      child: Container(
                                        //  color: dateBackgroundColor,
                                        width: displayWidth(context) * 0.21,
                                        height: displayWidth(context) * 0.09,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: !tripDurationButtonColor! ? reportTabColor : Colors.blue),
                                        child: Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Center(
                                            child: Text(
                                              "Trip Duration",
                                              style: TextStyle(
                                                  color: tripDurationButtonColor! ? Colors.white : Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedButton = 'avg speed';
                                          tripDurationButtonColor = false;
                                          avgSpeedButtonColor = true;
                                          fuelUsageButtonColor = false;
                                          powerUsageButtonColor = false;
                                        });
                                      },
                                      child: Container(
                                        //  color: dateBackgroundColor,
                                        width: displayWidth(context) * 0.19,
                                        height: displayWidth(context) * 0.09,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: !avgSpeedButtonColor! ? reportTabColor : Colors.blue),
                                        child: Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Center(
                                            child: Text(
                                              "Avg Speed",
                                              style: TextStyle(
                                                  color: avgSpeedButtonColor! ? Colors.white : Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedButton = 'fuel usage';
                                          tripDurationButtonColor = false;
                                          avgSpeedButtonColor = false;
                                          fuelUsageButtonColor = true;
                                          powerUsageButtonColor = false;
                                        });
                                      },
                                      child: Container(
                                        //  color: dateBackgroundColor,
                                        width: displayWidth(context) * 0.20,
                                        height: displayWidth(context) * 0.09,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: !fuelUsageButtonColor! ? reportTabColor : Colors.blue),
                                        child: Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Center(
                                            child: Text(
                                              "Fuel Usage",
                                              style: TextStyle(
                                                  color: fuelUsageButtonColor! ? Colors.white : Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedButton = 'power usage';
                                          tripDurationButtonColor = false;
                                          avgSpeedButtonColor = false;
                                          fuelUsageButtonColor = false;
                                          powerUsageButtonColor = true;

                                        });
                                      },
                                      child: Container(
                                        //  color: dateBackgroundColor,
                                        width: displayWidth(context) * 0.22,
                                        height: displayWidth(context) * 0.09,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: !powerUsageButtonColor! ? reportTabColor : Colors.blue),
                                        child: Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Center(
                                            child: Text(
                                              "Power Usage",
                                              style: TextStyle(
                                                  color: powerUsageButtonColor! ? Colors.white : Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: displayWidth(context) * 0.02,
                                ),
                              ],
                            ),
                          ),
                          isReportDataLoading! ?  buildGraph(context) : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  circularProgressColor),
                            ),
                          ),

                          // tripDurationGraph(context)!,
                          //avgSpeedGraph(context)!,
                          // fuelUsageGraph(context)!,
                          // powerUsageGraph(context)!,

                          Padding(
                            padding: EdgeInsets.only(right: 20, left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                tripWithColor(backgroundColor, 'Trip A Name'),
                                tripWithColor(circularProgressColor, 'Trip B Name'),
                                tripWithColor(tripColumnBarColor, 'Trip C Name'),
                              ],
                            ),
                          ),

                          table(context)!,

                          SizedBox(
                            height: displayWidth(context) * 0.08,
                          ),
                        ],
                      ) : Container(),


                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget tripWithColor(Color rangeColor, String rangeText) {
    return Row(
      children: [
        Container(
          height: 13,
          width: 13,
          color: rangeColor,
        ),
        SizedBox(
          width: 5,
        ),
        commonText(
            text: rangeText,
            context: context,
            textSize: displayWidth(context) * 0.025,
            textColor: Colors.black,
            fontWeight: FontWeight.w600)
      ],
    );
  }

  Widget? table(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: DataTable(
          columnSpacing: 25,
          dividerThickness: 1,
          columns: [
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(color: tableHeaderColor),
              ),
            ),
            DataColumn(
                label: Text('Trip Details',
                    style: TextStyle(color: tableHeaderColor))),
            DataColumn(
                label: Text('Duration',
                    style: TextStyle(color: tableHeaderColor))),
            DataColumn(
                label: Text('Avg Speed',
                    style: TextStyle(color: tableHeaderColor))),
            DataColumn(
                label: Text('Fuel Usage',
                    style: TextStyle(color: tableHeaderColor))),
            DataColumn(
                label: Text('Power Usage',
                    style: TextStyle(color: tableHeaderColor))),
          ],
          rows: [
            ...tripList.map((person) => DataRow(cells: [
                  DataCell(Text(person['date']!)),
                  DataCell(Text(person['tripDetails']!)),
                  DataCell(Text(person['duration']!)),
                  DataCell(Text(person['avgSpeed']!)),
                  DataCell(Text(person['fuelUsage']!)),
                  DataCell(Text(person['powerUsage']!)),
                ])),
            ...finalData.map((e) => DataRow(cells: [
                  DataCell(
                    Text(
                      e['date']!,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  DataCell(Text(
                    e['tripDetails']!,
                    style: TextStyle(color: Colors.blue),
                  )),
                  DataCell(Text(
                    e['duration']!,
                    style: TextStyle(color: Colors.blue),
                  )),
                  DataCell(Text(e['avgSpeed']!,
                      style: TextStyle(color: Colors.blue))),
                  DataCell(Text(e['fuelUsage']!,
                      style: TextStyle(color: Colors.blue))),
                  DataCell(Text(e['powerUsage']!,
                      style: TextStyle(color: Colors.blue))),
                ]))
          ],
        ),
      ),
    );
  }

  buildGraph(BuildContext context) {
    debugPrint('SELECTED BUTTON Text $selectedButton');

    switch (selectedButton.toLowerCase()) {
      case 'trip duration':
        return tripDurationGraph(context);
      case 'avg speed':
        return avgSpeedGraph(context);
      case 'fuel usage':
        return fuelUsageGraph(context);
      case 'power usage':
        return powerUsageGraph(context);
      default:
        return Container();
    }
  }

  Widget tripDurationGraph(BuildContext context) {
    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<TripModel, String>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) =>
            duration(tripData.tripsByDate![0].duration.toString()),
        name: 'Duration',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      ColumnSeries<TripModel, String>(
        color: tripColumnBarColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) => tripData.tripsByDate!.length > 1
            ? duration(tripData.tripsByDate![0].duration.toString())
            : null,
        name: 'Duration',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
    ];

    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      borderWidth: 1,
      //activationMode: ActivationMode.singleTap,
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex,
          int pointIndex) {
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.all(Radius.circular(40)),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            color: Colors.black,
          ),
          padding: EdgeInsets.all(9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text("${duration(data.tripsByDate[pointIndex].duration)}",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )),
                  Text(' min',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
     // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 1.3,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          //tooltipBehavior: CustomTooltipBehavior(),
          tooltipBehavior: tooltipBehavior,
          enableSideBySideSeriesPlacement: true,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
              interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(text: 'Minutes'),
              majorTickLines: MajorTickLines(width: 0),
              minorTickLines: MinorTickLines(width: 0),
              labelStyle: TextStyle(color: Colors.grey),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgDuration}min',
                    isVisible: true,
                    start: avgDuration,
                    end: avgDuration,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start),
              ]),
          series: columnSeriesData,
        ),
      ),
    );
  }

  Widget avgSpeedGraph(BuildContext context) {
    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<TripModel, dynamic>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) => tripData.tripsByDate![0].avgSpeed,
        name: 'Avg Speed',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      ColumnSeries<TripModel, dynamic>(
        color: tripColumnBarColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) => tripData.tripsByDate!.length > 1
            ? tripData.tripsByDate![1].avgSpeed
            : null,
        name: 'Avg Speed',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      /*  ColumnSeries<Trip,dynamic>(
        color: tripColumnBarColor,
        dataSource: triSpeedList,
        xValueMapper: (Trip tripData, _) => tripData.date ?? "",
        yValueMapper: (Trip tripData, _) => tripData.tripsByDate.length > 1 ? tripData.tripsByDate[1].avgSpeed : tripData.tripsByDate[1].avgSpeed,
        name: 'Latitude',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.1,
      ) */
      // ColumnSeries<TripData, String>(
      //   color: tripColumnBarColor,
      //   dataSource: tripDataList,
      //   xValueMapper: (TripData tripData, _) => tripData.date,
      //   yValueMapper: (TripData tripData, _) => double.parse(tripData.startPosition[0]),
      //   name: 'Longitude',
      // ),
    ];

    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      header: '',
      format: 'point.y %',
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex,
          int pointIndex) {
        print("data is: ${data.tripsByDate[pointIndex].avgSpeed}");
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            color: Colors.black,
          ),
          padding: EdgeInsets.all(9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text('${data.tripsByDate[pointIndex].avgSpeed}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )),
                  Text('NM',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      //physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 1.3,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
              interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(text: 'Notical Miles'),
              plotBands: <PlotBand>[
                PlotBand(
                    text: 'avg ${avgSpeed}NM',
                    isVisible: true,
                    start: avgSpeed,
                    end: avgSpeed,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black, fontSize: 12),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start,
                ),
              ]),
          series: columnSeriesData,
        ),
      ),
    );
  }

  Widget fuelUsageGraph(BuildContext context) {
    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<TripModel, String>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) =>
            tripData.tripsByDate![0].fuelConsumption,
        name: 'Fuel Usage',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      ColumnSeries<TripModel, String>(
        color: tripColumnBarColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) => tripData.tripsByDate!.length > 1
            ? tripData.tripsByDate![1].fuelConsumption
            : null,
        name: 'Fuel Usage',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      /* ColumnSeries<TripData, String>(
        color: tripColumnBarColor,
        dataSource: tripDataList,
        xValueMapper: (TripData tripData, _) => tripData.date,
        yValueMapper: (TripData tripData, _) => double.parse(tripData.startPosition[0]),
        name: 'Longitude',
      ), */
    ];

    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex,
          int pointIndex) {
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            color: Colors.black,
          ),
          padding: EdgeInsets.all(9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text('${data.tripsByDate[pointIndex].fuelConsumption}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )),
                  Text('Gal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
     // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 1.3,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
              labelFormat: '{value} gal',
              interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(text: 'Galance'),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgFuelConsumption}gal',
                    isVisible: true,
                    start: avgFuelConsumption,
                    end: avgFuelConsumption,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start),
              ]),
          series: columnSeriesData,
        ),
      ),
    );
  }

  Widget powerUsageGraph(BuildContext context) {
    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<TripModel, String>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) => tripData.tripsByDate![0].avgPower,
        name: 'Power Usage',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      ColumnSeries<TripModel, String>(
        color: tripColumnBarColor,
        dataSource: triSpeedList,
        xValueMapper: (TripModel tripData, _) => tripData.date,
        yValueMapper: (TripModel tripData, _) => tripData.tripsByDate!.length > 1
            ? tripData.tripsByDate![1].avgPower
            : null,
        name: 'Power Usage',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.4,
      ),
      /* ColumnSeries<TripData, String>(
        color: tripColumnBarColor,
        dataSource: tripDataList,
        xValueMapper: (TripData tripData, _) => tripData.date,
        yValueMapper: (TripData tripData, _) => double.parse(tripData.startPosition[0]),
        name: 'Longitude',
      ), */
    ];

    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex,
          int pointIndex) {
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            color: Colors.black,
          ),
          padding: EdgeInsets.all(9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text('${data.tripsByDate[pointIndex].avgPower}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )),
                  Text('Watts',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
     // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 1.3,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
              interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(text: 'Wats'),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgPower}W',
                    isVisible: true,
                    start: avgPower,
                    end: avgPower,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start),
              ]),
          series: columnSeriesData,
        ),
      ),
    );
  }

  Widget? filterByDate(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isStartDate = true;
                  selectDateOption = 1;
                });
              },
              child: Container(
                //  color: dateBackgroundColor,
                width: displayWidth(context) * 0.3,
                height: displayWidth(context) * 0.14,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: dateBackgroundColor),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Center(
                    child: Text(
                      "Start Date",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEndDate = true;
                  selectDateOption = 2;
                });
              },
              child: Container(
                //  color: dateBackgroundColor,
                width: displayWidth(context) * 0.3,
                height: displayWidth(context) * 0.14,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: dateBackgroundColor),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Center(
                    child: Text(
                      "End Date",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: displayWidth(context) * 0.08,
        ),
    selectDateOption == 1
            ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: displayWidth(context) * 0.045,
                        right: displayWidth(context) * 0.045),
                    child: Container(
                      width: displayWidth(context),
                      height: 50,
                      decoration: BoxDecoration(
                          color: selectDayBackgroundColor,
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
                            top: displayWidth(context) * 0.05),
                        child: Text(
                          "Select Day",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: displayWidth(context) * 0.045,
                        right: displayWidth(context) * 0.045),
                    child: TableCalendar(
                      daysOfWeekVisible: true,
                      focusedDay: selectedDate,
                      firstDay: firstDate,
                      lastDay: lastDate,
                      onFormatChanged: (CalendarFormat _format) {},
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, events) => Container(
                            margin: const EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          isTodayHighlighted: true,
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              color: Colors.pink),
                          todayTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              color: Colors.white)),
                      selectedDayPredicate: (DateTime date) {
                        return isSameDay(selectedDate, date);
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (DateTime? selectDay, DateTime? focusDay) {
                        setState(() {
                          selectedDate = selectDay!;
                          focusedDay = focusDay!;
                        });
                        print(focusDay);
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        formatButtonDecoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        formatButtonTextStyle: TextStyle(color: Colors.white),
                        formatButtonShowsNext: false,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: displayWidth(context) * 0.045,
              right: displayWidth(context) * 0.045),
          child: Container(
            width: displayWidth(context),
            height: 50,
            decoration: BoxDecoration(
                color: selectDayBackgroundColor,
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
                  top: displayWidth(context) * 0.05),
              child: Text(
                "Select Day",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: displayWidth(context) * 0.045,
              right: displayWidth(context) * 0.045),
          child: TableCalendar(
            daysOfWeekVisible: true,
            focusedDay: selectedDate,
            firstDay: firstDate,
            lastDay: lastDate,
            onFormatChanged: (CalendarFormat _format) {},
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.pink),
                todayTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.white)),
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDate, date);
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (DateTime? selectDay, DateTime? focusDay) {
              setState(() {
                selectedDate = selectDay!;
                lastDayFocused= focusDay!;
              });
              print(lastDayFocused);
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(22.0),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
          ),
        ),
      ],
    ),
      ],
    );
  }

  Widget? filterByTrip(BuildContext context) {
    return isTripIdListLoading! ? Column(
      children: [
        ListView(
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: displayWidth(context) * 0.046),
              child: CustomLabeledCheckbox(
                label: 'Select All',
                value: parentValue != null ? parentValue! : false,
                onChanged: (value) {
                  if (value != null) {
                    // Checked/Unchecked
                    selectedTripIdList = tripIdList;
                    _checkAll(value);
                  } else {
                    // Tristate
                    _checkAll(true);
                  }
                },
                checkboxType: CheckboxType.Parent,
                activeColor: Colors.indigo,
              ),
            ),
            ListView.builder(
              itemCount: children!.length ?? 0,
              itemBuilder: (context, index) => Column(
                children: [
                  Divider(),
                  CustomLabeledCheckboxOne(
                    label: children![index],
                    value: childrenValue![index],
                    tripId: tripIdList![index],
                    dateTime: dateTimeList![index],
                    onChanged: (value) {
                      print("trip list id: ${tripIdList![index]}");
                      if(!selectedTripIdList!.contains(tripIdList![index])){
                        selectedTripIdList!.add(tripIdList![index]);
                      }else{
                        selectedTripIdList!.remove(tripIdList![index]);
                      }
                      manageTristate(index, value);
                    },
                    checkboxType: CheckboxType.Child,
                    activeColor: Colors.indigo,
                  ),
                ],
              ),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
            ),
          ],
        )
      ],
    ) : Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            circularProgressColor),
      ),
    );
  }
}

class TripData {
  final String date;
  final List<dynamic> startPosition;

  TripData({required this.date, required this.startPosition});
}

class TripSpeed {
  final String date;
  final List<TripsByDate> speed;

  TripSpeed({required this.date, required this.speed});
}

class CustomTooltipBehavior extends TooltipBehavior {
  CustomTooltipBehavior({
    double duration = 3500,
    TooltipPosition tooltipPosition = TooltipPosition.pointer,
  }) : super(
          enable: true,
          duration: duration,
          tooltipPosition: tooltipPosition,
        );

  @override
  Widget buildContent(BuildContext context, dynamic data) {
    return Container(
      decoration: BoxDecoration(
        //color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      child: Text(
        '${data.x} : ${data.y}',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
}

class DropdownItem {
  final String? id;
  final String? name;

  DropdownItem({this.id, this.name});
}
