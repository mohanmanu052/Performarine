import 'package:flutter/material.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common_widgets/utils/urls.dart';

class RouteMap extends StatefulWidget {
  String? tripID;
  RouteMap({this.tripID});
  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  @override
  Widget build(BuildContext context) {
    print('https://' + "${Urls.baseUrl}/goeMaps/646651f3bc96c02b13879ac9");
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xfff2fffb),
        centerTitle: true,
        title: Text(
          "Reports",
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
        actions: [
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
        ],
      ),
      body: WebView(
        initialUrl:
            'https://${Urls.baseUrl}/goeMaps/646651f3bc96c02b13879ac9', // Replace with your desired URL
      ),
    );
  }
}
