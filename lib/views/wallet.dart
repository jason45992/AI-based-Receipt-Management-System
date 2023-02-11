import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:iconly/iconly.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:intl/intl.dart';
import 'package:tripo/views/add_card.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';

class Wallet extends StatefulWidget {
  final User user;
  const Wallet({required this.user});

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late User _currentUser;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    _currentUser = widget.user;
    getTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);
    return Scaffold(
      backgroundColor: Repository.bgColor(context),
      appBar:
          myAppBar(title: 'Receipts', implyLeading: false, context: context),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                // onTap: () => Navigator.push(context,
                //     MaterialPageRoute(builder: (c) => const AddCard())),
                child: Container(
                  width: size.width * 0.78,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Repository.accentColor(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.add,
                          color: Repository.textColor(context), size: 20),
                      const Gap(10),
                      Text('Search Receipt',
                          style:
                              TextStyle(color: Repository.textColor(context)))
                    ],
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Repository.accentColor(context),
                child: Icon(IconlyBroken.search,
                    color: Repository.textColor(context)),
                radius: 23,
              )
            ],
          ),
          const Gap(22),
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (c, i) {
              final trs = transactions[i];
              return ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => AddCard(
                              transaction: trs,
                            ))),
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
                    child:
                        Icon(trs['icon'], color: trs['iconColor'], size: 20)),
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
    setState(() {});
  }
}
