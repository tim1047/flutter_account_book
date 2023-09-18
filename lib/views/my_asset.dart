import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:account_book/utils/number_formatter.dart';
import 'package:account_book/widget/menubar.dart' as menubar;
import 'package:account_book/widget/menu.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/utils/number_utils.dart';

class MyAsset extends StatelessWidget {
  const MyAsset({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: menubar.MenuBar(),
      drawer: Menu(),
      body: SingleChildScrollView(
        child: MyAssetBody(),
      ),
    );
  }
}

class MyAssetBody extends StatefulWidget {
  const MyAssetBody({Key? key}) : super(key: key);

  @override
  State<MyAssetBody> createState() => _MyAssetBodyState();
}

class _MyAssetBodyState extends State<MyAssetBody> {
  DateUtils2 dateUtils = DateUtils2();
  NumberUtils numberUtils = NumberUtils();

  String inputMyAssetId = '';
  String inputAssetId = '';
  final myAssetNmController = TextEditingController();
  final tickerController = TextEditingController();
  String inputPriceDivCd = '';
  final priceController = TextEditingController();
  final qtyController = TextEditingController();
  String inputExchangeRateYn = '';

  late Future<List<dynamic>> _assetList;
  bool isInit = true;
  bool isEnablePrice = true;

  @override
  void initState() {
    super.initState();
    _assetList = _getAssetList();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as MyAssetParameter;
    inputMyAssetId = inputMyAssetId == '' ? args.myAssetId : inputMyAssetId;
    inputAssetId = inputAssetId == '' ? args.assetId : inputAssetId;
    inputPriceDivCd = inputPriceDivCd == '' ? args.priceDivCd : inputPriceDivCd;
    inputExchangeRateYn =
        inputExchangeRateYn == '' ? args.exchangeRateYn : inputExchangeRateYn;

    if (isInit) {
      myAssetNmController.text = (args.myAssetNm != '' ? args.myAssetNm : '');
      tickerController.text = args.ticker != '' ? args.ticker : '';
      priceController.text =
          (args.price >= 0 ? numberUtils.comma(args.price.toInt()) : '');
      qtyController.text = args.qty >= 0 ? args.qty.toString() : '';
      isEnablePrice = args.priceDivCd == 'AUTO' ? false : true;
      isInit = false;
    }

    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.check_box_outline_blank_rounded),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('자산')),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getAssetSelectBox())),
            ],
          )),
          Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.attach_money_rounded),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('이름'),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: TextField(
                    controller: myAssetNmController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    )),
              )),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.edit_note_rounded),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('티커')),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: TextField(
                    controller: tickerController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    )),
              )),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.dangerous_rounded),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('가격 세팅')),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getPriceDivCdSelectBox())),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.attach_money_rounded),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('가격'),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.grey,
                        filled: isEnablePrice ? false : true),
                    enabled: isEnablePrice,
                    inputFormatters: [ThousandsSeparatorInputFormatter()]),
              )),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.attach_money_rounded),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('개수'),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: TextField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    )),
              )),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.dangerous_rounded),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('환율 적용 여부')),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getExchangeRateYnSelectBox())),
            ],
          )),
          Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Visibility(
                      visible: !args.isInsert,
                      child: ElevatedButton(
                          onPressed: () => _delete(),
                          child: Text('삭제'),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.red)))),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: ElevatedButton(
                    onPressed: () => _update(args.isInsert),
                    child: args.isInsert ? Text('등록') : Text('수정'),
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor)),
              )
            ],
          )
        ]));
  }

  Future<List<dynamic>> _getAssetList() async {
    var url = Uri.parse(Config.API_URL + 'asset');
    List<dynamic> resultData = [];

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['result_data'];
        resultData.insert(0, {'asset_id': '', 'asset_nm': ''});
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _getAssetSelectBox() {
    return FutureBuilder(
        future: _assetList,
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
          } else {
            return DropdownButton(
                value: inputAssetId,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    inputAssetId = newValue!;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((dynamic obj) {
                  return DropdownMenuItem<String>(
                    value: obj['asset_id'],
                    child: Text(obj['asset_nm']),
                  );
                }).toList());
          }
        });
  }

  Widget _getPriceDivCdSelectBox() {
    return DropdownButton(
        value: inputPriceDivCd,
        elevation: 16,
        onChanged: (String? newValue) {
          setState(() {
            inputPriceDivCd = newValue!;
            if (newValue == 'AUTO') {
              isEnablePrice = false;
              priceController.text = 0.toString();
            } else {
              isEnablePrice = true;
            }
          });
        },
        items: ['', 'MANUAL', 'AUTO']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList());
  }

  Widget _getExchangeRateYnSelectBox() {
    return DropdownButton(
        value: inputExchangeRateYn,
        elevation: 16,
        onChanged: (String? newValue) {
          setState(() {
            inputExchangeRateYn = newValue!;
          });
        },
        items: ['', 'N', 'Y'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList());
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("닫기"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _update(bool isInsert) {
    var title = '수정';
    if (isInsert) {
      title = '등록';
    }
    if (inputAssetId == '') {
      _showDialog(title, '자산을 입력해주세요');
      return;
    }
    if (myAssetNmController.text == '') {
      _showDialog(title, '자산 이름을 입력해주세요');
      return;
    }
    if (tickerController.text == '') {
      _showDialog(title, '자산 이름을 입력해주세요');
      return;
    }
    if (inputPriceDivCd == '') {
      _showDialog(title, '가격 세팅을 입력해주세요');
      return;
    }
    if (priceController.text == '') {
      _showDialog(title, '가격을 입력해주세요');
      return;
    }
    if (qtyController.text == '') {
      _showDialog(title, '갯수를 입력해주세요');
      return;
    }
    if (inputExchangeRateYn == '') {
      _showDialog(title, '환율 적용 여부를 입력해주세요');
      return;
    }

    var requestParam = {
      'my_asset_id': inputMyAssetId,
      'my_asset_nm': myAssetNmController.text,
      'asset_id': inputAssetId,
      'ticker': tickerController.text,
      'price_div_cd': inputPriceDivCd,
      'price': double.parse(numberUtils.uncomma(priceController.text)),
      'qty': double.parse(qtyController.text),
      'exchange_rate_yn': inputExchangeRateYn,
    };

    if (isInsert) {
      _insertAccount(requestParam);
    } else {
      _updateAccount(requestParam);
    }
  }

  void _insertAccount(var requestParam) async {
    var url = Uri.parse(Config.API_URL + 'my_asset');

    try {
      http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestParam),
      );

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        Navigator.pop(context, '등록 완료!!!');
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateAccount(var requestParam) async {
    var url = Uri.parse(Config.API_URL + 'my_asset');

    try {
      http.Response response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestParam),
      );

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        Navigator.pop(context, '수정 완료!!!');
      }
    } catch (e) {
      print(e);
    }
  }

  void _delete() {
    var requestParam = {'my_asset_id': inputMyAssetId};
    _deleteAccount(requestParam);
  }

  void _deleteAccount(var requestParam) async {
    var url = Uri.parse(Config.API_URL + 'my_asset');

    try {
      http.Response response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestParam),
      );

      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));
        Navigator.pop(context, '샥제 완료!!!');
      }
    } catch (e) {
      print(e);
    }
  }
}

class MyAssetParameter {
  String myAssetId;
  String assetId;
  String myAssetNm;
  String ticker;
  String priceDivCd;
  double price;
  double qty;
  String exchangeRateYn;
  bool isInsert;

  MyAssetParameter(
      {this.myAssetId = '',
      this.assetId = '',
      this.myAssetNm = '',
      this.ticker = '',
      this.priceDivCd = '',
      this.price = -1,
      this.qty = -1.0,
      this.exchangeRateYn = 'N',
      this.isInsert = true});
}
