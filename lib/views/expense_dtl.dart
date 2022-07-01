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


class ExpenseDtl extends StatefulWidget {
  const ExpenseDtl({Key? key}) : super(key: key);

  @override
  State<ExpenseDtl> createState() => _ExpenseDtlState();
}

class _ExpenseDtlState extends State<ExpenseDtl> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuBar(),
      drawer: Menu(),
      body: Column(
        children: [
          Dropdown(),
          Consumer<Date>(
            builder: (_, date, __) => ExpenseDtlBody(),
          ),
        ],
      )
    );
  }
}

class ExpenseDtlBody extends StatefulWidget {
  const ExpenseDtlBody({Key? key}) : super(key: key);

  @override
  State<ExpenseDtlBody> createState() => _ExpenseDtlBodyState();
}

class _ExpenseDtlBodyState extends State<ExpenseDtlBody> {
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
      future: _getExpenseDtlList(strtDt, endDt),
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
    double pricePercent = element['sum_price'] == 0 ? 0 : element['sum_price'] / element['total_sum_price'];

    return Column(
      children: [
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Config.CATEGORY_SEQ_ICON_INFO[element['category_id'] + element['category_seq']]!,
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            element['category_seq_nm'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Visibility(
                          visible: element['fixed_price_yn'] == 'Y',
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Badge(
                              toAnimate: false,
                              shape: BadgeShape.square,
                              badgeColor: Colors.yellow,
                              borderRadius: BorderRadius.circular(8),
                              badgeContent: Text('고정지출', style: TextStyle(color: Colors.black, fontSize: 12)),
                            ),
                          ),
                        ),
                      ]
                    ),
                    Row(
                      children: [
                        Text(
                          numberUtils.comma(element['sum_price']),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          ' (' + (pricePercent * 100).toStringAsFixed(2).toString() + '%)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
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
                    progressColor: Colors.green,
                  ),
                ),
                onTap: () => _navigate(context, element)
              )
            ],
          ),
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    ); 
  }

  Future<List<dynamic>> _getExpenseDtlList(String strtDt, String endDt) async {
    var url = Uri.parse(Config.API_URL + 'category_seq_sum/3?strtDt=' + strtDt + '&endDt=' + endDt);
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

  void _navigate (BuildContext context, dynamic element) async {
    if (element != null) {
      await Navigator.pushNamed(
        context, 
        '/accountList',
        arguments: AccountListParameter(
          searchCategoryId: element['category_id'],
          searchCategorySeq: element['category_seq'],
          searchDivisionId: '3'
        )
      ).then((value) {
        setState(() {});
      });
    }
  }
}