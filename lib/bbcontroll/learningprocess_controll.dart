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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      if(lp?.isAlreadyAdd==null){
        await handleAddLearningProcess(context, lp!);
        lp.savedLP();
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

  // Future<void> handleUpdateLearningProcess(BuildContext context, MyLearningProcess lp) async{
  //   try{
  //     if(lp.comment=="" || lp.title==""){
  //       AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_empty_inputlp"));
  //       return;
  //     }
  //     else{
  //       await messageHandler.handleAction(
  //         context, 
  //         () => LearningProcessApi().updateProcess(lp), 
  //         "learningprocess_success", 
  //         "learningprocess_error"
  //       );
  //     }
  //   }
  //   catch(e){
  //     AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  //   }
  // }

 Future<void> handleUpdateLearningProcess(BuildContext context, MyLearningProcess lp) async {
  try {
    // Kiểm tra input rỗng
    if (lp.comment == null || lp.comment!.trim().isEmpty || lp.title == null || lp.title!.trim().isEmpty) {
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_empty_inputlp"));
      return;
    }

    // Kiểm tra studentId hợp lệ
    if (lp.studentId == null || lp.studentId!.trim().isEmpty) {
      print("Error: studentId is null or empty");
      AppMessage.errorMessage(context, "Student ID is missing.");
      return;
    }

    String studentId = lp.studentId!.trim();

    // Gọi API update quá trình học
    bool success = await messageHandler.handleAction(
      context, 
      () => LearningProcessApi().updateProcess(lp), 
      "learningprocess_success", 
      "learningprocess_error"
    );

    if (success) {
      try {
        // Lấy token FCM của học viên từ Firestore
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .get();

        // Ép kiểu data để tránh lỗi key không tồn tại
        Map<String, dynamic>? userData = studentDoc.data() as Map<String, dynamic>?;

        String? fcmToken = userData?['fcm_token'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await sendPushNotification(fcmToken, studentId);
        } else {
          print("Error: fcm_token not found for studentId: $studentId");
        }
      } catch (e) {
        print("Error fetching FCM token from Firestore: $e");
      }
    }
  } catch (e) {
    print("Error in handleUpdateLearningProcess: $e");
    AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  }
}

  Future<void> handleAddLearningProcess(BuildContext context, MyLearningProcess lp) async{
    try{
      if(lp.comment=="" || lp.title==""){
        AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_empty_inputlp"));
        return;
      }
      else{
        await messageHandler.handleAction(
          context, 
          () => LearningProcessApi().addProcess(lp), 
          "learningprocess_success", 
          "learningprocess_error"
        );
      }
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
    }
  } 
Future<void> sendPushNotification(String fcmToken, String studentId) async {
  const String serverKey = 'c7295add2ba1bf9dbe2836b0d66da6f04c9c0760';

  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': fcmToken,
        'notification': {
          'title': 'Thông báo từ HLV',
          'body': 'Huấn luyện viên vừa thêm quá trình học của $studentId. Hãy mở lên xem nào!',
          'sound': 'default'
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
      }),
    );
  } catch (e) {
    print("Lỗi gửi thông báo: $e");
  }
}

  
}