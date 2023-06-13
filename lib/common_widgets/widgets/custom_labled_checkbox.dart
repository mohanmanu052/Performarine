import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';

enum CheckboxType {
  Parent,
  Child,
}

// Custom labeled check box on reports module
@immutable
class CustomLabeledCheckbox extends StatelessWidget {
  CustomLabeledCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.checkboxType: CheckboxType.Child,
    required this.activeColor,
  })  : assert(label != null),
        assert(checkboxType != null),
        assert(
        (checkboxType == CheckboxType.Child && value != null) ||
            checkboxType == CheckboxType.Parent,
        ),
        tristate = checkboxType == CheckboxType.Parent ? true : false;

  String label;
  bool value;
  bool tristate;
  ValueChanged<bool> onChanged;
  CheckboxType checkboxType;
  Color activeColor;

  void _onChanged() {
    if (value != null) {
      onChanged(!value);
    } else {
      onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return InkWell(
      onTap: _onChanged,
      child: Padding(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Row(
          children: <Widget>[
            checkboxType == CheckboxType.Parent
                ? SizedBox(width: 0)
                : SizedBox(width: displayWidth(context) * 0.08),
            Checkbox(
              tristate: tristate,
              value: value,
              onChanged: (_) {
                _onChanged();
              },
              activeColor: activeColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }
}

// Custom labeled check box to select all trips on reports module
@immutable
class CustomLabeledCheckboxOne extends StatelessWidget {
  CustomLabeledCheckboxOne(
      {required this.label,
        required this.value,
        required this.onChanged,
        this.checkboxType: CheckboxType.Child,
        required this.activeColor,
        this.dateTime,
        this.tripId})
      : assert(label != null),
        assert(checkboxType != null),
        assert(
        (checkboxType == CheckboxType.Child && value != null) ||
            checkboxType == CheckboxType.Parent,
        ),
        tristate = checkboxType == CheckboxType.Parent ? true : false;

  String label;
  bool value;
  bool tristate;
  ValueChanged<bool> onChanged;
  CheckboxType checkboxType;
  Color activeColor;
  String? dateTime;
  String? tripId;

  void _onChanged() {
    if (value != null) {
      onChanged(!value);
    } else {
      onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ListTile(
      onTap: _onChanged,
      leading: Checkbox(
        tristate: tristate,
        value: value,
        onChanged: (_) {
          _onChanged();
        },
        activeColor: activeColor,
      ),
      title: Text(
        label,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: inter,
            fontSize: displayWidth(context) * 0.041,
            color: blutoothDialogTxtColor),
      ),
      subtitle: Text(
        "$tripId",
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: inter,
            fontSize: displayWidth(context) * 0.031,
            color: blutoothDialogTxtColor),
      ),
      trailing: Text(
        dateTime != null ? dateTime! : "",
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: inter,
            fontSize: displayWidth(context) * 0.028,
            color: dateColor),
      ),
    );

    /* return InkWell(
      onTap: _onChanged,
      child: Padding(
        padding: EdgeInsets.only(left: 0, right: 0),
        child: Row(
          children: <Widget>[
            checkboxType == CheckboxType.Parent
                ? SizedBox(width: 0)
                : SizedBox(width: 0),
            Checkbox(
              tristate: tristate,
              value: value,
              onChanged: (_) {
                _onChanged();
              },
              activeColor: activeColor ?? themeData.toggleableActiveColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: themeData.textTheme.labelLarge,
            )
          ],
        ),
      ),
    ); */
  }
}