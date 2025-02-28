
// ignore_for_file: use_build_context_synchronously

//---
import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/hash/hash_password.dart';
import 'package:badminton_management_1/bbcontroll/route/route_config.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_type.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/bbdata/online/coach_api.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:flutter/material.dart';

class CoachStrategy implements UserTypeStrategy {

  final List<RouteConfig> routes = UserRoutes.getRoutesForCoach();

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
    bool isAuth = await userApi.checkLoginCoach(phone: user.email??"", password: user.password??"");
    return isAuth;
  }
  
  @override
  Future<bool> updateBirthDay(BuildContext context, String birthday) async{
    try{
      Map<String, dynamic> lst = {"Birthday":birthday};
      bool isUpdate = await CoachApi().updateByCoachId(currentUser.id!, lst);
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
      Map<String, dynamic> lst = {"PassWord":hashPass};
      bool isUpdate = await CoachApi().updateByCoachId(currentUser.id!, lst);
      return isUpdate;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return false;
    }
  }
  
  @override
  Future<bool> updateEmail(BuildContext context, String email) async{
    try{
      Map<String, dynamic> lst = {"Email":email};
      bool isUpdate = await CoachApi().updateByCoachId(currentUser.id!, lst);
      return isUpdate;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return false;
    }
  }
  
  @override
  Future<bool> updatePhone(BuildContext context, String phone) async{
    try{
      Map<String, dynamic> lst = {"Phone":phone};
      bool isUpdate = await CoachApi().updateByCoachId(currentUser.id!, lst);
      return isUpdate;
    }
    catch(e){
      AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_data"));
      return false;
    }
  }

}