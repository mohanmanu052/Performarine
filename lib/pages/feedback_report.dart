import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../common_widgets/utils/colors.dart';
import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/utils.dart';
import '../common_widgets/widgets/common_buttons.dart';
import '../common_widgets/widgets/common_text_feild.dart';
import '../common_widgets/widgets/common_widgets.dart';
import 'dart:io';

import '../common_widgets/widgets/log_level.dart';
import '../models/device_model.dart';

class FeedbackReport extends StatefulWidget {
  final String? imagePath;
  File? file;
  List<int>? uIntList;
  FeedbackReport({this.imagePath = "",this.file,this.uIntList,Key? key}) : super(key: key);

  @override
  State<FeedbackReport> createState() => _FeedbackReportState();
}

class _FeedbackReportState extends State<FeedbackReport> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  List<File?> finalSelectedFiles = [];
  List<File?> sendFiles = [];
  File? imageFile;

  late CommonProvider commonProvider;
  bool isBtnClick = false;

  String? _result;
  bool _isRecursive = false;

  var totalSize = 1;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;
  Map<String,dynamic>? deviceDetails;

  String page = "feedback_report";

  @override
  void initState() {
    super.initState();

    commonProvider = context.read<CommonProvider>();
    commonProvider.init();
    nameController  = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        centerTitle: true,
        title: commonText(
            context: context,
            text: 'Feedback Report',
            fontWeight: FontWeight.w600,
            textColor: Colors.black,
            textSize: displayWidth(context) * 0.05,
            textAlign: TextAlign.start),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [

              Image.asset(
                "assets/images/mail_new.png",
                //width: displayWidth(context) * 0.4,
                height: displayHeight(context) * 0.2,
              ),

              Padding(
                padding: EdgeInsets.only(
                  left: displayWidth(context) * 0.07,
                  right: displayWidth(context) * 0.07,
                  top: displayWidth(context) * 0.04,
                ),
                child: commonText(
                    context: context,
                    text: 'Please let us know what happened so we can fix it. Your feedback is important to us. Thank you for your support!',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.035,
                    textAlign: TextAlign.start
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  left: displayWidth(context) * 0.07,
                  right: displayWidth(context) * 0.07,
                  top: displayWidth(context) * 0.06,
                ),
                child: commonText(
                    context: context,
                    text: 'If you experienced a crash or error message, please provide any details or steps that may have led to the issue. The more information you can provide, the better equipped we"ll be to diagnose and address the problem.',
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black,
                    textSize: displayWidth(context) * 0.035,
                    textAlign: TextAlign.start),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: displayWidth(context) * 0.05,
                  left: displayWidth(context) * 0.06,
                  right: displayWidth(context) * 0.06,
                ),
                child: CommonTextField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    labelText: 'Subject*',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    // maxLength: 32,
                    prefixIcon: null,
                    requestFocusNode: descriptionFocusNode,
                    obscureText: false,
                    onTap: () {},
                    onChanged: (String value) {},
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Enter Subject';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      Utils.customPrint(value);
                      CustomLogger().logWithFile(Level.info, "Subject: $value-> $page");
                    }),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: displayWidth(context) * 0.05,
                  left: displayWidth(context) * 0.06,
                  right: displayWidth(context) * 0.06,
                ),
                child: CommonTextField(
                    controller: descriptionController,
                    focusNode: descriptionFocusNode,
                    labelText: 'Description',
                    hintText: '',
                    suffixText: null,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    // maxLength: 32,
                    prefixIcon: null,
                    requestFocusNode: null,
                    obscureText: false,
                    onTap: () {},
                    onChanged: (String value) {},
                    validator: (value) {
                      // if (value!.trim().isEmpty) {
                      //   return 'Enter Description';
                      // }
                      // return true;
                    },
                    onSaved: (String value) {
                      Utils.customPrint(value);
                      CustomLogger().logWithFile(Level.info, "Description: $value-> $page");
                    }),
              ),

              Container(
                margin: EdgeInsets.only(top: 10.0),
                child: CommonButtons.getDottedButton(
                    'Upload Images', context, () {
                  uploadImageFunction();
                  Utils.customPrint(
                      'FIIALLL: ${finalSelectedFiles.length}');
                  CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles.length} -> $page");
                }, Colors.grey),
              ),

              Container(
               // margin: const EdgeInsets.only(top: 15.0),
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
                          height: displayHeight(context) * 0.035,
                          width: displayHeight(context) * 0.045,
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
                                /*child: Icon(
                                              Icons.close,
                                              size: displayWidth(context) * 0.05,
                                            ),*/
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: InkWell(
                                  onTap: () {
                                    Utils.customPrint(
                                        'FIIALLL: ${finalSelectedFiles.length}');
                                    CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles.length} -> $page");
                                    setState(() {
                                      finalSelectedFiles
                                          .removeAt(index);
                                    });
                                    Utils.customPrint(
                                        'FIIALLL: ${finalSelectedFiles.length}');
                                    CustomLogger().logWithFile(Level.info, "FIIALLL: ${finalSelectedFiles.length} -> $page");
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

              Padding(
                padding: EdgeInsets.only(
                  left: displayWidth(context) * 0.06,
                  right: displayWidth(context) * 0.06,
                  // top: displayWidth(context) * 0.02,
                ),
                child: isBtnClick ?  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          circularProgressColor),
                    ))
                    : CommonButtons.getActionButton(
                    title: 'Submit',
                    context: context,
                    fontSize: displayWidth(context) * 0.044,
                    textColor: Colors.white,
                    buttonPrimaryColor: buttonBGColor,
                    borderColor: buttonBGColor,
                    width: displayWidth(context),
                    onTap: () async {
                      if(formKey.currentState!.validate()){
                        bool check = await Utils().check(scaffoldKey);

                        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
                        if (Platform.isAndroid) {
                          androidDeviceInfo = await deviceInfoPlugin.androidInfo;
                          deviceDetails = {
                            'deviceId': androidDeviceInfo?.id,
                            'model': androidDeviceInfo?.model,
                            'version': androidDeviceInfo?.version.release,
                            'make': androidDeviceInfo?.manufacturer,
                            'board': androidDeviceInfo?.board,
                            'deviceType': androidDeviceInfo?.type,
                          };
                        } else if (Platform.isIOS) {
                          iosDeviceInfo = await deviceInfoPlugin.iosInfo;
                          deviceDetails = {
                            'deviceId': '',
                            'model': iosDeviceInfo?.model,
                            'version': iosDeviceInfo?.utsname.release,
                            'make': iosDeviceInfo?.utsname.machine,
                            'board': iosDeviceInfo?.utsname.machine,
                            'deviceType': iosDeviceInfo?.utsname.machine,
                          };
                        }
                        Utils.customPrint("deviceDetails:${deviceDetails!.toString()}");
                        CustomLogger().logWithFile(Level.info, "deviceDetails:${deviceDetails!.toString()} -> $page");

                        Utils.customPrint("deviceDetails:${commonProvider.loginModel!.token!}");

                        if(check){
                          final Directory appDir = await getApplicationDocumentsDirectory();
                          final String fileName = DateTime.now().toIso8601String() + '.png';
                          Directory directory = Directory('${appDir.path}/Feedback');
                          if ((await directory.exists())) {
                            var size = await _displayDirectorySize(directory.path,true);
                            if(size > 1.0){
                              directory.listSync().forEach((entity) {
                                if (entity is File) {
                                  entity.deleteSync();
                                }
                              });
                            }

                            imageFile = File('${directory.path}/$fileName');
                            await imageFile?.writeAsBytes(widget.uIntList!);

                            sendFiles.addAll(finalSelectedFiles);
                            sendFiles.add(imageFile);
                            setState(() {
                              isBtnClick = true;
                            });
                            commonProvider?.sendUserFeedbackDio(
                                context,
                                commonProvider!.loginModel!.token!,
                                nameController.text,
                                descriptionController.text,
                                deviceDetails!,
                                sendFiles,
                                scaffoldKey).then((value) async{
                              if(value != null){
                                setState(() {
                                  isBtnClick = false;
                                });
                                print("status of send user feedback is: ${value.status}");
                                CustomLogger().logWithFile(Level.info, "status of send user feedback is: ${value.status} -> $page");
                                if(value.status!){
                                  deleteImageFile(imageFile!.path);
                                  sendFiles.clear();
                                  finalSelectedFiles.clear();
                                  Navigator.pop(context);
                                }
                              } else{
                                setState(() {
                                  isBtnClick = false;
                                });
                              }
                            }).catchError((e){
                              setState(() {
                                isBtnClick = false;
                              });
                            });
                          } else {
                            directory.create();
                            imageFile = File('${directory.path}/$fileName');
                            sendFiles.addAll(finalSelectedFiles);
                            await imageFile?.writeAsBytes(widget.uIntList!);


                            sendFiles.add(imageFile);
                            setState(() {
                              isBtnClick = true;
                            });

                            debugPrint("REPORT TOKEN ${commonProvider!.loginModel!.token!}");
                            commonProvider?.sendUserFeedbackDio(
                                context,
                                commonProvider!.loginModel!.token!,
                                nameController.text,
                                descriptionController.text,
                                {},
                                sendFiles,
                                scaffoldKey).then((value) async{
                              if(value != null){
                                setState(() {
                                  isBtnClick = false;
                                });
                                print("status of send user feedback is: ${value.status}");
                                CustomLogger().logWithFile(Level.info, "status of send user feedback is: ${value.status} -> $page");
                                if(value.status!){
                                  deleteImageFile(imageFile!.path);
                                  Navigator.pop(context);
                                }
                              } else{
                                setState(() {
                                  isBtnClick = false;
                                });
                              }
                            }).catchError((e){
                              setState(() {
                                isBtnClick = false;
                              });
                            });
                          }
                        }else{
                          setState(() {
                            isBtnClick = false;
                          });
                        }
                      }
                    }
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getDirectorySize(String path, bool isRecursive) async {
    final entityList = await Directory(path).list(recursive: isRecursive).toList();

    await Future.forEach(entityList, (entity) async {
      if (entity is File) {
        final fileBytes = await File(entity.path).readAsBytes();
        totalSize += fileBytes.lengthInBytes;
      }
    });
    print('totalSize: $totalSize');
    CustomLogger().logWithFile(Level.info, "totalSize: $totalSize -> $page");
    return totalSize;
  }

  Future<double> _displayDirectorySize(String path, bool isRecursive) async {
    final fileSizeInBytes = await _getDirectorySize(path, isRecursive);
    double fileSize = _displaySize(fileSizeInBytes);
    return fileSize;
  }

  double _displaySize(int fileSizeInBytes) {
    final fileSizeInKB = fileSizeInBytes / 1000;
    final fileSizeInMB = fileSizeInKB / 1000;
    final fileSizeInGB = fileSizeInMB / 1000;
    final fileSizeInTB = fileSizeInGB / 1000;

    final fileSize = '''
  $fileSizeInBytes bytes
  $fileSizeInKB KB
  $fileSizeInMB MB
  $fileSizeInGB GB
  $fileSizeInTB TB
      ''';

    print("file size: $fileSize");
    CustomLogger().logWithFile(Level.info, "file Size: $fileSize -> $page");

    setState(() {
      _result = fileSize;
    });
    return fileSizeInMB;
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

      // bool isStoragePermissionGranted = await Permission.storage.isGranted;

      if (isStoragePermissionGranted) {
        await selectImage(context, Colors.red,
                (List<File?> selectedImageFileList) {
              if (selectedImageFileList.isNotEmpty) {
                setState(() {
                  //finalSelectedFiles.clear();
                  finalSelectedFiles.addAll(selectedImageFileList);
                  Utils.customPrint('CAMERA FILE 2 ${finalSelectedFiles[0]!.path}');
                  Utils.customPrint(
                      'CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()}');

                  CustomLogger().logWithFile(Level.info, "CAMERA FILE 2 ${finalSelectedFiles[0]!.path} -> $page");
                  CustomLogger().logWithFile(Level.info, "CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()} -> $page");

                  /* setState(() {
              finalSelectedFiles.addAll(finalSelectedFiles);
            });*/
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
                    //  finalSelectedFiles.clear();
                    finalSelectedFiles.addAll(selectedImageFileList);
                    Utils.customPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');
                    Utils.customPrint('finalSelectedFiles length:  ${finalSelectedFiles.length}');

                    CustomLogger().logWithFile(Level.info, "CAMERA FILE ${finalSelectedFiles[0]!.path} -> $page");
                    CustomLogger().logWithFile(Level.info, "finalSelectedFiles length:  ${finalSelectedFiles.length}-> $page");

                    /* setState(() {
              finalSelectedFiles.addAll(finalSelectedFiles);
            });*/
                  });
                }
              });
        }
      }
    } else {
      Utils.customPrint('OTHER ELSE');
      CustomLogger().logWithFile(Level.info, "OTHER ELSE -> $page");
      await selectImage(context, Colors.red,
              (List<File?> selectedImageFileList) {
            if (selectedImageFileList.isNotEmpty) {
              setState(() {
                // finalSelectedFiles.clear();
                finalSelectedFiles.addAll(selectedImageFileList);
                Utils.customPrint('CAMERA FILE ${finalSelectedFiles[0]!.path}');
                Utils.customPrint(
                    'CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()}');
                Utils.customPrint('finalSelectedFiles length1:  ${finalSelectedFiles.length}');

                CustomLogger().logWithFile(Level.info, "CAMERA FILE ${finalSelectedFiles[0]!.path} -> $page");
                CustomLogger().logWithFile(Level.info, "CAMERA FILE ${File(finalSelectedFiles[0]!.path).existsSync()} -> $page");
                CustomLogger().logWithFile(Level.info, "finalSelectedFiles length:  ${finalSelectedFiles.length}-> $page");

                /* setState(() {
              finalSelectedFiles.addAll(finalSelectedFiles);
            });*/
              });
            }
          });
    }
  }


  Future<String> captureAndSaveScreenshot() async {
    // final Uint8List? imageBytes = await controller.capture();

    final Directory appDir = await getApplicationDocumentsDirectory();

    final String fileName = DateTime.now().toIso8601String() + '.png';
    imageFile = File('${appDir.path}/$fileName');
    print("file path is: ${imageFile!.path}-> $page ${DateTime.now()}");
    CustomLogger().logWithFile(Level.info, "file path is: ${imageFile!.path} -> $page");

    await imageFile!.writeAsBytes(widget.uIntList!);

    // deleteImageAfterDelay(imageFile!.path);

    return imageFile!.path;
  }


  Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      print('Image deleted successfully');
      CustomLogger().logWithFile(Level.info, "Image deleted successfully -> $page");
    } catch (e) {
      CustomLogger().logWithFile(Level.error, "Failed to delete image -> $page");
      print('Failed to delete image: $e');
    }
  }

}
