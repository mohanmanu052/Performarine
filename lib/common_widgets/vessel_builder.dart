import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/add_new_vessel_screen.dart';
import 'package:performarine/pages/single_vessel_card.dart';

class VesselBuilder extends StatefulWidget {
  const VesselBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
    required this.onTap,
    required this.onDelete,
    required this.scaffoldKey,
  }) : super(key: key);
  final Future<List<CreateVessel>> future;
  final Function(CreateVessel) onEdit;
  final Function(CreateVessel) onTap;
  final Function(CreateVessel) onDelete;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  State<VesselBuilder> createState() => _VesselBuilderState();
}

class _VesselBuilderState extends State<VesselBuilder> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<CreateVessel>>(
          future: widget.future,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/vessel_default_img.png',
                        height: displayHeight(context) * 0.28,
                      ),
                      commonText(
                          context: context,
                          text: 'No vessels available'.toString(),
                          fontWeight: FontWeight.w500,
                          textColor: Colors.black,
                          textSize: displayWidth(context) * 0.04,
                          textAlign: TextAlign.start),
                    ],
                  ),
                );
              } else {
                return Container(
                  color:commonBackgroundColor,
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8, bottom: 70),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vessel = snapshot.data![index];
                      return vessel.vesselStatus == 1
                          ? SingleVesselCard(vessel, (CreateVessel value) {
                              widget.onTap(value);
                            }, widget.scaffoldKey!)
                          : SizedBox();
                    },
                  ),
                );
              }
            }
            return Container();
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            // color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
            child: CommonButtons.getActionButton(
                title: 'Add Vessel',
                context: context,
                fontSize: displayWidth(context) * 0.042,
                textColor: Colors.white,
                buttonPrimaryColor: buttonBGColor,
                borderColor: buttonBGColor,
                width: displayWidth(context),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNewVesselScreen()),
                  );
                }),
          ),
        )
      ],
    );
  }
}
