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
  final List<String> _yearList = [];
  final List<String> _monthList = [];
  String dropdownYearValue = '';
  String dropdownMonthValue = '';
  DateUtils2 dateUtils = DateUtils2();

  @override
  initState() {
    // 부모의 initState호출
    super.initState();
    _setAccountDtList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton(
          value: dropdownYearValue == '' ? context.read<Date>().getYear() : dropdownYearValue,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          onChanged: (String? newValue) {
            setState(() {
              context.read<Date>().setDate(newValue!, '');
              dropdownYearValue = newValue;
            });
          },
          items: _yearList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value + '년'),
            );
          }).toList()
        ),
        SizedBox(width: 10.0),
        DropdownButton(
          value: dropdownMonthValue == '' ? context.read<Date>().getMonth() : dropdownMonthValue,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          onChanged: (String? newValue) {
            setState(() {
              context.read<Date>().setDate('', newValue!);
              dropdownMonthValue = newValue;
            });
          },
          items: _monthList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value + '월'),
            );
          }).toList()
        )
      ]
    );
  }

  void _setAccountDtList() {
    _yearList.clear();
    _monthList.clear();
    int year = Config.STRT_YEAR;

    for (int i = DateTime.now().year; i >= year; i--) {
      _yearList.add(i.toString());
    }

    for (int i = 12; i > 0; i--) {
      if (i < 10) {
        _monthList.add('0' + i.toString());
      } else {
        _monthList.add(i.toString());
      }
    }
  }
}