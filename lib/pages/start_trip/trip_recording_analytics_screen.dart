import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';

import '../../common_widgets/widgets/common_widgets.dart';

class TripRecordingAnalyticsScreen extends StatefulWidget {
  const TripRecordingAnalyticsScreen({super.key});

  @override
  State<TripRecordingAnalyticsScreen> createState() => _TripRecordingAnalyticsScreenState();
}

class _TripRecordingAnalyticsScreenState extends State<TripRecordingAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 17, right: 17, top: 17, bottom: 17),
      child: Column(
        children: [

          SizedBox(height: displayHeight(context) * 0.05,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Container(
                width: displayWidth(context)* 0.43,
                height: displayHeight(context) * 0.13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xffECF3F9)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    commonText(
                      context: context,
                      text: 'Distance',
                      fontWeight: FontWeight.w400,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.032,
                    ),

                    SizedBox(height: displayHeight(context) * 0.005,),

                    commonText(
                      context: context,
                      text: '53.4',
                      fontWeight: FontWeight.w700,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.06,
                    ),

                    SizedBox(height: displayHeight(context) * 0.005,),

                    commonText(
                      context: context,
                      text: 'Nautical Miles',
                      fontWeight: FontWeight.w400,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.028,
                    ),
                  ],
                ),
              ),

              SizedBox(width: displayWidth(context) * 0.02,),

              Container(
                width: displayWidth(context)* 0.43,
                height: displayHeight(context) * 0.13,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffECF3F9)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    commonText(
                      context: context,
                      text: 'Current Speed',
                      fontWeight: FontWeight.w400,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.032,
                    ),

                    SizedBox(height: displayHeight(context) * 0.005,),

                    commonText(
                      context: context,
                      text: '53.4',
                      fontWeight: FontWeight.w700,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.06,
                    ),

                    SizedBox(height: displayHeight(context) * 0.005,),

                    commonText(
                      context: context,
                      text: 'KT/Hr',
                      fontWeight: FontWeight.w400,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.028,
                    ),
                  ],
                ),
              )

            ],
          ),

          SizedBox(height: displayHeight(context) * 0.03,),

          Container(
            width: displayWidth(context),
            height: displayHeight(context) * 0.13,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xffECF3F9)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                commonText(
                  context: context,
                  text: 'Total Time',
                  fontWeight: FontWeight.w400,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.032,
                ),

                SizedBox(height: displayHeight(context) * 0.005,),

                commonText(
                  context: context,
                  text: '2h 32m',
                  fontWeight: FontWeight.w700,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.06,
                ),

                SizedBox(height: displayHeight(context) * 0.005,),

                commonText(
                  context: context,
                  text: 'Nautical Miles',
                  fontWeight: FontWeight.w400,
                  textColor: Colors.black,
                  textSize: displayWidth(context) * 0.028,
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}
