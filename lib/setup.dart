import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:dialife/api/api.dart';
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

  final TextEditingController _recoveryIdController = TextEditingController();

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
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _setupController,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: const Color(0x80E4E4E4),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "WELCOME TO",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.istokWeb(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "PulsePilot",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.italianno(
                        color: fgColor,
                        fontSize: 68,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "PulsePilot is a mobile application for diabetes management designed to help diabetic patients improve self-management, enhance access to care, and facilitate communication with healthcare providers. This app provides features such as blood sugar monitoring, medication intake tracking, doctor's appointment scheduling, weight and activity logging, nutrition tracking, instant messaging, and access to reading materials, all aimed at improving the quality of life for individuals with diabetes.",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.istokWeb(
                          fontSize: 15,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Let's Get Started",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.istokWeb(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: fgColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Please enter your name",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.istokWeb(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "First name",
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _firstNameController,
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          fillColor: const Color(0xFFE4E4E4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "Last name",
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _lastNameController,
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFE4E4E4),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "Middle name (optional)",
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _middleNameController,
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFE4E4E4),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () async {
                                if (_firstNameController.text.isEmpty ||
                                    _lastNameController.text.isEmpty) {
                                  await ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(milliseconds: 300),
                                          content: Text(
                                              'Please enter your first and last name'),
                                          behavior: SnackBarBehavior.floating,
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: fgColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.7, 0),
                              ),
                              child: Text(
                                "Next",
                                style: GoogleFonts.istokWeb(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () {
                                _showRecoveryDialog(context);
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: fgColor),
                                ),
                                foregroundColor: fgColor,
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.7, 0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.restore, size: 18, color: fgColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Recover Account",
                                    style: GoogleFonts.istokWeb(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
              color: const Color(0x80E4E4E4),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "PulsePilot",
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
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                          top: 25,
                                        ),
                                        fillColor: const Color(0xFFE4E4E4),
                                      ),
                                      textStyle:
                                          GoogleFonts.istokWeb(fontSize: 12),
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
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(12),
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.white.withOpacity(0.3),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all(fgColor),
                                  shape: WidgetStateProperty.all(
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
                                            duration:
                                                Duration(milliseconds: 300),
                                            content: Text('Incomplete Form'),
                                          ),
                                        )
                                        .closed;

                                    return;
                                  }

                                  if (_contactNumberController.text.length !=
                                      11) {
                                    await ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          const SnackBar(
                                            duration:
                                                Duration(milliseconds: 300),
                                            content: Text(
                                                'Incorrect Contact Number'),
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
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(12),
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.white.withOpacity(0.3),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all(fgColor),
                                  shape: WidgetStateProperty.all(
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
              color: const Color(0x80E4E4E4),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "PulsePilot",
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
                                          borderRadius:
                                              BorderRadius.circular(3),
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
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                          left: 8,
                                          top: 25,
                                        ),
                                        fillColor: const Color(0xFFE4E4E4),
                                      ),
                                      enableSearch: true,
                                      isEnabled:
                                          _provinceController.dropDownValue !=
                                              null,
                                      dropDownList: () {
                                        if (_provinceController.dropDownValue ==
                                            null) {
                                          return const <DropDownValueModel>[];
                                        }

                                        final municipalities = widget
                                                    .provinceMap[
                                                _provinceController
                                                    .dropDownValue!
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
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                          left: 8,
                                          top: 25,
                                        ),
                                        fillColor: const Color(0xFFE4E4E4),
                                      ),
                                      enableSearch: true,
                                      isEnabled: _municipalityController
                                              .dropDownValue !=
                                          null,
                                      dropDownList: () {
                                        if (_municipalityController
                                                .dropDownValue ==
                                            null) {
                                          return const <DropDownValueModel>[];
                                        }

                                        final municipalities = widget
                                                    .provinceMap[
                                                _provinceController
                                                    .dropDownValue!
                                                    .name]["municipality_list"]
                                            as Map<String, dynamic>;

                                        final barangays = (municipalities[
                                                    _municipalityController
                                                        .dropDownValue!
                                                        .name]["barangay_list"]
                                                as List<dynamic>)
                                            .cast<String>();

                                        return barangays
                                            .map(
                                              (municipality) =>
                                                  DropDownValueModel(
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
                                          borderRadius:
                                              BorderRadius.circular(3),
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
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(12),
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.white.withOpacity(0.3),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all(fgColor),
                                  shape: WidgetStateProperty.all(
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
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(12),
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.white.withOpacity(0.3),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all(fgColor),
                                  shape: WidgetStateProperty.all(
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
              color: const Color(0x80E4E4E4),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "PulsePilot",
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
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(12),
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.white.withOpacity(0.3),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all(fgColor),
                                  shape: WidgetStateProperty.all(
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
                            _municipalityController
                                .dropDownValue!.name.isEmpty ||
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
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.all(12),
                        ),
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withOpacity(0.3),
                        ),
                        backgroundColor: WidgetStateProperty.all(fgColor),
                        shape: WidgetStateProperty.all(
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
        ),
      ],
    );
  }

  Future<dynamic> _showRecoveryDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(Icons.restore, color: fgColor),
              const SizedBox(width: 10),
              Text(
                "Account Recovery",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please enter your 6-digit Recovery ID:",
                style: GoogleFonts.istokWeb(),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _recoveryIdController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: fgColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: fgColor, width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE4E4E4),
                  hintText: "Enter 6 digits",
                  counterText: "",
                  prefixIcon: const Icon(Icons.pin, color: fgColor),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Your Recovery ID was provided when you first created your account.",
                style: GoogleFonts.istokWeb(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_recoveryIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter your Recovery ID"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                if (_recoveryIdController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Recovery ID must be 6 digits"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                _showRecoveringDialog(context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(fgColor),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: const Text(
                "Recover Account",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _showRecoveringDialog(BuildContext context) {
    final passcodeController = TextEditingController();
    final confirmPasscodeController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(Icons.restore, color: fgColor),
              const SizedBox(width: 10),
              Text(
                "Account Recovery",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
            ],
          ),
          content: FutureBuilder(
            future: () async {
              final recoveryData = await MonitoringAPI.getRecoveryData(
                _recoveryIdController.text,
              );

              await widget.db.insert(
                "User",
                {
                  "first_name": recoveryData.firstName,
                  "last_name": recoveryData.lastName,
                  "middle_name": recoveryData.middleName,
                  "contact_number": recoveryData.contactNumber,
                  "birthdate": recoveryData.birthdate.toIso8601String(),
                  "province": recoveryData.province,
                  "is_male": recoveryData.sex == "Male",
                  "municipality": recoveryData.municipality,
                  "barangay": recoveryData.barangay,
                  "address_description": recoveryData.addressDescription,
                  "zip_code": recoveryData.zipCode,
                  "recovery_id": recoveryData.recoveryId,
                  "web_id": recoveryData.id,
                },
              );

              for (final record in recoveryData.bmiRecords) {
                await widget.db.insert(
                  "BMIRecord",
                  {
                    "height": double.parse(record.height),
                    "weight": double.parse(record.weight),
                    "notes": record.notes,
                    "created_at": record.recordedAt.toIso8601String(),
                  },
                );
              }

              for (final record in recoveryData.glucoseRecords) {
                await widget.db.insert(
                  "GlucoseRecord",
                  {
                    "glucose_level": record.glucoseLevel,
                    "notes": record.notes,
                    "is_a1c": record.isA1c,
                    "blood_test_date": record.recordedAt.toIso8601String(),
                  },
                );
              }

              for (final record in recoveryData.nutritionRecords) {
                await widget.db.insert(
                  "NutritionRecord",
                  {
                    "notes": record.notes,
                    "day_description": record.dayDescription,
                    "foods_csv": record.foodsCsv,
                    "created_at": record.recordedAt.toIso8601String(),
                  },
                );
              }

              for (final record in recoveryData.activityRecords) {
                await widget.db.insert(
                  "ActivityRecord",
                  {
                    "type": record.type,
                    "duration": record.duration,
                    "frequency": record.frequency,
                    "notes": record.notes,
                    "created_at": record.recordedAt.toIso8601String(),
                  },
                );
              }

              for (final record in recoveryData.waterRecords) {
                await widget.db.insert(
                  "WaterRecord",
                  {
                    "glasses": record.glasses,
                    "time": record.recordedAt.toIso8601String(),
                  },
                );
              }
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Recovering your account...",
                      style: GoogleFonts.istokWeb(),
                    ),
                    const SizedBox(height: 15),
                    const Center(
                        child: CircularProgressIndicator(color: fgColor)),
                  ],
                );
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Unable to recover account",
                      style: GoogleFonts.istokWeb(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: snapshot.error != null
                          ? ExpansionTile(
                              title: Text(
                                "Technical Details",
                                style: GoogleFonts.istokWeb(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${snapshot.error}",
                                    style: GoogleFonts.istokWeb(
                                      fontSize: 13,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success icon with animation - reduced size
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.green[600],
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title with more concise styling
                        Text(
                          "Recovery Complete",
                          style: GoogleFonts.istokWeb(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: fgColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description with improved readability
                        Text(
                          "Please set up a new passcode to continue.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.istokWeb(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Passcode fields with improved styling and reduced spacing
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              // Combine passcode fields in rows to save vertical space
                              Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "New Passcode",
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: "Code",
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500]),
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                          ),
                                          textAlign: TextAlign.center,
                                          controller: passcodeController,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          maxLength: 4,
                                          obscureText: true,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            letterSpacing: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Confirm Passcode",
                                        style: GoogleFonts.istokWeb(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            hintText: "Confirm",
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500]),
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                          ),
                                          textAlign: TextAlign.center,
                                          controller: confirmPasscodeController,
                                          maxLength: 4,
                                          obscureText: true,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            letterSpacing: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // More compact button
                        ElevatedButton(
                          onPressed: () async {
                            if (passcodeController.text.isEmpty ||
                                confirmPasscodeController.text.isEmpty) {
                              await ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    const SnackBar(
                                      duration: Duration(milliseconds: 300),
                                      content: Text(
                                        "Please enter a 4-digit passcode.",
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  )
                                  .closed;
                              return;
                            }

                            if (passcodeController.text !=
                                confirmPasscodeController.text) {
                              await ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    const SnackBar(
                                      duration: Duration(milliseconds: 300),
                                      content: Text("Passcodes do not match."),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  )
                                  .closed;
                              return;
                            }

                            await widget.db.insert("Passcode", {
                              "code": passcodeController.text,
                            });

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            await ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  const SnackBar(
                                    duration: Duration(milliseconds: 300),
                                    content:
                                        Text('Account successfully recovered!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                )
                                .closed;

                            widget.reset();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fgColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.5, 0),
                          ),
                          child: Text(
                            "Complete Recovery",
                            style: GoogleFonts.istokWeb(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
