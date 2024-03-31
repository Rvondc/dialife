import 'dart:convert';

import 'package:dialife/api/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sqflite/sqflite.dart';

class MonitoringAPI {
  // NOTE: Private constructor
  MonitoringAPI._();

  static late final bool _https;
  static late final String _baseUrl;
  static const String _basePath = "/dialife-api";

  static void init({
    bool https = false,
    String baseUrl = "10.0.2.2:8080",
  }) {
    _https = https;
    _baseUrl = baseUrl;
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

  static Future<void> recordSyncAll(
      List<APIPatientRecordUploadable> records) async {
    if (records.isEmpty) {
      return;
    }

    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      return;
    }

    if (_https) {
      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/patient/record/syncall',
        ),
        body: jsonEncode({
          "patient_id": records.first.patientId,
          "records": records.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    } else {
      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/patient/record/syncall',
        ),
        body: jsonEncode({
          "patient_id": records.first.patientId,
          "records": records.map((record) => record.toApiInsertable()).toList(),
        }),
      );

      // var logger = Logger(
      //   filter: null,
      //   printer: PrettyPrinter(),
      //   output: null,
      // );

      // logger.d(
      //   jsonEncode({
      //     "patient_id": records.first.patientId,
      //     "records": records.map((record) => record.toApiInsertable()).toList(),
      //   }),
      // );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
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

  static Future<void> syncPatientState(User user) async {
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
          '$_basePath/patient/sync',
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
          '$_basePath/patient/sync',
        ),
        body: jsonEncode(user.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }
    }
  }

  static Future<int> createPatient(User user) async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (!isConnected) {
      throw Exception("No internet");
    }

    if (_https) {
      final response = await http.post(
        Uri.https(
          _baseUrl,
          '$_basePath/patient/create',
        ),
        body: jsonEncode(user.toApiInsertable()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      return jsonDecode(response.body)["web_id"];
    } else {
      // if (user.webId != null) {
      //   throw Exception("Patient already exists in Monitoring API");
      // }

      final response = await http.post(
        Uri.http(
          _baseUrl,
          '$_basePath/patient/create',
        ),
        body: jsonEncode(user.toApiInsertable()),
      );

      if (response.statusCode != 200) {
        throw Exception("Status Code not OK: ${response.body}");
      }

      return jsonDecode(response.body)["web_id"];
    }
  }
}
