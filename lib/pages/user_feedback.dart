import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';


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
                        print("Image is: ${image.toString()}");
                        captureAndSaveScreenshot();
                        //handleScreenshotAndAPI();
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
      print("delete confirmation");
      deleteImageFile(imagePath);
    });
  }

  Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  Future<String> captureAndSaveScreenshot() async {
    final Uint8List? imageBytes = await controller.capture();

    final Directory appDir = await getApplicationDocumentsDirectory();

    final String fileName = DateTime.now().toIso8601String() + '.png';
    imageFile = File('${appDir.path}/$fileName');
    print("file path is: ${imageFile!.path}");

    // Write the image bytes to the file
    await imageFile!.writeAsBytes(imageBytes!);

    deleteImageAfterDelay(imageFile!.path);

    return imageFile!.path;
  }

  // Future<void> sendImageToAPI(String imagePath) async {
  //   // Once you receive a successful response, you can delete the image from the directory
  //   final File imageFile = File(imagePath);
  //   await imageFile.delete();
  // }

  void handleScreenshotAndAPI() async {
    // String imagePath = await captureAndSaveScreenshot();

    bool apiResponse = true;

    if (apiResponse) {
      deleteImageAfterDelay(imageFile!.path);
    }
    //else {
    // If the API response is not successful, you can delete the image from the directory
    //final File imageFile = File(imagePath);
    // await imageFile.delete();
    // }
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
