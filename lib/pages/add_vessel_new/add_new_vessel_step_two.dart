import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
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
  GlobalKey<FormState> sizeFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> capacityFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> builtYearFormKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  AutovalidateMode _autoValidate = AutovalidateMode.onUserInteraction;

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

  String appendAsInt(double value) {
    int intValue = value.toInt();
    return intValue.toString();
  }

  @override
  void didUpdateWidget(covariant AddNewVesselStepTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(commonProvider.selectedImageFiles != null && commonProvider.selectedImageFiles.isNotEmpty){
      finalSelectedFiles = commonProvider.selectedImageFiles;
    } else{
      isDeleted = true;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });

    commonProvider = context.read<CommonProvider>();

    if (widget.isEdit!) {
      //debugPrint("IMAGE 1212 ${widget.addVesselData!.imageURLs!}");
      if (widget.addVesselData != null) {
        freeBoardController.text = appendAsInt(widget.addVesselData!.freeBoard!);
        lengthOverallController.text = appendAsInt(widget.addVesselData!.lengthOverall!);
        moldedBeamController.text = appendAsInt(widget.addVesselData!.beam!);
        moldedDepthController.text = appendAsInt(widget.addVesselData!.draft!);
        sizeController.text = widget.addVesselData!.vesselSize!.toString();
        capacityController.text = widget.addVesselData!.capacity!.toString();
        builtYearController.text = widget.addVesselData!.builtYear!.toString();

      }
    }

    if(commonProvider.selectedImageFiles != null || commonProvider.selectedImageFiles.isNotEmpty){
      finalSelectedFiles = commonProvider.selectedImageFiles;
    } else{
      isDeleted = true;
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
                      text: 'Size of the boat ',
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
                        labelText: 'Freeboard ($feet)',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType:
                        TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: lengthOverallFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
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
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: lengthFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: lengthOverallController,
                        focusNode: lengthOverallFocusNode,
                        labelText: 'Length Overall ($feet)',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: moldedBeamFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
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
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: beamFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: moldedBeamController,
                        focusNode: moldedBeamFocusNode,
                        labelText: 'Beam ($feet)',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: moldedDepthFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
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
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: draftFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: moldedDepthController,
                        focusNode: moldedDepthFocusNode,
                        labelText: 'Draft ($feet)',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: sizeFocusNode,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
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
                  ),
                  SizedBox(height: displayHeight(context) * 0.02),
                  commonText(
                      context: context,
                      text: 'Engine characteristics',
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
                        labelText: 'Size',
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
                        onChanged: (String value) {
                        },
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
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
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
                  ),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: builtYearFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: builtYearController,
                        focusNode: builtYearFocusNode,
                        labelText: 'Built Year ($year)',
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
                                && draftFormKey.currentState!.validate() && sizeFormKey.currentState!.validate() && capacityFormKey.currentState!.validate()
                                && builtYearFormKey.currentState!.validate()) {
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

                                    commonProvider.selectedImageFiles = [];

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
                                  setState(() {
                                    isBtnClicked = false;
                                  });
                                  Utils.showSnackBar(context,
                                      scaffoldKey: scaffoldKey,
                                      message: "Vessel created successfully");
                                  commonProvider.selectedImageFiles = [];
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