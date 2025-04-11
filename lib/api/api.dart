import 'dart:convert';
import 'dart:io';

import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sqflite/sqflite.dart';

class MonitoringAPI {
  // NOTE: Private constructor
  MonitoringAPI._();

  static late final bool _https;
  static late final String _baseUrl;
  static const String _basePath = "";

  static void init({
    bool https = false,
    String baseUrl = "10.0.2.2:8000",
  }) {
    _https = https;
    _baseUrl = baseUrl;
  }

  static String get baseUrl => "${_https ? "https://" : "http://"}$_baseUrl";

  static Future<void> revokeAccess(int doctorId) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    final user = await User.currentUser;
    
    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '$_basePath/api/patient/${user.webId}/revoke/$doctorId')
        : Uri.http(_baseUrl, '$_basePath/api/patient/${user.webId}/revoke/$doctorId');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }
  }

  static Future<List<APIAppointment>> getAppointments() async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    final user = await User.currentUser;
    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '/api/appointment/${user.webId}')
        : Uri.http(_baseUrl, '/api/appointment/${user.webId}');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return APIAppointment.fromListOfMaps(body.cast<Map<String, dynamic>>());
  }

  static Future<void> createAppointment({
    required int doctorId,
    required DateTime date,
    required TimeOfDay time,
    required Duration duration,
    required String reason,
    String? notes,
  }) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    final user = await User.currentUser;
    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '/api/appointment/$doctorId/${user.webId}/create')
        : Uri.http(_baseUrl, '/api/appointment/$doctorId/${user.webId}/create');

    final request = http.MultipartRequest('POST', uri);

    request.fields['date'] = date.toIso8601String();
    request.fields['time'] =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    request.fields['duration'] = duration.inMinutes.toString();
    request.fields['reason'] = reason;
    if (notes != null) {
      request.fields['notes'] = notes;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }
  }

  static Future<APITimeSlotSchedule> getTimeSlots(
      int doctorId, DateTime date) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '/api/appointment/$doctorId/timeslots')
        : Uri.http(_baseUrl, '/api/appointment/$doctorId/timeslots');

    final response = await http.post(
      uri,
      body: jsonEncode({'date': date.toIso8601String()}),
    );

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }

    return APITimeSlotSchedule.fromMap(jsonDecode(response.body));
  }

  static Future<APIRecoveryData> getRecoveryData(String recoveryId) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '$_basePath/api/recover/$recoveryId')
        : Uri.http(_baseUrl, '$_basePath/api/recover/$recoveryId');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }

    return APIRecoveryData.fromMap(jsonDecode(response.body));
  }

  static Future<List<APIDoctor>> getOnlineDoctors() async {
    final user = await User.currentUser;

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '$_basePath/api/online/${user.webId}/doctors')
        : Uri.http(_baseUrl, '$_basePath/api/online/${user.webId}/doctors');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return APIDoctor.fromListOfMaps(body.cast<Map<String, dynamic>>());
  }

  static Future<List<APILabRequest>> getLabRequests() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);
    final user = User.fromMap((await db.query("User")).first);

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    if (_https) {
      final response = await http.post(
        Uri.https(_baseUrl, '$_basePath/api/patient/${user.webId}/lab'),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body) as List<dynamic>;

      return APILabRequest.fromListOfMaps(body.cast());
    } else {
      final response = await http.post(
        Uri.http(_baseUrl, '$_basePath/api/patient/${user.webId}/lab'),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body) as List<dynamic>;

      return APILabRequest.fromListOfMaps(body.cast());
    }
  }

  static Future<void> pingOnline() async {
    final user = await User.currentUser;
    if (user.webId == null) {
      return;
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '$_basePath/api/online/${user.webId}/ping')
        : Uri.http(_baseUrl, '$_basePath/api/online/${user.webId}/ping');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception("Status Code not OK: ${response.body}");
    }
  }

  static Future<void> sendMessage({
    required int doctorId,
    required String messageType,
    String? textMessage,
    File? file,
  }) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet connection");
    }

    final user = await User.currentUser;
    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    // Validate inputs based on message type
    if (messageType == 'text' && textMessage == null) {
      throw Exception("Text message is required for text message type");
    }
    if ((messageType == 'image' || messageType == 'pdf') && file == null) {
      throw Exception("File is required for image or pdf message type");
    }

    final Uri uri = _https
        ? Uri.https(_baseUrl, '$_basePath/api/chat/send/$doctorId')
        : Uri.http(_baseUrl, '$_basePath/api/chat/send/$doctorId');

    dynamic response;

    if (messageType == 'text') {
      // For text messages
      final httpResponse = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': user.webId,
          'message_type': messageType,
          'message': textMessage,
        }),
      );

      if (httpResponse.statusCode != 200) {
        throw Exception("Status Code not OK: ${httpResponse.body}");
      }

      response = httpResponse;
    } else {
      // For image or PDF files
      final request = http.MultipartRequest('POST', uri);

      request.fields['patient_id'] = user.webId.toString();
      request.fields['message_type'] = messageType;
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file!.path,
      ));

      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<List<APIChatMessage>> getChatBatch(
    int doctorId, {
    int? fromMessageId,
  }) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet connection");
    }

    final patientId = (await User.currentUser).webId;

    // Convert parameters to request body
    final body = <String, dynamic>{};
    if (fromMessageId != null) {
      body['from_message_id'] = fromMessageId;
    }

    if (_https) {
      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/chat/batch/$patientId/$doctorId',
        ),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final responseBody = jsonDecode(response.body) as List<dynamic>;
      return APIChatMessage.fromListOfMaps(
          responseBody.cast<Map<String, dynamic>>());
    } else {
      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/chat/batch/$patientId/$doctorId',
        ),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final responseBody = jsonDecode(response.body) as List<dynamic>;
      return APIChatMessage.fromListOfMaps(
          responseBody.cast<Map<String, dynamic>>());
    }
  }

  static Future<List<APIDoctor>> getDoctors() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);
    final user = User.fromMap((await db.query("User")).first);

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return [];
    }

    if (_https) {
      final response = await http.post(
        Uri.https(_baseUrl, '$_basePath/api/doctors/${user.webId}/monitoring'),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIDoctor.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    } else {
      final response = await http.post(
        Uri.http(_baseUrl, '$_basePath/api/doctors/${user.webId}/monitoring'),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIDoctor.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    }
  }

  static Future<void> uploadLabResult(int requestId, File file) async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);
    final user = User.fromMap((await db.query("User")).first);

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      final request = http.MultipartRequest(
        'POST',
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/lab/result',
        ),
      );

      request.fields['request_id'] = requestId.toString();
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      final request = http.MultipartRequest(
        'POST',
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/lab/result',
        ),
      );

      request.fields['request_id'] = requestId.toString();
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> recordSyncAll() async {
    await Future.wait([
      syncBmiRecords(),
      syncActivityRecords(),
      syncMedicationRecords(),
      syncNutritionRecords(),
      syncWaterRecords(),
      syncGlucoseRecords(),
    ]);
  }

  static Future<void> uploadPatientRecord(
      APIPatientRecordUploadable record) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return;
    }

    if (_https) {
      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/patient/record/upload',
        ),
        body: jsonEncode(record.toApiInsertable()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/patient/record/upload',
        ),
        body: jsonEncode(record.toApiInsertable()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<List<APIConditionHistory>> getConditionHistory() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);
    final user = User.fromMap((await db.query("User")).first);

    if (_https) {
      final response = await http.post(Uri.https(
          _baseUrl, '$_basePath/api/patient/${user.webId}/history/condition'));

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIConditionHistory.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    } else {
      final response = await http.post(Uri.http(
          _baseUrl, '$_basePath/api/patient/${user.webId}/history/condition'));

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIConditionHistory.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    }
  }

  static Future<List<APIImmunizationHistory>> getImmunizationHistory() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);
    final user = User.fromMap((await db.query("User")).first);

    if (_https) {
      final response = await http.post(Uri.https(_baseUrl,
          '$_basePath/api/patient/${user.webId}/history/immunization'));

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIImmunizationHistory.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    } else {
      final response = await http.post(Uri.http(_baseUrl,
          '$_basePath/api/patient/${user.webId}/history/immunization'));

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIImmunizationHistory.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    }
  }

  static Future<void> syncPatientState() async {
    final user = await User.currentUser;

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return;
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/sync',
        ),
        body: jsonEncode(user.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/sync',
        ),
        body: jsonEncode(user.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> syncBmiRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = await User.currentUser;
    final bmiRecords = (await db.query("BmiRecord"))
        .map((record) => BMIRecord.fromMap(record))
        .toList();

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/bmi',
        ),
        body: jsonEncode({
          "records":
              bmiRecords.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/bmi',
        ),
        body: jsonEncode({
          "records":
              bmiRecords.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(response.body);
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> syncActivityRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = await User.currentUser;
    final activityRecords = (await db.query("ActivityRecord"))
        .map((record) => ActivityRecord.fromMap(record))
        .toList();

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/activity',
        ),
        body: jsonEncode({
          "records": activityRecords
              .map((record) => record.toApiInsertable())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/activity',
        ),
        body: jsonEncode({
          "records": activityRecords
              .map((record) => record.toApiInsertable())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(response.body);
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> syncMedicationRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = await User.currentUser;
    final medicationRecords = (await db.query("MedicationRecordDetails"))
        .map((record) => MedicationRecordDetails.fromMap(record))
        .toList();

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/medication',
        ),
        body: jsonEncode({
          "records": medicationRecords
              .map((record) => record.toApiInsertable())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/medication',
        ),
        body: jsonEncode({
          "records": medicationRecords
              .map((record) => record.toApiInsertable())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(response.body);
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> syncNutritionRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = await User.currentUser;
    final nutritionRecords = (await db.query("NutritionRecord"))
        .map((record) => NutritionRecord.fromMap(record))
        .toList();

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/nutrition',
        ),
        body: jsonEncode({
          "records": nutritionRecords
              .map((record) => record.toApiInsertable())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/nutrition',
        ),
        body: jsonEncode({
          "records": nutritionRecords
              .map((record) => record.toApiInsertable())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(response.body);
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> syncWaterRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = await User.currentUser;
    final waterRecords = (await db.query("WaterRecord"))
        .map((record) => WaterRecord.fromMap(record))
        .toList();

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/water',
        ),
        body: jsonEncode({
          "records":
              waterRecords.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/water',
        ),
        body: jsonEncode({
          "records":
              waterRecords.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(response.body);
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<void> syncGlucoseRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = await User.currentUser;
    final glucoseRecords = (await db.query("GlucoseRecord"))
        .map((record) => GlucoseRecord.fromMap(record))
        .toList();

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/glucose',
        ),
        body: jsonEncode({
          "records":
              glucoseRecords.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      if (user.webId == null) {
        throw Exception("Patient does not exist in Monitoring API");
      }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/${user.webId}/glucose',
        ),
        body: jsonEncode({
          "records":
              glucoseRecords.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(response.body);
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<(int, String)> createPatient(User user) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/api/patient/create',
        ),
        body: jsonEncode(user.toApiInsertable()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      return (
        jsonDecode(response.body)["web_id"] as int,
        jsonDecode(response.body)["recovery_id"] as String
      );
    } else {
      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/api/patient/create',
        ),
        body: jsonEncode(user.toApiInsertable()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      return (
        jsonDecode(response.body)["web_id"] as int,
        jsonDecode(response.body)["recovery_id"] as String
      );
    }
  }
}
