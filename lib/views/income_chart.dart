import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:account_book/config/config.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/provider/date.dart';

class IncomeChart extends StatelessWidget {
  const IncomeChart({Key? key}) : super(key: key);

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
              builder: (_, date, __) => IncomeChartBody(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )));
  }
}

class IncomeChartBody extends StatefulWidget {
  const IncomeChartBody({Key? key}) : super(key: key);

  @override
  State<IncomeChartBody> createState() => _IncomeChartBodyState();
}

class _IncomeChartBodyState extends State<IncomeChartBody> {
  NumberUtils numberUtils = NumberUtils();
  double maxY = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    String procDt = context.read<Date>().getYYYYMM();

    return FutureBuilder(
        future: _getDivisionSum(procDt),
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
            return Column(children: [
              Card(
                  margin: EdgeInsets.all(10),
                  shadowColor: Color(0xff2c4260),
                  elevation: 8,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white)),
                  child: Row(children: [
                    Text('  한달에 평균 '),
                    Text(
                        numberUtils.comma(snapshot.data['avg_total_sum_price']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(' 수입이 있어요')
                  ])),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              AspectRatio(
                aspectRatio: size.width / (size.height * 0.7),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  color: const Color(0xff2c4260),
                  child: BarChart(
                    BarChartData(
                        barTouchData: barTouchData,
                        titlesData: titlesData,
                        borderData: borderData,
                        barGroups: barGroups(snapshot.data),
                        gridData: FlGridData(show: false),
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY),
                  ),
                ),
              )
            ]);
          }
        });
  }

  Future<Map<String, dynamic>> _getDivisionSum(String procDt) async {
    var url = Uri.parse(Config.API_URL + 'division/1/sum?procDt=' + procDt);

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

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              numberUtils.comma(rod.toY.round()),
              const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text = value.toString() + '월';
    if (value == 0) {
      text = '평균';
    }
    return Center(child: Text(text, style: style));
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  final _barsGradient = const LinearGradient(
    colors: [
      Colors.lightBlueAccent,
      Colors.greenAccent,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> barGroups(dynamic element) {
    List<BarChartGroupData> barGroups = [];
    maxY = 0;

    for (var i = 0; i < element['data'].length; i++) {
      if (i == element['data'].length - 1) {
        barGroups.add(
          BarChartGroupData(
            x: element['data'][i]['month'],
            barRods: [
              BarChartRodData(
                  toY: element['data'][i]['total_sum_price'],
                  color: Colors.redAccent)
            ],
            showingTooltipIndicators: [0],
          ),
        );
      } else {
        barGroups.add(
          BarChartGroupData(
            x: element['data'][i]['month'],
            barRods: [
              BarChartRodData(
                toY: element['data'][i]['total_sum_price'],
                gradient: _barsGradient,
              )
            ],
            showingTooltipIndicators: [0],
          ),
        );
      }

      if (element['data'][i]['total_sum_price'] >= maxY) {
        maxY = element['data'][i]['total_sum_price'];
      }
      maxY *= Config.BARCHART_PADDING;
    }

    barGroups.add(
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: element['avg_total_sum_price'],
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: [0],
      ),
    );
    return barGroups;
  }
}
