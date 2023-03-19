import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/utils/functions.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../widgets/not_found.dart';

class Stats extends StatefulWidget {
  final User user;
  const Stats({required this.user});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  String _currentRange = 'Week';
  bool positive = false;
  late User _currentUser;
  List<Map<String, dynamic>> transactions = [];
  double totalExpenses = 0;
  DateTimeRange? pickedDate;
  DateTime filterStartdate = DateTime.now();
  DateTime filterEnddate = DateTime.now();

  @override
  void initState() {
    _currentUser = widget.user;
    getTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Repository.bgColor(context),
      appBar: myAppBar(
          title: 'Summary',
          implyLeading: false,
          context: context,
          hasAction: true),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: <Widget>[
          AnimatedToggleSwitch<String>.size(
            current: _currentRange,
            values: const ['Today', 'Week', 'Month', 'Date'],
            indicatorSize: const Size.fromWidth(150),
            indicatorColor: Repository.textColor(context),
            borderRadius: BorderRadius.circular(100),
            innerColor: Repository.bgColor(context),
            borderColor: Repository.accentColor(context),
            indicatorBorder:
                Border.all(color: Repository.titleColor(context), width: 2),
            customIconBuilder: (context, local, global) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(local.value,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: local.value == _currentRange
                              ? Repository.navbarColor(context)
                              : Repository.titleColor(context)))
                ],
              );
            },
            onChanged: (i) {
              _currentRange = i;
              getTransactions();
            },
          ),
          _currentRange == 'Date'
              ? Container(
                  height: 50,
                  width: 240,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      // color: Styles.greyColor,
                      border: Border.all(
                        width: 1.5,
                        color: Styles.greyColor,
                      ),
                      borderRadius: BorderRadius.circular(100)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(TextSpan(
                            text: 'From ',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Repository.subTextColor(context)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: DateFormat('dd/MM/yyyy')
                                      .format(filterStartdate),
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                      color: Repository.subTextColor(context)),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: ' to ',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Repository.subTextColor(
                                                context)),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: DateFormat('dd/MM/yyyy')
                                                .format(filterEnddate),
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 17,
                                                fontWeight: FontWeight.normal,
                                                color: Repository.subTextColor(
                                                    context)),
                                          )
                                        ])
                                  ])
                            ])),
                        const Gap(5),
                        InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              pickedDate = await showDateRangePicker(
                                  builder: (context, child) {
                                    return dateTimepickerTheme(context, child);
                                  },
                                  context: context,
                                  firstDate: DateTime(
                                      2000), //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime.now());

                              if (pickedDate != null) {
                                setState(() {
                                  filterStartdate = pickedDate!.start;
                                  filterEnddate = pickedDate!.end;
                                  getTransactions();
                                });
                              } else {
                                print('Date is not selected');
                              }
                            },
                            child: Icon(
                              Icons.edit_calendar_outlined,
                              size: 20,
                              color: Repository.textColor(context),
                            ))
                      ]),
                )
              : const SizedBox(),
          const Gap(20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Repository.accentColor2(context),
                border: Border.all(color: Repository.accentColor(context))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                    child: Text('Total Expenses',
                        style: TextStyle(
                            color: Repository.subTextColor(context)))),
                Divider(
                  color: Repository.dividerColor(context),
                  thickness: 2,
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
                    child: Text(
                        totalExpenses.toPrecision(2).toStringAsFixed(2) +
                            ' SGD',
                        style: TextStyle(
                            color: Repository.titleColor(context),
                            fontSize: 32,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Gap(20),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getCategoryPercent(),
          )
        ],
      ),
    );
  }

  Future<void> getTransactions() async {
    final db = FirebaseFirestore.instance;
    transactions = [];
    totalExpenses = 0;
    DateTime currentDateTime = DateTime.now();
    DateTime tdyDate = DateTime(
        currentDateTime.year, currentDateTime.month, currentDateTime.day);
    switch (_currentRange) {
      case 'Today':
        Timestamp tmrDate =
            Timestamp.fromDate(tdyDate.add(const Duration(days: 1)));
        await db
            .collection('receipts')
            .where('user_email', isEqualTo: _currentUser.email)
            .where('date_time',
                isLessThan: tmrDate,
                isGreaterThanOrEqualTo: Timestamp.fromDate(tdyDate))
            .orderBy('date_time', descending: true)
            .get()
            .then(
              (res) => res.docs.forEach((element) {
                Map<String, dynamic> item = element.data();
                item['icon'] = getIcon(element.data()['category']);
                item['iconColor'] = getIconColor(element.data()['category']);
                item['date_time'] = DateFormat('dd/MM/yyyy HH:mm')
                    .format(element.data()['date_time'].toDate());
                transactions.add(item);
                totalExpenses += double.parse(element['total_amount']);
              }),
              onError: (e) => print('Error completing: $e'),
            );
        break;
      case 'Week':
        Timestamp monDate = Timestamp.fromDate(DateTime(
            tdyDate.year, tdyDate.month, tdyDate.day - (tdyDate.weekday - 1)));

        Timestamp sunDate = Timestamp.fromDate(DateTime(tdyDate.year,
                tdyDate.month, tdyDate.day - (tdyDate.weekday - 1))
            .add(const Duration(days: 6)));
        await db
            .collection('receipts')
            .where('user_email', isEqualTo: _currentUser.email)
            .where('date_time',
                isLessThanOrEqualTo: sunDate, isGreaterThanOrEqualTo: monDate)
            .orderBy('date_time', descending: true)
            .get()
            .then(
              (res) => res.docs.forEach((element) {
                Map<String, dynamic> item = element.data();
                item['icon'] = getIcon(element.data()['category']);
                item['iconColor'] = getIconColor(element.data()['category']);
                item['date_time'] = DateFormat('dd/MM/yyyy HH:mm')
                    .format(element.data()['date_time'].toDate());
                transactions.add(item);
                totalExpenses += double.parse(element['total_amount']);
              }),
              onError: (e) => print('Error completing: $e'),
            );
        break;
      case 'Month':
        Timestamp startDate =
            Timestamp.fromDate(DateTime(tdyDate.year, tdyDate.month, 1));
        Timestamp endDate =
            Timestamp.fromDate(DateTime(tdyDate.year, tdyDate.month + 1, 1));
        await db
            .collection('receipts')
            .where('user_email', isEqualTo: _currentUser.email)
            .where('date_time',
                isLessThan: endDate, isGreaterThanOrEqualTo: startDate)
            .orderBy('date_time', descending: true)
            .get()
            .then(
              (res) => res.docs.forEach((element) {
                Map<String, dynamic> item = element.data();
                item['icon'] = getIcon(element.data()['category']);
                item['iconColor'] = getIconColor(element.data()['category']);
                item['date_time'] = DateFormat('dd/MM/yyyy HH:mm')
                    .format(element.data()['date_time'].toDate());
                transactions.add(item);
                totalExpenses += double.parse(element['total_amount']);
              }),
              onError: (e) => print('Error completing: $e'),
            );
        break;
      case 'Date':
        Timestamp startDate = Timestamp.fromDate(DateTime(filterStartdate.year,
            filterStartdate.month, filterStartdate.day, 0, 0, 0));
        Timestamp endDate = Timestamp.fromDate(DateTime(filterEnddate.year,
            filterEnddate.month, filterEnddate.day + 1, 0, 0, 0));
        await db
            .collection('receipts')
            .where('user_email', isEqualTo: _currentUser.email)
            .where('date_time',
                isLessThan: endDate, isGreaterThanOrEqualTo: startDate)
            .orderBy('date_time', descending: true)
            .get()
            .then(
              (res) => res.docs.forEach((element) {
                Map<String, dynamic> item = element.data();
                item['icon'] = getIcon(element.data()['category']);
                item['iconColor'] = getIconColor(element.data()['category']);
                item['date_time'] = DateFormat('dd/MM/yyyy HH:mm')
                    .format(element.data()['date_time'].toDate());
                transactions.add(item);
                totalExpenses += double.parse(element['total_amount']);
              }),
              onError: (e) => print('Error completing: $e'),
            );
        break;
    }
    setState(() {});
  }

  List<Widget> getCategoryPercent() {
    List<Widget> result = [];
    if (transactions.isEmpty) {
      result.add(notFound(context));
    } else {
      List<Map<String, dynamic>> resultsMap = [];
      var categoryMap = groupBy(transactions, (Map obj) => obj['category']);

      if (categoryMap.isNotEmpty) {
        categoryMap.forEach((i, value) {
          double totalCategoryAmount = 0;
          for (var element in value) {
            totalCategoryAmount += double.parse(element['total_amount']);
          }
          double percent =
              ((totalCategoryAmount / totalExpenses)).toPrecision(3);

          var item = {
            'key': i,
            'percent': percent,
            'totalCategoryAmount': totalCategoryAmount
          };
          resultsMap.add(item);
        });

        if (resultsMap.isNotEmpty) {
          resultsMap.sort((e1, e2) => e2['percent'].compareTo(e1['percent']));
          for (var element in resultsMap) {
            result.add(Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Repository.accentColor2(context),
                  border: Border.all(color: Repository.accentColor(context))),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    getIcon(element['key']),
                    color: getIconColor(element['key']),
                    size: 30,
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                element['key'] +
                                    ' ' +
                                    (double.parse(
                                                element['percent'].toString()) *
                                            100)
                                        .toPrecision(1)
                                        .toString() +
                                    '%',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Repository.textColor(context)),
                              ),
                              Text(
                                '\$' +
                                    double.parse(element['totalCategoryAmount']
                                            .toString())
                                        .toPrecision(2)
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Repository.textColor(context)),
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 10, 0, 10),
                        child: LinearPercentIndicator(
                          barRadius: const Radius.circular(100),
                          width: MediaQuery.of(context).size.width - 72,
                          animation: true,
                          lineHeight: 10.0,
                          animationDuration: 500,
                          percent: double.parse(element['percent'].toString())
                              .toPrecision(2),
                          // center: Text("80.0%"),
                          progressColor: getIconColor(element['key']),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ));
            result.add(const SizedBox(
              height: 10,
            ));
          }
        }
      }
    }
    return result;
  }

  Theme dateTimepickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Styles.primaryColor, // <-- SEE HERE
          onPrimary: Styles.greyColor, // <-- SEE HERE
          onSurface: Styles.primaryColor, // <-- SEE HERE
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Styles.primaryColor, // button text color
          ),
        ),
      ),
      child: child!,
    );
  }
}
