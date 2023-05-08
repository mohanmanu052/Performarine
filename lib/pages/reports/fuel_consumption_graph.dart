import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/widgets/common_drop_down_one.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
import '../home_page.dart';
import 'package:table_calendar/table_calendar.dart';


class FuelConsumptionGraph extends StatefulWidget {
  const FuelConsumptionGraph({Key? key}) : super(key: key);

  @override
  State<FuelConsumptionGraph> createState() => _FuelConsumptionGraphState();
}

class _FuelConsumptionGraphState extends State<FuelConsumptionGraph> {

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

  final List<ChartData> chartData = <ChartData>[
    ChartData('12 Jan', 55),
    ChartData('15 Jan', 55),
    ChartData('20 Jan', 55),
    ChartData('23 Jan', 55),
    ChartData('25 Jan', 55),
    ChartData('26 Jan', 55),
    ChartData('27 Jan', 55),
  ];



  void _manageTristate(int index, bool value) {
    setState(() {
      if (value) {
        // selected
        childrenValue![index] = true;
        // Checking if all other children are also selected -
        if (childrenValue!.contains(false)) {
          // No. Parent -> tristate.
          parentValue = null;
        } else {
          // Yes. Select all.
          _checkAll(true);
        }
      } else {
        // unselected
        childrenValue![index] = false;
        // Checking if all other children are also unselected -
        if (childrenValue!.contains(true)) {
          // No. Parent -> tristate.
          parentValue = null;
        } else {
          // Yes. Unselect all.
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

  @override
  void initState() {
    // _controller = CalendarController();
    parentValue = false;


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

    /*
    * There are four children, so there should be a list of 4 bool values to
    * manage their states. This generates and assigns the
    * _childrenValue = [false, false, false, false].
    * */
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

                        /* Container(
                    margin: EdgeInsets.only(bottom: displayHeight(context) * 0.005),
                    child: InputDecorator(
                      decoration: const InputDecoration(border: OutlineInputBorder(borderSide:
                      BorderSide(width: 1.5, color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(18)))),
                     /* decoration: InputDecoration(
                        labelText: "",
                        labelStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? "Select Vessel*" == 'User SubRole'
                                ? Colors.black
                                : Colors.white
                                : Colors.grey[500],
                            fontSize: displayWidth(context) * 0.034,
                            fontFamily: inter,
                            fontWeight: FontWeight.w500),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(width: 1.5, color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(width: 1.5, color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.5,
                                color: Colors.red.shade300.withOpacity(0.7)),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        errorStyle: TextStyle(
                            fontFamily: inter,
                            fontSize: displayWidth(context) * 0.025),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.5,
                                color: Colors.red.shade300.withOpacity(0.7)),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),*/
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? "Select Vessel*" == 'User SubRole'
                                ? Colors.black
                                : Colors.white
                                : Colors.black,
                          ),
                          value: selectedVessel,
                          hint: Text("Select Vessel*"),
                          items: <String>['Vessel1', 'Vessel2', 'Vessel3', 'Vessel4']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          }).toList(),
                          // Step 5.
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedVessel = newValue!;
                            });
                          },
                        ),
                      ),
                  ),
                  ) */

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
              graph(context)!,

              table(context)!,

              SizedBox(height: displayWidth(context) * 0.08,),
            ],
          ),
        ),
      ),
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
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Trip Details')),
            DataColumn(label: Text('Duration')),
            DataColumn(label: Text('Avg Speed')),
            DataColumn(label: Text('Fuel Usage')),
            DataColumn(label: Text('Power Usage')),
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
              DataCell(Text(e['date']!)),
              DataCell(Text(e['tripDetails']!)),
              DataCell(Text(e['duration']!)),
              DataCell(Text(e['avgSpeed']!)),
              DataCell(Text(e['fuelUsage']!)),
              DataCell(Text(e['powerUsage']!)),
            ]))

          ],
        ),
      ),
    );
  }

  Widget? graph(BuildContext context){
    final double average =
        chartData.fold(0, (sum, data) => (num.tryParse(sum.toString())!) + data.y) / chartData.length;
    TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true,
      color: Colors.grey.withOpacity(0),
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
                      '237',
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
          //legend: Legend(isVisible: true),
          tooltipBehavior: tooltipBehavior,
          // tooltipBehavior: TooltipBehavior(
          //   color: Colors.black45,
          //     enable: true,
          // ),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            labelFormat: ' gal',
            axisLine: AxisLine(width: 2),
            title: AxisTitle(text: 'Galance'),
            majorTickLines: MajorTickLines(size: 8),
            interval: 10,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            labelIntersectAction: AxisLabelIntersectAction.multipleRows,
            labelStyle: TextStyle(fontSize: 14),
          ),
          series:[
            ColumnSeries<ChartData, String>(
              color: circularProgressColor,
              name: 'Series 1',
              dataLabelSettings: DataLabelSettings(isVisible: false),
              spacing: 0.1,
              dataSource: [
                ChartData('12 Jan', 10),
                ChartData('15 Jan', 20),
                ChartData('20 Jan', 30),
                ChartData('23 Jan', 40),
                ChartData('25 Jan', 50),
                ChartData('26 Jan', 30),
                ChartData('27 Jan', 40),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
            ),
            ColumnSeries<ChartData, String>(
              color: tripColumnBarColor,
              name: 'Series 2',
              dataLabelSettings: DataLabelSettings(isVisible: false),
              spacing: 0.1,
              dataSource: [
                ChartData('12 Jan', 20),
                ChartData('15 Jan', 30),
                ChartData('20 Jan', 40),
                ChartData('23 Jan', 50),
                ChartData('25 Jan', 60),
                ChartData('26 Jan', 50),
                ChartData('27 Jan', 40),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
            ),
            ColumnSeries<ChartData, String>(
              color: tripColumnBar1Color,
              name: 'Series 2',
              dataLabelSettings: DataLabelSettings(
                  isVisible: false
              ),
              spacing: 0.1,
              dataSource: [
                ChartData('12 Jan', 30),
                ChartData('15 Jan', 40),
                ChartData('20 Jan', 50),
                ChartData('23 Jan', 60),
                ChartData('25 Jan', 70),
                ChartData('26 Jan', 50),
                ChartData('27 Jan', 60),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
            ),
            LineSeries<ChartData, String>(
              color: Colors.grey,
              yAxisName: "Galance",
              dashArray: [3, 3],
              name: 'Fuel Consumption',
              dataSource: [
                ChartData('12 Jan', 55),
                ChartData('15 Jan', 55),
                ChartData('20 Jan', 55),
                ChartData('23 Jan', 55),
                ChartData('25 Jan', 55),
                ChartData('26 Jan', 55),
                ChartData('27 Jan', 55),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              markerSettings: MarkerSettings(isVisible: false),
              /* trendlines: <Trendline>[
                Trendline(
                  type: TrendlineType.linear,
                  width: 2,
                  color: Colors.grey,
                  dashArray: <double>[3, 3],
                ),
              ], */
            ),
          ],

          annotations: <CartesianChartAnnotation>[
            CartesianChartAnnotation(
              /* widget: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.red,
                      ),
                      width: 50,
                      height: 20,
                      child: Center(
                        child: Text(
                          //'Avg: ${getAverage(_chartData).toStringAsFixed(1)}',
                          "Avg: 123 gal",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ), */
              widget: Container(
                child: Text(
                  "Avg 123 gal",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              x: 0.5,
              y: 60,
              coordinateUnit: CoordinateUnit.point,
              region: AnnotationRegion.chart,
            ),
          ],

          /* annotations: <CartesianChartAnnotation>[
              CartesianChartAnnotation(
                widget: Text(
                 // 'Avg: ${average.toStringAsFixed(2)}',
                  'Avg: 123 cal',
                  style: TextStyle(color: Colors.yellow,fontSize: 20),
                ),
                coordinateUnit: CoordinateUnit.point,
               // coordinateType: AnnotationCoordinateType.horizontal,
                x: 'Jan',
                y: average,
              ),
            ] */
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
                      _manageTristate(index, value);
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

  double getAverage(List<ChartData> data) {
    double sum = 0;
    data.forEach((element) => sum += element.y);
    return sum / data.length;
  }
}

class ChartData {
  String x;
  double y;

  ChartData(this.x, this.y);
}
