import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/views/my_asset.dart';

class MyAssetList extends StatefulWidget {
  const MyAssetList({Key? key}) : super(key: key);

  @override
  State<MyAssetList> createState() => _MyAssetListState();
}

class _MyAssetListState extends State<MyAssetList> {
  late FToast fToast;
  DateUtils2 dateUtils = DateUtils2();

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: menubar.MenuBar(),
      drawer: Menu(),
      body: Column(
        children: [
          Dropdown(),
          Consumer<Date>(
            builder: (_, date, __) => MyAssetListBody(),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateAndToast(context), child: Icon(Icons.add)),
    );
  }

  void _navigateAndToast(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/myAsset',
            arguments: MyAssetParameter())
        .then((value) {
      setState(() {});

      if (value != null) {
        _showToast(value.toString());
      }
    });
  }

  _showToast(String value) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.lightBlue,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(value),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}

class MyAssetListBody extends StatefulWidget {
  const MyAssetListBody({Key? key}) : super(key: key);

  @override
  State<MyAssetListBody> createState() => _MyAssetListBodyState();
}

class _MyAssetListBodyState extends State<MyAssetListBody> {
  NumberUtils numberUtils = NumberUtils();
  DateUtils2 dateUtils = DateUtils2();
  late FToast fToast;
  bool isDelayed = true;

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String procDt = dateUtils.DateToYYYYMMDD(DateTime.now());

    return FutureBuilder(
        future: _getMyAssetList(procDt, procDt),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else if (snapshot.connectionState != ConnectionState.done) {
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
            return Expanded(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(children: [
                  Text(
                      '총 자산 : ' +
                          numberUtils.comma(snapshot.data['tot_sum_price']),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text('|',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  Text(
                      '순자산 : ' +
                          numberUtils
                              .comma(snapshot.data['tot_net_worth_sum_price']),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                      onPressed: () => {
                            setState(() {
                              isDelayed = false;
                            })
                          },
                      icon: Icon(Icons.refresh_rounded))
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(children: [
                  Text(
                      '환율(\$): ' +
                          numberUtils.comma(snapshot.data['usd_krw_rate']),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text('|',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  Text(
                      '환율(￥): ' +
                          numberUtils.comma(
                              (snapshot.data['jpy_krw_rate'] * 100).toInt()),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text('|',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))),
                  Text(snapshot.data['my_asset_accum_dts'] + ' 기준',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                ]),
              ),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              _makeCard(snapshot.data['data'])
            ]));
          }
        });
  }

  Widget _makeCard(dynamic assetInfo) {
    List<dynamic> _result = <dynamic>[];

    for (var k in assetInfo.keys) {
      _result.addAll(assetInfo[k]['data']);
    }

    return Expanded(
      child: GroupedListView<dynamic, String>(
        elements: _result, // 리스트에 사용할 데이터 리스트
        groupBy: (element) => element['asset_nm'], // 데이터 리스트 중 그룹을 지정할 항목
        //order: GroupedListOrder.DESC, //정렬(오름차순)
        useStickyGroupSeparators: false, //가장 위에 그룹 이름을 고정시킬 것인지
        itemComparator: (item1, item2) =>
            item1['sum_price'] < item2['sum_price'] ? 1 : -1,
        groupHeaderBuilder: (dynamic element) => Padding(
          //그룹 타이틀 모양
          padding: const EdgeInsets.all(8.0),
          child: Text(
            element['asset_nm'] +
                ' ( ' +
                numberUtils.comma(
                    (assetInfo[element['asset_id']]['asset_tot_sum_price'])) +
                ' )',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        indexedItemBuilder: (c, element, index) {
          //항목들 모양 처리
          return Card(
            margin: EdgeInsets.all(10),
            shadowColor: Colors.blue,
            elevation: 8,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[_makeTile(element)],
            ),
          );
        },
      ),
    );
  }

  Widget _makeTile(dynamic element) {
    Widget tile;

    if (element['data'] == null) {
      tile = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ListTile(
              title: Text(numberUtils.comma(element['sum_price']),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      element['my_asset_nm'] +
                          ' | ' +
                          element['qty'].toString() +
                          '개',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              onTap: () => _navigateAndToast(context, element),
            ),
          ),
        ],
      );
    } else {
      List<Widget> _listTiles = [];

      for (var i = 0; i < element['data'].length; i++) {
        dynamic e = element['data'][i];
        _listTiles.add(ListTile(
          title: Text(numberUtils.comma(e['sum_price']),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e['my_asset_nm'] + ' | ' + e['qty'].toString() + '개',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
          onTap: () => _navigateAndToast(context, e),
        ));
      }

      tile = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ExpansionTile(
              title: Text(numberUtils.comma(element['sum_price']),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(element['my_asset_group_nm'],
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              children: _listTiles,
            ),
          ),
        ],
      );
    }
    return tile;
  }

  void _navigateAndToast(BuildContext context, var element) async {
    final result = await Navigator.pushNamed(context, '/myAsset',
            arguments: MyAssetParameter(
                assetId: element['asset_id'],
                myAssetNm: element['my_asset_nm'],
                ticker: element['ticker'],
                priceDivCd: element['price_div_cd'],
                price: element['price'],
                qty: element['qty'],
                exchangeRateYn: element['exchange_rate_yn'],
                isInsert: false,
                myAssetId: element['my_asset_id']))
        .then((value) {
      setState(() {});

      if (value != null) {
        _showToast(value.toString());
      }
    });
  }

  _showToast(String value) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.lightBlue,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(value),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  Future<Map<String, dynamic>> _getMyAssetList(
      String strtDt, String endDt) async {
    var urlString =
        Config.API_URL + 'my_asset?strtDt=' + strtDt + '&endDt=' + endDt;
    if (!isDelayed) {
      urlString = urlString + '&type=realtime';
      isDelayed = true;
    }

    var url = Uri.parse(urlString);

    Map<String, dynamic> resultData = {};

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['result_data'];
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }
}
