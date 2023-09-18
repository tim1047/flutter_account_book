import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Config {
  Config();

  static const String API_URL = 'http://146.56.159.174:8000/account_book/';
  static const Map<String, dynamic> AVATAR_INFO = {
    '1': 'assets/boy.png',
    '2': 'assets/girl.png',
    '3': 'assets/couple.png',
    '4': 'assets/baby.png'
  };
  static const int STRT_YEAR = 2021;
  static const int STRT_MONTH = 7;
  static const Map<String, Widget> CATEGORY_ICON_INFO = {
    '1': Icon(Icons.house_rounded),
    '2': Icon(Icons.local_phone_rounded),
    '3': Icon(Icons.attach_money_rounded),
    '4': Icon(Icons.food_bank_rounded),
    '5': Icon(Icons.bed_rounded),
    '6': Icon(Icons.directions_bus_filled_rounded),
    '7': Icon(LineIcons.tShirt),
    '8': Icon(Icons.abc_rounded),
    '9': Icon(Icons.local_hospital_rounded),
    '10': Icon(LineIcons.plane),
    '11': Icon(LineIcons.graduationCap),
    '12': Icon(LineIcons.gift),
    '13': Icon(LineIcons.wallet),
    '14': Icon(LineIcons.moneyBill),
    '15': Icon(LineIcons.alternateMoneyBill),
    '16': Icon(LineIcons.piggyBank),
    '17': Icon(LineIcons.alternateMoneyBill),
    '18': Icon(Icons.house_rounded),
    '19': Icon(LineIcons.moneyBill),
    '20': Icon(LineIcons.alternateMoneyBill),
    '21': Icon(LineIcons.bitcoin),
    '22': Icon(LineIcons.lineChart),
    '23': Icon(LineIcons.alternateMoneyBill),
    '24': Icon(LineIcons.gem),
    '25': Icon(LineIcons.moneyBill),
    '26': Icon(LineIcons.moneyBill),
  };
  static const Map<String, Widget> CATEGORY_SEQ_ICON_INFO = {
    '11': Icon(LineIcons.home),
    '12': Icon(Icons.bolt_rounded),
    '13': Icon(LineIcons.tools),
    '21': Icon(LineIcons.mobilePhone),
    '22': Icon(LineIcons.wifi),
    '31': Icon(LineIcons.moneyBill),
    '32': Icon(LineIcons.wavyMoneyBill),
    '33': Icon(LineIcons.moneyCheck),
    '34': Icon(LineIcons.creditCard),
    '41': Icon(Icons.food_bank_rounded),
    '42': Icon(LineIcons.cookieBite),
    '43': Icon(LineIcons.shoppingCart),
    '44': Icon(LineIcons.truck),
    '45': Icon(LineIcons.coffee),
    '46': Icon(LineIcons.utensils),
    '51': Icon(LineIcons.socks),
    '52': Icon(LineIcons.television),
    '53': Icon(Icons.push_pin_rounded),
    '61': Icon(LineIcons.bus),
    '62': Icon(LineIcons.taxi),
    '63': Icon(LineIcons.train),
    '64': Icon(LineIcons.car),
    '65': Icon(LineIcons.gasPump),
    '71': Icon(LineIcons.tShirt),
    '72': Icon(LineIcons.ring),
    '81': Icon(LineIcons.paintBrush),
    '82': Icon(LineIcons.cut),
    '83': Icon(LineIcons.paintBrush),
    '84': Icon(LineIcons.paintBrush),
    '91': Icon(LineIcons.hospital),
    '92': Icon(LineIcons.pills),
    '93': Icon(LineIcons.capsules),
    '101': Icon(LineIcons.film),
    '102': Icon(LineIcons.planeDeparture),
    '103': Icon(Icons.luggage_rounded),
    '104': Icon(Icons.book_rounded),
    '111': Icon(LineIcons.school),
    '112': Icon(LineIcons.book),
    '121': Icon(LineIcons.birthdayCake),
    '122': Icon(LineIcons.gifts),
    '123': Icon(LineIcons.fileInvoiceWithUsDollar),
    '124': Icon(LineIcons.wavyMoneyBill),
    '125': Icon(LineIcons.wallet),
  };
  static const double BARCHART_PADDING = 1.05;
}
