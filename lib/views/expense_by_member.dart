import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:account_book/widget/menubar.dart';
import 'package:account_book/widget/menu.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/views/account_list.dart';

class ExpenseByMember extends StatefulWidget {
  const ExpenseByMember({Key? key}) : super(key: key);

  @override
  State<ExpenseByMember> createState() => _ExpenseByMemberState();
}

class _ExpenseByMemberState extends State<ExpenseByMember> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MenuBar(),
        drawer: Menu(),
        body: Column(
          children: [
            Dropdown(),
            Consumer<Date>(
              builder: (_, date, __) => ExpenseByMemberBody(),
            ),
          ],
        ));
  }
}

class ExpenseByMemberBody extends StatefulWidget {
  const ExpenseByMemberBody({Key? key}) : super(key: key);

  @override
  State<ExpenseByMemberBody> createState() => _ExpenseByMemberBodyState();
}

class _ExpenseByMemberBodyState extends State<ExpenseByMemberBody> {
  NumberUtils numberUtils = NumberUtils();
  DateUtils2 dateUtils = DateUtils2();
  double totalSumPrice = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strtDt = context.read<Date>().getStrtDt();
    String endDt = context.read<Date>().getEndDt();

    return FutureBuilder(
        future: _getExpenseByMemberList(strtDt, endDt),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error가 발생하게 될 경우 반환하게 되는 부분
          else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 15),
              ),
            );
          }
          // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
          else {
            List<Widget> _result = <Widget>[];

            for (var i = 0; i < snapshot.data.length; i++) {
              _result.add(_makeCard(snapshot.data[i]));
            }
            return Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: _result,
            ));
          }
        });
  }

  Widget _makeCard(dynamic element) {
    double pricePercent = 0;

    if (totalSumPrice > 0) {
      pricePercent = element['sum_price'] / totalSumPrice;
    }

    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(10),
          shadowColor: Colors.blue,
          elevation: 8,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 199, 218, 251),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipOval(
                          child: Image.asset(
                              Config.AVATAR_INFO[element['member_id']]),
                        ),
                      )),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(element['member_nm'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(numberUtils.comma(element['sum_price']),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  ' (' +
                                      (pricePercent * 100)
                                          .toStringAsFixed(2)
                                          .toString() +
                                      '%)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ])
                      ]),
                  subtitle: Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: LinearPercentIndicator(
                      lineHeight: 4.0,
                      percent: pricePercent,
                      progressColor: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange
                      ][int.parse(element['member_id']) - 1],
                    ),
                  ),
                  onTap: () => _navigate(context, element)),
            ],
          ),
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Future<List<dynamic>> _getExpenseByMemberList(
      String strtDt, String endDt) async {
    var url = Uri.parse(
        Config.API_URL + 'member/sum?strtDt=' + strtDt + '&endDt=' + endDt);
    List<dynamic> resultData = [];
    totalSumPrice = 0;

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['result_data'];
        resultData.sort((a, b) => b['sum_price'].compareTo(a['sum_price']));

        for (var i = 0; i < resultData.length; i++) {
          totalSumPrice += resultData[i]['sum_price'];
        }
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  void _navigate(BuildContext context, dynamic element) async {
    if (element != null) {
      await Navigator.pushNamed(context, '/accountList',
              arguments: AccountListParameter(
                  searchDivisionId: '3', searchMemberId: element['member_id']))
          .then((value) {
        setState(() {});
      });
    }
  }
}
