import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
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
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_drop_down_one.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
import '../../models/reports_model.dart';
import '../../provider/common_provider.dart';
import '../home_page.dart';
import 'package:table_calendar/table_calendar.dart';

import '../trip_analytics.dart';

class SearchAndFilters extends StatefulWidget {
  const SearchAndFilters({Key? key}) : super(key: key);

  @override
  State<SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<SearchAndFilters> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  String foos = 'One';
  int? _key;
  int? newKey;
  DateTime now = DateTime.now();
  late CommonProvider commonProvider;
  bool? isSHowGraph = false;
  bool? isExpansionCollapse = false;
  String? selectedVessel;
  String? selectedVesselName = "";
  String? selectedTrip;
  int _selectedOption = 1;
  DateTime selectedDateForStartDate = DateTime.now();
  DateTime selectedDateForEndDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String? focusedDayString = "";
  DateTime firstDate = DateTime(1980);
  DateTime lastDate = DateTime.now();
  List<String> items = ["Start Date", "End Date"];
  DateTime lastDayFocused = DateTime.now();
  String? lastFocusedDayString = "";
  bool? isSelectedStartDay = false;
  bool? isSelectedEndDay = false;

  bool? parentValue = false;
  List<String>? children = [];
  List<bool>? childrenValue = [];
  List<String>? tripIdList = [];
  List<String>? dateTimeList = [];
  List<String>? selectedTripLabelList = [];
  bool? isStartDate = false;
  bool? isEndDate = false;
  bool? isBtnClick = false;

  //CalendarFormat format = CalendarFormat.month;

  String selectedButton = 'trip duration';
  int? selectedCaseType = 1;
  int? selectDateOption;

  final List<Map<String, dynamic>> finalChartData = [];

  List<Map<String, dynamic>> tripList = [];

  List<Map<String, dynamic>> tripAvgList = [];

  List<TripData> tripDataList = [];
  List<TripModel> triSpeedList = [];
  List<TripModel> jsonTripData = [];
  ReportModel? reportModel;
  double? avgSpeed = 0.0;
  dynamic avgDuration = 0;
  dynamic avgTotalDuration = 0;
  dynamic avgFuelConsumption;
  dynamic avgPower = 0.0;

  dynamic totalDuration = 0;
  dynamic totalSpeed;
  dynamic totalFuelConsumption;
  dynamic totalAvgPower;

  bool? tripDurationButtonColor = false;
  bool? avgSpeedButtonColor = false;
  bool? fuelUsageButtonColor = false;
  bool? powerUsageButtonColor = false;

  bool? isReportDataLoading = false;
  bool? isCheckInternalServer = false;

  List<Map<String, dynamic>> finalData = [];
  List<Map<String, dynamic>> totalData = [];

  List<Vessels> vesselList = [];
  List<DropdownItem> vesselData = [];

  List<DropdownItem> tripData = [];

  bool? isVesselDataLoading = true;

  List<String>? selectedTripIdList = [];

  bool? isTripIdListLoading = true;

  bool isExpandedTile = false;

  final List<ChartSeries> durationColumnSeriesData = [];
  final List<ChartSeries> avgSpeedColumnSeriesData = [];
  final List<ChartSeries> fuelUsageColumnSeriesData = [];
  final List<ChartSeries> powerUsageColumnSeriesData = [];

  final List<Color> barsColor = [
    circularProgressColor,
    tripColumnBarColor,
    tripColumnBar1Color,
    primaryColor,
    Colors.orange,
    bluetoothDeviceInActiveColor,
    Colors.tealAccent,
    letsGetStartedButtonColor,
    circularProgressColor,
    tripColumnBarColor,
    tripColumnBar1Color,
  ];

  DropdownItem? selectedValue;
  bool isSelectStartDate = false;
  bool isSelectEndDate = false;
  String? selectedTripsAndDateString = "";
  String? selectedTripsAndDateDetails = "";

  String selectedIndex = "";

  String convertIntoYearMonthDay(DateTime date) {
    // String dateTimeString = date;
    // DateTime dateTime = DateTime.parse(dateTimeString);
    // String dateString = dateTime.toString().split(' ')[0];

    String dateString = DateFormat('yyyy-MM-dd').format(date);
    print(dateString);
    return dateString;
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

  // _collapse(int _key, int newKey) {
  //   do {
  //     _key = new Random().nextInt(100);
  //   } while(newKey == _key);
  // }

  void _checkAll(bool value) {
    setState(() {
      parentValue = value;

      for (int i = 0; i < children!.length; i++) {
        childrenValue![i] = value;
      }
    });
  }

  getTripListData(String vesselID) async {
    try {
      commonProvider
          .tripListData(
              vesselID, context, commonProvider.loginModel!.token!, scaffoldKey)
          .then((value) {
        if (value != null) {
          setState(() {
            isTripIdListLoading = false;
          });
          print("value of trip list: ${value.data}");
          //debugger();
          tripIdList!.clear();
          dateTimeList!.clear();
          for (int i = 0; i < value.data!.length; i++) {
            tripIdList!.add(value.data![i].id!);
            dateTimeList!.add(value.data![i].createdAt != null &&
                    value.data![i].createdAt!.isNotEmpty
                ? tripDate(value.data![i].createdAt!)
                : "");
            children!.add("Trip ${i.toString()}");
          }
          // selectedTripsAndDateDetails = children!.join(", ");
          childrenValue = List.generate(children!.length, (index) => false);

          print("trip id list: $tripIdList");
          print("children: ${children}");
          print("dateTimeList: $dateTimeList");
        } else {
          setState(() {
            isTripIdListLoading = false;
          });
        }
      }).catchError((e) {
        setState(() {
          isTripIdListLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isTripIdListLoading = false;
      });
      print("issue while getting trip list data: $e");
    }
  }

  getVesselAndTripsData() async {
    try {
      bool check = await Utils().check(scaffoldKey);
      if (check) {
        commonProvider.getUserConfigData(
            context,
            commonProvider.loginModel!.userId!,
            commonProvider.loginModel!.token!,
            scaffoldKey, () {
          //commonProvider.updateConnectionCloseStatus(true);
          setState(() {
            isVesselDataLoading = false;
          });
        }).then((value) {
          if (value != null) {
            //commonProvider.updateConnectionCloseStatus(true);
            setState(() {
              isVesselDataLoading = false;
            });
            print("value of get user config by id: ${value.vessels}");
            vesselData = List<DropdownItem>.from(value.vessels!.map(
                (vessel) => DropdownItem(id: vessel.id, name: vessel.name)));
            //   tripData = List<DropdownItem>.from(value.trips!.map((trip) => DropdownItem(id: )));
            print("vesselData: ${vesselData.length}");
          } else {
            //commonProvider.updateConnectionCloseStatus(false);
            setState(() {
              isVesselDataLoading = false;
            });
          }
        }).catchError((e) {
          //commonProvider.updateConnectionCloseStatus(false);
          setState(() {
            isVesselDataLoading = false;
          });
        });
      } else {
        //commonProvider.updateConnectionCloseStatus(true);
        setState(() {
          isVesselDataLoading = false;
        });
      }
    } catch (e) {
      // commonProvider.updateConnectionCloseStatus(false);
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

  collapseExpansionTileKey() {
    do {
      _key = new Random().nextInt(100);
    } while (newKey == _key);
  }

  String tripDate(String date) {
    String inputDate = date;
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
  }

  List<TripModel> durationGraphData = [];

  updateTripId(String? selectedIndx) {
    setState(() {
      selectedIndex = selectedIndx!;
    });
  }

  dynamic duration1;
  double? avgSpeed1 = 0.0;
  double? fuelUsage = 0.0;
  double? powerUsage = 0.0;

  getReportsData(int caseType,
      {String? startDate,
      String? endDate,
      String? vesselID,
      List<String>? selectedTripListID}) async {
    try {
      await commonProvider
          .getReportData(
              startDate ?? "",
              endDate ?? "",
              caseType,
              vesselID,
              commonProvider.loginModel!.token!,
              selectedTripListID ?? [],
              context,
              scaffoldKey)
          .then((value) {
        if (value != null) {
          if (value.message == "Internal Server Error") {
            setState(() {
              isCheckInternalServer = true;
              isBtnClick = false;
              // triSpeedList.clear();
              totalData.clear();
              finalData.clear();
              finalChartData.clear();
            });
// <<<<<<< Report-code-merge
          } else if (!isCheckInternalServer! && value.statusCode == 200) {
            if (mounted) {
              setState(() {
                isReportDataLoading = true;
                isBtnClick = false;
                triSpeedList.clear();
                /*totalData.clear();
              finalData.clear();
              finalChartData.clear();*/

                avgSpeed = null;
                avgDuration = null;
                avgFuelConsumption = null;
                avgPower = null;
                triSpeedList.clear();
                tripList.clear();
                duration1 = null;
                avgSpeed1 = null;
                fuelUsage = null;
                powerUsage = null;
                finalData.clear();
                durationGraphData.clear();

                durationColumnSeriesData.clear();
                avgSpeedColumnSeriesData.clear();
                fuelUsageColumnSeriesData.clear();
                powerUsageColumnSeriesData.clear();
              });
            }

            collapseExpansionTileKey();
            isSHowGraph = true;
            avgSpeed = double.parse(
                value.data?.avgInfo?.avgSpeed?.toStringAsFixed(2) ?? '0');
            var myAvgDuration =
                (value.data?.avgInfo?.avgDuration ?? '').contains(".")
                    ? durationWithMilli2(
                        value.data?.avgInfo?.avgDuration ?? '0:0:0.0')
                    : duration(value.data!.avgInfo!.avgDuration ?? '0:0:0');
            avgDuration = myAvgDuration ?? 0;

            avgFuelConsumption = value.data?.avgInfo?.avgFuelConsumption;
            avgPower = value.data?.avgInfo?.avgPower ?? 0.0;
            print(
                "duration: $avgDuration, avgPower : $avgPower, avgFuelConsumption: $avgFuelConsumption, avgSpeed: $avgSpeed");
            triSpeedList = List<TripModel>.from(value.data!.trips!.map(
                (tripData) => TripModel(
                    date: tripData.date, tripsByDate: tripData.tripsByDate)));

            durationGraphData = triSpeedList;
            Utils.customPrint('list total data : ${durationGraphData}');

            for (int i = 0; i < durationGraphData.length; i++) {
              for (int j = 0;
                  j < durationGraphData[i].tripsByDate!.length;
                  j++) {
                print(
                    "trip duration data is: ${durationGraphData[i].tripsByDate![j].id}");
// =======
//           } else if(!isCheckInternalServer! && value.statusCode == 200){
//             setState(() {
//               isReportDataLoading = true;
//               triSpeedList.clear();
//             });
//             avgSpeed = value.data!.avgInfo!.avgSpeed;
//             avgDuration = durationWithMilli(value.data!.avgInfo!.avgDuration!);
//             avgFuelConsumption = value.data!.avgInfo!.avgFuelConsumption;
//             avgPower = value.data!.avgInfo!.avgPower ?? 0.0;
//             print("avgPower : $avgPower");
//             triSpeedList =  List<TripModel>.from(value.data!.trips!.map((tripData) => TripModel(date: tripData.date, tripsByDate: tripData.tripsByDate)));

//             for(int i=0; i< triSpeedList.length; i++){
//               for(int j=0; j < triSpeedList[i].tripsByDate!.length; j++){
//                 print("trip duration data is: ${triSpeedList[i].tripsByDate![j].id}");
// >>>>>>> Bug_loc_reports
                if (duration(triSpeedList[i].tripsByDate![j].duration!) > 0) {
                  durationColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    // color: barsColor[i],
                    // pointColorMapper: barsColor,
                    //width: 0.9,

                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        duration(triSpeedList[i].tripsByDate![j].duration!) > 0
                            ? triSpeedList[i].date
                            : null,
                    yValueMapper: (TripModel tripData, _) =>
                        duration(triSpeedList[i].tripsByDate![j].duration!) > 0
                            ? duration(
                                triSpeedList[i].tripsByDate![j].duration!)
                            : null,
                    /* onPointTap: (ChartPointDetails args) {
                    if (mounted) {
                      // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                      setState(() async {
                        selectedIndex =
                        await triSpeedList[i].tripsByDate![j].id!;
                        print("selected index: $selectedIndex");
                      });
                    }
                  }, */
                    name: 'Duration',
                    emptyPointSettings:
                        EmptyPointSettings(mode: EmptyPointMode.drop),
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }

//                 if (duration(triSpeedList[i].tripsByDate![j].duration!) > 0) {
//                   durationColumnSeriesData.add(ColumnSeries<TripModel, String>(
//                     // color: barsColor[i],
//                     // pointColorMapper: barsColor,
//                     //width: 0.9,
//
//                     dataSource: triSpeedList,
//                     xValueMapper: (TripModel tripData, _) =>
//                         triSpeedList[i].date,
//                     yValueMapper: (TripModel tripData, _) =>
//                         duration(triSpeedList[i].tripsByDate![j].duration!),
//                     /* onPointTap: (ChartPointDetails args) {
//                     if (mounted) {
//                       // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
//                       setState(() async {
//                         selectedIndex =
//                         await triSpeedList[i].tripsByDate![j].id!;
//                         print("selected index: $selectedIndex");
//                       });
//                     }
//                   }, */
//                     name: 'Duration',
//                     dataLabelSettings: DataLabelSettings(isVisible: false),
//                     spacing: 0.1,
//                   ));
//                 }
                // else {
                //   durationColumnSeriesData.add(ColumnSeries<TripModel, String>(
                //     // color: barsColor[i],
                //     // pointColorMapper: barsColor,
                //     //width: 0.9,
                //
                //     dataSource: triSpeedList,
                //     xValueMapper: (TripModel tripData, _) =>
                //         triSpeedList[i].date,
                //     yValueMapper: (TripModel tripData, _) =>
                //         duration(triSpeedList[i].tripsByDate![j].duration!),
                //     /* onPointTap: (ChartPointDetails args) {
                //     if (mounted) {
                //       // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                //       setState(() async {
                //         selectedIndex =
                //         await triSpeedList[i].tripsByDate![j].id!;
                //         print("selected index: $selectedIndex");
                //       });
                //     }
                //   }, */
                //     name: 'Duration',
                //     dataLabelSettings: DataLabelSettings(isVisible: false),
                //     spacing: 0.1,
                //   ));
                // }

                if (triSpeedList[i].tripsByDate![j].avgSpeed! > 0) {
                  avgSpeedColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    // color: barsColor[i],
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].date,
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].avgSpeed! > 0
                            ? triSpeedList[i].tripsByDate![j].avgSpeed!
                            : null,
                    /*  onPointTap: (ChartPointDetails args)  {
                    if (mounted) {
                      Future.delayed(Duration(seconds: 1), () async{
                          selectedIndex = await triSpeedList[i].tripsByDate![j].id!;
                          Utils.customPrint("selected index: $selectedIndex");
                      });
                      //await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                    }
                  },*/
                    name: 'Avg Speed',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }

                if (triSpeedList[i].tripsByDate![j].fuelConsumption! > 0) {
                  fuelUsageColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    // color: barsColor[i],
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].date,
                    yValueMapper: (TripModel tripData, _) =>
// <<<<<<< Report-code-merge
                        triSpeedList[i].tripsByDate![j].fuelConsumption! > 0
                            ? triSpeedList[i].tripsByDate![j].fuelConsumption!
                            : null,
                    /*   onPointTap: (ChartPointDetails args) {
                    if (mounted) {
                      // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                      setState(() async {
                        selectedIndex =
                        await triSpeedList[i].tripsByDate![j].id!;
                        print("selected index: $selectedIndex");
                      });
                    }
                  }, */
// =======
//                       triSpeedList[i].tripsByDate![j].fuelConsumption,
// >>>>>>> Bug_loc_reports
                    name: 'Fuel Usage',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }

                if (triSpeedList[i].tripsByDate![j].avgPower! > 0) {
                  powerUsageColumnSeriesData
                      .add(ColumnSeries<TripModel, String>(
                    // color: barsColor[i],
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].date,
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].avgPower! > 0
                            ? triSpeedList[i].tripsByDate![j].avgPower!
                            : null,
                    /*  onPointTap: (ChartPointDetails args) {
                    if (mounted) {
                      // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                      setState(() async {
                        selectedIndex =
                        await triSpeedList[i].tripsByDate![j].id!;
                        print("selected index: $selectedIndex");
                      });
                    }
                  }, */
                    name: 'Power Usage',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }
              }
            }
//
// <<<<<<< Report-code-merge
            tripList.clear();

            for (int i = 0; i < triSpeedList.length; i++) {
              for (int j = 0; j < triSpeedList[i].tripsByDate!.length; j++) {
                Map<String, dynamic> data = {
                  'date': triSpeedList[i].date!,
                  'tripDetails': triSpeedList[i].tripsByDate![j].id,
                  'duration': triSpeedList[i].tripsByDate![j].duration,
                  'avgSpeed': '${triSpeedList[i].tripsByDate![j].avgSpeed}',
                  'fuelUsage':
                      triSpeedList[i].tripsByDate![j].fuelConsumption ?? 0.0,
                  'powerUsage': triSpeedList[i].tripsByDate![j].avgPower ?? 0.0
                };
                tripList.add(data);
              }
            }
            print("length: ${tripList.length}, tripList: $tripList");

            /*int duration1 = durationWithMilli(value.data!.avgInfo!.avgDuration!);
          String avgSpeed1 = value.data!.avgInfo!.avgSpeed!.toStringAsFixed(1) + " nm";
          String? fuelUsage = value.data!.avgInfo!.avgFuelConsumption.toString() + " g";
          String? powerUsage = value.data!.avgInfo!.avgPower.toString() + " w";*/
            duration1 = durationWithMilli(
                value.data?.avgInfo?.avgDuration ?? '0:0:0.0');
            avgSpeed1 = value.data?.avgInfo?.avgSpeed ?? 0.0;
            fuelUsage = value.data?.avgInfo?.avgFuelConsumption ?? 0.0;
            powerUsage = value.data?.avgInfo?.avgPower ?? 0.0;

            /*   int duration1 = durationWithMilli(value.data!.avgInfo!.avgDuration!);
            double avgSpeed1 = value.data!.avgInfo!.avgSpeed! ;
            double? fuelUsage = value.data!.avgInfo!.avgFuelConsumption;
            double? powerUsage = value.data!.avgInfo!.avgPower;*/

            print(
                "duration: $duration1,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage  ");

            /*   for (int i = 0; i < tripList.length; i++) {
              totalDuration += duration(tripList[i]['duration']);
              totalSpeed = totalSpeed ??
                  0.0 + double.parse(tripList[i]['avgSpeed']) ??
                  0.0;
              totalFuelConsumption = totalFuelConsumption ??
                  0.0 +
                      (tripList[i]['fuelConsumption'] != null
                          ? double.parse(tripList[i]['fuelConsumption'])
                          : 0.0) ??
                  0.0;
              totalAvgPower = totalAvgPower ??
                  0.0 +
                      (tripList[i]['avgPower'] != null
                          ? double.parse(tripList[i]['avgPower'])
                          : 0.0) ??
                  0.0;
            } */

            // totalData = [
            //   {
            //     'date': '',
            //     'tripDetails': 'Total',
            //     'duration': "$totalDuration",
            //     'avgSpeed': totalSpeed,
            //     'fuelUsage': totalFuelConsumption,
            //     'powerUsage': totalAvgPower
            //   }
            // ];

            finalData = [
              {
                'date': '',
                'tripDetails': 'Average',
                'duration': "$duration1",
                'avgSpeed': avgSpeed1,
                'fuelUsage': fuelUsage,
                'powerUsage': powerUsage
              }
            ];
// =======
//                 tripList = value.data!.trips!
//               .map((trip) => {
//             'date': trip.date!,
//             'tripDetails': trip.tripsByDate![0].id,
//             'duration': trip.tripsByDate![0].duration,
//             'avgSpeed': '${trip.tripsByDate![0].avgSpeed} nm',
//             'fuelUsage': trip.tripsByDate![0].fuelConsumption ?? 0.0,
//             'powerUsage': trip.tripsByDate![0].avgPower ?? 0.0
//           })
//               .toList();
//           print("tripList: $tripList");

//           int duration1 = durationWithMilli(value.data!.avgInfo!.avgDuration!);
//           String avgSpeed1 = value.data!.avgInfo!.avgSpeed!.toStringAsFixed(1) + " nm";
//           String? fuelUsage = value.data!.avgInfo!.avgFuelConsumption.toString() + " g";
//           String? powerUsage = value.data!.avgInfo!.avgPower.toString() + " w";

//           print("duration: $duration1,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage  ");

//           for(int i = 0; i < tripList.length; i++){
//             totalDuration += duration(tripList[i]['duration']);
//             totalSpeed += tripList[i]['avgSpeed'] ?? 0.0;
//             totalFuelConsumption += tripList[i]['fuelConsumption'];
//             totalAvgPower += tripList[i]['avgPower'] ?? 0.0;
//           }

//           totalData = [{
//             'date': '',
//             'tripDetails': 'Total',
//             'duration': "$totalDuration",
//             'avgSpeed': totalSpeed,
//             'fuelUsage': totalFuelConsumption,
//             'powerUsage': totalAvgPower
//           }];

//            finalData = [
//             {
//               'date': '',
//               'tripDetails': 'Average',
//               'duration': "$duration1",
//               'avgSpeed': avgSpeed1,
//               'fuelUsage': fuelUsage,
//               'powerUsage': powerUsage
//             }
//           ];
// >>>>>>> Bug_loc_reports

            // print("finalData: $finalData");
          } else {
            setState(() {
              isBtnClick = false;
              isCheckInternalServer = false;
              isReportDataLoading = false;
            });
          }
        } else {
          setState(() {
            isBtnClick = false;
            isReportDataLoading = false;
          });
        }
      });
    } catch (e, s) {
      setState(() {
        isBtnClick = false;
      });
      print("Error while getting data from report api : $e \n $s");
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

  getReportsDataWithValues(int caseType,
      {String? startDate,
      String? endDate,
      String? vesselID,
      List<String>? selectedTripListID}) async {
    try {
      await commonProvider
          .getReportData(
              startDate ?? "",
              endDate ?? "",
              caseType,
              vesselID,
              commonProvider.loginModel!.token!,
              selectedTripListID ?? [],
              context,
              scaffoldKey)
          .then((value) async {
        if (value != null) {
          if (value.message == "Internal Server Error") {
            setState(() {
              isCheckInternalServer = true;
            });
          } else if (!isCheckInternalServer! && value.statusCode == 200) {
            setState(() {
              isReportDataLoading = true;
              triSpeedList.clear();
            });
            avgSpeed = value.data!.avgInfo!.avgSpeed;
            avgDuration = durationWithMilli(value.data!.avgInfo!.avgDuration!);
            avgFuelConsumption = value.data!.avgInfo!.avgFuelConsumption;
            avgPower = value.data!.avgInfo!.avgPower ?? 0.0;
            print("avgPower : $avgPower");

            triSpeedList = List<TripModel>.from(value.data!.trips!.map(
                (tripData) => TripModel(
                    date: tripData.date, tripsByDate: tripData.tripsByDate)));

            Utils.customPrint('${triSpeedList}');
            for (int i = 0; i < triSpeedList.length; i++) {
              for (int j = 0; j < triSpeedList[i].tripsByDate!.length; j++) {
                print(
                    "trip duration data is: ${triSpeedList[i].tripsByDate![j].id}");
                durationColumnSeriesData.add(ColumnSeries<TripModel, String>(
                  width: 0.9,
                  color: barsColor[j],
                  dataSource: triSpeedList,
                  xValueMapper: (TripModel tripData, _) => triSpeedList[i].date,
                  yValueMapper: (TripModel tripData, _) => duration(
                      triSpeedList[i].tripsByDate![j].duration.toString()),
                  name: 'Duration',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  spacing: 0.1,
                ));
                avgSpeedColumnSeriesData.add(ColumnSeries<TripModel, String>(
                  color: barsColor[j],
                  dataSource: triSpeedList,
                  xValueMapper: (TripModel tripData, _) => triSpeedList[i].date,
                  yValueMapper: (TripModel tripData, _) =>
                      triSpeedList[i].tripsByDate![j].avgSpeed,
                  name: 'Avg Speed',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  spacing: 0.1,
                ));
                fuelUsageColumnSeriesData.add(ColumnSeries<TripModel, String>(
                  color: barsColor[j],
                  dataSource: triSpeedList,
                  xValueMapper: (TripModel tripData, _) => triSpeedList[i].date,
                  yValueMapper: (TripModel tripData, _) =>
                      triSpeedList[i].tripsByDate![j].fuelConsumption,
                  name: 'Fuel Usage',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  spacing: 0.1,
                ));
                powerUsageColumnSeriesData.add(ColumnSeries<TripModel, String>(
                  color: barsColor[j],
                  dataSource: triSpeedList,
                  xValueMapper: (TripModel tripData, _) => triSpeedList[i].date,
                  yValueMapper: (TripModel tripData, _) =>
                      triSpeedList[i].tripsByDate![j].avgPower,
                  name: 'Power Usage',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  spacing: 0.1,
                ));
              }
            }

            tripList = value.data!.trips!
                .map((trip) => {
                      'date': trip.date!,
                      'tripDetails': trip.tripsByDate![0].id,
                      'duration': trip.tripsByDate![0].duration,
                      'avgSpeed': '${trip.tripsByDate![0].avgSpeed} nm',
                      'fuelUsage': trip.tripsByDate![0].fuelConsumption ?? 0.0,
                      'powerUsage': trip.tripsByDate![0].avgPower ?? 0.0
                    })
                .toList();
            print("tripList: $tripList");

            int duration1 =
                durationWithMilli(value.data!.avgInfo!.avgDuration!);
            String avgSpeed1 =
                value.data!.avgInfo!.avgSpeed!.toStringAsFixed(1) + " nm";
            String? fuelUsage =
                value.data!.avgInfo!.avgFuelConsumption.toString() + " g";
            String? powerUsage =
                value.data!.avgInfo!.avgPower.toString() + " w";

            print(
                "duration: $duration1,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage  ");

            for (int i = 0; i < tripList.length; i++) {
              totalDuration += duration(tripList[i]['duration']);
              totalSpeed += tripList[i]['avgSpeed'] ?? 0.0;
              totalFuelConsumption += tripList[i]['fuelConsumption'];
              totalAvgPower += tripList[i]['avgPower'] ?? 0.0;
            }

            totalData = [
              {
                'date': '',
                'tripDetails': 'Total',
                'duration': "$totalDuration",
                'avgSpeed': totalSpeed,
                'fuelUsage': totalFuelConsumption,
                'powerUsage': totalAvgPower
              }
            ];

            finalData = [
              {
                'date': '',
                'tripDetails': 'Average',
                'duration': "$duration1",
                'avgSpeed': avgSpeed1,
                'fuelUsage': fuelUsage,
                'powerUsage': powerUsage
              }
            ];

            // print("finalData: $finalData");
          } else {
            setState(() {
              isCheckInternalServer = false;
              isReportDataLoading = false;
            });
          }
        } else {
          setState(() {
            isReportDataLoading = false;
          });
        }
      });
    } catch (e) {
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
    print('TOTAL MIN: $totalMinutes');
    return double.parse('$totalMinutes.${parts[2]}');
  }

  dynamic dateWithZeros(String timesString) {
    String dateString = timesString;
    List<String> dateParts = dateString.split('-'); // ['3', '3', '2023']
    String day = dateParts[0].padLeft(2, '0'); // '03'
    String month = dateParts[1].padLeft(2, '0'); // '03'
    String year = dateParts[2]; // '2023'
    String formattedDate = '$day-$month-$year'; // '2023-03-03'
    return formattedDate;
  }

  dynamic durationWithMilli(String timesString) {
    String time = timesString;
    print('TIME STRING: $timesString');
    // Duration duration = Duration(
    //   hours: int.parse(time.split(':')[0]),
    //   minutes: int.parse(timeString.split(':')[1]),
    //   seconds: int.parse(timeString.split(':')[2].split('.')[0]),
    //   milliseconds: int.parse(timeString.split(':')[2].split('.')[1]),
    // );
    String timeString = time;
    String integerTimeString = timeString.split('.')[0];
    // int durationInMinutes = duration.inMinutes;
    // double timeInSeconds = double.parse(integerTimeString.replaceAll(':', ''));
    return integerTimeString;
  }

  dynamic durationWithMilli2(String timeString) {
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

  @override
  void initState() {
    super.initState();
    commonProvider = context.read<CommonProvider>();
    parentValue = false;
    isTripIdListLoading = true;
    Future.delayed(Duration.zero, () {
      getVesselAndTripsData();
    });

    selectedTripsAndDateString = "Date Range";

    tripDurationButtonColor = true;

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
                padding: EdgeInsets.only(top: 0),
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
                                width: displayWidth(context) * 0.25,
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
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: displayWidth(context) * 0.05,
                            right: displayWidth(context) * 0.05),
                        child: ExpansionTile(
                          key: new Key(_key.toString()),
                          maintainState: true,
                          initiallyExpanded: isExpansionCollapse!,
                          onExpansionChanged: (isExpanded) {
                            setState(() {
                              print("isExpansionCollapse : $isExpanded");
                              isExpansionCollapse = !isExpansionCollapse!;
                              isExpandedTile = !isExpandedTile;
                              // isExpansionCollapse = isExpanded;
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
                          trailing: !isExpandedTile
                              ? Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                )
                              : Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.black,
                                ),
                          children: [
                            //isVesselDataLoading!
                            !isVesselDataLoading!
                                ? Padding(
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
                                          contentPadding:
                                              const EdgeInsets.all(3),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.transparent),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.transparent),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.red),
                                          ),
                                          errorStyle: TextStyle(
                                              fontFamily: "",
                                              fontSize: displayWidth(context) *
                                                  0.025),
                                          focusedErrorBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.red),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 13,
                                              right:
                                                  displayWidth(context) * 0.45),
                                          child: Form(
                                            key: _formKey,
                                            child: DropdownButtonFormField<
                                                DropdownItem>(
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              dropdownColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? "Select Vessel" ==
                                                          'User SubRole'
                                                      ? Colors.white
                                                      : Colors.transparent
                                                  : Colors.white,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                border: InputBorder.none,
                                                hintText: "Select Vessel*",
                                                hintStyle: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? "Select Vessel" ==
                                                                'User SubRole'
                                                            ? Colors.black
                                                            : Colors.white
                                                        : Colors.black,
                                                    fontSize:
                                                        displayWidth(context) *
                                                            0.034,
                                                    fontFamily: inter,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              isExpanded: true,
                                              isDense: true,
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Select Vessel';
                                                }
                                                return null;
                                              },
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? "Select Vessel" ==
                                                              'User SubRole'
                                                          ? Colors.black
                                                          : Colors.white
                                                      : Colors.black),
                                              value: selectedValue,
                                              // value: selectState,
                                              items: vesselData.map((item) {
                                                return DropdownMenuItem<
                                                    DropdownItem>(
                                                  value: item,
                                                  child: Text(
                                                    item.name!,
                                                    style: TextStyle(
                                                        fontSize: displayWidth(
                                                                context) *
                                                            0.0346,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? "Select Vessel" ==
                                                                    'User SubRole'
                                                                ? Colors.black
                                                                : Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (item) {
                                                print("id is: ${item?.id} ");
                                                parentValue = false;
                                                selectedVessel = item!.id;
                                                selectedVesselName = item.name;
                                                if (mounted) {
                                                  setState(() {
                                                    isTripIdListLoading = false;
                                                    isSHowGraph = false;
                                                    avgSpeed = null;
                                                    avgDuration = null;
                                                    avgFuelConsumption = null;
                                                    avgPower = null;
                                                    triSpeedList.clear();
                                                    tripList.clear();
                                                    duration1 = null;
                                                    avgSpeed1 = null;
                                                    fuelUsage = null;
                                                    powerUsage = null;
                                                    finalData.clear();
                                                    durationGraphData.clear();

                                                    durationColumnSeriesData
                                                        .clear();
                                                    avgSpeedColumnSeriesData
                                                        .clear();
                                                    fuelUsageColumnSeriesData
                                                        .clear();
                                                    powerUsageColumnSeriesData
                                                        .clear();
                                                    selectedTripIdList!.clear();
                                                    selectedTripLabelList!
                                                        .clear();
                                                  });
                                                }

                                                dateTimeList!.clear();
                                                children!.clear();
                                                getTripListData(item.id!);

                                                // state.didChange(item);
                                                // onChanged!(item);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          circularProgressColor),
                                    ),
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        isSHowGraph = false;
                                        selectedCaseType = 1;
                                        print(
                                            "selectedCaseType: $selectedCaseType ");
                                        _selectedOption = value!;
                                        selectedTripsAndDateString =
                                            "Date Range";
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
                                        selectedTripsAndDateDetails = "";
                                        selectedCaseType = 2;
                                        isSHowGraph = false;
                                        print(
                                            "selectedCaseType: $selectedCaseType ");
                                        _selectedOption = value!;
                                        selectedTripsAndDateString =
                                            "Selected Trips";
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
                            isBtnClick ?? false
                                ? Container(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: circularProgressColor,
                                      ),
                                    ),
                                  )
                                : CommonButtons.getAcceptButton(
                                    "Search", context, primaryColor, () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isBtnClick = true;
                                        isExpansionCollapse = false;

                                        avgSpeed = null;
                                        avgDuration = null;
                                        avgFuelConsumption = null;
                                        avgPower = null;
                                        triSpeedList.clear();
                                        tripList.clear();
                                        duration1 = null;
                                        avgSpeed1 = null;
                                        fuelUsage = null;
                                        powerUsage = null;
                                        finalData.clear();
                                        durationGraphData.clear();

                                        durationColumnSeriesData.clear();
                                        avgSpeedColumnSeriesData.clear();
                                        fuelUsageColumnSeriesData.clear();
                                        powerUsageColumnSeriesData.clear();
                                      });

                                      // _collapseExpansionTile();
                                      String? startDate = "";
                                      String? endDate = "";
                                      totalDuration = 0;
                                      totalSpeed = 0;
                                      totalFuelConsumption = 0;
                                      totalAvgPower = 0;

                                      if (selectedCaseType == 1) {
                                        if (focusedDayString!.isNotEmpty ||
                                            lastFocusedDayString!.isNotEmpty) {
                                          startDate = convertIntoYearMonthDay(
                                              selectedDateForStartDate);
                                          endDate = convertIntoYearMonthDay(
                                              selectedDateForEndDate);
                                          selectedTripsAndDateDetails =
                                              "$startDate to $endDate";
                                        }
                                        if (selectedDateForEndDate.isBefore(
                                            selectedDateForStartDate)) {
                                          isBtnClick = false;
                                          Utils.showSnackBar(context,
                                              scaffoldKey: scaffoldKey,
                                              message:
                                                  'End date ($endDate) should be greater than start date($startDate)',
                                              duration: 2);
                                        }
                                        if (isSelectedStartDay! &&
                                            isSelectedEndDay!) {
                                          getReportsData(selectedCaseType!,
                                              startDate: startDate,
                                              endDate: endDate,
                                              vesselID: selectedVessel);
                                        } else {
                                          setState(() {
                                            isBtnClick = false;
                                          });
// <<<<<<< Report-code-merge
                                          Utils.showSnackBar(context,
                                              scaffoldKey: scaffoldKey,
                                              message:
                                                  'Please select the start and end dates',
                                              duration: 2);
                                        }
                                        /*    if ((selectedVessel?.isNotEmpty ??
                                              false) &&
                                              (startDate.isNotEmpty && startDate != null)&&
                                              (endDate.isNotEmpty && endDate != null)) {
                                            getReportsData(selectedCaseType!,
                                                startDate: startDate,
                                                endDate: endDate,
                                                vesselID: selectedVessel);
                                          } else if(startDate.isEmpty &&
                                              endDate.isEmpty){
                                            setState(() {
                                              isBtnClick = false;
                                            });
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                'Please select the start and end dates',
                                                duration: 2);
                                          }
                                          else if(!isSelectedStartDay!){
                                            setState(() {
                                              isBtnClick = false;
                                            });
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                'Please select the start dates',
                                                duration: 2);
                                          } else if(!isSelectedEndDay!){
                                            setState(() {
                                              isBtnClick = false;
                                            });
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                'Please select the end date',
                                                duration: 2);
                                          }; */
                                        /*   else {
                                            setState(() {
                                              isBtnClick = false;
                                            });
                                            if (startDate.isEmpty &&
                                                endDate.isEmpty) {
                                              Utils.showSnackBar(context,
                                                  scaffoldKey: scaffoldKey,
                                                  message:
                                                  'Please select the start and end dates',
                                                  duration: 2);
                                            } else if (startDate.isEmpty) {
                                              Utils.showSnackBar(context,
                                                  scaffoldKey: scaffoldKey,
                                                  message:
                                                  'Please select the start date',
                                                  duration: 2);
                                            } else if (endDate.isEmpty) {
                                              Utils.showSnackBar(context,
                                                  scaffoldKey: scaffoldKey,
                                                  message:
                                                  'Please select the end date',
                                                  duration: 2);
                                            }
                                          }*/

                                      } else if (selectedCaseType == 2) {
                                        if (selectedTripIdList?.isNotEmpty ??
                                            false) {
                                          getReportsData(selectedCaseType!,
                                              selectedTripListID:
                                                  selectedTripIdList);
                                        } else {
                                          setState(() {
                                            isBtnClick = false;
                                          });
                                          if (selectedTripIdList?.isEmpty ??
                                              false) {
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                    'Please select the Trip Id',
                                                duration: 2);
                                          }
                                        }
                                      }
// =======
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           _selectedOption == 1
//                               ? filterByDate(context)!
//                               : filterByTrip(context)!,
//                           SizedBox(
//                             height: displayWidth(context) * 0.08,
//                           ),
//                           CommonButtons.getAcceptButton(
//                               "Search", context, primaryColor, () {
//                             if (_formKey.currentState!.validate()) {
//                               _collapseExpansionTile();
//                               String? startDate = "";
//                               String? endDate = "";
//                               if(focusedDayString!.isNotEmpty || lastFocusedDayString!.isNotEmpty){
//                                  startDate = convertIntoYearMonthDay(focusedDayString!);
//                                  endDate =  convertIntoYearMonthDay(lastFocusedDayString!);
//                                  selectedTripsAndDateDetails = "$startDate to $endDate";
//                               }
//                               if(selectedCaseType == 1){
//                                 getReportsDataWithValues(selectedCaseType!,startDate: startDate,endDate: endDate,vesselID: selectedVessel);
//                               }else if(selectedCaseType == 2){
//                                 getReportsDataWithValues(selectedCaseType!,selectedTripListID: selectedTripIdList);
// >>>>>>> Bug_loc_reports
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
                    ),
                    !isSHowGraph!
                        ? Container()
                        : isReportDataLoading!
                            ? Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: displayWidth(context) * 0.05,
                                      right: displayWidth(context) * 0.05,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: displayWidth(context) * 0.07,
                                        ),
                                        Text(
                                          "$selectedVesselName",
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
                                              "$selectedTripsAndDateString",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: inter),
                                            ),
                                            SizedBox(
                                              width:
                                                  displayWidth(context) * 0.05,
                                            ),
                                            Expanded(
                                              child: Text(
                                                selectedCaseType == 1
                                                    ? ": ${selectedTripsAndDateDetails}"
                                                    : ":  ${selectedTripLabelList!.join(', ')}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: inter),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: displayWidth(context) * 0.06,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedButton =
                                                      'trip duration';
                                                  tripDurationButtonColor =
                                                      true;
                                                  avgSpeedButtonColor = false;
                                                  fuelUsageButtonColor = false;
                                                  powerUsageButtonColor = false;
                                                });
                                              },
                                              child: Container(
                                                //  color: dateBackgroundColor,
                                                width: displayWidth(context) *
                                                    0.21,
                                                height: displayWidth(context) *
                                                    0.09,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color:
                                                        !tripDurationButtonColor!
                                                            ? reportTabColor
                                                            : Colors.blue),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Center(
                                                    child: Text(
                                                      "Trip Duration",
                                                      style: TextStyle(
                                                          color:
                                                              tripDurationButtonColor!
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedButton = 'avg speed';
                                                  tripDurationButtonColor =
                                                      false;
                                                  avgSpeedButtonColor = true;
                                                  fuelUsageButtonColor = false;
                                                  powerUsageButtonColor = false;
                                                });
                                              },
                                              child: Container(
                                                //  color: dateBackgroundColor,
                                                width: displayWidth(context) *
                                                    0.19,
                                                height: displayWidth(context) *
                                                    0.09,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: !avgSpeedButtonColor!
                                                        ? reportTabColor
                                                        : Colors.blue),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Center(
                                                    child: Text(
                                                      "Avg Speed",
                                                      style: TextStyle(
                                                          color:
                                                              avgSpeedButtonColor!
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedButton = 'fuel usage';
                                                  tripDurationButtonColor =
                                                      false;
                                                  avgSpeedButtonColor = false;
                                                  fuelUsageButtonColor = true;
                                                  powerUsageButtonColor = false;
                                                });
                                              },
                                              child: Container(
                                                //  color: dateBackgroundColor,
                                                width: displayWidth(context) *
                                                    0.20,
                                                height: displayWidth(context) *
                                                    0.09,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color:
                                                        !fuelUsageButtonColor!
                                                            ? reportTabColor
                                                            : Colors.blue),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Center(
                                                    child: Text(
                                                      "Fuel Usage",
                                                      style: TextStyle(
                                                          color:
                                                              fuelUsageButtonColor!
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedButton =
                                                      'power usage';
                                                  tripDurationButtonColor =
                                                      false;
                                                  avgSpeedButtonColor = false;
                                                  fuelUsageButtonColor = false;
                                                  powerUsageButtonColor = true;
                                                });
                                              },
                                              child: Container(
                                                //  color: dateBackgroundColor,
                                                width: displayWidth(context) *
                                                    0.22,
                                                height: displayWidth(context) *
                                                    0.09,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color:
                                                        !powerUsageButtonColor!
                                                            ? reportTabColor
                                                            : Colors.blue),
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Center(
                                                    child: Text(
                                                      "Power Usage",
                                                      style: TextStyle(
                                                          color:
                                                              powerUsageButtonColor!
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400),
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
// <<<<<<< Report-code-merge
                                  ),
                                  isReportDataLoading!
                                      ? buildGraph(context)
                                      : Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    circularProgressColor),
// =======

//                           table(context)!,

//                           SizedBox(
//                             height: displayWidth(context) * 0.08,
// >>>>>>> Bug_loc_reports
                                          ),
                                        ),

                                  // tripDurationGraph(context)!,
                                  //avgSpeedGraph(context)!,
                                  // fuelUsageGraph(context)!,
                                  // powerUsageGraph(context)!,

                                  // Padding(
                                  //   padding: EdgeInsets.only(right: 20, left: 20),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceEvenly,
                                  //     children: [
                                  //       tripWithColor(
                                  //           backgroundColor, 'Trip A Name'),
                                  //       tripWithColor(
                                  //           circularProgressColor, 'Trip B Name'),
                                  //       tripWithColor(
                                  //           tripColumnBarColor, 'Trip C Name'),
                                  //     ],
                                  //   ),
                                  // ),

                                  table(context)!,

                                  SizedBox(
                                    height: displayWidth(context) * 0.08,
                                  ),
                                ],
                              )
                            : Container(),
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
// <<<<<<< Report-code-merge
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: DataTable(
          columnSpacing: 25,
          dividerThickness: 1,
          columns: [
            DataColumn(
              label: Expanded(
                child: Center(
                  child: Text(
                    'Date',
                    style: TextStyle(color: tableHeaderColor),
                  ),
                ),
              ),
            ),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text(
                  'Trip Details',
                  style: TextStyle(color: tableHeaderColor),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Duration',
                    style: TextStyle(color: tableHeaderColor),
                    textAlign: TextAlign.center),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Avg Speed (KT)',
                    style: TextStyle(color: tableHeaderColor),
                    textAlign: TextAlign.center),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Fuel Usage (gal)',
                    style: TextStyle(color: tableHeaderColor),
                    textAlign: TextAlign.center),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Power Usage (W)',
                    style: TextStyle(color: tableHeaderColor),
                    textAlign: TextAlign.center),
              ),
            )),
          ],
          rows: [
            ...tripList.map((person) => DataRow(cells: [
                  DataCell(
                    Align(
                        alignment: Alignment.center,
                        child: Text(dateWithZeros(person['date'])!,
                            textAlign: TextAlign.center)),
                  ),
                  DataCell(Align(
                      alignment: Alignment.center,
                      child: Text(person['tripDetails']!,
                          textAlign: TextAlign.center))),
                  DataCell(Align(
                      alignment: Alignment.center,
                      child: Text(person['duration']!,
                          textAlign: TextAlign.center))),
                  DataCell(Align(
                      alignment: Alignment.center,
                      child: Text('${person['avgSpeed']!}',
                          textAlign: TextAlign.center))),
                  DataCell(Align(
                      alignment: Alignment.center,
                      child: Text('${person['fuelUsage']}',
                          textAlign: TextAlign.center))),
                  DataCell(Align(
                      alignment: Alignment.center,
                      child: Text('${person['powerUsage']}',
                          textAlign: TextAlign.center))),
                ])),

            /* ...totalData.map((e) => DataRow(cells: [
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
              DataCell(Text('${e['avgSpeed']!}',
                  style: TextStyle(color: Colors.blue))),
              DataCell(Text('${e['fuelUsage']!}',
                  style: TextStyle(color: Colors.blue))),
              DataCell(Text('${e['powerUsage']!}',
                  style: TextStyle(color: Colors.blue))),
            ])),*/
            ...finalData.map((e) => DataRow(cells: [
                  DataCell(
                    Text(
                      e['date']!,
                      style: TextStyle(
                          color: circularProgressColor,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  DataCell(Text(
                    e['tripDetails']!,
                    style: TextStyle(
                        color: circularProgressColor,
                        fontWeight: FontWeight.w800),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text(
                      e['duration']!,
                      style: TextStyle(
                          color: circularProgressColor,
                          fontWeight: FontWeight.w800),
                    ),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('${e['avgSpeed'].toStringAsFixed(2)!}',
                        style: TextStyle(
                            color: circularProgressColor,
                            fontWeight: FontWeight.w800)),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('${e['fuelUsage']!}',
                        style: TextStyle(
                            color: circularProgressColor,
                            fontWeight: FontWeight.w800)),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('${e['powerUsage']!}',
                        style: TextStyle(
                            color: circularProgressColor,
                            fontWeight: FontWeight.w800)),
                  )),
                ]))
          ],
// =======
//       child: Container(

//         child: Padding(
//           padding: EdgeInsets.all(12.0),
//           child: DataTable(
//             columnSpacing: 25,
//             dividerThickness: 1,
//             columns: [
//               DataColumn(
//                 label: Text(
//                   'Date',
//                   style: TextStyle(color: tableHeaderColor),
//                 ),
//               ),
//               DataColumn(
//                   label: Text('Trip Details',
//                       style: TextStyle(color: tableHeaderColor))),
//               DataColumn(
//                   label: Text('Duration',
//                       style: TextStyle(color: tableHeaderColor))),
//               DataColumn(
//                   label: Text('Avg Speed',
//                       style: TextStyle(color: tableHeaderColor))),
//               DataColumn(
//                   label: Text('Fuel Usage',
//                       style: TextStyle(color: tableHeaderColor))),
//               DataColumn(
//                   label: Text('Power Usage',
//                       style: TextStyle(color: tableHeaderColor))),
//             ],
//             rows: [
//             /*  ...tripList.map((person) => DataRow(cells: [
//                     DataCell(Text(person['date']!)),
//                     DataCell(Text(person['tripDetails']!)),
//                     DataCell(Text(person['duration']!)),
//                     DataCell(Text(person['avgSpeed']!)),
//                     DataCell(Text(person['fuelUsage']!)),
//                     DataCell(Text(person['powerUsage'])),
//                   ])),*/
//                ...tripList.map((person) => DataRow(cells: [
//                 DataCell(Text(person['date']!)),
//                 DataCell(Text(person['tripDetails']!)),
//                 DataCell(Text(person['duration']!)),
//                 DataCell(Text(person['avgSpeed']!)),
//                 DataCell(Text(person['fuelUsage']!)),
//                 DataCell(Text(person['powerUsage'])),
//               ])),
//               ...totalData.map((e) => DataRow(cells: [
//                 DataCell(
//                   Text(
//                     e['date']!,
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 ),
//                 DataCell(Text(
//                   e['tripDetails'] ?? '',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//                 DataCell(Text(
//                   e['duration'] ?? '',
//                   style: TextStyle(color: Colors.blue),
//                 )),
//                 DataCell(Text(e['avgSpeed'] ?? '',
//                     style: TextStyle(color: Colors.blue))),
//                 DataCell(Text(e['fuelUsage'] ?? '',
//                     style: TextStyle(color: Colors.blue))),
//                 DataCell(Text(e['powerUsage'] ?? '',
//                     style: TextStyle(color: Colors.blue))),
//               ])),
//               ...finalData.map((e) => DataRow(cells: [
//                     DataCell(
//                       Text(
//                         e['date']!,
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                     DataCell(Text(
//                       e['tripDetails']!,
//                       style: TextStyle(color: Colors.blue),
//                     )),
//                     DataCell(Text(
//                       e['duration']!,
//                       style: TextStyle(color: Colors.blue),
//                     )),
//                     DataCell(Text(e['avgSpeed']!,
//                         style: TextStyle(color: Colors.blue))),
//                     DataCell(Text(e['fuelUsage']!,
//                         style: TextStyle(color: Colors.blue))),
//                     DataCell(Text(e['powerUsage']!,
//                         style: TextStyle(color: Colors.blue))),
//                   ]))
//             ],
//           ),
// >>>>>>> Bug_loc_reports
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
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      borderWidth: 1,
      activationMode: ActivationMode.singleTap,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final dynamic yValue = currentPoint.y;
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
                  Text("${yValue}",
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
// <<<<<<< Report-code-merge
              /*  TextButton(
                onPressed: () {
                  print("tapped on go to report button");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripAnalyticsScreen(
                            tripId: selectedIndex,
                            vesselName: selectedVesselName,
                            //  avgInfo: reportModel!.data!.avgInfo,
                            vesselId: selectedVessel,
                            tripIsRunningOrNot: false,
                            calledFrom: 'Report',
                            // vessel: getVesselById[0]
                          )));
// =======
//               TextButton(
//                 onPressed: () {

// >>>>>>> Bug_loc_reports
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              ) */
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 2.8,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          //tooltipBehavior: CustomTooltipBehavior(),
          palette: barsColor,

          // borderWidth: 6,
          tooltipBehavior: tooltipBehavior,
          enableSideBySideSeriesPlacement: true,
          primaryXAxis: CategoryAxis(
              autoScrollingMode: AutoScrollingMode.end,
              labelAlignment: LabelAlignment.center,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              )),
          primaryYAxis: NumericAxis(
              // interval: 5,

              axisLine: AxisLine(
                width: 0,
              ),
              title: AxisTitle(
                  text: 'Minutes',
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: displayWidth(context) * 0.028,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              majorTickLines: MajorTickLines(width: 0),
              minorTickLines: MinorTickLines(width: 0),
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              ),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgDuration} min',
                    isVisible: true,
                    start: avgDuration,
                    end: avgDuration,
                    borderWidth: 2,
                    borderColor: Colors.grey.shade400,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: displayWidth(context) * 0.028,
                      fontWeight: FontWeight.w500,
                      fontFamily: poppins,
                    ),
                    dashArray: <double>[4, 8],
                    horizontalTextAlignment: TextAnchor.start),
              ]),
          series: durationColumnSeriesData,
        ),
      ),
    );
  }

  Widget avgSpeedGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      borderWidth: 1,
      // activationMode: ActivationMode.singleTap,
      duration: 5000,
      tooltipPosition: TooltipPosition.pointer,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final double? yValue = currentPoint.y;

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
                  Text('${yValue}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )),
                  Text('KT',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              /*  TextButton(
                onPressed: () {
                  print("tapped on go to report button");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripAnalyticsScreen(
                            tripId: selectedIndex,
                            vesselName: selectedVesselName,
                            // avgInfo: reportModel!.data!.avgInfo,
                            vesselId: selectedVessel,
                            tripIsRunningOrNot: false,
                            calledFrom: 'Report',
                            // vessel: getVesselById[0]
                          )));
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              ) */
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      //physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 2.8,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          palette: barsColor,
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(
              autoScrollingMode: AutoScrollingMode.end,
              labelAlignment: LabelAlignment.center,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              )),
          primaryYAxis: NumericAxis(
              // interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(
                  text: 'Knots',
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: displayWidth(context) * 0.028,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              ),
              plotBands: <PlotBand>[
                PlotBand(
                  text: 'avg ${avgSpeed}KT',
                  isVisible: true,
                  start: avgSpeed,
                  end: avgSpeed,
                  borderWidth: 2,
                  borderColor: Colors.grey,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: displayWidth(context) * 0.028,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  ),
                  dashArray: <double>[4, 8],
                  horizontalTextAlignment: TextAnchor.start,
                ),
              ]),
          series: avgSpeedColumnSeriesData,
        ),
      ),
    );
  }

  Widget fuelUsageGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final double? yValue = currentPoint.y;
        print("fuel y data is: ${yValue}");
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
                  Text('${yValue}',
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
              /* TextButton(
                onPressed: () {
                  print("tapped on go to report button");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripAnalyticsScreen(
                            tripId: selectedIndex,
                            vesselName: selectedVesselName,
                            // avgInfo: reportModel!.data!.avgInfo,
                            vesselId: selectedVessel,
                            tripIsRunningOrNot: false,
                            calledFrom: 'Report',
                            // vessel: getVesselById[0]
                          )));
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              ) */
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 2.8,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          palette: barsColor,
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(
              autoScrollingMode: AutoScrollingMode.end,
              labelAlignment: LabelAlignment.center,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              )),
          primaryYAxis: NumericAxis(
              labelFormat: '{value} gal',
              // interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(
                  text: 'Galance',
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: displayWidth(context) * 0.028,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              ),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgFuelConsumption}gal',
                    isVisible: true,
                    start: avgFuelConsumption,
                    end: avgFuelConsumption,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: displayWidth(context) * 0.028,
                      fontWeight: FontWeight.w500,
                      fontFamily: poppins,
                    ),
                    dashArray: <double>[4, 8],
                    horizontalTextAlignment: TextAnchor.start),
              ]),
          series: fuelUsageColumnSeriesData,
        ),
      ),
    );
  }

  Widget powerUsageGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: reportBackgroundColor,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final double? yValue = currentPoint.y;
        print("power y data is: ${yValue}");
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
                  Text('${yValue}',
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
              /*  TextButton(
                onPressed: () {
                  print("tapped on go to report button");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripAnalyticsScreen(
                            tripId: selectedIndex,
                            vesselName: selectedVesselName,
                            //   avgInfo: reportModel!.data!.avgInfo,
                            vesselId: selectedVessel,
                            tripIsRunningOrNot: false,
                            calledFrom: 'Report',
                            // vessel: getVesselById[0]
                          )));
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )),
              ) */
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: displayWidth(context) * 2.8,
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          palette: barsColor,
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(
              autoScrollingMode: AutoScrollingMode.end,
              labelAlignment: LabelAlignment.center,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              )),
          primaryYAxis: NumericAxis(
              // interval: 5,
              axisLine: AxisLine(width: 2),
              title: AxisTitle(
                  text: 'Wats',
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: displayWidth(context) * 0.028,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              ),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgPower.toStringAsFixed(2)}W',
                    isVisible: true,
                    start: avgPower,
                    end: avgPower,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: displayWidth(context) * 0.028,
                      fontWeight: FontWeight.w500,
                      fontFamily: poppins,
                    ),
                    dashArray: <double>[4, 8],
                    horizontalTextAlignment: TextAnchor.start),
              ]),
          series: powerUsageColumnSeriesData,
        ),
      ),
    );
  }

  Widget? filterByDate(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isStartDate = true;
                      selectDateOption = 1;
                      isSelectStartDate = true;
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
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
                      isSelectEndDate = true;
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
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
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
            Text(
              '${DateFormat('yyyy-MM-dd').format(selectedDateForStartDate)}  to  ${DateFormat('yyyy-MM-dd').format(selectedDateForEndDate)}',
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
        SizedBox(
          height: displayWidth(context) * 0.08,
        ),
        selectDateOption == 1 && isSelectStartDate
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
                          "Select Start Date",
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
                      focusedDay: selectedDateForStartDate,
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
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue,
                              )),
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
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: selectedDateForStartDate == DateTime.now()
                                  ? Colors.white
                                  : Colors.blue)),
                      selectedDayPredicate: (DateTime date) {
                        return isSameDay(selectedDateForStartDate, date);
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (DateTime? selectDay, DateTime? focusDay) {
                        setState(() {
                          isSelectedStartDay = true;
                          selectedDateForStartDate = selectDay!;
                          focusedDay = focusDay!;
                          focusedDayString = focusDay.toString();
                        });
                        print("focusedDay: $focusDay");
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        // rightChevronVisible: DateTime(lastDate.year, lastDate.month , lastDate.day) == DateTime(now.year, now.month , now.day)  ? true:false,

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
            : isSelectEndDate
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
                              "Select End Date",
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
                          focusedDay: selectedDateForEndDate,
                          firstDay: firstDate,
                          lastDay: lastDate,
                          onFormatChanged: (CalendarFormat _format) {},
                          calendarBuilders: CalendarBuilders(
                            selectedBuilder: (context, date, events) =>
                                Container(
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
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue,
                                  )),
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
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.0,
                                  color:
                                      selectedDateForEndDate == DateTime.now()
                                          ? Colors.white
                                          : Colors.blue)),
                          selectedDayPredicate: (DateTime date) {
                            return isSameDay(selectedDateForEndDate, date);
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          onDaySelected:
                              (DateTime? selectDay, DateTime? focusDay) {
                            setState(() {
                              isSelectedEndDay = true;
                              selectedDateForEndDate = selectDay!;
                              lastDayFocused = focusDay!;
                              lastFocusedDayString = focusDay.toString();
                            });
                            print("lastDayFocused: $lastDayFocused");
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            formatButtonDecoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                            formatButtonTextStyle:
                                TextStyle(color: Colors.white),
                            formatButtonShowsNext: false,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
      ],
    );
  }

  Widget? filterByTrip(BuildContext context) {
    return !isTripIdListLoading!
        ? Column(
            children: [
              // (tripIdList?.isEmpty ?? false) ? Container(width: displayWidth(context),height: 40,child: Center(child: commonText(text: 'No Trip Id available',textSize: displayWidth(context)*0.030)),) :

              tripIdList!.length == 0
                  ? Container(
                      child: commonText(
                        text: 'No Trips available',
                        textSize: displayWidth(context) * 0.030,
                        textColor: primaryColor,
                      ),
                    )
                  : ListView(
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: displayWidth(context) * 0.046),
                          child: CustomLabeledCheckbox(
                            label: 'Select All',
                            value: parentValue != null ? parentValue! : false,
                            onChanged: (value) {
                              if (value != null) {
                                // Checked/Unchecked
                                //selectedTripIdList = tripIdList;
                                selectedTripIdList!.addAll(tripIdList!);
                                selectedTripLabelList!.clear();
                                selectedTripLabelList!.addAll(children!);
                                _checkAll(value);
                              } else {
                                // Tristate
                                selectedTripLabelList!.clear();
                                _checkAll(true);
                              }
                            },
                            checkboxType: CheckboxType.Parent,
                            activeColor: Colors.indigo,
                          ),
                        ),
                        ListView.builder(
                          itemCount: children?.length ?? 0,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
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
                                  if (!selectedTripIdList!
                                      .contains(tripIdList![index])) {
                                    selectedTripIdList!.add(tripIdList![index]);
                                    selectedTripLabelList!
                                        .add(children![index]);
                                  } else {
                                    selectedTripIdList!
                                        .remove(tripIdList![index]);
                                    // tripIdList!.removeAt(index);
                                    selectedTripLabelList!
                                        .remove(children![index]);
                                  }
                                  manageTristate(index, value);
                                },
                                checkboxType: CheckboxType.Child,
                                activeColor: Colors.indigo,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(circularProgressColor),
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
