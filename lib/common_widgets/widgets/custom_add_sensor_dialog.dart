import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/pages/lpr_view/lpr_view_screen.dart';

class CustomAddSensorDialog extends StatefulWidget {
  Function(LprDataModel)? positiveBtnOnTap;

  @override
  State<CustomAddSensorDialog> createState() => _CustomAddSensorDialogState();

  CustomAddSensorDialog({
    this.positiveBtnOnTap,
  });
}

class _CustomAddSensorDialogState extends State<CustomAddSensorDialog> {
  bool isPositiveBtnClick = false, isNegativeBtnClick = false;

  bool? userConfig = false, isError = false;

  // List<Map<String, dynamic>> sensorsList = ['Shaft RPM', 'Strain', 'RPM',];
  List<Map<String, dynamic>> sensorsList = [
    //{"unit": 'UTC', "type": 'LPR Time'},
    {"unit": 'RPM', "type": 'Shaft RPM'},
    {"unit": 'mV/v', "type": 'Strain'},
    {"unit": 'RPM', "type": 'RPM'},
  ];

  Map<String, dynamic>? dropdownValue;

  final _formKey = GlobalKey<FormState>();

  TextEditingController tagController = TextEditingController();

  FocusNode tagFocusNode = FocusNode();
  LprDataModel lprDataModel = LprDataModel();

  @override
  initState() {
    super.initState();
    // dropdownValue = {"unit": 'RPM', "type": 'Shaft RPM'};
  }

  dialogContent(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            return Stack(
              children: [
                Container(
                  width: orientation == Orientation.portrait
                      ? displayWidth(context)
                      : displayWidth(context) / 2,
                  margin: EdgeInsets.all(10),
                  decoration: new BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // To make the card compact
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: commonText(
                              text: 'Add new sensor',
                              context: context,
                              textSize: orientation == Orientation.portrait
                                  ? displayWidth(context) * 0.045
                                  : displayWidth(context) * 0.030,
                              textColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.03,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: dropDownBackgroundColor),
                          child: DropdownButtonFormField<Map<String, dynamic>>(
                            value: dropdownValue,
                            hint: commonText(
                                text: 'Select Sensor Type',
                                context: context,
                                textSize: orientation == Orientation.portrait
                                    ? displayWidth(context) * 0.038
                                    : displayWidth(context) * 0.030,
                                textColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500),
                            onChanged: (Map<String, dynamic>? newValue) {
                              setter(() {
                                dropdownValue = newValue!;
                              });
                              lprDataModel.type = newValue!['type'];
                              lprDataModel.unit = newValue['unit'];
                            },
                            items: sensorsList.map((item) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: item,
                                child: commonText(
                                    text: item['type'] ?? '',
                                    context: context,
                                    textSize: orientation == Orientation.portrait
                                        ? displayWidth(context) * 0.04
                                        : displayWidth(context) * 0.030,
                                    textColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w400),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Select Sensor';
                              }
                              return null;
                            },

                            // add extra sugar..
                            icon: Icon(Icons.keyboard_arrow_down_rounded),
                            iconSize: 24,
                            //underline: SizedBox(),
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.015,
                        ),
                        Form(
                          key: _formKey,
                          child: CommonTextField(
                              controller: tagController,
                              focusNode: tagFocusNode,
                              labelText: 'Enter Tag',
                              hintText: '',
                              suffixText: null,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              maxLength: 32,
                              prefixIcon: null,
                              requestFocusNode: null,
                              obscureText: false,
                              onTap: () {},
                              onChanged: (String value) {},
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Enter Tag';
                                }
                                return null;
                              },
                              onSaved: (String value) {
                                // CustomLogger().logWithFile(Level.info, "vessel name $value -> $page");
                                // Utils.customPrint(value);
                              }),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.03,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CommonButtons.getAcceptButton(
                                  'Cancel', context, Colors.transparent, () {
                                Navigator.pop(context);
                              },
                                  displayWidth(context) * 0.3,
                                  displayHeight(context) * 0.054,
                                  Colors.transparent,
                                  blueColor,
                                  displayHeight(context) * 0.018,
                                  Colors.transparent,
                                  '',
                                  fontWeight: FontWeight.w500),
                              Container(
                                padding: EdgeInsets.all(8),
                                child: CommonButtons.getActionButton(
                                  title: 'Add',
                                  context: context,
                                  fontSize: 15,
                                  textColor: Colors.white,
                                  buttonPrimaryColor: blueColor,
                                  borderColor: blueColor,
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      lprDataModel.value =
                                          tagController.text.trim();
                                      if (widget.positiveBtnOnTap != null) {
                                        widget.positiveBtnOnTap!(lprDataModel);
                                      }
                                    }
                                  },
                                  width: displayWidth(context) * 0.3,
                                  height: displayHeight(context) * 0.050,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white, width: 1),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
