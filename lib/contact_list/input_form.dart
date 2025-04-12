// import 'dart:convert';

// import 'package:collection/collection.dart';
// import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
// import 'package:dropdown_textfield/dropdown_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:material_symbols_icons/symbols.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:html/parser.dart' as parser;

// class ContactListInput extends StatefulWidget {
//   final Database db;

//   const ContactListInput({
//     super.key,
//     required this.db,
//   });

//   @override
//   State<ContactListInput> createState() => _ContactListInputState();
// }

// class _ContactListInputState extends State<ContactListInput> {
//   final _searchController = TextEditingController();

//   final _descriptionController = TextEditingController();

//   final _contactNameController = TextEditingController();

//   final _contactNumberController = TextEditingController();

//   final _dropdownController = SingleValueDropDownController();

//   List<int> _ids = [];
//   List<String> _names = [];
//   List<String> _imageLinks = [];

//   int? _seletedIndex;
//   bool _enabled = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Contact"),
//       ),
//       backgroundColor: Colors.grey.shade200,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.only(
//             top: 25,
//             left: 10,
//             right: 10,
//             bottom: 25,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Material(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Text(
//                         "CONTACTS",
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.montserrat(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 2),
//                       ),
//                       const SizedBox(height: 20),
//                       () {
//                         if (_seletedIndex != null) {
//                           return Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 24.0),
//                             child: Material(
//                               elevation: 10,
//                               borderRadius: BorderRadius.circular(200),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: ClipOval(
//                                   child: Image.network(
//                                     _imageLinks[_seletedIndex!],
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }

//                         return Image.asset(
//                           "assets/messenger_logo.png",
//                           height: 200,
//                         );
//                       }(),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Material(
//                 elevation: 4,
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _searchController,
//                               decoration: InputDecoration(
//                                 contentPadding: EdgeInsets.zero,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 prefixIcon: const Icon(Icons.search_outlined),
//                                 labelText: 'Search Name (Optional)',
//                                 fillColor: Colors.grey.shade200,
//                                 filled: true,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           TextButton(
//                             onPressed: () async {
//                               setState(() {
//                                 _seletedIndex = null;
//                                 _enabled = false;
//                                 _dropdownController.setDropDown(null);
//                               });

//                               if (_searchController.text.isEmpty) {
//                                 return;
//                               }

//                               final loader = HeadlessInAppWebView(
//                                 initialOptions: InAppWebViewGroupOptions(
//                                   crossPlatform: InAppWebViewOptions(
//                                     userAgent:
//                                         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
//                                   ),
//                                 ),
//                                 initialUrlRequest: URLRequest(
//                                     url: WebUri.parse(
//                                         "https://web.facebook.com/public/${Uri.encodeComponent(_searchController.text)}?_rdc=1&_rdr")),
//                               );

//                               await loader.setSize(const Size(2540, 1440));

//                               loader.onLoadStop = (controller, url) async {
//                                 final result =
//                                     await controller.evaluateJavascript(
//                                         source: "document.body.innerHTML");

//                                 final document = parser.parse(result);
//                                 final ids = document.body!
//                                     .querySelectorAll("._3u1._gli")
//                                     .map((id) => jsonDecode(
//                                             id.attributes["data-bt"]!)["id"]
//                                         as int);
//                                 final names = document.body!
//                                     .querySelectorAll("a._32mo")
//                                     .map((name) => name.attributes["title"])
//                                     .whereNotNull();

//                                 final imageLinks = document.body!
//                                     .querySelectorAll("img._1glk._6phc.img")
//                                     .map((link) => link.attributes["src"])
//                                     .whereNotNull();

//                                 if (ids.isNotEmpty && names.isNotEmpty) {
//                                   setState(() {
//                                     _enabled = true;
//                                     _ids = ids.toList();
//                                     _names = names.toList();
//                                     _imageLinks = imageLinks.toList();
//                                   });
//                                 }
//                               };

//                               await loader.run();
//                             },
//                             style: ButtonStyle(
//                               backgroundColor:
//                                   WidgetStateProperty.all(fgColor),
//                               overlayColor: WidgetStateProperty.all(
//                                   Colors.white.withOpacity(0.3)),
//                             ),
//                             child: Text(
//                               "Search",
//                               style:
//                                   GoogleFonts.montserrat(color: Colors.white),
//                             ),
//                           )
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       DropDownTextField(
//                         controller: _dropdownController,
//                         onChanged: (value) async {
//                           if (value.runtimeType.toString() ==
//                               "DropDownValueModel") {
//                             _seletedIndex = _ids.indexOf(value.value);

//                             await precacheImage(
//                               NetworkImage(_imageLinks[_seletedIndex!]),
//                               context,
//                             );
//                           }

//                           setState(() {});
//                         },
//                         textFieldDecoration: InputDecoration(
//                           contentPadding: EdgeInsets.zero,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: () {
//                             return Image.asset(
//                               "assets/messenger_logo.png",
//                               width: 32,
//                             );
//                           }(),
//                           labelText: 'Search Results',
//                           fillColor: Colors.grey.shade200,
//                           filled: true,
//                         ),
//                         dropDownList: _names
//                             .mapIndexed(
//                               (index, element) => DropDownValueModel(
//                                 name: element,
//                                 value: _ids[index],
//                               ),
//                             )
//                             .toList(),
//                         isEnabled: _enabled,
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: _contactNameController,
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.zero,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.person_outline),
//                           labelText: 'Contact Name',
//                           fillColor: Colors.grey.shade200,
//                           filled: true,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: _contactNumberController,
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.zero,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           prefixIcon: const Icon(Icons.phone_outlined),
//                           labelText: 'Contact Number (Optional)',
//                           fillColor: Colors.grey.shade200,
//                           filled: true,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Stack(
//                         children: [
//                           TextField(
//                             controller: _descriptionController,
//                             maxLines: 4,
//                             maxLength: 255,
//                             decoration: const InputDecoration(
//                               contentPadding: EdgeInsets.only(
//                                 top: 32,
//                                 left: 8,
//                                 right: 8,
//                               ),
//                               fillColor: Color(0xFFFFFCB7),
//                               counterText: "",
//                               filled: true,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "DESCRIPTION",
//                                   style: GoogleFonts.inter(
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 const Icon(
//                                   Symbols.add_notes,
//                                   color: Colors.grey,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Center(
//                 child: SizedBox(
//                   width: 150,
//                   child: TextButton(
//                     onPressed: () async {
//                       Future<void> error() async {
//                         await ScaffoldMessenger.of(context)
//                             .showSnackBar(
//                               const SnackBar(
//                                 duration: Duration(milliseconds: 1000),
//                                 content: Text(
//                                     'Must either have messenger contact or phone number'),
//                               ),
//                             )
//                             .closed;
//                       }

//                       if ((_contactNameController.text.isEmpty ||
//                               _dropdownController.dropDownValue == null) &&
//                           (_contactNumberController.text.isEmpty ||
//                               _contactNameController.text.isEmpty)) {
//                         await error();
//                         return;
//                       }

//                       widget.db.rawInsert(
//                         'INSERT INTO Doctor (facebook_id, name, address, description, contact_number) VALUES (?, ?, ?, ?, ?)',
//                         [
//                           _dropdownController.dropDownValue?.value,
//                           _contactNameController.text,
//                           "",
//                           _descriptionController.text,
//                           _contactNumberController.text,
//                         ],
//                       );

//                       if (context.mounted) {
//                         await ScaffoldMessenger.of(context)
//                             .showSnackBar(
//                               const SnackBar(
//                                 duration: Duration(milliseconds: 300),
//                                 content: Text('Success'),
//                               ),
//                             )
//                             .closed;
//                       }

//                       if (context.mounted) {
//                         Navigator.of(context).pop();
//                       }
//                     },
//                     style: ButtonStyle(
//                       backgroundColor: WidgetStateProperty.all(fgColor),
//                       overlayColor: WidgetStateProperty.all(
//                         Colors.white.withOpacity(0.5),
//                       ),
//                       shape: WidgetStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     child: const Text(
//                       "Add",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
