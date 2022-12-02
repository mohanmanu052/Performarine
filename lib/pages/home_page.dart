import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_sqflite_example/common_widgets/dog_builder.dart';
import 'package:flutter_sqflite_example/common_widgets/breed_builder.dart';
import 'package:flutter_sqflite_example/common_widgets/vessel_builder.dart';
import 'package:flutter_sqflite_example/models/breed.dart';
import 'package:flutter_sqflite_example/models/dog.dart';
import 'package:flutter_sqflite_example/pages/breed_form_page.dart';
import 'package:flutter_sqflite_example/pages/dogForm.dart';
import 'package:flutter_sqflite_example/pages/vessel_form.dart';
import 'package:flutter_sqflite_example/pages/vessel_single_view.dart';
import 'package:flutter_sqflite_example/services/database_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Dog>> _getDogs() async {
    return await _databaseService.dogs();
  }
  Future<List<CreateVessel>> _getVessels() async {
    // List<CreateVessel> result=await _databaseService.vessels();
    // debugPrint("result.toString():${jsonDecode(result[0].model.toString())}");
    return await _databaseService.vessels();
  }

  Future<List<Breed>> _gettrips() async {
    return await _databaseService.trips();
  }

  Future<void> _onDogDelete(Dog dog) async {
    await _databaseService.deleteDog(dog.id!);
    setState(() {});
  }
  Future<void> _onVesselDelete(CreateVessel vessel) async {
    await _databaseService.deleteVessel(vessel.id.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Performarine',style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          bottom: TabBar(
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
        ),
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
                  ).then((_) => setState(() {}));
                }
              },
              onTap:(value) async {
                {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => VesselSingleView(vessel: value,),
                      fullscreenDialog: true,
                    ),
                  ).then((_) => setState(() {}));
                }
              },
              onDelete: _onVesselDelete,
            ),
            // DogBuilder(
            //   future: _getDogs(),
            //   onEdit: (value) {
            //     {
            //       Navigator.of(context)
            //           .push(
            //             MaterialPageRoute(
            //               builder: (_) => VesselFormPage(dog: value),
            //               fullscreenDialog: true,
            //             ),
            //           )
            //           .then((_) => setState(() {}));
            //     }
            //   },
            //   onDelete: _onDogDelete,
            // ),
            BreedBuilder(
              future: _gettrips(),
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          // marginBottom: 10, //margin bottom
          icon: Icons.menu, //icon on Floating action button
          activeIcon: Icons.close, //icon when menu is expanded on button
          backgroundColor: Colors.teal, //background color of button
          foregroundColor: Colors.white, //font color, icon color in button
          activeBackgroundColor: Colors.blue, //background color when menu is expanded
          activeForegroundColor: Colors.white,
          buttonSize: Size(55,55),
          visible: true,
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          onOpen: () {}, // action when menu opens
          onClose: () {}, //action when menu closes

          elevation: 8.0, //shadow elevation of button
          shape: CircleBorder(), //shape of button

          children: [
            SpeedDialChild(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                label: 'Add Vessel',
                labelStyle: TextStyle(fontSize: 14.0),
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => VesselFormPage(),
                      fullscreenDialog: true,
                    ),
                  )
                      .then((_) => setState(() {}));
                },
                onLongPress: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => VesselFormPage(),
                      fullscreenDialog: true,
                    ),
                  )
                      .then((_) => setState(() {}));
                },
                child: Icon(Icons.add)
            ),
            SpeedDialChild(
              child: FaIcon(FontAwesomeIcons.ship),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: 'Start Trip',
              labelStyle: TextStyle(fontSize: 14.0),
              onTap: () async{
                List<CreateVessel>?vessel=await _databaseService.getAllVessels();
                // print(vessel[0].vesselName);
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => BreedFormPage(vessels: vessel,),
                    fullscreenDialog: true,
                  ),
                )
                    .then((_) => setState(() {}));
              },
              onLongPress: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => BreedFormPage(),
                    fullscreenDialog: true,
                  ),
                )
                    .then((_) => setState(() {}));
              },
            ),

            //add more menu item children here
          ],
        ),

      ),
    );
  }
}
