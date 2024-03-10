import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numpad_layout/numpad.dart';
import 'package:sqflite/sqflite.dart';

class Passcode extends StatefulWidget {
  final void Function(bool) setAuth;

  const Passcode({
    super.key,
    required this.setAuth,
  });

  @override
  State<Passcode> createState() => _PasscodeState();
}

class _PasscodeState extends State<Passcode> {
  // final _pinController = TextEditingController();
  String _passcode = "";
  Database? _db;

  @override
  Widget build(context) {
    const loading = SpinKitCircle(color: fgColor);
    final scaffold = Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 231, 251),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset("assets/bg.png").blurred(blur: 5),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "DiaLife",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.italianno(
                      color: fgColor,
                      fontSize: 64,
                      height: 1,
                    ),
                  ),
                  Text(
                    "Never share your passcode to anyone",
                    style: GoogleFonts.montserrat(
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                        top: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          AutoSizeText(
                            "Enter your passcode",
                            maxLines: 1,
                            minFontSize: 16,
                            maxFontSize: 32,
                            style: GoogleFonts.istokWeb(
                              fontWeight: FontWeight.bold,
                              color: fgColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Image.asset("assets/lock.png", width: 50),
                          const SizedBox(height: 36),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: () {
                                    if (_passcode.isNotEmpty) {
                                      return Center(
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: fgColor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      );
                                    }
                                  }(),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: () {
                                    if (_passcode.length > 1) {
                                      return Center(
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: fgColor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      );
                                    }
                                  }(),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: () {
                                    if (_passcode.length > 2) {
                                      return Center(
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: fgColor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      );
                                    }
                                  }(),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: () {
                                    if (_passcode.length > 3) {
                                      return Center(
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: fgColor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      );
                                    }
                                  }(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  NumPad(
                    rightWidget: IconButton(
                      onPressed: () {
                        if (_passcode.isNotEmpty) {
                          setState(() {
                            _passcode =
                                _passcode.substring(0, _passcode.length - 1);
                          });
                        }
                      },
                      color: fgColor,
                      icon: const Icon(Icons.arrow_back_outlined),
                    ),
                    highlightColor: fgColor,
                    onType: (val) async {
                      if (_passcode.length < 4) {
                        setState(() {
                          _passcode += val;
                        });
                      }

                      if (_passcode.length == 4 && _db != null) {
                        final passcode =
                            await _db!.rawQuery("SELECT * FROM Passcode");
                        if ((passcode.first["code"] as String) == _passcode) {
                          widget.setAuth(true);
                          return;
                        }

                        if (!context.mounted) return;

                        await ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                duration: Duration(milliseconds: 300),
                                content: Text('Try Again'),
                              ),
                            )
                            .closed;
                        setState(() {
                          _passcode = "";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  AutoSizeText(
                    "Swipe left for emergency numbers",
                    maxLines: 2,
                    style: GoogleFonts.montserrat(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (_db == null) {
      return waitForFuture(
        loading: loading,
        future: getDatabasesPath(),
        builder: (context, data) {
          return waitForFuture(
            loading: loading,
            future: initAppDatabase(data),
            builder: (context, data) {
              _db = data;
              return scaffold;
            },
          );
        },
      );
    }

    return scaffold;
  }
}
