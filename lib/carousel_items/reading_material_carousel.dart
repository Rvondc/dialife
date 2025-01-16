import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadingMaterialCarousel extends StatelessWidget {
  const ReadingMaterialCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              "Reading Materials",
              style: GoogleFonts.roboto(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: fgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      "assets/educational_material_logo.png",
                      width: 64,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Currently Reading",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade700,
                            height: 1,
                          ),
                        ),
                        Text(
                          "Diabetes Mellitus",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
