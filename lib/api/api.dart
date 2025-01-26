import 'dart:convert';

import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/chat/entities.dart';
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

  static Future<void> revokeDoctor(int id) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return;
    }

    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);
    final user = User.fromMap((await db.query("User")).first);

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    if (_https) {
      final response = await http.post(
        Uri.https(_baseUrl, '$_basePath/patient/revoke'),
        body: jsonEncode({
          "patient_id": user.webId,
          "doctor_id": id,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      final response = await http.post(
        Uri.http(_baseUrl, '$_basePath/patient/revoke'),
        body: jsonEncode({
          "patient_id": user.webId,
          "doctor_id": id,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
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
      final response = await http.get(
          Uri.https(_baseUrl, '$_basePath/patient/doctors/get/${user.webId}'));

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIDoctor.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
    } else {
      final response = await http.get(
          Uri.http(_baseUrl, '$_basePath/patient/doctors/get/${user.webId}'));

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final body = jsonDecode(response.body);

      return APIDoctor.fromListOfMaps(
          (body as List<dynamic>).cast<Map<String, dynamic>>());
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

  static Future<bool> chatExistsWith(APIDoctor doctor) async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = User.fromMap((await db.query("User")).first);

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return false;
    }

    if (_https) {
      final response = await http.get(
        Uri.https(
          _baseUrl,
          '$_basePath/doctor/chat/getid/${doctor.doctorId}/${user.webId}',
        ),
      );

      if (response.statusCode == 404) {
        return false;
      } else if (response.statusCode == 200) {
        return true;
      }

      throw Exception("Invalid Response: ${response.body}");
    } else {
      final response = await http.get(
        Uri.http(
          _baseUrl,
          '$_basePath/doctor/chat/getid/${doctor.doctorId}/${user.webId}',
        ),
      );

      if (response.statusCode == 404) {
        return false;
      } else if (response.statusCode == 200) {
        return true;
      }

      throw Exception("Invalid Response: ${response.body}");
    }
  }

  static Future<void> sendMessageTo(APIDoctor doctor, String message) async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final user = User.fromMap((await db.query("User")).first);

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    if (_https) {
      final response = await http.get(
        Uri.https(
          _baseUrl,
          '$_basePath/doctor/chat/getid/${doctor.doctorId}/${user.webId}',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final connectionId =
          int.parse(jsonDecode(response.body)['chat_connection_id']);

      http.post(
        Uri.https(_baseUrl, '$_basePath/message/send/$connectionId'),
        body: jsonEncode({
          'sender_type': 'patient',
          'sender_id': user.webId,
          'content': message,
        }),
      );
    } else {
      final response = await http.get(
        Uri.http(
          _baseUrl,
          '$_basePath/doctor/chat/getid/${doctor.doctorId}/${user.webId}',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final connectionId =
          int.parse(jsonDecode(response.body)['chat_connection_id']);

      http.post(
        Uri.http(_baseUrl, '$_basePath/message/send/$connectionId'),
        body: jsonEncode({
          'sender_type': 'patient',
          'sender_id': user.webId,
          'content': message,
        }),
      );
    }
  }

  static Future<List<ChatMessage>> getChatLog(
    User user,
    APIDoctor doctor,
  ) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    if (_https) {
      final response = await http.get(
        Uri.https(
          _baseUrl,
          '$_basePath/doctor/chat/getid/${doctor.doctorId}/${user.webId}',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final connectionId =
          int.parse(jsonDecode(response.body)['chat_connection_id']);

      final messages = await http.get(
        Uri.https(
          _baseUrl,
          '$_basePath/message/get/$connectionId',
        ),
      );

      final chatMessages = (jsonDecode(messages.body) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ChatMessage.fromMap);

      return chatMessages.toList();
    } else {
      final response = await http.get(
        Uri.http(
          _baseUrl,
          '$_basePath/doctor/chat/getid/${doctor.doctorId}/${user.webId}',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      final connectionId =
          int.parse(jsonDecode(response.body)['chat_connection_id']);

      final messages = await http.get(
        Uri.http(
          _baseUrl,
          '$_basePath/message/get/$connectionId',
        ),
      );

      final chatMessages = (jsonDecode(messages.body) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ChatMessage.fromMap);

      return chatMessages.toList();
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

      return jsonDecode(response.body)["web_id"];
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
