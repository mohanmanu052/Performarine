import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  String? url;
  bool? isPaccore;
  CustomWebView({this.url, this.isPaccore = false});
  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return widget.isPaccore!
    ? Scaffold(
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

          isLoading ? Center( child: CircularProgressIndicator(),)
              : Container()
        ],
      ),
    )
    : Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff2fffb),
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
        /*  actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    ModalRoute.withName(""));
              },
              icon: Image.asset('assets/images/home.png'),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ], */
      ),
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

          isLoading ? Center( child: CircularProgressIndicator(),)
              : Container()
        ],
      ),
    );
  }
}
