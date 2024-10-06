import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/doctors_appointment/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class DoctorConnections extends StatefulWidget {
  const DoctorConnections({super.key});

  @override
  State<DoctorConnections> createState() => _DoctorConnectionsState();
}

class _DoctorConnectionsState extends State<DoctorConnections> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 179, 209, 251),
      appBar: AppBar(
        title: const Text("Monitoring"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});

          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: waitForFuture(
          future: Future.wait([
            MonitoringAPI.getDoctors(),
            InternetConnection().hasInternetAccess,
            Future.delayed(const Duration(milliseconds: 200)),
          ]),
          loading: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "assets/bg.png",
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              const Center(
                child: CircularProgressIndicator(
                  color: fgColor,
                ),
              ),
            ],
          ),
          builder: (context, data) {
            if (!data[1]) {
              // NOTE: Stupid hack to get pullup to refresh working
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      "assets/bg.png",
                      opacity: const AlwaysStoppedAnimation(0.5),
                    ),
                  ),
                  ListView(),
                  Container(
                    alignment: Alignment.center,
                    child: const Text("No Internet"),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/bg.png",
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4.0,
                              spreadRadius: 0.0,
                              offset: const Offset(0.0, 4.0),
                            ),
                          ],
                        ),
                        child: Text(
                          "Doctors Who Are Currently Monitoring You:",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...(data[0] as List<APIDoctor>).map(
                        (doctor) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            height: 75,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0.0, 4.0),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Builder(builder: (context) {
                                        if (doctor.profilPictureLink.isEmpty) {
                                          return Image.asset(
                                            "assets/default.jpg",
                                          );
                                        }

                                        return FadeInImage.assetNetwork(
                                          image: MonitoringAPI.baseUrl +
                                              doctor.profilPictureLink,
                                          placeholder: "assets/default.jpg",
                                          fadeOutCurve:
                                              Easing.emphasizedAccelerate,
                                          fit: BoxFit.cover,
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: Row(
                                          children: [
                                            AutoSizeText(
                                              "Dr. ${doctor.name}",
                                              maxLines: 1,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            FutureBuilder(
                                                future: MonitoringAPI
                                                    .chatExistsWith(doctor),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return const SpinKitRing(
                                                      color: fgColor,
                                                      size: 16,
                                                      lineWidth: 2,
                                                    );
                                                  }

                                                  if (!snapshot.data!) {
                                                    return const SizedBox();
                                                  }

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                        "/monitoring/chat",
                                                        arguments: {
                                                          "doctor": doctor
                                                        },
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Icons.message_outlined,
                                                      size: 20,
                                                      color: fgColor,
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      ),
                                      Text(
                                        doctor.email,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          icon: const Icon(
                                            Icons.warning,
                                            size: 42,
                                            color: Colors.red,
                                          ),
                                          content: Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text:
                                                      "Are you sure you want to stop ",
                                                ),
                                                TextSpan(
                                                  text: "Dr. ${doctor.name} ",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const TextSpan(
                                                    text:
                                                        "from seeing your records? "),
                                                const TextSpan(
                                                  text:
                                                      "You won't be able to undo this operation.",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                )
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  color: fgColor,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();

                                                await MonitoringAPI
                                                    .revokeDoctor(
                                                  doctor.doctorId,
                                                );

                                                setState(() {});
                                              },
                                              child: const Text(
                                                "Confirm",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    size: 32,
                                    color: Colors.red.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList()
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
