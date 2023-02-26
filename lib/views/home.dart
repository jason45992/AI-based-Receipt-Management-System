import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tripo/utils/pie_chart_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:tripo/utils/size_config.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/utils/functions.dart';
import 'package:tripo/views/add_receipt.dart';
import 'package:tripo/views/image_preview.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:tripo/widgets/not_found.dart';

class Home extends StatefulWidget {
  final User user;
  const Home({required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User _currentUser;
  List<Map<String, dynamic>> transactions = [];
  List<String> filterOptions = ['Latest', 'Today', 'Week', 'Month'];
  String currentFilterOption = 'Latest';
  int touchedIndex = -1;

  @override
  void initState() {
    _currentUser = widget.user;
    getTransactions();
    super.initState();
  }

  Future<void> getImage(String type) async {
    ScannerFileSource source = ScannerFileSource.CAMERA;
    if (type != 'camera') {
      source = ScannerFileSource.GALLERY;
    }
    var image = await DocumentScannerFlutter.launch(context, source: source);
    if (image != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImagePreview(
                    imagePath: image.path,
                  ))).then((value) => getTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final size = Layouts.getSize(context);
    return Material(
      color: Repository.bgColor(context),
      elevation: 0,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.47,
            color: Repository.headerColor(context),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(children: [
                Gap(getProportionateScreenHeight(70)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi ${_currentUser.displayName}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16)),
                        const Gap(3),
                        const Text('Welcome back',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          IconlyBold.notification,
                          color: Styles.accentColor,
                        ),
                      ),
                    )
                  ],
                ),
                const Gap(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height * 0.23,
                      width: size.width * 0.54,
                      // padding: const EdgeInsets.fromLTRB(16, 10, 0, 20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(15)),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: 33,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        height: size.height * 0.23,
                        width: size.width * 0.36,
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 20),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(15)),
                            color: Styles.yellowColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getIndicator(),
                        )),
                  ],
                ),
                const Gap(15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Repository.accentColor(context),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.3),
                    //     spreadRadius: 1,
                    //     blurRadius: 10,
                    //     offset:
                    //         const Offset(0, 5), // changes position of shadow
                    //   ),
                    // ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          getImage('camera');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey.withOpacity(0.15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(IconlyBold.scan,
                                  color: Repository.textColor(context)),
                              Text('Scan',
                                  style: TextStyle(
                                      color: Repository.textColor(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0))
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          getImage('gallery');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey.withOpacity(0.15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(IconlyBold.image,
                                  color: Repository.textColor(context)),
                              Text('Upload',
                                  style: TextStyle(
                                      color: Repository.textColor(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0))
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddReceipt()))
                              .then((value) => setState(
                                    () {
                                      getTransactions();
                                    },
                                  ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.grey.withOpacity(0.15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(IconlyBold.paper,
                                  color: Repository.textColor(context)),
                              Text('Add',
                                  style: TextStyle(
                                      color: Repository.textColor(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transactions',
                        style: TextStyle(
                            color: Repository.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isDense: true,
                      value: currentFilterOption,
                      icon: Icon(CupertinoIcons.chevron_down,
                          color: Repository.subTextColor(context), size: 17),
                      // elevation: 16,
                      style: TextStyle(
                          color: Repository.subTextColor(context),
                          fontSize: 16),
                      underline: const SizedBox(),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        // setState(() {
                        currentFilterOption = value!;
                        getTransactions();
                        // });
                      },
                      items: filterOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ])),
          Padding(
            padding: const EdgeInsets.only(top: 480),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: getTransactionList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> getTransactions() async {
    final db = FirebaseFirestore.instance;
    transactions = [];
    DateTime currentDateTime = DateTime.now();
    DateTime tdyDate = DateTime(
        currentDateTime.year, currentDateTime.month, currentDateTime.day);
    switch (currentFilterOption) {
      case 'Latest':
        await db
            .collection('receipts')
            .where('user_email', isEqualTo: _currentUser.email)
            .orderBy('date_time', descending: true)
            .limit(100)
            .get()
            .then(
              (res) => res.docs.forEach((element) {
                Map<String, dynamic> item = element.data();
                item['icon'] = getIcon(element.data()['category']);
                item['iconColor'] = getIconColor(element.data()['category']);
                item['date_time'] = DateFormat('dd/MM/yyyy HH:mm')
                    .format(element.data()['date_time'].toDate());
                transactions.add(item);
              }),
              onError: (e) => print('Error completing: $e'),
            );
        break;
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
              }),
              onError: (e) => print('Error completing: $e'),
            );
        break;
    }
    setState(() {});
  }

  Widget getTransactionList() {
    if (transactions.isEmpty) {
      return notFound();
    } else {
      return ListView.separated(
        itemCount: transactions.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          final trs = transactions[i];
          return ListTile(
            isThreeLine: true,
            minLeadingWidth: 10,
            minVerticalPadding: 20,
            contentPadding: const EdgeInsets.all(0),
            leading: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Repository.accentColor(context),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 1),
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 1,
                    )
                  ],
                  shape: BoxShape.circle,
                ),
                child: Icon(trs['icon'], color: trs['iconColor'], size: 20)),
            title: Text(trs['vendor_name'],
                style: TextStyle(
                    color: Repository.textColor(context),
                    fontWeight: FontWeight.w500)),
            subtitle: Text(trs['date_time'],
                style: TextStyle(color: Repository.subTextColor(context))),
            trailing: Text(trs['total_amount'],
                style: TextStyle(
                    fontSize: 17, color: Repository.subTextColor(context))),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
          );
        },
      );
    }
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> result = [];

    double totalAllAmount = 0;
    for (var element in transactions) {
      totalAllAmount += double.parse(element['total_amount']);
    }
    var categoryMap = groupBy(transactions, (Map obj) => obj['category']);
    List<dynamic> keys = categoryMap.keys.toList();
    if (categoryMap.isNotEmpty) {
      categoryMap.forEach((i, value) {
        int index = keys.indexOf(i);

        double totalCategoryAmount = 0;
        for (var element in value) {
          totalCategoryAmount += double.parse(element['total_amount']);
        }
        double percent =
            ((totalCategoryAmount / totalAllAmount)).toPrecision(3);
        final isTouched = index == touchedIndex;
        final fontSize = isTouched ? 22.0 : 14.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 1)];
        result.add(PieChartSectionData(
          color: getIconColor(i.toString()),
          value: percent,
          title: (((percent * 100).toPrecision(2)).toString()) + '%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Styles.primaryColor,
            shadows: shadows,
          ),
        ));
      });
    }
    return result;
  }

  List<Widget> getIndicator() {
    List<Widget> result = [];
    var categoryMap = groupBy(transactions, (Map obj) => obj['category']);
    List<dynamic> keys = categoryMap.keys.toList();
    keys.forEachIndexed((index, element) {
      result.add(Indicator(
        color: getIconColor(keys[index]),
        text: keys[index],
        isSquare: true,
        size: 10,
      ));
      result.add(const SizedBox(
        height: 4,
      ));
    });
    return result;
  }
}
