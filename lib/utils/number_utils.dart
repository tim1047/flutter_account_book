import 'package:intl/intl.dart';

class NumberUtils {
  
  String comma(int val) {
    String numberFormat = '';

    if (val.isNegative) {
      val *= -1;
      numberFormat += '-';
    }
    return numberFormat + NumberFormat('###,###,###,###').format(val).toString().replaceAll(' ', '');
  }

  String uncomma(String val) {
    return val.replaceAll(',', '');
  }
}
