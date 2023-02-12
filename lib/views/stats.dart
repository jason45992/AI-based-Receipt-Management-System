import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/utils/functions.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class Stats extends StatefulWidget {
  final User user;
  const Stats({required this.user});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  String _currentRange = 'Today';
  bool positive = false;
  late User _currentUser;
  List<Map<String, dynamic>> transactions = [];
  double totalExpenses = 0;

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
          title: 'Stats',
          implyLeading: false,
          context: context,
          hasAction: true),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: <Widget>[
          AnimatedToggleSwitch<String>.size(
            current: _currentRange,
            values: const ['Today', 'Week', 'Month'],
            indicatorSize: const Size.fromWidth(150),
            indicatorColor: Repository.headerColor(context),
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
                              ? Colors.white
                              : Repository.titleColor(context)))
                ],
              );
            },
            onChanged: (i) {
              _currentRange = i;
              getTransactions();
            },
          ),
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
    }
    setState(() {});
  }

  List<Widget> getCategoryPercent() {
    List<Widget> result = [];
    List<Map<String, dynamic>> resultsMap = [];
    var categoryMap = groupBy(transactions, (Map obj) => obj['category']);

    if (categoryMap.isNotEmpty) {
      categoryMap.forEach((i, value) {
        double totalCategoryAmount = 0;
        for (var element in value) {
          totalCategoryAmount += double.parse(element['total_amount']);
        }
        double percent = ((totalCategoryAmount / totalExpenses)).toPrecision(3);

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
                                  (double.parse(element['percent'].toString()) *
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
    return result;
  }
}
