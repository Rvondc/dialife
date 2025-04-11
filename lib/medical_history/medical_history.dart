import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';

class MedicalHistory extends StatefulWidget {
  const MedicalHistory({super.key});

  @override
  State<MedicalHistory> createState() => _MedicalHistoryState();
}

class _MedicalHistoryState extends State<MedicalHistory> {
  bool _hasInternet = false;
  bool _isLoading = true;
  List<APIConditionHistory> _conditionHistory = [];
  List<APIImmunizationHistory> _immunizationHistory = [];

  @override
  void initState() {
    super.initState();

    () async {
      final hasInternet = await InternetConnection().hasInternetAccess;

      setState(() {
        _hasInternet = hasInternet;
      });

      if (!hasInternet) {
        setState(() {
          _isLoading = false;
        });

        return;
      }

      final [immunizations, conditions] = await Future.wait([
        MonitoringAPI.getImmunizationHistory(),
        MonitoringAPI.getConditionHistory(),
      ]);

      setState(() {
        _isLoading = false;
        _immunizationHistory = immunizations.cast();
        _conditionHistory = conditions.cast();
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.grey.shade50,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final [immunizations, conditions] = await Future.wait([
              MonitoringAPI.getImmunizationHistory(),
              MonitoringAPI.getConditionHistory(),
            ]);

            await Future.delayed(const Duration(milliseconds: 500));

            setState(() {
              _immunizationHistory = immunizations.cast();
              _conditionHistory = conditions.cast();
            });
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/medical_history.png"),
                const SizedBox(height: 16),
                const Text(
                  "Your Medical History",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoading) ...[
                  const SizedBox(height: 40),
                  const Center(child: CircularProgressIndicator()),
                ] else if (!_hasInternet) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.signal_wifi_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "No Internet Connection",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please check your connection and try again",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final hasInternet =
                                await InternetConnection().hasInternetAccess;
                            setState(() {
                              _hasInternet = hasInternet;
                            });

                            if (!hasInternet) {
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }

                            final [immunizations, conditions] =
                                await Future.wait([
                              MonitoringAPI.getImmunizationHistory(),
                              MonitoringAPI.getConditionHistory(),
                            ]);

                            setState(() {
                              _isLoading = false;
                              _immunizationHistory = immunizations.cast();
                              _conditionHistory = conditions.cast();
                            });
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  // Conditions Section
                  _buildSectionHeader("Conditions", Icons.medical_information),
                  const SizedBox(height: 12),
                  if (_conditionHistory.isEmpty)
                    _buildEmptyState("No conditions recorded")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _conditionHistory.length,
                      itemBuilder: (context, index) {
                        final condition = _conditionHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Icon(Icons.medical_services,
                                          color: Colors.blue.shade800),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            condition.conditionName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat("MMMM d, yyyy").format(
                                                condition.diagnosisDate),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow(
                                              "Type", condition.conditionType),
                                          _buildInfoRow(
                                              "Status", condition.status),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow("Patient",
                                              condition.patient.firstName),
                                          _buildInfoRow("Patient ID",
                                              condition.patient.recoveryId),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (condition.notes != null &&
                                    condition.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Notes:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    condition.notes!,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  // Immunizations Section
                  _buildSectionHeader("Immunizations", Icons.vaccines),
                  const SizedBox(height: 12),
                  if (_immunizationHistory.isEmpty)
                    _buildEmptyState("No immunizations recorded")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _immunizationHistory.length,
                      itemBuilder: (context, index) {
                        final immunization = _immunizationHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      child: Icon(Icons.health_and_safety,
                                          color: Colors.green.shade800),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            immunization.vaccineName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat("MMMM d, yyyy").format(
                                                immunization
                                                    .administrationDate),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (immunization.doseNumber != null)
                                            _buildInfoRow("Dose",
                                                "#${immunization.doseNumber}"),
                                          if (immunization.manufacturer !=
                                                  null &&
                                              immunization
                                                  .manufacturer!.isNotEmpty)
                                            _buildInfoRow("Manufacturer",
                                                immunization.manufacturer!),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow("Patient",
                                              immunization.patient.firstName),
                                          _buildInfoRow("Patient ID",
                                              immunization.patient.recoveryId),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (immunization.notes != null &&
                                    immunization.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Notes:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    immunization.notes!,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade800),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
