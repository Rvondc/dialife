import 'package:dialife/education/education.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiabetesList extends StatefulWidget {
  final Language _suggestedLang;

  const DiabetesList({
    super.key,
    required Language lang,
  }) : _suggestedLang = lang;

  @override
  State<DiabetesList> createState() => _DiabetesListState();
}

class _DiabetesListState extends State<DiabetesList> {
  late Language _lang;

  @override
  void initState() {
    _lang = widget._suggestedLang;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
          _lang == Language.english ? "Diabetes" : "Diyabetes",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
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
          )
        ],
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Brief Description",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "According to the American Diabetes Association (ADA), diabetes is a group of metabolic diseases characterized by high blood sugar (glucose) levels that result from defects in insulin secretion, insulin action, or both. Insulin is a hormone produced by the pancreas that allows glucose to enter cells, where it is used for energy. In diabetes, either the pancreas doesn't produce enough insulin or the body's cells do not respond properly to the insulin that is produced. This leads to elevated blood sugar levels, which can cause various complications if left untreated.")
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Ini isa ka pangmatag-ang kahimtangan sa panglawas nga nagakilala sa pagtaas sang level sang glucose (asukar) sa dugo. Ini nangin realidad ukon bangud ang lawas indi nagahimo sang bastante nga insulin, isa ka hormon nga nagaregulate sang asukar sa dugo, ukon bangud ang mga selula sang lawas indi maayo nga nagaresponde sa insulin."),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                _lang == Language.english
                    ? "Types of Diabetes"
                    : "Mga Uri ng Diyabetis",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          text: "\nA. Type 1 Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """(formerly Insulin-Dependent Diabetes Mellitus, IDDM): It is an autoimmune disease in which the body's immune system attacks and destroys insulin-producing beta cells in the pancreas. Therefore, the body does not produce insulin."""),
                        TextSpan(
                          text:
                              "\n\nReference: American Diabetes Association. (2021). Introduction: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S1-S2. [DOI: 10.2337/dc21-S001]",
                          style: TextStyle(fontSize: 10),
                        ),
                        TextSpan(
                          text: "\n\nB. Type 2 Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """(formerly Non-Insulin-Dependent Diabetes Mellitus, NIDDM): It is characterized by insulin resistance, where the body's cells do not respond effectively to insulin, and by impaired insulin secretion from the pancreas."""),
                        TextSpan(
                          text:
                              "\n\nReference: American Diabetes Association. (2021). Introduction: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S1-S2. [DOI: 10.2337/dc21-S001]",
                          style: TextStyle(fontSize: 10),
                        ),
                        TextSpan(
                          text: "\n\nC. Gestational Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """It occurs during pregnancy when the body cannot produce enough insulin to meet the increased needs of pregnancy."""),
                        TextSpan(
                          text:
                              "\n\nAmerican Diabetes Association. (2021). Management of Diabetes in Pregnancy: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S200-S210. [DOI: 10.2337/dc21-S015]",
                          style: TextStyle(fontSize: 10),
                        ),
                        TextSpan(
                          text: "\n\nD. Other Specific Types of Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """ This category includes various forms of diabetes resulting from specific causes, such as genetic defects of beta-cell function or insulin action, diseases of the exocrine pancreas (e.g., pancreatitis), endocrinopathies, drug- or chemical-induced diabetes, infections, and other genetic syndromes."""),
                        TextSpan(
                          text:
                              "\n\nReference: American Diabetes Association. (2020). 2. Classification and Diagnosis of Diabetes: Standards of Medical Care in Diabetes—2020. Diabetes Care, 43(Supplement 1), S14-S31. [DOI: 10.2337/dc20-S002]",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                            text: "\nA. Type 1 Diyabetis: \n",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """Sa Type 1 nga Diyabetis, nagakatabo ini kon ang immune system sa kalawasan nagakasala kag nagapukanay sa pag-ataki kag pagsira sang insulin-producing beta cells sa lapay. Ang mga tawo nga may Type 1 diabetes kinahanglan magkuha sang insulin sa regular nga paagi agod maupay nila kontrolon ang ila level sang asukar sa dugo."""),
                        TextSpan(
                            text: "\n\nB. Type 2 Diyabetis: \n",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                          text:
                              """Ini ang pinakamadayon nga klase sang Diyabetis, kinaandan nga nagadugang sa katigulangan. Sa Type 2 nga Diyabetis, ang lawas indi maayo mag-gamit sang insulin, kag sa sulod sang tiempo, mahimo nga indi na ini mag-produce sang bastante nga insulin. Madalag nga ginakonekta sa pag-usbong sang Type 2 diabetes ang mga baktor sa pamayo, henetiko, kag sobra nga kabug-atan.""",
                        ),
                        TextSpan(
                          text: "\n\nC. Gestational Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """Ini nga klase nagakatabo sa mga nanay naga busong kon ang lawas indi makahimo sang bastante nga insulin agod matigayon ang nagadamo nga panginahanglanon sa tion sang pagbata. Madalag ini nagalimpyo pagkatapos sang pagbun-agsang lapsag, pero ang mga babaye nga nag-antos sang gestational diabetes may dako nga katalagman nga magsulod sa Type 2 nga Diyabetis sa ulihi sa ila kabuhi."""),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Common Symptoms",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(() {
                TextSpan text;

                if (_lang == Language.english) {
                  text = TextSpan(
                    children: [
                      const TextSpan(
                        text: "● Excessive thirst (Polydipsia)\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Frequent urination (Polyuria)\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Unexplained weight loss\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Fatigue\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Blurred vision\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Slow healing of wounds\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Frequent infections\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Tingling or numbness in extremities\n",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "● Increased hunger (Polyphagia)",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      WidgetSpan(child: Image.asset("assets/dm_symptoms.png")),
                      const TextSpan(
                        text:
                            "\n\nReference: American Diabetes Association. (2021). Introduction: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S1-S2. [DOI: 10.2337/dc21-S001]",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  );
                } else {
                  text = const TextSpan(
                    children: [
                      TextSpan(text: "Not Available for Hiligaynon"),
                    ],
                  );
                }

                return text;
              }()),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Risk Factors",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "The American Diabetes Association (ADA) identifies several risk factors for developing type 2 diabetes. These risk factors include:\n\n",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Family History: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Having a parent or sibling with diabetes increases the risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Obesity or Overweight: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Being overweight or obese, especially if the weight is concentrated around the abdomen (central obesity), increases the risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Physical Inactivity: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Leading a sedentary lifestyle with little or no physical activity increases the risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Age: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "The risk of type 2 diabetes increases with age, particularly after the age of 45.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Race or Ethnicity: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Certain racial and ethnic groups, including African Americans, Hispanic/Latino Americans, Native Americans, Asian Americans, and Pacific Islanders, have a higher risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Gestational Diabetes: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Having gestational diabetes during pregnancy or giving birth to a baby weighing more than 9 pounds increases the risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Polycystic Ovary Syndrom (PCOS): ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Women with PCOS have a higher risk of developing type 2 diabetes.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Hypertension (High Blood Pressure): ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Having high blood pressure (140/90 mmHg or higher) increases the risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "High Cholesterol Levels: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Having low levels of high-density lipoprotein (HDL) cholesterol and/or high levels of triglycerides increases the risk.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "History of Cardiovascular Disease: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Having a history of heart disease or stroke increases the risk of type 2 diabetes.\n",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          text:
                              "\n\nReference: American Diabetes Association. (2021). Introduction: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S1-S2. [DOI: 10.2337/dc21-S001]",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        TextSpan(text: "Not Available for Hiligaynon"),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Diagnosis",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "\nDiabetes can be identified through A1C standards or plasma glucose criteria, which include the fasting plasma glucose (FPG) level, the 2-hour glucose (2-h PG) level during a 75-gram oral glucose tolerance test (OGTT), or a random glucose level alongside typical hyperglycemic symptoms like increased urination, excessive thirst, unexplained weight loss, or hyperglycemic emergencies.\n\n",
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                          text: "● A1C (Glycated Hemoglobin): ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                            text:
                                "A measurement of the average blood glucose levels over the past two to three months. An A1C level of 6.5% or higher is indicative of diabetes.\n\n"),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                          text: "● Fasting Plasma Glucose: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                            text:
                                "The level of glucose in the blood after an overnight fast of at least 8 - 10 hours. A fasting plasma glucose level of 126 milligrams per deciliter (mg/dL) or higher indicates diabetes.\n\n"),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                          text:
                              "● 2-hour Glucose (2-h PG) during Oral Glucose Tolerance Test (OGTT): ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                            text:
                                "measures the amount of glycosylation of normal hemoglobin A, and it correlates with the average blood glucose levels over the past 2 to 3 months.\n\n"),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                          text: "● Random Plasma Glucose: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                            text:
                                "A glucose test done at any time, regardless of the time since the last meal. A random plasma glucose level of 200 mg/dL (11.1 mmol/L) or higher, along with symptoms like increased urination (polyuria), excessive thirst (polydipsia), unexplained \n\n"),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                          text: "● Continuous Glucose Monitoring (CGM): ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                            text:
                                "is a valuable tool for diabetes management, providing real-time data on glucose levels throughout the day and night. It continuously measures glucose levels in the interstitial fluid, providing real-time data to users. These systems consist of a sensor inserted under the skin, which measures glucose levels and transmits data to a receiver or smartphone app."),
                        TextSpan(
                          text:
                              """\n\nReference: American Diabetes Association. (2022). Diagnosis and classification of diabetes mellitus. Diabetes Care, 45(Supplement_1), S17-S38. https://doi.org/10.2337/dc22-S002

American Diabetes Association. (2021). Continuous Glucose Monitoring: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S66. [DOI: 10.2337/dc21-S005]
""",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  } else {
                    text = TextSpan(
                      children: [
                        const TextSpan(
                          text: "\nA. Blood Text for Diabetes Mellitus \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Fast Glucose Test. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "Pag sukat sang asukal sa dugo paagi sa hindi pag kaon or inom tubig para sa chakto nga oras bag o ang aktuwal nga pag monitor , para sapag screen sang diabetes mga pasyente nga bag o lang man admit sa ospital care center. Ina ay parte sa tinuig nga screening sa unang pag atipan.\n\n"),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Random Glucose Test. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "Ini naga tungod parte sa sample nga dugo nga gin kuha maskin ano nga oras. Ang normal nga glucose level sang dugo dapat 70 asta 110 milligrams kada deciliter.\n\n"),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Hemoglobin A1C Test. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "Ga sukat sang kadamuon sang glycosylation sang normal hemoglobin A, kag nagaka angay upod sa katamtaman nga glucose level sang dugo halin sang nag ligad nga duwa asta tatlo ka bulan.\n\n"),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Glucose Tolerance Test. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "Ga sukat sang imo sugar sa dugo bag o kag matapos ka inom sang matam is nga ilimnon nga Gina tawag nga Glucola.\n"),
                        const WidgetSpan(
                            child: SizedBox(
                          height: 15,
                          width: double.infinity,
                        )),
                        const TextSpan(
                          text: "\nB. Methods/Gadgets used for testing\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const WidgetSpan(
                            child: SizedBox(
                          height: 15,
                          width: double.infinity,
                        )),
                        WidgetSpan(
                          child: Image.asset(
                            "assets/control_dm2.png",
                          ),
                        ),
                        const WidgetSpan(
                            child: SizedBox(
                          height: 15,
                          width: double.infinity,
                        )),
                        const TextSpan(
                            text:
                                "● Self-Monitoring of Blood Glucose (SMBG)\n"),
                        const TextSpan(
                            text: "● One Touch II Blood Glucose Monitor\n"),
                        const TextSpan(
                            text: "● Glucometer M+ Blood Glucose Monitor"),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              right: 10,
              left: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Prevention",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          text: "\n1. Healthy Eating - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Consuming a balanced diet rich in fruits, vegetables, whole grains, lean proteins, and healthy fats while limiting intake of processed foods, sugary beverages, and high-fat foods.\n\n"),
                        TextSpan(
                          text: "2. Regular Physical Activity - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Engaging in regular physical activity such as brisk walking, jogging, swimming, cycling, or aerobic exercises for at least 150 minutes per week, aiming for a combination of cardio and strength training exercises.\n\n"),
                        TextSpan(
                          text: "3. Weight Management - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Maintaining a healthy body weight through a combination of healthy eating and regular physical activity to achieve and sustain a body mass index (BMI) within the normal range (18.5–24.9 kg/m²).\n\n"),
                        TextSpan(
                          text: "4. Blood Pressure Control - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Monitoring blood pressure regularly and taking steps to control high blood pressure (hypertension) through lifestyle modifications (healthy diet, regular exercise, weight management) and, if necessary, medication prescribed by a healthcare provider.\n\n"),
                        TextSpan(
                          text: "5. Cholesterol Management - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Managing cholesterol levels by adopting a heart-healthy diet low in saturated and trans fats, maintaining a healthy weight, engaging in regular physical activity, and, if necessary, taking cholesterol-lowering medications as prescribed by a healthcare provider.\n\n"),
                        TextSpan(
                          text: "6. Smoking Cessation - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Quitting smoking or using tobacco products, as smoking is a significant risk factor for the development of type 2 diabetes and other serious health conditions."),
                        TextSpan(
                          text:
                              "\n\nReference: American Diabetes Association. (2021). Introduction: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S1-S2. [DOI: 10.2337/dc21-S001]",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          text: "\n1. Pag ehersisyo sang regular - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Ang pag ehersisyo nagapataas sang pagkasensitibo sang insulin sang cells, buot silingon, kilangnan sang dyutay nga insulin para sa pagdumala sang blood sugar lebel.\n\n"),
                        TextSpan(
                          text:
                              "2. Pag inom sang tubig bilang una nga ilimnon - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Ang mga maasukar nga ilimnom pareho sang mga soda (coke, sprite) kg mga matam is nga mga juice naga pataas sang kadelikado rason nga makuha mo ang sakit nga diabetes.\n\n"),
                        TextSpan(
                          text: "3. Pagkaon sang masustansya nga utan - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Ang mga utan nagahatag sang bitamina, mineral kg carbohydrates sa diet.\n\n"),
                        TextSpan(
                          text: "4. Pag untat sang panigarilyo - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Ang panigarilyo isa sa mga delikado nga rason para makapalala sang sakit nga diabetes. Kung permi naga sigarilyo dako man ang rason nga maglala ang diabetes."),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              right: 10,
              left: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Complications",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = TextSpan(
                      children: [
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                            text:
                                "These are long-term problems that can develop gradually, and can lead to serious damage if they go unchecked and untreated.\n\n"),
                        const TextSpan(
                          text: "I. Macrovascular Complications: \n\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(
                          child: Image.asset(
                            "assets/cvd.png",
                          ),
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "● Cardiovascular Disease (CVD) - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Diabetes increases the risk of various cardiovascular conditions such as coronary artery disease, heart attack, stroke, and peripheral arterial disease. "),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Introduction: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S1-S2. [DOI: 10.2337/dc21-S001] \n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/pad.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Peripheral Arterial Disease (PAD) - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "Diabetes can lead to reduced blood flow to the extremities, particularly the legs, due to narrowing or blockage of arteries, resulting in PAD."),
                            const TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Cardiovascular Disease and Risk Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S125-S150. [DOI: 10.2337/dc21-S008] \n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/stroke.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Stroke - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "Diabetes increases the risk of stroke, which occurs when blood flow to the brain is interrupted, leading to brain damage and neurological impairment."),
                            const TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Cardiovascular Disease and Risk Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S125-S150. [DOI: 10.2337/dc21-S008]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                            const TextSpan(
                              text: "\nII. Microvascular Complications: \n\n",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/dr.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Diabetic Retinopathy - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "Diabetes can damage the blood vessels in the retina, leading to diabetic retinopathy, a leading cause of blindness in adults."),
                            const TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Microvascular Complications and Foot Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S151-S167. [DOI: 10.2337/dc21-S009]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/cataract.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Cataracts - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "occur when the lens becomes cloudy, leading to blurred or impaired vision. The presence of diabetes can exacerbate the formation of cataracts due to the impact of elevated blood sugar levels on the lens structure."),
                            const TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Microvascular Complications and Foot Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S151-S167. [DOI: 10.2337/dc21-S009]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/dn.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Diabetic Nephropathy - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "Diabetes can cause damage to the kidneys, leading to diabetic nephropathy, characterized by proteinuria, decreased kidney function, and ultimately end-stage renal disease."),
                            const TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Microvascular Complications and Foot Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S151-S167. [DOI: 10.2337/dc21-S009]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/dnu.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Diabetic Neuropathy - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "Diabetes can damage nerves throughout the body, leading to various types of diabetic neuropathy, including peripheral neuropathy (affecting the extremities), autonomic neuropathy (affecting the internal organs), and focal neuropathy (affecting specific nerves). "),
                            const TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Microvascular Complications and Foot Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S151-S167. [DOI: 10.2337/dc21-S009]",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    text = TextSpan(
                      children: [
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                            text:
                                "Ang ini nga madugay nga problema naga dako kag naga rason sa paglala sang masakit kung indi pag ipa konsulta o ipabulong.\n"),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                "assets/eye_problems.png",
                              ),
                            ),
                            const TextSpan(
                              text: "● Eye Problems - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text:
                                    "Ang iban nga tawo nga may diabetes naga develop sang problema sa mata nga ginatawag nga retinopathy nga naga rason sa maglabi sang mata.kung ini nga problema maipakonsulta, malikawan ang paglala sang problema.\n\n"),
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Image.asset(
                                    "assets/foot_problems.png",
                                  ),
                                ),
                                const TextSpan(
                                  text: "● Foot Problems - ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                    text:
                                        "Ang problema sa tiil rason sang Diyabetis, isa ka seryoso nga problema nga maka apekto para utdon ang malala nga parti sang tiil nga may malala nga samad kung indi ini mabulong.Ang nerve damage makaapekto ini sa pamatyag sang tiil kung sa diin maga taas ang asukal sa dugo nga maging rason para masamad ang serkulasyon, kag ini maging rason nga madugay ang pag ayo sang samad.\n\n"),
                              ],
                            ),
                            const TextSpan(
                              children: [
                                TextSpan(
                                  text: "● Heart attack and Stroke - ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text:
                                        "Kung may ara ka nga diabetes, mataas nga asukal sa dugo nga makaapekto sa pagsamad sang ugat nga gina agyan sang dugo.Ini maging rason ngaa gina atake sa korason kag strokes.\n\n"),
                              ],
                            ),
                            const TextSpan(
                              children: [
                                TextSpan(
                                  text: "● Kidney Problems (nephropathy) - ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text:
                                        "Ang diabetes nagaapekto sa pagkasamad sang kidney sa madugay nga panahon ini mangin rason ngaa mabudlay mag sala sang higko halin sa aton lawas.Rason ini sa mataas nga asukal sa dugo kag altapresyon. Ginatawag ini nga Diabetic nephropathy ukon sakit sa bato.\n\n"),
                              ],
                            ),
                            const TextSpan(
                              children: [
                                TextSpan(
                                  text: "● Nerve Damange (neuropathy) - ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text:
                                        "Ang iban nga tawo nga may diabetes,naga develop sang nerve damage epekto sang komplikasyon sang mataas nga sugar level sa dugo. Amo ini ang rason ngaa mabudlay magdala sang mensahe sa pagitan sang utok kag iba pa nga parti sang lawas nga naga epekto sa aton panan awan,pamatin-an,aton nabatyagan kag aton paghulag.\n\n"),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              right: 10,
              left: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Acute Complications",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = TextSpan(
                      children: [
                        WidgetSpan(
                          child: Image.asset(
                            "assets/dka.png",
                          ),
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "● Diabetic Ketoacidosis (DKA) - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "It is a serious complication of diabetes characterized by high blood sugar levels, ketosis (elevated ketones in the blood), and metabolic acidosis. It typically occurs in individuals with type 1 diabetes but can also occur in those with type 2 diabetes under certain circumstances."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Diabetic Ketoacidosis (DKA) and Hyperglycemic Hyperosmolar State (HHS) in Adults. Diabetes Care, 44(Supplement 1), S193-S194. [DOI: 10.2337/dc21-S014]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        WidgetSpan(
                          child: Image.asset(
                            "assets/hhs.png",
                          ),
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "● Hyperglycemic Hyperosmolar State (HHS) - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "It is a severe complication of diabetes characterized by extremely high blood sugar levels, dehydration, and high blood osmolality without significant ketoacidosis. It typically occurs in individuals with type 2 diabetes and is more common in older adults."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Diabetic Ketoacidosis (DKA) and Hyperglycemic Hyperosmolar State (HHS) in Adults. Diabetes Care, 44(Supplement 1), S193-S194. [DOI: 10.2337/dc21-S014]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "● Smogyi Effect - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "It is also known as rebound hyperglycemia, occurs when blood sugar levels drop overnight, usually as a result of too much insulin or oral medications taken before bedtime. In response to low blood sugar levels, the body releases hormones (such as cortisol and adrenaline) to raise blood sugar levels, leading to high blood sugar levels in the morning."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Hypoglycemia. Diabetes Care, 44(Supplement 1), S178-S179. [DOI: 10.2337/dc21-S012]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "● Dawn Phenomenon - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "It refers to the natural rise in blood sugar levels that occurs in the early morning hours, usually between 4:00 a.m. and 8:00 a.m., in individuals with diabetes. This rise in blood sugar levels is believed to be related to the body's release of hormones (such as growth hormone and cortisol) in the hours before waking."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Glycemic Targets: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S73-S84. [DOI: 10.2337/dc21-S005]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        WidgetSpan(
                          child: Image.asset(
                            "assets/hypoglycemia.png",
                          ),
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "● Hypoglycemia - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "It occurs when blood sugar levels drop too low, leading to symptoms such as shakiness, sweating, confusion, and, if severe, loss of consciousness or seizures. It can result from excessive insulin or other glucose-lowering medications, delayed or missed meals, or increased physical activity."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Hypoglycemia. Diabetes Care, 44(Supplement 1), S178-S179. [DOI: 10.2337/dc21-S012]\n\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "● Hypoglycemia - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "Manubo nga asukal sa dugo.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "● Hyperglycemia - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "Mataas nga asukal sa dugo.\n\n"),
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "● Hyperosmolar Hyperglycaemic State (HHS) - ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text:
                                        "Ini isa ka banta sa kabuhi nga emergency ng nagakatabo sa tawo nga may type 2 diabetes.Rason ini sang sobra ka kulang sa tubig o mataas nga asukal sa dugo.\n\n"),
                              ],
                            ),
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "● Diabetic Ketoacidosis (DKA) - ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text:
                                        "Isa ka banta sa kabuhi nga emergency kung sa diin kulang sa insulin kag mataas nga asukal sa dugo nga naga rason para mag tubo ang ketones."),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              right: 10,
              left: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Intervention",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\n1. Self-Monitoring of Blood Glucose - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Monitor your blood glucose levels regularly to track how your body responds to food, exercise, and medication. This helps you make informed decisions about managing your diabetes effectively."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Hypoglycemia. Diabetes Care, 44(Supplement 1), S178-S179. [DOI: 10.2337/dc21-S012]\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "\n2. Healthy Eating and Physical Activity - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Adopt a healthy eating plan that includes a variety of nutrient-rich foods, such as fruits, vegetables, whole grains, lean proteins, and healthy fats. Combine this with regular physical activity, aiming for at least 150 minutes per week, to help manage your blood sugar levels and improve overall health."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Lifestyle Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S67-S76. [DOI: 10.2337/dc21-S005]\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\n3. Medication Adherence - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Adopt a healthy eating plan that includes a variety of nutrient-rich foods, such as fruits, vegetables, whole grains, lean proteins, and healthy fats. Combine this with regular physical activity, aiming for at least 150 minutes per week, to help manage your blood sugar levels and improve overall health."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Medication Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S98-S110. [DOI: 10.2337/dc21-S006]\n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "\n4. Stress Management and Coping Strategies - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Practice stress management techniques, such as deep breathing, meditation, or engaging in activities you enjoy, to help reduce stress and improve your emotional well-being. Seek support from friends, family, or mental health professionals if needed."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Psychosocial Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S165-S174. [DOI: 10.2337/dc21-S011]n",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "\n1. E edukar ukon tudluan ang pasyente - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "E edukar ukon tudluan ang pasyente parte sa diabetes kag sugiran kon ano ang mga pamaagi sila mabulong. Kag para mabal-an kag ma intindihan kon ano ang apekto sang pag diet, sang stress, sang bulong kag pag ehersisyo sa glucose level sa is aka pasyente nga may diabetes.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "2. E mintinar ang glucose levels - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "E mintinar ang HbA1c ng 7% kag ang blood sugar levels halin sa 90 tubtob sa 130 mg/dL. Ang malawig nga pagmintinar sang pag control sang glocuse level ang manami nga pag untat sang posible nga complikasyon.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "3. E edukar ukon tudluan sa pag inom sang bulong - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Ang pasyente nga may type 2 diabetes, prediabetes, and gestational diabetes ang naga mintinar sang bulong nga gina inom.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "4. E expectar nga lain-lain ang pama-agi ang pagbulong sa type 1 kag type 2 Diabetes - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Naga dependi ang pag bulong sa mga pasyente nga may diabetes mellitus, may ara nga gina inom, gina inject kag ang gina monitor ang blood sugar level.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "5. Asistiran ukon tudluan sang pwedi nga kaunon sang pasyete nga may diabetes - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Ang pasyente nga may diabetes dapat may ara nga gina sunod nga pwedi kag indi kaunon, ibanan ang pagkaon sang carbohydrates parihas sang pasta, tinapay labi na gid ang kan on, processed foods, kag pagkaon nga matam is. Tudluan sapagkaon sang damo nga prutas, gulay, kag ang pagkaon nga may protina.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "6. Iga tudlo ang pisikal nga ehersisyo - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Iga tudlo ang pag ubra sang pisikal nga ehersisyo para maka bulig nga maka sulod ang sugar sa cell para in maging enerhiya. Kay ang pag ehersisyo naga bulig para nga gamay na lang ang kinanglanun sang insulin pero gina advisan nga magpakunsulta danay sa doctor.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "7. Magcoordinar sa diabetes nurse educator - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Ang diabetes educator naga tudlo sa mga tawo nga may diabetes kon paano nila manage ila nga kondisyon. Naga edukar man sila sa pamilya kag naga alaga sang pasyente nga may diabetes kon paano sila alagaan.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "8. Ipabalo sa pasyente ang pag alaga sang baba - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Mataas ang tyansa sang gum infection sa pasyente nga may diabetes. Gina advise an ang pag toothbrush sang duha kada beses sa isa ka adlaw, mag gamit sang floss kag mag pa cheek up sa dental clinic.\n\n"),
                          ],
                        ),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                "Recommended Diet for Type 2 Diabetes",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\nEmphasize Nutriet-Rich Foods - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Focus on consuming a variety of nutrient-rich foods, including fruits, vegetables, whole grains, lean proteins (such as poultry, fish, beans, and tofu), and healthy fats (such as nuts, seeds, avocados, and olive oil).\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\nControl Carbohydrate Intake - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Adopt a healthy eating plan that includes a variety of nutrient-rich foods, such as fruits, vegetables, whole grains, lean proteins, and healthy fats. Combine this with regular physical activity, aiming for at least 150 minutes per week, to help manage your blood sugar levegetables.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\nMonitor Portion Sizes - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Be mindful of portion sizes to avoid overeating and maintain a healthy weight. Use measuring cups, spoons, or food scales to accurately measure serving sizes, especially for carbohydrate-containing foods.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\nLimit Added Sugars and Sweets - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Limit intake of foods and beverages high in added sugars, such as sugary drinks, desserts, candies, and processed snacks. Opt for naturally sweet options like fruits to satisfy your sweet cravings.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\nInclude Healthy Fats - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Incorporate sources of healthy fats, such as nuts, seeds, avocados, fatty fish (like salmon and mackerel), and olive oil, into your diet. These fats can help improve heart health and promote satiety.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\nStay Hydrated - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Drink plenty of water throughout the day to stay hydrated. Limit intake of sugary beverages and opt for water, herbal tea, or sparkling water instead."),
                            TextSpan(
                              text:
                                  "\n\nReference: American Diabetes Association. (2021). Lifestyle Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S67-S76. [DOI: 10.2337/dc21-S005]",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(text: "Not available for Hiligaynon");
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                "Wound Care Recommendations",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = TextSpan(
                      children: [
                        WidgetSpan(child: Image.asset("assets/wound_care.png")),
                        const TextSpan(
                            text:
                                "The American Diabetes Association (ADA) provides guidelines for wound care in individuals with diabetes, particularly focusing on foot care due to the increased risk of foot ulcers and complications. \n"),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "\n1. Daily Foot Inspection - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Individuals with diabetes should inspect their feet daily for any signs of injury, such as cuts, blisters, redness, or swelling. Any abnormalities should be reported to a healthcare professional promptly.\n"),
                          ],
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "\n2. Proper Wound Clearning - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Clean wounds with mild soap and warm water, and pat dry gently. Avoid soaking feet, as it can soften the skin and increase the risk of injury.\n"),
                          ],
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "\n3. Protection and Moisturization - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Apply a moisturizer to the feet, avoiding the areas between the toes, to prevent dryness and cracking. Wear clean, dry socks and well-fitting shoes to protect the feet from injury.\n"),
                          ],
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "\n4. Prompt Treatment of Wounds - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Apply a moisturizer to the feet, avoiding the areas between the toes, to prevent dryness and cracking. Wear clean, dry socks and well-fitting shoes to protect the feet from injury.\n"),
                          ],
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "\n5. Avoidance of Self-Treatment - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Drink plenty of water throughout the day to stay hydrated. Limit intake of sugary beverages and opt for water, herbal tea, or sparkling water instead."),
                            TextSpan(
                              text:
                                  "\n\nAmerican Diabetes Association. (2021). Microvascular Complications and Foot Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S151-S167. [DOI: 10.2337/dc21-S009]",
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(text: "Not available for Hiligaynon");
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                "Exercise Recommendations for Diabetic Patients",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        TextSpan(
                            text:
                                "Exercise is an important component of diabetes management, and the American Diabetes Association (ADA) provides guidelines for individuals with diabetes regarding physical activity. \n"),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\n1. Aerobic Exercise - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Engage in at least 150 minutes of moderate-intensity aerobic exercise per week, spread over at least three days, with no more than two consecutive days without exercise. Examples include brisk walking, cycling, swimming, or dancing.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\n2. Strength Training - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Incorporate strength training exercises at least two days per week, targeting major muscle groups. Use resistance bands, free weights, or weight machines for activities such as lifting weights or performing bodyweight exercises.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\n3. Flexibility and Balance Exercises - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Include flexibility and balance exercises in your routine to improve range of motion, flexibility, and stability. These exercises can help reduce the risk of falls and injuries. Examples include yoga, tai chi, or stretching exercises.\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "\n4. Individualized Approach - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Apply a moisturizer to the feet, avoiding the areas between the toes, to prevent dryness and cracking. Wear clean, dry socks and well-fitting shoes to protect the feet from injury.\n"),
                          ],
                        ),
                        TextSpan(
                          text:
                              "\nAmerican Diabetes Association. (2021). Lifestyle Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S67-S76. [DOI: 10.2337/dc21-S005]",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(text: "Not available for Hiligaynon");
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(
          //     left: 10,
          //     right: 10,
          //     bottom: 10,
          //   ),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(10),
          //     color: Colors.white,
          //     boxShadow: const [
          //       BoxShadow(
          //         color: Color(0xFF7F7A7A),
          //         offset: Offset(2, 2),
          //         spreadRadius: 1,
          //       )
          //     ],
          //   ),
          //   child: ListTile(
          //     title: Text(
          //       "Type 1 DM Treatments",
          //       style: GoogleFonts.istokWeb(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 24,
          //       ),
          //     ),
          //     tileColor: Colors.white,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     subtitle: Text.rich(
          //       () {
          //         TextSpan text;

          //         if (_lang == Language.english) {
          //           text = const TextSpan(
          //             children: [
          //               WidgetSpan(child: SizedBox(height: 20)),
          //               TextSpan(text: "● Insulin Injections\n"),
          //               TextSpan(text: "● Use of an insulin pump\n"),
          //               TextSpan(text: "● Routine blood sugar monitoring\n"),
          //               TextSpan(text: "● Carbohydrate counting\n"),
          //               TextSpan(text: "● Islet cell or pancreas transplant"),
          //             ],
          //           );
          //         } else {
          //           text = const TextSpan(
          //             children: [
          //               TextSpan(
          //                   text:
          //                       "Ini isa ka pangmatag-ang kahimtangan sa panglawas nga nagakilala sa pagtaas sang level sang glucose (asukar) sa dugo. Ini nangin realidad ukon bangud ang lawas indi nagahimo sang bastante nga insulin, isa ka hormon nga nagaregulate sang asukar sa dugo, ukon bangud ang mga selula sang lawas indi maayo nga nagaresponde sa insulin."),
          //             ],
          //           );
          //         }

          //         return text;
          //       }(),
          //       textAlign: TextAlign.justify,
          //       style: const TextStyle(
          //         fontSize: 16,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ),
          // Container(
          //   margin: const EdgeInsets.only(
          //     left: 10,
          //     right: 10,
          //     bottom: 10,
          //   ),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(10),
          //     color: Colors.white,
          //     boxShadow: const [
          //       BoxShadow(
          //         color: Color(0xFF7F7A7A),
          //         offset: Offset(2, 2),
          //         spreadRadius: 1,
          //       )
          //     ],
          //   ),
          //   child: ListTile(
          //     title: Text(
          //       "Type 2 DM Treatments",
          //       style: GoogleFonts.istokWeb(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 24,
          //       ),
          //     ),
          //     tileColor: Colors.white,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     subtitle: Text.rich(
          //       () {
          //         TextSpan text;

          //         if (_lang == Language.english) {
          //           text = const TextSpan(
          //             children: [
          //               WidgetSpan(child: SizedBox(height: 20)),
          //               TextSpan(
          //                   text: "● Dietary and lifestyle modifications\n"),
          //               TextSpan(text: "● Blood sugar monitoring\n"),
          //               TextSpan(text: "● Oral diabetic medications\n"),
          //               TextSpan(text: "● Insulin"),
          //             ],
          //           );
          //         } else {
          //           text = const TextSpan(
          //             children: [
          //               TextSpan(
          //                   text:
          //                       "Ini isa ka pangmatag-ang kahimtangan sa panglawas nga nagakilala sa pagtaas sang level sang glucose (asukar) sa dugo. Ini nangin realidad ukon bangud ang lawas indi nagahimo sang bastante nga insulin, isa ka hormon nga nagaregulate sang asukar sa dugo, ukon bangud ang mga selula sang lawas indi maayo nga nagaresponde sa insulin."),
          //             ],
          //           );
          //         }

          //         return text;
          //       }(),
          //       textAlign: TextAlign.justify,
          //       style: const TextStyle(
          //         fontSize: 16,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7A7A),
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Frequently Asked Questions (FAQ)",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text.rich(
                () {
                  TextSpan text;

                  if (_lang == Language.english) {
                    text = const TextSpan(
                      children: [
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text: "1. What if I forgot my insuling shots?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Missing insulin doses can lead to high blood sugar levels, increasing the risk of complications. It's crucial to adhere to the prescribed insulin regimen. If you've forgotten your insulin shot, it's important to take it as soon as you remember. However, consult your healthcare provider for specific advice, as individual circumstances can vary. Regularly monitoring blood sugar levels is crucial, and if in doubt, seek professional medical guidance.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Glycemic Targets: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S73-S84. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "2. What if I consume a large amount of sugary food in one sitting?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Monitor your blood sugar levels to assess the impact of the sugary food on your glucose levels and drink water to help flush out excess sugar from your system.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Nutrition Therapy: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S98-S110. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "3. What if I engage in intense physical activity without adjusting my insulin dose?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Exercise can lower blood sugar levels, and failure to adjust insulin may result in hypoglycemia. Monitoring and adjusting insulin accordingly are essential.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Physical Activity/Exercise: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S102-S111. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "4. What if I experience persistent high blood sugar levels despite medication adherence?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Consultation with a healthcare professional is crucial to adjust the treatment plan and identify potential reasons for uncontrolled blood sugar.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Medication Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S98-S110. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "5. What if I skip regular blood glucose monitoring?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Regular monitoring is vital for understanding how lifestyle choices affect blood sugar levels. Skipping monitoring can lead to difficulties in managing diabetes effectively.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Self-Monitoring of Blood Glucose in Non-Insulin-Treated Type 2 Diabetes: It Is Time to Reassess. Diabetes Care, 44(Supplement 1), S111-S118. [DOI: 10.2337/dc21-S007]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "6. What if my doctor prescribed a new medication and I experience side effects?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "It's crucial to communicate any side effects to the healthcare provider to explore alternative medications or adjust the treatment plan. Inform your doctor about the specific side effects you are experiencing. This allows them to assess the severity and determine the appropriate course of action.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Medication Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S98-S110. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text: "7. What is I acquire a foot injury?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Immediate attention to foot injuries is crucial due to the increased risk of complications in people with diabetes. If you have a minor cut or abrasion, clean it gently with mild soap and water. Avoid using hot water. Pat the area dry and apply an antiseptic ointment. Cover the wound with a clean, sterile dressing. Avoid tight bandages that might restrict blood flow. Consultation with a healthcare professional is necessary.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Microvascular Complications and Foot Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S151-S167. [DOI: 10.2337/dc21-S009]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "8. What if I have difficulty remembering to check my blood sugar regularly?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Set reminders, establish a routine, and use technology or apps to help track and manage blood sugar levels.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Self-Monitoring of Blood Glucose in Non-Insulin-Treated Type 2 Diabetes: It Is Time to Reassess. Diabetes Care, 44(Supplement 1), S111-S118. [DOI: 10.2337/dc21-S007]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "9. What if I forget to take my diabetes medication?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Take it as soon as you remember, but if it's close to the next dose, consult your healthcare provider.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Medication Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S98-S110. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "10. What if I have concerns about alcohol consumption with diabetes?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Limit alcohol intake, monitor blood sugar levels, and consult with your healthcare provider for personalized advice.\n"),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Lifestyle Management: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S67-S76. [DOI: 10.2337/dc21-S005]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "11. Why is it so hard to keep my blood sugar levels steady, even when I'm following my plan?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Balancing food, medication, and daily life can be tricky. Factors like stress, unexpected events, or even hormonal changes can affect blood sugar. It's important to communicate these challenges with my healthcare team for adjustments and support."),
                        TextSpan(
                          text:
                              "\nReference: American Diabetes Association. (2021). Psychosocial Care: Standards of Medical Care in Diabetes—2021. Diabetes Care, 44(Supplement 1), S165-S174. [DOI: 10.2337/dc21-S011]\n",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "1. Paano kung nalipatan mo mag-turok sang imo insulin?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "kung nalimtan mo mag-turok sang imo insulin ini pwede magahantong sa pagtaas sang imo asukal sa dugo, kung diin madamo ng komplikasyon ang pwide matabo. Importante gid na sundon ang tama nga oras sang pag-turok sang insulin, kag kung nalipatan mo importante gid nga mag-turok ka insigida kung madomduman mo. Importante gid nga mag-konsulta sa imo nga doctor kung may ara ka nga ginabatyag. kinanglan permi naton gina bantayan ang lebel sang asukal sa aton nga dugo kag kung ga duwa duwa kita dapat magkadto gid kita sa doktor insigida.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "2. Paano kung napadamo ang imo pagkaon sang matam'is?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Dapat bantayan mo ang asukal sa imo dugo matapos mo magkaon sang madamo ng matam'is nga pagkaon agod mabal'an mo ang epekto sini. kag mag-inom sang madamo ng tubig.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "3. Paano kung naga intra o nagahimo ikaw sang grabe nga mga aktibidad bisan wala mo gina adjust imo insulin dose?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Ang pag-ehersisyo makabulig gid sa pagpanubo sang aton blood sugar levels kag ang indi naton pagadjust sang insulin dose ta, magaresulta ini sa hypoglycemia ukon grabe nga pagnubo sang aton sugar. Gani, importante gid pagmonitor kag pag adjust sang aton insulin sang insakto.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "4. Paano kung sunod-sunod ukon padayon ka nga nagaka eksperyensya/nagakaagi sang taas nga blood sugar biskan ginasunod mo man inom sang bulong?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Ang pagkonsulta sa isa ka doktor o healthcare professional importante gid agudto ma adjust ang treatment plan kag mahibaloan ang posible nga mga rason para sa indi ma kontrol nga blood sugar.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "5. Paano kung nalipat ikaw ukon naglak-ang ka sa regular nga pagmonitor sang imo nga blood sugar?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Importante gid ang regular nga pagmonitor sa paghibalo kung paano maka apekto ang lifestyle choices sa aton nga blood sugar levels. Ang paglak-ang sa pagmonitor sini, posible nga mas makapabudlay sa aton sa epektibo nga pagbulong sang aton diabetes.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "6. Paano kung naghatag sang bag o nga preskribo nga bulong ang imo doktor kg nagaka eksperyensa ka sang mga epekto sini?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Importante gid nga mag istorya kita sa atun doktor angot sa aton gina eksperyensa nga mga epekto sang bulong agud makapangita sang mga alternatibo nga bulong ukon e adjust ang plano nga pagbulong sa aton. E inpormar ang imo nga doktor sa mga spesipiko nga epekto sang bulong nga imo ginaka eksperyensa. Maka bulig ini sa ila para ma bal an kung ano ang dapat nila nga himuon para sa imo gina eksperyensa.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "7. Paano kung ang tawo nga may diabetes mayara sang injury sa siki?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Importante gid nga ma aksyunan dayun ang injury sa siki kay ini naga pataas sang kadelikado rason nga maga lala ukon magka komplikasyon para sa mga tawo nga maydiabetes. Kung mayara ikaw nga mga samad bisan gamay lang,limpyuhi inisang indi maisog nga sabon kg tubig. Indi maggamit sang mainit nga tubig. Pahiri ang samay agud magmala kg magbutang sang antiseptic ointment. Tabuni ang samad sang malimpyo nga dressing. Iwasi ang mga hugot nga bandages nga maga pugong sang pag daloy sang dugo. Ang pag konsulta sa doktor importante kg kilangnan gid.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "8. Paano kung nabudlayan ukon naga kalipatka nga mag check regular sang imo blood sugar?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Mag set sang reminder, mag ubra sang routina kag maggamit sang teknolohiya or apps para makabulig track kag maneho sang imo blood sugar level.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "9. Paano kung nagakalipat ka nga mag tumar sang imo bulong sa diabetes?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Tumara ang bulong sa oras nga matandaan mo ini, pero kung ang oras malapit nalang sa ika duha mo nga inom sang bulong, mag konsulta na sa healthcare probayder.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "10. Paano kung indi mo ma kontrol o nabudlayan mag kontrol sang pag inom sang beer?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Limitahan lang ang pag inom sang beer o magkonsulta sa doktor agud matagaan sang intsakto nga himuon para sa imo gina ekperyensa.\n"),
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text:
                              "11. Ngaman nabudlayan ako maintenahon ang akon blood sugar level bisan gasunod ako sa plano?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Ang pagbalanse sa atun mga ginakaon, paginom sang bulong, kag pagkontrol sa adlaw-adlaw nga ginahimo ay mabudlay gid ubrahon. Ang mga sanhi kagaya ng istress, mga gakatabo sa atun kabuhi na indi ginepektar, kag imbalanse sa hormon ay makaapekto sa pagtaas ng atun blood sugar. Importante magkonsulta sa doktor agud matagaan sang intsakto nga himuon para sa imong mga palaligban."),
                      ],
                    );
                  }

                  return text;
                }(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
