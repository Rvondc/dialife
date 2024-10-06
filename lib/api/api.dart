import 'dart:convert';

import 'package:dialife/api/entities.dart';
import 'package:dialife/chat/entities.dart';
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
        Uri.https(baseUrl, '$_basePath/message/send/$connectionId'),
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
