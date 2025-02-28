import 'package:badminton_management_1/bbdata/aamodel/my_youtube_video.dart';

class MyLearningProcess{
  String? id, studentId, title, comment, isPublish, linkWeb, imgThumb, imgPath, dateCreated, dateUpdated;
  MyYoutubeVideo? youtubeVideo;
  bool? isAlreadyAdd = false;

  void savedLP() => isAlreadyAdd=true;

  MyLearningProcess({
    this.id,
    this.studentId,
    this.title,
    this.comment,
    this.isPublish,
    this.linkWeb,
    this.imgThumb,
    this.imgPath,
    this.dateCreated,
    this.dateUpdated,
    this.youtubeVideo,
    this.isAlreadyAdd
  }); 

  MyLearningProcess.fromJson(Map<dynamic, dynamic> e){
    id = e["learningProcessId"].toString();
    studentId = e["studentId"]?.toString();
    title = e["title"].toString();
    comment = e["comment"].toString();
    isPublish = e["isPublish"].toString();
    linkWeb = e["linkWebsite"].toString();
    imgThumb = e["imagesThumb"].toString();
    imgPath = e["imagesPath"].toString();
    dateCreated = e["dateCreated"].toString();
    dateUpdated = e["dateUpdated"].toString();
  }
}