import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/widget/indicator.dart';
import 'package:account_book/widget/menubar.dart';
import 'package:account_book/widget/menu.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/widget/dropdown.dart';


class MyAssetChart extends StatelessWidget {
  const MyAssetChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: MenuBar(),
      drawer: Menu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Dropdown(),
            MyAssetChartBody()
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      )
    );
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

  List<PieChartSectionData>? _result = [];
  List<PieChartSectionData>? _resultNetWorth = [];

  List<Widget> _indicators = [];
  List<Widget> _indicatorsNetWorth = [];
  final List<Color> _indicatorColors = [
    Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.black, Colors.orange, Colors.purple
  ];

  @override
  void initState() {
    super.initState();
    showingSections();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AspectRatio(
      aspectRatio: size.width / (size.height * 2),
      child: Column(
        children: <Widget>[
          Divider( thickness: 1, color: Colors.grey, ),
          Text('자산 비율', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(
            height: size.height * 0.5,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback:
                      (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: _result
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _indicators,
              )
            ],
          ),
          Divider( thickness: 1, color: Colors.grey, ),
          Text('순자산 비율', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(
            height: size.height * 0.5,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback:
                      (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: _resultNetWorth
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _indicatorsNetWorth,
              )
            ],
          ),
        ],
      ),
    );
  }

  void showingSections() {
    String procDt = dateUtils.DateToYYYYMMDD(DateTime.now());

    _getMyAssetList(procDt, procDt).then(
      (resultList) => setState(() {
        _result = _makeChart(resultList);
        _resultNetWorth = _makeNetWorthChart(resultList);
      })
    );
  }

  List<PieChartSectionData> _makeChart(dynamic resultList) {
    List<dynamic> myAssetList = [];
    num totSumPrice = 0;
    int i = 0;

    for (var r in resultList['data'].keys) {
      myAssetList.add(resultList['data'][r]);
     
      if (r != '6') {
        totSumPrice += (resultList['data'][r]['asset_tot_sum_price']).abs();
      }

      if (r == '5') {
        resultList['data'][r]['asset_tot_sum_price'] -= resultList['data']['6']['asset_tot_sum_price'];
      }

      _indicators.add(
        Indicator(
          color: _indicatorColors[i++],
          text: resultList['data'][r]['asset_nm'] + ' (' + numberUtils.comma((resultList['data'][r]['asset_tot_sum_price']).abs()) + ')',
          isSquare: true,
        ),
      );
      _indicators.add(
        SizedBox(
          height: 4,
        ),
      );
    }

    return List.generate(myAssetList.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 4:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 5:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'].abs() / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'].abs() / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 6:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'].abs() / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'].abs() / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }

  List<PieChartSectionData> _makeNetWorthChart(dynamic resultList) {
    List<dynamic> myAssetList = [];
    num totSumPrice = 0;
    int i = 0;

    for (var r in resultList['data'].keys) {
      if (r != '6') {
        myAssetList.add(resultList['data'][r]);

        totSumPrice += (resultList['data'][r]['asset_tot_sum_price']).abs();

        _indicatorsNetWorth.add(
          Indicator(
            color: _indicatorColors[i++],
            text: resultList['data'][r]['asset_nm'] + ' (' + numberUtils.comma((resultList['data'][r]['asset_tot_sum_price']).abs()) + ')',
            isSquare: true,
          ),
        );
        _indicatorsNetWorth.add(
          SizedBox(
            height: 4,
          ),
        );
      }
    }

    return List.generate(myAssetList.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 4:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 5:
          return PieChartSectionData(
            color: _indicatorColors[i],
            value: myAssetList[i]['asset_tot_sum_price'] / totSumPrice,
            title: (myAssetList[i]['asset_tot_sum_price'] / totSumPrice * 100).toStringAsFixed(2).toString() + '%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }

  Future<Map<String, dynamic>> _getMyAssetList(String strtDt, String endDt) async {
    var url = Uri.parse(
      Config.API_URL + 'my_asset?strtDt=' + strtDt + '&endDt=' + endDt
    );

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