import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/widgets/common_drop_down_one.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
import '../../models/reports_model.dart';
import '../home_page.dart';
import 'package:table_calendar/table_calendar.dart';


class SearchAndFilters extends StatefulWidget {
  const SearchAndFilters({Key? key}) : super(key: key);

  @override
  State<SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<SearchAndFilters> {

  String? selectedVessel;
  String? selectedTrip;
  int _selectedOption = 1;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime firstDate = DateTime(1980);
  DateTime lastDate = DateTime(2050);
  List<String> items = [
    "Start Date",
    "End Date"
  ];


  bool? parentValue = false;
  List<String>? children;
  List<bool>? childrenValue;
  List<String>? tripIdList;
  List<String>? dateTimeList;
  bool? isStartDate = false;
  bool? isEndDate = false;
  CalendarFormat format = CalendarFormat.month;

  var avgDurations;
  String? selectedButton = 'Trip Duration';

  final List<Map<String, String>> data = [
    {'date': '12 Jan 23', 'tripDetails': 'Trip ID02024884', 'duration': '08:15:36','avgSpeed' : '12.6 nm','fuelUsage': '15.36 g', 'powerUsage': '258.23 w'},
    {'date': '13 Jan 23', 'tripDetails': 'Trip ID02024884', 'duration': '08:15:36','avgSpeed' : '12.7 nm','fuelUsage': '15.36 g', 'powerUsage': '258.23 w'},
    {'date': '14 Jan 23', 'tripDetails': 'Trip ID02024884', 'duration': '08:15:36','avgSpeed' : '12.9 nm','fuelUsage': '15.36 g', 'powerUsage': '258.23 w'},
    {'date': '15 Jan 23', 'tripDetails': 'Trip ID02024884', 'duration': '08:15:36','avgSpeed' : '12.8 nm','fuelUsage': '15.36 g', 'powerUsage': '258.23 w'},
  ];

  final List<Map<String,String>> finalData = [
    {'date': '','tripDetails' : 'Total', 'duration' : '08:10:20','avgSpeed': '12.7 nm','fuelUsage': '15.36 g', 'powerUsage': '258.23 w'},
    {'date': '','tripDetails' : 'Average', 'duration' : '08:10:20','avgSpeed': '12.8 nm','fuelUsage': '15.36 g', 'powerUsage': '258.23 w'}
  ];

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

  List<TripData> tripDataList = [];
  List<Trip> triSpeedList = [];
  ReportModel? reportModel;
  double? avgSpeed;
  int? avgDuration;
  dynamic avgFuelConsumption;

  // Fetch content from the json file
  Future<void> readJson() async {
    var response = await rootBundle.loadString('assets/reports/reports.json');
    reportModel = ReportModel.fromJson(json.decode(response));
    avgSpeed = reportModel!.data.avgInfo.avgSpeed;
    avgDuration = durationWithMilli(reportModel!.data.avgInfo.avgDuration);
    avgFuelConsumption = reportModel!.data.avgInfo.avgFuelConsumption;

    triSpeedList = List<Trip>.from(reportModel!.data.trips.map((speed) => Trip(date: speed.date, tripsByDate: speed.tripsByDate)));

  }
  
  dynamic duration(String duration){
    String timeString = duration;
    List<String> parts = timeString.split(':');
    DateTime dateTime = DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2],));
    int totalMinutes = dateTime.hour * 60 + dateTime.minute;
    print(totalMinutes);
    return totalMinutes;
  }
  dynamic durationWithMilli(String timeString){
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
    parentValue = false;

    readJson();

    children = [
      'Trip1',
      'Trip2',
      'Trip3',
      'Trip4',
    ];

    dateTimeList = [
      "23-Jan-2023",
      "24-Jan-2023",
      "25-Jan-2023",
      "26-Jan-2023"
    ];

    tripIdList = [
      "226IMS56",
      "226IMS57",
      "226IMS58",
      "226IMS59"
    ];

    childrenValue = List.generate(children!.length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: reportBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding:  EdgeInsets.only(
                left: displayWidth(context) * 0.05,
                right: displayWidth(context) * 0.05,
                top: displayWidth(context) * 0.05
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: ()  {
                          Navigator.of(context).pop(true);
                        },
                        icon: const Icon(Icons.arrow_back,size: 28,),
                        color: Theme.of(context).brightness == Brightness.dark
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
                            fontWeight: FontWeight.w600,fontFamily: inter
                        ),
                      ),
                      SizedBox(
                        width: displayWidth(context) * 0.38,
                      ),
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

                  ExpansionTile(
                    collapsedBackgroundColor: dateBackgroundColor,
                    title: Text(
                      "Search & Filters",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          fontFamily: inter
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_down,color: Colors.black,
                    ),
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 8.0),
                        child: CommonDropDownFormFieldOne(
                          context: context,
                          value: selectedVessel,
                          hintText: 'Select Vessel*',
                          labelText: '',
                          onChanged: (String value) {
                            // formKey.currentState!.validate();
                          },
                          dataSource: ['Vessel1', 'Vessel2', 'Vessel3'],
                          borderRadius: 10,
                          padding: 6,
                          textColor: Colors.black,
                          textField: 'key',
                          valueField: 'value',
                          validator: (value) {
                            if (value == null) {
                              return 'Select vessel';
                            }
                            return null;
                          },
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
                                  _selectedOption = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: Text(
                                  "Filter By Trip",
                                  style: TextStyle(fontSize: 14)
                              ),
                              value: 2,
                              groupValue: _selectedOption,
                              onChanged: (int? value) {
                                setState(() {
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
                          "Search",
                          context,
                          primaryColor, () {
                        // Navigator.of(context).pop();
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
                          fontWeight: FontWeight.w500
                      ),

                      SizedBox(height: displayWidth(context) * 0.1,)

                    ],
                  ),

                  SizedBox(height: displayWidth(context) * 0.07,),

                  Text(
                    "Sea Cucumber",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: inter
                    ),
                  ),

                  SizedBox(height: displayWidth(context) * 0.04,),

                  Row(
                    children: [
                      Text(
                        "Selected Trips",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: inter
                        ),
                      ),
                      SizedBox(width: displayWidth(context) * 0.05,),
                      Text(
                        ":  Trip A, Trip B, Trip C",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: inter
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: displayWidth(context) * 0.06,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                         setState(() {
                           selectedButton = 'Trip Duration';
                         });
                        },
                        child: Container(
                          //  color: dateBackgroundColor,
                          width: displayWidth(context) * 0.21,
                          height: displayWidth(context) * 0.09,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: reportTabColor
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                "Trip Duration",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedButton = 'Avg Speed';
                          });
                        },
                        child: Container(
                          //  color: dateBackgroundColor,
                          width: displayWidth(context) * 0.19,
                          height: displayWidth(context) * 0.09,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: reportTabColor
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                "Avg Speed",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedButton = 'Fuel Usage';
                          });
                        },
                        child: Container(
                          //  color: dateBackgroundColor,
                          width: displayWidth(context) * 0.20,
                          height: displayWidth(context) * 0.09,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: reportTabColor
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                "Fuel Usage",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedButton = 'Power Usage';
                          });
                        },
                        child: Container(
                          //  color: dateBackgroundColor,
                          width: displayWidth(context) * 0.22,
                          height: displayWidth(context) * 0.09,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: reportTabColor
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                "Power Usage",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: displayWidth(context) * 0.02,),
                ],
              ),
            ),

         //  buildGraph(context)!,

          // tripDurationGraph(context)!,
              avgSpeedGraph(context)!,
             // fuelUsageGraph(context)!,
             // powerUsageGraph(context)!,

              Padding(
                padding: EdgeInsets.only(
                    right: 20, left: 20),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,
                  children: [
                    tripWithColor(backgroundColor,
                        'Trip A Name'),
                    tripWithColor(circularProgressColor,
                        'Trip B Name'),
                    tripWithColor(tripColumnBarColor,
                        'Trip C Name'),
                  ],
                ),
              ),

           table(context)!,
              
            SizedBox(height: displayWidth(context) * 0.08,),
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
          fontWeight: FontWeight.w600
        )
      ],
    );
  }

  Widget? table(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding:  EdgeInsets.all(12.0),
        child: DataTable(
          columnSpacing: 25,
          dividerThickness: 1,
          columns: [
            DataColumn(label: Text('Date',style: TextStyle(color: tableHeaderColor),),),
            DataColumn(label: Text('Trip Details',style: TextStyle(color: tableHeaderColor))),
            DataColumn(label: Text('Duration',style: TextStyle(color: tableHeaderColor))),
            DataColumn(label: Text('Avg Speed',style: TextStyle(color: tableHeaderColor))),
            DataColumn(label: Text('Fuel Usage',style: TextStyle(color: tableHeaderColor))),
            DataColumn(label: Text('Power Usage',style: TextStyle(color: tableHeaderColor))),
          ],
          rows: [
            ...data.map((person) => DataRow(
                cells: [
                  DataCell(Text(person['date']!)),
                  DataCell(Text(person['tripDetails']!)),
                  DataCell(Text(person['duration']!)),
                  DataCell(Text(person['avgSpeed']!)),
                  DataCell(Text(person['fuelUsage']!)),
                  DataCell(Text(person['powerUsage']!)),
                ])
            ),

            ...finalData.map((e) => DataRow(cells: [
              DataCell(Text(
                  e['date']!,
                style: TextStyle(color: Colors.blue),
              ),),
              DataCell(Text(
                e['tripDetails']!,style: TextStyle(color: Colors.blue),
              )),
              DataCell(Text(e['duration']!,style: TextStyle(color: Colors.blue),)),
              DataCell(Text(e['avgSpeed']!,style: TextStyle(color: Colors.blue))),
              DataCell(Text(e['fuelUsage']!,style: TextStyle(color: Colors.blue))),
              DataCell(Text(e['powerUsage']!,style: TextStyle(color: Colors.blue))),
            ]))

          ],
        ),
      ),
    );
  }

  Widget? buildGraph(BuildContext context) {
    switch (selectedButton) {
      case 'Trip Duration':
        tripDurationGraph(context);
        break;
      case 'Avg Speed':
        avgSpeedGraph(context);
        break;
      case 'Fuel Usage':
         fuelUsageGraph(context);
          break;
      case 'Power USage':
        powerUsageGraph(context);
        break;
      default:
        return Container();
    }
  }

  Widget? tripDurationGraph(BuildContext context){

    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<Trip, String>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (Trip tripData, _) => tripData.date,
        yValueMapper: (Trip tripData, _) => duration(tripData.tripsByDate[0].duration.toString()),
        name: 'Duration',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.6,
      ),
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
      borderWidth: 1,
      //activationMode: ActivationMode.singleTap,
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex, int pointIndex) {
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
           // borderRadius: BorderRadius.all(Radius.circular(40)),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              bottomRight: Radius.circular(20)
            ),
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
                  Text(
                      "${duration(data.tripsByDate[pointIndex].duration)}",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )
                  ),
                  Text(' min',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )
                  ),
                ],
              ),
              TextButton(onPressed: (){

              },
                child: Text(
                    'Go to Trip Report',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  )
              ),)
            ],
          ),
        );
      },
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: displayHeight(context) * 0.4,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        //scrollDirection: Axis.horizontal,
        child: SfCartesianChart(
          //tooltipBehavior: CustomTooltipBehavior(),
          tooltipBehavior: tooltipBehavior,
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
                  horizontalTextAlignment: TextAnchor.start
                ),
              ]
          ),
         series: columnSeriesData,
        ),
      ),
    );
  }

  Widget? avgSpeedGraph(BuildContext context){

    final List<ChartSeries> columnSeriesData = [

      ColumnSeries<Trip,dynamic>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (Trip tripData, _) => tripData.date ?? "",
        yValueMapper: (Trip tripData, _) => tripData.tripsByDate[0].avgSpeed ?? 0.0,
        name: 'Avg Speed',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.6,
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
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex, int pointIndex) {
        print("data is: ${data.tripsByDate[pointIndex].avgSpeed}");
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)
            ),
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
                  Text(
                      '${data.tripsByDate[pointIndex].avgSpeed}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )
                  ),
                  Text('NM',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )
                  ),
                ],
              ),
              TextButton(onPressed: (){

              },
                child: Text(
                    'Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )
                ),)
            ],
          ),
        );
      },
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: displayHeight(context) * 0.4,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        //scrollDirection: Axis.horizontal,
        child: SfCartesianChart(
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            interval: 5,
            axisLine: AxisLine(width: 2),
            title: AxisTitle(text: 'Notical Miles'),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgSpeed}NM',
                    isVisible: true,
                    start: avgSpeed,
                    end: avgSpeed,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black,fontSize: 12),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start
                ),
              ]
          ),
          series: columnSeriesData,
        ),
      ),
    );
  }

  Widget? fuelUsageGraph(BuildContext context){

    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<Trip, String>(
        color: circularProgressColor,
        dataSource: triSpeedList,
        xValueMapper: (Trip tripData, _) => tripData.date,
        yValueMapper: (Trip tripData, _) => tripData.tripsByDate[0].fuelConsumption,
        name: 'Fuel Usage',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.6,
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
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex, int pointIndex) {
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)
            ),
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
                  Text(
                      '${data.tripsByDate[pointIndex].fuelConsumption}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )
                  ),
                  Text('Gal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )
                  ),
                ],
              ),
              TextButton(onPressed: (){

              },
                child: Text(
                    'Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )
                ),)
            ],
          ),
        );
      },
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: displayHeight(context) * 0.4,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        //scrollDirection: Axis.horizontal,
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
                    start: 10,
                    end: 10,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start
                ),
              ]
          ),
          series: columnSeriesData,
        ),
      ),
    );
  }

  Widget? powerUsageGraph(BuildContext context){

    final List<ChartSeries> columnSeriesData = [
      ColumnSeries<TripData, String>(
        color: circularProgressColor,
        dataSource: tripDataList,
        xValueMapper: (TripData tripData, _) => tripData.date,
        yValueMapper: (TripData tripData, _) => double.parse(tripData.startPosition[1]),
        name: 'Power Usage',
        dataLabelSettings: DataLabelSettings(isVisible: false),
        spacing: 0.6,
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
      builder: (dynamic data, dynamic point, dynamic series, int dataIndex, int pointIndex) {
        return Container(
          width: displayWidth(context) * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)
            ),
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
                  Text(
                      '${data.tripsByDate[pointIndex].avgPower}',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      )
                  ),
                  Text('Watts',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      )
                  ),
                ],
              ),
              TextButton(onPressed: (){

              },
                child: Text(
                    'Go to Trip Report',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    )
                ),)
            ],
          ),
        );
      },
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      height: displayHeight(context) * 0.4,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        //scrollDirection: Axis.horizontal,
        child: SfCartesianChart(
          tooltipBehavior: tooltipBehavior,
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            interval: 5,
            axisLine: AxisLine(width: 2),
            title: AxisTitle(text: 'Wats'),
              plotBands: [
                PlotBand(
                    text: 'avg ${avgFuelConsumption}gal',
                    isVisible: true,
                    start: 10,
                    end: 10,
                    borderWidth: 2,
                    borderColor: Colors.grey,
                    textStyle: TextStyle(color: Colors.black),
                    dashArray: <double>[3, 3],
                    horizontalTextAlignment: TextAnchor.start
                ),
              ]
          ),
          series: columnSeriesData,
          annotations: <CartesianChartAnnotation>[
            CartesianChartAnnotation(
              widget: Container(
                child: Text(
                  "avg 100W",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              x: 0.02,
              y: 23,
              coordinateUnit: CoordinateUnit.point,
              region: AnnotationRegion.chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget? filterByDate(BuildContext context){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: (){
                setState(() {
                  isStartDate = true;
                });
              },
              child: Container(
                //  color: dateBackgroundColor,
                width: displayWidth(context) * 0.3,
                height: displayWidth(context) * 0.14,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: dateBackgroundColor
                ),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Center(
                    child: Text(
                      "Start Date",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ),
              ),
            ),


            GestureDetector(
              onTap: (){
                setState(() {
                  isEndDate = true;
                });
              },
              child: Container(
                //  color: dateBackgroundColor,
                width: displayWidth(context) * 0.3,
                height: displayWidth(context) * 0.14,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: dateBackgroundColor
                ),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Center(
                    child: Text(
                      "End Date",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400
                      ),
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

        isStartDate! || isEndDate == true ?
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: displayWidth(context) * 0.045,right: displayWidth(context) * 0.045),
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
                    )
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: displayWidth(context) * 0.03,top: displayWidth(context) * 0.05),
                  child: Text(
                      "Select Day",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: displayWidth(context) * 0.045,right: displayWidth(context) * 0.045),
              child: TableCalendar(
                daysOfWeekVisible: true,
                focusedDay: selectedDate,
                firstDay: firstDate,
                lastDay: lastDate,
                onFormatChanged: (CalendarFormat _format){

                },
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
                        color: Colors.white)
                ),
                selectedDayPredicate: (DateTime date){
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
        ) : Container(),
      ],
    );
  }

  Widget? filterByTrip(BuildContext context){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.0),
          child: CommonDropDownFormFieldOne(
            context: context,
            value: selectedTrip,
            hintText: 'Select Trip*',
            labelText: '',
            onChanged: (String value) {
              // formKey.currentState!.validate();
            },
            dataSource: ['Trip1', 'Trip2', 'Trip3'],
            borderRadius: 10,
            padding: 6,
            textColor: Colors.black,
            textField: 'key',
            valueField: 'value',
            validator: (value) {
              if (value == null) {
                return 'Select trip';
              }
              return null;
            },
          ),
        ),

        ListView(
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding:  EdgeInsets.only(left: displayWidth(context) * 0.046),
              child: CustomLabeledCheckbox(
                label: 'Select All',
                value: parentValue != null ? parentValue! : false,
                onChanged: (value) {
                  if (value != null) {
                    // Checked/Unchecked
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
              itemCount: children!.length,
              itemBuilder: (context, index) => Column(
                children: [
                  Divider(),
                  CustomLabeledCheckboxOne(
                    label: children![index],
                    value: childrenValue![index],
                    tripId: tripIdList![index],
                    dateTime: dateTimeList![index],
                    onChanged: (value) {
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
    );
  }
}

class TripData {
  final String date;
  final List<dynamic> startPosition;

  TripData({required this.date, required this.startPosition});
}

class TripSpeed{
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