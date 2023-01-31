import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripo/json/transactions.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/iconly/iconly_bold.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:tripo/utils/size_config.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/views/image_preview.dart';
import 'package:gap/gap.dart';
import 'package:tripo/views/scan.dart';

class Home extends StatefulWidget {
  final User user;
  const Home({required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
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
                        IconlyBold.Notification,
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
                            // Image.asset(Assets.cardsVisaYellow,
                            //     width: 60, height: 50, fit: BoxFit.cover),
                            Text('Banner',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                    color: Colors.white)),
                            // const Gap(20),
                            // Text('CARD NUMBER',
                            //     style: TextStyle(
                            //         color: Colors.white.withOpacity(0.5),
                            //         fontSize: 12)),
                            // const Gap(5),
                            // const Text('3829 4820 4629 5025',
                            //     style: TextStyle(
                            //         color: Colors.white, fontSize: 15)),
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
                        // child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Container(
                        //       padding: const EdgeInsets.all(10),
                        //       margin: const EdgeInsets.only(top: 10),
                        //       decoration: BoxDecoration(
                        //         shape: BoxShape.circle,
                        //         color: Styles.greenColor,
                        //       ),
                        //       child: const Icon(
                        //         Icons.swipe_rounded,
                        //         color: Colors.white,
                        //         size: 20,
                        //       ),
                        //     ),
                        //     const Spacer(),
                        //     const Text('VALID', style: TextStyle(fontSize: 12)),
                        //     const Gap(5),
                        //     const Text('05/22', style: TextStyle(fontSize: 15)),
                        //   ],
                        // ),
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const ScanReceipt()));
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
                            Icon(IconlyBold.Scan,
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
                            Icon(IconlyBold.Image,
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
                              color: const Color(0xFFFF736C), size: 20)),
                      title: Text(trs['name'],
                          style: TextStyle(
                              color: Repository.textColor(context),
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(trs['date'],
                          style: TextStyle(
                              color: Repository.subTextColor(context))),
                      trailing: Text(trs['amount'],
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
}
