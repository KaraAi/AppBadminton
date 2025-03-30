import 'dart:convert';
import 'dart:developer';

import 'package:badminton_management_1/bbdata/aamodel/my_roll_call_coachs.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;

class RollCallCoachesApi {
  final String baseUrl = "${dotenv.env["BASE_URL"]}";
  final currentUser = MyCurrentUser();
  List<MyRollCallCoachs> lst = [];

  Future<List<MyRollCallCoachs>> getListByCoachId(String id) async {
    try {
      final res = await http.get(
          Uri.parse(
              "$baseUrl/${dotenv.env["ROLLCALLCOACH_URL"]}/$id/getHistory"),
          headers: {
            "Authorization": 'Bearer ${currentUser.key}',
            "Content-Type": "application/json"
          }).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        for (var i in data) {
          lst.add(MyRollCallCoachs.fromJson(i));
        }
        return lst;
      }
      return [];
    } catch (e) {
      log("$e");
      return [];
    }
  }

  Future<bool> checkByCoachsID(String id) async {
    lst = await getListByCoachId(id);
    String dateNow = DateFormat("yyyy-MM-dd").format(DateTime.now());

    MyRollCallCoachs rollCallCoachs = MyRollCallCoachs();
    for (var rollcall in lst) {
      if (rollcall.dateUpdate!.split("T")[0] == dateNow &&
          rollcall.coachId == currentUser.id) {
        rollCallCoachs = rollcall;
      }
    }
    return rollCallCoachs.id != null;
  }

  Future<int> getRollCallCountToday(String id) async {
    lst = await getListByCoachId(id);
    String dateNow = DateFormat("yyyy-MM-dd").format(DateTime.now());

    int count = lst
        .where((rollcall) => rollcall.dateUpdate!.split("T")[0] == dateNow)
        .length;

    return count; // Trả về số lần điểm danh trong ngày
  }

  Future<bool> rollCallCoachs(BuildContext context) async {
  try {
    int count = await getRollCallCountToday(currentUser.id!);

    if (count > 0) {
      bool? confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Xác nhận chấm công",
              style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 13, 71, 161)),
            ),
            content: Text(
              "Bạn đã chấm công $count lần hôm nay. Bạn có muốn tiếp tục không?",
              style: const TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Hủy", style: TextStyle(fontSize: 20)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text("Xác nhận", style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          );
        },
      );

      if (confirm == null || !confirm) return false;
    }

    // Tiến hành điểm danh
    final body = {
      "coachId": int.parse(currentUser.id!),
      "statusId": 0,
      "isCheck": 1,
      "userCreated": currentUser.username,
      "userUpdated": currentUser.username,
      "dateCreated": DateTime.now().toLocal().toIso8601String(),
      "dateUpdated": DateTime.now().toLocal().toIso8601String()
    };

    final res = await http.post(
      Uri.parse("$baseUrl/${dotenv.env["ROLLCALLCOACH_URL"]}"),
      headers: {
        "Authorization": "Bearer ${currentUser.key}",
        "Content-Type": "application/json"
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode == 201) {
      count++;

      // **Gửi thông báo đến quản lý**
      await sendNotificationToManagers(
        "Huấn luyện viên ${currentUser.username} đã chấm công $count lần hôm nay."
      );

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Chấm công thành công!",
        text: "Bạn đã chấm công $count lần trong ngày.",
      );
      return true;
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Lỗi chấm công",
        text: "Vui lòng thử lại sau!",
      );
      return false;
    }
  } catch (e) {
    log("$e");
    return false;
  }
}

  Future<void> sendNotificationToManagers(String message) async {
  QuerySnapshot<Map<String, dynamic>> managers = await FirebaseFirestore.instance
      .collection('users')
      .where('typeUserID', isEqualTo: "2")
      .get();

  // Lấy danh sách token từ tất cả managers
  List<String> tokens = managers.docs
      .map((doc) => doc["fcm_token"] as String?)
      .where((token) => token != null && token.isNotEmpty)
      .cast<String>()
      .toList();

  if (tokens.isNotEmpty) {
    await sendPushNotification(tokens, "Thông báo chấm công", message);
  } else {
    print("❌ Không có quản lý nào để gửi thông báo!");
  }
}


Future<void> sendPushNotification(List<String> tokens, String title, String body) async {
  const String projectId = "david-education-coach";
  final String accessToken = await getAccessToken(); // 🔥 Lấy token tự động

  final Uri fcmUrl = Uri.parse("https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

  for (String token in tokens) {
    final Map<String, dynamic> fcmPayload = {
      "message": {
        "token": token, // Gửi từng token một
        "notification": {
          "title": title,
          "body": body
        }
      }
    };

    final response = await http.post(
      fcmUrl,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
      body: jsonEncode(fcmPayload),
    );
  }
}
Future<String> getAccessToken() async {
  final serviceAccount = jsonDecode(await rootBundle.loadString('assets/service-account.json'));

  final client = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(serviceAccount),
    ['https://www.googleapis.com/auth/firebase.messaging'],
  );

  return client.credentials.accessToken.data;
}


}
