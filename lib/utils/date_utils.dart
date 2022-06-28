import 'package:intl/intl.dart';

class DateUtils2 {
  
  String yyyymmddToHangeul(String dt) {
    return dt.substring(0, 4) + '년 ' + dt.substring(4, 6) + '월 ' + dt.substring(6, 8) + '일';
  }
  
  String yyyymmddToHangeul2(String dt) {
    return dt.substring(0, 4) + '년 ' + dt.substring(4, 6) + '월 ';
  }

  DateTime stringToDateTime(String dt) {
    return DateTime.parse(dt);
  }

  String DateToYYYYMMDD(DateTime datetime) {
    return DateFormat('yyyyMMdd').format(datetime);
  }

  String getPrevStrtDt(String dt) {
    DateTime dateTime = stringToDateTime(dt);

    int prevMonth = dateTime.month - 1;
    int prevYear = dateTime.year;

    if (prevMonth <= 0) {
      prevMonth = prevMonth + 12;
      prevYear = dateTime.year - 1; 
    } 
    return prevYear.toString() + (prevMonth < 10 ? '0' + prevMonth.toString() : prevMonth.toString()) + '01';
  }

  String getNextStrtDt(String dt) {
    DateTime dateTime = stringToDateTime(dt);

    int nextMonth = dateTime.month + 1;
    int nextYear = dateTime.year;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear = dateTime.year + 1; 
    } 
    return nextYear.toString() + (nextYear < 10 ? '0' + nextMonth.toString() : nextMonth.toString()) + '01';
  }
}
