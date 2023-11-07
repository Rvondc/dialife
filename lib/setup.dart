import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

class UserSetup extends StatefulWidget {
  final Database db;
  final void Function() reset;

  const UserSetup({
    super.key,
    required this.reset,
    required this.db,
  });

  @override
  State<UserSetup> createState() => _UserSetupState();
}

class _UserSetupState extends State<UserSetup> {
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _middleNameController = TextEditingController();

  final TextEditingController _contactNumberController =
      TextEditingController();

  final TextEditingController _provinceController = TextEditingController();

  final TextEditingController _municipalityController = TextEditingController();

  final TextEditingController _barangayController = TextEditingController();

  final TextEditingController _addressDescriptionController =
      TextEditingController();

  final TextEditingController _zipCodeController = TextEditingController();
  final PageController _setupController = PageController();

  bool _isMale = true;
  int? _birtdayDay;
  int? _birthdayMonth;
  int? _birthdayYear;

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _setupController,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFFE4E4E4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "WELCOME TO",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.istokWeb(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "DiaLife",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.italianno(
                    color: fgColor,
                    fontSize: 64,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "What's your name?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.istokWeb(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text("First name"),
                                  TextField(
                                    controller: _firstNameController,
                                    style: GoogleFonts.istokWeb(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      fillColor: const Color(0xFFE4E4E4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text("Last name"),
                                  TextField(
                                    controller: _lastNameController,
                                    style: GoogleFonts.istokWeb(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFE4E4E4),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text("Middle name (optional)"),
                                  TextField(
                                    controller: _middleNameController,
                                    style: GoogleFonts.istokWeb(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFE4E4E4),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextButton(
                              onPressed: () async {
                                if (_firstNameController.text.isEmpty ||
                                    _lastNameController.text.isEmpty) {
                                  await ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(milliseconds: 300),
                                          content: Text('Incomplete Form'),
                                        ),
                                      )
                                      .closed;

                                  return;
                                }

                                _setupController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(12),
                                ),
                                overlayColor: MaterialStateProperty.all(
                                  Colors.white.withOpacity(0.3),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(fgColor),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Next",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFFE4E4E4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "DiaLife",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.italianno(
                    color: fgColor,
                    fontSize: 64,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Tell me about yourself",
                  style: GoogleFonts.istokWeb(
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    "Choose your sex, date of birth, and enter your contact number.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.istokWeb(),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Sex",
                            style: GoogleFonts.istokWeb(),
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(3),
                                  color: const Color(0xFFE4E4E4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(width: 10),
                                    const Text("Male"),
                                    Checkbox(
                                      value: _isMale,
                                      activeColor: fgColor,
                                      onChanged: (value) {
                                        setState(() {
                                          _isMale = !_isMale;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(3),
                                  color: const Color(0xFFE4E4E4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(width: 10),
                                    const Text("Female"),
                                    Checkbox(
                                      value: !_isMale,
                                      activeColor: fgColor,
                                      onChanged: (value) {
                                        setState(() {
                                          _isMale = !_isMale;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Birthday",
                            style: GoogleFonts.istokWeb(),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownDatePicker(
                                  selectedDay: _birtdayDay,
                                  selectedMonth: _birthdayMonth,
                                  selectedYear: _birthdayYear,
                                  inputDecoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      top: 25,
                                    ),
                                    fillColor: const Color(0xFFE4E4E4),
                                  ),
                                  textStyle: GoogleFonts.istokWeb(fontSize: 12),
                                  onChangedDay: (val) {
                                    if (val == null) {
                                      return;
                                    }

                                    setState(() {
                                      _birtdayDay = int.parse(val);
                                    });
                                  },
                                  onChangedMonth: (val) {
                                    if (val == null) {
                                      return;
                                    }

                                    setState(() {
                                      _birthdayMonth = int.parse(val);
                                    });
                                  },
                                  onChangedYear: (val) {
                                    if (val == null) {
                                      return;
                                    }

                                    setState(() {
                                      _birthdayYear = int.parse(val);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Contact Number",
                              style: GoogleFonts.istokWeb(),
                            ),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                maxLength: 11,
                                decoration: InputDecoration(
                                  filled: true,
                                  isDense: true,
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    left: 8,
                                    top: 25,
                                  ),
                                  fillColor: const Color(0xFFE4E4E4),
                                ),
                                controller: _contactNumberController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              _setupController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.all(12),
                              ),
                              overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.3),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(fgColor),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              width: 75,
                              child: Text(
                                "Back",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          TextButton(
                            onPressed: () async {
                              if (_birthdayMonth == null ||
                                  _birtdayDay == null ||
                                  _birthdayYear == null ||
                                  _contactNumberController.text.isEmpty) {
                                await ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      const SnackBar(
                                        duration: Duration(milliseconds: 300),
                                        content: Text('Incomplete Form'),
                                      ),
                                    )
                                    .closed;

                                return;
                              }

                              if (_contactNumberController.text.length != 11) {
                                await ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      const SnackBar(
                                        duration: Duration(milliseconds: 300),
                                        content:
                                            Text('Incorrect Contact Number'),
                                      ),
                                    )
                                    .closed;

                                return;
                              }

                              _setupController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.all(12),
                              ),
                              overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.3),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(fgColor),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              width: 75,
                              child: Text(
                                "Next",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFFE4E4E4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "DiaLife",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.italianno(
                    color: fgColor,
                    fontSize: 64,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Enter your address",
                  style: GoogleFonts.istokWeb(
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    "Enter your province, municipality, barangay, and ZIP Code.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.istokWeb(),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Province",
                                  style: GoogleFonts.istokWeb(),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 8,
                                      top: 25,
                                    ),
                                    fillColor: const Color(0xFFE4E4E4),
                                  ),
                                  controller: _provinceController,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Municipality",
                                  style: GoogleFonts.istokWeb(),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 8,
                                      top: 25,
                                    ),
                                    fillColor: const Color(0xFFE4E4E4),
                                  ),
                                  controller: _municipalityController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Barangay",
                                  style: GoogleFonts.istokWeb(),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 8,
                                      top: 25,
                                    ),
                                    fillColor: const Color(0xFFE4E4E4),
                                  ),
                                  controller: _barangayController,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "ZIP Code",
                                  style: GoogleFonts.istokWeb(),
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 8,
                                      top: 25,
                                    ),
                                    fillColor: const Color(0xFFE4E4E4),
                                  ),
                                  controller: _zipCodeController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            "Address Description (optional)",
                            style: GoogleFonts.istokWeb(),
                          ),
                          TextField(
                            maxLines: 4,
                            maxLength: 255,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              contentPadding: const EdgeInsets.only(
                                left: 8,
                                top: 25,
                              ),
                              fillColor: const Color(0xFFE4E4E4),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              _setupController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.all(12),
                              ),
                              overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.3),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(fgColor),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            child: const SizedBox(
                              width: 75,
                              child: Text(
                                "Back",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () async {
                    if (_provinceController.text.isEmpty ||
                        _municipalityController.text.isEmpty ||
                        _barangayController.text.isEmpty ||
                        _zipCodeController.text.isEmpty) {
                      await ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 300),
                              content: Text('Incomplete Form'),
                            ),
                          )
                          .closed;

                      return;
                    }

                    await widget.db.insert(
                      "User",
                      {
                        "first_name": _firstNameController.text,
                        "last_name": _lastNameController.text,
                        "middle_name": _middleNameController.text,
                        "contact_number": _contactNumberController.text,
                        "birthdate": DateTime(
                          _birthdayYear!,
                          _birthdayMonth!,
                          _birtdayDay!,
                        ).toIso8601String(),
                        "province": _provinceController.text,
                        "is_male": _isMale,
                        "municipality": _municipalityController.text,
                        "barangay": _barangayController.text,
                        "address_description":
                            _addressDescriptionController.text,
                        "zip_code": _zipCodeController.text,
                      },
                    );

                    if (!context.mounted) {
                      return;
                    }

                    await ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 300),
                            content: Text('Successfully created user'),
                          ),
                        )
                        .closed;

                    widget.reset();
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(12),
                    ),
                    overlayColor: MaterialStateProperty.all(
                      Colors.white.withOpacity(0.3),
                    ),
                    backgroundColor: MaterialStateProperty.all(fgColor),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: const Text(
                      "Done",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const AutoSizeText(
//                 "First Time Setup",
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 48,
//                   height: 1,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text("Enter User Data: "),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _firstNameController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "First Name Required";
//                           }

//                           return null;
//                         },
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "First Name",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _lastNameController,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Last Name Required";
//                           }

//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "Last Name",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _middleNameController,
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "Middle Name",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () async {
//                         final birthday = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime.fromMillisecondsSinceEpoch(0),
//                           lastDate: DateTime.now(),
//                         );

//                         if (birthday == null) {
//                           return;
//                         }

//                         setState(() {
//                           _birthday = birthday;
//                           _dateTimeErr = false;
//                         });
//                       },
//                       child: Material(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Container(
//                           height: 48,
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.calendar_month_outlined),
//                               const SizedBox(width: 5),
//                               Text(
//                                 _birthday == null
//                                     ? "BIRTHDAY"
//                                     : DateFormat("dd/MM/yyyy")
//                                         .format(_birthday!),
//                                 style: TextStyle(
//                                   color: !_dateTimeErr
//                                       ? Colors.black.withOpacity(0.6)
//                                       : Colors.red,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Material(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: TextFormField(
//                   keyboardType: TextInputType.number,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   controller: _contactNumberController,
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(11),
//                   ],
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Contact Number Required";
//                     }

//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     isDense: true,
//                     contentPadding: const EdgeInsets.all(12),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                     hintText: "Contact Number",
//                     fillColor: Colors.white,
//                     filled: true,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Text("Enter Address Data: "),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _provinceController,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Provice Required";
//                           }

//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "Province",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _municipalityController,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Municipality Required";
//                           }

//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "Municipality",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _barangayController,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Barangay Required";
//                           }

//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "Barangay",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Material(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: TextFormField(
//                         controller: _zipCodeController,
//                         keyboardType: TextInputType.number,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "ZIP Code Required";
//                           }

//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           isDense: true,
//                           contentPadding: const EdgeInsets.all(12),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide.none,
//                           ),
//                           hintText: "ZIP Code",
//                           fillColor: Colors.white,
//                           filled: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Material(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: TextField(
//                   controller: _addressDescriptionController,
//                   maxLength: 255,
//                   maxLines: 5,
//                   decoration: InputDecoration(
//                     isDense: true,
//                     contentPadding: const EdgeInsets.all(12),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide.none,
//                     ),
//                     hintText: "Address Description",
//                     fillColor: Colors.white,
//                     floatingLabelBehavior: FloatingLabelBehavior.always,
//                     filled: true,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(fgColor),
//                 ),
//                 onPressed: () async {
//                   if (_formKey.currentState == null) {
//                     return;
//                   }

//                   if (_birthday == null) {
//                     setState(() {
//                       _dateTimeErr = true;
//                     });
//                   }

//                   if (!_formKey.currentState!.validate() || _dateTimeErr) {
//                     return;
//                   }

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Registering..."),
//                       duration: Duration(milliseconds: 200),
//                     ),
//                   );

//                   await widget.db.insert(
//                     "User",
//                     {
//                       "first_name": _firstNameController.text,
//                       "last_name": _lastNameController.text,
//                       "middle_name": _middleNameController.text,
//                       "contact_number": _contactNumberController.text,
//                       "birthdate": _birthday!.toIso8601String(),
//                       "province": _provinceController.text,
//                       "municipality": _municipalityController.text,
//                       "barangay": _barangayController.text,
//                       "address_description": _addressDescriptionController.text,
//                       "zip_code": _zipCodeController.text,
//                     },
//                   );

//                   if (!context.mounted) {
//                     return;
//                   }

//                   await ScaffoldMessenger.of(context)
//                       .showSnackBar(
//                         const SnackBar(
//                           content: Text("Success"),
//                           duration: Duration(milliseconds: 200),
//                         ),
//                       )
//                       .closed;

//                   await Future.delayed(
//                       const Duration(milliseconds: 500), widget.reset);
//                 },
//                 child: const Text(
//                   "SUBMIT",
//                   style: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),