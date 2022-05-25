import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:badges/badges.dart';

import 'package:account_book/widget/menubar.dart';
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
      resizeToAvoidBottomInset : false,
      appBar: MenuBar(),
      drawer: Menu(),
      body: Column(
        children: [
          Dropdown(),
          Consumer<Date>(
            builder: (_, date, __) => ExpenseBody(),
          ),
        ],
      )
    );
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
          List <Widget> _result = <Widget>[];

          for (var i = 0; i < snapshot.data.length; i++) {
            _result.add(_makeCard(snapshot.data[i]));
          } 
          return Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _result,
            )
          );
        }
      }
    );
  }

  Widget _makeCard(dynamic element) {
    double pricePercent = 1; 
    double planPercent = 1;
    double saveOrWastePercent = element['sum_price'] / element['plan_price'];
    String saveOrWasteStr = '';
    String saveOrWasteEmoji = '';

    if (element['sum_price'] >= element['plan_price']) {
      planPercent = element['plan_price'] / element['sum_price'];
      saveOrWasteStr = '지출';
      saveOrWasteEmoji = '😅';
    } else {
      pricePercent = element['sum_price'] / element['plan_price'];
      saveOrWasteStr = '절약';
      saveOrWasteEmoji = '🤗';
    }

    if (element['sum_price'] == 0) {
      pricePercent = 0;
    }
    if (element['plan_price'] == 0) {
      planPercent = 0;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Config.CATEGORY_ICON_INFO[element['category_id']]!,
              ),
              Text(
                element['category_nm'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Badge(
                  toAnimate: false,
                  shape: BadgeShape.square,
                  badgeColor: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  badgeContent: Text('계획 초과', style: TextStyle(color: Colors.white)),
                  showBadge: (element['sum_price'] > element['plan_price']) && element['plan_price'] != 0 ? true : false,
                ),
              ),
            ]
          ) 
        ),
        Card(
          margin: EdgeInsets.all(10),
          shadowColor: Colors.blue,
          elevation: 8,
          shape:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: BorderSide(color: Colors.white)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Row(
                  children: [
                    Text('실제   '),
                    Text(
                      numberUtils.comma(element['sum_price']),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    )
                  ]
                ),
                subtitle: Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: LinearPercentIndicator(
                    lineHeight: 4.0,
                    percent: pricePercent,
                    progressColor: Colors.blue,
                  ),
                ),
                onTap: () => _navigate(context, element['category_id']),
              ),
              ListTile(
                title: Row(
                  children: [
                    Text('계획   '),
                    Text(
                      numberUtils.comma(element['plan_price']),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    )
                  ]
                ),
                subtitle: Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: LinearPercentIndicator(
                    lineHeight: 4.0,
                    percent: planPercent,
                    progressColor: Colors.red,
                  ),
                ),
                onTap: () => _navigate(context, element['category_id']),
              ),
              Visibility(
                visible: element['plan_price'] > 0,
                child: Divider( thickness: 1, color: Colors.grey, ),
              ),
              Visibility(
                visible: element['plan_price'] > 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Text('계획 대비 '),
                      ),
                      Text(
                        numberUtils.comma((element['sum_price'] - element['plan_price']).abs()),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        ' (' + (saveOrWastePercent * 100).toStringAsFixed(2).toString() + '%) ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Badge(
                          toAnimate: false,
                          shape: BadgeShape.square,
                          badgeColor: saveOrWastePercent > 1 ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          badgeContent: Text(saveOrWasteStr, style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Text(
                        saveOrWasteEmoji,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ),
              ),
            ],
          ),
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    ); 
  }

  Future<List<dynamic>> _getExpenseList(String strtDt, String endDt) async {
    var url = Uri.parse(Config.API_URL + 'category_sum/3?strtDt=' + strtDt + '&endDt=' + endDt);
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

  void _navigate (BuildContext context, String categoryId) async {
    if (categoryId != '') {
      await Navigator.pushNamed(
        context, 
        '/accountList',
        arguments: AccountListParameter(
          searchCategoryId: categoryId,
          searchDivisionId: '3'
        )
      ).then((value) {
        setState(() {});
      });
    }
  }
}