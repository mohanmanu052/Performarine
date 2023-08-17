import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/urls.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
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
    Utils.customPrint('Url is: ${widget.url}');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: backgroundColor,
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
      ),
      body: WebView(
        initialUrl:
        'https://${Urls.terms}', // Replace with your desired URL
      ),
    );
  }
}
