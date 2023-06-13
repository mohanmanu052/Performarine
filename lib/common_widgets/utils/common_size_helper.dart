
import 'package:flutter/material.dart';

//Returns the size of the screen
Size displaySize(BuildContext context) {
  return MediaQuery.of(context).size;
}

//Returns height of the screen
double displayHeight(BuildContext context) {
  return displaySize(context).height;
}

//Returns width of the screen
double displayWidth(BuildContext context) {
  return displaySize(context).width;
}