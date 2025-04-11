import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EmergencyNumbers extends StatelessWidget {
  const EmergencyNumbers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          width: 200,
          child: AutoSizeText(
            "EMERGENCY CONTACTS",
            maxLines: 1,
            minFontSize: 0,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:911");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "National Emergency Hotline",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "911",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:0366210443");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(children: [
                            AutoSizeText(
                              "Capiz Emmanuel Hospital, Inc.",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            AutoSizeText(
                              "(036) 621 0443",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:0365221790");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "Roxas Memorial Provincial Hospital",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "(036) 522 1790",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:0366215675");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(children: [
                            AutoSizeText(
                              "Capiz Doctors Hospital",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            AutoSizeText(
                              "(036) 621 5675",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:0366212655");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "Medicus Diagnostic Center - Roxas",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "(036) 621 2655",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:143");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(children: [
                            AutoSizeText(
                              "Philippine Red Cross Hotline",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            AutoSizeText(
                              "143",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:026517800");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "DOH Health Emergency Management Bureau",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "(02) 651-7800",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:8531-1278");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "Philippine Diabetes Association",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "8531-1278",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                maxFontSize: 40,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:63-825311278");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "International Diabetes Federation",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "63-825311278",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                maxFontSize: 40,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:6328921064");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "Philippine Center for Diabetes Education Foundation, Inc.",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "632 892 1064",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                maxFontSize: 40,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:09173066741");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "Roxas City Emergency Response Team",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "0917 306 6741",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                maxFontSize: 40,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString("tel:(036) 621 1125 ");
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              AutoSizeText(
                                "Philippine Red Cross Capiz Chapter",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              AutoSizeText(
                                "(036) 621 1125",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                maxFontSize: 40,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
