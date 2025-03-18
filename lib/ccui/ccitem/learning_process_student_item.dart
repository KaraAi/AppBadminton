
import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_learning_process.dart';
import 'package:badminton_management_1/ccui/ccitem/youtube_item_view.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:badminton_management_1/ccui/ccresource/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearningProcessStudentItem extends StatefulWidget{
  const LearningProcessStudentItem({super.key, required this.lp});
  final MyLearningProcess lp;

  @override
  State<LearningProcessStudentItem> createState() => _LearningProcessStudentItem();
}

class _LearningProcessStudentItem extends State<LearningProcessStudentItem>{



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
        // Background container
        Container(
          width: AppMainsize.mainWidth(context),
          height: AppMainsize.mainHeight(context),
          color: AppColors.pageBackground,
        ),

        // Main content container
        Container(
          width: AppMainsize.mainWidth(context),
          padding: const EdgeInsets.all(5),
          color: AppColors.pageBackground,
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Start session video
                  if (widget.lp.youtubeVideo != null) ...[
                    _buildYoutubeVideo(context),
                    const SizedBox(height: 20),
                    _styledContainer(
                      context,
                      title: AppLocalizations.of(context).translate("title_video"),
                      content: widget.lp.youtubeVideo!.videoTitle ?? "",
                      contentStyle: AppTextstyle.subTitleStyle,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async{
                        final Uri uri = Uri.parse(widget.lp.youtubeVideo!.url ?? "");
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          // ignore: use_build_context_synchronously
                          AppMessage.errorMessage(context, AppLocalizations.of(context).translate("error_launch_url"));
                        }
                      },
                      child: _styledContainer(
                        context,
                        title: "Link video",
                        content: widget.lp.youtubeVideo!.url ?? "",
                        contentStyle: AppTextstyle.subTitleStyle.copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // End session video

                  _styledContainer(
                    context,
                      title: AppLocalizations.of(context).translate("title_note"),
                    content: widget.lp.title ?? "",
                    contentStyle: AppTextstyle.subTitleStyle,
                  ),
                  const SizedBox(height: 20),
                  _styledContainer(
                    context,
                    title: AppLocalizations.of(context).translate("learningprocess_comment"),
                    content: widget.lp.comment ?? "",
                    contentStyle: AppTextstyle.subTitleStyle,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ),
        ),
      ],
    );
  }

  // Widget _buildYoutubeVideo(BuildContext context) {
  //   return SizedBox(
  //     width: AppMainsize.mainWidth(context),
  //     height: 300,
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(20),
  //       child: YoutubeItemView(videoUrl: widget.lp.linkWeb ?? ""),
  //     ),
  //   );
  // }
Widget _buildYoutubeVideo(BuildContext context) {
  String formattedUrl = formatYoutubeUrl(widget.lp.youtubeVideo!.url ?? "");
  print("Formatted YouTube URL: $formattedUrl");
  
  return SizedBox(
    width: AppMainsize.mainWidth(context),
    height: 300,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: YoutubeItemView(videoUrl: formattedUrl),
    ),
  );
}
String formatYoutubeUrl(String url) {
  if (url.contains("youtu.be/")) {
    return url.replaceAll("youtu.be/", "www.youtube.com/watch?v=");
  }
  if (!url.contains("watch?v=")) {
    return url; // Giữ nguyên nếu đã đúng định dạng
  }
  return url;
}


  Widget _styledContainer(
    BuildContext context, {
    required String title,
    required String content,
    required TextStyle contentStyle,
  }) {
    return Container(
      width: AppMainsize.mainWidth(context),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset.zero,
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppMainsize.mainWidth(context),
            child: Text(
              title,
              style: AppTextstyle.contentGreySmallStyle,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
          ),
          SizedBox(
            width: AppMainsize.mainWidth(context),
            child: Text(
              content,
              style: contentStyle,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }


}