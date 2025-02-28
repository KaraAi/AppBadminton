// ignore_for_file: use_build_context_synchronously

import 'package:badminton_management_1/bbcontroll/firstview_controll.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_coach_type.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_student_type.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_type.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FirstView extends StatefulWidget {
  const FirstView({super.key});

  @override
  State<FirstView> createState() => _FirstView();
}

class _FirstView extends State<FirstView> {
  final currentUser = MyCurrentUser();

  UserTypeStrategy? userTypeStrategy;

  @override
  void initState() {
    //userTypeStrategy = StudentStrategy();
    userTypeStrategy = CoachStrategy();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    durationAwait(context, userTypeStrategy!);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: AppMainsize.mainWidth(context),
          height: AppMainsize.mainHeight(context),
          color: AppColors.pageBackground,
          child: Stack(
            children: [
              Positioned(
                  top: (AppMainsize.mainWidth(context) / 2) - 100,
                  left: 10,
                  right: 10,
                  child: SizedBox(
                    width: AppMainsize.mainWidth(context) - 50,
                    child: Image.asset(
                      "assets/logo_icon/logo.png",
                      fit: BoxFit.contain,
                    ),
                  )),
              Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: LoadingAnimationWidget.inkDrop(
                      color: AppColors.primary, size: 55))
            ],
          )),
    );
  }
}
