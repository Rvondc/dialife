import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditUserBirthDate extends StatefulWidget {
  final String barangay;
  final String municipality;
  final String province;
  final String zipCode;
  final String addressDescription;
  final Map<String, dynamic> provinceMap;

  const EditUserBirthDate({
    super.key,
    required this.barangay,
    required this.addressDescription,
    required this.municipality,
    required this.province,
    required this.zipCode,
    required this.provinceMap,
  });

  @override
  State<EditUserBirthDate> createState() => _EditUserBirthDateState();
}

class _EditUserBirthDateState extends State<EditUserBirthDate> {
  late final SingleValueDropDownController _provinceController;

  late final SingleValueDropDownController _municipalityController;

  late final SingleValueDropDownController _barangayController;

  late final TextEditingController _zipCodeController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _barangayController = SingleValueDropDownController(
      data: DropDownValueModel(
        name: widget.barangay,
        value: widget.barangay,
      ),
    );

    _municipalityController = SingleValueDropDownController(
      data: DropDownValueModel(
        name: widget.municipality,
        value: widget.municipality,
      ),
    );

    _provinceController = SingleValueDropDownController(
      data: DropDownValueModel(
        name: widget.province,
        value: widget.province,
      ),
    );

    _zipCodeController = TextEditingController(text: widget.zipCode);
    _descriptionController =
        TextEditingController(text: widget.addressDescription);

    _provinceController.addListener(() {
      _municipalityController.clearDropDown();
      _barangayController.clearDropDown();

      setState(() {});
    });

    _municipalityController.addListener(() {
      _barangayController.clearDropDown();

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final provinceList = widget.provinceMap.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Address")),
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "DiaLife",
                textAlign: TextAlign.center,
                style: GoogleFonts.italianno(
                  fontSize: 60,
                  color: fgColor,
                ),
              ),
              AutoSizeText(
                "Please review and edit your information below.",
                maxLines: 1,
                textAlign: TextAlign.center,
                style: GoogleFonts.istokWeb(),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(10),
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
                                dropDownList: provinceList
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
                                      .map((municipality) => DropDownValueModel(
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
                          controller: _descriptionController,
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
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  if (_provinceController.dropDownValue == null ||
                      _municipalityController.dropDownValue == null ||
                      _barangayController.dropDownValue == null) {
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

                  Navigator.of(context).pop(
                    AddressForm(
                      barangay: _barangayController.dropDownValue!.name,
                      municipality: _municipalityController.dropDownValue!.name,
                      province: _provinceController.dropDownValue!.name,
                      addressDescription: _descriptionController.text,
                      zipCode: _zipCodeController.text,
                    ),
                  );
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
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressForm {
  final String barangay;
  final String municipality;
  final String province;
  final String addressDescription;
  final String zipCode;

  const AddressForm({
    required this.barangay,
    required this.municipality,
    required this.province,
    required this.addressDescription,
    required this.zipCode,
  });
}
