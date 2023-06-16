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
## Read Documentation
  ### By using the below commands we can view the documentation in the local server with 8080 port and open the local host http://localhost:8080/
  - dart pub global activate dhttpd 
  - dhttpd --path doc/api

## Preview
<img src="screenshots/ss.png" />
