import 'dart:convert';
import 'dart:developer';

import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class StudentApi{

  final String baseUrl = "${dotenv.env["BASE_URL"]}";
  final currentUser = MyCurrentUser();

  Future<List<MyStudent>> getAllStudent() async{
    try{
      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["STUDENT_URL"]}"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        List<MyStudent> lst = [];
        for(var student in data){
          lst.add(MyStudent.fromJson(student));
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

  Future<List<MyStudent>> getListByCoachId(int id) async{
    try{
      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["STUDENT_URL"]}/coachId/$id"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        List<MyStudent> lst = [];
        for(var student in data){
          lst.add(MyStudent.fromJson(student));
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
Future<bool> updateByStudentId(String studentId, Map<String, dynamic> updateFields) async {
  try {
    String url = "http://api.davidbadminton.com/api/Students/studentId/$studentId";
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
      print("❌ Không tìm thấy sinh viên với ID: $studentId");
    }

     return response.statusCode == 200 || response.statusCode == 204; 
  } catch (e) {
    print("❌ Lỗi khi gửi request PATCH: $e");
    return false;
  }
}



  Future<MyStudent> getStudentByPhone(String phone) async{
    try{

      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["STUDENT_URL"]}/search/Phone/$phone"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        for(var student in data){
          return MyStudent.fromJson(student);
        }
      }
      return MyStudent();
    }
    catch(e){
      log("$e");
      return MyStudent();
    }
  }

  Future<MyStudent> getStudentByEmail(String email) async{
    try{

      final res = await http.get(
        Uri.parse("$baseUrl/${dotenv.env["STUDENT_URL"]}/search/Email/$email"),
        headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
      ).timeout(const Duration(seconds: 30));

      if(res.statusCode==200){
        final data = jsonDecode(res.body);
        for(var student in data){
          return MyStudent.fromJson(student);
        }
      }
      return MyStudent();
    }
    catch(e){
      log("$e");
      return MyStudent();
    }
  }
Future<bool> getCurrentUserStudent(String input) async {
  try {
    final res = await http.get(
      Uri.parse("$baseUrl/${dotenv.env["STUDENT_URL"]}/input/$input"),
      headers: {"Authorization": "Bearer ${currentUser.key}", "Content-Type": "application/json"}
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print("🔍 API Response: $data"); // In ra dữ liệu trả về từ API

      if (data["statusId"].toString() == "3") {
        MyUser user = MyUser.fromJson(data);
        currentUser.setCurrent(user);

        print("✅ user.id: ${user.id}");
        print("✅ user.userTypeId: ${user.userTypeId}");
        
        return currentUser.username != null;
      }
      return false;
    }
    return false;
  } catch (e) {
    log("$e");
    return false;
  }
}
}