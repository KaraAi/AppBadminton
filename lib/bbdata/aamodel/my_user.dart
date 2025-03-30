import 'package:badminton_management_1/bbcontroll/strategy/user_student_type.dart';
import 'package:badminton_management_1/bbcontroll/strategy/user_type.dart';

class MyUser {
  String? id,
      email,
      password,
      username,
      image,
      linkURL,
      gender,
      phone,
      birthday,
      startDay;
  String? code, tuitions, userTypeId;
  String? imageAssets;

  MyUser(
      {this.id,
      this.email,
      this.password,
      this.username,
      this.linkURL,
      this.image,
      this.gender,
      this.imageAssets,
      this.phone,
      this.birthday,
      this.startDay,
      this.code,
      this.tuitions,
      this.userTypeId});

  MyUser.fromJson(Map<dynamic, dynamic> e) {
    if (UserTypeContext.strategy is StudentStrategy) {
      id = e["studentId"].toString();
    } else {
      id = e["coachId"].toString();
    }
  email = (e["email"] ?? "").toString();
password = (e["password"] ?? "").toString();
username = (e["coachName"] ?? e["studentName"] ?? "").toString();
linkURL = (e["lessonPlan"] ?? "").toString();
image = (e["images"] ?? "").toString();
gender = (e["genderId"] ?? "").toString();
phone = (e["phone"] ?? "").toString();
birthday = (e["birthday"] ?? "").toString();
startDay = (e["workingStart"] ?? e["studyStart"] ?? "").toString();
code = (e["studentCode"] ?? "").toString();
tuitions = (e["tuitions"] ?? "").toString();
userTypeId = (e["typeUserId"] ?? "").toString();
  }
}

class MyCurrentUser extends MyUser {
  //singleton
  MyCurrentUser._privateContructor();
  static final MyCurrentUser _instance = MyCurrentUser._privateContructor();
  factory MyCurrentUser() {
    return _instance;
  }
  //
  double? latitude, longitude;
  String? key;
  String? userType, userTypeId;

  void setCurrent(MyUser user) {
    id = user.id;
    email = user.email;
    password = user.password;
    username = user.username;
    gender = user.gender;
    linkURL = user.linkURL;
    phone = user.phone;
    birthday = user.birthday;
    startDay = user.startDay;
    code = user.code;
    tuitions = user.tuitions;
    userTypeId = user.userTypeId;

    if (user.gender == "1" && user.image == "") {
      if (UserTypeContext.strategy is StudentStrategy) {
        imageAssets = "assets/logo_icon/3dboy.png";
      } else {
        imageAssets = "assets/logo_icon/male.png";
      }
    } else if (user.gender == "0" && user.image == "") {
      if (UserTypeContext.strategy is StudentStrategy) {
        imageAssets = "assets/logo_icon/3dgirl.png";
      } else {
        imageAssets = "assets/logo_icon/female.png";
      }
    } else {
      image = user.image;
    }
  }

  void logout() {
    id = null;
    email = null;
    password = null;
    username = null;
    gender = null;
    phone = null;
    linkURL = null;
    latitude = null;
    longitude = null;
    key = null;
    image = null;
    imageAssets = null;
    birthday = null;
    startDay = null;
    code = null;
    tuitions = null;
  }
}

