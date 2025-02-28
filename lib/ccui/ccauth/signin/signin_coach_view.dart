import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/auth_controll.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:badminton_management_1/ccui/ccresource/app_textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SignInCoachView extends StatefulWidget {
  SignInCoachView({super.key});

  TextEditingController textController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  State<SignInCoachView> createState() => _SignInView();
}

class _SignInView extends State<SignInCoachView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      width: AppMainsize.mainWidth(context),
      height: AppMainsize.mainHeight(context),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.3)])),
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: AppMainsize.mainWidth(context),
                height: AppMainsize.mainHeight(context) / 1.5,
                padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
                decoration: const BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(50)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary,
                          offset: Offset(0, 0),
                          blurRadius: 30,
                          spreadRadius: 20)
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("wellcome_back"),
                      style: AppTextstyle.mainTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    inputEmail(context),
                    inputPass(context),
                    const SizedBox(
                      height: 30,
                    ),
                    _button(context)
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget inputEmail(BuildContext context) {
    return Container(
        width: AppMainsize.mainWidth(context),
        color: AppColors.pageBackground,
        padding: const EdgeInsets.all(10),
        child: TextFormField(
          controller: widget.textController,
          maxLines: 1,
          decoration: InputDecoration(
              errorBorder: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent)),
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              fillColor: Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(
                Icons.phone,
                color: Colors.grey,
                size: 25,
              ),
              hintText: "Phone",
              hintStyle: AppTextstyle.contentGreySmallStyle,
              labelStyle: AppTextstyle.contentBlackSmallStyle),
        ));
  }

  bool isHide = true;

  Widget inputPass(BuildContext context) {
    return Container(
        width: AppMainsize.mainWidth(context),
        color: AppColors.pageBackground,
        padding: const EdgeInsets.all(10),
        child: TextFormField(
          controller: widget.passController,
          maxLines: 1,
          obscureText: isHide,
          decoration: InputDecoration(
              errorBorder: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent)),
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              fillColor: Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(
                Icons.password,
                color: Colors.grey,
                size: 25,
              ),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isHide = !isHide;
                    });
                  },
                  icon: Icon(
                    isHide
                        ? Icons.remove_red_eye_outlined
                        : Icons.remove_red_eye,
                    color: Colors.grey,
                    size: 25,
                  )),
              hintText: "Password",
              hintStyle: AppTextstyle.contentGreySmallStyle,
              labelStyle: AppTextstyle.contentBlackSmallStyle),
        ));
  }
bool isLoading = false;

Widget _button(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      setState(() {
        isLoading = true;
      });

      MyUser user = MyUser(
        email: widget.textController.text,
        password: widget.passController.text,
      );

      bool loginSuccess = await AuthControll().handleLogin(context, user: user);
      if (loginSuccess) {
        // Gán giá trị từ MyCurrentUser để đảm bảo có dữ liệu
        user.id = MyCurrentUser().id;
        user.userTypeId = MyCurrentUser().userTypeId;
        user.username = MyCurrentUser().username; // Thêm CoachName

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.username) // Dùng CoachName làm ID
              .set({
                'fcm_token': fcmToken,
                'userID': user.id ?? "null",
                'typeUserID': user.userTypeId ?? "null",
              }, SetOptions(merge: true));

          print("Firebase cập nhật thành công!");
        } else {
          print("Không lấy được FCM token");
        }
      } else {
        print("Đăng nhập thất bại");
      }

      setState(() {
        isLoading = false;
      });
    },
    child: Container(
      width: AppMainsize.mainWidth(context) - 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "Đăng Nhập",
                style: AppTextstyle.subWhiteTitleStyle,
              ),
      ),
    ),
  );
}

  // bool isLoading = false;
  // Widget _button(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () async {
  //       setState(() {
  //         isLoading = true;
  //       });

  //       await AuthControll().handleLogin(context,
  //           user: MyUser(
  //               email: widget.textController.text,
  //               password: widget.passController.text));

  //       setState(() {
  //         isLoading = false;
  //       });
  //     },
  //     child: Container(
  //       width: AppMainsize.mainWidth(context) - 100,
  //       padding: const EdgeInsets.all(15),
  //       decoration: BoxDecoration(
  //           color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
  //       child: Center(
  //           child: isLoading
  //               ? const CircularProgressIndicator(color: Colors.white)
  //               : Text(
  //                   "Đăng Nhập",
  //                   style: AppTextstyle.subWhiteTitleStyle,
  //                 )),
  //     ),
  //   );
  // }
}
