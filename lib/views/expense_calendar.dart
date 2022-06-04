import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_book/widget/menubar.dart';
import 'package:account_book/widget/menu.dart';
import 'package:account_book/utils/number_utils.dart';
import 'package:account_book/config/config.dart';
import 'package:account_book/utils/date_utils.dart';
import 'package:account_book/provider/date.dart';
import 'package:cell_calendar/cell_calendar.dart';
import 'package:account_book/views/sample_event.dart';


class ExpenseCalendar extends StatelessWidget {
  const ExpenseCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: MenuBar(),
      drawer: Menu(),
      body: Consumer<Date>(
        builder: (_, date, __) => ExpenseCalendarBody(),
      ),
    );
  }
}

class ExpenseCalendarBody extends StatefulWidget {
  ExpenseCalendarBody({Key? key}) : super(key: key);

  @override
  State<ExpenseCalendarBody> createState() => _ExpenseCalendarBodyState();
}

class _ExpenseCalendarBodyState extends State<ExpenseCalendarBody> {
  @override
  Widget build(BuildContext context) {
    final _sampleEvents = sampleEvents();
    final cellCalendarPageController = CellCalendarPageController();

    return CellCalendar(
      cellCalendarPageController: cellCalendarPageController,
      events: _sampleEvents,
      daysOfTheWeekBuilder: (dayIndex) {
        final labels = ["일", "월", "화", "수", "목", "금", "토"];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            labels[dayIndex],
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
      monthYearLabelBuilder: (datetime) {
        final year = datetime!.year.toString();
        final month = datetime.month.monthName;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                "$month  $year",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  cellCalendarPageController.animateToDate(
                    DateTime.now().subtract(new Duration(days: 30)),
                    curve: Curves.linear,
                    duration: Duration(milliseconds: 300),
                  );
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  cellCalendarPageController.animateToDate(
                    DateTime.now(),
                    curve: Curves.linear,
                    duration: Duration(milliseconds: 300),
                  );
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.arrow_forward_rounded),
                onPressed: () {
                  cellCalendarPageController.animateToDate(
                    DateTime.now().add(new Duration(days: 30)),
                    curve: Curves.linear,
                    duration: Duration(milliseconds: 300),
                  );
                },
              )
            ],
          ),
        );
      },
      onCellTapped: (date) {
        final eventsOnTheDate = _sampleEvents.where((event) {
          final eventDate = event.eventDate;
          return eventDate.year == date.year &&
              eventDate.month == date.month &&
              eventDate.day == date.day;
        }).toList();
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title:
                      Text(date.month.monthName + " " + date.day.toString()),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: eventsOnTheDate
                        .map(
                          (event) => Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4),
                            margin: EdgeInsets.only(bottom: 12),
                            color: event.eventBackgroundColor,
                            child: Text(
                              event.eventName,
                              style: TextStyle(color: event.eventTextColor),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ));
      },
      onPageChanged: (firstDate, lastDate) {
        /// Called when the page was changed
        /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
      },
    );
  }

  List<CalendarEvent> _getCalendarEventList() {
    
    return [];
  }
}