import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/stepper/status_stepper.dart';
import '../../common_widgets/utils/colors.dart';
import '../../common_widgets/utils/common_size_helper.dart';
import '../../common_widgets/utils/utils.dart';
import '../../common_widgets/widgets/common_buttons.dart';
import '../../common_widgets/widgets/common_dropdown.dart';
import '../../common_widgets/widgets/common_text_feild.dart';
import '../../common_widgets/widgets/common_widgets.dart';
import '../../common_widgets/widgets/log_level.dart';
import '../../models/vessel.dart';
import '../../provider/common_provider.dart';
import 'dart:io';

class AddNewVesselStepOne extends StatefulWidget {
  final PageController? pageController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CreateVessel? addVesselData;
  final bool? isEdit;
  final FocusNode? nameFocusNode,
      modelFocusNode,
      builderNameFocusNode,
      registrationNumberFocusNode,
      mmsiFocusNode,
      fuelCapacityFocusNode,
      batteryCapacityFocusNode,
      weightFocusNode;
  AddNewVesselStepOne({Key? key,
    this.pageController,
    this.scaffoldKey,
    this.addVesselData,
    this.isEdit,
    this.nameFocusNode,
    this.modelFocusNode,
    this.builderNameFocusNode,
    this.registrationNumberFocusNode,
    this.mmsiFocusNode,
    this.fuelCapacityFocusNode,
    this.batteryCapacityFocusNode,
    this.weightFocusNode}) : super(key: key);

  @override
  State<AddNewVesselStepOne> createState() => _AddNewVesselStepOneState();
}

class _AddNewVesselStepOneState extends State<AddNewVesselStepOne> with AutomaticKeepAliveClientMixin<AddNewVesselStepOne>{

  late GlobalKey<ScaffoldState> scaffoldKey;

  GlobalKey<FormState> nameFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> modelFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> builderNameFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> regNumberFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> mmsiFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> fuelCapacityFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> batteryCapacityFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> weightFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> selectedEngineFormKey = GlobalKey<FormState>();

  final FocusScopeNode node = FocusScopeNode();

  AutovalidateMode _autoValidate = AutovalidateMode.onUserInteraction;

  TextEditingController nameController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController builderNameController = TextEditingController();
  TextEditingController registrationNumberController = TextEditingController();
  TextEditingController mmsiController = TextEditingController();
  TextEditingController fuelCapacityController = TextEditingController();
  TextEditingController batteryCapacityController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode builderNameFocusNode = FocusNode();
  FocusNode registrationNumberFocusNode = FocusNode();
  FocusNode mmsiFocusNode = FocusNode();
  FocusNode fuelCapacityFocusNode = FocusNode();
  FocusNode batteryCapacityFocusNode = FocusNode();
  FocusNode weightFocusNode = FocusNode();

  String? selectedEngineType;
  late CommonProvider commonProvider;
  String page = "Add_new_vessel_step_one";
  bool? isBatteryCapacityEnable = false, isOtherInformation = false;
  List<File?> pickFilePath = [];
  List<File?> finalSelectedFiles = [];
  bool isDeleted = false;

  final statuses = List.generate(
    2,
        (index) => SizedBox.square(
      dimension: 14,
      child: Center(child: Text('')),
    ),
  );

  double curIndex = 0;
  double lastIndex = -1;

  bool isImageSelected = false;

  @override
  void didUpdateWidget(covariant AddNewVesselStepOne oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(commonProvider.selectedImageFiles.isNotEmpty){
      finalSelectedFiles = commonProvider.selectedImageFiles;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });

    if (widget.isEdit!) {
      if (widget.addVesselData != null) {
        Utils.customPrint('ENGINE TYPE ${widget.addVesselData!.engineType!}');

        CustomLogger().logWithFile(Level.info, "ENGINE TYPE ${widget.addVesselData!.engineType!} -> $page");

        nameController.text = widget.addVesselData!.name!.trim();
        modelController.text = widget.addVesselData!.model!.trim();
        builderNameController.text = widget.addVesselData!.builderName!.trim();
        registrationNumberController.text = widget.addVesselData!.regNumber!.trim();
        mmsiController.text = widget.addVesselData!.mMSI!.trim();
        selectedEngineType = widget.addVesselData!.engineType!.trim();
        fuelCapacityController.text =
            widget.addVesselData!.fuelCapacity!.toString().trim();
        batteryCapacityController.text =
            widget.addVesselData!.batteryCapacity!.toString().trim();
        weightController.text = widget.addVesselData!.weight!.toString().trim();
        if(widget.addVesselData!.imageURLs != null)
        {
          if(widget.addVesselData!.imageURLs!.isNotEmpty)
          {
            finalSelectedFiles.add(File(widget.addVesselData!.imageURLs!));
          }

        }
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Form(
      //key: formKey,
      autovalidateMode: _autoValidate,
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
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
              Form(
                key: nameFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CommonTextField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    labelText: 'Name of the Vessel *',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 32,
                    prefixIcon: null,
                    requestFocusNode: modelFocusNode,
                    obscureText: false,
                    onTap: () {},
                    onChanged: (String value) {
                    },
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Enter Vessel Name';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      CustomLogger().logWithFile(Level.info, "vessel name $value -> $page");
                      Utils.customPrint(value);
                    }),
              ),
              SizedBox(height: displayHeight(context) * 0.015),
              Form(
                key: modelFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CommonTextField(
                    controller: modelController,
                    focusNode: modelFocusNode,
                    labelText: 'Model *',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 32,
                    prefixIcon: null,
                    requestFocusNode: weightFocusNode,
                    obscureText: false,
                    onTap: () {},
                    onChanged: (String value) {
                    },
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Enter Vessel Model';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      Utils.customPrint(value);
                      CustomLogger().logWithFile(Level.info, "vessel model $value -> $page");
                    }),
              ),
              //SizedBox(height: displayHeight(context) * 0.015),


              SizedBox(height: displayHeight(context) * 0.015),
              Form(
                key: weightFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CommonTextField(
                    controller: weightController,
                    focusNode: weightFocusNode,
                    labelText: 'Displacement ($pound) *',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 6,
                    prefixIcon: null,
                    requestFocusNode: null,
                    obscureText: false,
                    onTap: () {},
                    onChanged: (String value) {
                    },
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Enter Vessel Displacement';
                      }

                      return null;
                    },
                    onSaved: (String value) {
                      Utils.customPrint(value);
                      CustomLogger().logWithFile(Level.info, "Vessel Displacement $value -> $page");
                    }),
              ),
              SizedBox(height: displayHeight(context) * 0.015),
              Form(
                key: selectedEngineFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  margin: EdgeInsets.only(top: 2.0),
                  child: CommonDropDownFormField(
                    context: context,
                    value: selectedEngineType,
                    hintText: 'Engine Type *',
                    labelText: '',
                    onChanged: (String value) {
                      setState(() {
                        selectedEngineType = value;
                        Utils.customPrint('engine $selectedEngineType');
                        CustomLogger().logWithFile(Level.info, "engine $selectedEngineType -> $page");
                      });

                      if (selectedEngineType!.toLowerCase() == 'hybrid') {
                        setState(() {
                          isBatteryCapacityEnable = true;
                        });
                      } else {
                        setState(() {
                          isBatteryCapacityEnable = false;
                        });
                      }

                      if (selectedEngineType!.toLowerCase() == 'hybrid' ||
                          selectedEngineType!.toLowerCase() == 'combustion') {
                        // setState(() {
                        //   FocusScope.of(context)
                        //       .requestFocus(fuelCapacityFocusNode);
                        // });
                      } else if (selectedEngineType!.toLowerCase() ==
                          'electric') {
                        // setState(() {
                        //   FocusScope.of(context)
                        //       .requestFocus(batteryCapacityFocusNode);
                        // });
                      }
                    },
                    dataSource: ['Hybrid', 'Combustion', 'Electric'],
                    borderRadius: 10,
                    padding: 6,
                    textColor: Colors.black,
                    textField: 'key',
                    valueField: 'value',
                    validator: (value) {
                      if (value == null) {
                        return 'Select Vessel Engine Type';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              selectedEngineType == 'Hybrid' ||
                  selectedEngineType == 'Combustion'
                  ? Column(
                children: [
                  SizedBox(height: displayHeight(context) * 0.015),
                  Form(
                    key: fuelCapacityFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: fuelCapacityController,
                        focusNode: fuelCapacityFocusNode,
                        labelText: 'Fuel ($liters) *',
                        hintText: '',
                        suffixText: null,
                        textInputAction: selectedEngineType == 'Hybrid'
                            ? TextInputAction.next
                            : TextInputAction.done,
                        textInputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: selectedEngineType == 'Hybrid'
                            ? batteryCapacityFocusNode
                            : null,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter Fuel';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Fuel $value-> $page");
                        }),
                  ),
                ],
              )
                  : SizedBox(),
              selectedEngineType == 'Hybrid' ||
                  selectedEngineType == 'Electric'
                  ? Column(
                children: [
                  SizedBox(height: displayHeight(context) * 0.015),

                  Form(
                    key: batteryCapacityFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: CommonTextField(
                        controller: batteryCapacityController,
                        focusNode: batteryCapacityFocusNode,
                        labelText: 'Battery Capacity ($kiloWattHour) *',
                        hintText: '',
                        suffixText: null,
                        textInputAction: TextInputAction.done,
                        textInputType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 6,
                        prefixIcon: null,
                        requestFocusNode: null,
                        obscureText: false,
                        onTap: () {},
                        onChanged: (String value) {
                        },
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Enter Battery Capacity';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          Utils.customPrint(value);
                          CustomLogger().logWithFile(Level.info, "Battery Capacity $value-> $page");
                        }),
                  ),
                ],
              )
                  : SizedBox(),

              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: commonText(
                      context: context,
                      text: 'Other Optional Information',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black45,
                      textSize: displayWidth(context) * 0.036,
                      textAlign: TextAlign.start
                  ),
                  trailing: !isOtherInformation! ? Icon(
                    Icons.add,
                    color: Colors.black45,
                    size: displayWidth(context) * 0.05,
                  ) : Icon(
                    Icons.remove,
                    color: Colors.black45,
                    size: displayWidth(context) * 0.05,
                  ),
                  onExpansionChanged: ((newState) {
                    setState(() {
                      isOtherInformation = newState;
                    });

                    Utils.customPrint(
                        'EXPANSION CHANGE $isOtherInformation');
                    CustomLogger().logWithFile(Level.info, "EXPANSION CHANGE $isOtherInformation -> $page");
                  }),
                  //maintainState: true,
                  expandedCrossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: displayHeight(context) * 0.0045),
                    Form(
                      key: builderNameFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: CommonTextField(
                          controller: builderNameController,
                          focusNode: builderNameFocusNode,
                          labelText: 'Builder Name',
                          hintText: '',
                          suffixText: null,
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 32,
                          prefixIcon: null,
                          requestFocusNode: registrationNumberFocusNode,
                          obscureText: false,
                          onTap: () {},
                          onChanged: (String value) {
                          },
                          validator: (value) {
                            return null;
                          
                            /*if (value!.trim().isEmpty) {
                              return 'Enter Vessel Builder Name';
                            }

                            return null;*/
                          },
                          onSaved: (String value) {
                            Utils.customPrint(value);
                            CustomLogger().logWithFile(Level.info, "Vessel Builder Name $value -> $page");
                          }),
                    ),
                    SizedBox(height: displayHeight(context) * 0.015),
                    Form(
                      key: regNumberFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: CommonTextField(
                          controller: registrationNumberController,
                          focusNode: registrationNumberFocusNode,
                          labelText: 'Registration Number',
                          hintText: '',
                          suffixText: null,
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 10,
                          prefixIcon: null,
                          requestFocusNode: mmsiFocusNode,
                          obscureText: false,
                          onTap: () {},
                          onChanged: (String value) {},
                          onSaved: (String value) {
                            Utils.customPrint(value);
                            CustomLogger().logWithFile(Level.info, "Registration Number $value -> $page");
                          }),
                    ),
                    SizedBox(height: displayHeight(context) * 0.015),
                    Form(
                      key: mmsiFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: CommonTextField(
                          controller: mmsiController,
                          focusNode: mmsiFocusNode,
                          labelText: 'MMSI',
                          hintText: '',
                          suffixText: null,
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 10,
                          prefixIcon: null,
                          requestFocusNode: null,
                          obscureText: false,
                          onTap: () {},
                          onChanged: (String value) {},
                          onSaved: (String value) {
                            Utils.customPrint(value);
                            CustomLogger().logWithFile(Level.info, "MMSI $value -> $page");
                          }),
                    ),
                    SizedBox(height: displayHeight(context) * 0.015),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(
                  // bottom: displayHeight(context) * 0.02,
                    top: displayHeight(context) * 0.02),
                child: Column(
                  children: [
                    CommonButtons.getActionButton(
                        title: 'Next',
                        context: context,
                        fontSize: displayWidth(context) * 0.042,
                        textColor: Colors.white,
                        buttonPrimaryColor: blueColor,
                        borderColor: blueColor,
                        width: displayWidth(context),
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());

                          if (nameFormKey.currentState!.validate() && modelFormKey.currentState!.validate() && weightFormKey.currentState!.validate() && selectedEngineFormKey.currentState!.validate()
                              && (selectedEngineType!.toLowerCase() == 'hybrid' ? fuelCapacityFormKey.currentState!.validate() && batteryCapacityFormKey.currentState!.validate()
                                  : selectedEngineType!.toLowerCase() == 'combustion' ? fuelCapacityFormKey.currentState!.validate() : batteryCapacityFormKey.currentState!.validate())
                          ) {
                            if(isDeleted){
                              commonProvider.selectedImageFiles = [];
                              //widget.addVesselData?.imageURLs = '';
                            }
                            /*    Utils.customPrint(
                                'FINAL SELECTED FILES ${finalSelectedFiles.isEmpty}');
                            CustomLogger().logWithFile(Level.info, "FINAL SELECTED FILES ${finalSelectedFiles.isEmpty} -> $page");
                            // return; */

                            Utils.customPrint(
                                'Displacement ${int.parse(weightController.text)}');
                            CustomLogger().logWithFile(Level.info, "WEIGHT 1 ${int.parse(weightController.text)} -> $page");

                            commonProvider.addVesselRequestModel = CreateVessel();

                            commonProvider.addVesselRequestModel!.name =
                                nameController.text.trim();
                            commonProvider.addVesselRequestModel!.model =
                                modelController.text.trim();
                            commonProvider.addVesselRequestModel!.builderName =
                                builderNameController.text.trim();
                            commonProvider.addVesselRequestModel!.regNumber =
                                registrationNumberController.text.trim();
                            commonProvider.addVesselRequestModel!.mMSI =
                                mmsiController.text.trim();
                            commonProvider.addVesselRequestModel!.engineType =
                                selectedEngineType!;
                            commonProvider.addVesselRequestModel!.fuelCapacity =
                            fuelCapacityController.text.isEmpty
                                ? '0'
                                : fuelCapacityController.text.trim();
                            commonProvider.addVesselRequestModel!.weight =
                                weightController.text.trim();
                            commonProvider.selectedImageFiles = finalSelectedFiles.isEmpty
                                ? []
                                : finalSelectedFiles;
                            // commonProvider.addVesselRequestModel!.selectedImages =
                            // finalSelectedFiles.isEmpty
                            //     ? []
                            //     : finalSelectedFiles;
                            commonProvider.addVesselRequestModel!.batteryCapacity =
                            batteryCapacityController.text.isEmpty
                                ? '0'
                                : batteryCapacityController.text.trim();
                            commonProvider.addVesselRequestModel!.imageURLs =
                            widget.addVesselData == null
                                ? ''
                                : widget.addVesselData!.imageURLs == null ||
                                widget.addVesselData!.imageURLs!.isEmpty
                                ? ''
                                : widget.addVesselData!.imageURLs;

                            Utils.customPrint(
                                'Step ONE VESSEL NAME: ${nameController.text}');

                            Utils.customPrint(
                                'Step ONE VESSEL NAME: ${nameController.text}');

                            Utils.customPrint(
                                'Step ONE VESSEL NAME: ${nameController.text}');

                            CustomLogger().logWithFile(Level.info, "Step ONE VESSEL NAME: ${nameController.text} -> $page");
                            //Utils.customPrint('Step ONE VESSEL NAME: ${nameController.text}');

                            FocusScope.of(context).requestFocus(new FocusNode());

                            widget.pageController!.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                    isDeleted = true;
                    finalSelectedFiles.clear();
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
                  finalSelectedFiles.clear();
                  isImageSelected = true;
                  finalSelectedFiles.addAll(selectedImageFileList);
                  commonProvider.selectedImageFiles = selectedImageFileList;
                  //  widget.addVesselData?.selectedImages = selectedImageFileList;
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
                    widget.addVesselData?.selectedImages = selectedImageFileList;
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
            value: 0.5,
            isCallingFromAddVessel: true
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}