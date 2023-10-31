import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/start_trip/start_trip_recording_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class StartTripLprPermission  {
  
  void locationPermissions(bool isTripRecordingStarted,GlobalKey<StartTripRecordingScreenState> satrtTrip_sate, GlobalKey<ScaffoldState> scaffoldKey,BuildContext context)async{
      
        if (Platform.isAndroid) {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
        FlutterBluePlus.instance.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name.toLowerCase().contains("lpr")) {
              Utils.customPrint('FOUND DEVICE AGAIN');

              r.device.connect().catchError((e) {
                r.device.state.listen((event) {
                  if (event == BluetoothDeviceState.connected) {
                    r.device.disconnect().then((value) {
                      r.device.connect().catchError((e) {
                        if (satrtTrip_sate.currentState!.mounted) {
                       //satrtTrip_sate.currentState!.setState(() {
                         
                        {
                        satrtTrip_sate.currentState!.    isBluetoothPermitted = true;
                        satrtTrip_sate.currentState!.     progress = 1.0;
                          satrtTrip_sate.currentState!.   lprSensorProgress = 1.0;
                          satrtTrip_sate.currentState!.   isStartButton = true;
                          }
                          //}
                       
                         // );
                        }
                      });
                    });
                  }
                });
              });

            satrtTrip_sate.currentState!.  bluetoothName = r.device.name;
          // satrtTrip_sate.currentState!.   setState(() {
             satrtTrip_sate.currentState!.   isBluetoothPermitted = true;
             satrtTrip_sate.currentState!.   progress = 1.0;
             satrtTrip_sate.currentState!.   lprSensorProgress = 1.0;
             satrtTrip_sate.currentState!.   isStartButton = true;
            //  });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device.disconnect().then(
                      (value) => Utils.customPrint("is device disconnected:"));
            }
          }
        });

     //satrtTrip_sate.currentState!.   setState(() {
          satrtTrip_sate.currentState!.isLocationPermitted = isLocationPermitted;
       // });

        if (isTripRecordingStarted) {
          bool isLocationPermitted = await Permission.location.isGranted;

          if (isLocationPermitted) {
            if (Platform.isAndroid) {
              final androidInfo = await DeviceInfoPlugin().androidInfo;

              if (androidInfo.version.sdkInt < 29) {
                var isStoragePermitted = await Permission.storage.status;
                if (isStoragePermitted.isGranted) {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.    startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.    startWritingDataToDB(context);
                    }
                  }
                } else {
                  await Utils.getStoragePermission(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  var isStoragePermitted = await Permission.storage.status;

                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  }
                }
              }
            } else {
              bool isNotificationPermitted =
              await Permission.notification.isGranted;

              if (isNotificationPermitted) {
                satrtTrip_sate.currentState!.  startWritingDataToDB(context);
              } else {
                await Utils.getNotificationPermission(context);
                bool isNotificationPermitted =
                await Permission.notification.isGranted;
                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                }
              }
            }
          } else {
            await Utils.getLocationPermission(context, scaffoldKey);
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              // service.startService();

              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(
                      context,
                    );
                  }
                }
              }
            }
          }
        }

      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          FlutterBluePlus.instance.scanResults.listen((results) async {
            for (ScanResult r in results) {
              if (r.device.name.toLowerCase().contains("lpr")) {
                r.device.connect().catchError((e) {
                  r.device.state.listen((event) {
                    if (event == BluetoothDeviceState.connected) {
                      r.device.disconnect().then((value) {
                        r.device.connect().catchError((e) {
                          if (satrtTrip_sate.currentState!.mounted) {
                       // satrtTrip_sate.currentState!.    setState(() {
                          satrtTrip_sate.currentState!.     isBluetoothPermitted = true;
                          satrtTrip_sate.currentState!.     progress = 1.0;
                           satrtTrip_sate.currentState!.    lprSensorProgress = 1.0;
                            satrtTrip_sate.currentState!.   isStartButton = true;
                          //  });
                          }
                        });
                      });
                    }
                  });
                });

              satrtTrip_sate.currentState!.  bluetoothName = r.device.name;
              // satrtTrip_sate.currentState!. setState(() {
              satrtTrip_sate.currentState!.     isBluetoothPermitted = true;
                 satrtTrip_sate.currentState!.  progress = 1.0;
                satrtTrip_sate.currentState!.   lprSensorProgress = 1.0;
                 satrtTrip_sate.currentState!.  isStartButton = true;
               // });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device.disconnect().then(
                        (value) => Utils.customPrint("is device disconnected: "));
              }
            }
          });

      // satrtTrip_sate.currentState!.   setState(() {
            satrtTrip_sate.currentState!. isLocationPermitted = isLocationPermitted;
        //  });

          if (isTripRecordingStarted) {
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  }
                }
              }
            } else {
              await Utils.getLocationPermission(context, scaffoldKey);
              bool isLocationPermitted = await Permission.location.isGranted;

              if (isLocationPermitted) {
                // service.startService();

                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  if (androidInfo.version.sdkInt < 29) {
                    var isStoragePermitted = await Permission.storage.status;
                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        }
                      }
                    } else {
                      await Utils.getStoragePermission(context);
                      final androidInfo = await DeviceInfoPlugin().androidInfo;

                      var isStoragePermitted = await Permission.storage.status;

                      if (isStoragePermitted.isGranted) {
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;

                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        } else {
                          await Utils.getNotificationPermission(context);
                          bool isNotificationPermitted =
                          await Permission.notification.isGranted;
                          if (isNotificationPermitted) {
                            satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                          }
                        }
                      }
                    }
                  } else {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(
                        context,
                      );
                    }
                  }
                }
              }
            }
          }

        }
      }
    } else {
      bool isLocationPermitted = await Permission.locationAlways.isGranted;
      if (isLocationPermitted) {
        FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
        FlutterBluePlus.instance.scanResults.listen((results) async {
          for (ScanResult r in results) {
            if (r.device.name.toLowerCase().contains("lpr")) {
              Utils.customPrint('FOUND DEVICE AGAIN');

              r.device.connect().catchError((e) {
                r.device.state.listen((event) {
                  if (event == BluetoothDeviceState.connected) {
                    r.device.disconnect().then((value) {
                      r.device.connect().catchError((e) {
                        if (satrtTrip_sate.currentState!.mounted) {
                        // satrtTrip_sate.currentState!. setState(() {
                          satrtTrip_sate.currentState!.  isBluetoothPermitted = true;
                          satrtTrip_sate.currentState!.  progress = 1.0;
                           satrtTrip_sate.currentState!. lprSensorProgress = 1.0;
                           satrtTrip_sate.currentState!. isStartButton = true;
                         // });
                        }
                      });
                    });
                  }
                });
              });

            satrtTrip_sate.currentState!.  bluetoothName = r.device.name;
            // satrtTrip_sate.currentState!. setState(() {
              satrtTrip_sate.currentState!.  isBluetoothPermitted = true;
              satrtTrip_sate.currentState!.  progress = 1.0;
             satrtTrip_sate.currentState!.   lprSensorProgress = 1.0;
             satrtTrip_sate.currentState!.   isStartButton = true;
             // });
              FlutterBluePlus.instance.stopScan();
              break;
            } else {
              r.device.disconnect().then(
                      (value) => Utils.customPrint("is device disconnected: "));
            }
          }
        });

     // satrtTrip_sate.currentState!.  setState(() {
        satrtTrip_sate.currentState!.  isLocationPermitted = isLocationPermitted;
       // });

        if (isTripRecordingStarted) {
          bool isLocationPermitted = await Permission.location.isGranted;

          if (isLocationPermitted) {
            if (Platform.isAndroid) {
              final androidInfo = await DeviceInfoPlugin().androidInfo;

              if (androidInfo.version.sdkInt < 29) {
                var isStoragePermitted = await Permission.storage.status;
                if (isStoragePermitted.isGranted) {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    }
                  }
                } else {
                  await Utils.getStoragePermission(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  var isStoragePermitted = await Permission.storage.status;

                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  }
                }
              }
            } else {
              bool isNotificationPermitted =
              await Permission.notification.isGranted;

              if (isNotificationPermitted) {
                satrtTrip_sate.currentState!.  startWritingDataToDB(context);
              } else {
                await Utils.getNotificationPermission(context);
                bool isNotificationPermitted =
                await Permission.notification.isGranted;
                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                }
              }
            }
          } else {
            await Utils.getLocationPermission(context, scaffoldKey);
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              // service.startService();

              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(
                      context,
                    );
                  }
                }
              }
            }
          }
        }

      } else {
        await Utils.getLocationPermissions(context, scaffoldKey);
        bool isLocationPermitted = await Permission.locationAlways.isGranted;
        if (isLocationPermitted) {
          FlutterBluePlus.instance.startScan(timeout: Duration(seconds: 4));
          FlutterBluePlus.instance.scanResults.listen((results) async {
            for (ScanResult r in results) {
              if (r.device.name.toLowerCase().contains("lpr")) {
                r.device.connect().catchError((e) {
                  r.device.state.listen((event) {
                    if (event == BluetoothDeviceState.connected) {
                      r.device.disconnect().then((value) {
                        r.device.connect().catchError((e) {
                          if (satrtTrip_sate.currentState!.mounted) {
                         // satrtTrip_sate.currentState!.  setState(() {
                           satrtTrip_sate.currentState!.   isBluetoothPermitted = true;
                           satrtTrip_sate.currentState!.   progress = 1.0;
                             satrtTrip_sate.currentState!. lprSensorProgress = 1.0;
                             satrtTrip_sate.currentState!. isStartButton = true;
                            //});
                          }
                        });
                      });
                    }
                  });
                });

               satrtTrip_sate.currentState!. bluetoothName = r.device.name;
              //satrtTrip_sate.currentState!.  setState(() {
               satrtTrip_sate.currentState!.   isBluetoothPermitted = true;
                satrtTrip_sate.currentState!.  progress = 1.0;
                 satrtTrip_sate.currentState!. lprSensorProgress = 1.0;
                 satrtTrip_sate.currentState!. isStartButton = true;
               // });
                FlutterBluePlus.instance.stopScan();
                break;
              } else {
                r.device.disconnect().then(
                        (value) => Utils.customPrint("is device disconnected: "));
              }
            }
          });

        //satrtTrip_sate.currentState!.   setState(() {
            satrtTrip_sate.currentState!.isLocationPermitted = isLocationPermitted;
         // });

          if (isTripRecordingStarted) {
            bool isLocationPermitted = await Permission.location.isGranted;

            if (isLocationPermitted) {
              if (Platform.isAndroid) {
                final androidInfo = await DeviceInfoPlugin().androidInfo;

                if (androidInfo.version.sdkInt < 29) {
                  var isStoragePermitted = await Permission.storage.status;
                  if (isStoragePermitted.isGranted) {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  } else {
                    await Utils.getStoragePermission(context);
                    final androidInfo = await DeviceInfoPlugin().androidInfo;

                    var isStoragePermitted = await Permission.storage.status;

                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        }
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    }
                  }
                }
              } else {
                bool isNotificationPermitted =
                await Permission.notification.isGranted;

                if (isNotificationPermitted) {
                  satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                } else {
                  await Utils.getNotificationPermission(context);
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;
                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  }
                }
              }
            } else {
              await Utils.getLocationPermission(context, scaffoldKey);
              bool isLocationPermitted = await Permission.location.isGranted;

              if (isLocationPermitted) {
                // service.startService();

                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;

                  if (androidInfo.version.sdkInt < 29) {
                    var isStoragePermitted = await Permission.storage.status;
                    if (isStoragePermitted.isGranted) {
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;

                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      } else {
                        await Utils.getNotificationPermission(context);
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;
                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        }
                      }
                    } else {
                      await Utils.getStoragePermission(context);
                      final androidInfo = await DeviceInfoPlugin().androidInfo;

                      var isStoragePermitted = await Permission.storage.status;

                      if (isStoragePermitted.isGranted) {
                        bool isNotificationPermitted =
                        await Permission.notification.isGranted;

                        if (isNotificationPermitted) {
                          satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                        } else {
                          await Utils.getNotificationPermission(context);
                          bool isNotificationPermitted =
                          await Permission.notification.isGranted;
                          if (isNotificationPermitted) {
                            satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                          }
                        }
                      }
                    }
                  } else {
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;

                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                    } else {
                      await Utils.getNotificationPermission(context);
                      bool isNotificationPermitted =
                      await Permission.notification.isGranted;
                      if (isNotificationPermitted) {
                        satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                      }
                    }
                  }
                } else {
                  bool isNotificationPermitted =
                  await Permission.notification.isGranted;

                  if (isNotificationPermitted) {
                    satrtTrip_sate.currentState!.  startWritingDataToDB(context);
                  } else {
                    await Utils.getNotificationPermission(context);
                    bool isNotificationPermitted =
                    await Permission.notification.isGranted;
                    if (isNotificationPermitted) {
                      satrtTrip_sate.currentState!.  startWritingDataToDB(
                        context,
                      );
                    }
                  }
                }
              }
            }
          }

        }
      }
    }

    }
    

  
}