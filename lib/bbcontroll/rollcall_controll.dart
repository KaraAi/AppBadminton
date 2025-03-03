// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/connection/check_connection.dart';
import 'package:badminton_management_1/bbcontroll/state/list_student_provider.dart';
import 'package:badminton_management_1/bbcontroll/template/message_template.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_facility.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/bbdata/online/facility_api.dart';
import 'package:badminton_management_1/bbdata/online/roll_call_api.dart';
import 'package:badminton_management_1/bbdata/online/roll_call_coachs_api.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class RollCallControll {
  final RollCallCoachesApi rollCallCoachesApi = RollCallCoachesApi();
  final FacilityApi facilityApi = FacilityApi();
  final RollCallApi rollCallApi = RollCallApi();
  // final RollCallDatabaseRepository rollcallRepository = RollCallDatabaseRepository();
  final MessageHandler messageHandler = MessageHandler();
  final ConnectionService connectionService = ConnectionService();
  final currentFacility = MyCurrentFacility();
  final listFacility = MyListCurrentFacility();
  final currentUser = MyCurrentUser();

  // Student Roll Call --------------------------------------------------------

Future<void> handleSaveListRollCall(BuildContext context) async {
  try {
    bool isConnect = await connectionService.checkConnect();
    await _processRollCallSave(context, isOnline: isConnect);
  } catch (e) {
    AppMessage.errorMessage(
        context, AppLocalizations.of(context).translate("error_data"));
  }
}

// ✅ Xử lý điểm danh và gửi thông báo
Future<void> _processRollCallSave(BuildContext context, {required bool isOnline}) async {
  final studentProvider = Provider.of<ListStudentProvider>(context, listen: false);

  bool? youSure = await _showConfirmationDialog(
    context,
    title: isOnline
        ? AppLocalizations.of(context).translate("rollcall_check_save")
        : AppLocalizations.of(context).translate("rollcall_check_save_local"),
  );

  if (youSure != true) return;

  QuickAlert.show(context: context, type: QuickAlertType.loading, disableBackBtn: true);

  Map<String, String> checkedStudents = {}; // id -> "1" (Đi học) hoặc "0" (Không đi học)
  bool isAllSuccessful = true;

  List<MyStudent> studentsToCheck = List<MyStudent>.from(studentProvider.lstUpdateIsCheck);

  // ✅ Duyệt qua tất cả học viên cần cập nhật
  for (var std in studentsToCheck) { 
    String status = std.isCheck ?? "0"; // Mặc định là "0" nếu null (coi như không đi học)

    bool isSaved = await _saveRollCallWithRetry(std, retryLimit: 3, isOnline: isOnline);

    if (!isSaved) {
      isAllSuccessful = false;
    } else {
      int index = studentProvider.lstUpdateIsCheck.indexWhere((student) => student.id == std.id);
      studentProvider.deleteFromLstUpdate(index);
      studentProvider.updateSavedRollCall(std);

      checkedStudents[std.id!] = status; // ✅ Đảm bảo danh sách đúng định dạng ID -> Trạng thái
    }
  }

  Navigator.pop(context);

  await messageHandler.handleAction(
      context,
      () async => isAllSuccessful,
      AppLocalizations.of(context).translate("success_save"),
      AppLocalizations.of(context).translate("error_retry_failed"));

  // 🔥 Gửi thông báo sau khi lưu điểm danh
  if (checkedStudents.isNotEmpty) {
    await _sendNotificationToCheckedStudents(checkedStudents);
  }
}



// ✅ Gửi thông báo cho học viên có token hợp lệ từ Firestore
Future<void> _sendNotificationToCheckedStudents(Map<String, String> checkedStudents) async {
  try {
    QuerySnapshot<Map<String, dynamic>> studentsSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where("studentID", whereIn: checkedStudents.keys.map((e) => e.toString()).toList()) 
    .get();

        print("📢 Danh sách ID cần tìm: ${checkedStudents.keys.toList()}");
print("📢 Số lượng document lấy về: ${studentsSnapshot.docs.length}");

    Map<String, String> studentTokens = {};
    Map<String, String> studentIdMap = {}; 
   for (var doc in studentsSnapshot.docs) {
      String? fcmToken = doc['fcm_token'];
      String? studentID = doc['studentID']; // 🔥 Lấy studentID đúng
      if (studentID != null && fcmToken != null && fcmToken.trim().isNotEmpty) {
        studentTokens[doc.id] = fcmToken;
        studentIdMap[doc.id] = studentID.toString(); // 🔥 Lưu document ID -> student ID
      }
    }


    // ✅ Gửi thông báo nếu có token hợp lệ
    if (studentTokens.isNotEmpty) {
      for (var entry in studentTokens.entries) {
        String docId = entry.key; // Firestore Document ID
        String token = entry.value;
        String studentId = studentIdMap[docId] ?? "0"; // Lấy student ID đúng
        String status = checkedStudents[studentId] ?? "0"; // Lấy trạng thái điểm danh

        String statusMessage = status == "1" ? "Bạn đã đi học" : "Bạn đã vắng mặt";

        print("📢 Gửi thông báo cho $studentId ($docId) - Trạng thái: $statusMessage");

        await sendPushNotification([token], "Thông báo điểm danh", statusMessage);
      }
    } else {
      print("⚠️ Không có token hợp lệ để gửi thông báo.");
    }
  } catch (e) {
    print("❌ Lỗi khi lấy token từ Firestore hoặc gửi thông báo: $e");
  }
}


// ✅ Hiển thị hộp thoại xác nhận
Future<bool?> _showConfirmationDialog(BuildContext context, {required String title}) async {
  return await QuickAlert.show(
    context: context,
    type: QuickAlertType.warning,
    title: title,
    showCancelBtn: true,
    onConfirmBtnTap: () => Future.microtask(() => Navigator.of(context).pop(true)),
    onCancelBtnTap: () => Future.microtask(() => Navigator.of(context).pop(false)),
  );
}

// ✅ Lưu điểm danh qua API với cơ chế retry
Future<bool> _saveRollCallWithRetry(MyStudent std, {required int retryLimit, required bool isOnline}) async {
  int retryCount = 0;
  bool isSaved = false;

  while (!isSaved && retryCount < retryLimit) {
      if (isOnline) {
        isSaved = await rollCallApi.rollCall(std.id!, std.isCheck ?? "1");
      }
      if (!isSaved) {
        retryCount++;
      }
      await Future.delayed(const Duration(seconds: 1));
    }

  return isSaved;
}



Future<void> sendPushNotification(List<String> tokens, String title, String body) async {
  if (tokens.isEmpty) {
    print("❌ Không có token hợp lệ để gửi thông báo.");
    return;
  }

  const String projectId = "davidbadminton";
  final String accessToken = await getAccessToken();

  final Uri fcmUrl = Uri.parse("https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

  for (String token in tokens) {
    try {
      final response = await http.post(
        fcmUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode({
          "message": {
            "token": token,
            "notification": {
              "title": title,
              "body": body
            },
            "android": {
              "priority": "high"
            },
            "apns": {
              "payload": {
                "aps": {
                  "sound": "default"
                }
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Gửi thành công đến $token");
      } else {
        print("❌ Lỗi gửi FCM đến $token: ${response.body}");
      }
    } catch (e) {
      print("❌ Lỗi khi gửi FCM: $e");
    }
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


  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Dịch vụ vị trí bị tắt.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Quyền vị trí bị từ chối.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Quyền vị trí bị từ chối vĩnh viễn.");
    }

    Position position = await Geolocator.getCurrentPosition();
    print(
        "📍 Vị trí hiện tại: Lat: ${position.latitude}, Lng: ${position.longitude}");
    return position;
  }

  Future<Map<String, dynamic>> _fetchWeatherData() async {
    try {
      Position position = await _determinePosition();
      print(
          "🌍 Lấy dữ liệu thời tiết tại: ${position.latitude}, ${position.longitude}");

      String apiKey = "62c8370f658f2457db00ee12eaa5b07d"; // API Key của bạn
      String url =
          "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=vi";
      print("🔗 API URL: $url"); // Kiểm tra URL API

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("✅ Dữ liệu thời tiết: $data");
        return {
          "city": data["name"],
          "description": data["weather"][0]["description"],
          "temperature": data["main"]["temp"],
          "icon": data["weather"][0]["icon"],
        };
      } else {
        throw Exception("Lỗi khi tải dữ liệu thời tiết.");
      }
    } catch (e) {
      print("❌ Lỗi lấy dữ liệu thời tiết: $e");
      return {};
    }
  }

  Future<bool> isNearFacility(BuildContext context) async {
    try {
      const double proximityThreshold = 50; // 1km
      await listFacility.setList();
      List<MyFacility> lstFacility = listFacility.lstFacility!;
      List<MyFacility> nearbyFacility = [];

      print(
          "📍 Vị trí hiện tại: ${currentUser.latitude}, ${currentUser.longitude}");
      print("🏢 Danh sách cơ sở có trong hệ thống:");

      for (var facility in lstFacility) {
        double distance = Geolocator.distanceBetween(
          currentUser.latitude ?? 0.0, // Tránh lỗi nếu giá trị null
          currentUser.longitude ?? 0.0,
          facility.latitude ?? 0.0,
          facility.longtitude ?? 0.0,
        );

        print("🏢 Cơ sở: ${facility.name}");
        print("📍 Vị trí cơ sở: ${facility.latitude}, ${facility.longtitude}");
        print("📏 Khoảng cách: $distance mét");

        if (distance <= proximityThreshold) {
          nearbyFacility.add(facility);
        }
      }

      if (nearbyFacility.isNotEmpty) {
        currentFacility.setCurrent(nearbyFacility.first);
        print("✅ Tìm thấy cơ sở gần nhất: ${nearbyFacility.first.name}");
      } else {
        print("❌ Không có cơ sở nào trong phạm vi $proximityThreshold mét.");
      }

      return nearbyFacility.isNotEmpty;
    } catch (e) {
      print("❌ Lỗi trong quá trình kiểm tra khoảng cách: $e");
      return false;
    }
  }

  Future<void> rollCallCoachs(BuildContext context) async {
    await listFacility.setList();
    List<MyFacility> lstFacility = listFacility.lstFacility!;

    print("📌 Danh sách cơ sở từ database:");
    for (var facility in lstFacility) {
      print(
          "🏢 Cơ sở: ${facility.name}, Tọa độ: ${facility.latitude}, ${facility.longtitude}");
    }

    if (lstFacility.isEmpty) {
      print("⚠️ Lỗi: Không có cơ sở nào được tải từ database!");
    }
    try {
      await getCurrentPosition();
      bool isAtWork = await isNearFacility(context);

      print("🛠 Kiểm tra vị trí chấm công: $isAtWork");

      if (isAtWork) {
        print("✅ Bạn đang ở trong khu vực chấm công.");

        await messageHandler.handleAction(context, () async {
          await rollCallCoachesApi.rollCallCoachs(context);
          return true;
        }, "rollcall_success", "error_rollcall");
      } else {
        print("❌ Bạn không ở trong khu vực chấm công!");
        AppMessage.errorMessage(
            context, "Bạn chưa ở đúng vị trí để chấm công.");
      }
    } catch (e) {
      print("❌ Lỗi trong quá trình chấm công: $e");
      AppMessage.errorMessage(context, "Lỗi chấm công. Vui lòng thử lại.");
    }
  }

  Future<void> getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      currentUser.latitude = position.latitude; // Lưu dưới dạng double
      currentUser.longitude = position.longitude;
      print(
          "📌 Tọa độ hiện tại cập nhật: ${currentUser.latitude}, ${currentUser.longitude}");
    } catch (e) {
      print("❌ Lỗi khi lấy vị trí: $e");
    }
  }

  Future<void> handleAction(
      BuildContext context,
      Future<bool> Function(BuildContext) action, // Hàm có tham số `context`
      String successMessage,
      String errorMessage) async {
    try {
      bool result = await action(context); // Gọi hàm với `context`
      if (result) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: successMessage,
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: errorMessage,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: errorMessage,
      );
    }
  }
}
