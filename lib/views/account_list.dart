import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:account_book/widget/menubar.dart';
import 'package:account_book/widget/menu.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/provider/date.dart';
import 'package:account_book/widget/dropdown.dart';
import 'package:account_book/views/account.dart';

class AccountList extends StatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
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
      appBar: MenuBar(),
      drawer: Menu(),
      body: Column(
        children: [
          Dropdown(),
          Consumer<Date>(
            builder: (_, date, __) => AccountListBody(),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateAndToast(context), child: Icon(Icons.add)),
    );
  }

  void _navigateAndToast(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/account',
            arguments: AccountParameter(
                accountDt: dateUtils.DateToYYYYMMDD(DateTime.now())))
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

class AccountListBody extends StatefulWidget {
  const AccountListBody({Key? key}) : super(key: key);

  @override
  State<AccountListBody> createState() => _AccountListBodyState();
}

class _AccountListBodyState extends State<AccountListBody> {
  NumberUtils numberUtils = NumberUtils();
  DateUtils2 dateUtils = DateUtils2();
  late FToast fToast;

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strtDt = context.read<Date>().getStrtDt();
    String endDt = context.read<Date>().getEndDt();
    final args = ModalRoute.of(context)!.settings.arguments != null
        ? ModalRoute.of(context)!.settings.arguments as AccountListParameter
        : null;

    return FutureBuilder(
        future: _getAccountList(strtDt, endDt, args),
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
          }
          // ???????????? ??????????????? ???????????? ?????? ?????? ????????? ???????????? ?????? ?????????.
          else {
            return Expanded(
              child: GroupedListView<dynamic, String>(
                elements: snapshot.data, // ???????????? ????????? ????????? ?????????
                groupBy: (element) =>
                    element['account_dt'], // ????????? ????????? ??? ????????? ????????? ??????
                order: GroupedListOrder.DESC, //??????(????????????)
                useStickyGroupSeparators: false, //?????? ?????? ?????? ????????? ???????????? ?????????
                groupSeparatorBuilder: (String value) => Padding(
                  //?????? ????????? ??????
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    dateUtils.yyyymmddToHangeul(value),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                indexedItemBuilder: (c, element, index) {
                  //????????? ?????? ??????
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: ListTile(
                                leading: CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 199, 218, 251),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: ClipOval(
                                        child: Image.asset(Config
                                            .AVATAR_INFO[element['member_id']]),
                                      ),
                                    )),
                                title: Text(numberUtils.comma(element['price']),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        element['category_nm'] +
                                            (element['category_seq_nm'] != null
                                                ? (' | ' +
                                                    element['category_seq_nm'])
                                                : '') +
                                            (element['remark'] != '' 
                                              ? ' ( ' + element['remark'] + ' )'
                                              : ''
                                            ),
                                        style: TextStyle(fontSize: 12)),
                                    Row(children: getBadgeList(element))
                                  ],
                                ),
                                onTap: () =>
                                    _navigateAndToast(context, element),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        });
  }

  List<Widget> getBadgeList(dynamic element) {
    List<Widget> badgeList = [];

    if (element['point_yn'] == 'Y') {
      badgeList.add(Container(
        margin: EdgeInsets.all(3),
        child: Badge(
            toAnimate: false,
            shape: BadgeShape.square,
            badgeColor: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(8),
            badgeContent: Text('?????????',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            showBadge: true),
      ));
    }

    if (element['impulse_yn'] == 'Y') {
      badgeList.add(Container(
        margin: EdgeInsets.all(3),
        child: Badge(
          toAnimate: false,
          shape: BadgeShape.square,
          badgeColor: Colors.purple,
          borderRadius: BorderRadius.circular(8),
          badgeContent:
              Text('??????', style: TextStyle(color: Colors.white, fontSize: 12)),
          showBadge: element['impulse_yn'] == 'N' ? false : true,
        ),
      ));
    }

    Color badgeColor;
    if (element['division_id'] == '1') {
      badgeColor = Colors.green;
    } else if (element['division_id'] == '2') {
      badgeColor = Colors.blue;
    } else {
      badgeColor = Colors.red;
    }

    badgeList.add(Container(
      margin: EdgeInsets.all(3),
      child: Badge(
        toAnimate: false,
        shape: BadgeShape.square,
        badgeColor: badgeColor,
        borderRadius: BorderRadius.circular(8),
        badgeContent: Text(element['division_nm'],
            style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    ));
    return badgeList;
  }

  void _navigateAndToast(BuildContext context, var element) async {
    final result = await Navigator.pushNamed(context, '/account',
            arguments: AccountParameter(
                accountDt: element['account_dt'],
                divisionId: element['division_id'],
                divisionNm: element['division_nm'],
                paymentId: element['payment_id'],
                paymentNm: element['payment_nm'],
                memberId: element['member_id'],
                memberNm: element['member_nm'],
                categoryId: element['category_id'],
                categoryNm: element['category_nm'],
                categorySeq: element['category_seq'],
                categorySeqNm: (element['category_seq_nm'] ?? ''),
                price: element['price'],
                remark: element['remark'],
                impulseYn: element['impulse_yn'],
                pointYn: element['point_yn'],
                accountId: element['account_id'].toString(),
                isInsert: false))
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

  Future<List<dynamic>> _getAccountList(
      String strtDt, String endDt, dynamic args) async {
    String searchDivisionId = '';
    String searchCategoryId = '';
    String searchCategorySeq = '';
    String searchMemberId = '';

    if (args != null) {
      searchDivisionId = args.searchDivisionId;
      searchCategoryId = args.searchCategoryId;
      searchCategorySeq = args.searchCategorySeq;
      searchMemberId = args.searchMemberId;
    }

    var url = Uri.parse(Config.API_URL +
        'account?strtDt=' +
        strtDt +
        '&endDt=' +
        endDt +
        '&searchDivisionId=' +
        searchDivisionId +
        '&searchCategoryId=' +
        searchCategoryId +
        '&searchCategorySeq=' +
        searchCategorySeq +
        '&searchMemberId=' +
        searchMemberId);

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
}

class AccountListParameter {
  String searchDivisionId;
  String searchCategoryId;
  String searchCategorySeq;
  String searchMemberId;

  AccountListParameter(
      {this.searchDivisionId = '',
      this.searchCategoryId = '',
      this.searchCategorySeq = '',
      this.searchMemberId = ''});
}
