import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';

import '../../../common_widgets/utils/colors.dart';

class ReportsDataTable extends StatefulWidget {
  List<Map<String, dynamic>> tripList = [];
  List<Map<String, dynamic>> finalData = [];
  Orientation? orientation;
  Function(int index, dynamic personData, Orientation orientation)?
      onTapCallBack;
  dynamic globalkey;

  int? barIndex;

  ReportsDataTable(
      {super.key,
      required this.tripList,
      required this.finalData,
      this.onTapCallBack,
      this.barIndex = -1,
      this.globalkey,
      this.orientation});

  @override
  State<ReportsDataTable> createState() => ReportsDataTableState();
}

class ReportsDataTableState extends State<ReportsDataTable> {
  int selectedRowIndex = -1;
  int selectedBarIndex = -1;
  int? index;
  int? index2 = 0;
  bool isToolTipShown = false;

  Function(int index1) setSelectedRowIndex = (selectedRowIndex) {
    print('the selected row index was-------------' +
        selectedRowIndex.toString());
  };

  dynamic dateWithZeros(String timesString) {
    String dateString = timesString;
    List<String> dateParts = dateString.split('-'); // ['3', '3', '2023']
    String day = dateParts[0].padLeft(2, '0'); // '03'
    String month = dateParts[1].padLeft(2, '0'); // '03'
    String year = dateParts[2]; // '2023'
    String formattedDate = '$year-$day-$month'; // '2023-03-03'
    return formattedDate;
  }

  // @override
  // void didUpdateWidget(covariant ReportsDataTable oldWidget) {
  //  selectedBarIndex = widget.barIndex!;
  //   super.didUpdateWidget(oldWidget);
  // }
  @override
  void didUpdateWidget(covariant ReportsDataTable oldWidget) {
    // Use the selectedBarIndex from the widget instead of a local variable
    selectedBarIndex = widget.barIndex!;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    print('the report datatable index was----------' +
        selectedRowIndex.toString());

    return SingleChildScrollView(
      key: widget.globalkey,
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
                    style: TextStyle(
                      color: tableHeaderColor,
                      fontFamily: dmsans,
                    ),
                  ),
                ),
              ),
            ),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Duration',
                    style:
                        TextStyle(color: tableHeaderColor, fontFamily: dmsans),
                    textAlign: TextAlign.center),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Avg Speed ($speedKnot)',
                    style:
                        TextStyle(color: tableHeaderColor, fontFamily: dmsans),
                    textAlign: TextAlign.center),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Fuel Usage ($liters)',
                    style:
                        TextStyle(color: tableHeaderColor, fontFamily: dmsans),
                    textAlign: TextAlign.center),
              ),
            )),
            DataColumn(
                label: Expanded(
              child: Center(
                child: Text('Power Usage ($watt)',
                    style:
                        TextStyle(color: tableHeaderColor, fontFamily: dmsans),
                    textAlign: TextAlign.center),
              ),
            )),
          ],
          rows: [
            ...widget.tripList.map((person) => DataRow(

//                 onSelectChanged: (isSelected) {
//     setState(() {
//       selectedRowIndex = isSelected??false ? widget.tripList.indexOf(person) : -1;
//     });
//  },
                    color: WidgetStateProperty.all(
                      selectedRowIndex == widget.tripList.indexOf(person)
                          ? reroprtHighlightBackgroundColor // Change the background color for the selected row
                          : null, // Use null to keep the default background color
                    ),
                    cells: [
                      DataCell(
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                                dateWithZeros(
                                  person['date'],
                                )!,
                                style: TextStyle(
                                    color: Colors.black, fontFamily: dmsans),
                                textAlign: TextAlign.center),
                          ), onTap: () {
                        widget.onTapCallBack!(widget.tripList.indexOf(person),
                            person, widget.orientation ?? Orientation.portrait);
                        setState(() {
                          selectedRowIndex = widget.tripList.indexOf(person);
                        });

                      }),
                      DataCell(
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                person['duration']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontFamily: dmsans),
                              )), onTap: () {
                        widget.onTapCallBack!(widget.tripList.indexOf(person),
                            person, widget.orientation ?? Orientation.portrait);

                        setState(() {
                          selectedRowIndex = widget.tripList.indexOf(person);
                        });


                      }),
                      DataCell(
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${person['avgSpeed']!}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontFamily: dmsans),
                              )), onTap: () {
                        widget.onTapCallBack!(widget.tripList.indexOf(person),
                            person, widget.orientation ?? Orientation.portrait);

                        setState(() {
                          selectedRowIndex = widget.tripList.indexOf(person);
                        });
                      }),
                      DataCell(
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${person['fuelUsage']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontFamily: dmsans),
                              )), onTap: () {
                        widget.onTapCallBack!(widget.tripList.indexOf(person),
                            person, widget.orientation ?? Orientation.portrait);

                        setState(() {
                          selectedRowIndex = widget.tripList.indexOf(person);
                        });
                      }),
                      DataCell(
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${person['powerUsage']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontFamily: dmsans),
                              )), onTap: () {
                        widget.onTapCallBack!(widget.tripList.indexOf(person),
                            person, widget.orientation ?? Orientation.portrait);

                        setState(() {
                          selectedRowIndex = widget.tripList.indexOf(person);
                        });
                      }),
                    ])),
            ...widget.finalData.map((e) => DataRow(cells: [
                  DataCell(
                    Text(
                      'Average',
                      style: TextStyle(
                          color: circularProgressColor,
                          fontFamily: dmsans,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text(
                      e['duration']!,
                      style: TextStyle(
                          color: circularProgressColor,
                          fontFamily: dmsans,
                          fontWeight: FontWeight.w800),
                    ),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('${e['avgSpeed'].toStringAsFixed(2)!}',
                        style: TextStyle(
                            color: circularProgressColor,
                            fontFamily: dmsans,
                            fontWeight: FontWeight.w800)),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('${e['fuelUsage']!}',
                        style: TextStyle(
                            color: circularProgressColor,
                            fontFamily: dmsans,
                            fontWeight: FontWeight.w800)),
                  )),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('${e['powerUsage']!}',
                        style: TextStyle(
                            color: circularProgressColor,
                            fontFamily: dmsans,
                            fontWeight: FontWeight.w800)),
                  )),
                ]))
          ],
        ),
      ),
    );
  }
}
