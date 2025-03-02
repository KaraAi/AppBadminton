// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/session_controll.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_type.dart';
import 'package:badminton_management_1/bbcontroll/template/message_template.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/bbdata/online/user_api.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:badminton_management_1/main.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthControll{

  final currentUser = MyCurrentUser();
  final userTypeContext = UserTypeContext();
  final messageHandler = MessageHandler();
  final sessionManager = SessionManager();

  // Handle logout
  Future<void> handleLogout(BuildContext context) async {
  // Xóa dữ liệu đăng nhập trong SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userID');

  // Đăng xuất người dùng
  currentUser.logout();
  sessionManager.stopSession();

  // Chuyển về màn hình đăng nhập
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => MainApp(isLoggedIn: false)), // ✅ Sửa lỗi tại đây
    (route) => false,
  );
}

  Future<bool> handleLogin(BuildContext context, {required MyUser user}) async {
  bool isLogin = await UserTypeContext.login(user);

  await messageHandler.handleAction(
    context,
    () async => isLogin,
    "success_login",
    "error_emailpass",
  );

  if (isLogin) {
    UserTypeContext.navigateReplacement(context, "/home");
  }

  return isLogin; // Thêm return để có giá trị trả về
}

  // Handle login user type
  // Future<void> handleLogin(BuildContext context, {required MyUser user}) async{

  //   bool isLogin = await UserTypeContext.login(user);

  //   await messageHandler.handleAction(
  //     context,
  //     () async => isLogin,
  //     "success_login", 
  //     "error_emailpass",
  //   );

  //   if (isLogin) {
  //     UserTypeContext.navigateReplacement(context, "/home");
  //   }
  // }

  // Handle update birthday student / coach
  Future<void> handleUpdateBirthday(BuildContext context, String birthday) async{
    try{
      await messageHandler.handleAction(
        context,
        () => UserTypeContext.updateBirthDay(context, birthday),
        "success_update",
        "error_update",
      );
      currentUser.birthday = birthday;
    }
    catch(e){
      log("$e");
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
    }
  }

  // Handle update phone
  Future<void> handleUpdatePhone(BuildContext context, String phone) async{
    try{
      final phoneRegex = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');

      if(phone=="" || !phoneRegex.hasMatch(phone) || phone.length<10 || phone.length>10){
        AppMessage.showAlert(
          context: context, 
          type: QuickAlertType.error, 
          message: AppLocalizations.of(context).translate("error_phone_type")
        );
        return;
      }
      else{
        bool isUpdate = await UserTypeContext.updatePhone(context, phone);
        if(isUpdate){
          AppMessage.showAlert(
            context: context, 
            type: QuickAlertType.success, 
            message: AppLocalizations.of(context).translate("success_update")
          );
          currentUser.phone = phone;
          return;
        }
        else{
          AppMessage.showAlert(
            context: context, 
            type: QuickAlertType.error, 
            message: AppLocalizations.of(context).translate("error_update")
          );
          return;
        }
        
      }

    }
    catch(e){
      log("$e");
      AppMessage.showAlert(
        context: context, 
        type: QuickAlertType.error, 
        message: AppLocalizations.of(context).translate("error_data")
      );
    }
  }

  // Handle update email
  Future<void> handleUpdateEmail(BuildContext context, String email) async{
    try{
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      bool isReal = await UserApi().isDomainValid(email);
      if(email=="" || !emailRegex.hasMatch(email)){
        AppMessage.showAlert(
          context: context, 
          type: QuickAlertType.error, 
          message: AppLocalizations.of(context).translate("error_email_type")
        );
        return;
      }
      else if(!isReal){
        AppMessage.showAlert(
          context: context, 
          type: QuickAlertType.error, 
          message: AppLocalizations.of(context).translate("error_email_type")
        );
        return;
      }
      else{
        bool isDublicate = await UserTypeContext.checkDublicateEmail(email);
        if(isDublicate){
          AppMessage.showAlert(
            context: context, 
            type: QuickAlertType.error, 
            message: AppLocalizations.of(context).translate("error_dublicate_email")
          );
          return;
        }
        else{
          bool isUpdate = await UserTypeContext.updateEmail(context, email);
          if(isUpdate){
            AppMessage.showAlert(
              context: context, 
              type: QuickAlertType.success, 
              message: AppLocalizations.of(context).translate("success_update")
            );
            currentUser.email = email;
            return;
          }
          else{
            AppMessage.showAlert(
              context: context, 
              type: QuickAlertType.error, 
              message: AppLocalizations.of(context).translate("error_update")
            );
            return;
          }
        }
      }

    }
    catch(e){
      log("$e");
      AppMessage.showAlert(
        context: context, 
        type: QuickAlertType.error, 
        message: AppLocalizations.of(context).translate("error_data")
      );
    }
  }

  // Handle update password student / password
  // Future<void> handleUpdatePassword(BuildContext context, String password, String confirmPassword) async{
  //   try{
  //     if(password!=confirmPassword || password=="" || confirmPassword==""){
  //       AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_notsame_password"));
  //       return;
  //     }
  //     else if (!_isPasswordStrong(password)) {
  //       AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_weak_password"));
  //       return;
  //     }
  //     else{
  //       bool isUpdate = await UserTypeContext.updatePassword(context, password);
        
  //       await messageHandler.handleAction(
  //         context,
  //         () async => isUpdate,
  //         "success_update",
  //         "error_update",
  //       );
  //     }
  //   }
  //   catch(e){
  //     log("$e");
  //     AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  //   }
  // }

Future<void> handleUpdatePassword(BuildContext context, String password, String confirmPassword) async {
  try {
    if (password != confirmPassword || password.isEmpty || confirmPassword.isEmpty) {
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_notsame_password"));
      return;
    } else if (!_isPasswordStrong(password)) {
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_weak_password"));
      return;
    } else {
      log("Bắt đầu cập nhật mật khẩu...");

      bool isUpdate = await UserTypeContext.updatePassword(context, password);
      log("Kết quả cập nhật mật khẩu: $isUpdate");

      if (!isUpdate) {
        AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_update"));
        return;
      }

      await messageHandler.handleAction(
        context,
        () async => true, // Đảm bảo chỉ thực thi khi cập nhật thành công
        "success_update",
        "error_update",
      );
    }
  } catch (e) {
    log("Lỗi khi cập nhật mật khẩu: $e");
    AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
  }
}
  // Check password strong
  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters && hasMinLength;
  }

}