import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';

import '../utils/colors.dart';

//Custom drop down form field
class CommonDropDownFormField extends FormField<dynamic> {
  final BuildContext? context;
  final String? titleText;
  final String? hintText;
  final String? labelText;
  final bool? required;
  final String? errorText;
  final String? value;
  final List<String>? dataSource;
  final FormFieldValidator<dynamic>? validator;
  final String? textField;
  final String? valueField;
  final Function? onChanged;
  final double? borderRadius;
  final double? padding;
  final Color? textColor;

  CommonDropDownFormField({
    FormFieldSetter<dynamic>? onSaved,
    this.validator,
    this.context,
    this.titleText = 'Title',
    this.hintText = 'Select one option',
    this.labelText,
    this.required = false,
    this.errorText = 'Please select one option',
    this.value,
    this.dataSource,
    this.textField,
    this.valueField,
    this.onChanged,
    this.borderRadius,
    this.padding,
    this.textColor,
  }) : super(
          onSaved: onSaved,
          //autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: value == '' ? null : value,
          builder: (FormFieldState<dynamic> state) {
            return Container(
              margin: EdgeInsets.only(bottom: displayHeight(context!) * 0.005),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText,
                  labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? hintText == 'User SubRole'
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
                ),
                child: DropdownButtonFormField<String>(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  dropdownColor: Theme.of(context).brightness == Brightness.dark
                      ? hintText == 'User SubRole'
                          ? Colors.white
                          : Colors.black
                      : Colors.white,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey,
                        fontSize: displayWidth(context) * 0.032,
                        fontFamily: inter),
                    filled: true,
                    fillColor: dropDownBackgroundColor,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1.5,
                            color: dropDownBackgroundColor),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1.5,
                            color: dropDownBackgroundColor),
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
                  ),
                  isExpanded: true,
                  isDense: true,
                  validator: validator,
                  icon: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? hintText == 'User SubRole'
                              ? Colors.black
                              : Colors.white
                          : textColor,
                    ),
                  ),
                  value: value,
                  onChanged: (String? item) {
                    state.didChange(item);
                    onChanged!(item);
                  },
                  items: dataSource!.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                            fontSize: displayWidth(context) * 0.04,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? hintText == 'User SubRole'
                                        ? Colors.black
                                        : Colors.white
                                    : textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
}

class CommonMapDropDownFormField extends FormField<dynamic> {
  final BuildContext? context;
  final String? titleText;
  final String? hintText;
  final String? labelText;
  final bool? required;
  final String? errorText;
  final String? value;
  final List<Map<String, dynamic>>? dataSource;
  final FormFieldValidator<dynamic>? validator;
  final String? textField;
  final String? valueField;
  final Function? onChanged;
  final double? borderRadius;
  final double? padding;
  final Color? textColor;

  CommonMapDropDownFormField({
    FormFieldSetter<dynamic>? onSaved,
    this.validator,
    this.context,
    this.titleText = 'Title',
    this.hintText = 'Select one option',
    this.labelText,
    this.required = false,
    this.errorText = 'Please select one option',
    this.value,
    this.dataSource,
    this.textField,
    this.valueField,
    this.onChanged,
    this.borderRadius,
    this.padding,
    this.textColor,
  }) : super(
    onSaved: onSaved,
    //autovalidateMode: AutovalidateMode.onUserInteraction,
    initialValue: value == '' ? null : value,
    builder: (FormFieldState<dynamic> state) {
      return Container(
        margin: EdgeInsets.only(bottom: displayHeight(context!) * 0.005),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? hintText == 'User SubRole'
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
          ),
          child: DropdownButtonFormField<String>(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            dropdownColor: Theme.of(context).brightness == Brightness.dark
                ? hintText == 'User SubRole'
                ? Colors.white
                : Colors.black
                : Colors.white,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey,
                  fontSize: displayWidth(context) * 0.032,
                  fontFamily: inter),
              filled: true,
              fillColor: dropDownBackgroundColor,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1.5,
                      color: dropDownBackgroundColor),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1.5,
                      color: dropDownBackgroundColor),
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
            ),
            isExpanded: true,
            isDense: true,
            validator: validator,
            icon: Center(
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).brightness == Brightness.dark
                    ? hintText == 'User SubRole'
                    ? Colors.black
                    : Colors.white
                    : textColor,
              ),
            ),
            value: value,
            onChanged: (String? item) {
              state.didChange(item);
              onChanged!(item);
            },
            items: dataSource!.map((Map<String, dynamic> item) {
              return DropdownMenuItem<String>(
                value: item[valueField],
                child: Text(
                  item[textField],
                  style: TextStyle(
                      fontSize: displayWidth(context) * 0.04,
                      color:
                      Theme.of(context).brightness == Brightness.dark
                          ? hintText == 'User SubRole'
                          ? Colors.black
                          : Colors.white
                          : textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}