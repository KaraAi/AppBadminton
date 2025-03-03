// ignore_for_file: prefer_final_fields

import 'dart:core';
import 'dart:developer';

import 'package:badminton_management_1/bbdata/aamodel/my_roll_call.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_time.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_user.dart';
import 'package:badminton_management_1/bbdata/online/roll_call_api.dart';
import 'package:badminton_management_1/bbdata/online/student_api.dart';
import 'package:badminton_management_1/bbdata/online/time_api.dart';
import 'package:flutter/material.dart';

class ListStudentProvider with ChangeNotifier {
  final StudentApi studentApi = StudentApi();
  final TimeApi timeApi = TimeApi();
  final RollCallApi rollCallApi = RollCallApi();
  final currentUser = MyCurrentUser();

  String? timeIdFilter, timeName;

  List<MyStudent> _allStudents = []; // Toàn bộ dữ liệu học viên
  List<MyStudent> _lstStudent = [];
  List<MyStudent> _filterStudent = [];
  List<MyStudent> _lstStudentFilter() =>
      _filterStudent.isEmpty ? _lstStudent : _filterStudent;
  List<MyTime> _lstTime = [];
  List<MyRollCall> _lstRollCall = [];

  List<MyStudent> _lstUpdateIsCheck = [];

  List<MyStudent> get allStudents => _allStudents; //
  List<MyStudent> get lstUpdateIsCheck => _lstUpdateIsCheck;
  List<MyStudent> get lstStudentFilter => _lstStudentFilter();
  List<MyStudent> get lstStudent => _lstStudent;
  List<MyTime> get lstTime => _lstTime;

  bool isLoading = false;
  String _searchQuery = '';

  void disposeList() {
    timeIdFilter = null;
    timeName = null;
    _searchQuery = '';
    _filterStudent.clear();
  }

  // Clear student in update list
  void clearLstUpdateIsCheck() {
    _lstUpdateIsCheck.clear();
  }

  // Add to _lstUpdateIsCheck
  void addIsCheck(MyStudent student, String isCheck) {
    if (_lstUpdateIsCheck.isEmpty) {
      _lstUpdateIsCheck.add(student);
    } else {
      int index = _lstUpdateIsCheck.indexWhere((std) => std.id == student.id);
      if (index == -1) {
        _lstUpdateIsCheck.add(student);
      } else {
        _lstUpdateIsCheck[index] = student;
      }
    }
    notifyListeners();
  }

  // Update isCheck for student in _lstStudent
  void updaIsCheckInMainList(MyStudent student, String isCheck) {
    student.isCheck = isCheck;
    _lstStudent[_lstStudent.indexWhere((std) => std.id == student.id)] =
        student;
    addIsCheck(student, isCheck);
  }

  // Delete 1 student from _lstUpdateIsCheck
  void deleteFromLstUpdate(index) {
    if (index != -1) {
      _lstUpdateIsCheck.removeAt(index);
      notifyListeners();
    }
  }

  // Update savedRollCall of student
  void updateSavedRollCall(MyStudent student) {
    int index = _lstStudent.indexWhere((std) => std.id == student.id);
    if (index != -1) {
      _lstStudent[index].savedRollCall();
    }
    notifyListeners();
  }

  void deleteFromLstUpdateWithMyStudent(MyStudent student) {
    int index = lstUpdateIsCheck.indexWhere((std) => std.id == student.id);
    if (index != -1) {
      _lstUpdateIsCheck.removeAt(index);
      notifyListeners();
    }
  }

  // Check for online / offline
  Future<void> setList(Function onNoStudentFound) async {
    // bool isConnect = await ConnectionService().checkConnect();
    // isConnect ? await setListOnline() : await setListLocal();
    await setListOnline(onNoStudentFound);
  }

  Future<void> setListAllStudent(Function onNoStudentFound) async {
    await setListOnlineAllStudent(onNoStudentFound);
  }

  // Set list with data sqlite
  Future<void> setListLocal() async {
    _setLoadingState(true);

    try {
      _lstStudent.clear();
      _filterStudent.clear();
      _mergeRollCallWithStudents();
    } catch (e) {
      log("$e");
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> setListOnline(Function onNoStudentFound) async {
    _setLoadingState(true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      _lstStudent.clear();
      _filterStudent.clear();

      _lstStudent =
          await studentApi.getListByCoachId(int.parse(currentUser.id!));
      _allStudents = await studentApi.getAllStudent();
      _lstRollCall = await rollCallApi.getListDate();
      _lstTime = await timeApi.getList();

      _lstStudent = _lstStudent.where((std) => std.statusId == "3").toList();
      _mergeRollCallWithStudents();
      //     //filterListTimeID(_lstTime[0].id ?? "");
      if (_lstTime.isNotEmpty && _lstTime[0].id != null) {
        filterListTimeID(_lstTime[0].id!, onNoStudentFound);
      } else {
        onNoStudentFound(); // Hiển thị SnackBar nếu không có khung giờ hợp lệ
      }
    } catch (e) {
      log("$e");
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> setListOnlineAllStudent(Function onNoStudentFound) async {
    _setLoadingState(true);
    await Future.delayed(const Duration(seconds: 1));
    try {
      _lstStudent.clear();
      _filterStudent.clear();

      _lstStudent = await studentApi.getAllStudent();
      _lstRollCall = await rollCallApi.getListDate();
      _lstTime = await timeApi.getList();
      _allStudents = await studentApi.getAllStudent();
      _lstStudent = _lstStudent.where((std) => std.statusId == "3").toList();

      _mergeRollCallWithStudents();
      if (_lstTime.isNotEmpty && _lstTime[0].id != null) {
        filterListTimeID(_lstTime[0].id!, onNoStudentFound);
      } else {
        onNoStudentFound(); 
      }
    } catch (e) {
      log("$e");
    } finally {
      _setLoadingState(false);
    }
  }

  // Set for isLoading
  void _setLoadingState(bool loading) {
    isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Merge rollCall data for isCheck of student
  void _mergeRollCallWithStudents() {
    Set<String> seenStudentIds = {};
    _lstRollCall = _lstRollCall.where((rollCall) {
      if (seenStudentIds.contains(rollCall.studentId)) {
        return false;
      } else {
        seenStudentIds.add(rollCall.studentId!);
        return true;
      }
    }).toList();

    for (var student in _lstStudent) {
      MyRollCall rollCall = _lstRollCall.firstWhere(
        (rc) => rc.studentId == student.id,
        orElse: () => MyRollCall(),
      );
      if (rollCall.isCheck != null) {
        student.isCheck = rollCall.isCheck;
        student.savedRollCall();
      }
    }
    _lstRollCall.clear();
  }

  // For search or filter
  void _filterList() {
    final searchQueryTrimmed =
        _searchQuery.trim().replaceAll(RegExp(r'\s+'), '');
    _filterStudent.clear();
    _filterStudent = _lstStudent.where((student) {
      final bool matchesSearch = _searchQuery.isEmpty ||
          _searchQuery == "" ||
          student.studentName!
              .toLowerCase()
              .replaceAll(RegExp(r'\s+'), '')
              .contains(searchQueryTrimmed.toLowerCase().trim());
      final bool matchesTimeId =
          timeIdFilter == null || student.timeId == timeIdFilter;

      return matchesSearch && matchesTimeId;
    }).toList();
    notifyListeners();
  }

  void filterListSearch(String query) {
    _searchQuery = query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      _filterStudent = List.from(
          _allStudents); // Trả lại toàn bộ danh sách khi không tìm kiếm
    } else {
      _filterStudent = _allStudents.where((student) {
        return student.studentName != null &&
            student.studentName!.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  void filterListTimeID(String timeId, Function onNoStudentFound) {
    timeIdFilter = timeId.isEmpty ? null : timeId;
    // Lấy danh sách học viên từ lstStudent
    List<MyStudent> tempFilteredStudents = lstStudent.where((student) {
      return timeIdFilter == null || student.timeId == timeIdFilter;
    }).toList();
    // Nếu không có học viên, hiển thị SnackBar và dừng cập nhật danh sách
    if (tempFilteredStudents.isEmpty) {
      onNoStudentFound();
      return;
    }
    // Nếu có học viên, cập nhật danh sách
    _filterStudent = tempFilteredStudents;
    notifyListeners();
  }
}
