import 'dart:io';

import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class LabResults extends StatefulWidget {
  const LabResults({super.key});

  @override
  State<LabResults> createState() => _LabResultsState();
}

class _LabResultsState extends State<LabResults> {
  bool _isLoading = true;
  bool _hasInternet = false;
  List<APILabRequest> _requests = [];

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

      final requests = await MonitoringAPI.getLabRequests();

      setState(() {
        _isLoading = false;
        _requests = requests;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Requests"),
        backgroundColor: Colors.grey.shade50,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final requests = await MonitoringAPI.getLabRequests();

            await Future.delayed(const Duration(milliseconds: 500));

            setState(() {
              _requests = requests;
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Image.asset('assets/pp_banner_lab_results.png'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 24,
                      ),
                      hintText: 'Search by file name',
                      isDense: true,
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: fgColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(fgColor),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Loading your lab results...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This may take a moment',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        if (_hasInternet) {
                          if (_requests.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.science_outlined,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No lab results found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Your Lab Results',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _requests.length,
                                itemBuilder: (context, index) {
                                  final request = _requests[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: request.submission != null
                                          ? BorderSide(
                                              color: Colors.green.shade300,
                                              width: 1.5)
                                          : BorderSide.none,
                                    ),
                                    color: request.submission != null
                                        ? Colors.green.shade50
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  request.type,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: request
                                                              .priorityLevel ==
                                                          'Urgent'
                                                      ? Colors.red.shade100
                                                      : request.priorityLevel ==
                                                              'High'
                                                          ? Colors
                                                              .orange.shade100
                                                          : Colors
                                                              .green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  request.priorityLevel,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: request
                                                                .priorityLevel ==
                                                            'Urgent'
                                                        ? Colors.red.shade800
                                                        : request.priorityLevel ==
                                                                'High'
                                                            ? Colors
                                                                .orange.shade800
                                                            : Colors
                                                                .green.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  size: 16,
                                                  color: Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Requested: ${DateFormat('MMM d, yyyy - h:mm a').format(request.createdAt)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (request.submission != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      size: 16,
                                                      color: Colors
                                                          .green.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Submitted: ${DateFormat('MMM d, yyyy - h:mm a').format(request.submission!.createdAt)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Physician: ${request.doctor.name}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (request.fastingRequired)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.breakfast_dining,
                                                    size: 16,
                                                    color:
                                                        Colors.orange.shade700,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Fasting Required',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors
                                                          .orange.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (request
                                              .clinicalIndication.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Indication:',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    request.clinicalIndication,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(height: 12),
                                          _viewSubmission(request, context),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        } else {
                          return const Text('No internet connection');
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _viewSubmission(APILabRequest request, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (request.submission != null)
          OutlinedButton.icon(
            icon: const Icon(
              Icons.visibility,
              size: 18,
            ),
            label: const Text(
              'View Submission',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (request.submission!.type == 'image') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: double.maxFinite,
                        constraints:
                            const BoxConstraints(maxWidth: 600, maxHeight: 600),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.science_outlined,
                                      color: fgColor, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Lab Result',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    "${MonitoringAPI.baseUrl}/storage/${request.submission!.filePath}",
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(fgColor),
                                              strokeWidth: 3,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Loading image...',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.error_outline,
                                                  color: Colors.red, size: 48),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Unable to load image',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'The image could not be loaded at this time',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.file_download,
                                        size: 16),
                                    label: const Text('Download'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: fgColor,
                                      side: const BorderSide(color: fgColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final dio = Dio();
                                      final url =
                                          "${MonitoringAPI.baseUrl}/storage/${request.submission!.filePath}";
                                      const docs =
                                          "storage/emulated/0/Download";
                                      final fileName =
                                          "${request.type}-${request.createdAt.year}-${request.createdAt.month}-${request.createdAt.day}.${request.submission!.filePath.split('.').last}";
                                      final savePath = "$docs/$fileName";

                                      // Show downloading progress notification
                                      if (!context.mounted) return;
                                      final downloadingSnackBar =
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Downloading file...'),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 30),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );

                                      try {
                                        await dio.download(url, savePath);

                                        // Dismiss the downloading snackbar
                                        downloadingSnackBar.close();

                                        if (!context.mounted) return;
                                        Navigator.pop(context);

                                        // Show options after download completes
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            final fileType = fileName
                                                .split('.')
                                                .last
                                                .toLowerCase();
                                            IconData fileIcon =
                                                Icons.insert_drive_file;

                                            if (['jpg', 'jpeg', 'png', 'gif']
                                                .contains(fileType)) {
                                              fileIcon = Icons.image;
                                            } else if (fileType == 'pdf') {
                                              fileIcon = Icons.picture_as_pdf;
                                            }

                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.file_download_done,
                                                      color: Colors.green,
                                                      size: 24),
                                                  SizedBox(width: 8),
                                                  Text('Download Complete'),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Icon(fileIcon,
                                                        color: fgColor,
                                                        size: 48),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'File saved to Downloads',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    fileName,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton.icon(
                                                  icon: const Icon(
                                                      Icons.visibility,
                                                      size: 16),
                                                  label: const Text('View'),
                                                  style: TextButton.styleFrom(
                                                      foregroundColor: fgColor),
                                                  onPressed: () {
                                                    Navigator.pop(context);

                                                    OpenFile.open(savePath)
                                                        .then((result) {
                                                      if (result.type ==
                                                          ResultType.error) {
                                                        if (!context.mounted) {
                                                          return;
                                                        }

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Error opening file: ${result.message}'),
                                                            backgroundColor:
                                                                Colors.red,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    });

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            'Opening file...'),
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                TextButton.icon(
                                                  icon: const Icon(Icons.close,
                                                      size: 16),
                                                  label: const Text('Close'),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } catch (e) {
                                        downloadingSnackBar.close();
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Download failed: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text('Close'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: fgColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: double.maxFinite,
                        constraints:
                            const BoxConstraints(maxWidth: 600, maxHeight: 400),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.description_outlined,
                                      color: fgColor, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Lab Result Document',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.description_outlined,
                                      size: 64,
                                      color: fgColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      request.type,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Document is ready for download',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.file_download,
                                          size: 18),
                                      label: const Text('Download Document'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: fgColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final url =
                                            "${MonitoringAPI.baseUrl}/storage/${request.submission!.filePath}";
                                        const docs =
                                            "storage/emulated/0/Download";
                                        final savePath =
                                            "$docs/${request.type}-${request.createdAt.year}-${request.createdAt.month}-${request.createdAt.day}.pdf";

                                        final dio = Dio();
                                        // Show a loading indicator while downloading
                                        final downloadingSnackBar =
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Downloading document...'),
                                              ],
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );

                                        try {
                                          await Future.wait([
                                            dio.download(url, savePath),
                                            Future.delayed(
                                              const Duration(seconds: 2),
                                            ),
                                          ]);

                                          // Close the downloading snackbar
                                          downloadingSnackBar.close();

                                          // Show success dialog with view option
                                          if (!context.mounted) return;
                                          Navigator.pop(context);

                                          OpenFile.open(savePath);
                                        } catch (e) {
                                          // Close the downloading snackbar
                                          downloadingSnackBar.close();

                                          // Show error message
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Download failed: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        }
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade700,
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.file_upload, size: 18),
            label: const Text('Submit Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: fgColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (BuildContext context) {
                  return _pullUpMethod(
                    context,
                    request.id,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  SafeArea _pullUpMethod(BuildContext context, int requestId) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_copy, color: fgColor),
              title: const Text('Upload document'),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                );

                if (!context.mounted) return;
                Navigator.pop(context);

                if (result != null) {
                  final file = result.files.first;

                  if (!context.mounted) return;

                  // Show a dialog with file preview
                  showDialog(
                    context: context,
                    builder: (context) {
                      Widget previewWidget;

                      // Determine the preview based on file type
                      final extension = file.extension?.toLowerCase() ?? '';

                      if (extension == 'pdf') {
                        previewWidget = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.picture_as_pdf,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 10),
                            const Text('PDF Document'),
                            Text(
                              '(${(file.size / 1024).toStringAsFixed(2)} KB)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
                        if (file.bytes != null) {
                          // For web or when bytes are available
                          previewWidget = Image.memory(
                            file.bytes!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Unable to preview this image'),
                              );
                            },
                          );
                        } else if (file.path != null) {
                          // For mobile platforms
                          previewWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(file.path!),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text('Unable to preview this image'),
                                );
                              },
                            ),
                          );
                        } else {
                          previewWidget = const Center(
                            child: Text('Unable to preview this file'),
                          );
                        }
                      } else {
                        previewWidget = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file,
                                size: 60, color: Colors.blue),
                            const SizedBox(height: 10),
                            Text('File: ${file.name}'),
                            Text(
                              '(${(file.size / 1024).toStringAsFixed(2)} KB)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Row(
                          children: [
                            Icon(Icons.file_present, color: fgColor, size: 24),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'File Preview',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        content: Container(
                          width: double.maxFinite,
                          height: 350,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${(file.size / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Center(child: previewWidget),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: fgColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload, size: 18),
                            label: const Text('Upload'),
                            onPressed: () async {
                              Navigator.pop(context);

                              final controller =
                                  ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Uploading ${file.name}...'),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );

                              await MonitoringAPI.uploadLabResult(
                                requestId,
                                File(file.path!),
                              );

                              controller.close();

                              final requests =
                                  await MonitoringAPI.getLabRequests();

                              setState(() {
                                _requests = requests;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fgColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                        actionsPadding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
