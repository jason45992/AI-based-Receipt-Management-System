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
import 'package:tripo/views/image_preview.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
                  )));
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
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Repository.cardColor(context).withOpacity(0.4),

                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    // border:
                    //     Border.all(color: Repository.accentColor(context))
                  ),
                  child: Column(
                    children: [
                      Container(
                          height: size.height * 0.21,
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.2,
                                  child: PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event,
                                            pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              touchedIndex = -1;
                                              return;
                                            }
                                            touchedIndex = pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 35,
                                      sections: showingSections(),
                                    ),
                                  ),
                                ),
                                const Gap(25),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Indicator(
                                      color: Colors.blue,
                                      text: 'First',
                                      textColor: Styles.whiteColor,
                                      isSquare: true,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Indicator(
                                      color: Colors.yellow,
                                      text: 'Second',
                                      textColor: Styles.whiteColor,
                                      isSquare: true,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Indicator(
                                      color: Colors.purple,
                                      text: 'Third',
                                      textColor: Styles.whiteColor,
                                      isSquare: true,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Indicator(
                                      color: Colors.green,
                                      text: 'Fourth',
                                      textColor: Styles.whiteColor,
                                      isSquare: true,
                                    ),
                                    const SizedBox(
                                      height: 18,
                                    ),
                                  ],
                                ),
                              ])),
                    ],
                  ),
                ),
                const Gap(15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Repository.accentColor(context),
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
                          width: 150,
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
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.orange.withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(IconlyBold.image,
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: transactions.length,
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
                            child: Icon(trs['icon'],
                                color: trs['iconColor'], size: 20)),
                        title: Text(trs['vendor_name'],
                            style: TextStyle(
                                color: Repository.textColor(context),
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(trs['date_time'],
                            style: TextStyle(
                                color: Repository.subTextColor(context))),
                        trailing: Text(trs['total_amount'],
                            style: TextStyle(
                                fontSize: 17,
                                color: Repository.subTextColor(context))),
                      );
                    },
                  ),
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
    print("tdy: " + tdyDate.toString());
    switch (currentFilterOption) {
      case 'Latest':
        await db
            .collection('receipts')
            .where('user_email', isEqualTo: _currentUser.email)
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
        print(monDate.toDate().toString());

        Timestamp sunDate = Timestamp.fromDate(DateTime(tdyDate.year,
                tdyDate.month, tdyDate.day - (tdyDate.weekday - 1))
            .add(const Duration(days: 6)));
        print(sunDate.toDate().toString());
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
        print(startDate.toDate().toString());
        Timestamp endDate =
            Timestamp.fromDate(DateTime(tdyDate.year, tdyDate.month + 1, 1));
        print(endDate.toDate().toString());
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

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Repository.textColor(context),
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Repository.textColor(context),
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.purple,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Repository.textColor(context),
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.green,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Repository.textColor(context),
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
