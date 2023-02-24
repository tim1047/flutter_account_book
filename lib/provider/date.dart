import 'package:flutter/material.dart';

class Date with ChangeNotifier {
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString();
  String day = DateTime.now().day.toString();

  String getStrtDt() {
    return year + month + '01';
  }

  String getEndDt() {
    return year + month + (DateTime(int.parse(year), int.parse(month) + 1, 0).day).toString();
  }

  String getYYYYMM() {
    return year + month;
  }

  String getYear() {
    return year;
  }

  String getMonth() {
    return month;
  }

  String getPrevStrtDt(int month) {
    int prevMonth = int.parse(this.month) - month;
    int prevYear = int.parse(this.year);

    if (prevMonth <= 0) {
      prevMonth = prevMonth + 12;
      prevYear = int.parse(this.year) - 1; 
    } 
    return prevYear.toString() + (prevMonth < 10 ? '0' + prevMonth.toString() : prevMonth.toString()) + '01';
  }

  void setDate(String year, String month) {
    if (year.isNotEmpty) {
      this.year = year;
    }

    if (month.isNotEmpty) {
      this.month = month;
    }
    notifyListeners();
  }
}