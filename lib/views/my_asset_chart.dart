import 'dart:async';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/provider/date.dart';

class MyAssetChart extends StatefulWidget {
  const MyAssetChart({Key? key}) : super(key: key);

  @override
  State<MyAssetChart> createState() => _MyAssetChartState();
}

class _MyAssetChartState extends State<MyAssetChart> {
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
              builder: (_, date, __) => MyAssetChartBody(),
            ),
          ],
        ));
  }
}

class MyAssetChartBody extends StatefulWidget {
  const MyAssetChartBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAssetChartBodyState();
}

class _MyAssetChartBodyState extends State {
  int touchedIndex = -1;
  DateUtils2 dateUtils = DateUtils2();
  NumberUtils numberUtils = NumberUtils();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strtDt = context.read<Date>().getStrtDt();
    String endDt = context.read<Date>().getEndDt();

    return FutureBuilder(
        future: _getMyAssetList(strtDt, endDt),
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

            for (var k in snapshot.data['data'].keys) {
              _result.add(_makeCard(
                  snapshot.data['data'][k], snapshot.data['totSumPrice']));
            }

            return Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: _result,
            ));
          }
        });
  }

  Widget _makeCard(dynamic element, int totSumPrice) {
    double pricePercent = element['assetTotSumPrice'] == 0
        ? 0
        : element['assetTotSumPrice'] / totSumPrice;

    List<Widget> _listTiles = [];
    String assetId = element['data'][0]['assetId'];

    for (var i = 0; i < element['data'].length; i++) {
      var e = element['data'][i];
      double pricePercent =
          e['sumPrice'] == 0 ? 0 : e['sumPrice'] / element['assetTotSumPrice'];

      _listTiles.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Config.ASSET_ICON_INFO[assetId]!,
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          e['myAssetGroupId'] == '0'
                              ? e['myAssetNm']
                              : e['myAssetGroupNm'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ]),
                    Row(
                      children: [
                        Text(
                          numberUtils.comma(e['sumPrice']),
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
                    progressColor: Colors.deepOrange.shade200,
                  ),
                ),
                onTap: () => {}),
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
                          Config.ASSET_ICON_INFO[assetId]!,
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Text(
                              element['assetNm'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ]),
                        Row(
                          children: [
                            Text(
                              numberUtils.comma(element['assetTotSumPrice']),
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

  Future<Map<String, dynamic>> _getMyAssetList(
      String strtDt, String endDt) async {
    var url = Uri.parse(
        Config.V2_API_URL + 'my-asset?strtDt=' + strtDt + '&endDt=' + endDt);

    Map<String, dynamic> resultData = {};

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['resultData'];
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }
}
