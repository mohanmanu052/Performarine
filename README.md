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