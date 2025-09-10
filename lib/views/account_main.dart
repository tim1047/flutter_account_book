import 'dart:convert';

import 'package:account_book/widget/dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/views/account_list.dart';

class AccountMain extends StatelessWidget {
  const AccountMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: menubar.MenuBar(),
        drawer: Menu(),
        body: Column(
          children: [
            Dropdown(),
            Expanded(
                child:
                    Consumer<Date>(builder: (_, date, __) => AccountMainBody()))
          ],
        ));
  }
}

class AccountMainBody extends StatefulWidget {
  const AccountMainBody({Key? key}) : super(key: key);

  @override
  _AccountMainBodyState createState() => _AccountMainBodyState();
}

class _AccountMainBodyState extends State<AccountMainBody> {
  NumberUtils numberUtils = NumberUtils();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strtDt = context.watch<Date>().getStrtDt();
    String endDt = context.watch<Date>().getEndDt();

    return FutureBuilder(
        future: _getDivsionSum(strtDt, endDt),
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
            for (var k in snapshot.data.keys) {
              _result.add(_makeRow(k, snapshot.data[k]));
            }
            return ListView(
              padding: EdgeInsets.zero,
              children: _result,
            );
          }
        });
  }

  Future<Map<String, dynamic>> _getDivsionSum(
      String strtDt, String endDt) async {
    var url = Uri.parse(Config.V2_API_URL +
        'division/sum?strtDt=' +
        strtDt +
        '&endDt=' +
        endDt);
    Map<String, dynamic> resultData = {};

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        String body = response.body;
        var result = json.decode(body);

        resultData = result['resultData'];
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _makeRow(String divisionId, dynamic price) {
    Map<String, dynamic> divisionIconInfo = {
      'income': {
        'icon': Icons.attach_money_rounded,
        'name': '수입',
        'color': Colors.blue,
        'divisionId': '1'
      },
      'interest': {
        'icon': Icons.account_balance_wallet_rounded,
        'name': '순수익(수입 - 지출)',
        'color': Colors.green,
        'divisionId': ''
      },
      'expense': {
        'icon': Icons.add_shopping_cart_rounded,
        'name': '지출',
        'color': Colors.red,
        'divisionId': '3'
      },
      'invest': {
        'icon': Icons.currency_bitcoin_rounded,
        'name': '투자',
        'color': Colors.orange,
        'divisionId': '2'
      },
      'investRate': {
        'icon': Icons.percent_rounded,
        'name': '투자율',
        'color': Colors.yellow,
        'divisionId': ''
      },
    };

    return Card(
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
            leading: Icon(divisionIconInfo[divisionId]['icon'],
                size: 50, color: divisionIconInfo[divisionId]['color']),
            title: Text(
              price is int ? numberUtils.comma(price) : price,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(divisionIconInfo[divisionId]['name'],
                style: TextStyle(fontSize: 12)),
            onTap: () =>
                _navigate(context, divisionIconInfo[divisionId]['divisionId']),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String divisionId) async {
    if (divisionId != '') {
      await Navigator.pushNamed(context, '/accountList',
              arguments: AccountListParameter(searchDivisionId: divisionId))
          .then((value) {
        setState(() {});
      });
    }
  }
}
