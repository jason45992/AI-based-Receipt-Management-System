import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:iconly/iconly.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:intl/intl.dart';
import 'package:tripo/views/receipt_detail.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';

class ReceiptManagement extends StatefulWidget {
  final User user;
  const ReceiptManagement({required this.user});

  @override
  _ReceiptManagementState createState() => _ReceiptManagementState();
}

class _ReceiptManagementState extends State<ReceiptManagement> {
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
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 60, 15, 0),
            child: StickyGroupedListView<Map<String, dynamic>, DateTime>(
              elements: transactions,
              order: StickyGroupedListOrder.DESC,
              groupBy: (Map<String, dynamic> element) =>
                  DateFormat('dd/MM/yyyy')
                      .parseStrict(element['date_time'].split(' ')[0]),
              groupComparator: (DateTime value1, DateTime value2) =>
                  value1.compareTo(value2),
              itemComparator: (Map<String, dynamic> element1,
                      Map<String, dynamic> element2) =>
                  DateFormat('dd/MM/yyyy HH:mm')
                      .parseStrict(element1['date_time'])
                      .compareTo(DateFormat('dd/MM/yyyy HH:mm')
                          .parseStrict(element2['date_time'])),
              floatingHeader: true,
              groupSeparatorBuilder: _getGroupSeparator,
              itemBuilder: _getItem,
            ),
          )
        ]));
  }

  Widget _getGroupSeparator(Map<String, dynamic> element) {
    return SizedBox(
      height: 50,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 120,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${element['date_time'].split(' ')[0]}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getItem(BuildContext ctx, Map<String, dynamic> element) {
    return
        // Card(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(6.0),
        //   ),
        //   elevation: 8.0,
        //   // margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        //   child:
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListTile(
              onTap: (() => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReceiptDetail(transaction: element)))),
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
                  child: Icon(element['icon'],
                      color: element['iconColor'], size: 20)),
              title: Text(element['vendor_name'],
                  style: TextStyle(
                      color: Repository.textColor(context),
                      fontWeight: FontWeight.w500)),
              subtitle: Text(element['date_time'],
                  style: TextStyle(color: Repository.subTextColor(context))),
              trailing: Text(element['total_amount'],
                  style: TextStyle(
                      fontSize: 17, color: Repository.subTextColor(context))),
            )
            // ),
            );
  }

  Future<void> getTransactions() async {
    final db = FirebaseFirestore.instance;
    transactions = [];
    DateTime currentDateTime = DateTime.now();
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
