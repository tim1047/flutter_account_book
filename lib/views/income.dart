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

class Income extends StatefulWidget {
  const Income({Key? key}) : super(key: key);

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: menubar.MenuBar(),
        drawer: Menu(),
        body: Column(
          children: [
            Dropdown(),
            Consumer<Date>(
              builder: (_, date, __) => IncomeBody(),
            ),
          ],
        ));
  }
}

class IncomeBody extends StatefulWidget {
  const IncomeBody({Key? key}) : super(key: key);

  @override
  State<IncomeBody> createState() => _IncomeBodyState();
}

class _IncomeBodyState extends State<IncomeBody> {
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
        future: _getIncomeList(strtDt, endDt),
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
                  child: ListTile(
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
                          progressColor: Colors.green,
                        ),
                      ),
                      onTap: () => _navigate(context, element)),
                ),
              ],
            )
          ]),
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Future<List<dynamic>> _getIncomeList(String strtDt, String endDt) async {
    var url = Uri.parse(Config.API_URL +
        'division/1/category/sum?strtDt=' +
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

  void _navigate(BuildContext context, dynamic element) async {
    if (element != null) {
      await Navigator.pushNamed(context, '/accountList',
              arguments: AccountListParameter(
                  searchDivisionId: element['division_id'],
                  searchCategoryId: element['category_id']))
          .then((value) {
        setState(() {});
      });
    }
  }
}
