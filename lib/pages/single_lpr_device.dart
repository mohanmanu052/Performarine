import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/widgets/common_buttons.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';

import '../common_widgets/utils/common_size_helper.dart';
import '../common_widgets/utils/constants.dart';
import '../common_widgets/widgets/log_level.dart';

import '../common_widgets/utils/utils.dart';

class SingleLPRDevice extends StatefulWidget {
  final BluetoothDevice? device;
  final BuildContext? dialogContext;
  final Function(String)? onSelected;
  final Function(bool)? onBluetoothConnection;
  final StateSetter? setSetter;
  final Function(bool)? onSingleDeviceTapped;
  String? connectedDeviceId;
  BluetoothDevice? connectedBluetoothDevice;

  SingleLPRDevice(
      {Key? key,
        this.device,
        this.dialogContext,
        this.onSelected,
        this.onBluetoothConnection,
        this.setSetter,
        this.connectedDeviceId,
        this.connectedBluetoothDevice,
        this.onSingleDeviceTapped})
      : super(key: key);

  @override
  State<SingleLPRDevice> createState() => _SingleLPRDeviceState();
}

class _SingleLPRDeviceState extends State<SingleLPRDevice> {
  bool isConnect = false;
  DateTime? connectDeviceClickTime;
  String page = "single_lpr_device";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      onTap: () async {
        List<BluetoothDevice> connectedDevicesList =
        await FlutterBluePlus.instance.connectedDevices;
        Utils.customPrint("BONDED LIST $connectedDevicesList");

        if (connectedDevicesList.isNotEmpty) {
          showForgetDeviceDialog(context, forgetDeviceBtnClick: () async {
            Navigator.of(context).pop();
            EasyLoading.show(
                status: 'Disconnecting...',
                maskType: EasyLoadingMaskType.black);
            for (int i = 0; i < connectedDevicesList.length; i++) {
              await connectedDevicesList[i].disconnect();
            }
            EasyLoading.dismiss();
            EasyLoading.show(
                status: 'Searching for available devices...',
                maskType: EasyLoadingMaskType.black);
            Future.delayed(Duration(seconds: 2), () async {
              EasyLoading.dismiss();
              if (widget.connectedBluetoothDevice != null) {
                widget.connectedBluetoothDevice!.disconnect();
              }
              widget.setSetter!(() {
                isConnect = true;
                widget.connectedDeviceId = widget.device!.id.id;
                widget.onSingleDeviceTapped!(true);
              });
              await storage.write(
                  key: 'lprDeviceId', value: widget.device!.id.id);
              debugPrint("SINGLE SELECTED BLE ID ${widget.device!.id.id}");

              // widget.device!.connect().then((value) {}).catchError((s) {
              //   CustomLogger().logWithFile(Level.error, "ERROR $s-> $page");
              //   widget.device!.state.listen((event) {
              //     if (event == BluetoothDeviceState.connected) {
              //       CustomLogger()
              //           .logWithFile(Level.info, "CONNECTION EVENT ${event}-> $page");
              //       widget.device!.disconnect().then((value) {
              //         widget.device!.connect().then((value) {
              //           CustomLogger().logWithFile(Level.info,
              //               "CONNECTION NAME ${widget.device!.name}-> $page");
              //           widget.onSelected!(
              //               widget.device!.name == null || widget.device!.name.isEmpty
              //                   ? widget.device!.id.toString()
              //                   : widget.device!.name);
              //           widget.onBluetoothConnection!(true);
              //
              //           Navigator.pop(
              //             widget.dialogContext!,
              //           );
              //           widget.setSetter!(() {
              //             isConnect = false;
              //             widget.onSingleDeviceTapped!(false);
              //           });
              //           FlutterBluePlus.instance.stopScan();
              //         });
              //       });
              //     } else {
              //       CustomLogger()
              //           .logWithFile(Level.error, "ERROR CONNECTED 1212-> $page");
              //     }
              //   });
              // });
              // CustomLogger().logWithFile(Level.error, "ERROR CONNECTED-> $page");
              // CustomLogger()
              //     .logWithFile(Level.error, "ERROR CONNECTED FIRST-> $page");

              widget.device!.connect().then((value) {});

              widget.setSetter!(() {
                widget.onBluetoothConnection!(true);
                widget.onSelected!(
                    widget.device!.name == null || widget.device!.name.isEmpty
                        ? widget.device!.id.toString()
                        : widget.device!.name);
              });

              Future.delayed(Duration(seconds: 1), () {
                if (mounted) {
                  widget.setSetter!(() {
                    isConnect = false;
                    widget.onSingleDeviceTapped!(false);
                  });
                }
                Navigator.pop(widget.dialogContext!);
              });
            });
          }, onCancelClick: () {
            Navigator.of(context).pop();
          });
        } else {
          if (widget.connectedBluetoothDevice != null) {
            widget.connectedBluetoothDevice!.disconnect();
          }
          widget.setSetter!(() {
            isConnect = true;
            widget.connectedDeviceId = widget.device!.id.id;
            widget.onSingleDeviceTapped!(true);
          });
          await storage.write(key: 'lprDeviceId', value: widget.device!.id.id);
          debugPrint("SINGLE SELECTED BLE ID ${widget.device!.id.id}");

          // widget.device!.connect().then((value) {}).catchError((s) {
          //   CustomLogger().logWithFile(Level.error, "ERROR $s-> $page");
          //   widget.device!.state.listen((event) {
          //     if (event == BluetoothDeviceState.connected) {
          //       CustomLogger()
          //           .logWithFile(Level.info, "CONNECTION EVENT ${event}-> $page");
          //       widget.device!.disconnect().then((value) {
          //         widget.device!.connect().then((value) {
          //           CustomLogger().logWithFile(Level.info,
          //               "CONNECTION NAME ${widget.device!.name}-> $page");
          //           widget.onSelected!(
          //               widget.device!.name == null || widget.device!.name.isEmpty
          //                   ? widget.device!.id.toString()
          //                   : widget.device!.name);
          //           widget.onBluetoothConnection!(true);
          //
          //           Navigator.pop(
          //             widget.dialogContext!,
          //           );
          //           widget.setSetter!(() {
          //             isConnect = false;
          //             widget.onSingleDeviceTapped!(false);
          //           });
          //           FlutterBluePlus.instance.stopScan();
          //         });
          //       });
          //     } else {
          //       CustomLogger()
          //           .logWithFile(Level.error, "ERROR CONNECTED 1212-> $page");
          //     }
          //   });
          // });
          // CustomLogger().logWithFile(Level.error, "ERROR CONNECTED-> $page");
          // CustomLogger()
          //     .logWithFile(Level.error, "ERROR CONNECTED FIRST-> $page");

          widget.device!.connect().then((value) {});

          widget.setSetter!(() {
            widget.onBluetoothConnection!(true);
            widget.onSelected!(
                widget.device!.name == null || widget.device!.name.isEmpty
                    ? widget.device!.id.toString()
                    : widget.device!.name);
          });

          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              widget.setSetter!(() {
                isConnect = false;
                widget.onSingleDeviceTapped!(false);
              });
            }
            Navigator.pop(widget.dialogContext!);
          });
        }
      },
      title: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: commonText(
            context: context,
            text: widget.device!.name,
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.036,
            textAlign: TextAlign.start,
            fontFamily: inter),
      ),
      subtitle: commonText(
          context: context,
          text: widget.device!.id.toString(),
          fontWeight: FontWeight.w500,
          textColor: Colors.black54,
          textSize: displayWidth(context) * 0.032,
          textAlign: TextAlign.start,
          fontFamily: inter),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: widget.device!.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (c, snapshot) {
          // if (snapshot.data ==
          //     BluetoothDeviceState.connected) {
          return widget.connectedDeviceId != null
              ? widget.connectedDeviceId == widget.device!.id.id
              ? commonText(
              context: context,
              text: 'Connected',
              fontWeight: FontWeight.w400,
              textColor: Colors.green,
              textSize: displayWidth(context) * 0.032,
              textAlign: TextAlign.start,
              fontFamily: inter)
              : commonText(
              context: context,
              text: 'Tap to connect',
              fontWeight: FontWeight.w400,
              textColor: blueColor,
              textSize: displayWidth(context) * 0.032,
              textAlign: TextAlign.start,
              fontFamily: inter)
              : commonText(
              context: context,
              text: 'Tap to connect',
              fontWeight: FontWeight.w400,
              textColor: blueColor,
              textSize: displayWidth(context) * 0.032,
              textAlign: TextAlign.start,
              fontFamily: inter);
        },
      ),
    );
  }

  showForgetDeviceDialog(BuildContext context,
      {VoidCallback? forgetDeviceBtnClick, VoidCallback? onCancelClick}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                return Container(
                  height: displayHeight(context) * 0.42,
                  width: MediaQuery.of(context).size.width,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              //color: Color(0xfff2fffb),
                              child: Image.asset(
                                'assets/images/boat.gif',
                                height: displayHeight(ctx) * 0.1,
                                width: displayWidth(ctx),
                                fit: BoxFit.contain,
                              ),
                            )),
                        SizedBox(
                          height: displayHeight(context) * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: commonText(
                              context: context,
                              text:
                              'Would you like to disconnect from the currently connected Bluetooth device and connect to a new device?',
                              fontWeight: FontWeight.w500,
                              textColor: Colors.black87,
                              textSize: displayWidth(context) * 0.042,
                              textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          height: displayHeight(context) * 0.01,
                        ),
                        Column(
                          children: [
                            Center(
                              child: CommonButtons.getAcceptButton(
                                  'Forget Device',
                                  context,
                                  endTripBtnColor,
                                  forgetDeviceBtnClick,
                                  displayWidth(context) / 1.5,
                                  displayHeight(context) * 0.055,
                                  primaryColor,
                                  Colors.white,
                                  displayWidth(context) * 0.036,
                                  endTripBtnColor,
                                  '',
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: CommonButtons.getAcceptButton(
                                  'Cancel',
                                  context,
                                  Colors.transparent,
                                  onCancelClick,
                                  displayWidth(context) * 0.5,
                                  displayHeight(context) * 0.05,
                                  Colors.transparent,
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                      ? Colors.white
                                      : blueColor,
                                  displayHeight(context) * 0.018,
                                  Colors.transparent,
                                  '',
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
