import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusScopeNode node = FocusScopeNode();

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
  bool? isBatteryCapacityEnable = false;
  List<File?> pickFilePath = [];
  List<File?> finalSelectedFiles = [];
  double sliderValue = 0.0;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.isEdit! ? sliderValue = 0.35 : sliderValue = 0.05;
    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });

    if (widget.isEdit!) {
      if (widget.addVesselData != null) {
        Utils.customPrint('ENGINE TYPE ${widget.addVesselData!.engineType!}');

        CustomLogger().logWithFile(Level.info, "ENGINE TYPE ${widget.addVesselData!.engineType!} -> $page");

        nameController.text = widget.addVesselData!.name!;
        modelController.text = widget.addVesselData!.model!;
        builderNameController.text = widget.addVesselData!.builderName!;
        registrationNumberController.text = widget.addVesselData!.regNumber!;
        mmsiController.text = widget.addVesselData!.mMSI!;
        selectedEngineType = widget.addVesselData!.engineType!.trim();
        fuelCapacityController.text =
            widget.addVesselData!.fuelCapacity!.toString();
        batteryCapacityController.text =
            widget.addVesselData!.batteryCapacity!.toString();
        weightController.text = widget.addVesselData!.weight!.toString();
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
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Form(
      key: formKey,
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
              CommonTextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  labelText: 'Name of the Vessel',
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
                    setState(() {
                      sliderValue = 0.10;
                    });
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
              SizedBox(height: displayHeight(context) * 0.015),
              CommonTextField(
                  controller: modelController,
                  focusNode: modelFocusNode,
                  labelText: 'Model',
                  hintText: '',
                  suffixText: null,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 32,
                  prefixIcon: null,
                  requestFocusNode: builderNameFocusNode,
                  obscureText: false,
                  onTap: () {},
                  onChanged: (String value) {
                    setState(() {
                      sliderValue = 0.15;
                    });
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
              SizedBox(height: displayHeight(context) * 0.015),
              CommonTextField(
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
                    setState(() {
                      sliderValue = 0.20;
                    });
                  },
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Enter Vessel Builder Name';
                    }

                    return null;
                  },
                  onSaved: (String value) {
                    Utils.customPrint(value);
                    CustomLogger().logWithFile(Level.info, "Vessel Builder Name $value -> $page");
                  }),
              SizedBox(height: displayHeight(context) * 0.015),
              CommonTextField(
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
              SizedBox(height: displayHeight(context) * 0.015),
              CommonTextField(
                  controller: mmsiController,
                  focusNode: mmsiFocusNode,
                  labelText: 'MMSI',
                  hintText: '',
                  suffixText: null,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 10,
                  prefixIcon: null,
                  requestFocusNode: weightFocusNode,
                  obscureText: false,
                  onTap: () {},
                  onChanged: (String value) {},
                  onSaved: (String value) {
                    Utils.customPrint(value);
                    CustomLogger().logWithFile(Level.info, "MMSI $value -> $page");
                  }),
              SizedBox(height: displayHeight(context) * 0.015),
              CommonTextField(
                  controller: weightController,
                  focusNode: weightFocusNode,
                  labelText: 'Weight (lb)',
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
                    setState(() {
                      sliderValue = 0.25;
                    });
                  },
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Enter Vessel Weight';
                    }

                    return null;
                  },
                  onSaved: (String value) {
                    Utils.customPrint(value);
                    CustomLogger().logWithFile(Level.info, "Vessel Weight $value -> $page");
                  }),
              SizedBox(height: displayHeight(context) * 0.015),
              Container(
                margin: EdgeInsets.only(top: 2.0),
                child: CommonDropDownFormField(
                  context: context,
                  value: selectedEngineType,
                  hintText: 'Engine Type',
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
              selectedEngineType == 'Hybrid' ||
                  selectedEngineType == 'Combustion'
                  ? Column(
                children: [
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: fuelCapacityController,
                      focusNode: fuelCapacityFocusNode,
                      labelText: 'Fuel Capacity(l/kw)',
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
                        setState(() {
                          sliderValue = 0.30;
                        });
                      },
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Enter Fuel Capacity';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        Utils.customPrint(value);
                        CustomLogger().logWithFile(Level.info, "Fuel Capacity $value-> $page");
                      }),
                ],
              )
                  : SizedBox(),
              selectedEngineType == 'Hybrid' ||
                  selectedEngineType == 'Electric'
                  ? Column(
                children: [
                  SizedBox(height: displayHeight(context) * 0.015),

                  CommonTextField(
                      controller: batteryCapacityController,
                      focusNode: batteryCapacityFocusNode,
                      labelText: 'Battery Capacity(kw)',
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
                        setState(() {
                          sliderValue = 0.35;
                        });
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
                ],
              )
                  : SizedBox(),

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

                          if (formKey.currentState!.validate()) {
                        /*    Utils.customPrint(
                                'FINAL SELECTED FILES ${finalSelectedFiles.isEmpty}');
                            CustomLogger().logWithFile(Level.info, "FINAL SELECTED FILES ${finalSelectedFiles.isEmpty} -> $page");
                            // return; */

                            Utils.customPrint(
                                'WEIGHT 1 ${int.parse(weightController.text)}');
                            CustomLogger().logWithFile(Level.info, "WEIGHT 1 ${int.parse(weightController.text)} -> $page");

                            commonProvider.addVesselRequestModel = CreateVessel();

                            commonProvider.addVesselRequestModel!.name =
                                nameController.text;
                            commonProvider.addVesselRequestModel!.model =
                                modelController.text;
                            commonProvider.addVesselRequestModel!.builderName =
                                builderNameController.text;
                            commonProvider.addVesselRequestModel!.regNumber =
                                registrationNumberController.text;
                            commonProvider.addVesselRequestModel!.mMSI =
                                mmsiController.text;
                            commonProvider.addVesselRequestModel!.engineType =
                                selectedEngineType;
                            commonProvider.addVesselRequestModel!.fuelCapacity =
                            fuelCapacityController.text.isEmpty
                                ? '0'
                                : fuelCapacityController.text;
                            commonProvider.addVesselRequestModel!.weight =
                                weightController.text;
                            commonProvider.addVesselRequestModel!.selectedImages =
                            finalSelectedFiles.isEmpty
                                ? []
                                : finalSelectedFiles;
                            commonProvider.addVesselRequestModel!.batteryCapacity =
                            batteryCapacityController.text.isEmpty
                                ? '0'
                                : batteryCapacityController.text;
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
                    widget.addVesselData?.imageURLs = '';
                    finalSelectedFiles.clear();
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
            value: sliderValue,
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
