import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({Key? key}) : super(key: key);

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: commonText(
              text: 'COMING SOON',
              context: context,
              textSize: displayWidth(context) * 0.07,
              textColor: Colors.black,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.start),
        ));
  }
}
