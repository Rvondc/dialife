import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ExapndedRoot extends StatelessWidget {
  const ExapndedRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                            'Emergency Hotlines',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Material(
                                elevation: 1,
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
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
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
                    const SizedBox(width: 24),
                    const Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SizedBox(),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SizedBox(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
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
                        const Divider(height: 1),
                        Padding(
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
}
