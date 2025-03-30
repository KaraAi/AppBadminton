// ignore_for_file: use_build_context_synchronously

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/template/message_template.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_learning_process.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_youtube_video.dart';
import 'package:badminton_management_1/bbdata/online/learning_process_api.dart';
import 'package:badminton_management_1/bbdata/online/youtube_html.dart';
import 'package:badminton_management_1/ccui/ccitem/learning_process_coach_item.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart';

class LearningProcessControll {

  final MessageHandler messageHandler = MessageHandler();
  
  Future<void> handleGetLearningProcess(BuildContext context, MyStudent student) async{
    try{
      MyLearningProcess? learningProcess = await LearningProcessApi().getLearningProcess(student.id!, DateTime.now().toIso8601String());
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context)=>LearningProcessItem(student: student, learningProcess: learningProcess, isNullLP: learningProcess==null,)
        )
      );
    } 
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
    } 
  }

  Future<MyLearningProcess> setYoutubeVideoLP(MyLearningProcess lp) async {
    String videoTitle = "Loading...";
    String imageUrl = "";

    videoTitle = await fetchVideoTitle(lp.linkWeb ?? "");
    imageUrl = await getVideoThumbnailUrl(lp.linkWeb ?? "");

    lp.youtubeVideo = MyYoutubeVideo(
      url: lp.linkWeb,
      videoTitle: videoTitle,
      imageUrl: imageUrl,
    );

    return lp;
  }

  Future<MyLearningProcess> handleCheckForAddUpdate(BuildContext context, MyLearningProcess? lp, MyStudent student) async{
    try{
      // MyLearningProcess? mylp = await LearningProcessApi().getLearningProcess(student.id!, lp.dateCreated);
      if(lp?.id!=null){lp?.savedLP();}
      if (lp == null || lp.studentId == null || lp.studentId!.isEmpty) {
  print("Error: Cannot update, learning process or studentId is missing.");
  return MyLearningProcess();
}
await handleUpdateLearningProcess(context, lp);

      if (lp?.isAlreadyAdd == null || lp?.isAlreadyAdd == false) {
        await handleAddLearningProcess(context, lp!);
        lp.savedLP();
        print("✅ Đã gọi `savedLP()`, trạng thái: ${lp.isAlreadyAdd}");
}
      else{
        // lp.id = mylp.id;
        // lp.dateCreated = mylp.dateCreated;
        lp?.dateUpdated = DateTime.now().toIso8601String();
        if(lp?.id==null){
          lp = await LearningProcessApi().getLearningProcess(student.id!, lp?.dateCreated);
        }
        await handleUpdateLearningProcess(context, lp!);
      }
      return lp;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return MyLearningProcess();
    }
  }



Future<void> handleUpdateLearningProcess(BuildContext context, MyLearningProcess lp) async {
  try {
    // 🛑 Kiểm tra dữ liệu đầu vào
    if ((lp.comment?.trim().isEmpty ?? true) || (lp.title?.trim().isEmpty ?? true)) {
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_empty_inputlp"));
      return;
    }

    if (lp.studentId == null || lp.studentId!.trim().isEmpty) {
      AppMessage.errorMessage(context, "⚠️ Student ID is missing.");
      return;
    }

    String studentId = lp.studentId!.trim(); // 🔹 Firestore lưu `studentID` dưới dạng String

    // 🚀 Gọi API để cập nhật quá trình học
    bool success = await LearningProcessApi().updateProcess(lp);
    if (!success) {
      print("❌ API trả về thất bại! Kiểm tra lại dữ liệu.");
      // AppMessage.errorMessage(context, "⚠️ API cập nhật thất bại, kiểm tra lại dữ liệu!");
      return;
    }

    print("✅ API cập nhật quá trình học thành công!");
    AppMessage.successMessage(context, AppLocalizations.of(context).translate("learningprocess_success"));

    // 🔥 Lấy thông tin học viên từ Firestore (truy vấn bằng `String`)
    String studentName = "Học viên"; // Giá trị mặc định
    String? studentFcmToken;

    try {
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('studentID', isEqualTo: studentId) 
          .limit(1)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        var data = studentQuery.docs.first.data() as Map<String, dynamic>;
        print("🔥 Dữ liệu Firestore lấy được: $data");

        studentName = data['studentName'] ?? "Học viên";
        studentFcmToken = data['fcm_token'] as String?; // Lấy token FCM

        if (studentFcmToken == null || studentFcmToken.isEmpty) {
          print("⚠️ Không tìm thấy FCM token cho học viên ID: $studentId");
        }
      } else {
        print("⚠️ Không tìm thấy học viên với studentID: $studentId");
        return; // Không có học viên thì không gửi thông báo nữa
      }
    } catch (e) {
      print("❌ Lỗi khi lấy dữ liệu Firestore: $e");
      return;
    }

    // 📩 Gửi thông báo FCM nếu tìm thấy token
    if (studentFcmToken != null && studentFcmToken.isNotEmpty) {
      print("📩 Đang gửi FCM đến token: $studentFcmToken");
      await sendFCMNotification(
        [studentFcmToken],
        "Cập nhật quá trình học",
        "Huấn luyện viên đã cập nhật quá trình học của bạn, $studentName!",
      );
    }
  } catch (e) {
    print("❌ Lỗi khi cập nhật quá trình học: $e");
    AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  }
}



Future<void> handleAddLearningProcess(BuildContext context, MyLearningProcess lp) async {
  try {
    if ((lp.comment?.isEmpty ?? true) || (lp.title?.isEmpty ?? true)) {
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_empty_inputlp"));
      return;
    }

    // 🟢 Gửi dữ liệu quá trình học lên server
    bool isSuccess = await LearningProcessApi().addProcess(lp);
    if (isSuccess) {
      print("✅ Quá trình học đã được lưu thành công!");
      AppMessage.successMessage(context, AppLocalizations.of(context).translate("learningprocess_success"));

      // 🔥 Lấy tên học viên từ Firestore
      String studentName = "Học viên"; // Giá trị mặc định
      String? studentFcmToken; // Token để gửi thông báo cho học viên
      try {
        QuerySnapshot studentQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('studentID', isEqualTo: lp.studentId) // Lọc theo studentID
            .limit(1) 
            .get();

        if (studentQuery.docs.isNotEmpty) {
          var data = studentQuery.docs.first.data() as Map<String, dynamic>;
          studentName = data['studentName'] ?? "Học viên";
          studentFcmToken = data['fcm_token']; // Lấy FCM token của học viên
          print("🔥 Lấy được studentName: $studentName");
        } else {
          print("⚠️ Không tìm thấy học viên với studentID: ${lp.studentId}");
        }
      } catch (e) {
        print("⚠️ Không thể lấy thông tin học viên từ Firestore: $e");
      }

      // 🔥 Lấy danh sách quản lý (`typeUserID = "2"`) để gửi thông báo xác nhận
      QuerySnapshot managerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('typeUserID', isEqualTo: "2") // Chỉ lấy quản lý
          .get();

      List<String> fcmTokens = [];
      for (var doc in managerSnapshot.docs) {
        var token = doc['fcm_token'];
        if (token != null && token.isNotEmpty) {
          fcmTokens.add(token);
        }
      }

      // 📩 Gửi thông báo FCM cho quản lý
      if (fcmTokens.isNotEmpty) {
        await sendFCMNotification(
          fcmTokens,
          "Xác nhận quá trình học",
          "Huấn luyện viên đã thêm quá trình học cho học viên $studentName",
        );
      }

      // 📩 Gửi thông báo FCM cho học viên
      if (studentFcmToken != null && studentFcmToken.isNotEmpty) {
        await sendFCMNotification(
          [studentFcmToken],
          "Cập nhật quá trình học",
          "Huấn luyện viên đã cập nhật quá trình học của bạn!",
        );
      }

    } else {
      print("❌ Lưu dữ liệu thất bại nhưng vẫn gửi lên server! Kiểm tra response.");
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("learningprocess_error"));
    }

  } catch (e) {
    print("Lỗi: $e");
    AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  }
}

Future<void> sendFCMNotification(List<String> tokens, String title, String body) async {
  const String projectId = "david-education-coach";
  final String accessToken = await getAccessToken(); // 🔥 Lấy token tự động

  final Uri fcmUrl = Uri.parse("https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

  for (String token in tokens) {
    final Map<String, dynamic> fcmPayload = {
      "message": {
        "token": token, 
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

    if (response.statusCode == 200) {
      print("🔥 Thông báo gửi thành công đến: $token");
    } else {
      print("❌ Lỗi gửi FCM ($token): ${response.body}");
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

  
}