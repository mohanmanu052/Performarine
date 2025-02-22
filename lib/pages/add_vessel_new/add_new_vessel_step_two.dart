import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/widgets/common_dropdown.dart';
import 'package:performarine/pages/add_vessel_new/successfully_added_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../analytics/get_or_create_folder.dart';
import '../../common_widgets/stepper/status_stepper.dart';
import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../models/vessel.dart';
import '../../provider/common_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../services/database_service.dart';

class AddNewVesselStepTwo extends StatefulWidget {
  final PageController? pageController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CreateVessel? addVesselData;
  final bool? isEdit;
  AddNewVesselStepTwo({Key? key,
    this.pageController,
    this.scaffoldKey,
    this.addVesselData,
    this.isEdit}) : super(key: key);

  @override
  State<AddNewVesselStepTwo> createState() => _AddNewVesselStepTwoState();
}

class _AddNewVesselStepTwoState extends State<AddNewVesselStepTwo> with AutomaticKeepAliveClientMixin<AddNewVesselStepTwo>{

  late GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<FormState> freeBoardFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> lengthFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> beamFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> draftFormKey = GlobalKey<FormState>();
  //GlobalKey<FormState> displacementKey = GlobalKey<FormState>();
  GlobalKey<FormState> sizeFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> capacityFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> builtYearFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> selectedHullFormKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  AutovalidateMode _autoValidate = AutovalidateMode.onUserInteraction;

  TextEditingController freeBoardController = TextEditingController();
  TextEditingController lengthOverallController = TextEditingController();
  TextEditingController moldedBeamController = TextEditingController();
  TextEditingController moldedDepthController = TextEditingController();
  //TextEditingController displacementController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController builtYearController = TextEditingController();

  FocusNode freeBoardFocusNode = FocusNode();
  FocusNode lengthOverallFocusNode = FocusNode();
  FocusNode moldedBeamFocusNode = FocusNode();
  FocusNode moldedDepthFocusNode = FocusNode();
  FocusNode displacementFocusNode = FocusNode();
  FocusNode sizeFocusNode = FocusNode();
  FocusNode capacityFocusNode = FocusNode();
  FocusNode builtYearFocusNode = FocusNode();

  late CommonProvider commonProvider;
  bool? isBtnClicked = false,isImageSelected = false,isDeleted = false;
  String page = "Add_new_vessel_step_two";
  final statuses = List.generate(
    2,
        (index) => SizedBox.square(
      dimension: 14,
      child: Center(child: Text('')),
    ),
  );

  double curIndex = 0;
  double lastIndex = -1;
  List<File?> pickFilePath = [];
  List<File?> finalSelectedFiles = [];

  String? selectedHullType;
  List<Map<String, dynamic>> hullTypesList = [];

  String appendAsInt(double value) {
    int intValue = value.toInt();
    return intValue.toString();
  }

  @override
  void didUpdateWidget(covariant AddNewVesselStepTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(commonProvider.selectedImageFiles.isNotEmpty){
      finalSelectedFiles = commonProvider.selectedImageFiles;
    } else{
      isDeleted = true;
    }
  }



  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });
    getHullTypes();

    commonProvider = context.read<CommonProvider>();

    if (widget.isEdit!) {
      //debugPrint("IMAGE 1212 ${widget.addVesselData!.imageURLs!}");
      if (widget.addVesselData != null) {
        freeBoardController.text = widget.addVesselData!.freeBoard!.toString().trim();
        lengthOverallController.text = widget.addVesselData!.lengthOverall!.toString().trim();
        moldedBeamController.text = widget.addVesselData!.beam!.toString().trim();
        moldedDepthController.text = widget.addVesselData!.draft!.toString().trim();
        //displacementController.text = widget.addVesselData!.displacement.toString();
        sizeController.text = widget.addVesselData!.vesselSize!.toString().trim();
        //  capacityController.text = widget.addVesselData!.capacity!.toString();s
        builtYearController.text = widget.addVesselData!.builtYear!.toString().trim();
        if(widget.addVesselData!.hullType != null)
          {
            selectedHullType = widget.addVesselData!.hullType.toString();
            Utils.customPrint('HHHHH HULL TYPE: ${selectedHullType is String}');
          }


      }
    }

    if(commonProvider.selectedImageFiles != null || commonProvider.selectedImageFiles.isNotEmpty){
      finalSelectedFiles = commonProvider.selectedImageFiles;
    } else{
      isDeleted = true;
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // TODO: implement dispose
    super.dispose();
  }

  getHullTypes() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? hullTypes = await storage.read(
        key: 'hullTypes'
    );

    if(hullTypes != null){
      Map<String, dynamic> mapOfHullTypes = jsonDecode(hullTypes);
      Utils.customPrint('HHHHH MAP: ${mapOfHullTypes}');
      hullTypesList.clear();
      mapOfHullTypes.forEach((key, value) {
        hullTypesList.add({"key": key, "value": value});
      });
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

    super.build(context);
    return Form(
      //key: formKey,
      autovalidateMode: _autoValidate,
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  stepperWidget(),

                  !finalSelectedFiles.isNotEmpty ? Container(
                    margin: EdgeInsets.only(top: displayHeight(context) * 0.008),

                    child: CommonButtons.uploadVesselImage(
                        'Click here to Upload Vessel Image\n(png, jpeg files only)', context, () {
                      uploadImageFunction();
                      Utils.customPrint(
                          'FIIALLL: ${finalSelectedFiles}');
                      CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles} -> $page");
                    }, blueColor),
                  ) : Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: displayHeight(context) * 0.008),
                        child: CommonButtons.uploadVesselImage(
                            'Click here to Upload Vessel Image\n(png, jpeg files only)', context, () {
                          uploadImageFunction();
                          Utils.customPrint(
                              'FIIALLL: ${finalSelectedFiles}');
                          CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles} -> $page");
                        }, blueColor),
                      ),
                      Positioned(
                          top: displayHeight(context) * 0.016,
                          left: displayWidth(context) * 0.045,
                          child: uploadingImage(context)
                      )
                    ],
                  ),

                  SizedBox(height: displayHeight(context) * 0.03),
                  commonText(
                      context: context,
                      text: 'Size of the boat *',
                      fontWeight: FontWeight.w500,
                      textColor: blutoothDialogTxtColor,
                      textSize: displayWidth(context) * 0.035,
                      textAlign: TextAlign.start,
                      fontFamily: outfit
                  ),
                  SizedBox(height: displayHeight(context) * 0.01),
                  Form(
                    key: freeBoardFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: freeBoardController,
                        focusNode: freeBoardFocusNode,
                        labelText: 'Freeboard ($feet) *',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: lengthOverallFocusNode,
                        obscureText: false,
                        isForDecimal: true,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty||value.trim()=='.') {
                            return 'Enter Vessel Freeboard';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Vessel Freeboard $value -> $page");
                        },),
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: lengthFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: lengthOverallController,
                        focusNode: lengthOverallFocusNode,
                        labelText: 'Length Overall ($feet) *',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: moldedBeamFocusNode,
                        obscureText: false,
                        isForDecimal: true,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty||value.trim()=='.') {
                            return 'Enter Vessel Length Overall';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Vessel Length Overall $value -> $page");
                        }),
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: beamFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: moldedBeamController,
                        focusNode: moldedBeamFocusNode,
                        labelText: 'Beam ($feet) *',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: moldedDepthFocusNode,
                        obscureText: false,
                        isForDecimal: true,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty||value.trim()=='.') {
                            return 'Enter Vessel Beam';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Vessel Beam $value -> $page");
                        }),
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: draftFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: moldedDepthController,
                        focusNode: moldedDepthFocusNode,
                        labelText: 'Draft ($feet) *',
                        hintText: '',
                        suffixText: null,
                        isForDecimal: true,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        //why this focused to displacementFocusNode?
                        requestFocusNode: displacementFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty||value.trim()=='.') {
                            return 'Enter Vessel Draft';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Vessel Draft $value -> $page");
                        }),
                  ),

                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: selectedHullFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Container(
                      margin: EdgeInsets.only(top: 2.0),
                      child: CommonMapDropDownFormField(
                        context: context,
                        value: selectedHullType,
                        hintText: 'Hull Type',
                        labelText: '',
                        onChanged: (String value) {
                          setState(() {
                            selectedHullType = value;
                            Utils.customPrint('SELECTED HULL TYPE $selectedHullType');
                            CustomLogger().logWithFile(Level.info, "hull $selectedHullType -> $page");
                          });
                        },
                        dataSource: hullTypesList,
                        borderRadius: 10,
                        padding: 6,
                        textColor: Colors.black,
                        textField: 'value',
                        valueField: 'key',
                        validator: (value) {
                          if (value == null) {
                            return 'Select Hull Type';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: displayHeight(context) * 0.02),
                  commonText(
                      context: context,
                      text: 'Engine characteristics *',
                      fontWeight: FontWeight.w500,
                      textColor: blutoothDialogTxtColor,
                      textSize: displayWidth(context) * 0.035,
                      textAlign: TextAlign.start,
                      fontFamily: outfit
                  ),
                  SizedBox(height: displayHeight(context) * 0.02),
                  Form(
                    key: sizeFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: sizeController,
                        focusNode: sizeFocusNode,
                        labelText: 'Size ($hp) *',
                        isForDecimal: true,
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: capacityFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
int dotCount = value!.split('.').length - 1;

if (dotCount > 1) {
  

  // Return an error or handle the case where the value contains more than one dot
                          //  return 'Enter Valid Vessel Size';
} else {
  // The value is valid, you can proceed with it
  print("Value is valid");
}






                          if (value.trim().isEmpty||value.trim()=='.') {
                            return 'Enter Vessel Size';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Vessel Size $value -> $page");
                        }),
                  ),
                  /*    SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: capacityFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: capacityController,
                        focusNode: capacityFocusNode,
                        labelText: 'Capacity',
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
                        onChanged: (String value) {
                        },
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
                  ), */
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: builtYearFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: builtYearController,
                        focusNode: builtYearFocusNode,
                        labelText: 'Built Year ($year) *',
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
                        onChanged: (String value) {
                        },
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
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: displayHeight(context) * 0.01,
                          top: displayHeight(context) * 0.02),
                      child: isBtnClicked!
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            blueColor),
                      )
                          : CommonButtons.getActionButton(
                          title:
                          widget.isEdit! ? 'Update Vessel' : 'Add Vessel',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: blueColor,
                          borderColor: blueColor,
                          width: displayWidth(context),
                          onTap: () async {
                            if (freeBoardFormKey.currentState!.validate() && lengthFormKey.currentState!.validate() && beamFormKey.currentState!.validate()
                                && draftFormKey.currentState!.validate() && sizeFormKey.currentState!.validate() && builtYearFormKey.currentState!.validate()
                                && selectedHullFormKey.currentState!.validate()) {
                              setState(() {
                                isBtnClicked = true;
                              });


                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              if(isDeleted!){
                                commonProvider
                                    .addVesselRequestModel!.imageURLs = '';
                              }
                              commonProvider.addVesselRequestModel!.freeBoard =
                              freeBoardController.text.trim().length >= 6 ? num.parse(double.parse(freeBoardController.text.trim()).toStringAsFixed(4)).toDouble()
                                  : double.parse(freeBoardController.text.trim());
                              commonProvider
                                  .addVesselRequestModel!.lengthOverall = lengthOverallController.text.trim().length >=6
                                  ? num.parse(double.parse(lengthOverallController.text.trim()).toStringAsFixed(4)).toDouble()
                                  : double.parse(lengthOverallController.text.trim());
                              commonProvider.addVesselRequestModel!.beam = moldedBeamController.text.trim().length >= 6
                                  ? num.parse(double.parse(moldedBeamController.text.trim()).toStringAsFixed(4)).toDouble()
                                  : double.parse(moldedBeamController.text.trim());
                              commonProvider.addVesselRequestModel!.draft = moldedDepthController.text.trim().length >= 6
                                  ? num.parse(double.parse(moldedDepthController.text.trim()).toStringAsFixed(4)).toDouble()
                                  : double.parse(moldedDepthController.text.trim());
                              /*commonProvider.addVesselRequestModel!.displacement = displacementController.text.length >= 7
                                  ? num.parse(double.parse(displacementController.text).toStringAsFixed(5)).toDouble()
                                  : double.parse(displacementController.text);*/
                              commonProvider.addVesselRequestModel!.vesselSize =
                                  sizeController.text.trim();
                              commonProvider.addVesselRequestModel!.capacity = 0;
                              //  int.parse(capacityController.text);
                              commonProvider.addVesselRequestModel!.builtYear =
                                  builtYearController.text.trim();
                              commonProvider.addVesselRequestModel!.id =
                              widget.isEdit!
                                  ? widget.addVesselData!.id!
                                  : ObjectId().toString();
                              commonProvider.addVesselRequestModel!.selectedImages =
                              finalSelectedFiles.isEmpty
                                  ? []
                                  : finalSelectedFiles;
                              commonProvider.addVesselRequestModel!.isSync = 0;
                              commonProvider
                                  .addVesselRequestModel!.vesselStatus = 1;
                              commonProvider.addVesselRequestModel!.createdAt =
                                  DateTime.now().toUtc().toString();
                              commonProvider.addVesselRequestModel!.updatedAt =
                                  DateTime.now().toUtc().toString();
                              commonProvider.addVesselRequestModel!.createdBy =
                                  commonProvider.loginModel!.userId.toString();
                              commonProvider.addVesselRequestModel!.updatedBy =
                                  commonProvider.loginModel!.userId.toString();
                              commonProvider.addVesselRequestModel!.hullType = int.parse(selectedHullType!);

                              if (commonProvider.addVesselRequestModel!
                                  .selectedImages!.isNotEmpty) {
                                Utils.customPrint(
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
                                    .then((value) async {
                                  setState(() {
                                    isBtnClicked = false;
                                  });

                                  if (value == 1) {
                                    Utils.showSnackBar(context,
                                        scaffoldKey: scaffoldKey,
                                        message:
                                        "Vessel Details Updated Successfully");

                                    _databaseService.updateIsSyncStatus(0,
                                        widget.addVesselData!.id!.toString());

                                    _databaseService.updateVesselName(
                                        commonProvider
                                            .addVesselRequestModel!.name!,
                                        widget.addVesselData!.id!.toString());

                                    commonProvider.selectedImageFiles = [];

                                    CustomLogger().logWithFile(Level.info, "User Navigating to SuccessfullyAddedScreen -> $page");
                            await SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.portraitDown,
                                      DeviceOrientation.portraitUp,
                                    ]);

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
                                    .then((value) async{
                                  setState(() {
                                    isBtnClicked = false;
                                  });
                                  Utils.showSnackBar(context,
                                      scaffoldKey: scaffoldKey,
                                      message: "Vessel Created Successfully");
                                  commonProvider.selectedImageFiles = [];

                                  await  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.portraitDown,
                                    DeviceOrientation.portraitUp,
                                  ]);

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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  stepperWidget(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * 0.1, vertical: 8),
      child: Column(
        children: [
          StatusStepper(
            connectorCurve: Curves.linear,
            itemCurve: Curves.easeOut,
            activeColor: blueColor,
            disabledColor: dropDownBackgroundColor,
            animationDuration: const Duration(milliseconds: 500),
            lastActiveIndex: lastIndex,
            currentIndex: curIndex,
            connectorThickness: 5,
            children: statuses,
            value: 1,
            isCallingFromAddVessel: true,
          ),
          SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Step 1",
                      style: TextStyle(
                          fontSize: displayWidth(context) * 0.028,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: inter
                      ),
                    ),)),
              Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Step 2",
                      style: TextStyle(
                          fontSize: displayWidth(context) * 0.028,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: inter
                      ),
                    ),)),
            ],
          )
        ],
      ),
    );
  }


  Widget uploadingImage(BuildContext context){
    return SizedBox(
      height: displayHeight(context) * 0.206,
      width: displayWidth(context) * 0.82,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(6),
            alignment: Alignment.topRight,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.grey.shade300),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(
                      File(finalSelectedFiles[0]
                      !.path),
                    ))),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: InkWell(
              onTap: () {
                Utils.customPrint(
                    'FIIALLL: ${finalSelectedFiles.length}');
                CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles} -> $page");
                setState(() {
                  isImageSelected = false;
                  if(finalSelectedFiles.isNotEmpty){
                    finalSelectedFiles.clear();
                    isDeleted = true;
                    commonProvider.selectedImageFiles.clear();
                  }
                });
                Utils.customPrint(
                    'FIIALLL: ${finalSelectedFiles}');
                CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles} -> $page");
              },
              child: Container(
                width: displayWidth(context) * 0.08,
                height: displayHeight(context) * 0.04,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    'assets/images/Trash.png',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Upload images from adding new vessel page
  uploadImageFunction() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      bool isStoragePermissionGranted = false;

      if (androidInfo.version.sdkInt <= 32) {
        isStoragePermissionGranted = await Permission.storage.isGranted;
      } else {
        isStoragePermissionGranted = await Permission.photos.isGranted;
      }

      if (isStoragePermissionGranted) {
        await selectImage(context, Colors.red,
                (List<File?> selectedImageFileList) {
              if (selectedImageFileList.isNotEmpty ) {
                setState(() {
                  commonProvider.selectedImageFiles.clear();
                  finalSelectedFiles.clear();
                  isImageSelected = true;
                  finalSelectedFiles.addAll(selectedImageFileList);
                  commonProvider.selectedImageFiles = selectedImageFileList;

                  Utils.customPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');
                  CustomLogger().logWithFile(Level.info, "CAMERA FILE ${finalSelectedFiles[0]!.path} -> $page");
                  Utils.customPrint('CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()}');
                  CustomLogger().logWithFile(Level.info, "CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()} -> $page");

                });
              }
            });
      } else {
        await Utils.getStoragePermission(context);
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        bool isStoragePermissionGranted = false;

        if (androidInfo.version.sdkInt <= 32) {
          isStoragePermissionGranted = await Permission.storage.isGranted;
        } else {
          isStoragePermissionGranted = await Permission.photos.isGranted;
        }

        if (isStoragePermissionGranted) {
          await selectImage(context, Colors.red,
                  (List<File?> selectedImageFileList) {
                if (selectedImageFileList.isNotEmpty) {
                  setState(() {
                    finalSelectedFiles.clear();
                    isImageSelected = true;
                    finalSelectedFiles.addAll(selectedImageFileList);
                    Utils.customPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');

                    CustomLogger().logWithFile(Level.info, "CAMERA FILE ${finalSelectedFiles[0]!.path} -> $page");

                  });
                }
              });
        }
      }
    } else {
      Utils.customPrint('OTHER ELSE');
      CustomLogger().logWithFile(Level.info, "OTHER ELSE -> -> $page");
      await selectImage(context, Colors.red,
              (List<File?> selectedImageFileList) {
            if (selectedImageFileList.isNotEmpty) {
              setState(() {
                finalSelectedFiles.clear();
                isImageSelected = true;
                finalSelectedFiles.addAll(selectedImageFileList);
                Utils.customPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');

                CustomLogger().logWithFile(Level.info, "CAMERA FILE ${finalSelectedFiles[0]!.path} -> $page");
                Utils.customPrint('CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()}');
                CustomLogger().logWithFile(Level.info, "CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()} -> $page");

              });
            }
          });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}