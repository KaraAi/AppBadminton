import 'dart:convert';
import 'dart:developer';

import 'package:badminton_management_1/bbdata/aamodel/my_learning_process.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LearningProcessApi {
  final String baseUrl = "${dotenv.env["BASE_URL"]}";
  final currentUser = MyCurrentUser();

  Future<bool> addProcess(MyLearningProcess learningProcess) async {
    try {
      final body = {
        "studentId": int.parse(learningProcess.studentId!),
        "title": learningProcess.title ?? "",
        "comment": learningProcess.comment ?? "",
        "isPublish": learningProcess.isPublish == "1" ? 1 : 0,
        "linkWebsite": learningProcess.linkWeb ?? "",
        "imagesThumb": learningProcess.imgThumb ?? "",
        "imagesPath": learningProcess.imgPath ?? "",
        "dateCreated": DateTime.now().toIso8601String(),
        "dateUpdated": DateTime.now().toIso8601String()
      };

      final res = await http
          .post(Uri.parse("$baseUrl/${dotenv.env["LEARNINGPROCESS_URL"]}"),
              headers: {
                "Authorization": "Bearer ${currentUser.key}",
                "Content-Type": "application/json"
              },
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      print("📌 Response status: ${res.statusCode}");
      print("📌 Response body: ${res.body}");
      return res.statusCode == 200 || res.statusCode == 201;

    } catch (e) {
      print("$e");
      return false;
    }
  }

  Future<bool> updateProcess(MyLearningProcess learningProcess) async {
    try {
      final body = {
        "learningProcessId": int.parse(learningProcess.id!),
        "studentId": int.parse(learningProcess.studentId!),
        "title": learningProcess.title ?? "",
        "comment": learningProcess.comment ?? "",
        "isPublish": learningProcess.isPublish == "1" ? 1 : 0,
        "linkWebsite": learningProcess.linkWeb ?? "",
        "imagesThumb": learningProcess.imgThumb ?? "",
        "imagesPath": learningProcess.imgPath ?? "",
        "dateCreated": learningProcess.dateCreated,
        "dateUpdated": DateTime.now().toIso8601String()
      };

      final res = await http
          .patch(
              Uri.parse(
                  "$baseUrl/${dotenv.env["LEARNINGPROCESS_URL"]}/${int.parse(learningProcess.id!)}"),
              headers: {
                "Authorization": "Bearer ${currentUser.key}",
                "Content-Type": "application/json"
              },
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<MyLearningProcess?> getLearningProcess(
      String studentId, String? dateCreated) async {
    try {
      DateFormat formatted = DateFormat("yyyy-MM-dd");
      String dateNow =
          dateCreated?.split("T")[0] ?? formatted.format(DateTime.now());

      final res = await http.get(
          Uri.parse(
              "$baseUrl/${dotenv.env["LEARNINGPROCESS_URL"]}/studentId=${int.parse(studentId)}&date=$dateNow"),
          headers: {
            "Authorization": "Bearer ${currentUser.key}",
            "Content-Type": "application/json"
          }).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          MyLearningProcess learningProcess =
              MyLearningProcess.fromJson(data[0]);
          return learningProcess;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
      log("$e");
      return null;
    }
  }

  Future<List<MyLearningProcess>> getAllListSortStudentId(
      String studentId) async {
    try {
      final res = await http.get(
          Uri.parse("$baseUrl/${dotenv.env["LEARNINGPROCESS_URL"]}"),
          headers: {
            "Authorization": "Bearer ${currentUser.key}",
            "Content-Type": "application/json"
          }).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<MyLearningProcess> lst = [];
        for (var lp in data) {
          MyLearningProcess mylp = MyLearningProcess.fromJson(lp);
          if (mylp.studentId == studentId) {
            lst.add(mylp);
          }
        }
        return lst;
      }
      return [];
    } catch (e) {
      log("$e");
      return [];
    }
  }

  Future<List<MyLearningProcess>> getListWithStudentId(String studentId) async {
    try {
      final res = await http.get(
          Uri.parse(
              "$baseUrl/${dotenv.env["LEARNINGPROCESS_URL"]}/studentId/${int.parse(studentId)}"),
          headers: {
            "Authorization": "Bearer ${currentUser.key}",
            "Content-Type": "application/json"
          }).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<MyLearningProcess> lst = [];
        for (var lp in data) {
          lst.add(MyLearningProcess.fromJson(lp));
        }
        return lst;
      }
      return [];
    } catch (e) {
      log("$e");
      return [];
    }
  }
}
