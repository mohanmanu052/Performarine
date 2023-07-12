import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  CommonProvider? commonProvider;
  bool isBtnClick = false;

  @override
  void initState() {
    super.initState();
    commonProvider = context.read<CommonProvider>();
    nameController  = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: commonBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: commonBackgroundColor,
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: displayWidth(context) * 0.07,
                right: displayWidth(context) * 0.07,
                top: displayWidth(context) * 0.04,
              ),
              child: commonText(
                  context: context,
                  text: 'We "re sorry for the experience. Please let us know what happened so we can fix it. Your feedback is important to us. Thank you for your support!',
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
                  labelText: 'Name',
                  hintText: '',
                  suffixText: null,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 32,
                  prefixIcon: null,
                  requestFocusNode: descriptionFocusNode,
                  obscureText: false,
                  onTap: () {},
                  onChanged: (String value) {},
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Enter Vessel Name';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    Utils.customPrint(value);
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
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 32,
                  prefixIcon: null,
                  requestFocusNode: null,
                  obscureText: false,
                  onTap: () {},
                  onChanged: (String value) {},
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Enter Vessel Name';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    Utils.customPrint(value);
                  }),
            ),

            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: CommonButtons.getDottedButton(
                  'Upload Images', context, () {
                uploadImageFunction();
                Utils.customPrint(
                    'FIIALLL: ${finalSelectedFiles.length}');
              }, Colors.grey),
            ),

            Container(
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
                        height: displayHeight(context) * 0.045,
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
                                  setState(() {
                                    finalSelectedFiles
                                        .removeAt(index);
                                  });
                                  Utils.customPrint(
                                      'FIIALLL: ${finalSelectedFiles.length}');
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
                top: displayHeight(context) * 0.23,
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
                    final Directory appDir = await getApplicationDocumentsDirectory();
                    final String fileName = DateTime.now().toIso8601String() + '.png';
                    imageFile = File('${appDir.path}/$fileName');
                    sendFiles.addAll(finalSelectedFiles);
                   await imageFile?.writeAsBytes(widget.uIntList!);
                    sendFiles.add(imageFile);
                    setState(() {
                      isBtnClick = true;
                    });
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
                    });;
                  }),
            ),

          ],
        ),
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
    print("file path is: ${imageFile!.path}");

    await imageFile!.writeAsBytes(widget.uIntList!);

   // deleteImageAfterDelay(imageFile!.path);

    return imageFile!.path;
  }

  /*
  void deleteImageAfterDelay(String imagePath) {
    const delayDuration = Duration(seconds: 2);

    Timer(delayDuration, () {
      print("delete confirmation");
      deleteImageFile(imagePath);
    });
  } */

  Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

}
