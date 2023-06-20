import 'package:flutter/material.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsWebView extends StatefulWidget {
  String? url;
  TermsAndConditionsWebView({this.url});
  @override
  _TermsAndConditionsWebViewState createState() => _TermsAndConditionsWebViewState();
}

class _TermsAndConditionsWebViewState extends State<TermsAndConditionsWebView> {
  @override
  Widget build(BuildContext context) {
    print('Url is: ${widget.url}');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff2fffb),
        centerTitle: true,
        title: Text(
          "Terms and Conditions",
          style: TextStyle(color: Colors.black),
        ),
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
      body: WebView(
        initialUrl:
        'https://www.google.com', // Replace with your desired URL
      ),
    );
  }
}
