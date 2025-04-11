import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class DoctorConnections extends StatefulWidget {
  const DoctorConnections({super.key});

  @override
  State<DoctorConnections> createState() => _DoctorConnectionsState();
}

class _DoctorConnectionsState extends State<DoctorConnections> {
  bool _isLoading = true;
  bool _hasInternet = false;
  List<APIDoctor> _doctors = [];
  List<APIDoctor> _onlineDoctors = [];

  @override
  void initState() {
    super.initState();

    () async {
      while (true) {
        final doctors = await MonitoringAPI.getOnlineDoctors();

        if (mounted) {
          setState(() {
            _onlineDoctors = doctors;
          });
        } else {
          break;
        }

        await Future.delayed(const Duration(seconds: 45));
      }
    }();

    () async {
      final [hasInternet, doctors] = await Future.wait([
        InternetConnection().hasInternetAccess,
        MonitoringAPI.getDoctors(),
      ]) as List<dynamic>;

      setState(() {
        _hasInternet = hasInternet;
        _doctors = doctors;
        _isLoading = false;
      });
    }();
  }

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
        child: Stack(
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
                  if (_isLoading) ...[
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (!_hasInternet) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.signal_wifi_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "No Internet Connection",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your connection and try again",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_doctors.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "No Doctors Monitoring",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You currently don't have any doctors monitoring your health data",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    ..._doctors
                        .map(
                          (doctor) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                "/monitoring/chat",
                                arguments: {"doctor": doctor},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0.0, 4.0),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.blue.shade100,
                                        backgroundImage: doctor.profileImage !=
                                                null
                                            ? NetworkImage(
                                                '${MonitoringAPI.baseUrl}/storage/${doctor.profileImage!}')
                                            : null,
                                        child: doctor.profileImage == null
                                            ? Text(
                                                doctor.name.isNotEmpty
                                                    ? doctor.name[0]
                                                    : "?",
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doctor.name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.black
                                                    .withOpacity(0.85),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              doctor.email,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _onlineDoctors
                                                  .any((d) => d.id == doctor.id)
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _onlineDoctors.any((d) =>
                                                        d.id == doctor.id)
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _onlineDoctors.any(
                                                      (d) => d.id == doctor.id)
                                                  ? "Active"
                                                  : "Inactive",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: _onlineDoctors.any((d) =>
                                                        d.id == doctor.id)
                                                    ? Colors.green.shade700
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _showDoctorDetails(doctor);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.visibility,
                                                size: 12,
                                                color: Colors.blue.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "View",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDoctorDetails(APIDoctor doctor) async {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Doctor header with gradient background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 179, 209, 251),
                      const Color.fromARGB(255, 179, 209, 251).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'doctor-${doctor.id}',
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        backgroundImage: doctor.profileImage != null
                            ? NetworkImage(
                                '${MonitoringAPI.baseUrl}/storage/${doctor.profileImage!}')
                            : null,
                        child: doctor.profileImage == null
                            ? Text(
                                doctor.name.isNotEmpty ? doctor.name[0] : "?",
                                style: GoogleFonts.montserrat(
                                  color: Colors.blue.shade700,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Medical Doctor",
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Doctor information section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Information",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 20, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              doctor.email,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Status",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _onlineDoctors.any((d) => d.id == doctor.id)
                            ? Colors.green.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _onlineDoctors.any((d) => d.id == doctor.id)
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _onlineDoctors.any((d) => d.id == doctor.id)
                                      ? Colors.green
                                      : Colors.grey,
                              boxShadow: [
                                BoxShadow(
                                  color: _onlineDoctors
                                          .any((d) => d.id == doctor.id)
                                      ? Colors.green.withOpacity(0.4)
                                      : Colors.transparent,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _onlineDoctors.any((d) => d.id == doctor.id)
                                ? "Currently Active"
                                : "Currently Inactive",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  _onlineDoctors.any((d) => d.id == doctor.id)
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          side: BorderSide(color: Colors.red.shade300),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black45,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              icon: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade600,
                                size: 48,
                              ),
                              title: Text(
                                "WARNING: Revoke Access",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to revoke ${doctor.name}'s access to your health data? This action cannot be undone.",
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () async {
                                    await MonitoringAPI.revokeAccess(doctor.id);

                                    final doctors =
                                        await MonitoringAPI.getDoctors();
                                    final online =
                                        await MonitoringAPI.getOnlineDoctors();

                                    setState(() {
                                      _onlineDoctors = online;
                                      _doctors = doctors;
                                    });

                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Access revoked for Dr. ${doctor.name}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors.grey.shade800,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "REVOKE ACCESS",
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.security_outlined,
                          size: 18,
                          color: Colors.red.shade400,
                        ),
                        label: Text(
                          "Revoke",
                          style: GoogleFonts.montserrat(
                            color: Colors.red.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              const Color.fromARGB(255, 179, 209, 251),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
