import 'dart:async';
import 'dart:convert';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/widget/indicator.dart';
import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/widget/dropdown.dart';

class MyAssetChart extends StatelessWidget {
  const MyAssetChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: menubar.MenuBar(),
        drawer: Menu(),
        body: SingleChildScrollView(
            child: Column(
          children: [Dropdown(), MyAssetChartBody()],
          mainAxisAlignment: MainAxisAlignment.center,
        )));
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

  List<ChartData> chartDataList = [];
  List<Color> colorList = [
    Colors.blue,
    Colors.indigo,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.brown,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
    showingSections();
  }

  @override
  Widget build(BuildContext context) {
    NumberUtils numberUtils = NumberUtils();
    final Size size = MediaQuery.of(context).size;

    return Center(
        child: Column(children: [
      SizedBox(
          width: size.width * 0.5,
          height: size.height * 0.5,
          child: SfCircularChart(series: <CircularSeries>[
            // Render pie chart
            PieSeries<ChartData, String>(
                dataLabelMapper: (ChartData data, _) =>
                    data.x + ' ( ' + numberUtils.comma(data.y) + ' )',
                dataLabelSettings: DataLabelSettings(isVisible: true),
                radius: '100%',
                dataSource: chartDataList,
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y),
          ])),
    ]));
  }

  void showingSections() {
    String procDt = dateUtils.DateToYYYYMMDD(DateTime.now());

    _getMyAssetList(procDt, procDt).then((resultList) => setState(() {
          _makeChartData(resultList);
        }));
  }

  void _makeChartData(resultList) {
    num totSumPrice = 0;
    int i = 0;

    for (var r in resultList['data'].keys) {
      if (r != '6') {
        totSumPrice += (resultList['data'][r]['asset_tot_sum_price']).abs();
      }

      if (r == '5') {
        resultList['data'][r]['asset_tot_sum_price'] -=
            resultList['data']['6']['asset_tot_sum_price'];
      }

      chartDataList.add(ChartData(
          resultList['data'][r]['asset_nm'],
          resultList['data'][r]['asset_tot_sum_price'],
          colorList[int.parse(r) - 1]));
    }
  }

  Future<Map<String, dynamic>> _getMyAssetList(
      String strtDt, String endDt) async {
    var url = Uri.parse(
        Config.API_URL + 'my_asset?strtDt=' + strtDt + '&endDt=' + endDt);

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

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final int y;
  final Color color;
}
