import 'dart:developer';

import 'package:badminton_management_1/app_local.dart';
import 'package:badminton_management_1/bbcontroll/learningprocess_controll.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_learning_process.dart';
import 'package:badminton_management_1/bbdata/aamodel/my_student.dart';
import 'package:badminton_management_1/bbdata/online/learning_process_api.dart';
import 'package:badminton_management_1/ccui/ccresource/app_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListLearningprocessProvider with ChangeNotifier{
  // For publish and not publish
  List<MyLearningProcess> _lstLP = [];
  // For publish learning process
  List<MyLearningProcess> _lstLP1 = [];

  List<MyLearningProcess> _filterList = [];
  List<MyLearningProcess> get filterList => _filterList;

  List<MyLearningProcess> todayLst = [];
  List<MyLearningProcess> yesterdayLst = [];
  List<MyLearningProcess> createdLst = [];

  List<MyLearningProcess> youtubeList = [];
  List<MyLearningProcess> thisMonthList = [];
  List<MyLearningProcess> monthList = [];

  // List<MyWeek> lstWeek = [];

  List<String> lstDropdown(BuildContext context) => [
    AppLocalizations.of(context).translate("sort_all"),
    AppLocalizations.of(context).translate("sort_newest"), 
    AppLocalizations.of(context).translate("sort_oldest"), 
  ];

  List<MyLearningProcess> get lstLP => _lstLP;
  List<MyLearningProcess> get lstLP1 => _lstLP1;

  bool isLoading = false;
  String? currentDropdownValue;

  void clearList(){
    _lstLP.clear();
    todayLst.clear();
    yesterdayLst.clear();
    createdLst.clear();
    _filterList.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<MyLearningProcess> _sortList(BuildContext context, List<MyLearningProcess> lst){

    if(currentDropdownValue==lstDropdown(context)[1]){
      lst.sort((a, b) => DateTime.parse(b.dateUpdated??"").compareTo(DateTime.parse(a.dateUpdated??"")));
    }
    else if(currentDropdownValue==lstDropdown(context)[2]){
      lst.sort((a, b) => DateTime.parse(a.dateUpdated??"").compareTo(DateTime.parse(b.dateUpdated??"")));
    }
    else{
      lst.sort((a, b) => DateTime.parse(b.dateUpdated??"").compareTo(DateTime.parse(a.dateUpdated??"")));
    }

    return lst;
  }

  void sortListLPStudent(BuildContext context){
    _lstLP1 = _sortList(context, _lstLP1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void sortListThisMonthStudent(BuildContext context){
    thisMonthList = _sortList(context, thisMonthList);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void sortListMonthStudent(BuildContext context){
    monthList = _sortList(context, monthList);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Set list have confirm url link
  Future<void> setYoutubeList() async{
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final urlPattern = RegExp(r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$');
    youtubeList = lstLP
      .where((lp)=> lp.linkWeb!=null && lp.linkWeb!="" && urlPattern.hasMatch(lp.linkWeb??""))
      .toList();
    
    for(var yt in youtubeList){
      yt = await LearningProcessControll().setYoutubeVideoLP(yt);
    }
    
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Set the 3 list of today, yesterday and other
  void populateDateLists(List<MyLearningProcess> lst) {
    String today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String yesterday = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(const Duration(days: 1)));

    todayLst = lst.where((lp) => lp.dateUpdated?.split("T")[0] == today).toList();
    yesterdayLst = lst.where((lp) => lp.dateUpdated?.split("T")[0] == yesterday).toList();
    createdLst = lst.where((lp) => lp.dateUpdated?.split("T")[0] != today && lp.dateUpdated?.split("T")[0] != yesterday).toList();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Set list learning process with studentId
  Future<void> setListWithStudentId(String studentId) async{
    try{
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      _lstLP = await LearningProcessApi().getListWithStudentId(studentId);
      
      _lstLP1 = _lstLP.where(
        (lp)=>lp.isPublish=="1"
      ).toList();
      
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
    catch(e){
      log("$e");
    }
  }

  // Set list learning process sort studentId
  Future<void> setAllListSortStudentId(String studentId) async{
    try{
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      _lstLP = await LearningProcessApi().getAllListSortStudentId(studentId);
      
      _lstLP1 = _lstLP.where(
        (lp)=>lp.isPublish=="1"
      ).toList();
      
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
    catch(e){
      log("$e");
    }
  }

  // Set month list
  List<MyLearningProcess> _setMonthListStudent(BuildContext context, String thisMonth){
    DateFormat formatMonth = DateFormat("MM");
    List<MyLearningProcess> lst = [];
    lst = _lstLP1.where(
      (lp){
        DateTime date = DateTime.parse(lp.dateUpdated??"");
        String month = formatMonth.format(date);
        return month==thisMonth;
      }
    ).toList();
    return lst;
  }

  void setThisMonthList(BuildContext context){
    String thisMonth = DateFormat("MM").format(DateTime.now());
    thisMonthList = _setMonthListStudent(context, thisMonth);
    thisMonthList.sort((a, b) => DateTime.parse(b.dateUpdated??"").compareTo(DateTime.parse(a.dateUpdated??"")));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setMonthList(BuildContext context, String month){
    monthList = _setMonthListStudent(context, month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Check if is update or add
  Future<MyLearningProcess> handleCheckAddUpdate(
    BuildContext context, 
    MyStudent student,
    MyLearningProcess lp
  ) 
  async{
    lp = await LearningProcessControll().handleCheckForAddUpdate(context, lp, student);

    int index = _lstLP.indexWhere((mylp)=>mylp.id==lp.id);
    if(index!=-1){
      _lstLP[index] = lp;
    }
    populateDateLists(_lstLP);
    return lp;
  }

  // Get list recent learning process for student
  List<MyLearningProcess> getRecentLearningProcesses() {
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

    return lstLP1
        .where((lp) => DateTime.parse(lp.dateCreated??"").isAfter(fiveDaysAgo) && lp.isPublish=="1")
        .toList()
        ..sort((a, b) => DateTime.parse(b.dateCreated??"").compareTo(DateTime.parse(a.dateCreated??"")));
  }

  // For search or filter
  String _searchQuery = "";
  void _filterListVoid() {
    final searchQueryTrimmed = _searchQuery.trim().replaceAll(RegExp(r'\s+'), '');

    _filterList = _lstLP.where((lp) {

      final bool matchesSearch = _searchQuery.isEmpty || _searchQuery=="" ||
                                 lp.title!.toLowerCase().replaceAll(RegExp(r'\s+'), '').contains(searchQueryTrimmed.toLowerCase().trim()) ||
                                 AppFormat.formatDateTime(lp.dateUpdated??"").toLowerCase().replaceAll(RegExp(r'\s+'), '').contains(searchQueryTrimmed.toLowerCase().trim()) ||
                                 lp.comment!.toLowerCase().replaceAll(RegExp(r'\s+'), '').contains(searchQueryTrimmed.toLowerCase().trim());

      return matchesSearch;
    }).toList();
    notifyListeners();
  }

  // For search
  void filterListSearch(String query) {
    _searchQuery = query;
    _filterListVoid();
  }
}