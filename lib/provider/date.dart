import 'package:flutter/material.dart';

class Date with ChangeNotifier {
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month < 10
      ? '0' + DateTime.now().month.toString()
      : DateTime.now().month.toString();
  String day = DateTime.now().day.toString();
  bool isAll = false;

  String getStrtDt() {
    if (isAll) {
      return year + '01' + '01';
    }
    return year + month + '01';
  }

  String getEndDt() {
    if (isAll) {
      return year + '12' + '31';
    }
    return year +
        month +
        (DateTime(int.parse(year), int.parse(month) + 1, 0).day).toString();
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

  String getPrevYear(String year, String month) {
    String prevYear = year;
    if (int.parse(month) <= 1) {
      prevYear = (int.parse(prevYear) - 1).toString();
    }
    return prevYear;
  }

  String getPrevMonth(String year, String month) {
    String prevMonth = "";
    if (int.parse(month) > 1) {
      prevMonth = (int.parse(month) - 1).toString();
    } else {
      prevMonth = '12';
    }
    return int.parse(prevMonth) < 10 ? '0' + prevMonth : prevMonth;
  }

  String getNextYear(String year, String month) {
    String nextYear = year;
    if (int.parse(month) >= 12) {
      nextYear = (int.parse(nextYear) + 1).toString();
    }
    return nextYear;
  }

  String getNextMonth(String year, String month) {
    String nextMonth = "";
    if (int.parse(month) >= 12) {
      nextMonth = "1";
    } else {
      nextMonth = (int.parse(month) + 1).toString();
    }
    return int.parse(nextMonth) < 10 ? '0' + nextMonth : nextMonth;
  }

  String getPrevStrtDt(int month) {
    int prevMonth = int.parse(this.month) - month;
    int prevYear = int.parse(year);

    if (prevMonth <= 0) {
      prevMonth = prevMonth + 12;
      prevYear = int.parse(year) - 1;
    }
    return prevYear.toString() +
        (prevMonth < 10 ? '0' + prevMonth.toString() : prevMonth.toString()) +
        '01';
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

  String getInitYear() {
    return DateTime.now().year.toString();
  }

  String getInitMonth() {
    return DateTime.now().month < 10
        ? '0' + DateTime.now().month.toString()
        : DateTime.now().month.toString();
  }

  void setIsAll(bool isAll) {
    this.isAll = isAll;
  }
}
