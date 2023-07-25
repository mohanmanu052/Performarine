import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:objectid/objectid.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/services/database_service.dart';
import 'package:uuid/uuid.dart';

class VesselFormPage extends StatefulWidget {
  const VesselFormPage({Key? key, this.vessel}) : super(key: key);
  final CreateVessel? vessel;

  @override
  _VesselFormPageState createState() => _VesselFormPageState();
}

class _VesselFormPageState extends State<VesselFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _builderController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _mmsiController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _fuelCapacityController = TextEditingController();
  final TextEditingController _batteryCapacityController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _freeboardController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _beamController = TextEditingController();
  final TextEditingController _draftController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _builtyearController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.vessel != null) {
      _nameController.text = widget.vessel!.name.toString();
      _modelController.text = widget.vessel!.model.toString();
      _builderController.text = widget.vessel!.builderName.toString();
      _registrationNumberController.text = widget.vessel!.regNumber.toString();
      _mmsiController.text = widget.vessel!.mMSI.toString();
      _engineTypeController.text = widget.vessel!.engineType.toString();
      _fuelCapacityController.text = widget.vessel!.fuelCapacity.toString();
      _batteryCapacityController.text =
          widget.vessel!.batteryCapacity.toString();
      _weightController.text = widget.vessel!.weight.toString();
      _freeboardController.text = widget.vessel!.freeBoard.toString();
      _lengthController.text = widget.vessel!.lengthOverall.toString();
      _beamController.text = widget.vessel!.beam.toString();
      _draftController.text = widget.vessel!.draft.toString();
      _sizeController.text = widget.vessel!.vesselSize.toString();
      _capacityController.text = widget.vessel!.capacity.toString();
      _builtyearController.text = widget.vessel!.builtYear.toString();
    }
  }

  /// To insert and update vessel details into local database
  Future<void> _onVesselSave() async {
    final vesselName = _nameController.text;
    final builder = _builderController.text;
    final model = _modelController.text;
    final registrationNumber = _registrationNumberController.text;
    final mmsi = _mmsiController.text;
    final engineType = _engineTypeController.text;
    final fuelCapacity = _fuelCapacityController.text;
    final batteryCapacity = _batteryCapacityController.text;
    final weight = _weightController.text;
    final freeBoard = _freeboardController.text;
    final lengthOverall = _lengthController.text;
    final beam = _beamController.text;
    final draft = _draftController.text;
    final size = _sizeController.text;
    final capacity = _capacityController.text;
    final builtYear = _builtyearController.text;
    var uuid = Uuid();

    widget.vessel == null
        ? await _databaseService.insertVessel(CreateVessel(
            id: ObjectId().toString(),
            name: vesselName,
            builderName: builder,
            model: model,
            regNumber: registrationNumber,
            mMSI: mmsi,
            engineType: engineType,
            fuelCapacity: fuelCapacity,
            batteryCapacity: batteryCapacity,
            weight: weight,
            freeBoard: double.parse(freeBoard),
            lengthOverall: double.parse(lengthOverall),
            beam: double.parse(beam),
            draft: double.parse(draft),
            vesselSize: double.parse(size),
            capacity: int.parse(capacity),
            builtYear: int.parse(builtYear),
            isSync: 0,
            vesselStatus: 1,
            imageURLs: "",
            createdAt: DateTime.now().toUtc().toString(),
            createdBy: "",
            updatedAt: DateTime.now().toUtc().toString(),
            updatedBy: ""))
        : await _databaseService.updateVessel(CreateVessel(
            id: widget.vessel!.id,
            name: vesselName,
            builderName: builder,
            model: model,
            regNumber: registrationNumber,
            mMSI: mmsi,
            engineType: engineType,
            fuelCapacity: fuelCapacity,
            batteryCapacity: batteryCapacity,
            weight: weight,
            freeBoard: freeBoard != "null" ? double.parse(freeBoard) : 0.0,
            lengthOverall:
                lengthOverall != "null" ? double.parse(lengthOverall) : 0.0,
            beam: double.parse(beam),
            draft: double.parse(draft),
            vesselSize: double.parse(size),
            capacity: int.parse(capacity),
            builtYear: int.parse(builtYear),
            updatedBy: "",
            updatedAt: DateTime.now().toUtc().toString()));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Vessel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Vessel Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _builderController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Builder',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _modelController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Model',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _registrationNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Registration Number',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _mmsiController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'MMSI',
                ),
              ),
              SizedBox(height: 16.0),
              //Todo: add the drop down
              TextField(
                controller: _engineTypeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Engine Type',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _fuelCapacityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Fuel Capacity',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _batteryCapacityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Battery Capacity',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Weight',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _freeboardController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Free Board',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _lengthController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Length overall',
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 16.0),
              TextField(
                controller: _beamController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Beam',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _draftController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Draft',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered.
              ),
              SizedBox(height: 16.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _sizeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Size',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered.
              ),

              SizedBox(height: 16.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _capacityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Capacity',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered.
              ),
              SizedBox(height: 16.0),

              SizedBox(height: 16.0),
              TextField(
                controller: _builtyearController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Built Year',
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 24.0),
              SizedBox(
                height: 45.0,
                child: ElevatedButton(
                  onPressed: _onVesselSave,
                  child: Text(
                    'Add Vessel',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
