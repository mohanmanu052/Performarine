import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/pages/home_page.dart';

import 'common_widgets/utils/common_size_helper.dart';
import 'common_widgets/widgets/common_widgets.dart';

class NewTripAnalyticsScreen extends StatefulWidget {
  const NewTripAnalyticsScreen({super.key});

  @override
  State<NewTripAnalyticsScreen> createState() => _NewTripAnalyticsScreenState();
}

class _NewTripAnalyticsScreenState extends State<NewTripAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: Container(
          child: commonText(
            context: context,
            text: 'Trip Recording',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.045,
          ),
        ),
        actions: [
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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 17),
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
