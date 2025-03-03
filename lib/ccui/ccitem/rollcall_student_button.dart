// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/state/list_student_provider.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/ccui/ccresource/app_resources.dart';
import 'package:flutter/material.dart';

class RollcallStudentButton extends StatefulWidget{
  RollcallStudentButton({
    super.key, 
    required this.student,
    required this.child,
    required this.provider
  });

  MyStudent student;
  Widget child;
  ListStudentProvider provider;

  @override
  State<RollcallStudentButton> createState() => _RollcallStudentButton();
}

class _RollcallStudentButton extends State<RollcallStudentButton>{


  Future<void> showBottomNavigate() async {
    showModalBottomSheet(
      context: context,
      elevation: 20,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setModalState) {
            return Container(
              width: AppMainsize.mainWidth(context),
              height: AppMainsize.mainHeight(context) / 2,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context).translate("rollCallStudent")} ${widget.student.studentName ?? ""}",
                      style: AppTextstyle.mainTitleStyle,
                    ),
                    const SizedBox(height: 10),

                    widget.student.isCheck != null
                        ? Text(
                            widget.student.isCheck == "1"
                                ? AppLocalizations.of(context).translate("in_class")
                                : AppLocalizations.of(context).translate("out_class"),
                            style: widget.student.isCheck == "1" ? AppTextstyle.contentGreenSmallStyle : AppTextstyle.contentRedSmallStyle,
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: () {
                        if (widget.student.isCheck != "1") {
                          setModalState(() {
                            widget.student.isCheck = "1";
                          });
                          widget.provider.updaIsCheckInMainList(widget.student, "1");
                        }
                        else{
                          setModalState(() {
                            widget.student.isCheck = null;
                          });
                          widget.provider.deleteFromLstUpdateWithMyStudent(widget.student);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.secondary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              widget.student.isCheck == "1" ? Icons.check_circle_rounded : Icons.circle,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              AppLocalizations.of(context).translate("in_class"),
                              style: AppTextstyle.subWhiteTitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        if (widget.student.isCheck != "0") {
                          setModalState(() {
                            widget.student.isCheck = "0";
                          });
                          widget.provider.updaIsCheckInMainList(widget.student, "0");
                        }
                        else{
                          setModalState(() {
                            widget.student.isCheck = null;
                          });
                          widget.provider.deleteFromLstUpdateWithMyStudent(widget.student);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.primary.withOpacity(1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              widget.student.isCheck == "0" ? Icons.check_circle_rounded : Icons.circle,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              AppLocalizations.of(context).translate("out_class"),
                              style: AppTextstyle.subWhiteTitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async{
        await showBottomNavigate();
      },
      child: widget.child,
    );
  }

}