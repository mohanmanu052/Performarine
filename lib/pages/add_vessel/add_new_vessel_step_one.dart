import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_dropdown.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddVesselStepOne extends StatefulWidget {
  final PageController? pageController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CreateVessel? addVesselData;
  final bool? isEdit;
  const AddVesselStepOne(
      {Key? key,
      this.pageController,
      this.scaffoldKey,
      this.addVesselData,
      this.isEdit})
      : super(key: key);

  @override
  State<AddVesselStepOne> createState() => _AddVesselStepOneState();
}

class _AddVesselStepOneState extends State<AddVesselStepOne>
    with AutomaticKeepAliveClientMixin<AddVesselStepOne> {
  late GlobalKey<ScaffoldState> scaffoldKey;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  List<File?> pickFilePath = [];
  List<File?> finalSelectedFiles = [];

  String? selectedEngineType;

  late CommonProvider commonProvider;

  List<String> deletedImageUrls = [];

  bool? isBatteryCapacityEnable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });

    //commonProvider = context.read<CommonProvider>();

    if (widget.isEdit!) {
      if (widget.addVesselData != null) {
        debugPrint('ENGINE TYPE ${widget.addVesselData!.engineType!}');

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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();

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
                      text: 'Step 1/2',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.03),
                  CommonTextField(
                      controller: nameController,
                      focusNode: nameFocusNode,
                      labelText: 'Name*',
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
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel name';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: modelController,
                      focusNode: modelFocusNode,
                      labelText: 'Model*',
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
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel model';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: builderNameController,
                      focusNode: builderNameFocusNode,
                      labelText: 'Builder Name*',
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
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel builder name';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
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
                      /*validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter registration number';
                        }

                        return null;
                      },*/
                      onSaved: (String value) {
                        print(value);
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
                      requestFocusNode: null,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      /*validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter MMSI';
                        }

                        return null;
                      },*/
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  Container(
                    margin: EdgeInsets.only(top: 8.0),
                    child: CommonDropDownFormField(
                      context: context,
                      value: selectedEngineType,
                      hintText: 'Engine Type*',
                      labelText: '',
                      onChanged: (String value) {
                        formKey.currentState!.validate();

                        setState(() {
                          selectedEngineType = value;
                          print('engine $selectedEngineType');
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
                      },
                      dataSource: ['Hybrid', 'Combustion', 'Electric'],
                      borderRadius: 10,
                      padding: 6,
                      textColor: Colors.black,
                      textField: 'key',
                      valueField: 'value',
                      validator: (value) {
                        if (value == null) {
                          return 'Select vessel engine type';
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
                                labelText: 'Fuel Capacity (gal)*',
                                hintText: '',
                                suffixText: null,
                                textInputAction: TextInputAction.next,
                                textInputType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 6,
                                prefixIcon: null,
                                requestFocusNode: weightFocusNode,
                                obscureText: false,
                                onTap: () {},
                                onChanged: (String value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter fuel capacity';
                                  }

                                  return null;
                                },
                                onSaved: (String value) {
                                  print(value);
                                }),
                          ],
                        )
                      : SizedBox(),
                  selectedEngineType == 'Hybrid' ||
                          selectedEngineType == 'Electric'
                      ? Column(
                          children: [
                            SizedBox(height: displayHeight(context) * 0.015),

                            //SizedBox(height: displayHeight(context) * 0.015),
                            CommonTextField(
                                controller: batteryCapacityController,
                                focusNode: batteryCapacityFocusNode,
                                labelText: 'Battery Capacity(kw)*',
                                hintText: '',
                                suffixText: null,
                                textInputAction: TextInputAction.next,
                                textInputType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 6,
                                prefixIcon: null,
                                requestFocusNode: weightFocusNode,
                                obscureText: false,
                                onTap: () {},
                                onChanged: (String value) {},
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter battery capacity';
                                  }

                                  return null;
                                },
                                onSaved: (String value) {
                                  print(value);
                                }),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: weightController,
                      focusNode: weightFocusNode,
                      labelText: 'Weight (lb)*',
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
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel weight';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: CommonButtons.getDottedButton(
                        'Upload Images', context, () {
                      uploadImageFunction();
                    }, Colors.grey),
                  ),
                  SizedBox(height: displayHeight(context) * 0.01),
                  /*widget.addVesselData == null
                      ? SizedBox()
                      : widget.addVesselData!.imageURLs == null
                          ? SizedBox()
                          : widget.addVesselData!.imageURLs!.isEmpty
                              ? SizedBox()
                              : Container(
                                  margin: const EdgeInsets.only(top: 15.0),
                                  child: SingleChildScrollView(
                                    child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 1,
                                          mainAxisSpacing: 1,
                                        ),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: widget
                                            .addVesselData!.imageURLs!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            height:
                                                displayHeight(context) * 0.06,
                                            width:
                                                displayHeight(context) * 0.06,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.all(6),
                                                  alignment: Alignment.topRight,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(widget
                                                                  .addVesselData!
                                                                  .imageURLs![
                                                              index]))

                                                  ),
                                                  child: CachedNetworkImage(
                                                    height:
                                                        displayHeight(context) *
                                                            0.12,
                                                    width:
                                                        displayHeight(context) *
                                                            0.12,
                                                    // imageUrl: 'https://picsum.photos/200',
                                                    imageUrl: widget
                                                        .addVesselData!
                                                        .imageURLs![index],
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                downloadProgress) =>
                                                            Center(
                                                      child: CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
child: Icon(
                                      Icons.close,
                                      size: displayWidth(context) * 0.05,
                                    ),

                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        deletedImageUrls.add(
                                                            widget.addVesselData!
                                                                    .imageURLs![
                                                                index]);
                                                        widget.addVesselData!
                                                            .imageURLs!
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      size: displayWidth(
                                                              context) *
                                                          0.05,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ),*/
                  finalSelectedFiles.isEmpty
                      ? Container()
                      : Container(
                          margin: const EdgeInsets.only(top: 15.0),
                          child: SingleChildScrollView(
                            child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 1,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: finalSelectedFiles.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: displayHeight(context) * 0.06,
                                    width: displayHeight(context) * 0.06,
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
                                                    File(finalSelectedFiles[
                                                            index]!
                                                        .path),
                                                  ))),
                                          child: Icon(
                                            Icons.close,
                                            size: displayWidth(context) * 0.05,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                finalSelectedFiles
                                                    .removeAt(index);
                                              });
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size:
                                                  displayWidth(context) * 0.05,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                    bottom: displayHeight(context) * 0.02,
                    top: displayHeight(context) * 0.02),
                child: CommonButtons.getActionButton(
                    title: 'Next',
                    context: context,
                    fontSize: displayWidth(context) * 0.042,
                    textColor: Colors.white,
                    buttonPrimaryColor: buttonBGColor,
                    borderColor: buttonBGColor,
                    width: displayWidth(context),
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        debugPrint(
                            'FINAL SELECTED FILES ${finalSelectedFiles.isEmpty}');
                        // return;

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
                            int.parse(weightController.text);
                        commonProvider.addVesselRequestModel!.selectedImages =
                            finalSelectedFiles.isEmpty
                                ? []
                                : finalSelectedFiles;
                        commonProvider.addVesselRequestModel!.batteryCapacity =
                            batteryCapacityController.text.isEmpty
                                ? '0'
                                : batteryCapacityController.text;
                        /* commonProvider.addVesselRequestModel!.imageURLs =
                            deletedImageUrls.isNotEmpty
                                ? deletedImageUrls.join(',')
                                : " ";*/

                        widget.pageController!.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                      /*Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
                              ); */
                    }),
              ),
            ],
          ),
        ));
  }

  uploadImageFunction() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      bool isStoragePermissionGranted = false;

      if (androidInfo.version.sdkInt <= 32) {
        isStoragePermissionGranted = await Permission.storage.isGranted;
      } else {
        isStoragePermissionGranted = await Permission.photos.isGranted;
      }

      // bool isStoragePermissionGranted = await Permission.storage.isGranted;

      if (isStoragePermissionGranted) {
        await selectImage(context, Colors.red,
            (List<File?> selectedImageFileList) {
          setState(() {
            finalSelectedFiles.clear();
            finalSelectedFiles.addAll(selectedImageFileList);
            kReleaseMode
                ? null
                : debugPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');

            /* setState(() {
              finalSelectedFiles.addAll(finalSelectedFiles);
            });*/
          });
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
            setState(() {
              finalSelectedFiles.clear();
              finalSelectedFiles.addAll(selectedImageFileList);
              kReleaseMode
                  ? null
                  : debugPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');
              /*setState(() {
                finalSelectedFiles.addAll(finalSelectedFiles);
              });*/
            });
          });
        }
      }
    } else {
      debugPrint('OTHER ELSE');
      await selectImage(context, Colors.red,
          (List<File?> selectedImageFileList) {
        setState(() {
          finalSelectedFiles.clear();
          finalSelectedFiles.addAll(selectedImageFileList);
          kReleaseMode
              ? null
              : debugPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');

          /*setState(() {
            finalSelectedFiles.addAll(finalSelectedFiles);
          });*/
        });
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
