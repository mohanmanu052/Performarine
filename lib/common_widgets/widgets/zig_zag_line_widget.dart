import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';

class ZigZagLineWidget extends StatelessWidget {
  const ZigZagLineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/zig_zag_line.png',
          height: displayHeight(context) * 0.01,
          color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white : Colors.black,
        ),

        Image.asset('assets/images/zig_zag_line.png',
          height: displayHeight(context) * 0.01,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white : Colors.black,
        ),
      ],
    );
  }
}
