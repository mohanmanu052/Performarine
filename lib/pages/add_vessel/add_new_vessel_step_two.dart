import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/get_or_create_folder.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/add_vessel/sucessfully_added_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../../common_widgets/widgets/log_level.dart';

// Add new vessel step two
class AddNewVesselStepTwo extends StatefulWidget {
  final PageController? pageController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CreateVessel? addVesselData;
  final bool? isEdit;
  const AddNewVesselStepTwo(
      {Key? key,
      this.pageController,
      this.scaffoldKey,
      this.addVesselData,
      this.isEdit})
      : super(key: key);

  @override
  State<AddNewVesselStepTwo> createState() => _AddNewVesselStepTwoState();
}

class _AddNewVesselStepTwoState extends State<AddNewVesselStepTwo>
    with AutomaticKeepAliveClientMixin<AddNewVesselStepTwo> {
  late GlobalKey<ScaffoldState> scaffoldKey;
  final DatabaseService _databaseService = DatabaseService();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController freeBoardController = TextEditingController();
  TextEditingController lengthOverallController = TextEditingController();
  TextEditingController moldedBeamController = TextEditingController();
  TextEditingController moldedDepthController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController builtYearController = TextEditingController();

  FocusNode freeBoardFocusNode = FocusNode();
  FocusNode lengthOverallFocusNode = FocusNode();
  FocusNode moldedBeamFocusNode = FocusNode();
  FocusNode moldedDepthFocusNode = FocusNode();
  FocusNode sizeFocusNode = FocusNode();
  FocusNode capacityFocusNode = FocusNode();
  FocusNode builtYearFocusNode = FocusNode();

  late CommonProvider commonProvider;

  bool? isBtnClicked = false;
  String page = "Add_new_vessel_step_two";

  @override
  void initState() {
    super.initState();

    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });

    commonProvider = context.read<CommonProvider>();

    if (widget.isEdit!) {
      if (widget.addVesselData != null) {
        freeBoardController.text = widget.addVesselData!.freeBoard!.toString();
        lengthOverallController.text =
            widget.addVesselData!.lengthOverall!.toString();
        moldedBeamController.text = widget.addVesselData!.beam!.toString();
        moldedDepthController.text = widget.addVesselData!.draft!.toString();
        sizeController.text = widget.addVesselData!.vesselSize!.toString();
        capacityController.text = widget.addVesselData!.capacity!.toString();
        builtYearController.text = widget.addVesselData!.builtYear!.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    super.build(context);

    return Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: displayHeight(context) * 0.02),
                  commonText(
                      context: context,
                      text: 'Step 2/2',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.02),
                  commonText(
                      context: context,
                      text: 'Size of the boat',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black54,
                      textSize: displayWidth(context) * 0.035,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.02),
                  CommonTextField(
                      controller: freeBoardController,
                      focusNode: freeBoardFocusNode,
                      labelText: 'Freeboard (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: lengthOverallFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Freeboard';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Vessel Freeboard $value -> $page");
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: lengthOverallController,
                      focusNode: lengthOverallFocusNode,
                      labelText: 'Length overall (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: moldedBeamFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Length Overall';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Vessel Length Overall $value -> $page");
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: moldedBeamController,
                      focusNode: moldedBeamFocusNode,
                      labelText: 'Beam (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: moldedDepthFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Beam';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Vessel Beam $value -> $page");
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: moldedDepthController,
                      focusNode: moldedDepthFocusNode,
                      labelText: 'Draft (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: sizeFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Draft';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Vessel Draft $value -> $page");
                      }),
                  SizedBox(height: displayHeight(context) * 0.025),
                  commonText(
                      context: context,
                      text: 'Engine characteristics*',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black54,
                      textSize: displayWidth(context) * 0.035,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.025),
                  CommonTextField(
                      controller: sizeController,
                      focusNode: sizeFocusNode,
                      labelText: 'Size (hp)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: capacityFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Size';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Vessel Size $value -> $page");
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: capacityController,
                      focusNode: capacityFocusNode,
                      labelText: 'Capacity (cc)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: builtYearFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Capacity';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Vessel Capacity $value -> $page");
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: builtYearController,
                      focusNode: builtYearFocusNode,
                      labelText: 'Built Year (YYYY)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 4,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Vessel Built Year';
                        } else if (int.parse(value) < 1947) {
                          return 'Please Enter Valid Year';
                        } else if (int.parse(value) > DateTime.now().year) {
                          return 'Please Enter Valid Year';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Built year: $value -> $page");
                      }),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: displayHeight(context) * 0.01,
                      top: displayHeight(context) * 0.02),
                  child: isBtnClicked!
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              circularProgressColor),
                        )
                      : CommonButtons.getActionButton(
                          title:
                              widget.isEdit! ? 'Update Vessel' : 'Add Vessel',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: buttonBGColor,
                          borderColor: buttonBGColor,
                          width: displayWidth(context),
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isBtnClicked = true;
                              });

                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());

                              commonProvider.addVesselRequestModel!.freeBoard =
                                  double.parse(freeBoardController.text);
                              commonProvider
                                      .addVesselRequestModel!.lengthOverall =
                                  double.parse(lengthOverallController.text);
                              commonProvider.addVesselRequestModel!.beam =
                                  double.parse(moldedBeamController.text);
                              commonProvider.addVesselRequestModel!.draft =
                                  double.parse(moldedDepthController.text);
                              commonProvider.addVesselRequestModel!.vesselSize =
                                  double.parse(sizeController.text);
                              commonProvider.addVesselRequestModel!.capacity =
                                  int.parse(capacityController.text);
                              commonProvider.addVesselRequestModel!.builtYear =
                                  builtYearController.text;
                              commonProvider.addVesselRequestModel!.id =
                                  widget.isEdit!
                                      ? widget.addVesselData!.id
                                      : ObjectId().toString();
                              commonProvider.addVesselRequestModel!.isSync = 0;
                              commonProvider
                                  .addVesselRequestModel!.vesselStatus = 1;
                              commonProvider.addVesselRequestModel!.createdAt =
                                  DateTime.now().toUtc().toString();
                              commonProvider.addVesselRequestModel!.updatedAt =
                                  DateTime.now().toUtc().toString();
                              //ToDo: @ruapli add the created by as login userid.
                              commonProvider.addVesselRequestModel!.createdBy =
                                  commonProvider.loginModel!.userId.toString();
                              commonProvider.addVesselRequestModel!.updatedBy =
                                  commonProvider.loginModel!.userId.toString();

                              if (commonProvider.addVesselRequestModel!
                                  .selectedImages!.isNotEmpty) {
                                print(
                                    'XXXXX:${commonProvider.addVesselRequestModel!.selectedImages!}');
                                CustomLogger().logWithFile(Level.info, "XXXXX:${commonProvider.addVesselRequestModel!.selectedImages!} -> $page");
                                String vesselImagesDirPath =
                                    await GetOrCreateFolder()
                                        .getOrCreateFolderForAddVessel();
                                Utils.customPrint(
                                    'FOLDER PATH: $vesselImagesDirPath');
                                CustomLogger().logWithFile(Level.info, "FOLDER PATH: $vesselImagesDirPath -> $page");

                                File copiedFile = File(commonProvider
                                    .addVesselRequestModel!
                                    .selectedImages![0]!
                                    .path);
                                String fileExtension =
                                    path.extension(copiedFile.path);

                                Directory directory;

                                if (Platform.isAndroid) {
                                  directory = Directory(
                                      '$vesselImagesDirPath/${commonProvider.addVesselRequestModel!.id}-${DateTime.now().toUtc().millisecondsSinceEpoch}$fileExtension');
                                } else {
                                  Directory dir =
                                      await getApplicationDocumentsDirectory();
                                  directory = Directory(
                                      '$vesselImagesDirPath/${commonProvider.addVesselRequestModel!.id}-${DateTime.now().toUtc().millisecondsSinceEpoch}$fileExtension');
                                }

                                copiedFile.copy(directory.path);

                                Utils.customPrint(
                                    'DOES FILE EXIST: ${copiedFile.existsSync()}');

                                Utils.customPrint(
                                    'COPIED FILE PATH: ${copiedFile.path}');
                                Utils.customPrint(
                                    'COPIED FILE PATH: ${directory.path}');
                                Utils.customPrint(
                                    'COPIED FILE PATH EXISTS: ${File(directory.path).existsSync()}');
                                CustomLogger().logWithFile(Level.info, "DOES FILE EXIST: ${copiedFile.existsSync()} -> $page");
                                CustomLogger().logWithFile(Level.info, "COPIED FILE PATH: ${copiedFile.path} -> $page");
                                CustomLogger().logWithFile(Level.info, "COPIED FILE PATH: ${directory.path} -> $page");

                                commonProvider.addVesselRequestModel!
                                    .imageURLs = directory.path;
                              } else {
                                commonProvider.addVesselRequestModel!
                                    .imageURLs = commonProvider
                                        .addVesselRequestModel!.imageURLs ??
                                    '';
                              }

                              /*setState(() {
                                isBtnClicked = false;
                              });
                              return;*/

                              if (widget.isEdit!) {
                                Utils.customPrint(
                                    'VESSEL NAME: ${widget.addVesselData!.name}');
                                Utils.customPrint(
                                    'VESSEL NAME: ${commonProvider.addVesselRequestModel!.toMap()}');

                                CustomLogger().logWithFile(Level.info, "VESSEL NAME: ${widget.addVesselData!.name} -> $page");
                                CustomLogger().logWithFile(Level.info, "VESSEL NAME: ${commonProvider.addVesselRequestModel!.toMap()} -> $page");;

                                await _databaseService
                                    .updateVessel(
                                        commonProvider.addVesselRequestModel!)
                                    .then((value) {
                                  setState(() {
                                    isBtnClicked = false;
                                  });

                                  if (value == 1) {
                                    Utils.showSnackBar(context,
                                        scaffoldKey: scaffoldKey,
                                        message:
                                            "Vessel details updated successfully");

                                    _databaseService.updateIsSyncStatus(0,
                                        widget.addVesselData!.id!.toString());

                                    _databaseService.updateVesselName(
                                        commonProvider
                                            .addVesselRequestModel!.name!,
                                        widget.addVesselData!.id!.toString());

                                    CustomLogger().logWithFile(Level.info, "User Navigating to SuccessfullyAddedScreen -> $page");

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SuccessfullyAddedScreen(
                                                  data: commonProvider
                                                      .addVesselRequestModel!,
                                                  isEdit: widget.isEdit)),
                                    );
                                  } else {
                                    Utils.showSnackBar(context,
                                        scaffoldKey: scaffoldKey,
                                        message: "Failed to update");
                                  }
                                });
                              } else {
                                await _databaseService
                                    .insertVessel(
                                        commonProvider.addVesselRequestModel!)
                                    .then((value) {
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           SuccessfullyAddedScreen(
                                  //               data: value.addVesselData,
                                  //               isEdit: widget.isEdit)),
                                  // );
                                  setState(() {
                                    isBtnClicked = false;
                                  });
                                  Utils.showSnackBar(context,
                                      scaffoldKey: scaffoldKey,
                                      message: "Vessel created successfully");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SuccessfullyAddedScreen(
                                                data: commonProvider
                                                    .addVesselRequestModel!,
                                                isEdit: widget.isEdit)),
                                  );
                                });
                              }
                            }
                          }),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
