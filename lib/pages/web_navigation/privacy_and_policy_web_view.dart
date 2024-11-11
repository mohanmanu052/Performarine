import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  String? url;
  bool? isPaccore;
  int? bottomNavIndex;
  CustomWebView({this.url, this.isPaccore = false,this.bottomNavIndex});
  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {

  bool isLoading = true;



@override
  void initState() {
        SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    // TODO: implement initState
    super.initState();
  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(widget.bottomNavIndex==1){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);

    }

  }

  @override
  Widget build(BuildContext context) {
    return widget.isPaccore!
    ? Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          WebView(
            initialUrl:
            widget.url, // Replace with your desired URL
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),

          isLoading ? Center( child: CircularProgressIndicator(
            color: blueColor,
          ),)
              : Container()
        ],
      ),
    )
    : Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: Stack(
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl:
            widget.url, // Replace with your desired URL
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading ? Center( child: CircularProgressIndicator(
            color: blueColor,
          ),)
              : Container()
        ],
      ),
    );
  }
}
