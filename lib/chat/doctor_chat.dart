import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/chat/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DoctorChat extends StatelessWidget {
  final APIDoctor doctor;
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();

  DoctorChat({
    super.key,
    required this.doctor,
  });

  Stream<(bool, List<ChatMessage>)> _getChatStream() async* {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = User.fromMap((await db.query("User")).first);

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final messages = await MonitoringAPI.getChatLog(user, doctor);
    yield (true, messages);

    var lastLength = messages.length;

    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final messages = await MonitoringAPI.getChatLog(user, doctor);

      yield (lastLength != messages.length, messages);

      lastLength = messages.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 179, 209, 251),
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 44,
              width: 44,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: FadeInImage.assetNetwork(
                  image: MonitoringAPI.baseUrl + doctor.profilPictureLink,
                  placeholder: "assets/default.jpg",
                  fadeOutCurve: Easing.emphasizedAccelerate,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            AutoSizeText("Dr. ${doctor.name}"),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _getChatStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitRing(color: fgColor),
            );
          }

          final (changed, messages) = snapshot.data!;

          if (changed) {
            Future.delayed(Duration.zero, () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + 100,
                curve: Curves.easeOut,
                duration: const Duration(seconds: 1),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 64),
                  child: ListView(
                    controller: _scrollController,
                    children: messages.map((message) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: message.senderType == "doctor"
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: message.senderType == "doctor"
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 250),
                                  decoration: BoxDecoration(
                                    color: message.senderType == "doctor"
                                        ? Colors.white
                                        : fgColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(8),
                                      bottomRight:
                                          message.senderType == "doctor"
                                              ? const Radius.circular(8)
                                              : const Radius.circular(0),
                                      bottomLeft: message.senderType == "doctor"
                                          ? const Radius.circular(0)
                                          : const Radius.circular(8),
                                      topRight: const Radius.circular(8),
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    message.content,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: message.senderType == "doctor"
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM. d, yyyy h:mm a')
                                      .format(message.createdAt),
                                  style: GoogleFonts.istokWeb(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.istokWeb(color: Colors.black),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Color.fromARGB(255, 179, 209, 251),
                            filled: true,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_messageController.text.isEmpty) {
                            return;
                          }

                          await MonitoringAPI.sendMessageTo(
                            doctor,
                            _messageController.text,
                          );

                          _messageController.clear();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
