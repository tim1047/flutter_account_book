import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/widget/legend_widget.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/utils/number_utils.dart';

class MyAssetAccum extends StatelessWidget {
  const MyAssetAccum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: menubar.MenuBar(),
        drawer: Menu(),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Dropdown(),
            Consumer<Date>(
              builder: (_, date, __) => MyAssetAccumBody(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )));
  }
}

class MyAssetAccumBody extends StatefulWidget {
  const MyAssetAccumBody({Key? key}) : super(key: key);

  @override
  State<MyAssetAccumBody> createState() => _MyAssetAccumState();
}

class _MyAssetAccumState extends State<MyAssetAccumBody> {
  static const List<Color> _legendColorList = [
    Color(0xff632af2),
    Color(0xffffb3ba),
    Color(0xff578eff),
    Color.fromARGB(255, 175, 227, 54),
    Color.fromARGB(255, 221, 10, 10),
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 255, 108, 3),
    Color.fromARGB(255, 15, 6, 0),
  ];
  static const betweenSpace = 1000000;
  DateUtils2 dateUtils = DateUtils2();
  NumberUtils numberUtils = NumberUtils();
  List<String> _accumDtList = [];
  double maxY = 0;

  BarChartGroupData generateGroupData(int x, dynamic resultList) {
    List<BarChartRodData> _barRods = [];
    double fromY = 0;
    double toY = 0;
    int debt = 0;

    for (var i = 1; i < resultList.length; i++) {
      if (resultList[i]['asset_id'] == '6') {
        debt = resultList[i]['total_sum_price'];
      }
    }

    for (var i = 1; i < resultList.length; i++) {
      if (resultList[i]['asset_id'] == '5') {
        toY = toY + resultList[i]['total_sum_price'] - debt;
      } else if (resultList[i]['asset_id'] == '6') {
        continue;
      } else {
        toY = toY + resultList[i]['total_sum_price'];
      }

      _barRods.add(
        BarChartRodData(
          fromY: fromY,
          toY: toY,
          color: _legendColorList[int.parse(resultList[i]['asset_id']) - 1],
          width: 5,
        ),
      );

      fromY = toY + betweenSpace;
    }

    if (maxY < fromY) {
      maxY = fromY;
    }

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: _barRods,
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff787694),
      fontSize: 12,
    );
    String text = _accumDtList[value.toInt()];

    return Padding(
      child:
          Text(text.substring(0, 4) + '.' + text.substring(4, 6), style: style),
      padding: const EdgeInsets.only(
        top: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String strtDt = context.read<Date>().getStrtDt();
    strtDt = dateUtils.DateToYYYYMMDD(
        dateUtils.stringToDateTime(strtDt).subtract(const Duration(days: 120)));
    String endDt = context.read<Date>().getEndDt();
    final Size size = MediaQuery.of(context).size;

    return FutureBuilder(
        future: _getMyAssetAccum(strtDt, endDt),
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
            List<Legend> _legendList = [];
            List<BarChartGroupData> _groupDataList = [];
            _accumDtList = [];
            Map<String, dynamic> assetInfo = {};

            for (var i = 1;
                i < snapshot.data[snapshot.data.length - 1]['data'].length;
                i++) {
              if (i != 6) {
                _legendList.add(_getLengend(
                    snapshot.data[snapshot.data.length - 1]['data'][i], i - 1));
              }
            }

            for (var i = 0; i < snapshot.data.length; i++) {
              _accumDtList.add(snapshot.data[i]['accum_dt']);
              _groupDataList
                  .add(generateGroupData(i, snapshot.data[i]['data']));
              assetInfo =
                  _calculateAssetInfo(assetInfo, snapshot.data[i]['data']);
            }

            return Column(children: [
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      LegendsListWidget(
                        legends: _legendList,
                      ),
                      const SizedBox(height: 14),
                      AspectRatio(
                        aspectRatio: size.width / (size.height * 0.7),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceEvenly,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(),
                              rightTitles: AxisTitles(),
                              topTitles: AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: bottomTitles,
                                  reservedSize: 16,
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(enabled: false),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            barGroups: _groupDataList,
                            maxY: maxY,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: _makeListViewCard(assetInfo),
              )
            ]);
          }
        });
  }

  Future<List<dynamic>> _getMyAssetAccum(String strtDt, String endDt) async {
    var url = Uri.parse(
        Config.API_URL + 'my_asset/accum?strtDt=' + strtDt + '&endDt=' + endDt);

    List<dynamic> resultData = [];

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

  Legend _getLengend(dynamic result, int idx) {
    return Legend(result['asset_nm'], _legendColorList[idx]);
  }

  Map<String, dynamic> _calculateAssetInfo(
      Map<String, dynamic> assetInfo, List<dynamic> element) {
    for (int i = 0; i < element.length; i++) {
      if (!assetInfo.containsKey(element[i]['asset_id'])) {
        assetInfo[element[i]['asset_id']] = <String, dynamic>{};
        assetInfo[element[i]['asset_id']]['data'] = [];
      }

      assetInfo[element[i]['asset_id']]['asset_nm'] = element[i]['asset_nm'];

      double totalSumPriceDiff = 0;
      double totalSumPriceDiffPercentage = 0;
      var dataLength = assetInfo[element[i]['asset_id']]['data'].length;

      if (dataLength > 0) {
        totalSumPriceDiff = element[i]['total_sum_price'] -
            assetInfo[element[i]['asset_id']]['data'][dataLength - 1]
                ['total_sum_price'];
        totalSumPriceDiffPercentage = (element[i]['total_sum_price'] -
                assetInfo[element[i]['asset_id']]['data'][dataLength - 1]
                    ['total_sum_price']) /
            assetInfo[element[i]['asset_id']]['data'][dataLength - 1]
                ['total_sum_price'] *
            100;
      }
      assetInfo[element[i]['asset_id']]['data'].add({
        'accum_dt': element[i]['accum_dt'],
        'total_sum_price': (element[i]['total_sum_price'] is double)
            ? element[i]['total_sum_price'].toInt()
            : element[i]['total_sum_price'],
        'total_sum_price_diff': totalSumPriceDiff.toInt(),
        'total_sum_price_diff_percentage': totalSumPriceDiffPercentage
      });
    }
    return assetInfo;
  }

  List<Widget> _makeListView(Map<String, dynamic> assetInfo) {
    List<Widget> _listViewList = [];

    getTextColor(int val) {
      if (val > 0) {
        return Colors.red;
      } else if (val < 0) {
        return Colors.blue;
      } else {
        return Colors.black;
      }
    }

    _listViewList.add(Text(assetInfo['asset_nm'],
        style: TextStyle(fontWeight: FontWeight.bold)));
    _listViewList.add(Divider(
      thickness: 1,
      color: Colors.grey,
    ));

    for (int i = 0; i < assetInfo['data'].length; i++) {
      _listViewList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(assetInfo['data'][i]['accum_dt'].substring(0, 4) +
              '년 ' +
              assetInfo['data'][i]['accum_dt'].substring(4, 6) +
              '월'),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(numberUtils.comma(assetInfo['data'][i]['total_sum_price']),
                style: TextStyle(
                    color: getTextColor(
                        assetInfo['data'][i]['total_sum_price_diff']),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(
              ' ( ' +
                  numberUtils
                      .comma(assetInfo['data'][i]['total_sum_price_diff']) +
                  ' )' +
                  ' ( ' +
                  assetInfo['data'][i]['total_sum_price_diff_percentage']
                      .toStringAsFixed(2) +
                  '%' +
                  ' )',
              style: TextStyle(
                  color: getTextColor(
                      assetInfo['data'][i]['total_sum_price_diff']),
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            )
          ]),
        ],
      ));
      _listViewList.add(Divider(
        thickness: 1,
        color: Colors.grey,
      ));
    }
    return _listViewList;
  }

  List<Widget> _makeListViewCard(Map<String, dynamic> assetInfo) {
    List<Widget> _listViewCardList = [];

    for (var key in assetInfo.keys) {
      _listViewCardList.add(Card(
          margin: EdgeInsets.all(10),
          shadowColor: Colors.blue,
          elevation: 8,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white)),
          child: ListView(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              primary: false,
              children: _makeListView(assetInfo[key]))));
    }
    return _listViewCardList;
  }
}
