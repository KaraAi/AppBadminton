
import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_roll_call_coachs.dart';
import 'package:badminton_management_1/ccui/ccresource/app_format.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:badminton_management_1/ccui/ccresource/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RollCallCoachItem extends StatefulWidget{
  RollCallCoachItem({super.key, required this.rcCoachs});
  MyRollCallCoachs rcCoachs;

  @override
  State<RollCallCoachItem> createState() => _RollCallItem();
}

class _RollCallItem extends State<RollCallCoachItem>{

  bool isLoadingRC = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppMainsize.mainWidth(context),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${AppLocalizations.of(context).translate("you_rollcall_atday")} ${AppFormat.formatDateTime(widget.rcCoachs.dateUpdate??"")}", 
            style: AppTextstyle.contentBlackSmallStyle, 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10,),

          Text(
            "${AppLocalizations.of(context).translate("you_rollcall_attime")} ${DateFormat('HH:mm').format(DateTime.parse(widget.rcCoachs.dateUpdate!))}", 
            style: AppTextstyle.contentBlackSmallStyle, 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
          ),
        ],
      )
    );
  }

}