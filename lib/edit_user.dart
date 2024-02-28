import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dialife/activity_log/input_form.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/edit_user_birthdate.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sqflite/sqflite.dart';

class EditUser extends StatelessWidget {
  const EditUser({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: const SpinKitCircle(color: fgColor),
    );

    return waitForFuture(
      future: getDatabasesPath(),
      loading: loading,
      builder: (context, data) {
        return waitForFuture(
          future: initAppDatabase(data),
          loading: loading,
          builder: (context, db) {
            return waitForFuture(
              future: Future.wait([
                db.query("User"),
                loadMunicipalityData(),
              ]),
              loading: loading,
              builder: (context, List<dynamic> data) {
                final user = User.fromMap(data[0][0] as Map<String, dynamic>);
                final municipalityData = data[1] as Map<String, dynamic>;
                final vals = municipalityData.values
                    .map((region) => region["province_list"])
                    .toList()
                    .cast<Map<String, dynamic>>();

                final provinceList = vals
                    .map((provinceList) => provinceList.entries.toList())
                    .flattened
                    .toList();

                final provinceMap = {
                  for (var element in provinceList) element.key: element.value
                };

                return _EditUserInternalScaffold(
                  user: user,
                  db: db,
                  provinceMap: provinceMap,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _EditUserInternalScaffold extends StatelessWidget {
  final Map<String, dynamic> provinceMap;
  final Database db;
  final User user;

  const _EditUserInternalScaffold({
    super.key,
    required this.provinceMap,
    required this.db,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Edit User")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _EditUserInternal(
            user: user,
            db: db,
            provinceMap: provinceMap,
          ),
        ),
      ),
    );
  }
}

class _EditUserInternal extends StatefulWidget {
  final Map<String, dynamic> _provinceMap;
  final Database db;
  final User user;

  const _EditUserInternal({
    super.key,
    required this.user,
    required this.db,
    required Map<String, dynamic> provinceMap,
  }) : _provinceMap = provinceMap;

  @override
  State<_EditUserInternal> createState() => _EditUserInternalState();
}

class _EditUserInternalState extends State<_EditUserInternal> {
  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _middleNameController = TextEditingController();

  final _contactNumberController = TextEditingController();

  late bool _isMale;
  late String _barangay;
  late String _municipality;
  late String _province;
  late String _zipCode;
  late String _addressDescription;
  late DateTime _birthday;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _middleNameController.text = widget.user.middleName;
    _contactNumberController.text = widget.user.contactNumber;

    _isMale = widget.user.isMale;
    _barangay = widget.user.barangay.toLowerCase().capitalize();
    _municipality = widget.user.municipality.toLowerCase().capitalize();
    _province = widget.user.province.toLowerCase().capitalize();
    _addressDescription = widget.user.addressDescription;
    _zipCode = widget.user.zipCode;
    _birthday = widget.user.birthday;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "DiaLife",
          textAlign: TextAlign.center,
          style: GoogleFonts.italianno(
            fontSize: 60,
            color: fgColor,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Hello, ",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: widget.user.firstName,
                style: GoogleFonts.istokWeb(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        AutoSizeText(
          "Please review and edit your information below.",
          maxLines: 1,
          textAlign: TextAlign.center,
          style: GoogleFonts.istokWeb(),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "First Name",
                          style: GoogleFonts.istokWeb(),
                        ),
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
                            contentPadding: const EdgeInsets.symmetric(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Name",
                          style: GoogleFonts.istokWeb(),
                        ),
                        TextField(
                          controller: _lastNameController,
                          style: GoogleFonts.istokWeb(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            fillColor: const Color(0xFFE4E4E4),
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
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Middle Name",
                          style: GoogleFonts.istokWeb(),
                        ),
                        TextField(
                          controller: _middleNameController,
                          style: GoogleFonts.istokWeb(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
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
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sex",
                          style: GoogleFonts.istokWeb(),
                        ),
                        DropdownButtonFormField(
                          items: ["Male", "Female"]
                              .map((sex) => DropdownMenuItem(
                                  value: sex, child: Text(sex)))
                              .toList(),
                          value: widget.user.isMale ? "Male" : "Female",
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            _isMale = value == "Male";
                          },
                          style: GoogleFonts.istokWeb(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            fillColor: const Color(0xFFE4E4E4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Number",
                    style: GoogleFonts.istokWeb(),
                  ),
                  TextField(
                    controller: _contactNumberController,
                    maxLength: 11,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      fillColor: const Color(0xFFE4E4E4),
                      counterText: "",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address",
                    style: GoogleFonts.istokWeb(),
                  ),
                  TextField(
                    onTap: () async {
                      final result = await Navigator.of(context).pushNamed(
                        "/edit-user/address",
                        arguments: {
                          "barangay": _barangay.toUpperCase(),
                          "municipality": _municipality.toUpperCase(),
                          "province": _province.toUpperCase(),
                          "zip_code": _zipCode,
                          "address_description": _addressDescription,
                          "province_map": widget._provinceMap,
                        },
                      ) as AddressForm?;

                      if (result == null) {
                        return;
                      }

                      setState(() {
                        _province = result.province.toLowerCase().capitalize();
                        _municipality =
                            result.municipality.toLowerCase().capitalize();
                        _barangay = result.barangay.toLowerCase().capitalize();
                        _zipCode = result.zipCode;
                        _addressDescription = result.addressDescription;
                      });
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      hintText:
                          "$_barangay, $_municipality, $_province, $_zipCode",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      fillColor: const Color(0xFFE4E4E4),
                      counterText: "",
                      suffixIcon: const Icon(
                        Symbols.edit_note,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Birthday",
                    style: GoogleFonts.istokWeb(),
                  ),
                  TextField(
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _birthday,
                        firstDate: DateTime(1),
                        lastDate: DateTime.now(),
                      );

                      if (date == null) {
                        return;
                      }

                      setState(() {
                        _birthday = date;
                      });
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      isDense: true,
                      hintText: DateFormat("MMMM dd, yyyy").format(_birthday),
                      suffixIcon: const Icon(
                        Symbols.edit_note,
                        size: 24,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      fillColor: const Color(0xFFE4E4E4),
                      counterText: "",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
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

              await widget.db.update(
                "User",
                {
                  "first_name": _firstNameController.text,
                  "last_name": _lastNameController.text,
                  "middle_name": _middleNameController.text,
                  "contact_number": _contactNumberController.text,
                  "birthdate": _birthday.toIso8601String(),
                  "province": _province,
                  "is_male": _isMale,
                  "municipality": _municipality,
                  "barangay": _barangay,
                  "address_description": _addressDescription,
                  "zip_code": _zipCode,
                },
                where: "id = ?",
                whereArgs: [widget.user.id],
              );

              if (!context.mounted) {
                return;
              }

              await ScaffoldMessenger.of(context)
                  .showSnackBar(
                    const SnackBar(
                      duration: Duration(milliseconds: 300),
                      content: Text('Successfully updated user'),
                    ),
                  )
                  .closed;

              if (!context.mounted) {
                return;
              }

              Navigator.of(context).pop();
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
        ),
      ],
    );
  }
}
