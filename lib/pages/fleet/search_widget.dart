import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';

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

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    // _filteredSuggestions.addAll(_suggestions);
  }

  void _filterSuggestions(String query) {
    _filteredSuggestions = _suggestions
        .where((suggestion) =>
        suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
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
                borderRadius: BorderRadius.circular(18),
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
          focusNode: focusNode,
          onFieldSubmitted: (value) {
            onFieldSubmitted();
          },
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _suggestions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: widget.onSelect,
    );
  }
}

