import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class Home extends StatefulWidget {
  final User user;
  const Home({required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User _currentUser;
  List<Map<String, dynamic>> transactions = [];

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
            height: size.height * 0.44,
            color: Repository.headerColor(context),
          ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
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
              const Gap(25),
              FittedBox(
                child: SizedBox(
                  height: size.height * 0.23,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.67,
                        padding: const EdgeInsets.fromLTRB(16, 10, 0, 20),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(15)),
                          color: Repository.cardColor(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Banner',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      Container(
                        width: size.width * 0.27,
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(15)),
                          color: Styles.yellowColor,
                        ),
                      )
                    ],
                  ),
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
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions',
                      style: TextStyle(
                          color: Repository.textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text('Today',
                          style: TextStyle(
                              color: Repository.subTextColor(context),
                              fontSize: 16)),
                      const Gap(3),
                      Icon(CupertinoIcons.chevron_down,
                          color: Repository.subTextColor(context), size: 17)
                    ],
                  )
                ],
              ),
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
        ],
      ),
    );
  }

  Future<void> getTransactions() async {
    final db = FirebaseFirestore.instance;
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
            transactions.add(item);
          }),
          onError: (e) => print('Error completing: $e'),
        );

    setState(() {});
  }
}
