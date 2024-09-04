import 'package:flutter/material.dart';
import 'package:account_book/views/account_main.dart';
import 'package:account_book/views/account_list.dart';
import 'package:account_book/views/account.dart';
import 'package:account_book/views/expense.dart';
import 'package:account_book/views/income.dart';
import 'package:account_book/views/invest.dart';
import 'package:account_book/views/expense_dtl.dart';
import 'package:account_book/views/expense_by_member.dart';
import 'package:account_book/views/my_asset_list.dart';
import 'package:account_book/views/my_asset.dart';
import 'package:account_book/views/my_asset_chart.dart';
import 'package:account_book/views/expense_chart.dart';
import 'package:account_book/views/income_chart.dart';
import 'package:account_book/views/invest_chart.dart';
import 'package:account_book/views/my_asset_accum.dart';
import 'package:account_book/views/expense_daily_chart.dart';

class Routes {
  Routes();

  Map<String, Widget Function(BuildContext)> getRoutes(BuildContext context) {
    Map<String, Widget Function(BuildContext)> _routes = {
      '/': (context) => AccountMain(),
      '/accountList': (context) => AccountList(),
      '/account': (context) => Account(),
      '/expense': (context) => Expense(),
      '/expenseDtl': (context) => ExpenseDtl(),
      '/income': (context) => Income(),
      '/invest': (context) => Invest(),
      '/expense/member': (context) => ExpenseByMember(),
      '/asset': (context) => MyAssetList(),
      '/myAsset': (context) => MyAsset(),
      '/asset/chart': (context) => MyAssetChart(),
      '/expense/chart': (context) => ExpenseChart(),
      '/income/chart': (context) => IncomeChart(),
      '/invest/chart': (context) => InvestChart(),
      '/asset/accum': (context) => MyAssetAccum(),
      '/expense/dailyChart': (context) => ExpenseDailyChart(),
    };
    return _routes;
  }

  Map<String, Widget> getRoutesWidget() {
    Map<String, Widget> _routes = {
      '/': AccountMain(),
      '/accountList': AccountList(),
      '/account': Account(),
      '/expense': Expense(),
      '/expenseDtl': ExpenseDtl(),
      '/income': Income(),
      '/invest': Invest(),
      '/expense/member': ExpenseByMember(),
      '/asset': MyAssetList(),
      '/myAsset': MyAsset(),
      '/asset/chart': MyAssetChart(),
      '/expense/chart': ExpenseChart(),
      '/income/chart': IncomeChart(),
      '/invest/chart': InvestChart(),
      '/asset/accum': MyAssetAccum(),
      '/expense/dailyChart': ExpenseDailyChart(),
    };
    return _routes;
  }
}
