import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:performarine/common_widgets/trip_builder.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
// import 'package:performarine/common_widgets/Trip_builder.dart';
import 'package:performarine/common_widgets/vessel_builder.dart';
import 'package:performarine/models/trip.dart';
// import 'package:performarine/models/Trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/custom_drawer.dart';
import 'package:performarine/pages/trip/tripViewBuilder.dart';
import 'package:performarine/pages/tripStart.dart';
import 'package:performarine/pages/vessel_form.dart';
import 'package:performarine/pages/vessel_single_view.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();

  late CommonProvider commonProvider;

  Future<List<CreateVessel>> _getVessels() async {
    return await _databaseService.vessels();
  }

  Future<List<Trip>> _gettrips() async {
    return await _databaseService.trips();
  }
//ToDo: Vessel Name by Vessel Id
//   Future<String> _getVesselName() async {
//     List<CreateVessel> data= await _databaseService.getVesselNameByID("538b49e0-7ab5-11ed-8f52-89603b7614ba");
//     debugPrint("data:${data[0].name.toString()}");
//     return data[0].name.toString();
//   }

  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    commonProvider = context.read<CommonProvider>();
    commonProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(

        appBar: AppBar(
          centerTitle: true,
          title: Container(
            width: MediaQuery.of(context).size.width/2,
            // color: Colors.yellow,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center ,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/lognotitle.png",
                        height: 50,
                        width: 50,
                      ),
                      Text("Performarine")
                    ],
                  )),
                  // TextSpan(
                  //   text: " to add",
                  // ),
                ],
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: primaryColor,
            tabs: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Vessels'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Activity (4)'),
              ),
            ],
          ),
          backgroundColor: letsGetStartedButtonColor,
        ),
        drawer: const CustomDrawer(),

        body: TabBarView(
          children: [
            VesselBuilder(
              future: _getVessels(),
              onEdit: (value) async {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => VesselFormPage(vessel: value),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
              onTap: (value) async {
                {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => VesselSingleView(
                            vessel: value,
                          ),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                }
              },
              onDelete: _onVesselDelete,
            ),
            SingleChildScrollView(
              child: TripViewListing(future: _gettrips()),
              // TripBuilder(
              //   future: _gettrips(),
              // ),
            ),
          ],
        ),
        // floatingActionButton: SpeedDial(
        //   // marginBottom: 10, //margin bottom
        //   icon: Icons.menu, //icon on Floating action button
        //   activeIcon: Icons.close, //icon when menu is expanded on button
        //   backgroundColor:
        //       letsGetStartedButtonColor, //background color of button
        //   foregroundColor: Colors.white, //font color, icon color in button
        //   activeBackgroundColor:
        //       letsGetStartedButtonColor, //background color when menu is expanded
        //   activeForegroundColor: Colors.white,
        //   buttonSize: Size(55, 55),
        //   visible: true,
        //   closeManually: false,
        //   curve: Curves.bounceIn,
        //   overlayColor: Colors.black,
        //   overlayOpacity: 0.5,
        //   onOpen: () {}, // action when menu opens
        //   onClose: () {}, //action when menu closes
        //
        //   elevation: 8.0, //shadow elevation of button
        //   shape: CircleBorder(), //shape of button
        //
        //   children: [
        //     SpeedDialChild(
        //         backgroundColor: buttonBGColor,
        //         foregroundColor: Colors.white,
        //         label: 'Add Vessel',
        //         labelStyle: TextStyle(fontSize: 14.0),
        //         onTap: () {
        //           Navigator.of(context)
        //               .push(
        //                 MaterialPageRoute(
        //                   builder: (_) => PickImages(),
        //                   fullscreenDialog: true,
        //                 ),
        //               )
        //               .then((_) => setState(() {}));
        //         },
        //         // onLongPress: () {
        //         //   Navigator.of(context)
        //         //       .push(
        //         //         MaterialPageRoute(
        //         //           builder: (_) => VesselFormPage(),
        //         //           fullscreenDialog: true,
        //         //         ),
        //         //       )
        //         //       .then((_) => setState(() {}));
        //         // },
        //         child: Icon(Icons.add)),
        //     // ToDo: floating button elements
        //     // SpeedDialChild(
        //     //   child: FaIcon(FontAwesomeIcons.ship),
        //     //   backgroundColor: primaryColor,
        //     //   foregroundColor: Colors.white,
        //     //   label: 'Start Trip',
        //     //   labelStyle: TextStyle(fontSize: 14.0),
        //     //   onTap: () async{
        //     //     List<CreateVessel>?vessel=await _databaseService.getAllVessels();
        //     //     // print(vessel[0].vesselName);
        //     //     Navigator.of(context)
        //     //         .push(
        //     //       MaterialPageRoute(
        //     //         builder: (_) => StartTrip(vessels: vessel,context: context,),
        //     //         fullscreenDialog: true,
        //     //       ),
        //     //     );
        //     //   },
        //     //   onLongPress: () {
        //     //     Navigator.of(context)
        //     //         .push(
        //     //       MaterialPageRoute(
        //     //         builder: (_) => StartTrip(context: context,),
        //     //         fullscreenDialog: true,
        //     //       ),
        //     //     )
        //     //         .then((_) => setState(() {}));
        //     //   },
        //     // ),
        //
        //     // add more menu item children here
        //   ],
        // ),
      ),
    );
  }
}
