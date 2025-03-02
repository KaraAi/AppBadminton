import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/auth_controll.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/ccui/ccresource/app_format.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:badminton_management_1/ccui/ccresource/app_textstyle.dart';
import 'package:badminton_management_1/ccui/ccuser/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class HomeHeaderView extends StatefulWidget {
  const HomeHeaderView({super.key, required this.body});

  final Widget body;

  @override
  State<HomeHeaderView> createState() => _HomeHeaderView();
}

class _HomeHeaderView extends State<HomeHeaderView> {
  final currentUser = MyCurrentUser();
  double valueAnimate = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Detect horizontal drag
          if (details.delta.dx > 0) {
            setState(() {
              valueAnimate = 0;
            });
          }
        },
        child: _sideMenu(context),
      ),
    );
  }

  Widget _sideMenu(BuildContext context) {
    return Container(
      width: AppMainsize.mainWidth(context),
      height: AppMainsize.mainHeight(context),
      color: AppColors.secondary,
      child: Stack(
        children: [
          // Sidebar content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile
                Container(
                  width: AppMainsize.mainWidth(context),
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: (currentUser.image == null ||
                                  currentUser.image!.isEmpty)
                              ? Image.asset(
                                  currentUser
                                      .imageAssets!, // Hình ảnh mặc định nếu không có
                                  fit: BoxFit.cover,
                                )
                              : Image.memory(
                                  base64Decode(
                                    currentUser.image!
                                        .split(',')
                                        .last, // Loại bỏ prefix
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      currentUser
                                          .imageAssets!, // Hình ảnh mặc định nếu có lỗi
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile and Settings options
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileView(),
                      ),
                    );
                  },
                  trailing:
                      const Icon(Icons.person, color: Colors.white, size: 30),
                  title: Text("Người dùng",
                      style: AppTextstyle.subWhiteTitleStyle,
                      textAlign: TextAlign.end),
                ),

                ListTile(
                  onTap: () {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      disableBackBtn: true,
                      title: AppLocalizations.of(context)
                          .translate("warning_logout"),
                      showCancelBtn: true,
                      onConfirmBtnTap: () async {
                        Navigator.pop(context);
                        await AuthControll().handleLogout(context);
                      },
                    );
                  },
                  trailing:
                      const Icon(Icons.logout, color: Colors.white, size: 25),
                  title: Text("Đăng xuất",
                      style: AppTextstyle.subRedTitleStyle,
                      textAlign: TextAlign.end),
                ),
                //       const SizedBox(
                //         height: 20,
                //       ),
                //       _logoutSection()
              ],
            ),
          ),

          // 3D Slide Animation
          Positioned.fill(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: valueAnimate),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, double val, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002) // Depth effect
                    ..translate(200 * val,
                        -20 * val) // Horizontal and vertical movement
                    ..scale(1 - (0.1 * val)) // Slight scaling down
                    ..rotateX((pi / 24) * val) // Top tilting effect
                    ..rotateY(
                        (pi / 10) * val), // Horizontal rotation for 3D effect
                  child: Opacity(
                    opacity: val.clamp(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: val == 0
                          ? BorderRadius.circular(0)
                          : BorderRadius.circular(25),
                      child: _body(context, val),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _body(BuildContext context, double val) {
    double headerHeight = 190;

    return Container(
        width: AppMainsize.mainWidth(context),
        color: AppColors.pageBackground,
        child: Stack(
          children: [
            //--------------------------------
            Positioned.fill(
              top: headerHeight + 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 15,
                      child: val == 0
                          ? widget.body
                          : SizedBox(
                              width: AppMainsize.mainWidth(context),
                              height: AppMainsize.mainHeight(context),
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  // Detect horizontal drag
                                  if (details.delta.dx > 0) {
                                    setState(() {
                                      valueAnimate = 0;
                                    });
                                  }
                                },
                                child: widget.body,
                              ),
                            )),
                ],
              ),
            ),

            //
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: AppMainsize.mainWidth(context),
                  height: headerHeight,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary,
                            offset: Offset(0, 0),
                            blurRadius: 20)
                      ],
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30))),
                  child: SafeArea(child: _titleWellcome(context)),
                )),
          ],
        ));
  }

  Widget _logoutSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 70),
      child: ListTile(
        onTap: () {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            disableBackBtn: true,
            title: AppLocalizations.of(context).translate("warning_logout"),
            showCancelBtn: true,
            onConfirmBtnTap: () async {
              Navigator.pop(context);
              await AuthControll().handleLogout(context);
            },
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.logout, size: 25, color: Colors.white),
        ),
        title: const Text(
          "Đăng xuất",
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _titleWellcome(BuildContext context) {
  return SizedBox(
    width: AppMainsize.mainWidth(context),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ Tránh lỗi tràn chiều dọc
        children: [
          // Avatar
          SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: (currentUser.image == null || currentUser.image!.isEmpty)
                  ? Image.asset(
                      currentUser.imageAssets!,
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      base64Decode(currentUser.image!.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          currentUser.imageAssets!,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(width: 10), // Khoảng cách nhỏ

          // Phần văn bản chứa tên học viên
          Expanded( // ✅ Dùng Expanded để chiếm đủ không gian
            child: SingleChildScrollView( // ✅ Cho phép cuộn nếu nội dung dài
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min, // ✅ Đảm bảo nội dung không bị ép quá mức
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("wellcome_home"),
                    style: AppTextstyle.subWhiteTitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ✅ Hiển thị đầy đủ, không bị lỗi tràn
                  Text(
                    AppFormat.removeParentheses(currentUser.username ?? ""),
                    style: AppTextstyle.mainWhiteTitleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Nút cài đặt
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  valueAnimate = valueAnimate == 0 ? -1 : 0;
                });
              },
              icon: const Icon(Icons.settings, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildImageFromBase64(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            currentUser.imageAssets!, // Hình ảnh mặc định nếu có lỗi
            fit: BoxFit.cover,
          );
        },
      );
    } catch (e) {
      return Image.asset(
        currentUser.imageAssets!, // Hình ảnh mặc định nếu chuỗi Base64 bị lỗi
        fit: BoxFit.cover,
      );
    }
  }
}
