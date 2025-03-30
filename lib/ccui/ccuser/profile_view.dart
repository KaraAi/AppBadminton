// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/auth_controll.dart';
import 'package:badminton_management_1/bbcontroll/state/list_rollcallcoach_provider.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_student_type.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_type.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/ccui/ccresource/app_format.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:badminton_management_1/ccui/ccresource/app_textstyle.dart';
import 'package:badminton_management_1/ccui/ccuser/changepassword_view.dart';
import 'package:badminton_management_1/ccui/ccuser/statistic_tuitions_student.dart';
import 'package:badminton_management_1/ccui/ccuser/update_view/update_email.dart';
import 'package:badminton_management_1/ccui/ccuser/update_view/update_phone.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  final currentUser = MyCurrentUser();

  String birthday = "";

  @override
  void initState() {
    birthday = currentUser.birthday ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: AppMainsize.mainWidth(context),
          height: AppMainsize.mainHeight(context),
          color: AppColors.pageBackground,
        ),
        Container(
          width: AppMainsize.mainWidth(context),
          color: AppColors.pageBackground,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                _personalSection(),
                const SizedBox(
                  height: 20,
                ),
                _settingSection(),
                // const SizedBox(
                //   height: 20,
                // ),
                // _logoutSection(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _personalSection() {
    return Column(
      children: [
        if (UserTypeContext.strategy is! StudentStrategy)
          Center(
            child: Container(
              width: AppMainsize.mainWidth(context) / 2,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.5), width: 5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: (currentUser.image == null || currentUser.image!.isEmpty)
                    ? Image.asset(
                        currentUser
                            .imageAssets!, // Hình ảnh mặc định nếu không có
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        base64Decode(
                          currentUser.image!.split(',').last, // Loại bỏ prefix
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
          ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            AppFormat.removeParentheses(currentUser.username ?? ""),
            style: AppTextstyle.mainTitleStyle,
            textAlign: TextAlign.center,
          ),
        ),
        _personalInfoSection(),
      ],
    );
  }

  Widget _personalInfoSection() {
    return Container(
      width: AppMainsize.mainWidth(context),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          UpdateEmailView(
              child: _personalInfoItem("Email", currentUser.email ?? "")),
          const SizedBox(height: 10),
          UpdatePhoneView(
              child: _personalInfoItem("Phone",
                  AppFormat.formatPhoneNumberVN(currentUser.phone ?? "")))
        ],
      ),
    );
  }

  Widget _personalInfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: AppMainsize.mainWidth(context) - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppMainsize.mainWidth(context),
                child: Text(
                  label,
                  style: AppTextstyle.contentGreySmallStyle,
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                ),
              ),
              SizedBox(
                width: AppMainsize.mainWidth(context),
                child: Text(
                  value,
                  style: AppTextstyle.subTitleStyle,
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                ),
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(100)),
          child: const Icon(
            Icons.edit,
            color: AppColors.contentColorWhite,
            size: 15,
          ),
        )
      ],
    );
  }

  Widget _settingSection() {
    return Container(
      width: AppMainsize.mainWidth(context),
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (UserTypeContext.strategy is StudentStrategy)
            _settingOption(
              icon: Icons.bar_chart,
              color: AppColors.secondary,
              label:
                  AppLocalizations.of(context).translate("summary_see_option"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StatisticTuitionsStudent())),
            ),
          _birthdayOption(),
          _settingOption(
            icon: Icons.password,
            color: AppColors.secondary,
            label: AppLocalizations.of(context)
                .translate("setting_change_password"),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangePasswordSecondView())),
          ),
          _rollcallHistoryOption(),
        ],
      ),
    );
  }

  Widget _birthdayOption() {
    return ListTile(
      onTap: () async {
        DateTime initialDate = DateTime.tryParse(
            currentUser.birthday ?? DateTime.now().toIso8601String())!;
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(initialDate.year - 20),
          lastDate: DateTime(DateTime.now().year + 100),
        );
        if (selectedDate != null) {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.loading,
              disableBackBtn: true);

          String selectedDay = selectedDate.toIso8601String();
          await AuthControll().handleUpdateBirthday(context, selectedDay);
          Navigator.pop(context);

          setState(() => birthday = selectedDay);
        }
      },
      leading: _iconContainer(Icons.bubble_chart, AppColors.secondary),
      title: Text(
          AppLocalizations.of(context).translate("setting_update_birthday"),
          style: AppTextstyle.subSecondTitleStyle),
      subtitle: Text(AppFormat.formatDateTime(birthday),
          style: AppTextstyle.contentGreySmallStyle),
    );
  }

  Widget _rollcallHistoryOption() {
    return Consumer<ListRollcallcoachProvider>(
      builder: (context, value, child) {
        return value.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : _settingOption(
                icon: Icons.history,
                color: AppColors.secondary,
                label: AppLocalizations.of(context)
                    .translate("setting_history_rollcall"),
                onTap: () =>
                    UserTypeContext.navigate(context, "/history/rollcall"),
              );
      },
    );
  }

  Widget _settingOption(
      {required IconData icon,
      required Color color,
      required String label,
      required Function() onTap}) {
    return ListTile(
      onTap: onTap,
      leading: _iconContainer(icon, color),
      title: Text(label, style: AppTextstyle.subSecondTitleStyle),
    );
  }

  Widget _iconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
      child: Icon(icon, size: 25, color: Colors.white),
    );
  }
}
