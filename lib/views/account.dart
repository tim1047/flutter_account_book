import 'dart:convert';

import 'package:account_book/utils/number_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:account_book/widget/menubar.dart';
import 'package:account_book/widget/menu.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/utils/number_utils.dart';


class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: MenuBar(),
        drawer: Menu(),
        body: SingleChildScrollView(
          child: AccountBody(),
        ));
  }
}

class AccountBody extends StatefulWidget {
  const AccountBody({Key? key}) : super(key: key);

  @override
  State<AccountBody> createState() => _AccountBodyState();
}

class _AccountBodyState extends State<AccountBody> {
  DateUtils2 dateUtils = DateUtils2();
  NumberUtils numberUtils = NumberUtils();
  String inputAccountDt = '';
  String inputDivisionId = '';
  String inputMemberId = '';
  String inputPaymentId = '';
  String inputImpulseYn = '';
  String inputCategoryId = '';
  String inputCategorySeq = '';
  String accountId = '';
  String inputPointYn = '';
  late Future<List<dynamic>> _divisionList;
  late Future<List<dynamic>> _memberList;
  final priceController = TextEditingController();
  final remarkController = TextEditingController();
  bool isInit = true;
  bool isExpense = true;

  @override
  void initState() {
    super.initState();
    _divisionList = _getDivisionList();
    _memberList = _getMemberList();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AccountParameter;
    inputAccountDt = inputAccountDt == '' ? args.accountDt : inputAccountDt;
    inputDivisionId = inputDivisionId == '' ? args.divisionId : inputDivisionId;
    inputMemberId = inputMemberId == '' ? args.memberId : inputMemberId;
    inputPaymentId = inputPaymentId == '' ? args.paymentId : inputPaymentId;
    inputCategoryId = inputCategoryId == '' ? args.categoryId : inputCategoryId;
    inputCategorySeq =
        inputCategorySeq == '' ? args.categorySeq : inputCategorySeq;
    inputImpulseYn = inputImpulseYn == '' ? args.impulseYn : inputImpulseYn;
    inputPointYn = inputPointYn == '' ? args.pointYn : inputPointYn;
    accountId = args.accountId;

    if (isInit) {
      priceController.text = (args.price != 0 ? numberUtils.comma(args.price) : '');
      remarkController.text = args.remark;
      isInit = false;
      isExpense = args.divisionId == '3' ? true : false;
    }

    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                Icon(Icons.calendar_month_rounded),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text('??????')),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: TextButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text(dateUtils.yyyymmddToHangeul(inputAccountDt))),
                )),
              ])),
          Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.check_box_outline_blank_rounded),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('??????')),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getDivisionSelectBox(args.divisionId))),
            ],
          )),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.person_outline_rounded),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('??????'),
                ),
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: _getMemberSelectBox())),
              ],
            ),
          ),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.payment_rounded),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('????????????'),
              ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getPaymentSelectBox(inputMemberId))),
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
              Icon(Icons.category_rounded),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('?????????'),
              ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getCategorySelectBox(inputDivisionId))),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.category_rounded),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text('?????????'),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: _getCategorySeqSelectBox(inputCategoryId),
              )),
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
                child: Text('??????'),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                ),
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
                  child: Text('??????')),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: TextField(
                    controller: remarkController,
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
                  child: Text('????????????')),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getImpulseYnSelectBox())),
            ],
          )),
          ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.card_membership_rounded),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text('????????? ??????')),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _getPointYnSelectBox())),
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
                          child: Text('??????'),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.red)))),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: ElevatedButton(
                    onPressed: () => _update(args.isInsert),
                    child: args.isInsert ? Text('??????') : Text('??????'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue)),
              )
            ],
          )
        ]));
  }

  void _selectDate(BuildContext contexet) async {
    DateTime inputDate = dateUtils.stringToDateTime(inputAccountDt);

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: inputDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );

    if (selected != null && selected != inputDate) {
      setState(() {
        inputAccountDt = dateUtils.DateToYYYYMMDD(selected);
      });
    }
  }

  Future<List<dynamic>> _getDivisionList() async {
    var url = Uri.parse(Config.API_URL + 'division_list');
    List<dynamic> resultData = [];

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['result_data'];
        resultData.insert(0, {'division_id': '', 'division_nm': ''});
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _getDivisionSelectBox(String divisionId) {
    return FutureBuilder(
        future: _divisionList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //?????? ????????? data??? ?????? ?????? ?????? ???????????? ???????????? ????????? ????????????.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error??? ???????????? ??? ?????? ???????????? ?????? ??????
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
                value: inputDivisionId,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == '3') {
                      isExpense = true;
                    } else {
                      isExpense = false;
                      inputImpulseYn = 'N';
                      inputPointYn = 'N';
                    }
                    inputDivisionId = newValue!;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((dynamic obj) {
                  return DropdownMenuItem<String>(
                    value: obj['division_id'],
                    child: Text(obj['division_nm']),
                  );
                }).toList());
          }
        });
  }

  Future<List<dynamic>> _getMemberList() async {
    var url = Uri.parse(Config.API_URL + 'member_list');
    List<dynamic> resultData = [];

    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var result = json.decode(utf8.decode(response.bodyBytes));

        resultData = result['result_data'];
        resultData.insert(0, {'member_id': '', 'member_nm': ''});
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _getMemberSelectBox() {
    return FutureBuilder(
        future: _memberList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //?????? ????????? data??? ?????? ?????? ?????? ???????????? ???????????? ????????? ????????????.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error??? ???????????? ??? ?????? ???????????? ?????? ??????
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
                value: inputMemberId,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    inputMemberId = newValue!;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((dynamic obj) {
                  return DropdownMenuItem<String>(
                    value: obj['member_id'],
                    child: Text(obj['member_nm']),
                  );
                }).toList());
          }
        });
  }

  Future<List<dynamic>> _getPaymentList(String memberId) async {
    var url = Uri.parse(Config.API_URL + 'payment_list/' + memberId);
    List<dynamic> resultData = [];

    try {
      if (memberId != '') {
        http.Response response = await http.get(url);
        if (response.statusCode == 200) {
          var result = json.decode(utf8.decode(response.bodyBytes));

          resultData = result['result_data'];
        }
        resultData.insert(0, {'payment_id': '', 'payment_nm': ''});
      }
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _getPaymentSelectBox(String memberId) {
    return FutureBuilder(
        future: _getPaymentList(memberId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //?????? ????????? data??? ?????? ?????? ?????? ???????????? ???????????? ????????? ????????????.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error??? ???????????? ??? ?????? ???????????? ?????? ??????
          else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 15),
              ),
            );
          } else {
            bool isCotain = false;

            for (var i = 1; i < snapshot.data.length; i++) {
              if (inputPaymentId == snapshot.data[i]['payment_id']) {
                isCotain = true;
                break;
              }
            }
            inputPaymentId = isCotain ? inputPaymentId : '';

            return DropdownButton(
                value: inputPaymentId,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    inputPaymentId = newValue!;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((dynamic obj) {
                  return DropdownMenuItem<String>(
                    value: obj['payment_id'],
                    child: Text(obj['payment_nm']),
                  );
                }).toList());
          }
        });
  }

  Future<List<dynamic>> _getCategoryList(String divisionId) async {
    var url = Uri.parse(Config.API_URL + 'category_list/' + divisionId);
    List<dynamic> resultData = [];

    try {
      if (divisionId != '') {
        http.Response response = await http.get(url);
        if (response.statusCode == 200) {
          var result = json.decode(utf8.decode(response.bodyBytes));

          resultData = result['result_data'];
        }
      }
      resultData.insert(0, {'category_id': '', 'category_nm': ''});
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _getCategorySelectBox(String divisionid) {
    return FutureBuilder(
        future: _getCategoryList(divisionid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //?????? ????????? data??? ?????? ?????? ?????? ???????????? ???????????? ????????? ????????????.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error??? ???????????? ??? ?????? ???????????? ?????? ??????
          else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 15),
              ),
            );
          } else {
            bool isCotain = false;

            for (var i = 1; i < snapshot.data.length; i++) {
              if (inputCategoryId == snapshot.data[i]['category_id']) {
                isCotain = true;
                break;
              }
            }
            inputCategoryId = isCotain ? inputCategoryId : '';

            return DropdownButton(
                value: inputCategoryId,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    inputCategoryId = newValue!;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((dynamic obj) {
                  return DropdownMenuItem<String>(
                    value: obj['category_id'],
                    child: Text(obj['category_nm']),
                  );
                }).toList());
          }
        });
  }

  Future<List<dynamic>> _getCategorySeqList(String categoryId) async {
    var url = Uri.parse(Config.API_URL + 'category_seq_list/' + categoryId);
    List<dynamic> resultData = [];

    try {
      if (categoryId != '') {
        http.Response response = await http.get(url);
        if (response.statusCode == 200) {
          var result = json.decode(utf8.decode(response.bodyBytes));

          resultData = result['result_data'];
        }
      }
      resultData.insert(0, {'category_seq': '', 'category_seq_nm': ''});
    } catch (e) {
      print(e);
    }
    return resultData;
  }

  Widget _getCategorySeqSelectBox(String categoryId) {
    return FutureBuilder(
        future: _getCategorySeqList(categoryId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //?????? ????????? data??? ?????? ?????? ?????? ???????????? ???????????? ????????? ????????????.
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          //error??? ???????????? ??? ?????? ???????????? ?????? ??????
          else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 15),
              ),
            );
          } else {
            bool isCotain = false;

            for (var i = 1; i < snapshot.data.length; i++) {
              if (inputCategorySeq == snapshot.data[i]['category_seq']) {
                isCotain = true;
                break;
              }
            }
            inputCategorySeq = isCotain ? inputCategorySeq : '';

            return DropdownButton(
                value: inputCategorySeq,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    inputCategorySeq = newValue!;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((dynamic obj) {
                  return DropdownMenuItem<String>(
                    value: obj['category_seq'],
                    child: Text(obj['category_seq_nm']),
                  );
                }).toList());
          }
        });
  }

  Widget _getImpulseYnSelectBox() {
    return DropdownButton(
        value: inputImpulseYn,
        elevation: 16,
        onChanged: isExpense ? (String? newValue) {
          setState(() {
            inputImpulseYn = newValue!;
          });
        } : null,
        items: ['N', 'Y'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList());
  }

  Widget _getPointYnSelectBox() {
    return DropdownButton(
        value: inputPointYn,
        elevation: 16,
        onChanged: isExpense ? (String? newValue) {
          setState(() {
            inputPointYn = newValue!;
          });
        } : null,
        items: ['N', 'Y'].map<DropdownMenuItem<String>>((String value) {
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
              child: Text("??????"),
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
    var title = '??????';
    if (isInsert) {
      title = '??????';
    }
    if (inputAccountDt == '') {
      _showDialog(title, '????????? ??????????????????');
      return;
    }
    if (inputCategoryId == '') {
      _showDialog(title, '???????????? ??????????????????');
      return;
    }
    if (inputDivisionId == '') {
      _showDialog(title, '????????? ??????????????????');
      return;
    }
    if (inputMemberId == '') {
      _showDialog(title, '????????? ??????????????????');
      return;
    }
    if (inputPaymentId == '') {
      _showDialog(title, '??????????????? ??????????????????');
      return;
    }
    if (priceController.text == '') {
      _showDialog(title, '????????? ??????????????????');
      return;
    }
    if (!isInsert && accountId == '') {
      _showDialog(title, 'id??? ???????????? ????????????');
      return;
    }

    var requestParam = {
      'account_id': accountId,
      'account_dt': inputAccountDt,
      'member_id': inputMemberId,
      'division_id': inputDivisionId,
      'payment_id': inputPaymentId,
      'category_id': inputCategoryId,
      'category_seq': inputCategorySeq,
      'price': int.parse(numberUtils.uncomma(priceController.text)),
      'remark': remarkController.text,
      'impulse_yn': inputImpulseYn,
      'point_yn': inputPointYn,
    };

    if (isInsert) {
      _insertAccount(requestParam);
    } else {
      _updateAccount(requestParam);
    }
  }

  void _insertAccount(var requestParam) async {
    var url = Uri.parse(Config.API_URL + 'account');

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
        Navigator.pop(context, '?????? ??????!!!');
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateAccount(var requestParam) async {
    var url = Uri.parse(Config.API_URL + 'account');

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
        Navigator.pop(context, '?????? ??????!!!');
      }
    } catch (e) {
      print(e);
    }
  }

  void _delete() {
    var requestParam = {'account_id': accountId};
    _deleteAccount(requestParam);
  }

  void _deleteAccount(var requestParam) async {
    var url = Uri.parse(Config.API_URL + 'account');

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
        Navigator.pop(context, '?????? ??????!!!');
      }
    } catch (e) {
      print(e);
    }
  }
}

class AccountParameter {
  String accountDt;
  String divisionId;
  String divisionNm;
  String memberId;
  String memberNm;
  String paymentId;
  String paymentNm;
  String categoryId;
  String categoryNm;
  String categorySeq;
  String categorySeqNm;
  int price;
  String remark;
  String impulseYn;
  String pointYn;
  String accountId;
  bool isInsert;

  AccountParameter(
      {this.accountDt = '',
      this.divisionId = '',
      this.divisionNm = '',
      this.memberId = '',
      this.memberNm = '',
      this.paymentId = '',
      this.paymentNm = '',
      this.categoryId = '',
      this.categoryNm = '',
      this.categorySeq = '',
      this.categorySeqNm = '',
      this.price = 0,
      this.remark = '',
      this.impulseYn = 'N',
      this.pointYn = 'N',
      this.accountId = '',
      this.isInsert = true});
}
