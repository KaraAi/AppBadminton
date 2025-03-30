class MyStudent {
  String? id,typeUserID, studentName, phone, password, album;
  String? timeId, images, gender, birthday, email, statusId = "1";
  String? isCheck;
  bool isSavedRollCall = false;

  void savedRollCall() => isSavedRollCall = true;

  MyStudent(
      {this.id,
      this.typeUserID,
      this.studentName,
      phone,
      password,
      this.album,
      this.timeId,
      this.images,
      this.gender,
      this.birthday,
      this.email,
      this.statusId});

  MyStudent.fromJson(Map<dynamic, dynamic> e) {
    id = e["studentId"].toString();
    typeUserID=e["typeUserID"].toString();
    timeId = e["timeId"].toString();
    studentName = e["studentName"].toString();
    album = (e["album"] ?? e["album"]).toString();
    images = (e["images"] ?? e["images"]).toString();
    birthday = e["birthday"].toString().split("T")[0];
    phone = (e["phone"] ?? e["phone"]).toString();
    password = e["password"].toString();
    email = (e["email"] ?? e["email"]).toString();
    gender = e["genderId"].toString();
    statusId = e["statusId"].toString();
  }

  Map<String, dynamic> toMapSqlite() {
    return {
      'studentId': id,
      'typeUserID':typeUserID,
      'studentName': studentName,
      'album': album,
      'phone': phone,
      'password': password,
      'timeId': timeId,
      'images': images,
      'genderId': gender,
      'birthday': birthday,
      'email': email,
      'statusId': statusId,
      'isCheck': isCheck,
    };
  }
}
