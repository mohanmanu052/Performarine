import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/services/database_service.dart';

class RetiredVesselsScreen extends StatefulWidget {
  const RetiredVesselsScreen({Key? key}) : super(key: key);

  @override
  State<RetiredVesselsScreen> createState() => _RetiredVesselsScreenState();
}

class _RetiredVesselsScreenState extends State<RetiredVesselsScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final DatabaseService _databaseService = DatabaseService();

  late Future<List<CreateVessel>> getVesselFuture;

  bool isUnretire = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getVesselFuture = _databaseService.retiredVessels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          text: 'Retired Vessels',
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
          textSize: displayWidth(context) * 0.045,
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
        backgroundColor: commonBackgroundColor,
      ),
      body: Container(
        color: Colors.white,
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
            Utils.customPrint('HAS DATA: ${snapshot.hasData}');
            Utils.customPrint('HAS DATA: ${snapshot.error}');
            Utils.customPrint('HAS DATA: ${snapshot.hasError}');
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: commonText(
                      context: context,
                      text: 'No vessels available'.toString(),
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.start),
                );
              } else {
                return Container(
                  color: commonBackgroundColor,
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 70),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vessel = snapshot.data![index];
                      return snapshot.data![index].vesselStatus == 0
                          ? vesselSingleViewCard(context, vessel,
                              (CreateVessel value) {}, scaffoldKey)
                          : SizedBox();
                    },
                  ),
                );
              }
            }
            return Container();
          },
        ),
      ),
    );
  }
}
