import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/vessel_single_view.dart';

class SuccessfullyAddedScreen extends StatefulWidget {
  final bool? isEdit;
  final CreateVessel? data;
  const SuccessfullyAddedScreen({Key? key, this.data, this.isEdit = false})
      : super(key: key);

  @override
  State<SuccessfullyAddedScreen> createState() =>
      _SuccessfullyAddedScreenState();
}

class _SuccessfullyAddedScreenState extends State<SuccessfullyAddedScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isEdit!) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VesselSingleView(
                      vessel: widget.data,
                      isCalledFromSuccessScreen: true,
                    )),
          );
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              ModalRoute.withName("SuccessFullScreen"));
        }

        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: commonBackgroundColor,
        bottomNavigationBar: Container(
          margin: EdgeInsets.symmetric(
              horizontal: displayHeight(context) * 0.03,
              vertical: displayHeight(context) * 0.02),
          child: CommonButtons.getActionButton(
              title: widget.isEdit! ? 'View Vessel' : 'Add More',
              context: context,
              fontSize: displayWidth(context) * 0.042,
              textColor: Colors.white,
              buttonPrimaryColor: buttonBGColor,
              borderColor: buttonBGColor,
              width: displayWidth(context),
              onTap: () {
                if (widget.isEdit!) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VesselSingleView(vessel: widget.data!)),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewVesselScreen(
                            calledFrom: 'SuccessFullScreen')),
                  );
                }
              }),
        ),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: commonBackgroundColor,
          leading: IconButton(
            onPressed: () {
              if (widget.isEdit!) {
                // Navigator.of(context).pop([true, widget.data]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VesselSingleView(
                            vessel: widget.data,
                            isCalledFromSuccessScreen: true,
                          )),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                    ModalRoute.withName(""));
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
              text: widget.isEdit!
                  ? 'Successfully Updated'
                  : 'Successfully Added',
              fontWeight: FontWeight.w700,
              textColor: Colors.black,
              textSize: displayWidth(context) * 0.05,
              textAlign: TextAlign.start),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 17),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    height: displayHeight(context) / 2,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: Lottie.asset('assets/lottie/done.json')),
                vesselSingleViewCard(context, widget.data!,
                    (CreateVessel value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VesselSingleView(
                              vessel: value,
                              isCalledFromSuccessScreen: true,
                            )),
                  );
                }, scaffoldKey),
                Column(
                  children: [
                    SizedBox(
                      height: displayHeight(context) * 0.03,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                            ModalRoute.withName(""));
                      },
                      child: commonText(
                          context: context,
                          text: 'View all Vessels',
                          fontWeight: FontWeight.w500,
                          textColor: primaryColor,
                          textSize: displayWidth(context) * 0.05,
                          textAlign: TextAlign.start),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
