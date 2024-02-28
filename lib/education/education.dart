import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class Education extends StatefulWidget {
  const Education({super.key});

  @override
  State<Education> createState() => _EducationState();
}

enum Language {
  english,
  ilonggo,
}

class _EducationState extends State<Education> {
  var _lang = Language.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Educational Materials"),
      ),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            top: 25,
            left: 10,
            right: 10,
            bottom: 25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "EDUCATIONAL MATERIALS",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 30),
                        child: Image.asset(
                          "assets/educational_material_logo.png",
                          height: 200,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _lang = _lang == Language.english
                                ? Language.ilonggo
                                : Language.english;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "English",
                                style: TextStyle(
                                  fontWeight: _lang == Language.english
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const TextSpan(text: " / "),
                              TextSpan(
                                text: "Hiligaynon",
                                style: TextStyle(
                                  fontWeight: _lang != Language.english
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
              const SizedBox(height: 10),
              const Divider(),
              Text(
                "Topics",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed("/education/diabetes", arguments: {
                        "lang": _lang,
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF7F7A7A),
                            offset: Offset(4, 4),
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        dense: true,
                        title: Text(
                          _lang == Language.english
                              ? "Diabetes Mellitus"
                              : "Diyabetis",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              const Icon(
                                Symbols.dictionary,
                              ),
                              const SizedBox(width: 10),
                              Text(_lang == Language.english
                                  ? "English"
                                  : "Hiligaynon"),
                            ],
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
      ),
    );
  }
}
