import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/config/config.dart';


class Dropdown extends StatefulWidget {
  const Dropdown({Key? key}) : super(key: key);

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  List<String> _accountDtList = [];
  String dropdownValue = '';
  DateUtils2 dateUtils = DateUtils2();

  @override
  initState() {
    // 부모의 initState호출
    super.initState();
    _setAccountDtList();
  }
  
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: dropdownValue == '' ? context.read<Date>().getYYYYMM() : dropdownValue,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? newValue) {
        setState(() {
          context.read<Date>().setDate(newValue!.substring(0, 4), newValue.substring(4, 6));
          dropdownValue = newValue;
        });
      },
      items: _accountDtList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(dateUtils.yyyymmddToHangeul2(value)),
        );
      }).toList()
    );
  }

  void _setAccountDtList() {
    _accountDtList.clear();
    int year = Config.STRT_YEAR;
    int month = Config.STRT_MONTH;

    for (int i = DateTime.now().year; i >= year; i--){
      int tempMonth = DateTime.now().month;

      if (i != DateTime.now().year) {
        tempMonth = 12;
      }

      for (int j = tempMonth; j >= 1; j--){
        if (j < 10) {
          _accountDtList.add(i.toString() + '0' + j.toString());
        } else {
          _accountDtList.add(i.toString() + j.toString());
        }
        if (i == year && j == month) {
          break;
        }
      }
    }
  }
}