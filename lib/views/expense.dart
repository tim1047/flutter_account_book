import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:badges/badges.dart' as badge;

import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/views/account_list.dart';

class Expense extends StatefulWidget {
  const Expense({Key? key}) : super(key: key);

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: menubar.MenuBar(),
        drawer: Menu(),
        body: Column(
          children: [
            Dropdown(),
            Consumer<Date>(
              builder: (_, date, __) => ExpenseBody(),
            ),
          ],
        ));
  }
}

class ExpenseBody extends StatefulWidget {
  const ExpenseBody({Key? key}) : super(key: key);

  @override
  State<ExpenseBody> createState() => _ExpenseBodyState();
}

class _ExpenseBodyState extends State<ExpenseBody> {
  NumberUtils numberUtils = NumberUtils();
  DateUtils2 dateUtils = DateUtils2();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strtDt = context.read<Date>().getStrtDt();
    String endDt = context.read<Date>().getEndDt();

    return FutureBuilder(
        future: _getExpenseList(strtDt, endDt),
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
    double pricePercent = element['sum_price'] == 0
        ? 0
        : element['sum_price'] / element['total_sum_price'];

    List<Widget> _listTiles = [];

    for (var i = 0; i < element['data'].length; i++) {
      var e = element['data'][i];
      double pricePercent =
          e['sum_price'] == 0 ? 0 : e['sum_price'] / element['sum_price'];

      _listTiles.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Config.CATEGORY_SEQ_ICON_INFO[
                        element['category_id'] + e['category_seq']]!,
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        e['category_seq_nm'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ]),
                  Row(
                    children: [
                      Text(
                        numberUtils.comma(e['sum_price']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        ' (' +
                            (pricePercent * 100).toStringAsFixed(2).toString() +
                            '%)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
              subtitle: Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: LinearPercentIndicator(
                  lineHeight: 4.0,
                  percent: pricePercent,
                  progressColor: Colors.deepOrange.shade200,
                ),
              ),
              onTap: () => _navigate(context, element['division_id'],
                  element['category_id'], e['category_seq']),
            ),
          ),
        ],
      ));
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
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Config.CATEGORY_ICON_INFO[element['category_id']]!,
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Text(
                              element['category_nm'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ]),
                        Row(
                          children: [
                            Text(
                              numberUtils.comma(element['sum_price']),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              ' (' +
                                  (pricePercent * 100)
                                      .toStringAsFixed(2)
                                      .toString() +
                                  '%)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: LinearPercentIndicator(
                        lineHeight: 4.0,
                        percent: pricePercent,
                        progressColor: Colors.red,
                      ),
                    ),
                    children: _listTiles,
                  ),
                ),
              ],
            )
          ]),
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Future<List<dynamic>> _getExpenseList(String strtDt, String endDt) async {
    var url = Uri.parse(Config.API_URL +
        'division/3/category/sum?strtDt=' +
        strtDt +
        '&endDt=' +
        endDt);
    List<dynamic> resultData = [];

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['result_data'];
        resultData.sort((a, b) => b['sum_price'].compareTo(a['sum_price']));
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  void _navigate(BuildContext context, String divisionId, String categoryId,
      String categorySeq) async {
    await Navigator.pushNamed(context, '/accountList',
            arguments: AccountListParameter(
                searchDivisionId: divisionId,
                searchCategoryId: categoryId,
                searchCategorySeq: categorySeq))
        .then((value) {
      setState(() {});
    });
  }
}
