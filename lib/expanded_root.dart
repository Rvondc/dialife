import 'package:dialife/api/api.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

class ExapndedRoot extends StatelessWidget {
  final Database _db;
  final User _user;
  final Future<void> Function() _generatePdfFile;

  const ExapndedRoot({
    super.key,
    required Database db,
    required User user,
    required Future<void> Function() generatePdfFile,
  })  : _db = db,
        _user = user,
        _generatePdfFile = generatePdfFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/pp_banner_2.png'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/blood-glucose-tracking',
                            arguments: {
                              'db': _db,
                              'user': _user,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/glucose.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Glucose Records',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/medication-tracking',
                            arguments: {
                              'db': _db,
                              'user': _user,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/meds.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Medicine Reminders',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/activity-log',
                            arguments: {
                              'db': _db,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/exercise.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Activity Log',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/bmi-tracking',
                            arguments: {
                              'db': _db,
                              'user': _user,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/scale.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'BMI',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/nutrition-log',
                            arguments: {
                              'db': _db,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/fork_spoon.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nutrition Log',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/doctors-appointment/input',
                            arguments: {
                              'db': _db,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/event.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appointments',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final user = await User.currentUser;

                          if (user.webId == null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enable monitoring to use this feature.',
                                ),
                              ),
                            );

                            return;
                          }

                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed('/monitoring');
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/sos.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'My Doctors',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/education');
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/auto_stories.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Learning Material',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final user = await User.currentUser;

                          if (user.webId == null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enable monitoring to use this feature.',
                                ),
                              ),
                            );

                            return;
                          }

                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed('/lab-results');
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/biotech.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lab Results',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final user = await User.currentUser;

                          if (user.webId == null) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enable monitoring to use this feature.',
                                ),
                              ),
                            );

                            return;
                          }

                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed('/medical-history');
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/history.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Medical History',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: _generatePdfFile,
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/history.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Generate Summary',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final user = await User.currentUser;

                          if (!context.mounted) return;

                          if (user.webId != null && user.recoveryId != null) {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      'Already Connected',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your account is already synced with the monitoring service. Doctors can view your health metrics.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Text(
                                            'Recovery ID: ${user.recoveryId}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy,
                                                size: 16),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                text: user.recoveryId!,
                                              ));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Recovery ID copied to clipboard'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue[700],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Sync your account with the web!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Sync your account to the web and allow doctors to monitor your health metrics',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                  ),
                                  child: const Text(
                                    'Back',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final isConnected =
                                        await InternetConnection()
                                            .hasInternetAccess;

                                    if (!context.mounted) return;
                                    Navigator.pop(context);

                                    if (!isConnected) {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'No Internet Connection',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text(
                                            'Please check your internet connection and try again.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );

                                      return;
                                    }

                                    _showSyncDialog(context);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue[700],
                                    backgroundColor: Colors.blue[50],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Sync Now',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/history.svg',
                                    width: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Monitoring',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Help Center',
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/edit-user');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'My Profile',
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Settings',
                                style: GoogleFonts.roboto(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/logo_simp.svg',
                                width: 20,
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  Text(
                                    'About',
                                    style: GoogleFonts.roboto(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/pp_name.svg',
                                    height: 14,
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }

  Future<void> _showSyncDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Creating your account...',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: FutureBuilder(future: () async {
            try {
              final user = await User.currentUser;
              final (webId, recoveryId) =
                  await MonitoringAPI.createPatient(user);

              await _db.update(
                "User",
                {
                  "web_id": webId,
                  "recovery_id": recoveryId,
                },
                where: "id = ?",
                whereArgs: [user.id],
              );

              await MonitoringAPI.recordSyncAll();
            } catch (e) {
              if (!context.mounted) return;
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Creation Failed',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'We encountered an error while creating your account. Please try again later.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Technical details:\n${e.toString()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );

              if (!context.mounted) return;
              Navigator.pop(context);
              return;
            }
          }(), builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 24),
                  Text('Please wait...'),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Account Successfully Created',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can now sync your health data with your healthcare provider.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.blue[700],
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
