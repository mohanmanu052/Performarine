import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:performarine/models/fleet_list_model.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/new_trip_analytics_screen.dart';
import 'package:performarine/pages/reports_module/widgets/reports_datatable.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

//import 'package:performarine/sync_chart/lib/charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/constants.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../common_widgets/widgets/user_feed_back.dart';
import '../../models/reports_model.dart';
import '../../provider/common_provider.dart';

class ReportsModule extends StatefulWidget {
  ReportsModule(
      {super.key, this.onScreenShotCaptureCallback, this.isTypeFleet = false});

  VoidCallback? onScreenShotCaptureCallback;
  bool? isTypeFleet;

  @override
  State<ReportsModule> createState() => _ReportsModuleState();
}

class _ReportsModuleState extends State<ReportsModule>
    with WidgetsBindingObserver {
  String page = "Reports_module";
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GlobalKey<SfCartesianChartState> dration_barchart_key = GlobalKey();
  Function(dynamic args)? ponitTapCallBackArgs;
  final _formKey = GlobalKey<FormState>();
  final controller = ScreenshotController();
  late CommonProvider commonProvider;
  int? _key, newKey;
  List<DropdownItem> vesselData = [];
  List<String> filters = ["Filter by Date", "Filter by Trips"];
  DropdownItem? selectedValue;
  DropdownItem? selectedFleet;
  String? selectedFilter;
  DateTime selectedDateForStartDate = DateTime.now();
  DateTime selectedDateForEndDate = DateTime.now();
  String? pickStartDate = "Start Date";
  String? pickEndDate = "End Date";
  DateTime firstDate = DateTime(1980);
  DateTime lastDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  String? focusedDayString = "";
  String? lastFocusedDayString = "";
  DateTime? selectedStartDateFromCal;
  DateTime? selectedEndDateFromCal;
  DateTime lastDayFocused = DateTime.now();
  List<String>? tripIdList = [];
  List<String>? selectedTripIdList = [];
  List<String>? selectedTripLabelList = [];
  List<String>? children = [];
  List<bool>? childrenValue = [];
  List<String>? dateTimeList = [];
  List<String>? distanceList = [];
  List<String>? timeList = [];
  List<DropdownItem>? fleetList = [
    DropdownItem(id: '123', name: 'Fleet1'),
    DropdownItem(id: '1233', name: 'Fleet2'),
    DropdownItem(id: '124', name: 'Fleet3'),
    DropdownItem(id: '125', name: 'Fleet4'),
  ];
  String? selectedTripsAndDateDetails = "";
  int? selectedCaseType = 0;
  int? selectDateOption;
  String? selectedVessel;
  String? selectedVesselName = "";
  String? selectedTripsAndDateString = "";
  String selectedButton = 'trip duration';
  String selectedIndex = "";
  final List<ChartSeries> durationColumnSeriesData = [];
  final List<ChartSeries> tempDurationColumnSeriesData = [];
  final List<ChartSeries> avgSpeedColumnSeriesData = [];
  final List<ChartSeries> tempAvgSpeedColumnSeriesData = [];
  final List<ChartSeries> fuelUsageColumnSeriesData = [];
  final List<ChartSeries> tempFuelUsageColumnSeriesData = [];
  final List<ChartSeries> powerUsageColumnSeriesData = [];
  final List<ChartSeries> tempPowerUsageColumnSeriesData = [];
  GlobalKey<ReportsDataTableState> reportsDataTableKey = GlobalKey();
  ActivationMode tooltipactivationMode = ActivationMode.none;

  double? avgSpeed = 0.0;
  dynamic avgDuration = 0;
  dynamic avgFuelConsumption;
  dynamic avgPower = 0.0;
  dynamic totalDuration = 0;
  dynamic totalSpeed;
  dynamic totalFuelConsumption;
  dynamic totalAvgPower;
  List<Map<String, dynamic>> tripList = [];
  List<TripModel> triSpeedList = [];
  dynamic duration1;
  double? avgSpeed1 = 0.0;
  double? fuelUsage = 0.0;
  double? powerUsage = 0.0;
  List<Map<String, dynamic>> finalData = [];
  List<Map<String, dynamic>> totalData = [];
  List<TripModel> durationGraphData = [];
  double chartWidth = 0.0;
  String? imageUrl;
  int? pointIndex;
  bool? isExpansionCollapse = false;
  bool isExpandedTile = false;
  bool? isStartDate = false;
  bool? isEndDate = false;
  bool? isBtnClick = false;
  bool isSelectStartDate = false;
  bool isSelectEndDate = false;
  bool? isSelectedStartDay = false;
  bool? isSelectedEndDay = false;
  bool? isTripIdListLoading = false;
  bool? parentValue = false;
  bool? isSHowGraph = false;
  bool? isVesselDataLoading = false;
  bool isVesselsFound = false;
  bool? isReportDataLoading = false;
  bool? tripDurationButtonColor = false;
  bool? avgSpeedButtonColor = false;
  bool? fuelUsageButtonColor = false;
  bool? powerUsageButtonColor = false;
  bool? isCheckInternalServer = false, isInterConnectionIsOn = false;
  bool? isTripsAreAvailable = false;
  String? capacity;
  bool? isExportBtnClick = false;
  bool? isStartDateSelected = false;
  bool? isEndDateSected = false;
  String? builtYear;
  String? registerNumber;
  List<Vessels>? vesselList;
  int selectedBarIndex = -1;

  final DatabaseService _databaseService = DatabaseService();

  ScrollController _tripDurationSrollController = ScrollController();
  ScrollController _avgSpeedSrollController = ScrollController();
  ScrollController _fuelUsageSrollController = ScrollController();
  ScrollController _powerUsageSrollController = ScrollController();

  bool isStickyYAxisVisible = false;
  ScrollController _mainScrollController = ScrollController();
  int? selectedRowIndex;
  Color defaultColor = Colors.green; // Default bar color
  Color highlightColor = Colors.blue; // Color to highlight the bar
// List<Color> barColors = List.generate(
//   triSpeedList.length,
//   (index) => Colors.black, // Initialize with a default color
// );
  FleetListModel? fleetdata;
  FleetData? selectedFleetvalue;

  List<Color> barColors = [];

  // Define a list of colors for each bar
  //Map<int, Color> barColors = {};

  TooltipBehavior? tooltipBehaviorDurationGraph;
  TooltipBehavior? powerUsageToolTip;
  TooltipBehavior? avgSpeedToolTip;
  TooltipBehavior? fuelUsageToolTip;

  late StreamSubscription<ConnectivityResult> subscription;

  bool bargraphtooltipBool = false;

  //Convertion of date time into month/day/year format
  String convertIntoMonthDayYear(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    Utils.customPrint(dateString);
    CustomLogger().logWithFile(
        Level.info, "convertIntoMonthDayYear: $dateString -> $page");

    return dateString;
  }

  void getVesselDetails(String id) async {
    if (vesselList != null && vesselList!.isNotEmpty) {
      Vessels? vessel = vesselList!
          .firstWhere((vessel) => vessel.id == id, orElse: () => Vessels());

      CreateVessel? vesselData =
          await _databaseService.getVesselFromVesselID(id);

      imageUrl = vesselData!.imageURLs ?? '';

      setState(() {
        builtYear = vessel.builtYear.toString() ?? '-';
        capacity = vessel.capacity ?? '-';
        registerNumber = vessel.regNumber ?? '-';
      });
    } else {}
  }

  //Convertion of date time into year-month-day format
  String convertIntoYearMonthDay(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    Utils.customPrint(dateString);
    CustomLogger().logWithFile(
        Level.info, "convertIntoYearMonthDay: $dateString -> $page");
    return dateString;
  }

  //Convertion of date time into year-month-day format
  String convertIntoYearMonthDayToShow(DateTime date) {
    String dateString = DateFormat('yyyy-MM-dd').format(date);

    Utils.customPrint(dateString);
    CustomLogger().logWithFile(
        Level.info, "convertIntoYearMonthDayToShow: $dateString -> $page");

    return dateString;
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

  //To collapse expansion tile on reports page
  collapseExpansionTileKey() {
    do {
      _key = new Random().nextInt(100);
    } while (newKey == _key);
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

  //To show date on trips list on filter by trip
  String tripDate(String date) {
    String inputDate = date;
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  //returns duration with milli seconds
  dynamic durationWithMilli3(String timeString) {
    String time = timeString;

    List<String> timeComponents = time.split(":");
    int hours = int.parse(timeComponents[0]);
    int minutes = int.parse(timeComponents[1]);
    double seconds = double.parse(timeComponents[2]);

// Calculate the total minutes

    int totalMinutes = (hours * 60) + minutes;
    return double.parse(
        '$totalMinutes.${seconds.toInt()}'); // Duration duration = Duration(
    //   hours: int.parse(time.split(':')[0]),
    //   minutes: int.parse(timeString.split(':')[1]),
    //   seconds: int.parse(timeString.split(':')[2].split('.')[0]),
    //   milliseconds: int.parse(timeString.split(':')[2].split('.')[1]),
    // );
    // int durationInMinutes = duration.inMinutes;
    // return double.parse(
    //     "${durationInMinutes}.${int.parse(timeString.split(':')[2].split('.')[0])}");
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

    // Utils.customPrint('TOTAL MIN: $totalMinutes');
    CustomLogger().logWithFile(Level.info, "TOTAL MIN: $totalMinutes -> $page");

    return double.parse('$totalMinutes.${parts[2]}');
  }

  //Duration with milli seconds
  dynamic durationWithMilli(String timesString) {
    String time = timesString;

    Utils.customPrint('TIME STRING: $timesString');
    CustomLogger()
        .logWithFile(Level.info, "TIME STRING: $timesString -> $page");

    String timeString = time;
    String integerTimeString = timeString.split('.')[0];
    return integerTimeString;
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

    Utils.customPrint('TOTAL MIN: $totalMinutes');
    CustomLogger().logWithFile(Level.info, "TOTAL MIN: $totalMinutes -> $page");

    return double.parse('$totalMinutes.${parts[2]}');
  }

  //To get all vessels while enter into report screen
  getVesselAndTripsData() async {
    try {
      bool check = await Utils().check(scaffoldKey);
      setState(() {
        isInterConnectionIsOn = check;
      });
      if (check) {
        setState(() {
          isVesselDataLoading = false;
        });
        commonProvider
            .getUserConfigData(context, commonProvider.loginModel!.userId!,
                commonProvider.loginModel!.token!, scaffoldKey,)
            .then((value) {
          Utils.customPrint("value is: ${value!.status}");
          CustomLogger()
              .logWithFile(Level.info, "value is: ${value.status} -> $page");

          Utils.customPrint("value 1 is: ${value.status}");
          setState(() {
            isVesselDataLoading = true;
            vesselList = value.vessels ?? [];
          });

          Utils.customPrint(
              "value of get user config by id: ${value.vessels}");
          CustomLogger().logWithFile(Level.info,
              "value of get user config by id: ${value.vessels} -> $page");

          if (value.vessels!.length == 0) {
            isVesselsFound = true;
          }

          if(widget.isTypeFleet!)
            {
              vesselData = List<DropdownItem>.from(value.vessels!.map(
                      (vessel) => DropdownItem(id: vessel.id, name: vessel.name)));
            }
          else
            {
              vesselData = List<DropdownItem>.from(value.vessels!.where((element) => commonProvider.loginModel!.userId == element.createdBy).toList().map(
                      (vessel) => DropdownItem(id: vessel.id, name: vessel.name)));
            }


          Utils.customPrint("vesselData: ${vesselData.length}");
          CustomLogger().logWithFile(
              Level.info, "vesselData: ${vesselData.length} -> $page");
                }).catchError((e) {
          if (mounted)
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

      Utils.customPrint("Error while fetching data from getUserConfigById: $e");
      CustomLogger().logWithFile(Level.error,
          "Error while fetching data from getUserConfigById: $e -> $page");
    }
  }

//To export the report data
  exportTripData() async {
    isExportBtnClick = true;
    setState(() {});

    Map<String, dynamic> body = {};
    String token = commonProvider.loginModel?.token ?? '';
    if (selectedCaseType == 1) {
      body = {
        "case": 1,
        "vesselID": selectedVessel,
        "startDate": pickStartDate,
        "isExport": true,
        "endDate": pickEndDate,
      };
    } else {
      body = {"case": 2, "isExport": true, "tripIds": selectedTripIdList};
    }

    var data = await commonProvider.exportReportData(
        body, token, context, scaffoldKey);

    setState(() {
      isExportBtnClick = false;
    });
  }

  //To get all trip details based on vessel Id
  getTripListData(String vesselID) async {
    try {
      commonProvider
          .tripListData(
              vesselID, context, commonProvider.loginModel!.token!, scaffoldKey)
          .then((value) {
        setState(() {
          isTripIdListLoading = true;
        });

        Utils.customPrint("value of trip list: ${value.data}");
        CustomLogger().logWithFile(
            Level.info, "value of trip list: ${value.data} -> $page");
        tripIdList!.clear();
        dateTimeList!.clear();
        distanceList!.clear();
        timeList!.clear();
        children!.clear();
        childrenValue!.clear();
        for (int i = 0; i < value.data!.length; i++) {
          isTripsAreAvailable = false;
          tripIdList!.add(value.data![i].id!);
          if (value.data![i].createdAt != null) {
            dateTimeList!.add(tripDate(value.data![i].createdAt.toString()));
            //distanceList!.add(100.222.toStringAsFixed(1));

            distanceList!.add(value.data![i].distance!.toStringAsFixed(1));
            timeList!.add(value.data![i].duration.toString());
          }
          children!.add("Trip ${i.toString()}");
        }
        childrenValue = List.generate(children!.length, (index) => false);

        Utils.customPrint("trip id list: $tripIdList");
        Utils.customPrint("children: ${children}");
        Utils.customPrint("dateTimeList: $dateTimeList");

        CustomLogger()
            .logWithFile(Level.info, "trip id list: $tripIdList -> $page");
        CustomLogger()
            .logWithFile(Level.info, "children: ${children} -> $page");
        CustomLogger()
            .logWithFile(Level.info, "dateTimeList: $dateTimeList -> $page");
            }).catchError((e) {
        setState(() {
          isTripIdListLoading = true;
        });
      });
    } catch (e) {
      setState(() {
        isTripIdListLoading = false;
      });

      Utils.customPrint("issue while getting trip list data: $e");
      CustomLogger().logWithFile(
          Level.error, "issue while getting trip list data: $e -> $page");
    }
  }

  //Get reports data api to get all details about reports
  getReportsData(int caseType,
      {String? startDate,
      String? endDate,
      String? vesselID,
      List<String>? selectedTripListID}) async {
    try {
      isEndDateSected = true;
      setState(() {});
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
                tempDurationColumnSeriesData.clear();
                avgSpeedColumnSeriesData.clear();
                tempAvgSpeedColumnSeriesData.clear();
                fuelUsageColumnSeriesData.clear();
                tempFuelUsageColumnSeriesData.clear();
                powerUsageColumnSeriesData.clear();
                tempPowerUsageColumnSeriesData.clear();
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

            Utils.customPrint(
                "NEW AVG DATA ${value.data?.avgInfo?.avgDuration}");
            CustomLogger().logWithFile(Level.info,
                "NEW AVG DATA ${value.data?.avgInfo?.avgDuration} -> $page");

            avgDuration = myAvgDuration ?? 0;
            print(
                'my avg duration was-------------' + myAvgDuration.toString());

            avgFuelConsumption = value.data?.avgInfo?.avgFuelConsumption;
            avgPower = value.data?.avgInfo?.avgPower ?? 0.0;

            Utils.customPrint(
                "duration: $avgDuration, avgPower : $avgPower, avgFuelConsumption: $avgFuelConsumption, avgSpeed: $avgSpeed");
            CustomLogger().logWithFile(Level.info,
                "duration: $avgDuration, avgPower : $avgPower, avgFuelConsumption: $avgFuelConsumption, avgSpeed: $avgSpeed -> $page");
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
            CustomLogger().logWithFile(
                Level.info, "list total data : ${durationGraphData} -> $page");

            for (int i = 0; i < durationGraphData.length; i++) {
              for (int j = 0;
                  j < durationGraphData[i].tripsByDate!.length;
                  j++) {
                Utils.customPrint(
                    "trip duration data is: ${durationGraphData[i].tripsByDate![j].id}");
                CustomLogger().logWithFile(Level.info,
                    "trip duration data is: ${durationGraphData[i].tripsByDate![j].id} -> $page");
                Utils.customPrint(
                    "selected row index : ${selectedRowIndex.toString()}    ${durationGraphData[i].toString()} ");

                if (duration(triSpeedList[i].tripsByDate![j].duration!) > 0) {
                  durationColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    //  color: durationGraphData[j]==selectedRowIndex?Colors.red:circularProgressColor,
                    width: 0.9,

                    enableTooltip: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, data) {
                      return durationWithSeconds(
                                  triSpeedList[i].tripsByDate![j].duration!) >
                              0
                          ? dateWithZeros(triSpeedList[i].date ?? "")
                          : null;
                    },
                    yValueMapper: (TripModel tripData, data) {
                      pointIndex = data;

                      return durationWithSeconds(
                                  triSpeedList[i].tripsByDate![j].duration!) >
                              0
                          ? durationWithSeconds(
                              triSpeedList[i].tripsByDate![j].duration!)
                          : null;
                    },

//pointColorMapper: (_, __) => barColor,

                    pointColorMapper: (TripModel tripData, int index) {
                      return triSpeedList[i].tripsByDate![j].dataLineColor !=
                              null
                          ? triSpeedList[i].tripsByDate![j].dataLineColor
                          : blueColor;
                    },

                    onPointTap: (ChartPointDetails args) {
                      reportsDataTableKey.currentState!
                          .setSelectedRowIndex(args.seriesIndex!);
                      tooltipactivationMode = ActivationMode.singleTap;

                      for (int i = 0; i < durationGraphData.length; i++) {
                        for (int j = 0;
                            j < durationGraphData[i].tripsByDate!.length;
                            j++) {
                          durationGraphData[i].tripsByDate![j].dataLineColor =
                              null;
                        }
                      }

                      triSpeedList[i].tripsByDate![j].dataLineColor =
                          Colors.green;
                      setState(() {
                        reportsDataTableKey.currentState!.isToolTipShown = true;
                        bargraphtooltipBool = true;
                        tooltipactivationMode = ActivationMode.none;

                        // tooltipBehaviorDurationGraph!.enable=true;
                        // tooltipBehaviorDurationGraph!.activationMode=ActivationMode.singleTap;
                        // tooltipBehaviorDurationGraph!.showByIndex(args.seriesIndex!, args.pointIndex!);
                      });

                      Future.delayed(Duration(milliseconds: 100), () {
                        tooltipBehaviorDurationGraph!
                            .showByIndex(args.seriesIndex!, args.pointIndex!);
                        reportsDataTableKey.currentState!.setState(() {
                          reportsDataTableKey.currentState!.isToolTipShown =
                              false;
                        });
                      });

                      reportsDataTableKey.currentState!.setState(() {
                        reportsDataTableKey.currentState!.selectedRowIndex =
                            args.seriesIndex!;
                      });

                      if (mounted) {
                        selectedIndex = triSpeedList[i].tripsByDate![j].id!;

                        triSpeedList[i].tripsByDate![j].SelectedDataIndex =
                            args.pointIndex;
                        Utils.customPrint("selected index: $selectedIndex");
                        CustomLogger().logWithFile(Level.info,
                            "selected index: $selectedIndex -> $page");
                        selectedBarIndex = args.seriesIndex!;
                      }
                    },
                    name: 'Trip Duration',
                    emptyPointSettings:
                        EmptyPointSettings(mode: EmptyPointMode.drop),
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.2,
                  ));

                  tempDurationColumnSeriesData
                      .add(ColumnSeries<TripModel, String>(
                    width: 0.9,
                    color: Colors.transparent,
                    enableTooltip: true,
                    isVisible: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) => '',
                    yValueMapper: (TripModel tripData, _) =>
                        durationWithSeconds(
                                    triSpeedList[i].tripsByDate![j].duration!) >
                                0
                            ? durationWithSeconds(
                                triSpeedList[i].tripsByDate![j].duration!)
                            : null,
                    pointColorMapper: (TripModel tripData, int index) {
                      return Colors.transparent;
                      //return triSpeedList[i].tripsByDate![j].dataLineColor != null ? triSpeedList[i].tripsByDate![j].dataLineColor : blueColor;
                    },
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        selectedIndex = triSpeedList[i].tripsByDate![j].id!;
                        Utils.customPrint("selected index: $selectedIndex");
                        CustomLogger().logWithFile(Level.info,
                            "selected index: $selectedIndex -> $page");
                      }
                    },
                    name: 'Trip Duration',
                    emptyPointSettings:
                        EmptyPointSettings(mode: EmptyPointMode.drop),
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.2,
                  ));
                }
                ;
                //  if (triSpeedList[i].tripsByDate![j].avgSpeed! > 0) {
                avgSpeedColumnSeriesData.add(ColumnSeries<TripModel, String>(
                  pointColorMapper: (TripModel tripData, int index) {
                    return triSpeedList[i].tripsByDate![j].dataLineColor != null
                        ? triSpeedList[i].tripsByDate![j].dataLineColor
                        : blueColor;
                  },
                  dataSource: triSpeedList,
                  width: 0.9,
                  enableTooltip: true,
                  emptyPointSettings:
                      EmptyPointSettings(mode: EmptyPointMode.drop),
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  spacing: 0.2,

                  xValueMapper: (TripModel tripData, _) =>
                      dateWithZeros(triSpeedList[i].date ?? ""),
                  yValueMapper: (TripModel tripData, _) =>
                      triSpeedList[i].tripsByDate![j].avgSpeed! > 0
                          ? triSpeedList[i].tripsByDate![j].avgSpeed!
                          : null,
                  onPointTap: (ChartPointDetails args) {
                    //  print('the avg column data series length was---')
                    print(
                        'avg column series args point index was---- ${args.pointIndex}     ${args.seriesIndex}');

                    reportsDataTableKey
                        .currentState!.setSelectedRowIndex(args.seriesIndex!);
                    tooltipactivationMode = ActivationMode.singleTap;

                    reportsDataTableKey.currentState!.setState(() {
                      reportsDataTableKey.currentState!.selectedRowIndex =
                          args.seriesIndex!;
                    });

                    for (int i = 0; i < durationGraphData.length; i++) {
                      for (int j = 0;
                          j < durationGraphData[i].tripsByDate!.length;
                          j++) {
                        durationGraphData[i].tripsByDate![j].dataLineColor =
                            null;
                      }
                    }

                    triSpeedList[i].tripsByDate![j].dataLineColor =
                        Colors.green;
                    setState(() {
                      reportsDataTableKey.currentState!.isToolTipShown = true;
                      bargraphtooltipBool = true;
                      tooltipactivationMode = ActivationMode.none;
                    });

                    Future.delayed(Duration(milliseconds: 100), () {
                      avgSpeedToolTip!
                          .showByIndex(args.seriesIndex!, args.pointIndex!);
                      // reportsDataTableKey.currentState!.setState(() {

                      //                                    reportsDataTableKey.currentState!.isToolTipShown=false;
                      //                                    });
                    });

                    if (mounted) {
                      selectedIndex = triSpeedList[i].tripsByDate![j].id!;
                      Utils.customPrint("selected index: $selectedIndex");
                      CustomLogger().logWithFile(Level.info,
                          "selected index: $selectedIndex -> $page");
                    }
                  },
                  name: 'Avg Speed',
                  // dataLabelSettings: DataLabelSettings(isVisible: false),
                  // spacing: 0.1,
                ));

                tempAvgSpeedColumnSeriesData
                    .add(ColumnSeries<TripModel, String>(
                  pointColorMapper: (TripModel tripData, int index) {
                    return Colors.transparent;
                    //return triSpeedList[i].tripsByDate![j].dataLineColor != null ? triSpeedList[i].tripsByDate![j].dataLineColor : blueColor;
                  },
                  dataSource: triSpeedList,
                  width: 0.9,
                  color: Colors.transparent,
                  enableTooltip: true,
                  isVisible: true,
                  xValueMapper: (TripModel tripData, _) => '',
                  yValueMapper: (TripModel tripData, _) =>
                      triSpeedList[i].tripsByDate![j].avgSpeed! > 0
                          ? triSpeedList[i].tripsByDate![j].avgSpeed!
                          : null,
                  onPointTap: (ChartPointDetails args) {
                    if (mounted) {
                      selectedIndex = triSpeedList[i].tripsByDate![j].id!;
                      Utils.customPrint("selected index: $selectedIndex");
                      CustomLogger().logWithFile(Level.info,
                          "selected index: $selectedIndex -> $page");
                    }
                  },
                  name: 'Avg Speed',
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  spacing: 0.2,
                ));
                //   }

                if (triSpeedList[i].tripsByDate![j].fuelConsumption! > 0) {
                  fuelUsageColumnSeriesData.add(ColumnSeries<TripModel, String>(
                    pointColorMapper: (TripModel tripData, int index) {
                      return triSpeedList[i].tripsByDate![j].dataLineColor !=
                              null
                          ? triSpeedList[i].tripsByDate![j].dataLineColor
                          : blueColor;
                    },
                    width: 0.9,
                    enableTooltip: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        dateWithZeros(triSpeedList[i].date ?? ""),
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].fuelConsumption! > 0
                            ? triSpeedList[i].tripsByDate![j].fuelConsumption!
                            : null,
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        setState(() async {
                          selectedIndex =
                              await triSpeedList[i].tripsByDate![j].id!;
                          Utils.customPrint("selected index: $selectedIndex");
                          CustomLogger().logWithFile(Level.info,
                              "selected index: $selectedIndex -> $page");
                        });
                      }
                    },
                    name: 'Fuel Usage',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.2,
                  ));
                }

                if (triSpeedList[i].tripsByDate![j].avgPower! > 0) {
                  powerUsageColumnSeriesData
                      .add(ColumnSeries<TripModel, String>(
                    pointColorMapper: (TripModel tripData, int index) {
                      return triSpeedList[i].tripsByDate![j].dataLineColor !=
                              null
                          ? triSpeedList[i].tripsByDate![j].dataLineColor
                          : blueColor;
                    },
                    width: 0.9,
                    enableTooltip: true,
                    dataSource: triSpeedList,
                    xValueMapper: (TripModel tripData, _) =>
                        dateWithZeros(triSpeedList[i].date ?? ''),
                    yValueMapper: (TripModel tripData, _) =>
                        triSpeedList[i].tripsByDate![j].avgPower! > 0
                            ? triSpeedList[i].tripsByDate![j].avgPower!
                            : null,
                    onPointTap: (ChartPointDetails args) {
                      if (mounted) {
                        setState(() async {
                          selectedIndex =
                              await triSpeedList[i].tripsByDate![j].id!;
                          Utils.customPrint("selected index: $selectedIndex");
                          CustomLogger().logWithFile(Level.info,
                              "selected index: $selectedIndex -> $page");
                        });
                      }
                    },
                    name: 'Power Usage',
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    spacing: 0.2,
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

            Utils.customPrint(
                "length: ${tripList.length}, tripList: $tripList");
            CustomLogger().logWithFile(Level.info,
                "length: ${tripList.length}, tripList: $tripList -> $page");

            duration1 = durationWithMilli(
                value.data?.avgInfo?.avgDuration ?? '0:0:0.0');
            avgSpeed1 = value.data?.avgInfo?.avgSpeed ?? 0.0;
            fuelUsage = value.data?.avgInfo?.avgFuelConsumption ?? 0.0;
            powerUsage = value.data?.avgInfo?.avgPower ?? 0.0;
            Utils.customPrint(
                "duration: $duration1,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage  ");
            CustomLogger().logWithFile(Level.info,
                "duration: $duration1,avgSpeed1: $avgSpeed1,fuelUsage: $fuelUsage,powerUsage: $powerUsage -> $page");

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

      Utils.customPrint("Error while getting data from report api : $e \n $s");
      CustomLogger().logWithFile(Level.error,
          "Error while getting data from report api : $e \n $s -> $page");
    }
  }

  void getFleetDetails() async {
    debugPrint("ISTYPE FLEET ${widget.isTypeFleet}");
    fleetdata = await commonProvider.getFleetListdata(
        token: commonProvider.loginModel!.token,
        scaffoldKey: scaffoldKey,
        context: context,
        isCalledFromSession:  true );

    setState(() {});
  }

  //To get format of HH:mm:ss
  String formatDurations(Duration duration) {
    final formatter = DateFormat('HH:mm:ss');
    final formattedTime = formatter.format(DateTime(0, 1, 1).add(duration));
    return formattedTime;
  }

  //Returns trip duration on tap of column bar in Avg Duration tab
  dynamic tripDuration(String tripDuration) {
    Utils.customPrint("DDDDD: $tripDuration");
    CustomLogger().logWithFile(Level.info, "DDDDD: $tripDuration -> $page");

    String inputDuration = tripDuration;
    String formattedDuration = "";
    List<String> parts = inputDuration.split(".");

    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1].length > 1 ? parts[1] : '${parts[1]}0');

    int hours = minutes ~/ 60;
    minutes = minutes % 60;

    Duration duration =
        Duration(hours: hours, minutes: minutes, seconds: seconds);

    Utils.customPrint("duration: $duration");
    CustomLogger().logWithFile(Level.info, "duration: $duration -> $page");
    formattedDuration = formatDurations(duration);

    Utils.customPrint(formattedDuration);
    CustomLogger().logWithFile(
        Level.info, "formattedDuration: $formattedDuration -> $page");

    return formattedDuration;
  }

  //Returns date time along with zero like 2023-03-03 instead of 2023-3-3
  dynamic dateWithZeros(String timesString) {
    String dateString = timesString;
    List<String> dateParts = dateString.split('-'); // ['3', '3', '2023']
    String day = dateParts[0].padLeft(2, '0'); // '03'
    String month = dateParts[1].padLeft(2, '0'); // '03'
    String year = dateParts[2]; // '2023'
    String formattedDate = '$year-$day-$month'; // '2023-03-03'
    return formattedDate;
  }

  @override
  void initState() {
    // super.initState();
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

    barColors = List.generate(
      tripList.length,
      (index) => Colors.black, // Initialize with a default color
    );
    commonProvider = context.read<CommonProvider>();
    parentValue = false;
    isTripsAreAvailable = true;
    isTripIdListLoading = true;
    isExpansionCollapse = true;
    selectedCaseType = 0;
    selectedTripsAndDateString = "Date Range";
    Future.delayed(Duration.zero, () {
      getVesselAndTripsData();
    });

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
      debugPrint("INTERNET CONNECTION ${Connectivity().onConnectivityChanged}");
      Future.delayed(Duration.zero, () {
        getVesselAndTripsData();
      });
    });
    tripDurationButtonColor = true;
    addListenerToControllers();
    if (widget.isTypeFleet ?? false) {
      getFleetDetails();
    }

    debugPrint("IS TYPE FLEET ${widget.isTypeFleet}");
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    subscription.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes here
    if (state == AppLifecycleState.resumed) {
      // App has resumed from the background
      print("App resumed from background");
    } else if (state == AppLifecycleState.paused) {
      // App is going into the background
      print("App going into the background");
    } else if (state == AppLifecycleState.inactive) {
      print("App is in active");
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    return Scaffold(
        backgroundColor: backgroundColor,
        key: scaffoldKey,
        body: OrientationBuilder(builder: (context, orientation) {
          return SingleChildScrollView(
            controller: _mainScrollController,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: reportTripsListBackColor),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: new Key(_key.toString()),
                        maintainState: true,
                        initiallyExpanded: isExpansionCollapse!,
                        onExpansionChanged: (isExpanded) {
                          setState(() {
                            Utils.customPrint(
                                "isExpansionCollapse : $isExpanded");
                            CustomLogger().logWithFile(Level.info,
                                "isExpansionCollapse : $isExpanded -> $page");

                            isExpansionCollapse = !isExpansionCollapse!;
                            isExpandedTile = !isExpandedTile;
                          });
                        },
                        collapsedBackgroundColor: reportDropdownColor,
                        title: Text(
                          "Search & Filters",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: orientation == Orientation.portrait
                                  ? displayWidth(context) * 0.043
                                  : displayWidth(context) * 0.02,
                              fontFamily: outfit),
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
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (widget.isTypeFleet ?? false)
                                  Container(
                                    alignment: Alignment.center,
                                    // height: orientation==Orientation.landscape?60:60,
                                    width: displayWidth(context) * 0.8,
                                    child:
                                        fleetdata != null &&
                                                fleetdata!.data != null
                                            ? Column(
                                                children: [
                                                  IgnorePointer(
                                                    ignoring:
                                                        isBtnClick ?? false,
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: FormField(
                                                        builder: (state) {
                                                          return DropdownButtonFormField2<
                                                              FleetData>(
                                                            isExpanded: true,
                                                            decoration:
                                                                InputDecoration(
                                                              //errorText: _showDropdownError1 ? 'Select Vessel' : null,

                                                              prefixIcon:
                                                                  Container(
                                                                      width: 50,
                                                                      height: displayHeight(
                                                                              context) *
                                                                          0.02,
                                                                      child: Transform
                                                                          .scale(
                                                                        scale:
                                                                            0.5,
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/vessels.png',
                                                                          height:
                                                                              displayHeight(context) * 0.02,
                                                                        ),
                                                                      )),
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          0,
                                                                      vertical: orientation ==
                                                                              Orientation.portrait
                                                                          ? 10
                                                                          : 13),

                                                              focusedBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width:
                                                                          1.5,
                                                                      color: Colors
                                                                          .transparent),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15))),
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width:
                                                                          1.5,
                                                                      color: Colors
                                                                          .transparent),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15))),
                                                              errorBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width:
                                                                          1.5,
                                                                      color: Colors
                                                                          .red
                                                                          .shade300
                                                                          .withOpacity(
                                                                              0.7)),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15))),
                                                              errorStyle: TextStyle(
                                                                  fontFamily:
                                                                      inter,
                                                                  fontSize: orientation ==
                                                                          Orientation
                                                                              .portrait
                                                                      ? displayWidth(
                                                                              context) *
                                                                          0.025
                                                                      : displayWidth(
                                                                              context) *
                                                                          0.015),
                                                              focusedErrorBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width:
                                                                          1.5,
                                                                      color: Colors
                                                                          .red
                                                                          .shade300
                                                                          .withOpacity(
                                                                              0.7)),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15))),
                                                              fillColor:
                                                                  reportDropdownColor,
                                                              filled: true,
                                                              hintText:
                                                                  "Filter By",

                                                              hintStyle:
                                                                  TextStyle(
                                                                      color: Theme.of(context).brightness ==
                                                                              Brightness
                                                                                  .dark
                                                                          ? "Filter By" ==
                                                                                  'User SubRole'
                                                                              ? Colors
                                                                                  .black54
                                                                              : Colors
                                                                                  .white
                                                                          : Colors
                                                                              .black,
                                                                      fontSize: orientation ==
                                                                              Orientation
                                                                                  .portrait
                                                                          ? displayWidth(context) *
                                                                              0.034
                                                                          : displayWidth(context) *
                                                                              0.015,
                                                                      fontFamily:
                                                                          outfit,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300),
                                                            ),
                                                            hint: Container(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                left: 15,
                                                              ),
                                                              child: Text(
                                                                'Select Fleet *',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize: orientation ==
                                                                            Orientation
                                                                                .portrait
                                                                        ? displayWidth(context) *
                                                                            0.032
                                                                        : displayWidth(context) *
                                                                            0.02,
                                                                    fontFamily:
                                                                        outfit,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            value:
                                                                selectedFleetvalue,
                                                            items: fleetdata!
                                                                .data!
                                                                .map((item) {
                                                              return DropdownMenuItem<
                                                                  FleetData>(
                                                                value: item,
                                                                child:
                                                                    Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .only(
                                                                    left: 15,
                                                                  ),
                                                                  child: Text(
                                                                    item.fleetName!,
                                                                    style: TextStyle(
                                                                        fontSize: orientation == Orientation.portrait ? displayWidth(context) * 0.032 : displayWidth(context) * 0.02,
                                                                        color: Theme.of(context).brightness == Brightness.dark
                                                                            ? "Select Vessel" == 'User SubRole'
                                                                                ? Colors.black
                                                                                : Colors.white
                                                                            : Colors.black,
                                                                        fontWeight: FontWeight.w500),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                            validator: (value) {
                                                              if (value ==
                                                                  null) {
                                                                return 'Select Fleet';
                                                              }
                                                              return null;
                                                            },
                                                            style: TextStyle(
                                                                fontSize: orientation ==
                                                                        Orientation
                                                                            .portrait
                                                                    ? displayWidth(
                                                                            context) *
                                                                        0.032
                                                                    : displayWidth(
                                                                            context) *
                                                                        0.02,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            onChanged: (item) {
                                                              if (item !=
                                                                  null) {
                                                                selectedFleetvalue =
                                                                    item;
                                                                // Remove error for the first dropdown
                                                                _formKey
                                                                    .currentState
                                                                    ?.validate();
                                                                                                                            }
                                                              // getVesselDetails(
                                                              //     item?.id ?? "");
                                                              // Utils.customPrint(
                                                              //     "id is: ${item?.id} ");
                                                              // CustomLogger().logWithFile(
                                                              //     Level.info,
                                                              //     "id is: ${item?.id}-> $page");

                                                              // parentValue = false;
                                                              // selectedVessel = item!.id;
                                                              // selectedVesselName =
                                                              //     item.name;

                                                              // if (mounted) {
                                                              //   setState(() {
                                                              //     isTripIdListLoading =
                                                              //         false;
                                                              //     isSHowGraph = false;
                                                              //     avgSpeed = null;
                                                              //     avgDuration = null;
                                                              //     avgFuelConsumption =
                                                              //         null;
                                                              //     avgPower = null;
                                                              //     triSpeedList.clear();
                                                              //     tripList.clear();
                                                              //     duration1 = null;
                                                              //     avgSpeed1 = null;
                                                              //     fuelUsage = null;
                                                              //     powerUsage = null;
                                                              //     finalData.clear();
                                                              //     durationGraphData
                                                              //         .clear();

                                                              //     durationColumnSeriesData
                                                              //         .clear();
                                                              //     tempDurationColumnSeriesData
                                                              //         .clear();
                                                              //     avgSpeedColumnSeriesData
                                                              //         .clear();
                                                              //     tempAvgSpeedColumnSeriesData
                                                              //         .clear();
                                                              //     fuelUsageColumnSeriesData
                                                              //         .clear();
                                                              //     tempFuelUsageColumnSeriesData
                                                              //         .clear();
                                                              //     powerUsageColumnSeriesData
                                                              //         .clear();
                                                              //     tempPowerUsageColumnSeriesData
                                                              //         .clear();
                                                              //     selectedTripIdList!
                                                              //         .clear();
                                                              //     selectedTripLabelList!
                                                              //         .clear();
                                                              //   });
                                                              // }

                                                              // dateTimeList!.clear();
                                                              // children!.clear();
                                                              // getTripListData(item.id!);
                                                            },
                                                            buttonStyleData:
                                                                ButtonStyleData(
                                                              padding: EdgeInsets.only(
                                                                  right: orientation ==
                                                                          Orientation
                                                                              .portrait
                                                                      ? 0
                                                                      : 10),
                                                            ),
                                                            iconStyleData:
                                                                IconStyleData(
                                                              icon: Icon(
                                                                Icons
                                                                    .keyboard_arrow_down_rounded,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              iconSize: orientation ==
                                                                      Orientation
                                                                          .portrait
                                                                  ? displayHeight(
                                                                          context) *
                                                                      0.035
                                                                  : displayHeight(
                                                                          context) *
                                                                      0.080,
                                                            ),
                                                            dropdownStyleData:
                                                                DropdownStyleData(
                                                              maxHeight: orientation ==
                                                                      Orientation
                                                                          .portrait
                                                                  ? displayHeight(
                                                                          context) *
                                                                      0.25
                                                                  : displayHeight(
                                                                          context) *
                                                                      0.42,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                // color: backgroundColor,
                                                              ),
                                                              offset:
                                                                  const Offset(
                                                                      0, 0),
                                                              scrollbarTheme:
                                                                  ScrollbarThemeData(
                                                                radius:
                                                                    const Radius
                                                                        .circular(
                                                                        20),
                                                                thickness:
                                                                    WidgetStateProperty
                                                                        .all<double>(
                                                                            6),
                                                                thumbVisibility:
                                                                    WidgetStateProperty
                                                                        .all<bool>(
                                                                            true),
                                                              ),
                                                            ),
                                                            menuItemStyleData:
                                                                MenuItemStyleData(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          0),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: blueColor,
                                                ),
                                              ),
                                  ),
                                isVesselDataLoading!
                                    ? InkWell(
                                        onTap: () async {
                                          debugPrint(
                                              "TAP TAP TAP !!!! $isInterConnectionIsOn!");

                                          if (!isInterConnectionIsOn!) {
                                            Utils.showSnackBar(context,
                                                scaffoldKey: scaffoldKey,
                                                message:
                                                    'Please enable your data connection.');
                                          }
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          // height: orientation==Orientation.landscape?60:60,
                                          width: displayWidth(context) * 0.8,
                                          child: IgnorePointer(
                                            ignoring: isBtnClick ?? false,
                                            child: DropdownButtonHideUnderline(
                                              child: FormField(
                                                builder: (state) {
                                                  return DropdownButtonFormField2<
                                                      DropdownItem>(
                                                    isExpanded: true,
                                                    decoration: InputDecoration(
                                                      //errorText: _showDropdownError1 ? 'Select Vessel' : null,

                                                      prefixIcon: Container(
                                                          width: 50,
                                                          height: displayHeight(
                                                                  context) *
                                                              0.02,
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.5,
                                                            child: Image.asset(
                                                              'assets/icons/vessels.png',
                                                              height: displayHeight(
                                                                      context) *
                                                                  0.02,
                                                            ),
                                                          )),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 0,
                                                              vertical: orientation ==
                                                                      Orientation
                                                                          .portrait
                                                                  ? 10
                                                                  : 13),

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
                                                          fontSize: orientation ==
                                                                  Orientation
                                                                      .portrait
                                                              ? displayWidth(
                                                                      context) *
                                                                  0.025
                                                              : displayWidth(
                                                                      context) *
                                                                  0.015),
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
                                                          reportDropdownColor,
                                                      filled: true,
                                                      hintText: "Filter By",

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
                                                          fontSize: orientation ==
                                                                  Orientation
                                                                      .portrait
                                                              ? displayWidth(
                                                                      context) *
                                                                  0.034
                                                              : displayWidth(
                                                                      context) *
                                                                  0.015,
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
                                                      child: Text(
                                                        'Select Vessel *',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: orientation ==
                                                                    Orientation
                                                                        .portrait
                                                                ? displayWidth(
                                                                        context) *
                                                                    0.032
                                                                : displayWidth(
                                                                        context) *
                                                                    0.02,
                                                            fontFamily: outfit,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    value: selectedValue,
                                                    items:
                                                        vesselData.map((item) {
                                                      return DropdownMenuItem<
                                                          DropdownItem>(
                                                        value: item,
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: 15,
                                                          ),
                                                          child: Text(
                                                            item.name!,
                                                            style: TextStyle(
                                                                fontSize: orientation ==
                                                                        Orientation
                                                                            .portrait
                                                                    ? displayWidth(
                                                                            context) *
                                                                        0.032
                                                                    : displayWidth(
                                                                            context) *
                                                                        0.02,
                                                                color: Theme.of(context)
                                                                            .brightness ==
                                                                        Brightness
                                                                            .dark
                                                                    ? "Select Vessel" ==
                                                                            'User SubRole'
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .white
                                                                    : Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    validator: (value) {
                                                      if (value == null) {
                                                        return 'Select Vessel';
                                                      }
                                                      return null;
                                                    },
                                                    style: TextStyle(
                                                        fontSize: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? displayWidth(
                                                                    context) *
                                                                0.032
                                                            : displayWidth(
                                                                    context) *
                                                                0.02,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    onChanged: (item) {
                                                      if (item != null) {
                                                        // Remove error for the first dropdown
                                                        _formKey.currentState
                                                            ?.validate();
                                                                                                            }
                                                      getVesselDetails(
                                                          item?.id ?? "");
                                                      Utils.customPrint(
                                                          "id is: ${item?.id} ");
                                                      CustomLogger().logWithFile(
                                                          Level.info,
                                                          "id is: ${item?.id}-> $page");

                                                      parentValue = false;
                                                      selectedVessel = item!.id;
                                                      selectedVesselName =
                                                          item.name;

                                                      if (mounted) {
                                                        setState(() {
                                                          isTripIdListLoading =
                                                              false;
                                                          isSHowGraph = false;
                                                          avgSpeed = null;
                                                          avgDuration = null;
                                                          avgFuelConsumption =
                                                              null;
                                                          avgPower = null;
                                                          triSpeedList.clear();
                                                          tripList.clear();
                                                          duration1 = null;
                                                          avgSpeed1 = null;
                                                          fuelUsage = null;
                                                          powerUsage = null;
                                                          finalData.clear();
                                                          durationGraphData
                                                              .clear();

                                                          durationColumnSeriesData
                                                              .clear();
                                                          tempDurationColumnSeriesData
                                                              .clear();
                                                          avgSpeedColumnSeriesData
                                                              .clear();
                                                          tempAvgSpeedColumnSeriesData
                                                              .clear();
                                                          fuelUsageColumnSeriesData
                                                              .clear();
                                                          tempFuelUsageColumnSeriesData
                                                              .clear();
                                                          powerUsageColumnSeriesData
                                                              .clear();
                                                          tempPowerUsageColumnSeriesData
                                                              .clear();
                                                          selectedTripIdList!
                                                              .clear();
                                                          selectedTripLabelList!
                                                              .clear();
                                                        });
                                                      }

                                                      dateTimeList!.clear();
                                                      children!.clear();
                                                      getTripListData(item.id!);
                                                    },
                                                    buttonStyleData:
                                                        ButtonStyleData(
                                                      padding: EdgeInsets.only(
                                                          right: orientation ==
                                                                  Orientation
                                                                      .portrait
                                                              ? 0
                                                              : 10),
                                                    ),
                                                    iconStyleData:
                                                        IconStyleData(
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded,
                                                        color: Colors.black,
                                                      ),
                                                      iconSize: orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? displayHeight(
                                                                  context) *
                                                              0.035
                                                          : displayHeight(
                                                                  context) *
                                                              0.080,
                                                    ),
                                                    dropdownStyleData:
                                                        DropdownStyleData(
                                                      maxHeight: orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? displayHeight(
                                                                  context) *
                                                              0.25
                                                          : displayHeight(
                                                                  context) *
                                                              0.42,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                        // color: backgroundColor,
                                                      ),
                                                      offset:
                                                          const Offset(0, 0),
                                                      scrollbarTheme:
                                                          ScrollbarThemeData(
                                                        radius: const Radius
                                                            .circular(20),
                                                        thickness:
                                                            WidgetStateProperty
                                                                .all<double>(6),
                                                        thumbVisibility:
                                                            WidgetStateProperty
                                                                .all<bool>(
                                                                    true),
                                                      ),
                                                    ),
                                                    menuItemStyleData:
                                                        MenuItemStyleData(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 0),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: displayHeight(context) * 0.1,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    blueColor),
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: orientation == Orientation.portrait
                                      ? displayHeight(context) * 0.018
                                      : displayHeight(context) * 0.050,
                                ),
                                Container(
                                  width: displayWidth(context) * 0.8,
                                  child: IgnorePointer(
                                    ignoring: isBtnClick ?? false,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField2<String>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          // errorText: _showDropdownError2 ? 'Select Filters' : null,

                                          prefixIcon: Container(
                                              height:
                                                  displayHeight(context) * 0.02,
                                              width: 50,
                                              child: Transform.scale(
                                                scale: 0.5,
                                                child: Image.asset(
                                                  'assets/icons/filter_icon.png',
                                                  height:
                                                      displayHeight(context) *
                                                          0.02,
                                                ),
                                              )),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: orientation ==
                                                      Orientation.portrait
                                                  ? 10
                                                  : 15),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.transparent),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.transparent),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.red.shade300
                                                      .withOpacity(0.7)),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          errorStyle: TextStyle(
                                              fontFamily: inter,
                                              fontSize: orientation ==
                                                      Orientation.portrait
                                                  ? displayWidth(context) *
                                                      0.025
                                                  : displayWidth(context) *
                                                      0.015),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1.5,
                                                      color: Colors.red.shade300
                                                          .withOpacity(0.7)),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                          fillColor: reportDropdownColor,
                                          filled: true,
                                          //hintText: "Filter By",
                                          hintStyle: TextStyle(
                                              color: Colors.black,
                                              // color: Theme.of(context).brightness ==
                                              //     Brightness.dark
                                              //     ? "Filter By" == 'User SubRole'
                                              //     ? Colors.black54
                                              //     : Colors.white
                                              //     : Colors.black,
                                              fontSize: orientation ==
                                                      Orientation.portrait
                                                  ? displayWidth(context) *
                                                      0.034
                                                  : displayWidth(context) *
                                                      0.034,
                                              fontFamily: outfit,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        hint: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(left: 15),
                                          child: Text(
                                            'Filter By *',
                                            style: TextStyle(
                                                color: Colors.black,
                                                // color: Theme.of(context)
                                                //     .brightness ==
                                                //     Brightness.dark
                                                //     ? "Filter By" ==
                                                //     'User SubRole'
                                                //     ? Colors.black54
                                                //     : Colors.white
                                                //     : Colors.black54,
                                                fontSize: orientation ==
                                                        Orientation.portrait
                                                    ? displayWidth(context) *
                                                        0.032
                                                    : displayWidth(context) *
                                                        0.02,
                                                fontFamily: outfit,
                                                fontWeight: FontWeight.w400),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        value: selectedFilter,
                                        items: filters.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 15),
                                              child: Text(
                                                item,
                                                style: TextStyle(
                                                    fontSize: orientation ==
                                                            Orientation.portrait
                                                        ? displayWidth(
                                                                context) *
                                                            0.032
                                                        : displayWidth(
                                                                context) *
                                                            0.02,

                                                    // fontSize: displayWidth(context) *
                                                    //     0.0346,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? "Filter by" ==
                                                                'User SubRole'
                                                            ? Colors.black
                                                            : Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Select Filters';
                                          }
                                          return null;
                                        },
                                        onChanged: (item) {
                                          if (item != null) {
                                            // Remove error for the second dropdown
                                            _formKey.currentState?.validate();
                                          }

                                          if (item == "Filter by Date") {
                                            setState(() {
                                              selectedCaseType = 1;
                                              isSHowGraph = false;
                                              Utils.customPrint(
                                                  "selectedCaseType: $selectedCaseType ");
                                              CustomLogger().logWithFile(
                                                  Level.info,
                                                  "selectedCaseType: $selectedCaseType-> $page");
                                              selectedTripsAndDateString =
                                                  "Date Range";
                                            });
                                          } else if (item ==
                                              "Filter by Trips") {
                                            setState(() {
                                              selectedCaseType = 2;
                                              selectedTripsAndDateDetails = "";
                                              isSHowGraph = false;
                                              Utils.customPrint(
                                                  "selectedCaseType: $selectedCaseType ");
                                              CustomLogger().logWithFile(
                                                  Level.info,
                                                  "selectedCaseType: $selectedCaseType-> $page");
                                              selectedTripsAndDateString =
                                                  "Selected Trips";
                                            });
                                          }
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          padding: EdgeInsets.only(
                                              right: orientation ==
                                                      Orientation.portrait
                                                  ? 0
                                                  : 10),
                                        ),
                                        iconStyleData: IconStyleData(
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.black,
                                          ),
                                          iconSize: orientation ==
                                                  Orientation.portrait
                                              ? displayHeight(context) * 0.035
                                              : displayHeight(context) * 0.080,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: orientation ==
                                                  Orientation.portrait
                                              ? displayHeight(context) * 0.25
                                              : displayHeight(context) * 0.42,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            // color: backgroundColor,
                                          ),
                                          offset: const Offset(0, 0),
                                          scrollbarTheme: ScrollbarThemeData(
                                            radius: const Radius.circular(20),
                                            thickness: WidgetStateProperty
                                                .all<double>(6),
                                            thumbVisibility:
                                                WidgetStateProperty.all<bool>(
                                                    true),
                                          ),
                                        ),
                                        menuItemStyleData: MenuItemStyleData(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: displayWidth(context) * 0.04,
                          ),
                          selectedCaseType == 0
                              ? Container()
                              : selectedCaseType == 1
                                  ? filterByDate(context, orientation)!
                                  : filterByTrip(context, orientation)!,
                          SizedBox(
                            height: displayWidth(context) * 0.04,
                          ),
                          isBtnClick ?? false
                              ? Container(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: blueColor,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    CommonButtons.getAcceptButton(
                                      "Generate Report",
                                      context,
                                      blueColor,
                                      () {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            isSHowGraph = false;
                                            isBtnClick = true;
                                            isExpansionCollapse = false;
                                            isExpandedTile = true;
                                            avgSpeed = null;
                                            avgDuration = null;
                                            // isSelectStartDate=false;
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
                                            tempDurationColumnSeriesData
                                                .clear();
                                            avgSpeedColumnSeriesData.clear();
                                            tempAvgSpeedColumnSeriesData
                                                .clear();
                                            fuelUsageColumnSeriesData.clear();
                                            tempFuelUsageColumnSeriesData
                                                .clear();
                                            powerUsageColumnSeriesData.clear();
                                            tempPowerUsageColumnSeriesData
                                                .clear();
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
                                                lastFocusedDayString!
                                                    .isNotEmpty) {
                                              startDate =
                                                  convertIntoYearMonthDay(
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

                                            if ((selectedStartDateFromCal !=
                                                        null &&
                                                    selectedEndDateFromCal !=
                                                        null) &&
                                                selectedDateForEndDate.isBefore(
                                                    selectedDateForStartDate)) {
                                              isBtnClick = false;
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
                                                      'Please Select the Start Date',
                                                  duration: 2);
                                            } else if (!isSelectedEndDay!) {
                                              setState(() {
                                                isBtnClick = false;
                                              });
                                              Utils.showSnackBar(context,
                                                  scaffoldKey: scaffoldKey,
                                                  message:
                                                      'Please Select the End Date',
                                                  duration: 2);
                                            }
                                          } else if (selectedCaseType == 2) {
                                            if (selectedTripIdList
                                                    ?.isNotEmpty ??
                                                false) {
                                              selectedTripLabelList!
                                                  .sort((a, b) {
                                                int numberA =
                                                    int.parse(a.split(" ")[1]);
                                                int numberB =
                                                    int.parse(b.split(" ")[1]);
                                                return numberA
                                                    .compareTo(numberB);
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
                                                        'Please Select the Trip',
                                                    duration: 2);
                                              }
                                            }
                                          }
                                        } else {}
                                      },
                                      orientation == Orientation.portrait
                                          ? displayWidth(context) * 0.8
                                          : displayWidth(context) * 0.4,
                                      orientation == Orientation.portrait
                                          ? displayHeight(context) * 0.06
                                          : displayHeight(context) * 0.15,
                                      Colors.grey.shade400,
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.white,
                                      orientation == Orientation.portrait
                                          ? displayHeight(context) * 0.021
                                          : displayWidth(context) * 0.022,
                                      blueColor,
                                      '',
                                    ),
                                    !isSHowGraph!
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              top: displayWidth(context) * 0.01,
                                            ),
                                            child: GestureDetector(
                                                onTap: widget
                                                    .onScreenShotCaptureCallback,
                                                child: UserFeedback()
                                                    .getUserFeedback(context,
                                                        orientation:
                                                            orientation)),
                                          )
                                        : Container(),
                                  ],
                                ),
                          SizedBox(
                            height: displayWidth(context) * 0.04,
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
                                    left: displayWidth(context) * 0.03,
                                    right: displayWidth(context) * 0.03,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: displayWidth(context) * 0.055,
                                      ),
                                      vesselDetails(context, orientation),
                                      Container(
                                        child: SizedBox(
                                          height: displayWidth(context) * 0.04,
                                        ),
                                      ),
                                      Visibility(
                                        visible: selectedCaseType == 1
                                            ? true
                                            : false,
                                        child: Row(
                                          children: [
                                            Text(
                                              "$selectedTripsAndDateString",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: outfit),
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
                                      ),
                                      SizedBox(
                                        height:
                                            orientation == Orientation.portrait
                                                ? displayWidth(context) * 0.06
                                                : displayWidth(context) * 0.02,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              for (int i = 0;
                                                  i < durationGraphData.length;
                                                  i++) {
                                                for (int j = 0;
                                                    j <
                                                        durationGraphData[i]
                                                            .tripsByDate!
                                                            .length;
                                                    j++) {
                                                  durationGraphData[i]
                                                      .tripsByDate![j]
                                                      .dataLineColor = null;
                                                }
                                              }

                                              reportsDataTableKey.currentState!
                                                  .setState(() {
                                                reportsDataTableKey
                                                    .currentState!
                                                    .selectedRowIndex = -1;

                                                reportsDataTableKey
                                                    .currentState!
                                                    .isToolTipShown = false;
                                              });

                                              setState(() {
                                                selectedButton =
                                                    'trip duration';
                                                isStickyYAxisVisible = false;
                                                tripDurationButtonColor = true;
                                                avgSpeedButtonColor = false;
                                                fuelUsageButtonColor = false;
                                                powerUsageButtonColor = false;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                if (_tripDurationSrollController
                                                    .positions.isNotEmpty) {
                                                  _tripDurationSrollController
                                                      .animateTo(
                                                    0.0,
                                                    duration:
                                                        Duration(seconds: 2),
                                                    curve: Curves.fastOutSlowIn,
                                                  );
                                                }
                                              });
                                            },
                                            child: Container(
                                              width:
                                                  displayWidth(context) * 0.20,
                                              height: orientation ==
                                                      Orientation.portrait
                                                  ? displayHeight(context) *
                                                      0.041
                                                  : displayHeight(context) *
                                                      0.099,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color:
                                                      !tripDurationButtonColor!
                                                          ? reportsNewTabColor
                                                          : Color(0xff2663DB)),
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
                                                        //fontSize: 11,
                                                        fontSize: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? displayWidth(
                                                                    context) *
                                                                0.025
                                                            : displayWidth(
                                                                    context) *
                                                                0.02,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              for (int i = 0;
                                                  i < durationGraphData.length;
                                                  i++) {
                                                for (int j = 0;
                                                    j <
                                                        durationGraphData[i]
                                                            .tripsByDate!
                                                            .length;
                                                    j++) {
                                                  durationGraphData[i]
                                                      .tripsByDate![j]
                                                      .dataLineColor = null;
                                                }
                                              }

                                              reportsDataTableKey.currentState!
                                                  .setState(() {
                                                reportsDataTableKey
                                                    .currentState!
                                                    .selectedRowIndex = -1;

                                                reportsDataTableKey
                                                    .currentState!
                                                    .isToolTipShown = false;
                                              });

                                              setState(() {
                                                selectedButton = 'avg speed';
                                                isStickyYAxisVisible = false;
                                                tripDurationButtonColor = false;
                                                avgSpeedButtonColor = true;
                                                fuelUsageButtonColor = false;
                                                powerUsageButtonColor = false;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                if (_avgSpeedSrollController
                                                    .positions.isNotEmpty) {
                                                  _avgSpeedSrollController
                                                      .animateTo(
                                                    0.0,
                                                    duration:
                                                        Duration(seconds: 2),
                                                    curve: Curves.fastOutSlowIn,
                                                  );
                                                }
                                              });
                                            },
                                            child: Container(
                                              width:
                                                  displayWidth(context) * 0.18,
                                              height: orientation ==
                                                      Orientation.portrait
                                                  ? displayHeight(context) *
                                                      0.041
                                                  : displayHeight(context) *
                                                      0.099,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: !avgSpeedButtonColor!
                                                      ? reportsNewTabColor
                                                      : Color(0xff2663DB)),
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
                                                        fontSize: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? displayWidth(
                                                                    context) *
                                                                0.025
                                                            : displayWidth(
                                                                    context) *
                                                                0.02,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              for (int i = 0;
                                                  i < durationGraphData.length;
                                                  i++) {
                                                for (int j = 0;
                                                    j <
                                                        durationGraphData[i]
                                                            .tripsByDate!
                                                            .length;
                                                    j++) {
                                                  durationGraphData[i]
                                                      .tripsByDate![j]
                                                      .dataLineColor = null;
                                                }
                                              }

                                              reportsDataTableKey.currentState!
                                                  .setState(() {
                                                reportsDataTableKey
                                                    .currentState!
                                                    .selectedRowIndex = -1;

                                                reportsDataTableKey
                                                    .currentState!
                                                    .isToolTipShown = false;
                                              });

                                              setState(() {
                                                selectedButton = 'fuel usage';
                                                isStickyYAxisVisible = false;
                                                tripDurationButtonColor = false;
                                                avgSpeedButtonColor = false;
                                                fuelUsageButtonColor = true;
                                                powerUsageButtonColor = false;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                if (_fuelUsageSrollController
                                                    .positions.isNotEmpty) {
                                                  _fuelUsageSrollController
                                                      .animateTo(
                                                    0.0,
                                                    duration:
                                                        Duration(seconds: 2),
                                                    curve: Curves.fastOutSlowIn,
                                                  );
                                                }
                                              });
                                            },
                                            child: Container(
                                              width:
                                                  displayWidth(context) * 0.20,
                                              height: orientation ==
                                                      Orientation.portrait
                                                  ? displayHeight(context) *
                                                      0.042
                                                  : displayHeight(context) *
                                                      0.099,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: !fuelUsageButtonColor!
                                                      ? reportsNewTabColor
                                                      : Color(0xff2663DB)),
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
                                                        fontSize: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? displayWidth(
                                                                    context) *
                                                                0.025
                                                            : displayWidth(
                                                                    context) *
                                                                0.02,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              for (int i = 0;
                                                  i < durationGraphData.length;
                                                  i++) {
                                                for (int j = 0;
                                                    j <
                                                        durationGraphData[i]
                                                            .tripsByDate!
                                                            .length;
                                                    j++) {
                                                  durationGraphData[i]
                                                      .tripsByDate![j]
                                                      .dataLineColor = null;
                                                }
                                              }

                                              reportsDataTableKey.currentState!
                                                  .setState(() {
                                                reportsDataTableKey
                                                    .currentState!
                                                    .selectedRowIndex = -1;

                                                reportsDataTableKey
                                                    .currentState!
                                                    .isToolTipShown = false;
                                              });

                                              setState(() {
                                                selectedButton = 'power usage';
                                                isStickyYAxisVisible = false;
                                                tripDurationButtonColor = false;
                                                avgSpeedButtonColor = false;
                                                fuelUsageButtonColor = false;
                                                powerUsageButtonColor = true;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                if (_powerUsageSrollController
                                                    .positions.isNotEmpty) {
                                                  _powerUsageSrollController
                                                      .animateTo(
                                                    0.0,
                                                    duration:
                                                        Duration(seconds: 2),
                                                    curve: Curves.fastOutSlowIn,
                                                  );
                                                }
                                              });
                                            },
                                            child: Container(
                                              width:
                                                  displayWidth(context) * 0.22,
                                              height: orientation ==
                                                      Orientation.portrait
                                                  ? displayHeight(context) *
                                                      0.042
                                                  : displayHeight(context) *
                                                      0.099,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: !powerUsageButtonColor!
                                                      ? reportsNewTabColor
                                                      : Color(0xff2663DB)),
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
                                                        fontSize: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? displayWidth(
                                                                    context) *
                                                                0.025
                                                            : displayWidth(
                                                                    context) *
                                                                0.02,
                                                        fontWeight:
                                                            FontWeight.w500),
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
                                    ? buildGraph(context, orientation)
                                    : Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  blueColor),
                                        ),
                                      ),
                                // table(context)!,

                                ReportsDataTable(
                                  tripList: tripList,
                                  finalData: finalData,
                                  onTapCallBack: scorllToParticularPostion,
                                  barIndex: selectedBarIndex,
                                  key: reportsDataTableKey,
                                  orientation: orientation,
                                ),

                                SizedBox(
                                  height: displayWidth(context) * 0.03,
                                ),
                                SizedBox(
                                  height: orientation == Orientation.portrait
                                      ? displayHeight(context) * 0.06
                                      : displayHeight(context) * 0.15,
                                  child: isExportBtnClick ?? false
                                      ? Center(
                                          child: CircularProgressIndicator(
                                          color: blueColor,
                                        ))
                                      : InkWell(
                                          onTap: () {
                                            exportTripData();
                                          },
                                          child: Container(
                                            height: orientation ==
                                                    Orientation.portrait
                                                ? displayHeight(context) * 0.06
                                                : displayHeight(context) * 0.15,
                                            width: orientation ==
                                                    Orientation.portrait
                                                ? displayWidth(context) * 0.8
                                                : displayWidth(context) * 0.4,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: blueColor),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.file_download_outlined,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                                SizedBox(
                                                  width: displayWidth(context) *
                                                      0.01,
                                                ),
                                                commonText(
                                                  context: context,
                                                  text:
                                                      'Export Complete Report',
                                                  fontWeight: FontWeight.w600,
                                                  textColor: Colors.white,
                                                  textSize: orientation ==
                                                          Orientation.portrait
                                                      ? displayWidth(context) *
                                                          0.041
                                                      : displayWidth(context) *
                                                          0.02,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: displayWidth(context) * 0.025,
                                  ),
                                  child: GestureDetector(
                                      onTap: widget.onScreenShotCaptureCallback,
                                      child: UserFeedback().getUserFeedback(
                                          context,
                                          orientation: orientation)),
                                ),
                              ],
                            )
                          : Container(),
                ],
              ),
            ),
          );
        }));
  }

  //Vessel Details in report screen
  Widget vesselDetails(BuildContext context, Orientation orentation) {
    return Container(
      height: orentation == Orientation.portrait
          ? displayHeight(context) * 0.14
          : displayHeight(context) * 0.30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: selectDayBackgroundColor),
      child: Row(
        children: [
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 8, top: 2),
              height: orentation == Orientation.portrait
                  ? displayHeight(context) * 0.1
                  : displayHeight(context) * 0.5,
              width: displayWidth(context) * 0.19,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(imageUrl ?? '')))
                    : DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "assets/images/vessel_default_img.png",
                        )),
              )),
          SizedBox(
            width: displayWidth(context) * 0.04,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: orentation == Orientation.portrait ? 10 : 27),
                width: displayWidth(context) / 2,
                child: Text(
                  "$selectedVesselName",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      fontFamily: poppins),
                ),
              ),
              SizedBox(
                height: displayWidth(context) * 0.013,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Column(
                      children: [
                        // Container(
                        //   alignment: Alignment.center,
                        //   child: Text(
                        //     capacity??'-',
                        // textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w700,
                        //         fontFamily: inter,
                        //         fontSize:orentation==Orientation.portrait? displayWidth(context) * 0.035:displayWidth(context) * 0.025,
                        //         color: blutoothDialogTxtColor),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: displayHeight(context) * 0.008,
                        // ),
                        // Text(
                        //   "Capacity",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       fontFamily: inter,
                        //       fontSize:orentation==Orientation.portrait? displayWidth(context) * 0.026:displayWidth(context) * 0.018,
                        //       color: blutoothDialogTxtColor),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: displayWidth(context) * 0.03,
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          builtYear ?? '-',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: inter,
                              fontSize: orentation == Orientation.portrait
                                  ? displayWidth(context) * 0.035
                                  : displayWidth(context) * 0.02,
                              color: blutoothDialogTxtColor),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.008,
                        ),
                        Text(
                          "Built",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: inter,
                              fontSize: orentation == Orientation.portrait
                                  ? displayWidth(context) * 0.026
                                  : displayWidth(context) * 0.018,
                              color: blutoothDialogTxtColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: displayWidth(context) * 0.03,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        registerNumber == null
                            ? '-'
                            : registerNumber!.isEmpty
                                ? '-'
                                : registerNumber.toString(),

                        // registerNumber==null&&  registerNumber!.isEmpty?'-' : registerNumber!,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: inter,
                            fontSize: orentation == Orientation.portrait
                                ? displayWidth(context) * 0.035
                                : displayWidth(context) * 0.02,
                            color: blutoothDialogTxtColor),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.008,
                      ),
                      Text(
                        "Registration Number",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: inter,
                            fontSize: orentation == Orientation.portrait
                                ? displayWidth(context) * 0.026
                                : displayWidth(context) * 0.018,
                            color: blutoothDialogTxtColor),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  //Custom selection graph
  buildGraph(BuildContext context, Orientation orientation) {
    double graph_height = orientation == Orientation.portrait
        ? displayHeight(context) * 0.4
        : displayHeight(context) * 0.95;

    Utils.customPrint('SELECTED BUTTON Text $selectedButton');
    CustomLogger().logWithFile(
        Level.info, "SELECTED BUTTON Text $selectedButton -> $page");

    switch (selectedButton.toLowerCase()) {
      case 'trip duration':
        return tripDurationGraph(context, graph_height, orientation);
      case 'avg speed':
        return avgSpeedGraph(context, graph_height, orientation);
      case 'fuel usage':
        return fuelUsageGraph(context, graph_height, orientation);
      case 'power usage':
        return powerUsageGraph(context, graph_height, orientation);
      default:
        return Container();
    }
  }

  //Trip duration graph
  Widget tripDurationGraph(
      BuildContext context, double graph_height, Orientation orientation) {
    tooltipBehaviorDurationGraph = TooltipBehavior(
      enable: reportsDataTableKey.currentState?.isToolTipShown,
      activationMode: reportsDataTableKey.currentState?.isToolTipShown == null
          ? ActivationMode.singleTap
          : tooltipactivationMode,
      shouldAlwaysShow: true,
      color: commonBackgroundColor,
      borderWidth: 1,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final String yValue = currentPoint.y.toString();
        return Container(
          width: orientation == Orientation.portrait
              ? displayWidth(context) * 0.4
              : displayWidth(context) / 4.2,
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
                    onPressed: () async {
                      Utils.customPrint("tapped on go to report button");
                      CustomLogger().logWithFile(Level.info,
                          "Navigating user into Trip Analytics Screen -> $page");
                      bool isTripExists = await _databaseService
                          .checkIfTripExist(selectedIndex);
                      if (isTripExists) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewTripAnalyticsScreen(
                                      tripId: selectedIndex,
                                      vesselName: selectedVesselName,
                                      // avgInfo: reportModel!.data!.avgInfo,
                                      vesselId: selectedVessel,
                                      tripIsRunningOrNot: false,
                                      calledFrom: 'Report',
                                      // vessel: getVesselById[0]
                                    )));
                      } else {
                        Utils.showSnackBar(context,
                            scaffoldKey: scaffoldKey,
                            message:
                                'Click on sync from cloud to reload your trips data to view trip analytics screen');
                      }
                    },
                    child: Text('Go to Trip Report',
                        style: TextStyle(
                          fontSize: 12,
                          color: blueColor,
                        )),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _tripDurationSrollController,
          child: SizedBox(
              width: durationColumnSeriesData.length > 3
                  ? orientation == Orientation.portrait
                      ? (1.5 * 100 * durationColumnSeriesData.length)
                      : durationColumnSeriesData.length > 4
                          ? (1.5 * 100 * durationColumnSeriesData.length)
                          : displayWidth(context)
                  : displayWidth(context),
              height: graph_height,
              child: SfCartesianChart(
                tooltipBehavior: tooltipBehaviorDurationGraph,
                enableSideBySideSeriesPlacement: true,
                // zoomPanBehavior: zoomPanBehavior,
                primaryXAxis: CategoryAxis(
                    isVisible: true,
                    // autoScrollingDelta: 10,
                    // autoScrollingMode: AutoScrollingMode.start,
                    // visibleMaximum: 0.1,
                    // visibleMinimum: 0,
                    labelPlacement: LabelPlacement.betweenTicks,
                    // Or LabelPlacement.onTicks
                    labelAlignment: LabelAlignment.start,
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: orientation == Orientation.portrait
                          ? displayWidth(context) * 0.034
                          : displayWidth(context) * 0.018,
                      fontWeight: FontWeight.w500,
                      fontFamily: poppins,
                    )),
                primaryYAxis: NumericAxis(
                    axisLine: AxisLine(
                      width: 0,
                    ),
                    title: AxisTitle(
                        text: 'Time ($minutes)',
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.028
                              : displayWidth(context) * 0.018,
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
                    axisLabelFormatter: (axisLabelRenderArgs) {
                      String value = axisLabelRenderArgs.text.length == 1
                          ? '00${axisLabelRenderArgs.text}'
                          : axisLabelRenderArgs.text.length == 2
                              ? '0${axisLabelRenderArgs.text}'
                              : axisLabelRenderArgs.text;
                      return ChartAxisLabel(
                          value,
                          TextStyle(
                            color: Colors.black,
                            fontSize: orientation == Orientation.portrait
                                ? displayWidth(context) * 0.034
                                : displayWidth(context) * 0.018,
                            fontWeight: FontWeight.w500,
                            fontFamily: poppins,
                          ));
                    },
                    plotBands: [
                      PlotBand(
                          text: 'avg ${avgDuration} min',
                          isVisible: true,
                          start: avgDuration,
                          end: avgDuration,
                          borderWidth: 2,
                          borderColor: Colors.grey,
                          shouldRenderAboveSeries: true,
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: orientation == Orientation.portrait
                                ? displayWidth(context) * 0.028
                                : displayWidth(context) * 0.018,
                            fontWeight: FontWeight.w500,
                            fontFamily: poppins,
                          ),
                          dashArray: <double>[4, 8],
                          horizontalTextAlignment: TextAnchor.start),
                    ]),

                series: durationColumnSeriesData,
              )),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: !isStickyYAxisVisible
              ? SizedBox()
              : Container(
                  //  padding: EdgeInsets.only(bottom: 20),
                  width: orientation == Orientation.portrait
                      ? displayWidth(context) * 0.18
                      : displayWidth(context) * 0.105,
                  // ? displayWidth(context) * 0.16
                  // ? tempDurationColumnSeriesData.length > 10 ? displayWidth(context) * 0.168 : displayWidth(context) * 0.20
                  //: tempDurationColumnSeriesData.length > 10 ? displayWidth(context) * 0.14 : displayWidth(context) * 0.1450,
                  height: graph_height,
                  color: Colors.white,
                  child: SfCartesianChart(
                    //plotAreaBorderWidth: 0,
                    tooltipBehavior: tooltipBehaviorDurationGraph,
                    plotAreaBorderColor: Colors.transparent,
                    // enableSideBySideSeriesPlacement: true,
                    primaryXAxis: CategoryAxis(

                        //axisLine: AxisLine(width: 0),
                        isVisible: true,
                        //isInversed: true,
                        //labelPlacement: LabelPlacement.betweenTicks,
                        // Or LabelPlacement.onTicks
                        autoScrollingMode: AutoScrollingMode.end,
                        labelAlignment: LabelAlignment.center,
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.034
                              : displayWidth(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        )),
                    primaryYAxis: NumericAxis(
                        axisLine: AxisLine(width: 1),
                        title: AxisTitle(
                            text: 'Time ($minutes)',
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: orientation == Orientation.portrait
                                  ? displayWidth(context) * 0.028
                                  : displayWidth(context) * 0.018,
                              fontWeight: FontWeight.w500,
                              fontFamily: poppins,
                            )),
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                        majorGridLines: MajorGridLines(width: 0),
                        minorGridLines: MinorGridLines(width: 0),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: displayWidth(context) * 0.034,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        ),
                        axisLabelFormatter: (axisLabelRenderArgs) {
                          String value = axisLabelRenderArgs.text.length == 1
                              ? '00${axisLabelRenderArgs.text}'
                              : axisLabelRenderArgs.text.length == 2
                                  ? '0${axisLabelRenderArgs.text}'
                                  : axisLabelRenderArgs.text;
                          return ChartAxisLabel(
                              value,
                              TextStyle(
                                color: Colors.black,
                                fontSize: orientation == Orientation.portrait
                                    ? displayWidth(context) * 0.034
                                    : displayWidth(context) * 0.018,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                              ));
                        },
                        plotBands: <PlotBand>[]),
                    series: tempDurationColumnSeriesData,
                  ),
                ),
        ),
      ],
    );
  }

  // Average speed graph in reports
  Widget avgSpeedGraph(
      BuildContext context, double graph_height, Orientation orientation) {
    avgSpeedToolTip = TooltipBehavior(
      enable: reportsDataTableKey.currentState?.isToolTipShown,
      activationMode: reportsDataTableKey.currentState?.isToolTipShown == null
          ? ActivationMode.singleTap
          : tooltipactivationMode,
      shouldAlwaysShow: true,
      color: commonBackgroundColor,
      borderWidth: 1,
      // activationMode: ActivationMode.singleTap,
      //duration: 5000,
      tooltipPosition: TooltipPosition.pointer,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final double? yValue = currentPoint.y;

        return Container(
          width: orientation == Orientation.portrait
              ? displayWidth(context) * 0.4
              : displayWidth(context) / 4.2,
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
                  Text(speedKnot,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              TextButton(
                onPressed: () async {
                  Utils.customPrint("tapped on go to report button");
                  CustomLogger().logWithFile(Level.info,
                      "Navigating user into Trip Analytics Screen -> $page");

                  bool isTripExists =
                      await _databaseService.checkIfTripExist(selectedIndex);
                  if (isTripExists) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewTripAnalyticsScreen(
                                  tripId: selectedIndex,
                                  vesselName: selectedVesselName,
                                  // avgInfo: reportModel!.data!.avgInfo,
                                  vesselId: selectedVessel,
                                  tripIsRunningOrNot: false,
                                  calledFrom: 'Report',
                                  // vessel: getVesselById[0]
                                )));
                  } else {
                    Utils.showSnackBar(context,
                        scaffoldKey: scaffoldKey,
                        message:
                            'Click on sync from cloud to reload your trips data to view trip analytics screen');
                  }
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: blueColor,
                    )),
              )
            ],
          ),
        );
      },
    );

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _avgSpeedSrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: avgSpeedColumnSeriesData.length > 3
                ? orientation == Orientation.portrait
                    ? (1.5 * 100 * avgSpeedColumnSeriesData.length)
                    : avgSpeedColumnSeriesData.length > 4
                        ? (1.5 * 100 * avgSpeedColumnSeriesData.length)
                        : displayWidth(context)
                : displayWidth(context),
            height: graph_height,
            child: SfCartesianChart(
              // palette: barsColor,
              tooltipBehavior: avgSpeedToolTip,
              primaryXAxis: CategoryAxis(
                  isVisible: true,
                  autoScrollingMode: AutoScrollingMode.end,
                  labelAlignment: LabelAlignment.center,
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: orientation == Orientation.portrait
                        ? displayWidth(context) * 0.034
                        : displayWidth(context) * 0.018,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              primaryYAxis: NumericAxis(
                  // interval: 5,
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(width: 0),
                  minorTickLines: MinorTickLines(width: 0),
                  title: AxisTitle(
                      text: 'Speed ($knotReport)',
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: orientation == Orientation.portrait
                            ? displayWidth(context) * 0.028
                            : displayWidth(context) * 0.018,
                        fontWeight: FontWeight.w500,
                        fontFamily: poppins,
                      )),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: displayWidth(context) * 0.034,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  ),
                  axisLabelFormatter: (axisLabelRenderArgs) {
                    String value = axisLabelRenderArgs.text.length == 1
                        ? '00${axisLabelRenderArgs.text}'
                        : axisLabelRenderArgs.text.length == 2
                            ? '0${axisLabelRenderArgs.text}'
                            : axisLabelRenderArgs.text;
                    return ChartAxisLabel(
                        value,
                        TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.034
                              : displayWidth(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        ));
                  },
                  plotBands: <PlotBand>[
                    PlotBand(
                      text: 'avg ${avgSpeed}$speedKnot',
                      isVisible: true,
                      start: avgSpeed,
                      end: avgSpeed,
                      borderWidth: 2,
                      borderColor: Colors.grey,
                      shouldRenderAboveSeries: true,
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: orientation == Orientation.portrait
                            ? displayWidth(context) * 0.028
                            : displayWidth(context) * 0.018,
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
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: !isStickyYAxisVisible
              ? SizedBox()
              : Container(
                  //padding: EdgeInsets.only(bottom: 20),
                  width: orientation == Orientation.portrait
                      ? displayWidth(context) * 0.18
                      : displayWidth(context) * 0.105,
                  color: Colors.white,
                  height: graph_height,
                  child: SfCartesianChart(
                    // palette: barsColor,
                    tooltipBehavior: avgSpeedToolTip,
                    plotAreaBorderColor: Colors.transparent,
                    primaryXAxis: CategoryAxis(
                        isVisible: true,
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                        majorGridLines: MajorGridLines(width: 0),
                        minorGridLines: MinorGridLines(width: 0),
                        autoScrollingMode: AutoScrollingMode.end,
                        labelAlignment: LabelAlignment.center,
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.034
                              : displayWidth(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        )),
                    primaryYAxis: NumericAxis(
                        // interval: 5,
                        // axisLine: AxisLine(width: 1),
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                        majorGridLines: MajorGridLines(width: 0),
                        minorGridLines: MinorGridLines(width: 0),
                        title: AxisTitle(
                            text: 'Speed ($knotReport)',
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: orientation == Orientation.portrait
                                  ? displayWidth(context) * 0.028
                                  : displayWidth(context) * 0.018,
                              fontWeight: FontWeight.w500,
                              fontFamily: poppins,
                            )),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: displayWidth(context) * 0.034,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        ),
                        axisLabelFormatter: (axisLabelRenderArgs) {
                          String value = axisLabelRenderArgs.text.length == 1
                              ? '00${axisLabelRenderArgs.text}'
                              : axisLabelRenderArgs.text.length == 2
                                  ? '0${axisLabelRenderArgs.text}'
                                  : axisLabelRenderArgs.text;
                          return ChartAxisLabel(
                              value,
                              TextStyle(
                                color: Colors.black,
                                fontSize: orientation == Orientation.portrait
                                    ? displayWidth(context) * 0.034
                                    : displayWidth(context) * 0.018,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                              ));
                        },
                        plotBands: <PlotBand>[]),
                    series: tempAvgSpeedColumnSeriesData,
                  ),
                ),
        ),
      ],
    );
  }

  // Fuel usage graph on reports
  Widget fuelUsageGraph(
      BuildContext context, double graph_height, Orientation orientation) {
    fuelUsageToolTip = TooltipBehavior(
      enable: reportsDataTableKey.currentState?.isToolTipShown,
      activationMode: reportsDataTableKey.currentState?.isToolTipShown == null
          ? ActivationMode.singleTap
          : tooltipactivationMode,
      shouldAlwaysShow: true,
      color: commonBackgroundColor,
      borderWidth: 1,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final double? yValue = currentPoint.y;

        Utils.customPrint("fuel y data is: ${yValue}");
        CustomLogger()
            .logWithFile(Level.info, "fuel y data is: ${yValue} -> $page");

        return Container(
          width: orientation == Orientation.portrait
              ? displayWidth(context) * 0.4
              : displayWidth(context) / 4.2,
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
                  Text(liters,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )),
                ],
              ),
              TextButton(
                onPressed: () async {
                  Utils.customPrint("tapped on go to report button");
                  CustomLogger().logWithFile(Level.info,
                      "Navigating user into Trip Analytics Screen -> $page");

                  bool isTripExists =
                      await _databaseService.checkIfTripExist(selectedIndex);
                  if (isTripExists) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewTripAnalyticsScreen(
                                  tripId: selectedIndex,
                                  vesselName: selectedVesselName,
                                  // avgInfo: reportModel!.data!.avgInfo,
                                  vesselId: selectedVessel,
                                  tripIsRunningOrNot: false,
                                  calledFrom: 'Report',
                                  // vessel: getVesselById[0]
                                )));
                  } else {
                    Utils.showSnackBar(context,
                        scaffoldKey: scaffoldKey,
                        message:
                            'Click on sync from cloud to reload your trips data to view trip analytics screen');
                  }
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: blueColor,
                    )),
              )
            ],
          ),
        );
      },
    );

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _fuelUsageSrollController,
          scrollDirection: Axis.horizontal,
          physics: fuelUsageColumnSeriesData.isEmpty
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: fuelUsageColumnSeriesData.length > 3
                ? orientation == Orientation.portrait
                    ? (1.5 * 100 * fuelUsageColumnSeriesData.length)
                    : fuelUsageColumnSeriesData.length > 4
                        ? (1.5 * 100 * fuelUsageColumnSeriesData.length)
                        : displayWidth(context)
                : displayWidth(context),
            height: graph_height,
            child: SfCartesianChart(
              tooltipBehavior: fuelUsageToolTip,
              primaryXAxis: CategoryAxis(
                  autoScrollingMode: AutoScrollingMode.end,
                  labelAlignment: LabelAlignment.center,
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: orientation == Orientation.portrait
                        ? displayWidth(context) * 0.034
                        : displayWidth(context) * 0.018,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              primaryYAxis: NumericAxis(
                  labelFormat: '{value}',
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(width: 0),
                  minorTickLines: MinorTickLines(width: 0),
                  title: AxisTitle(
                      text: 'Volume ($literReport)',
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: orientation == Orientation.portrait
                            ? displayWidth(context) * 0.028
                            : displayWidth(context) * 0.018,
                        fontWeight: FontWeight.w500,
                        fontFamily: poppins,
                      )),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: orientation == Orientation.portrait
                        ? displayWidth(context) * 0.028
                        : displayWidth(context) * 0.018,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  ),
                  axisLabelFormatter: (axisLabelRenderArgs) {
                    String value = axisLabelRenderArgs.text.length == 1
                        ? '00${axisLabelRenderArgs.text}'
                        : axisLabelRenderArgs.text.length == 2
                            ? '0${axisLabelRenderArgs.text}'
                            : axisLabelRenderArgs.text;
                    return ChartAxisLabel(
                        value,
                        TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.034
                              : displayWidth(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        ));
                  },
                  plotBands: [
                    PlotBand(
                        text: 'avg ${avgFuelConsumption}$liters',
                        isVisible: true,
                        start: avgFuelConsumption,
                        end: avgFuelConsumption,
                        borderWidth: 2,
                        borderColor: Colors.grey,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.028
                              : displayWidth(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        ),
                        dashArray: <double>[4, 8],
                        horizontalTextAlignment: TextAnchor.start),
                  ]),
              series: fuelUsageColumnSeriesData,
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: !isStickyYAxisVisible
              ? SizedBox()
              : Container(
                  width: orientation == Orientation.portrait
                      ? displayWidth(context) * 0.198
                      : displayWidth(context) * 0.135,
                  color: Colors.white,
                  height: graph_height,
                  child: SfCartesianChart(
                    tooltipBehavior: fuelUsageToolTip,
                    primaryXAxis: CategoryAxis(
                        autoScrollingMode: AutoScrollingMode.end,
                        labelAlignment: LabelAlignment.center,
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: orientation == Orientation.portrait
                              ? displayWidth(context) * 0.034
                              : displayWidth(context) * 0.018,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        )),
                    primaryYAxis: NumericAxis(
                        labelFormat: '{value}',
                        axisLine: AxisLine(width: 2),
                        title: AxisTitle(
                            text: 'Volume ($literReport)',
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: orientation == Orientation.portrait
                                  ? displayWidth(context) * 0.028
                                  : displayWidth(context) * 0.018,
                              fontWeight: FontWeight.w500,
                              fontFamily: poppins,
                            )),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: displayWidth(context) * 0.034,
                          fontWeight: FontWeight.w500,
                          fontFamily: poppins,
                        ),
                        axisLabelFormatter: (axisLabelRenderArgs) {
                          String value = axisLabelRenderArgs.text.length == 1
                              ? '00${axisLabelRenderArgs.text}'
                              : axisLabelRenderArgs.text.length == 2
                                  ? '0${axisLabelRenderArgs.text}'
                                  : axisLabelRenderArgs.text;
                          return ChartAxisLabel(
                              value,
                              TextStyle(
                                color: Colors.black,
                                fontSize: orientation == Orientation.portrait
                                    ? displayWidth(context) * 0.034
                                    : displayWidth(context) * 0.018,
                                fontWeight: FontWeight.w500,
                                fontFamily: poppins,
                              ));
                        },
                        plotBands: []),
                    series: tempFuelUsageColumnSeriesData,
                  ),
                ),
        ),
      ],
    );
  }

  // Power usage graph on reports
  Widget powerUsageGraph(
      BuildContext context, double graph_height, Orientation orientation) {
    powerUsageToolTip = TooltipBehavior(
      enable: reportsDataTableKey.currentState?.isToolTipShown,
      activationMode: reportsDataTableKey.currentState?.isToolTipShown == null
          ? ActivationMode.singleTap
          : tooltipactivationMode,
      shouldAlwaysShow: true,
      color: commonBackgroundColor,
      borderWidth: 1,
      builder: (dynamic data, dynamic point, dynamic series, dynamic dataIndex,
          dynamic pointIndex) {
        CartesianChartPoint currentPoint = point;
        final double? yValue = currentPoint.y;

        Utils.customPrint("power y data is: ${yValue}");
        CustomLogger()
            .logWithFile(Level.info, "power y data is: ${yValue} -> $page");

        return Container(
          width: orientation == Orientation.portrait
              ? displayWidth(context) * 0.4
              : displayWidth(context) / 4.2,
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
                onPressed: () async {
                  Utils.customPrint("tapped on go to report button");
                  CustomLogger().logWithFile(Level.info,
                      "Navigating user into Trip Analytics Screen -> $page");
                  print('the selected index was---' + selectedIndex.toString());
                  bool isTripExists =
                      await _databaseService.checkIfTripExist(selectedIndex);
                  if (isTripExists) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewTripAnalyticsScreen(
                                  tripId: selectedIndex,
                                  vesselName: selectedVesselName,
                                  // avgInfo: reportModel!.data!.avgInfo,
                                  vesselId: selectedVessel,
                                  tripIsRunningOrNot: false,
                                  calledFrom: 'Report',
                                  // vessel: getVesselById[0]
                                )));
                  } else {
                    Utils.showSnackBar(context,
                        scaffoldKey: scaffoldKey,
                        message:
                            'Click on sync from cloud to reload your trips data to view trip analytics screen');
                  }
                },
                child: Text('Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: blueColor,
                    )),
              )
            ],
          ),
        );
      },
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _powerUsageSrollController,
      physics: powerUsageColumnSeriesData.isEmpty
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        width: powerUsageColumnSeriesData.length > 3
            ? orientation == Orientation.portrait
                ? (1.5 * 100 * powerUsageColumnSeriesData.length)
                : powerUsageColumnSeriesData.length > 4
                    ? (1.5 * 100 * powerUsageColumnSeriesData.length)
                    : displayWidth(context)
            : displayWidth(context),
        height: graph_height,
        child: SfCartesianChart(
          tooltipBehavior: powerUsageToolTip,
          primaryXAxis: CategoryAxis(
              autoScrollingMode: AutoScrollingMode.end,
              labelAlignment: LabelAlignment.center,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: orientation == Orientation.portrait
                    ? displayWidth(context) * 0.034
                    : displayWidth(context) * 0.018,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              )),
          primaryYAxis: NumericAxis(
              axisLine: AxisLine(width: 0),
              majorTickLines: MajorTickLines(width: 0),
              minorTickLines: MinorTickLines(width: 0),
              title: AxisTitle(
                  text: 'Power ($watsReport)',
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: orientation == Orientation.portrait
                        ? displayWidth(context) * 0.028
                        : displayWidth(context) * 0.018,
                    fontWeight: FontWeight.w500,
                    fontFamily: poppins,
                  )),
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: displayWidth(context) * 0.034,
                fontWeight: FontWeight.w500,
                fontFamily: poppins,
              ),
              axisLabelFormatter: (axisLabelRenderArgs) {
                String value = axisLabelRenderArgs.text.length == 1
                    ? '00${axisLabelRenderArgs.text}'
                    : axisLabelRenderArgs.text.length == 2
                        ? '0${axisLabelRenderArgs.text}'
                        : axisLabelRenderArgs.text;
                return ChartAxisLabel(
                    value,
                    TextStyle(
                      color: Colors.black,
                      fontSize: orientation == Orientation.portrait
                          ? displayWidth(context) * 0.034
                          : displayWidth(context) * 0.018,
                      fontWeight: FontWeight.w500,
                      fontFamily: poppins,
                    ));
              },
              plotBands: [
                PlotBand(
                    text: 'avg ${avgPower.toStringAsFixed(2)}$watt',
                    isVisible: true,
                    start: avgPower,
                    end: avgPower,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: orientation == Orientation.portrait
                          ? displayWidth(context) * 0.028
                          : displayWidth(context) * 0.018,
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
  Widget? filterByDate(BuildContext context, Orientation orientation) {
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isEndDateSected = false;
                      isStartDate = true;
                      selectDateOption = 1;
                      isSelectStartDate = true;

                      isStartDateSelected = false;
                    });
                  },
                  child: Container(
                    width: displayWidth(context) * 0.385,
                    height: orientation == Orientation.portrait
                        ? displayWidth(context) * 0.1
                        : displayWidth(context) * 0.075,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: reportDropdownColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.04,
                          right: displayWidth(context) * 0.04),
                      child: Row(
                        children: [
                          SizedBox(
                            width: displayWidth(context) * 0.23,
                            child: Text(
                              pickStartDate!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: inter),
                            ),
                          ),
                          SizedBox(
                            width: displayWidth(context) * 0.02,
                          ),
                          Image.asset(
                            "assets/icons/Calendar.png",
                            width: displayWidth(context) * 0.053,
                            height: displayHeight(context) * 0.05,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: displayWidth(context) * 0.02,
                ),
                GestureDetector(
                  onTap: () {
                    if (isSelectedStartDay!) {
                      if (!isSelectStartDate) {
                        Utils.showSnackBar(context,
                            scaffoldKey: scaffoldKey,
                            message: 'Please Select The Start Date',
                            duration: 2);
                      } else {
                        setState(() {
                          isEndDateSected = false;
                          isEndDate = true;
                          selectDateOption = 2;

                          isSelectEndDate = true;
                        });
                      }
                    } else {
                      Utils.showSnackBar(context,
                          scaffoldKey: scaffoldKey,
                          message: 'Please Select Start Date.',
                          duration: 2);
                    }
                  },
                  child: Container(
                    width: displayWidth(context) * 0.385,
                    height: orientation == Orientation.portrait
                        ? displayWidth(context) * 0.1
                        : displayWidth(context) * 0.075,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: reportDropdownColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.04,
                          right: displayWidth(context) * 0.04),
                      child: Row(
                        children: [
                          SizedBox(
                            width: displayWidth(context) * 0.23,
                            child: Text(
                              pickEndDate!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: inter),
                            ),
                          ),
                          SizedBox(
                            width: displayWidth(context) * 0.02,
                          ),
                          Image.asset(
                            "assets/icons/Calendar.png",
                            width: displayWidth(context) * 0.053,
                            height: displayHeight(context) * 0.05,
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
          height: displayWidth(context) * 0.04,
        ),
        selectDateOption == 1 && isSelectStartDate
            ? Visibility(
                visible: !isEndDateSected!,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: displayWidth(context) * 0.045,
                          right: displayWidth(context) * 0.045),
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
                              top: orientation == Orientation.portrait
                                  ? displayWidth(context) * 0.05
                                  : displayWidth(context) * 0.02),
                          child: Text(
                            "Select Start Date",
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
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))),
                        child: Visibility(
                          visible: !isEndDateSected!,
                          child: IgnorePointer(
                            ignoring: isBtnClick ?? false,
                            child: TableCalendar(
                              daysOfWeekVisible: true,
                              focusedDay: selectedDateForStartDate,
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
                                      color: selectedDateForStartDate ==
                                              DateTime.now()
                                          ? Colors.white
                                          : blueColor)),
                              selectedDayPredicate: (DateTime date) {
                                return isSameDay(
                                    selectedDateForStartDate, date);
                              },
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              onDaySelected:
                                  (DateTime? selectDay, DateTime? focusDay) {
                                setState(() {
                                  isSelectedStartDay = true;
                                  selectedDateForStartDate = selectDay!;
                                  focusedDay = focusDay!;
                                  focusedDayString = focusDay.toString();
                                  pickStartDate =
                                      convertIntoMonthDayYear(selectDay);
                                  selectedStartDateFromCal = selectDay;
                                  isStartDateSelected = true;
                                  isSelectEndDate = true;
                                  selectDateOption = 2;
                                  isSelectEndDate = true;

                                  Utils.customPrint(
                                      "pick start date: $pickStartDate");
                                  CustomLogger().logWithFile(Level.info,
                                      "pick start date: $pickStartDate -> $page");
                                });
                                Utils.customPrint("focusedDay: $focusDay");
                                CustomLogger().logWithFile(Level.info,
                                    "focused Day: $focusedDay -> $page");
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
                    ),
                  ],
                ),
              )
            : isSelectEndDate
                ? Visibility(
                    visible: !isEndDateSected!,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: displayWidth(context) * 0.045,
                              right: displayWidth(context) * 0.045),
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
                                  top: orientation == Orientation.portrait
                                      ? displayWidth(context) * 0.05
                                      : displayWidth(context) * 0.02),
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
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20))),
                            child: IgnorePointer(
                              ignoring: isBtnClick ?? false,
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
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(15)
                                              //shape: BoxShape.circle

                                              ),
                                          child: Text(
                                            date.day.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
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
                                      color: blueColor,
                                      shape: BoxShape.rectangle,
                                    ),
                                    selectedTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0,
                                        color: Colors.pink),
                                    todayTextStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16.0,
                                        color: selectedDateForEndDate ==
                                                DateTime.now()
                                            ? Colors.white
                                            : blueColor)),
                                selectedDayPredicate: (DateTime date) {
                                  return isSameDay(
                                      selectedDateForEndDate, date);
                                },
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                onDaySelected:
                                    (DateTime? selectDay, DateTime? focusDay) {
                                  setState(() {
                                    isSelectedEndDay = true;
                                    selectedDateForEndDate = selectDay!;
                                    lastDayFocused = focusDay!;
                                    lastFocusedDayString = focusDay.toString();
                                    pickEndDate =
                                        convertIntoMonthDayYear(selectDay);
                                    selectedEndDateFromCal = selectDay;
                                    isEndDateSected = true;

                                    Utils.customPrint(
                                        "pick end date: $pickEndDate");
                                    CustomLogger().logWithFile(Level.info,
                                        "pick end date: $pickEndDate -> $page");
                                  });
                                  Utils.customPrint(
                                      "lastDayFocused: $lastDayFocused");
                                  CustomLogger().logWithFile(Level.info,
                                      "lastDayFocused: $lastDayFocused -> $page");
                                },
                                headerStyle: HeaderStyle(
                                  titleCentered: true,

                                  titleTextStyle: TextStyle(
                                      fontSize: 17,
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
                      ],
                    ),
                  )
                : Container(),
      ],
    );
  }

  //Filter by trip in reports
  Widget? filterByTrip(BuildContext context, Orientation orientation) {
    return isTripIdListLoading!
        ? Container(
            padding: EdgeInsets.only(bottom: tripIdList!.length != 0 ? 15 : 0),
            decoration: BoxDecoration(
                color: reportTripsListBackColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(displayWidth(context) * 0.05))),
            child: Column(
              children: [
                tripIdList!.length == 0
                    ? Container(
                        padding: EdgeInsets.all(8),
                        child: commonText(
                            text: 'No Trips Available',
                            textSize: displayWidth(context) * 0.030,
                            textColor: primaryColor))
                    : IgnorePointer(
                        ignoring: isBtnClick ?? false,
                        child: ListView(
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: displayWidth(context) * 0.046),
                              child: CustomLabeledCheckbox(
                                orientation: orientation,
                                label: 'Select All',
                                value:
                                    parentValue != null ? parentValue! : false,
                                onChanged: (value) {
                                  if (value) {
                                    Utils.customPrint(
                                        "select all status: $value");
                                    selectedTripIdList!.clear();
                                    selectedTripIdList!.addAll(tripIdList!);
                                    isSHowGraph = false;
                                    selectedTripLabelList!.clear();
                                    selectedTripLabelList!.addAll(children!);
                                    Utils.customPrint(
                                        "selected trip label list: ${selectedTripLabelList}");
                                    CustomLogger().logWithFile(Level.info,
                                        "selected trip label list: ${selectedTripLabelList} -> $page");
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
                                  SizedBox(
                                    height: orientation == Orientation.portrait
                                        ? displayHeight(context) * 0.01
                                        : displayHeight(context) * 0.03,
                                  ),
                                  CustomLabeledCheckboxNew(
                                    isfleetType: widget.isTypeFleet,
                                    orientation: orientation,
                                    label: children![index],
                                    value: childrenValue![index],
                                    imageUrl: imageUrl,
                                    dateTime: dateTimeList![index],
                                    distance:
                                        '${distanceList![index]} $nauticalMile',
                                    time: timeList![index],
                                    onChanged: (value) {
                                      isSHowGraph = false;
                                      Utils.customPrint(
                                          "trip list id: ${tripIdList![index]}");
                                      CustomLogger().logWithFile(Level.info,
                                          "trip list id: ${tripIdList![index]} -> $page");

                                      if (selectedTripIdList!
                                          .contains(tripIdList![index])) {
                                        selectedTripIdList!
                                            .remove(tripIdList![index]);
                                        //tripIdList!.remove(index);
                                        selectedTripLabelList!
                                            .remove(children![index]);
                                        Utils.customPrint(
                                            "selected trip label list: ${selectedTripLabelList}");
                                        CustomLogger().logWithFile(Level.info,
                                            "selected trip label list: ${selectedTripLabelList} -> $page");
                                        setState(() {});
                                      } else {
                                        selectedTripIdList!
                                            .add(tripIdList![index]);
                                        // tripIdList!.add(index);
                                        selectedTripLabelList!
                                            .add(children![index]);
                                        setState(() {});
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
                        ),
                      )
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(blueColor),
            ),
          );
  }

  void getTappedItemBarIndex(int index) {
    selectedBarIndex = index;
  }

  void scorllToParticularPostion(
      int index, dynamic persondata, Orientation orientation) {
    selectedIndex = persondata['tripDetails'];
    tooltipactivationMode = ActivationMode.singleTap;
    reportsDataTableKey.currentState!.setState(() {
      reportsDataTableKey.currentState!.isToolTipShown = true;
    });

    for (int i = 0; i < durationGraphData.length; i++) {
      for (int j = 0; j < durationGraphData[i].tripsByDate!.length; j++) {
        durationGraphData[i].tripsByDate![j].dataLineColor = blueColor;
        if (durationGraphData[i].tripsByDate![j].id ==
            persondata['tripDetails']) {
          durationGraphData[i].tripsByDate![j].dataLineColor = Colors.green;
        }
      }
    }

    final scrollPosition = index * 150.0;
    selectedRowIndex = index;
    setState(() {});
    if (orientation == Orientation.portrait) {
      _mainScrollController.animateTo(
        0.0, // Scroll to the top
        duration: Duration(milliseconds: 100), // Adjust the duration as needed
        curve: Curves.easeInOut, // Specify the easing curve
      );
    } else {
      _mainScrollController.animateTo(
        500, // Scroll to the top
        duration: Duration(milliseconds: 100), // Adjust the duration as needed
        curve: Curves.easeInOut, // Specify the easing curve
      );
    }

    // Calculate the scroll position based on your data
    if (selectedButton == "trip duration") {
      _tripDurationSrollController
          .animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 100), // Adjust the duration as needed
        curve: Curves.easeInOut,
      )
          .then((value) {
        Future.delayed(Duration(seconds: 1), () {
          tooltipBehaviorDurationGraph?.showByIndex(
              selectedRowIndex!, pointIndex ?? 0);
        });
      });
    } else if (selectedButton == 'avg speed') {
      _avgSpeedSrollController
          .animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 100), // Adjust the duration as needed
        curve: Curves.easeInOut,
      )
          .then((value) {
        Future.delayed(Duration(seconds: 1), () {
          avgSpeedToolTip?.showByIndex(selectedRowIndex!, pointIndex ?? 0);
        });
      });
    } else if (selectedButton == 'fuel usage') {
      _fuelUsageSrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 100), // Adjust the duration as needed
        curve: Curves.easeInOut,
      )..then((value) {
          Future.delayed(Duration(seconds: 1), () {
            fuelUsageToolTip!.showByIndex(selectedRowIndex!, pointIndex ?? 0);
          });
        });
    } else {
      _powerUsageSrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 500), // Adjust the duration as needed
        curve: Curves.easeInOut,
      )..then((value) {
          Future.delayed(Duration(seconds: 1), () {
            powerUsageToolTip!.showByIndex(selectedRowIndex!, pointIndex ?? 0);
          });
        });
    }
  }

  addListenerToControllers() {
    _tripDurationSrollController.addListener(() {
      if (_tripDurationSrollController.position.maxScrollExtent ==
          _tripDurationSrollController.position.pixels) {
      } else {
        setState(() {
          if (!isStickyYAxisVisible) {
            isStickyYAxisVisible = true;
          }
        });

        if (_tripDurationSrollController.offset <= 51.0) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
        bool isTop = _tripDurationSrollController.position.pixels == 0;
        if (isTop) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
      }
    });

    _avgSpeedSrollController.addListener(() {
      if (_avgSpeedSrollController.position.maxScrollExtent ==
          _avgSpeedSrollController.position.pixels) {
      } else {
        setState(() {
          if (!isStickyYAxisVisible) {
            isStickyYAxisVisible = true;
          }
        });

        if (_avgSpeedSrollController.offset <= 51.0) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
        bool isTop = _avgSpeedSrollController.position.pixels == 0;
        if (isTop) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
      }
    });

    _fuelUsageSrollController.addListener(() {
      if (_fuelUsageSrollController.position.maxScrollExtent ==
          _fuelUsageSrollController.position.pixels) {
      } else {
        setState(() {
          if (!isStickyYAxisVisible) {
            isStickyYAxisVisible = true;
          }
        });

        if (_fuelUsageSrollController.offset <= 51.0) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
        bool isTop = _fuelUsageSrollController.position.pixels == 0;
        if (isTop) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
      }
    });

    _powerUsageSrollController.addListener(() {
      if (_powerUsageSrollController.position.maxScrollExtent ==
          _powerUsageSrollController.position.pixels) {
      } else {
        setState(() {
          if (!isStickyYAxisVisible) {
            isStickyYAxisVisible = true;
          }
        });

        if (_powerUsageSrollController.offset <= 51.0) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
        bool isTop = _powerUsageSrollController.position.pixels == 0;
        if (isTop) {
          setState(() {
            isStickyYAxisVisible = false;
          });
        }
      }
    });
  }
}

class DropdownItem {
  final String? id;
  final String? name;

  DropdownItem({this.id, this.name});
}
