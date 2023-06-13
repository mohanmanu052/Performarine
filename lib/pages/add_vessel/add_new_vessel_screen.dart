import 'dart:io';

import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_step_one.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_step_two.dart';
import 'package:performarine/pages/home_page.dart';

import '../../common_widgets/utils/colors.dart';

//Add new vessel page
class AddNewVesselScreen extends StatefulWidget {
  //final
  final bool? isEdit;
  final CreateVessel? createVessel;
  final String? calledFrom;
  const AddNewVesselScreen(
      {Key? key, this.isEdit = false, this.createVessel, this.calledFrom})
      : super(key: key);

  @override
  State<AddNewVesselScreen> createState() => _AddNewVesselScreenState();
}

class _AddNewVesselScreenState extends State<AddNewVesselScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  late PageController pageController;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.calledFrom == 'SuccessFullScreen') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              ModalRoute.withName(""));

          return false;
        } else if (pageIndex == 0) {
          Navigator.of(context).pop();
          return false;
        } else if (pageIndex == 1) {
          pageController.previousPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: commonBackgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: commonBackgroundColor,
          leading: IconButton(
            onPressed: () {
              if (widget.calledFrom == 'SuccessFullScreen') {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                    ModalRoute.withName(""));
              } else if (pageIndex == 1) {
                pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: true,
          title: commonText(
              context: context,
              text: widget.isEdit! ? 'Edit Vessel' : 'Add New Vessel',
              fontWeight: FontWeight.w700,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 17),
          width: MediaQuery.of(context).size.width,
          height: displayHeight(context),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (value) {
                    setState(() {
                      pageIndex = value;
                    });
                    Utils.customPrint('PAGEVIEW INDEX $pageIndex');
                  },
                  children: [
                    AddVesselStepOne(
                      pageController: pageController,
                      scaffoldKey: scaffoldKey,
                      addVesselData:
                          widget.isEdit! ? widget.createVessel : null,
                      isEdit: widget.isEdit,
                    ),
                    AddNewVesselStepTwo(
                      pageController: pageController,
                      scaffoldKey: scaffoldKey,
                      addVesselData:
                          widget.isEdit! ? widget.createVessel : null,
                      isEdit: widget.isEdit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddVesselRequestModel {
  String? name;
  String? model;
  String? builderName;
  String? regNumber;
  String? MMSI;
  String? engineType;
  String? fuelCapacity;
  String? batteryCapacity;
  String? weight;
  String? freeBoard;
  String? lenghtOverAll;
  String? beam;
  String? depth;
  String? size;
  String? capacity;
  String? builtYear;
  String? imageUrls;
  int? vesselStatus;
  List<File?>? files;

  AddVesselRequestModel(
      {this.name,
      this.model,
      this.builderName,
      this.regNumber,
      this.MMSI,
      this.engineType,
      this.fuelCapacity,
      this.batteryCapacity,
      this.weight,
      this.freeBoard,
      this.lenghtOverAll,
      this.beam,
      this.depth,
      this.size,
      this.capacity,
      this.builtYear,
      this.imageUrls,
      this.vesselStatus,
      this.files});
}
