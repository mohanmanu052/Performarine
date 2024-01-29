import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/reports_module/reports.dart';

class FleetReports extends StatefulWidget {
  const FleetReports({super.key});

  @override
  State<FleetReports> createState() => _FleetReportsState();
}

class _FleetReportsState extends State<FleetReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: false,
          title: commonText(
              context: context,
              
              text: 'Fleet Reports',
              fontWeight: FontWeight.w600,
              textColor: Colors.black,
              textSize: 18,
              textAlign: TextAlign.start),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            )
          ],
        ),

      body: Column(
children: [
Expanded(child: ReportsModule(isTypeFleet: true,))
],
  
),
      
    );
  }
}