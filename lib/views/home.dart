import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:tripo/generated/assets.dart';
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
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User _currentUser;
  List<Map<String, dynamic>> transactions = [];
  List<ChartData> charSections = [];
  double totalAllAmount = 0;
  List<String> filterOptions = ['Latest', 'Today', 'Week', 'Month'];

  List<double> categoryPecent = [];
  String currentFilterOption = 'Latest';
  int touchedIndex = -1;
  String documentId = '';
  String profileImgUrl = '';
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          return Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                '${data.title} : \$${data.amount.toString()}',
                style: const TextStyle(color: Colors.white),
              ));
        });

    _currentUser = FirebaseAuth.instance.currentUser!;
    getUserData();
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
    return Scaffold(
        body: SnappingSheet(
      snappingPositions: [
        SnappingPosition.pixels(
          positionPixels: MediaQuery.of(context).size.height * 0.28,
          snappingCurve: Curves.elasticOut,
          snappingDuration: const Duration(milliseconds: 1750),
        ),
        const SnappingPosition.factor(
          positionFactor: 0.859,
          snappingCurve: Curves.bounceOut,
          snappingDuration: Duration(seconds: 1),
          grabbingContentOffset: GrabbingContentOffset.bottom,
        ),
      ],
      // Top area
      child: Container(
          color: Repository.navbarColor(context),
          child: Stack(children: [
            Container(
              width: double.infinity,
              height: size.height,
              decoration: BoxDecoration(
                  color: Repository.navbarColor(context),
                  borderRadius: BorderRadius.circular(40)),
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
                                  color: Repository.subTextColor(context),
                                  fontSize: 16)),
                          const Gap(3),
                          Text('Welcome back',
                              style: TextStyle(
                                  color: Repository.textColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.5,
                              color: Styles.darkGreyColor,
                            ),
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: CircleAvatar(
                            backgroundColor: Styles.greenColor,
                            radius: 20,
                            child: ClipOval(
                              child: profileImgUrl != ''
                                  ? Image.network(profileImgUrl)
                                  : Image.asset(Assets.defaultUserProfileImg),
                            ),
                          ),

                          // Icon(
                          //   Icons.more_vert,
                          //   color: Styles.accentColor,
                          // ),
                        ),
                      )
                    ],
                  ),
                  const Gap(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height * 0.35,
                        width: size.width * 0.78,
                        // margin: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SfCircularChart(
                              annotations: [
                                CircularChartAnnotation(
                                    widget: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Total ',
                                          style: TextStyle(
                                              color: Repository.subTextColor(
                                                  context),
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15)),
                                      Text(
                                          '\$${totalAllAmount.toPrecision(2)} ',
                                          style: TextStyle(
                                              color:
                                                  Repository.textColor(context),
                                              fontWeight: FontWeight.bold,
                                              fontSize: totalAllAmount < 9999
                                                  ? 30
                                                  : 25)),
                                    ],
                                  ),
                                ))
                              ],
                              tooltipBehavior: _tooltip,
                              series: <CircularSeries>[
                                DoughnutSeries<ChartData, String>(
                                  dataSource: charSections,
                                  animationDuration: 1000,
                                  xValueMapper: (ChartData data, _) =>
                                      data.title,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  pointColorMapper: (ChartData data, _) =>
                                      data.color,
                                  // Corner style of doughnut segment
                                  cornerStyle: CornerStyle.bothFlat,
                                  explodeAll: true,
                                  radius: '100%',
                                  innerRadius: '60%',
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                  const Gap(0),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: getIndicator())),
                  const Gap(15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Styles.purewhiteColor.withOpacity(0.4),
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
                                        fontSize: 17.0))
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
                                        fontSize: 17.0))
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddReceipt()))
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
                                        fontSize: 17.0))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
          ])),
      grabbingHeight: 70,
      // Dragging area,
      grabbing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            // boxShadow: const [
            //   BoxShadow(
            //     offset: Offset(0, 1),
            //     color: Colors.grey,
            //     blurRadius: 5,
            //     spreadRadius: 1,
            //   )
            // ],
            color: Repository.bg2Color(context),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Repository.textColor(context),
                    borderRadius: BorderRadius.circular(50)),
              ),
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
                        color: Repository.subTextColor(context), fontSize: 16),
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
            ],
          )),
      // Transaction area
      sheetBelow: SnappingSheetContent(
        sizeBehavior: SheetSizeStatic(size: 300),
        draggable: false,
        child: Container(
          color: Repository.bg2Color(context),
          padding: const EdgeInsets.only(top: 10),
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
        ),
      ),
    ));
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
    showingSections();
    setState(() {});
  }

  Widget getTransactionList() {
    if (transactions.isEmpty) {
      return notFound(context);
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

  Future<void> showingSections() async {
    charSections = [];
    categoryPecent = [];
    totalAllAmount = 0;

    for (var element in transactions) {
      totalAllAmount += double.parse(element['total_amount']);
    }
    var categoryMap = groupBy(transactions, (Map obj) => obj['category']);
    if (categoryMap.isNotEmpty) {
      categoryMap.forEach((i, value) {
        // int index = keys.indexOf(i);

        double totalCategoryAmount = 0;
        for (var element in value) {
          totalCategoryAmount += double.parse(element['total_amount']);
        }
        double percent =
            ((totalCategoryAmount / totalAllAmount)).toPrecision(3);
        categoryPecent.add(percent);
        // final isTouched = index == touchedIndex;
        // final fontSize = isTouched ? 16.0 : 12.0;
        // final radius = isTouched ? 60.0 : 50.0;
        // const shadows = [Shadow(color: Colors.black, blurRadius: 1)];
        charSections.add(ChartData(
          i.toString(),
          (totalCategoryAmount).toPrecision(2),
          percent,
          getIconColor(i.toString()),
        ));
      });
    }
    setState(() {});
  }

  List<Widget> getIndicator() {
    List<Widget> result = [];
    var categoryMap = groupBy(transactions, (Map obj) => obj['category']);
    List<dynamic> keys = categoryMap.keys.toList();
    keys.forEachIndexed((index, element) {
      double percent = categoryPecent[index];
      result.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                keys[index],
                style: TextStyle(
                    fontSize: 13, color: Repository.subTextColor(context)),
              )),
          const Gap(2),
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                (((percent * 100).toPrecision(2)).toString()) + '%',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Repository.textColor(context)),
              )),
          LinearPercentIndicator(
            barRadius: const Radius.circular(100),
            width: MediaQuery.of(context).size.width - 300,
            animation: true,
            lineHeight: 8.0,
            animationDuration: 1000,
            percent: percent,
            progressColor: getIconColor(keys[index]),
          )
        ],
      ));
      result.add(const SizedBox(
        width: 20,
      ));
      // result.add(Indicator(
      //   color: getIconColor(keys[index]),
      //   text: keys[index],
      //   isSquare: true,
      //   size: 10,
      // ));
    });
    return result;
  }

  getUserData() async {
    final db = FirebaseFirestore.instance;
    await db
        .collection('users')
        .where('email', isEqualTo: _currentUser.email)
        .get()
        .then((res) {
      documentId = res.docs[0].id;
      profileImgUrl = res.docs[0].get('profile_photo_url');
    });
    setState(() {});
  }
}

class ChartData {
  ChartData(this.title, this.amount, this.value, this.color);
  final String title;
  final double amount;
  final double value;
  final Color color;
}
