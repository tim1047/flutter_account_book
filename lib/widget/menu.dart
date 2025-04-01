import 'package:account_book/provider/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // children: [
                //   Text('강원 🧡 정윤 가계부', style: TextStyle(color: Colors.white)),
                //   Consumer<ThemeNotifier>(
                //     builder: (context, notifier, child) => Switch(
                //         value: notifier.darkTheme,
                //         onChanged: (newValue) {
                //           notifier.changeTheme();
                //         }),
                //   )
                // ],
                ),
            decoration: BoxDecoration(
              // color: Theme.of(context).primaryColor,
              image: DecorationImage(
                image: AssetImage('assets/family.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_customize_rounded),
            title: Text('가계부 홈'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt_rounded),
            title: Text('가계부 목록'),
            onTap: () {
              Navigator.pushNamed(context, '/accountList');
            },
          ),
          ExpansionTile(
              leading: Icon(Icons.shopping_cart_rounded),
              title: Text('지출'),
              children: [
                ListTile(
                  leading: Padding(
                      padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Icon(Icons.shopping_cart_rounded)),
                  title: Text('지출'),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(Icons.shopping_cart_checkout_rounded),
                  ),
                  title: Text('지출 상세'),
                  onTap: () {
                    Navigator.pushNamed(context, '/expenseDtl');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  title: Text('주체별 지출'),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense/member');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(LineIcons.lineChart),
                  ),
                  title: Text('지출 추이'),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense/chart');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(LineIcons.lineChart),
                  ),
                  title: Text('일별 지출 추이'),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense/dailyChart');
                  },
                ),
              ]),
          ExpansionTile(
              leading: Icon(Icons.account_balance_wallet_rounded),
              title: Text('수입'),
              children: [
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(Icons.money_rounded),
                  ),
                  title: Text('수입'),
                  onTap: () {
                    Navigator.pushNamed(context, '/income');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(LineIcons.lineChart),
                  ),
                  title: Text('수입 추이'),
                  onTap: () {
                    Navigator.pushNamed(context, '/income/chart');
                  },
                ),
              ]),
          ExpansionTile(
              leading: Icon(Icons.real_estate_agent_rounded),
              title: Text('투자'),
              children: [
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(Icons.real_estate_agent_rounded),
                  ),
                  title: Text('투자'),
                  onTap: () {
                    Navigator.pushNamed(context, '/invest');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(LineIcons.lineChart),
                  ),
                  title: Text('투자 추이'),
                  onTap: () {
                    Navigator.pushNamed(context, '/invest/chart');
                  },
                ),
              ]),
          ListTile(
            leading: Icon(Icons.calendar_view_day_rounded),
            title: Text('CALENDAR 보기'),
            onTap: () {
              Navigator.pushNamed(context, '/expense/calendar');
            },
          ),
          ExpansionTile(
              leading: Icon(LineIcons.building),
              title: Text('자산'),
              children: [
                ListTile(
                  leading: Padding(
                      padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Icon(LineIcons.lineChart)),
                  title: Text('자산'),
                  onTap: () {
                    Navigator.pushNamed(context, '/asset');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(Icons.chat_rounded),
                  ),
                  title: Text('자산 비율'),
                  onTap: () {
                    Navigator.pushNamed(context, '/asset/chart');
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Icon(LineIcons.lineChart),
                  ),
                  title: Text('자산 추이'),
                  onTap: () {
                    Navigator.pushNamed(context, '/asset/accum');
                  },
                ),
              ]),
        ],
      ),
    );
  }
}
