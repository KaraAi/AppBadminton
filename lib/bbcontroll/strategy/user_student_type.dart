
// ignore_for_file: use_build_context_synchronously

//---
import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/hash/hash_password.dart';
import 'package:badminton_management_1/bbcontroll/route/route_config.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_type.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/bbdata/online/student_api.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:flutter/material.dart';

class StudentStrategy implements UserTypeStrategy {
  
  final List<RouteConfig> routes = UserRoutes.getRoutesForStudent();

  @override
  void navigatePageRouteReplacement(BuildContext context, String route) {
    final routeConfig = routes.firstWhere(
      (config) => config.route == route,
      orElse: () => throw Exception("Route not found: $route"),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => routeConfig.builder()),
    );
  }

  @override
  void navigatePageRoute(BuildContext context, String route) {
    final routeConfig = routes.firstWhere(
      (config) => config.route == route,
      orElse: () => throw Exception("Route not found: $route"),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => routeConfig.builder()),
    );
  }
  
  @override
  Future<bool> login(MyUser user) async{
    bool isAuth = await userApi.checkLoginStudent(
      code: user.code??"",
      password: user.password??""
    );
    return isAuth;
  }
  
  @override
  Future<bool> updateBirthDay(BuildContext context, String birthday) async{
    try{
      Map<String, dynamic> lst = {"Birthday":birthday
    };
      bool isUpdate = await StudentApi().updateByStudentId(currentUser.id!, lst);
      return isUpdate;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return false;
    }
  }
  
  @override
  Future<bool> updatePassword(BuildContext context, String password) async{
    try{
      String hashPass = hashPassword(password);
      print("Mật khẩu sau khi băm: $hashPass");
      Map<String, dynamic> lst = {"Password":hashPass
    };
      print("Gọi API cập nhật mật khẩu cho userId: ${currentUser.id}");
      bool isUpdate = await StudentApi().updateByStudentId(currentUser.id!, lst);
      print("Kết quả cập nhật mật khẩu từ API: $isUpdate");
      return isUpdate;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return false;
    }
  }
  
  @override
  // Future<bool> updateEmail(BuildContext context, String email) async{
  //   try{
  //     List<Map<String, dynamic>> lst = [{"key": "Email", "value": email}];
  //     bool isUpdate = await StudentApi().updateByStudentId(currentUser.id!, lst);
  //     return isUpdate;
  //   }
  //   catch(e){
  //     AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  //     return false;
  //   }
  // }
  Future<bool> updateEmail(BuildContext context, String email) async {
  try {
    Map<String, dynamic> updateData = {
       "email": email  
    };

    bool isUpdate = await StudentApi().updateByStudentId(currentUser.id!, updateData);
    return isUpdate;
  } catch (e) {
    AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
    return false;
  }
}
  @override
  Future<bool> updatePhone(BuildContext context, String phone) async{
    try{
      Map<String, dynamic> lst = {"phone":phone
    };
      bool isUpdate = await StudentApi().updateByStudentId(currentUser.id!, lst);
      return isUpdate;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return false;
    }
  }

}