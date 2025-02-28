import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:badminton_management_1/bbdata/aamodel/my_coach.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CoachApi{
  
  final String baseUrl = "${dotenv.env["BASE_URL"]}";
  final currentUser = MyCurrentUser();

  Future<List<MyCoach>> getAllCoach() async{
    try{
      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["COACHS_URL"]}"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        List<MyCoach> lst = [];
        for(var coach in data){
          lst.add(MyCoach.fromJson(coach));
        }
        return lst;
      }
      return [];
    }
    catch(e){
      log("$e");
      return [];
    }
  }

  Future<MyCoach> getCoachByPhone(String phone) async{
    try{

      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["COACHS_URL"]}/search/Phone/$phone"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        for(var coach in data){
          return MyCoach.fromJson(coach);
        }
      }
      return MyCoach();
    }
    catch(e){
      log("$e");
      return MyCoach();
    }
  }

  Future<MyCoach> getCoachByEmail(String email) async{
    try{

      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["COACHS_URL"]}/search/Email/$email"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        for(var coach in data){
          return MyCoach.fromJson(coach);
        }
      }
      return MyCoach();
    }
    catch(e){
      log("$e");
      return MyCoach();
    }
  }
  
  // Future<bool> updateByCoachId(String coachId, List<Map<String, dynamic>> fields) async{
  //   try{ 
  //     final body = {
  //       for (var field in fields) field['key']: field['value']
  //     };

  //     final res = await http.put(
  //       Uri.parse("$baseUrl/${dotenv.env["COACHS_URL"]}/coachId/$coachId"),
  //       headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"},
  //       body: jsonEncode(body)
  //     ).timeout(const Duration(seconds: 30));

  //     return res.statusCode==204;
  //   }
  //   catch(e){
  //     log("$e");
  //     return false;
  //   }
  // }
Future<bool> updateByCoachId(String coachId, Map<String, dynamic> updateFields) async {
  try {
    String url = "http://api.davidbadminton.com/api/Coachs/coachId/$coachId";
    print("🔍 Gọi API PATCH: $url");

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${currentUser.key}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(updateFields),  // 🛠 Gửi dữ liệu trực tiếp
    );

    print("📩 Phản hồi từ API: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 400) {
      print("⚠️ API từ chối dữ liệu, kiểm tra lại format!");
    } else if (response.statusCode == 404) {
      print("❌ Không tìm thấy sinh viên với ID: $coachId");
    }

     return response.statusCode == 200 || response.statusCode == 204; 
  } catch (e) {
    print("❌ Lỗi khi gửi request PATCH: $e");
    return false;
  }
}
}