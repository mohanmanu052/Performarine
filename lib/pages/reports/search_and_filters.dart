import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';

import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/widgets/common_drop_down_one.dart';
import '../../common_widgets/widgets/custom_labled_checkbox.dart';
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
        body: Padding(
            padding:  EdgeInsets.only(
                left: displayWidth(context) * 0.05,
              top: displayWidth(context) * 0.05,
              right: displayWidth(context) * 0.05
            ),
            child: SingleChildScrollView(
              child: Column(
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
                )
              ],
              ),
            ),
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
}
