import 'dart:convert';

import 'package:badminton_management_1/bbdata/aamodel/my_facility.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FacilityApi {
  final String baseUrl = "${dotenv.env["BASE_URL"]}";
  final currentUser = MyCurrentUser();

  Future<List<MyFacility>> getList() async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/${dotenv.env["FACILITY_URL"]}"), headers: {
        "Authorization": "Bearer ${currentUser.key}",
        "Content-Type": "application/json"
      }).timeout(const Duration(seconds: 30));

      print(
          "📡 API Response (${res.statusCode}): ${res.body}"); // In dữ liệu nhận được

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data == null || data.isEmpty) {
          print("⚠️ API trả về danh sách rỗng!");
          return [];
        }

        List<MyFacility> lst = [];
        for (var fac in data) {
          lst.add(MyFacility.fromJson(fac));
        }

        print("✅ Số cơ sở tải về: ${lst.length}");
        return lst;
      } else {
        print("❌ Lỗi API: Mã lỗi ${res.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Lỗi khi gọi API: $e");
      return [];
    }
  }
}
