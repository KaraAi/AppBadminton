import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/state/list_learningprocess_provider.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_learning_process.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/ccui/ccitem/youtube_item_view.dart';
import 'package:badminton_management_1/ccui/ccresource/app_colors.dart';
import 'package:badminton_management_1/ccui/ccresource/app_mainsize.dart';
import 'package:badminton_management_1/ccui/ccresource/app_message.dart';
import 'package:badminton_management_1/ccui/ccresource/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LearningProcessItem extends StatefulWidget {
  LearningProcessItem(
      {super.key,
      required this.student,
      this.learningProcess,
      required this.isNullLP});

  MyStudent student;
  MyLearningProcess? learningProcess;
  bool isNullLP = false;

  @override
  State<LearningProcessItem> createState() => _LearningProcessItem();
}

class _LearningProcessItem extends State<LearningProcessItem> {
  bool isSaving = false;
  bool isAdd = false;
  bool isCheck = false;
  double footerHeight = 70;

  String title = "";
  String currentUrl = "";

  TextEditingController titleController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    //
    isAdd = widget.isNullLP;
    if (!isAdd) {
      isCheck = widget.learningProcess!.isPublish == "1";

      urlController.text = widget.learningProcess!.linkWeb ?? "";
      commentController.text = widget.learningProcess!.comment ?? "";
      WidgetsBinding.instance.addPostFrameCallback((_) {
        titleController.text = (widget.learningProcess!.title == ""
            ? "${AppLocalizations.of(context).translate("learningprocess_title")} ${widget.student.studentName!}"
            : widget.learningProcess!.title)!;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        titleController.text =
            "${AppLocalizations.of(context).translate("learningprocess_title")} ${widget.student.studentName!}";
      });
    }
    currentUrl = urlController.text;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    urlController.addListener(() {
      setState(() {
        currentUrl = normalizeYouTubeUrl(urlController.text);
        // currentUrl = urlController.text;
      });
    });

    super.didChangeDependencies();
  }

  String normalizeYouTubeUrl(String url) {
    final regexShort = RegExp(r'^https?:\/\/youtu\.be\/([^\?&]+)');
    final regexStandard =
        RegExp(r'^https?:\/\/(www\.)?youtube\.com\/watch\?v=([^\?&]+)');

    if (regexShort.hasMatch(url)) {
      final match = regexShort.firstMatch(url);
      final videoId = match?.group(1);
      return 'https://www.youtube.com/watch?v=$videoId';
    } else if (regexStandard.hasMatch(url)) {
      return url; // Đã đúng định dạng rồi
    } else {
      return ''; // Không phải link YouTube hợp lệ
    }
  }

  @override
  void dispose() {
    urlController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Stack(
        children: [
          Container(
            width: AppMainsize.mainWidth(context),
            height: AppMainsize.mainHeight(context),
            color: AppColors.pageBackground,
          ),
          SafeArea(child: _body(context)),
        ],
      )),
      bottomNavigationBar: SafeArea(child: _saveButton(context)),
    );
  }

  // Widget _saveButton(BuildContext context) {
  //   return Consumer<ListLearningprocessProvider>(
  //     builder: (context, value, child) {
  //       return Container(
  //           width: AppMainsize.mainWidth(context),
  //           padding: const EdgeInsets.all(10),
  //           color: AppColors.pageBackground,
  //           child: GestureDetector(
  //             onTap: isSaving
  //                 ? null
  //                 : () async {
  //                   if (!mounted) return;
  //                     setState(() {
  //                       isSaving = true;
  //                     });

  //                     MyLearningProcess lp = MyLearningProcess(
  //                         id: widget.learningProcess?.id,
  //                         studentId: widget.student.id,
  //                         title: titleController.text,
  //                         comment: commentController.text,
  //                         isPublish: isCheck ? "1" : "0",
  //                         linkWeb: urlController.text,
  //                         imgThumb: "",
  //                         imgPath: "",
  //                         dateCreated: widget.learningProcess?.dateCreated,
  //                         isAlreadyAdd: widget.learningProcess?.isAlreadyAdd);

  //                     MyLearningProcess mylp = await value.handleCheckAddUpdate(
  //                         context, widget.student, lp);
  //                     widget.learningProcess = mylp;

  //                     setState(() {
  //                       isSaving = false;
  //                     });
  //                   },
  //             child: Container(
  //               width: double.infinity,
  //               height: footerHeight,
  //               decoration: BoxDecoration(
  //                   color: AppColors.primary,
  //                   borderRadius: BorderRadius.circular(20)),
  //               child: isSaving
  //                   ? const Stack(
  //                       children: [
  //                         Center(
  //                           child: CircularProgressIndicator(
  //                             color: Colors.white,
  //                           ),
  //                         )
  //                       ],
  //                     )
  //                   : Center(
  //                       child: Text(
  //                         AppLocalizations.of(context)
  //                             .translate("learningprocess_save"),
  //                         style: AppTextstyle.subWhiteTitleStyle,
  //                       ),
  //                     ),
  //             ),
  //           ));
  //     },
  //   );
  // }

Widget _saveButton(BuildContext context) {
  return Consumer<ListLearningprocessProvider>(
    builder: (context, value, child) {
      return Container(
        width: AppMainsize.mainWidth(context),
        padding: const EdgeInsets.all(10),
        color: AppColors.pageBackground,
        child: GestureDetector(
          onTap: isSaving
              ? null
              : () async {
                  if (!mounted) return; // Kiểm tra widget còn tồn tại

                  setState(() {
                    isSaving = true;
                  });

                  try {
                    MyLearningProcess lp = MyLearningProcess(
                      id: widget.learningProcess?.id,
                      studentId: widget.student.id,
                      title: titleController.text,
                      comment: commentController.text,
                      isPublish: isCheck ? "1" : "0",
                      linkWeb: urlController.text,
                      imgThumb: "",
                      imgPath: "",
                      dateCreated: widget.learningProcess?.dateCreated,
                      isAlreadyAdd: widget.learningProcess?.isAlreadyAdd,
                    );

                    MyLearningProcess mylp = await value.handleCheckAddUpdate(
                        context, widget.student, lp);
                    widget.learningProcess = mylp;

                  } catch (e) {
                    print("Lỗi khi lưu quá trình học: $e");
                    AppMessage.errorMessage(
                      context,
                      AppLocalizations.of(context).translate("error_data"),
                    );
                  }

                  if (mounted) {
                    setState(() {
                      isSaving = false;
                    });
                  }
                },
          child: Container(
            width: double.infinity,
            height: footerHeight,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isSaving
                ? const Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
                : Center(
                    child: Text(
                      AppLocalizations.of(context).translate("learningprocess_save"),
                      style: AppTextstyle.subWhiteTitleStyle,
                    ),
                  ),
          ),
        ),
      );
    },
  );
}

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: AppMainsize.mainWidth(context),
        color: AppColors.pageBackground,
        padding: EdgeInsets.only(bottom: footerHeight, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 0, child: _title(context)),
            _publishCheck(context),
            _urlField(context),
            _commentField(context),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      width: AppMainsize.mainWidth(context),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate("title"),
            style: AppTextstyle.contentGreySmallStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextFormField(
            controller: titleController,
            maxLines: 2,
            style: AppTextstyle.mainTitleStyle,
            decoration: InputDecoration(
                border: null, labelStyle: AppTextstyle.mainTitleStyle),
          )
        ],
      ),
    );
  }

  Widget _publishCheck(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCheck = !isCheck;
        });
      },
      child: Container(
        width: AppMainsize.mainWidth(context),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).translate("learningprocess_publish"),
              style: AppTextstyle.subTitleStyle,
            ),
            isCheck
                ? const Icon(
                    Icons.check_box_rounded,
                    color: AppColors.secondary,
                    size: 30,
                  )
                : const Icon(
                    Icons.crop_square,
                    color: Colors.grey,
                    size: 30,
                  )
          ],
        ),
      ),
    );
  }

  Widget _urlField(BuildContext context) {
    return Container(
      width: AppMainsize.mainWidth(context),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate("learningprocess_url"),
            style: AppTextstyle.contentGreySmallStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextFormField(
            controller: urlController,
            maxLines: 1,
            decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.grey)),
                labelStyle: AppTextstyle.contentBlackSmallStyle),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: AppMainsize.mainWidth(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: YoutubeItemView(videoUrl: currentUrl),
            ),
          )
        ],
      ),
    );
  }

  Widget _commentField(BuildContext context) {
    return Container(
      width: AppMainsize.mainWidth(context),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate("learningprocess_comment"),
            style: AppTextstyle.contentGreySmallStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextFormField(
            controller: commentController,
            maxLines: 10,
            decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.grey)),
                labelStyle: AppTextstyle.contentBlackSmallStyle),
          )
        ],
      ),
    );
  }
}
