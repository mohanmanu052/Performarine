import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
// import 'package:goe/utils/utils/common_size_helper.dart';
// import 'package:goe/utils/utils/constants.dart';
// import 'package:goe/utils/utils.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Widget commonText(
    {String? text,
    BuildContext? context,
    double? textSize,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign? textAlign = TextAlign.center,
    TextDecoration textDecoration = TextDecoration.none}) {
  return Text(
    text ?? '',
    textAlign: textAlign!,
    style: TextStyle(
        fontSize: textSize,
        color: textColor,
        fontFamily: poppins,
        fontWeight: fontWeight,
        decoration: textDecoration),
    overflow: TextOverflow.clip,
    softWrap: true,
  );
}

Widget? selectImage(
  context,
  Color buttonPrimaryColor,
  Function(List<File?>) onSelectImage,
) {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return Wrap(
              children: <Widget>[
                const ListTile(
                  title: Text(
                    'Choose Files',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                    dense: true,
                    horizontalTitleGap: 0.5,
                    leading: Icon(
                      Icons.photo_album,
                      color: buttonPrimaryColor,
                    ),
                    title: const Text(
                      'Gallery',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      List<File?>? list = [];

                      // list = await Utils.pickFileFromGallery();
                      list = await Utils.pickImages();

                      onSelectImage(list);
                    }),
                ListTile(
                    dense: true,
                    horizontalTitleGap: 0.5,
                    leading: Icon(
                      Icons.camera_enhance,
                      color: buttonPrimaryColor,
                    ),
                    title: const Text(
                      'Camera',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    onTap: () async {
                      /* Navigator.pop(context);
                      List<File> list = await Utils.pickCameraImages();
                      onSelectImage(list);*/

                      bool isCameraPermissionGranted =
                          await Permission.camera.isGranted;

                      debugPrint(' CAM PERMISSION $isCameraPermissionGranted');

                      if (!isCameraPermissionGranted) {
                        await Utils.getStoragePermission(
                            context, Permission.camera);
                        bool isCameraPermissionGranted =
                            await Permission.camera.isGranted;

                        if (isCameraPermissionGranted) {
                          Navigator.pop(context);
                          List<File> list = await Utils.pickCameraImages();
                          onSelectImage(list);
                        }
                      } else {
                        Navigator.pop(context);
                        List<File> list = await Utils.pickCameraImages();
                        onSelectImage(list);
                      }
                    }),
                /*ListTile(
                    leading: Icon(Icons.file_copy_outlined, color: buttonPrimaryColor,),
                    title: Text('File'),
                    onTap: () async {
                      Navigator.pop(context);
                      List<File> list = await Utils.pickFilePath();
                      onSelectImage(list);
                    }),*/
              ],
            );
          },
        );
      });
}

Widget richText(
    {String? modelName,
    String? builderName,
    BuildContext? context,
    Color? color}) {
  return Row(
    children: [
      Expanded(
        child: RichText(
          text: TextSpan(
              text: modelName,
              style: TextStyle(
                color: Theme.of(context!).brightness == Brightness.dark
                    ? Colors.white
                    : color,
                fontSize: displayWidth(context) * 0.04,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' | ',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: displayWidth(context) * 0.04,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: builderName,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : color,
                      fontSize: displayWidth(context) * 0.04,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // navigate to desired screen
                      })
              ]),
        ),
      ),
    ],
  );
}

Widget dashboardRichText(
    {String? modelName,
    String? builderName,
    BuildContext? context,
    Color? color}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Flexible(
        child: Text(
          modelName!,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: displayWidth(context!) * 0.034,
            color: Colors.white.withOpacity(0.8),
            fontFamily: poppins,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
      ),
      SizedBox(
        width: displayWidth(context) * 0.02,
      ),
      Container(
        height: displayHeight(context) * 0.02,
        color: Colors.white,
        width: displayWidth(context) * 0.0045,
      ),
      SizedBox(
        width: displayWidth(context) * 0.02,
      ),
      Flexible(
        child: Text(
          builderName!,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: displayWidth(context) * 0.034,
            color: Colors.white.withOpacity(0.8),
            fontFamily: poppins,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
      ),
    ],
  );
}
