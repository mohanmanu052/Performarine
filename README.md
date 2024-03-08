# Performarine

## Project Setup:
- setup the flutter and IDE: https://docs.flutter.dev/get-started/editor
- post configuring the application use the below commands
  - flutter doctor (to check the set up status and issues)
  - flutter --version(check the version)
  - flutter clean (remove the builds and cache from the project)
  - flutter pub get (install the required packages)
  - flutter run --release/debug/profile (run the code in emulator/ physical device)
  - flutter build apk --release/debug/profile (build the android executables- APK)
  - flutter build ios --release/debug/profile (build the IOS executables- APK)
  - pod cache clean --all (remove the pod cache)
  - pod deintegrate (remove the pod specification from project)
  - pod install (install the ios dependencies)
  - pod updates (update the ios dependencies)
  - open Runner.xcworkspace(open the project in xcode)
  - flutter create . (to install the latest flutter sdk changes)

## Sensor data format
### Accelerometer (ACC)
- ACC,-0.13636240374208206,0.05717136928190788,9.824958347138905,2022-12-16T17:38:16.503109Z
  - X Accel
  - Y Accel
  - Z Accel
  - UTC ISO 8601 Timestamp
### User Accelerometer (UACC)
- UACC,-0.13636240374208206,0.05717136928190788,9.824958347138905,2022-12-16T17:38:16.503109Z
  - X Accel
  - Y Accel
  - Z Accel
  - UTC ISO 8601 Timestamp
  Gyroscope (GYRO)
  GYRO,-0.0009162978967651725,-0.003512475173920393,0.004428773187100887,2022-12-16T17:38:14.820518Z
  X Rotation
  Y Rotation
  Z Rotation
  UTC ISO 8601 Timestamp
  Magnetometer (MAG)
  MAG,-76.19021911621094,-59.91785850524902,-76.19021911621094,2022-12-16T17:38:14.932642Z
  Magnetic Field’s X
  Magnetic Field’s Y
  Magnetic Field’s Z
  UTC ISO 8601 Timestamp
  World Positioning (GPS)
  GPS,44.6276332,-63.5902818,3.9159998893737793,
  -17.196053035159977,298.0196838378906,3.1892454624176025,0.2001989781856537,2022-12-16T17:38:16.621Z
  Latitude
  Longitude
  GPS Accuracy
  Altitude
  Heading
  Speed
  Speed Accuracy
  Timestam
## Read Documentation
  ### By using the below commands we can view the documentation in the local server with 8080 port and open the local host http://localhost:8080/
  - dart pub global activate dhttpd 
  - dhttpd --path documentation

## Preview
<img src="screenshots/ss.png" />





## Sprint10 Notes
  - User kills the application and reopens - need to show a popup containing "Last time you used performarine. there is a trip in progress. do you want to end the trip or continue? ("End trip", "continue trip")
  - Firebase crash analytics Implemented
  - User feedback is added in all screens. Uploading image files.


  # Flutter Version Using
  3.16.3
   Engine • revision 54a7145303
   Tools • Dart 3.2.3 
    DevTools 2.28.4   



    #LPR Docs 


    LPR CallBack Handler 

Overview 

The LPRCallbackHandler class serves as a central handler for managing callbacks and streaming data related to a Bluetooth Low Energy (BLE) device with specific UUIDs for services and characteristics. This handler allows you to establish and manage connections, receive data, and handle disconnections for a BLE device. 


Class Structure 

Singleton Design Pattern  

The class follows the Singleton design pattern, ensuring that only one instance of LPRCallbackHandler can exist in the application. This is achieved through a private constructor and a static instance _instance. 

LPRCallbackHandler._internal();  

factory LPRCallbackHandler() => _instance; 

Public Properties and Methods 

Properties 

callBackLprTanspernetserviecId: A callback function for LPR Transparent Service ID and UART TX. 

callBackLprTanspernetserviecIdStatus: A callback function for the status of the LPR Transparent Service ID. 

callBackLprUartTxStatus: A callback function for the status of the LPR UART TX. 

callBackconnectedDeviceName: A callback function for the connected Bluetooth device's name. 

callBackLprStreamingData: A callback function for streaming LPR data. 

onDeviceDisconnectCallback: A callback function triggered upon device disconnection. 

lprService: Represents the Bluetooth service for LPR communication. 

lprDataStream: A stream of lists containing LPR data. 

Methods 

listenToDeviceConnectionState: Establishes and manages the connection to a BLE device. It listens for changes in the device's connection state, discovers services, and sets up data characteristics for streaming LPR data. 

void listenToDeviceConnectionState({/* ... */}) async; 
 

dispose: 

 Closes the stream controller to avoid memory leaks when the LPRCallbackHandler instance is no longer needed. 

void dispose(); 

 

getLPRConfigartion: Retrieves LPR configuration values stored securely. 
 

Future<Map<String, dynamic>> getLPRConfigartion() async; 

 

Usage Example 

// Initialize the LPRCallbackHandler LPRCallbackHandler lprHandler = LPRCallbackHandler().instance; // Set up callbacks l 

prHandler.callBackLprStreamingData = (data) {  

// Handle LPR data streaming };  

// Connect to a BLE device 

 lprHandler.listenToDeviceConnectionState( callBackLprStreamingData:lprHandler.callBackLprStreamingData, connectedDevice: /* BluetoothDevice instance */, );  

// Dispose of the handler when no longer needed  

lprHandler.dispose(); 


Important Notes 

The listenToDeviceConnectionState method assumes specific UUIDs for LPR services and characteristics. Ensure these UUIDs match your device's specifications. 

Handle the callbacks appropriately based on your application's requirements. 
