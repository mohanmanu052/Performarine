// import 'package:flutter/material.dart';
//
// class _DropdownItemState extends State<DropdownItem> {
//   String? selectedValue = null;
//   final _dropdownFormKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//         key: _dropdownFormKey,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             DropdownButtonFormField(
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   filled: true,
//                   fillColor: Colors.blueAccent,
//                 ),
//                 validator: (value) => value == null ? "Select a country" : null,
//                 dropdownColor: Colors.blueAccent,
//                 value: selectedValue,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedValue = newValue!;
//                   });
//                 },
//                 items: dropdownItems),
//             ElevatedButton(
//                 onPressed: () {
//                   if (_dropdownFormKey.currentState!.validate()) {
//                     //valid flow
//                   }
//                 },
//                 child: Text("Submit"))
//           ],
//         ));
//   }
// }

// import 'package:flutter/material.dart';
//
// class AppDropdownInput<T> extends StatelessWidget {
//   final String hintText;
//   final List<T> options;
//   final T? value;
//   final String Function(T)? getLabel;
//   // final VoidCallback? onChanged;
//    final Function onChanged;
//
//   AppDropdownInput({
//     this.hintText = 'Please select an Option',
//     this.options = const [],
//     this.getLabel,
//     this.value,
//     this.onChanged
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FormField<T>(
//       builder: (FormFieldState<T> state) {
//         return InputDecorator(
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(
//                 horizontal: 20.0, vertical: 15.0),
//             labelText: hintText,
//             border:
//             OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
//           ),
//           isEmpty: value == null || value == '',
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<T>(
//               value: value,
//               isDense: true,
//               onChanged: onChanged,
//               items: options.map((T value) {
//                 return DropdownMenuItem<T>(
//                   value: value,
//                   child: Text(getLabel!(value)),
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//ToDo : need to add belo code

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:performarine/models/vessel.dart';
//
// class CustomDropDown extends StatefulWidget {
//   const CustomDropDown({Key? key}) : super(key: key);
//
//   @override
//   State<CustomDropDown> createState() => _CustomDropDownState();
// }
//
// class _CustomDropDownState extends State<CustomDropDown> {
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<CreateVessel>(
//       //isDense: true,
//       hint: Text('Choose'),
//       value: _selectedValue,
//       icon: Icon(Icons.check_circle_outline),
//       iconSize: 24,
//       elevation: 16,
//       style: TextStyle(color: Colors.deepPurple),
//       underline: Container(
//         height: 2,
//         color: Colors.blue[300],
//       ),
//       onChanged: (Country newValue) {
//         setState(() {
//           _selectedValue = newValue;
//         });
//       },
//       items:
//       countryList.map<DropdownMenuItem<Country>>((Country value) {
//         return DropdownMenuItem<Country>(
//           value: value,
//           child: Text(value.name + ' ' + value.flag),
//         );
//       }).toList(),
//     );
//   }
// }
//
//
// class  extends StatefulWidget {
//   const ({Key? key}) : super(key: key);
//
//   @override
//   State<> createState() => _State();
// }
//
// class _State extends State<> {
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<Country>(
//     //isDense: true,
//     hint: Text('Choose'),
//     value: _selectedValue,
//     icon: Icon(Icons.check_circle_outline),
//     iconSize: 24,
//     elevation: 16,
//     style: TextStyle(color: Colors.deepPurple),
//     underline: Container(
//     height: 2,
//     color: Colors.blue[300],
//     ),
//     onChanged: (Country newValue) {
//     setState(() {
//     _selectedValue = newValue;
//     });
//     },
//     items:
//     countryList.map<DropdownMenuItem<Country>>((Country value) {
// return DropdownMenuItem<Country>(
// value: value,
// child: Text(value.name + ' ' + value.flag),
// );
// }).toList(),
// ),
//   }
// }


