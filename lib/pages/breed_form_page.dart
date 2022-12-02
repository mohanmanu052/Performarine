import 'package:flutter/material.dart';
import 'package:flutter_sqflite_example/models/breed.dart';
import 'package:flutter_sqflite_example/models/dog.dart';
import 'package:flutter_sqflite_example/services/database_service.dart';

class BreedFormPage extends StatefulWidget {
 final List<CreateVessel>? vessels;

  const BreedFormPage({Key? key,this.vessels}) : super(key: key);

  @override
  _BreedFormPageState createState() => _BreedFormPageState();
}

class _BreedFormPageState extends State<BreedFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _controller = new TextEditingController();
  // List<CreateVessel>? vessels;
  var items = ['Working a lot harder', 'Being a lot smarter', 'Being a self-starter', 'Placed in charge of trading charter'];
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _onSave() async {
    final vesselName = _nameController.text;
    final currentLoad = _descController.text;

    await _databaseService
        .insertTrip(Breed(vesselName: vesselName, currentLoad: currentLoad));
    //Todo: @bhargava Need to navigate to create trip screen and save the sensor data and given option to download
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: Text('Start Trip'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField(
            //   controller: _nameController,
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(),
            //     hintText: 'Vessel Name',
            //   ),
            // ),
            // SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Vessel Name',
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    _nameController.text = value;
                  },
                  itemBuilder: (BuildContext context) {
                   List<String> data=[];
                   widget.vessels!.forEach((value) {
                     data.add(value.vesselName!.toString());
                   });
                    return  data
                        .map<PopupMenuItem<String>>((String value) {
                      return new PopupMenuItem(
                          child: new Text(value), value: value);
                    }).toList();

                  },
                ),
              ),
            ),

            SizedBox(height: 16.0),
            TextField(
              controller: _descController,
              // maxLines: 7,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Current Load',
              ),
            ),
            SizedBox(height: 16.0),

          ],
        ),
      ),
      bottomSheet:  Container(
        height: 65.0,
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width ,
        child: ElevatedButton(
          onPressed: _onSave,
          child: Text(
            'Start Trip',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
