import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../common_widgets/utils/utils.dart';


class UserFeedback extends StatefulWidget {
  const UserFeedback({Key? key}) : super(key: key);

  @override
  State<UserFeedback> createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {

  final controller = ScreenshotController();

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              buildImage(),
              Column(
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                      ),
                      onPressed: (){
                        final image = controller.capture();
                        Utils.customPrint("Image is: ${image.toString()}");
                        captureAndSaveScreenshot();
                      },
                      child: Text(
                        "Capture Image",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      )),

                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      onPressed: (){
                        handleScreenshotAndAPI();
                      },
                      child: Text(
                        "Delete Image",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void deleteImageAfterDelay(String imagePath) {
    const delayDuration = Duration(seconds: 2);

    Timer(delayDuration, () {
      Utils.customPrint("delete confirmation");
      deleteImageFile(imagePath);
    });
  }

  Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      Utils.customPrint('Image deleted successfully');
    } catch (e) {
      Utils.customPrint('Failed to delete image: $e');
    }
  }

  Future<String> captureAndSaveScreenshot() async {
    final Uint8List? imageBytes = await controller.capture();

    final Directory appDir = await getApplicationDocumentsDirectory();

    final String fileName = DateTime.now().toIso8601String() + '.png';
    imageFile = File('${appDir.path}/$fileName');
    Utils.customPrint("file path is: ${imageFile!.path}");

    // Write the image bytes to the file
    await imageFile!.writeAsBytes(imageBytes!);

    deleteImageAfterDelay(imageFile!.path);

    return imageFile!.path;
  }

  void handleScreenshotAndAPI() async {
    bool apiResponse = true;

    if (apiResponse) {
      deleteImageAfterDelay(imageFile!.path);
    }
  }

  Widget buildImage(){
    return Padding(
      padding:  EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          "https://scanbot.io/wp-content/uploads/2022/03/flutter_tutorial_hero-2048x819.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
