import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

class UserSetup extends StatefulWidget {
  final Database db;
  final Map<String, dynamic> provinceMap;
  final void Function() reset;

  const UserSetup({
    super.key,
    required this.reset,
    required this.provinceMap,
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

  final _provinceController = SingleValueDropDownController();
  final _municipalityController = SingleValueDropDownController();
  final _barangayController = SingleValueDropDownController();

  final TextEditingController _addressDescriptionController =
      TextEditingController();

  final TextEditingController _zipCodeController = TextEditingController();
  final PageController _setupController = PageController();
  late List<String> _provinceList;

  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isMale = true;
  int? _birtdayDay;
  int? _birthdayMonth;
  int? _birthdayYear;

  @override
  void initState() {
    _provinceList = widget.provinceMap.keys.toList();

    _provinceController.addListener(() {
      _municipalityController.clearDropDown();
      _barangayController.clearDropDown();

      setState(() {});
    });

    _municipalityController.addListener(() {
      _barangayController.clearDropDown();

      setState(() {});
    });

    super.initState();
  }

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
                                DropDownTextField(
                                  controller: _provinceController,
                                  enableSearch: true,
                                  dropDownItemCount: 4,
                                  textFieldDecoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    fillColor: const Color(0xFFE4E4E4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 8,
                                      top: 25,
                                    ),
                                  ),
                                  dropDownList: _provinceList
                                      .map((province) => DropDownValueModel(
                                          name: province, value: province))
                                      .toList(),
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
                                DropDownTextField(
                                  dropDownItemCount: 4,
                                  controller: _municipalityController,
                                  textFieldDecoration: InputDecoration(
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
                                  enableSearch: true,
                                  isEnabled:
                                      _provinceController.dropDownValue != null,
                                  dropDownList: () {
                                    if (_provinceController.dropDownValue ==
                                        null) {
                                      return const <DropDownValueModel>[];
                                    }

                                    final municipalities = widget.provinceMap[
                                            _provinceController.dropDownValue!
                                                .name]["municipality_list"]
                                        as Map<String, dynamic>;

                                    return municipalities.keys
                                        .map((municipality) =>
                                            DropDownValueModel(
                                                name: municipality,
                                                value: municipality))
                                        .toList();
                                  }(),
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
                                DropDownTextField(
                                  dropDownItemCount: 4,
                                  controller: _barangayController,
                                  textFieldDecoration: InputDecoration(
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
                                  enableSearch: true,
                                  isEnabled:
                                      _municipalityController.dropDownValue !=
                                          null,
                                  dropDownList: () {
                                    if (_municipalityController.dropDownValue ==
                                        null) {
                                      return const <DropDownValueModel>[];
                                    }

                                    final municipalities = widget.provinceMap[
                                            _provinceController.dropDownValue!
                                                .name]["municipality_list"]
                                        as Map<String, dynamic>;

                                    final barangays = (municipalities[
                                                _municipalityController
                                                    .dropDownValue!.name]
                                            ["barangay_list"] as List<dynamic>)
                                        .cast<String>();

                                    return barangays
                                        .map(
                                          (municipality) => DropDownValueModel(
                                            name: municipality,
                                            value: municipality,
                                          ),
                                        )
                                        .toList();
                                  }(),
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
                                  maxLength: 4,
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
                                    counterText: "",
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
                          const Expanded(child: SizedBox()),
                          TextButton(
                            onPressed: () {
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
          padding: const EdgeInsets.all(30),
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
                    "Setup Passcode",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.istokWeb(),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.only(
                    top: 36,
                    bottom: 10,
                    left: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Passcode"),
                      Material(
                        elevation: 4,
                        child: SizedBox(
                          width: 200,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "",
                              labelStyle: const TextStyle(fontSize: 32),
                              counterText: "",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              fillColor: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            controller: _pinController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 4,
                            obscureText: true,
                            style: const TextStyle(
                              fontSize: 48,
                              letterSpacing: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text("Confirm Passcode"),
                      Material(
                        elevation: 4,
                        child: SizedBox(
                          width: 200,
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: "",
                              labelStyle: const TextStyle(fontSize: 32),
                              counterText: "",
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              fillColor: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            controller: _confirmPinController,
                            maxLength: 4,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 48,
                              letterSpacing: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
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
                    if (_provinceController.dropDownValue == null ||
                        _municipalityController.dropDownValue == null ||
                        _barangayController.dropDownValue == null) {
                      return;
                    }

                    if (_provinceController.dropDownValue!.name.isEmpty ||
                        _municipalityController.dropDownValue!.name.isEmpty ||
                        _barangayController.dropDownValue!.name.isEmpty ||
                        _pinController.text.isEmpty ||
                        _confirmPinController.text.isEmpty) {
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

                    if (_zipCodeController.text.isEmpty) {
                      _zipCodeController.text = "----";
                    }

                    if (_pinController.text != _confirmPinController.text) {
                      await ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 300),
                              content: Text("Pins don't match."),
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
                        "province": _provinceController.dropDownValue!.name,
                        "is_male": _isMale,
                        "municipality":
                            _municipalityController.dropDownValue!.name,
                        "barangay": _barangayController.dropDownValue!.name,
                        "address_description":
                            _addressDescriptionController.text,
                        "zip_code": _zipCodeController.text,
                      },
                    );

                    await widget.db.insert("Passcode", {
                      "code": _pinController.text,
                    });

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
