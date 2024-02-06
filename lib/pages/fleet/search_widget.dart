import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';

class SearchWidget extends StatefulWidget {
  final Function(String)? onSelect;
  final Function(int, String) onRemoved;
  final int index;

  const SearchWidget(
      {super.key,
        required this.onSelect,
        required this.index,
        required this.onRemoved});
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  List<String> _suggestions = [
    'suneetha90@gmail.com',
    'rupali.c@paccore.com',
    'suneetha360@gmail.com',
  ];

  List<String> filteredOptions = [];

  int lengthOfList = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Autocomplete<String>(
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade50),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: textEditingController.text.isNotEmpty
                            ? Radius.circular(0)
                            : Radius.circular(18),
                        bottomRight: textEditingController.text.isNotEmpty
                            ? Radius.circular(0)
                            : Radius.circular(18)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      widget.onRemoved(
                          widget.index, textEditingController.text.trim());
                    },
                  )),
              onChanged: (value) {
                setState(() {});
                debugPrint("ON TYPE $lengthOfList");
              },
              focusNode: focusNode,
              onFieldSubmitted: (value) {
                onFieldSubmitted();
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18)),
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18)),
                  ),
                  // height: 52.0 * options.length,
                  width: constraints.biggest.width, // <-- Right here !
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(option),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        color: Colors.black45,
                        width: constraints.biggest.width,
                        height: 1,
                      );
                    },
                  ),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            filteredOptions = _suggestions.where((String option) {
              return option.contains(textEditingValue.text.toLowerCase());
            }).toList();
            return filteredOptions;
          },
          onSelected: widget.onSelect,
        ),
      );
    });
  }
}
