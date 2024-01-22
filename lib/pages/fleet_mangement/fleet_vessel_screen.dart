import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/services/database_service.dart';
import 'package:screenshot/screenshot.dart';

class FleetVesselScreen extends StatefulWidget {
  const FleetVesselScreen({super.key});

  @override
  State<FleetVesselScreen> createState() => _FleetVesselScreenState();
}

class _FleetVesselScreenState extends State<FleetVesselScreen> {
GlobalKey<ScaffoldState> _scafoldKey=GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late Future<List<CreateVessel>> getVesselFuture;


@override
  void initState() {
        getVesselFuture = _databaseService.vessels();

    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        key: _scafoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
            context: context,
            text: 'Fleet Vessels',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.045,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async{
                await  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: backgroundColor,
                child: FutureBuilder<List<CreateVessel>>(
                  future: getVesselFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(circularProgressColor),
                        ),
                      );
                    }
                    Utils.customPrint('Fleet Vessel HAS DATA: ${snapshot.hasData}');
                    Utils.customPrint('Fleet Vessel Error: ${snapshot.error}');
                    Utils.customPrint('Fleet Vessel IsError: ${snapshot.hasError}');
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: displayHeight(context) * 0.43),
                          child: Center(
                            child: commonText(
                                context: context,
                                text: 'No vessels available'.toString(),
                                fontWeight: FontWeight.w500,
                                textColor: Colors.black,
                                textSize: displayWidth(context) * 0.04,
                                textAlign: TextAlign.start),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              // height: displayHeight(context),
                              color: backgroundColor,
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 8, bottom: 10),
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                primary: false,
                                shrinkWrap: true,
                                //physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final vessel = snapshot.data![index];
                                  return snapshot.data![index].vesselStatus == 0
                                      ? vesselSingleViewCard(context, vessel,
                                          (CreateVessel value) {

                                          }, _scafoldKey)
                                      : SizedBox();
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return Container();
                  },
                ),
              ),

              SizedBox(
                height: displayWidth(context) * 0.04,
              )
            ],
          ),
        ),
        

          );

  }
}