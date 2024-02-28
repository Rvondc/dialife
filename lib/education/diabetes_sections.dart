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
                                "It is a chronic medical condition characterized by elevated levels of blood glucose (sugar). This occurs either because the body does not produce enough insulin, a hormone that regulates blood sugar, or because the body's cells do not respond effectively to insulin.")
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
                                """This type occurs when the immune system mistakenly attacks and destroys the insulin-producing beta cells in the pancreas. People with Type 1 diabetes need to take insulin regularly to manage their blood sugar levels."""),
                        TextSpan(
                          text: "\n\nB. Type 2 Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """This is the most common form of diabetes, typically developing in adulthood. In Type 2 diabetes, the body doesn't use insulin properly, and over time, it may not produce enough insulin. Lifestyle factors, genetics, and obesity are often associated with the development of Type 2 diabetes."""),
                        TextSpan(
                          text: "\n\nC. Gestational Diabetes: \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                """This type occurs during pregnancy when the body cannot produce enough insulin to meet the increased demands. It usually resolves after childbirth, but women who have had gestational diabetes are at an increased risk of developing Type 2 diabetes later in life."""),
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
                    text = TextSpan(
                      children: [
                        const TextSpan(
                          text: "\nA. Blood Test for Diabetes Mellitus \n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Fast Glucose Test ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "measures your blood sugar through fasting or not eating or drinking (except water) for a certain period before the actual monitoring. To screen for diabetes in patients recently admitted to hospitals care centers. It is part of annual screening in primary care.\n\n"),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Random Glucose Test ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "measures your blood sugar through fasting or not eating or drinking (except water) for a certain period before the actual monitoring. To screen for diabetes in patients recently admitted to hospitals care centers. It is part of annual screening in primary care.\n\n"),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Hemoglobin A1C Test ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "measures the amount of glycosylation of normal hemoglobin A, and it correlates with the average blood glucose levels over the past 2 to 3 months.\n\n"),
                        const WidgetSpan(child: SizedBox(width: 30)),
                        const TextSpan(
                          text: "Glucose Tolerance Test ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(
                            text:
                                "measures your blood sugar before and after drinking a sweetened liquid called Glucola.\n"),
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
                          text: "\n1. Exercise regularly - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Exercise increases the insulin sensitivity of your cells, meaning that you need less insulin to manage your blood sugar levels.\n\n"),
                        TextSpan(
                          text: "2. Drink water as your primary beverage - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Sugary beverages like soda and sweetened fruit juice have been linked to an increased risk of both type 2 diabetes and latent autoimmune diabetes of adults.\n\n"),
                        TextSpan(
                          text: "3. Eat healty plant foods - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Plants provide vitamins, minerals and carbohydrates in your diet.\n\n"),
                        TextSpan(
                          text: "4. Quit smoking - ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                "Smoking is just one risk factor for increased risk of diabetes. The more often someone smokes, the higher their risk."),
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
                                "These are long-term problems that can develop gradually, and can lead to serious damage if they go unchecked and untreated.\n"),
                        WidgetSpan(
                          child: Image.asset(
                            "assets/eye_problems.png",
                          ),
                        ),
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: "● Eye Problems - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Some people with diabetes develop an eye disease called diabetic retinopathy which can affect their eyesight. If retinopathy is picked up, usually from an eye screening test, it can be treated and sight loss prevented.\n"),
                          ],
                        ),
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
                                    "Diabetes foot problems are serious and can lead to amputation if untreated. Nerve damage can affect the feeling in your feet and raised blood sugar can damage the circulation, making it slower for sores and cuts to heal.\n\n"),
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
                                    "When you have diabetes, high blood sugar for a period of time can damage your blood vessels. This can sometimes lead to heart attacks and strokes.\n\n"),
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
                                    "Diabetes can cause damage to your kidneys over a long period of time making it harder to clear extra fluid and waste from your body. This is caused by high blood sugar levels and high blood pressure. It is known as diabetic nephropathy or kidney disease.\n\n"),
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
                                    "Some people with diabetes may develop nerve damage caused by complications of high blood sugar levels. This can make it harder for the nerves to carry messages between the brain and every part of our body so it can affect how we see, hear, feel and move.\n\n"),
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
                    text = const TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "● Hypoglycemia - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "When your blood sugars are too low.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "● Hyperglycemia - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "When your blood sugars are too high.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "● Hyperosmolar Hyperglycaemic State (HHS) - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "A life-threatening emergency that only happens in people with type 2 diabetes. It’s brought on by severe dehydration and very high blood sugars.\n\n"),
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
                                    "A life-threatening emergency where the lack of insulin and high blood sugars leads to a build-up of ketones."),
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
                              text: "\n1. Educate the patient - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Education on diabetes is critical. Inform the patients about their treatment options. Patients who understand how diet, stress, medications, and exercise affect their glucose levels can make informed choices.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "2. Maintain ideal glucose level - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Maintain HbA1c under 7% and blood sugar levels between 90 and 130 mg/dL. Long-term glucose control is the best way to prevent complications.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "3. Educate on oral diabetes medications - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Patients with type 2 diabetes, prediabetes, and gestational diabetes benefit the most from oral diabetic medications.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "4. Expect some differences in treatment for type 1 and 2 DM - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Depending on the kind of diabetes patients have, the treatment plan may include oral medications, insulin, and blood sugar monitoring.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "5. Assist the patient in meal planning - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Diabetes requires adhering to a diabetic diet; reducing carbohydrates, processed foods, and sugar. The patient may need education on how carbohydrates (pasta, bread, rice) become glucose once digested. Instruct on increasing fruits, vegetables, lean proteins, and whole grains.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "6. Promote physical activities - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Diabetes requires adhering to a diabetic diet; reducing carbohydrates, processed foods, and sugar. The patient may need education on how carbohydrates (pasta, bread, rice) become glucose once digested. Instruct on increasing fruits, vegetables, lean proteins, and whole grains.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "7. Coordinate with a diabetes nurse educator - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "Diabetes educators specialize in teaching people with diabetes how to manage their condition. The diabetes educator can educate those with diabetes and their family and caregivers on effectively managing DM.\n\n"),
                          ],
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "8. Enlighten the patient about mouth care - ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text:
                                    "The chance of severe gum infections may increase in diabetes. Advise the patient to floss and brush their teeth at least twice daily and plan routine dental exams.\n\n"),
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
                )
              ],
            ),
            child: ListTile(
              title: Text(
                "Type 1 DM Treatments",
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
                        WidgetSpan(child: SizedBox(height: 20)),
                        TextSpan(text: "● Insulin Injections\n"),
                        TextSpan(text: "● Use of an insulin pump\n"),
                        TextSpan(text: "● Routine blood sugar monitoring\n"),
                        TextSpan(text: "● Carbohydrate counting\n"),
                        TextSpan(text: "● Islet cell or pancreas transplant"),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
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
                "Type 2 DM Treatments",
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
                        WidgetSpan(child: SizedBox(height: 20)),
                        TextSpan(
                            text: "● Dietary and lifestyle modifications\n"),
                        TextSpan(text: "● Blood sugar monitoring\n"),
                        TextSpan(text: "● Oral diabetic medications\n"),
                        TextSpan(text: "● Insulin"),
                      ],
                    );
                  } else {
                    text = const TextSpan(
                      children: [
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
                        WidgetSpan(child: SizedBox(height: 30)),
                        TextSpan(
                          text: "7. What is I acquire a foot injury?\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(child: SizedBox(width: 30)),
                        TextSpan(
                            text:
                                "Immediate attention to foot injuries is crucial due to the increased risk of complications in people with diabetes. If you have a minor cut or abrasion, clean it gently with mild soap and water. Avoid using hot water. Pat the area dry and apply an antiseptic ointment. Cover the wound with a clean, sterile dressing. Avoid tight bandages that might restrict blood flow. Consultation with a healthcare professional is necessary.\n"),
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
