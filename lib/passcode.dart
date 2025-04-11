import 'package:blur/blur.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numpad_layout/numpad.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: SafeArea(
        child: Stack(
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
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/logo.png',
                      height: 60,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        "Never share your passcode with anyone",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/lock.png", width: 24),
                              const SizedBox(width: 10),
                              Text(
                                "Enter your passcode",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: fgColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              bool isFilled = index < _passcode.length;
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isFilled ? fgColor : Colors.transparent,
                                  border: Border.all(
                                    color: isFilled
                                        ? fgColor
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: NumPad(
                        rightWidget: IconButton(
                          onPressed: () {
                            if (_passcode.isNotEmpty) {
                              setState(() {
                                _passcode = _passcode.substring(
                                    0, _passcode.length - 1);
                              });
                            }
                          },
                          color: fgColor,
                          icon: const Icon(Icons.backspace_outlined),
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
                            if ((passcode.first["code"] as String) ==
                                _passcode) {
                              widget.setAuth(true);
                              return;
                            }

                            if (!context.mounted) return;

                            await ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    content: const Text(
                                        'Incorrect passcode. Try again.',
                                        style: TextStyle(color: Colors.white)),
                                    duration:
                                        const Duration(milliseconds: 1000),
                                  ),
                                )
                                .closed;
                            setState(() {
                              _passcode = "";
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'support@pulsepilot.info',
                          queryParameters: {
                            'subject': 'Support-Request',
                            'body': '',
                          },
                        );

                        launchUrl(emailUri);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: fgColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mail,
                                color: Colors.black, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Contact PulsePilot at support@pulsepilot.info",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
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
