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
}
