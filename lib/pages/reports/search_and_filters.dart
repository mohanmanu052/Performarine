import 'dart:async';
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

  int? _key;
  int? newKey;
  late CommonProvider commonProvider;
  bool? isSHowGraph = false;
  bool? isExpansionCollapse = false;
  String? selectedVessel;
  String? selectedVesselName = "";
  int _selectedOption = 1;
  DateTime selectedDateForStartDate = DateTime.now();
  DateTime selectedDateForEndDate = DateTime.now();
  DateTime? selectedStartDateFromCal;
  DateTime? selectedEndDateFromCal;
  DateTime focusedDay = DateTime.now();
  String? focusedDayString = "";
  DateTime firstDate = DateTime(1980);
  DateTime lastDate = DateTime.now();
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

  String selectedButton = 'trip duration';
  int? selectedCaseType = 1;
  int? selectDateOption;

  List<Map<String, dynamic>> tripList = [];
  List<TripModel> triSpeedList = [];
  double? avgSpeed = 0.0;
  dynamic avgDuration = 0;
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

  List<DropdownItem> vesselData = [];

  bool? isVesselDataLoading = false;

  List<String>? selectedTripIdList = [];

  bool? isTripIdListLoading = false;

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
  String? pickStartDate = "Start Date";
  String? pickEndDate = "End Date";

  List<TripModel> durationGraphData = [];
  double chartWidth = 0.0;

  dynamic duration1;
  double? avgSpeed1 = 0.0;
  double? fuelUsage = 0.0;
  double? powerUsage = 0.0;
  bool isVesselsFound = false;

  //Convertion of date time into year-month-day format
  String convertIntoYearMonthDay(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);
    print(dateString);
    return dateString;
  }

  //Convertion of date time into month/day/year format
  String convertIntoMonthDayYear(DateTime date) {
    String dateString = DateFormat('MM/dd/yyyy').format(date);
    print(dateString);
    return dateString;
  }

  //Convertion of date time into year-month-day format
  String convertIntoYearMonthDayToShow(DateTime date) {
    String dateString = DateFormat('MM-dd-yyyy').format(date);
    print(dateString);
    return dateString;
  }


  //Manage tri state on selectin trip from trip by id
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

//To select all trips from trip list on trip by id
  void _checkAll(bool value) {
    setState(() {
      parentValue = value;

      for (int i = 0; i < children!.length; i++) {
        childrenValue![i] = value;
      }
    });
  }


  //To get all trip details based on vessel Id
  getTripListData(String vesselID) async {
    try {
      commonProvider
          .tripListData(
              vesselID, context, commonProvider.loginModel!.token!, scaffoldKey)
          .then((value) {
        if (value != null) {
          setState(() {
            isTripIdListLoading = true;
          });
          print("value of trip list: ${value.data}");
          //debugger();
          tripIdList!.clear();
          dateTimeList!.clear();
          for (int i = 0; i < value.data!.length; i++) {
            tripIdList!.add(value.data![i].id!);
            if (value.data![i].createdAt != null) {
              dateTimeList!.add(tripDate(value.data![i].createdAt.toString()));
            }
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
          isTripIdListLoading = true;
        });
      });
    } catch (e) {
      setState(() {
        isTripIdListLoading = false;
      });
      print("issue while getting trip list data: $e");
    }
  }

  //To get all vessels while enter into report screen
  getVesselAndTripsData() async {
    try {
      bool check = await Utils().check(scaffoldKey);
      if (check) {
        setState(() {
          isVesselDataLoading = false;
        });
        commonProvider
            .getUserConfigData(context, commonProvider.loginModel!.userId!,
                commonProvider.loginModel!.token!, scaffoldKey)
            .then((value) {
          print("value is: ${value!.status}");
          if (value != null) {
            print("value 1 is: ${value.status}");
            setState(() {
              isVesselDataLoading = true;
            });
            print("value of get user config by id: ${value.vessels}");
            if(value.vessels!.length == 0){
              isVesselsFound = true;
            }
            vesselData = List<DropdownItem>.from(value.vessels!.map(
                (vessel) => DropdownItem(id: vessel.id, name: vessel.name)));

            print("vesselData: ${vesselData.length}");
          } else {
            setState(() {
              isVesselDataLoading = true;
            });
          }
        }).catchError((e) {
          setState(() {
            isVesselDataLoading = true;
          });
        });
      } else {
        setState(() {
          isVesselDataLoading = true;
        });
      }
    } catch (e) {
      setState(() {
        isVesselDataLoading = true;
      });
      print("Error while fetching data from getUserConfigById: $e");
    }
  }

  //To collapse expansion tile on reports page
  collapseExpansionTileKey() {
    do {
      _key = new Random().nextInt(100);
    } while (newKey == _key);
  }

  //To show date on trips list on filter by trip
  String tripDate(String date) {
    String inputDate = date;
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('MM-dd-yyyy').format(dateTime);
    return formattedDate;
  }

  //Get reports data api to get all details about reports
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
            });
          } else if (!isCheckInternalServer! && value.statusCode == 200) {
            if (mounted) {
              setState(() {
                isReportDataLoading = true;
                isBtnClick = false;
                triSpeedList.clear();

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
                    ? durationWithMilli3(
                        value.data?.avgInfo?.avgDuration ?? '0:0:0.0')
                    : durationWithSeconds(
                        value.data!.avgInfo!.avgDuration ?? '0:0:0');
            avgDuration = myAvgDuration ?? 0;

            avgFuelConsumption = value.data?.avgInfo?.avgFuelConsumption;
            avgPower = value.data?.avgInfo?.avgPower ?? 0.0;
            print(
                "duration: $avgDuration, avgPower : $avgPower, avgFuelConsumption: $avgFuelConsumption, avgSpeed: $avgSpeed");
            triSpeedList = List<TripModel>.from(value.data!.trips!.map(
                (tripData) => TripModel(
                    date: tripData.date, tripsByDate: tripData.tripsByDate)));

            durationGraphData = triSpeedList;
            if (triSpeedList.length <= 1) {
              chartWidth = displayWidth(context) * 1;
            } else if (triSpeedList.length <= 2) {
              chartWidth = displayWidth(context);
            } else if (triSpeedList.length < 5) {
              chartWidth = displayHeight(context) * 0.5;
            } else if (triSpeedList.length < 10) {
              chartWidth = displayHeight(context) * 1;
            } else if (triSpeedList.length > 10) {
              chartWidth = displayHeight(context) * 4;
            } else if (triSpeedList.length > 20) {
              chartWidth = displayHeight(context) * 7;
            }
            Utils.customPrint('list total data : ${durationGraphData}');

            for (int i = 0; i < durationGraphData.length; i++) {
              for (int j = 0;
                  j < durationGraphData[i].tripsByDate!.length;
                  j++) {
                print(
                    "trip duration data is: ${durationGraphData[i].tripsByDate![j].id}");
                if (duration(triSpeedList[i].tripsByDate![j].duration!) > 0) {
                  durationColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    color: circularProgressColor,
                    // pointColorMapper: barsColor,
                    width: 0.4,
                    enableTooltip: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        durationWithSeconds(
                                    triSpeedList[i].tripsByDate![j].duration!) >
                                0
                            ? triSpeedList[i].date
                            : null,
                    yValueMapper: (TripModel tripData, _) =>
                        durationWithSeconds(
                                    triSpeedList[i].tripsByDate![j].duration!) >
                                0
                            ? durationWithSeconds(
                                triSpeedList[i].tripsByDate![j].duration!)
                            : null,
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                        // setState(() async {
                        selectedIndex = triSpeedList[i].tripsByDate![j].id!;
                        print("selected index: $selectedIndex");
                        // });
                      }
                    },
                    name: 'Trip Duration',
                    emptyPointSettings:
                        EmptyPointSettings(mode: EmptyPointMode.drop),
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }
                if (triSpeedList[i].tripsByDate![j].avgSpeed! > 0) {
                  avgSpeedColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    color: circularProgressColor,
                    dataSource: triSpeedList,
                    width: 0.4,
                    enableTooltip: true,
                    xValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].date,
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].avgSpeed! > 0
                            ? triSpeedList[i].tripsByDate![j].avgSpeed!
                            : null,
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                        // setState(() async {
                        selectedIndex = triSpeedList[i].tripsByDate![j].id!;
                        print("selected index: $selectedIndex");
                        // });
                      }
                    },
                    name: 'Avg Speed',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }

                if (triSpeedList[i].tripsByDate![j].fuelConsumption! > 0) {
                  fuelUsageColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    color: circularProgressColor,
                    width: 0.4,
                    enableTooltip: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].date,
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].fuelConsumption! > 0
                            ? triSpeedList[i].tripsByDate![j].fuelConsumption!
                            : null,
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                        setState(() async {
                          selectedIndex =
                              await triSpeedList[i].tripsByDate![j].id!;
                          print("selected index: $selectedIndex");
                        });
                      }
                    },
                    name: 'Fuel Usage',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }

                if (triSpeedList[i].tripsByDate![j].avgPower! > 0) {
                  powerUsageColumnSeriesData
                      .add(ColumnSeries<TripModel, String>(
                    color: circularProgressColor,
                    width: 0.4,
                    enableTooltip: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].date,
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].avgPower! > 0
                            ? triSpeedList[i].tripsByDate![j].avgPower!
                            : null,
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        // await updateTripId(triSpeedList[i].tripsByDate![j].id!);
                        setState(() async {
                          selectedIndex =
                              await triSpeedList[i].tripsByDate![j].id!;
                          print("selected index: $selectedIndex");
                        });
                      }
                    },
                    name: 'Power Usage',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.1,
                  ));
                }
              }
            }
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
            duration1 = durationWithMilli(
                value.data?.avgInfo?.avgDuration ?? '0:0:0.0');
            avgSpeed1 = value.data?.avgInfo?.avgSpeed ?? 0.0;
            fuelUsage = value.data?.avgInfo?.avgFuelConsumption ?? 0.0;
            powerUsage = value.data?.avgInfo?.avgPower ?? 0.0;
            print(
                "duration: $duration1,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage  ");

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
  }

  //It returns total minutes along with seconds
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

  //Returns duration with seconds
  dynamic durationWithSeconds(String duration) {
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

  //Returns trip duration on tap of column bar in Avg Duration tab
  dynamic tripDuration(String tripDuration) {
    print("DDDDD: $tripDuration");
    String inputDuration = tripDuration;
    String formattedDuration = "";
    List<String> parts = inputDuration.split(".");

    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1].length > 1 ? parts[1] : '${parts[1]}0');

    int hours = minutes ~/ 60;
    minutes = minutes % 60;

    Duration duration =
        Duration(hours: hours, minutes: minutes, seconds: seconds);
    print("duration: $duration");
    formattedDuration = formatDurations(duration);
// formattedDuration = duration.toString().split(".")[0];

    print(formattedDuration);
    return formattedDuration;
  }

  //To get format of HH:mm:ss
  String formatDurations(Duration duration) {
    final formatter = DateFormat('HH:mm:ss');
    final formattedTime = formatter.format(DateTime(0, 1, 1).add(duration));
    return formattedTime;
  }

  //returns duration with milli seconds
  dynamic durationWithMilli3(String timeString) {
    String time = timeString;
    Duration duration = Duration(
      hours: int.parse(time.split(':')[0]),
      minutes: int.parse(timeString.split(':')[1]),
      seconds: int.parse(timeString.split(':')[2].split('.')[0]),
      milliseconds: int.parse(timeString.split(':')[2].split('.')[1]),
    );
    int durationInMinutes = duration.inMinutes;
    return double.parse(
        "${durationInMinutes}.${int.parse(timeString.split(':')[2].split('.')[0])}");
  }

  //Returns date time along with zero like 2023-03-03 instead of 2023-3-3
  dynamic dateWithZeros(String timesString) {
    String dateString = timesString;
    List<String> dateParts = dateString.split('-'); // ['3', '3', '2023']
    String day = dateParts[0].padLeft(2, '0'); // '03'
    String month = dateParts[1].padLeft(2, '0'); // '03'
    String year = dateParts[2]; // '2023'
    String formattedDate = '$day-$month-$year'; // '2023-03-03'
    return formattedDate;
  }

  //Duration with milli seconds
  dynamic durationWithMilli(String timesString) {
    String time = timesString;
    print('TIME STRING: $timesString');
    String timeString = time;
    String integerTimeString = timeString.split('.')[0];
    return integerTimeString;
  }

  @override
  void initState() {
    super.initState();
    commonProvider = context.read<CommonProvider>();
    parentValue = false;
    isTripIdListLoading = true;
    isExpansionCollapse = true;
    Future.delayed(Duration.zero, () {
      getVesselAndTripsData();
    });

    selectedTripsAndDateString = "Date Range";

    tripDurationButtonColor = true;
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: commonBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff2fffb),
        centerTitle: true,
        title: Text(
          "Reports",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    ModalRoute.withName(""));
              },
              icon: Image.asset('assets/images/home.png'),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
      body: !isVesselsFound ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        trailing: isExpandedTile
                            ? Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                              )
                            : Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.black,
                              ),
                        children: [
                          isVesselDataLoading!
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
                                        contentPadding: const EdgeInsets.all(3),
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
                                            fontSize:
                                                displayWidth(context) * 0.025),
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
                                            dropdownColor:
                                                Theme.of(context).brightness ==
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
                                      selectedTripsAndDateString = "Date Range";
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
                                      isSHowGraph = false;
                                      isBtnClick = true;
                                      isExpansionCollapse = false;
                                      isExpandedTile = true;
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
                                    String? startDateToDispaly = "";
                                    String? endDateToDispaly = "";
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
                                        startDateToDispaly =
                                            convertIntoYearMonthDayToShow(
                                                selectedDateForStartDate);
                                        endDateToDispaly =
                                            convertIntoYearMonthDayToShow(
                                                selectedDateForEndDate);
                                        selectedTripsAndDateDetails =
                                            "$startDateToDispaly to $endDateToDispaly";
                                      }

                                      if ((selectedStartDateFromCal != null &&
                                              selectedEndDateFromCal != null) &&
                                          selectedDateForEndDate!.isBefore(
                                              selectedDateForStartDate)) {
                                        isBtnClick = false;
                                        setState(() {
                                          isSelectedStartDay = false;
                                          isSelectedEndDay = false;
                                        });
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'End date ($endDate) should be greater than start date($startDate)',
                                            duration: 2);
                                        return;
                                      }
                                      if ((isSelectedStartDay! &&
                                          isSelectedEndDay!)) {
                                        getReportsData(selectedCaseType!,
                                            startDate: startDate,
                                            endDate: endDate,
                                            vesselID: selectedVessel);
                                      } else if (!isSelectedStartDay!) {
                                        setState(() {
                                          isBtnClick = false;
                                        });
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'Please select the start date',
                                            duration: 2);
                                      } else if (!isSelectedEndDay!) {
                                        setState(() {
                                          isBtnClick = false;
                                        });
                                        Utils.showSnackBar(context,
                                            scaffoldKey: scaffoldKey,
                                            message:
                                                'Please select the end date',
                                            duration: 2);
                                      }
                                    } else if (selectedCaseType == 2) {
                                      if (selectedTripIdList?.isNotEmpty ??
                                          false) {
                                        selectedTripLabelList!.sort((a, b) {
                                          int numberA =
                                              int.parse(a.split(" ")[1]);
                                          int numberB =
                                              int.parse(b.split(" ")[1]);
                                          return numberA.compareTo(numberB);
                                        });
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
                                            width: displayWidth(context) * 0.05,
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
                                                tripDurationButtonColor = true;
                                                avgSpeedButtonColor = false;
                                                fuelUsageButtonColor = false;
                                                powerUsageButtonColor = false;
                                              });
                                            },
                                            child: Container(
                                              //  color: dateBackgroundColor,
                                              width:
                                                  displayWidth(context) * 0.21,
                                              height:
                                                  displayWidth(context) * 0.09,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                : Colors.black,
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
                                                tripDurationButtonColor = false;
                                                avgSpeedButtonColor = true;
                                                fuelUsageButtonColor = false;
                                                powerUsageButtonColor = false;
                                              });
                                            },
                                            child: Container(
                                              //  color: dateBackgroundColor,
                                              width:
                                                  displayWidth(context) * 0.19,
                                              height:
                                                  displayWidth(context) * 0.09,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                : Colors.black,
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
                                                tripDurationButtonColor = false;
                                                avgSpeedButtonColor = false;
                                                fuelUsageButtonColor = true;
                                                powerUsageButtonColor = false;
                                              });
                                            },
                                            child: Container(
                                              //  color: dateBackgroundColor,
                                              width:
                                                  displayWidth(context) * 0.20,
                                              height:
                                                  displayWidth(context) * 0.09,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: !fuelUsageButtonColor!
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
                                                                : Colors.black,
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
                                                selectedButton = 'power usage';
                                                tripDurationButtonColor = false;
                                                avgSpeedButtonColor = false;
                                                fuelUsageButtonColor = false;
                                                powerUsageButtonColor = true;
                                              });
                                            },
                                            child: Container(
                                              //  color: dateBackgroundColor,
                                              width:
                                                  displayWidth(context) * 0.22,
                                              height:
                                                  displayWidth(context) * 0.09,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: !powerUsageButtonColor!
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
                                                                : Colors.black,
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
                                ),
                                isReportDataLoading!
                                    ? buildGraph(context)
                                    : Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  circularProgressColor),
                                        ),
                                      ),
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
      ) : Center(
        child: Container(
          child: commonText(
              text: 'No Data Available!',
              textSize: displayWidth(context) * 0.04,
              textColor: primaryColor),
        ),
      ),
    );
  }

  //Table which we are showing in reports page
  Widget? table(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: DataTable(
          columnSpacing: displayWidth(context) * 0.07,
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
            DataColumn(label: _verticalDivider),
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
                  DataCell(_verticalDivider),
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
                  DataCell(_verticalDivider),
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
        ),
      ),
    );
  }

  //Vertical divider in table
  Widget _verticalDivider = const VerticalDivider(
    color: dividerColor,
    thickness: 1,
  );

  //Custom selection graph
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

  //Trip duration graph
  Widget tripDurationGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: commonBackgroundColor,
      borderWidth: 1,
      activationMode: ActivationMode.singleTap,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final String yValue = currentPoint.y.toString();
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
              Row(
                children: [
                  Text(
                    series.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(' (HH:MM:SS)',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      )),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text("${tripDuration(yValue)}",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )),
                  TextButton(
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
                  )
                ],
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: durationColumnSeriesData.length > 3
            ? (1.5 * 100 * durationColumnSeriesData.length)
            : displayWidth(context),
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          //tooltipBehavior: CustomTooltipBehavior(),
          // palette: barsColor,
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

  // Average speed graph in reports
  Widget avgSpeedGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: commonBackgroundColor,
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
              TextButton(
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
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      //physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: avgSpeedColumnSeriesData.length > 3
            ? (1.5 * 100 * avgSpeedColumnSeriesData.length)
            : displayWidth(context),
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          // palette: barsColor,
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

  // Fuel usage graph on reports
  Widget fuelUsageGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: commonBackgroundColor,
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
              TextButton(
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
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: fuelUsageColumnSeriesData.length > 3
            ? (1.5 * 100 * fuelUsageColumnSeriesData.length)
            : displayWidth(context),
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          //palette: barsColor,
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

  // Power usage graph on reports
  Widget powerUsageGraph(BuildContext context) {
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: commonBackgroundColor,
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
              TextButton(
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
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      // physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: powerUsageColumnSeriesData.length > 3
            ? (1.5 * 100 * powerUsageColumnSeriesData.length)
            : displayWidth(context),
        height: displayHeight(context) * 0.4,
        child: SfCartesianChart(
          // palette: barsColor,
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

  // Widget for filter by date in reports
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
                    width: displayWidth(context) * 0.385,
                    height: displayWidth(context) * 0.14,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: dateBackgroundColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.05,
                          right: displayWidth(context) * 0.05),
                      child: Row(
                        children: [
                          Text(
                            pickStartDate!,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: displayWidth(context) * 0.02,
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          )
                        ],
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
                    width: displayWidth(context) * 0.385,
                    height: displayWidth(context) * 0.14,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: dateBackgroundColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.05,
                          right: displayWidth(context) * 0.05),
                      child: Row(
                        children: [
                          Text(
                            pickEndDate!,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: displayWidth(context) * 0.02,
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                          pickStartDate = convertIntoMonthDayYear(selectDay);
                          selectedStartDateFromCal = selectDay;
                          print("pick start date: $pickStartDate");
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
                              pickEndDate = convertIntoMonthDayYear(selectDay);
                              selectedEndDateFromCal = selectDay;
                              print("pick end date: $pickEndDate");
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

  //Filter by trip in reports
  Widget? filterByTrip(BuildContext context) {
    return isTripIdListLoading!
        ? Column(
            children: [

              tripIdList!.length == 0
                  ? Container(
                      child: commonText(
                          text: 'No Trips available',
                          textSize: displayWidth(context) * 0.030,
                          textColor: primaryColor))
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
                              if (value) {
                                print("select all status: $value");
                                // Checked/Unchecked
                                //selectedTripIdList = tripIdList;
                                selectedTripIdList!.addAll(tripIdList!);
                                selectedTripLabelList!.clear();
                                selectedTripLabelList!.addAll(children!);
                                Utils.customPrint(
                                    "selected trip label list: ${selectedTripLabelList}");
                                _checkAll(value);
                              } else if (!value) {
                                // Tristate
                                selectedTripIdList!.clear();
                                selectedTripLabelList!.clear();
                                _checkAll(false);
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
                              Divider(
                                height: 0,
                                thickness: 0.5,
                                color: dividerColor,
                              ),
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
                                    Utils.customPrint(
                                        "selected trip label list: ${selectedTripLabelList}");
                                  } else {
                                    selectedTripIdList!
                                        .remove(tripIdList![index]);
                                    // tripIdList!.removeAt(index);
                                    selectedTripLabelList!
                                        .remove(children![index]);
                                    Utils.customPrint(
                                        "selected trip label list: ${selectedTripLabelList}");
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

class DropdownItem {
  final String? id;
  final String? name;

  DropdownItem({this.id, this.name});
}
