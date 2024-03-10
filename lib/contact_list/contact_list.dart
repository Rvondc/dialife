import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/contact_list/entities.dart';
import 'package:dialife/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactList extends StatefulWidget {
  const ContactList({
    super.key,
  });

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

    reset() {
      setState(() {});
    }

    return waitForFuture(
      loading: loading,
      future: getDatabasesPath(),
      builder: (context, data) {
        return waitForFuture(
          loading: loading,
          future: initAppDatabase(data),
          builder: (context, db) {
            return waitForFuture(
              loading: loading,
              future: db.query("Doctor"),
              builder: (context, data) {
                final doctors = Doctor.fromListOfMaps(data);

                return _ContanctListInternal(
                  contacts: doctors,
                  reset: reset,
                  db: db,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ContanctListInternal extends StatelessWidget {
  final List<Doctor> contacts;
  final void Function() reset;
  final Database db;

  const _ContanctListInternal({
    required this.db,
    required this.reset,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Contacts"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: fgColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          await Navigator.of(context).pushNamed(
            "/contact-list/input",
            arguments: {
              "db": db,
            },
          );

          reset();
        },
      ),
      backgroundColor: Colors.grey.shade200,
      body: () {
        if (contacts.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
              ),
              child: Text(
                "No Contacts",
                style: GoogleFonts.istokWeb(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return ListView(
          children: [
            const SizedBox(height: 5),
            ...contacts.map((contact) {
              return Dismissible(
                key: ValueKey(contact.name),
                onDismissed: (direction) async {
                  await db.delete(
                    "Doctor",
                    where: "id = ?",
                    whereArgs: [contact.id],
                  );
                },
                confirmDismiss: (direction) async {
                  final result = ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: const Text('Delete?'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );

                  return await result.closed != SnackBarClosedReason.action;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (contact.facebookId == null) {
                        return;
                      }

                      await launchUrlString(
                          "https://www.messenger.com/t/${contact.facebookId}");
                    },
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      elevation: 4,
                      child: ListTile(
                        tileColor: Colors.white,
                        dense: true,
                        contentPadding: const EdgeInsets.only(right: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        leading: Image.asset(
                          "assets/messenger_logo.png",
                          width: 48,
                        ),
                        title: AutoSizeText(
                          contact.name,
                          maxLines: 1,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: contact.phoneNumber == null ||
                                contact.phoneNumber!.isEmpty
                            ? null
                            : Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(50),
                                child: IconButton(
                                  onPressed: () async {
                                    await launchUrlString(
                                        "tel:${contact.phoneNumber}");
                                  },
                                  icon: const Icon(
                                    Icons.phone_outlined,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                              ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5),
                            AutoSizeText(
                              "Phone Number: ${contact.phoneNumber}",
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                            ),
                            AutoSizeText(
                              "Description: ${contact.description}",
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList()
          ],
        );
      }(),
    );
  }
}
