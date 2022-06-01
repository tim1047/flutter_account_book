import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:account_book/config/config.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/widget/menubar.dart';
import 'package:account_book/widget/menu.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/widget/indicator.dart';

class ExpenseDailyChart extends StatefulWidget {
  const ExpenseDailyChart({Key? key}) : super(key: key);

  @override
  State<ExpenseDailyChart> createState() => _ExpenseDailyChartState();
}

class _ExpenseDailyChartState extends State<ExpenseDailyChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MenuBar(),
        drawer: Menu(),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Dropdown(),
            Consumer<Date>(
              builder: (_, date, __) => ExpenseDailyChartBody(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )));
  }
}

class ExpenseDailyChartBody extends StatefulWidget {
  const ExpenseDailyChartBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExpenseDailyChartBodyState();
}

class ExpenseDailyChartBodyState extends State<ExpenseDailyChartBody> {
  NumberUtils numberUtils = NumberUtils();
  bool touchingGraph = false;
  List<int> showIndexes = [DateTime.now().day - 1];
  final double intervalLeftTiles = 500000;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    List<Widget> _indicators = [];
    final List<Color> _indicatorColors = [
      Color(0xff4af699),
      Color.fromARGB(255, 37, 205, 243),
      Color.fromARGB(255, 227, 47, 11),
    ];

    return FutureBuilder(
        future: _getExpenseDailySum(),
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
            _indicators = [];
            var header = snapshot.data[0];

            for (int i = 1; i < header.length; i++) {
              _indicators.add(
                Indicator(
                  color: _indicatorColors[i - 1],
                  text: header[i],
                  isSquare: true,
                  textColor: Colors.white,
                ),
              );
              _indicators.add(
                SizedBox(
                  width: 5,
                ),
              );
            }

            List<LineChartBarData> lineBarsData1 = [];
            List<FlSpot> lineBarsFlSpot1 = [];
            List<FlSpot> lineBarsFlSpot2 = [];
            List<FlSpot> lineBarsFlSpot3 = [];

            List<int> maxList = [];
            for (int i = 1; i < snapshot.data.length; i++) {
              var element = snapshot.data[i];
              lineBarsFlSpot1.add(FlSpot(i.toDouble(), element[1]));
              lineBarsFlSpot2.add(FlSpot(i.toDouble(), element[2]));
              lineBarsFlSpot3.add(FlSpot(i.toDouble(), element[3]));

              if (i == snapshot.data.length - 1) {
                for (int j = 1; j < element.length; j++) {
                  maxList.add(element[j]);
                }
              }
            }

            lineBarsData1.add(LineChartBarData(
                isCurved: true,
                color: const Color(0xff4af699),
                barWidth: 8,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                spots: lineBarsFlSpot1,
                showingIndicators: showIndexes));

            lineBarsData1.add(LineChartBarData(
                isCurved: true,
                color: Color.fromARGB(255, 37, 205, 243),
                barWidth: 8,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                spots: lineBarsFlSpot2,
                showingIndicators: showIndexes));

            lineBarsData1.add(LineChartBarData(
              isCurved: true,
              color: Color.fromARGB(255, 227, 47, 11),
              barWidth: 8,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
              spots: lineBarsFlSpot3,
              showingIndicators: showIndexes,
            ));

            LineChartData sampleData1 = LineChartData(
              lineTouchData: getLineTouchData1(header),
              gridData: gridData,
              titlesData: titlesData1,
              borderData: borderData,
              lineBarsData: lineBarsData1,
              showingTooltipIndicators: showIndexes.map((index) {
                List<LineBarSpot> showingTooltipIndicators = [];
                for (int i = 0; i < lineBarsData1.length; i++) {
                  showingTooltipIndicators.add(LineBarSpot(
                      lineBarsData1[i],
                      lineBarsData1.indexOf(lineBarsData1[i]),
                      lineBarsData1[i].spots[index]));
                }
                return ShowingTooltipIndicators(showingTooltipIndicators);
              }).toList(),
              minX: 1,
              maxX: 31,
              maxY:
                  ((maxList.reduce(max).toDouble() ~/ intervalLeftTiles) + 1) *
                      intervalLeftTiles,
              minY: 0,
            );

            return AspectRatio(
              aspectRatio: size.width / (size.height * 0.8),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2c274c),
                      Color(0xff46426c),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(
                          height: 37,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _indicators,
                        ),
                        const SizedBox(
                          height: 37,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 16.0, left: 6.0),
                            child: LineChart(
                              sampleData1,
                              swapAnimationDuration:
                                  const Duration(milliseconds: 250),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Future<List<dynamic>> _getExpenseDailySum() async {
    String prevStrtDt = context.read<Date>().getPrevStrtDt(2);
    String endDt = context.read<Date>().getEndDt();

    var url = Uri.parse(Config.API_URL +
        'expense_sum_daily?strtDt=' +
        prevStrtDt +
        '&endDt=' +
        endDt);

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

  LineTouchData getLineTouchData1(var header) {
    return LineTouchData(
      touchCallback: (touchEvent, response) {
        if (touchEvent is FlTapUpEvent || touchEvent is FlPanEndEvent) {
          setState(() {
            if (response != null) {
              if (response.lineBarSpots != null) {
                showIndexes = [response.lineBarSpots![0].x.toInt() - 1];
              }
            }
            touchingGraph = false;
          });
        } else if (touchEvent is FlTapDownEvent ||
            touchEvent is FlPanStartEvent) {
          setState(() {
            touchingGraph = true;
          });
        }
      },
      enabled: touchingGraph,
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
          return lineBarsSpot.map((lineBarSpot) {
            return LineTooltipItem(
                header[lineBarSpot.barIndex + 1] +
                    ' ' +
                    numberUtils.comma(lineBarSpot.y.toInt()),
                TextStyle(
                    color: lineBarSpot.bar.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                textAlign: TextAlign.start);
          }).toList();
        },
      ),
    );
  }

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff75729e),
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    String text = numberUtils.comma(value.toInt());
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: intervalLeftTiles,
        reservedSize: 60,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff72719b),
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    Widget text = Text(value.toInt().toString(), style: style);

    return Padding(child: text, padding: const EdgeInsets.only(top: 10.0));
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 2,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 4),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );
}
