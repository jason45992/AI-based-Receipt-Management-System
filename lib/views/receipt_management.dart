import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:intl/intl.dart';
import 'package:tripo/utils/styles.dart';
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
  List<Map<String, dynamic>> filteredTransactions = [];
  final TextEditingController _searchKey = TextEditingController();

  final List<bool> _warranty = [false];
  final List<bool> _filterController = List.filled(categoryItems.length, false);
  int selectedCategory = -1;

  var controller = ScrollController();
  var currentPage = 0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
                  alignment: Alignment.center,
                  width: size.width * 0.85,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Repository.accentColor(context),
                  ),
                  child: TextField(
                    style: TextStyle(color: Repository.textColor(context)),
                    controller: _searchKey,
                    cursorColor: Repository.textColor(context),
                    decoration: InputDecoration(
                        hintStyle:
                            TextStyle(color: Repository.textColor(context)),
                        border: InputBorder.none,
                        hintText: 'Search receipts'),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          filteredTransactions = transactions
                              .where((i) => i['vendor_name']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      } else {
                        setState(() {
                          filteredTransactions = transactions;
                        });
                      }
                    },
                  )),
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                        height: 30,
                        padding: const EdgeInsets.only(left: 30),
                        margin: const EdgeInsets.only(right: 10),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(50),
                          children: <Widget>[
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      getIcon(categoryItemsWithWarranty[0]),
                                      size: 15,
                                    ),
                                    const Gap(2),
                                    Text(
                                      categoryItemsWithWarranty[0],
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                          isSelected: _warranty,
                          onPressed: (int index) {
                            setState(() {
                              _warranty[index] = !_warranty[index];
                            });
                          },
                          borderColor:
                              getIconColor(categoryItemsWithWarranty[0]),
                          color: getIconColor(categoryItemsWithWarranty[0]),
                          selectedColor: Repository.bgColor(context),
                          fillColor: Repository.titleColor(context),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        )),
                    Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ToggleButtons(
                          renderBorder: false,
                          children: getFilter(),
                          isSelected: _filterController,
                          onPressed: (int index) {
                            print(index);
                            setState(() {
                              //same selection
                              if (index == selectedCategory) {
                                for (int i = 0;
                                    i < _filterController.length;
                                    i++) {
                                  _filterController[i] = false;
                                  selectedCategory = -1;
                                }
                              } else {
                                //different selection
                                for (int i = 0;
                                    i < _filterController.length;
                                    i++) {
                                  _filterController[i] = i == index;
                                  selectedCategory = index;
                                }
                              }
                            });
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          fillColor: Colors.transparent,
                        )),
                  ],
                )),
          ),

          // Container(
          //   margin: const EdgeInsets.fromLTRB(0, 60, 0, 0),
          //   // padding: const EdgeInsets.only(left: 30),
          //   height: 30,
          //   child: ,
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 100, 15, 0),
            child: StickyGroupedListView<Map<String, dynamic>, DateTime>(
              elements: filteredTransactions,
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
                              ReceiptDetail(transaction: element)))
                  .then((value) => getTransactions())),
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
    filteredTransactions = [];
    await db
        .collection('receipts')
        .where('user_email', isEqualTo: _currentUser.email)
        .orderBy('date_time', descending: true)
        .get()
        .then(
          (res) => res.docs.forEach((element) {
            Map<String, dynamic> item = element.data();
            item['id'] = element.id;
            item['icon'] = getIcon(element.data()['category']);
            item['iconColor'] = getIconColor(element.data()['category']);
            item['date_time'] = DateFormat('dd/MM/yyyy HH:mm')
                .format(element.data()['date_time'].toDate());
            transactions.add(item);
          }),
          onError: (e) => print('Error completing: $e'),
        );
    filteredTransactions = transactions;
    setState(() {});
  }

  List<Widget> getFilter() {
    List<Widget> filters = [];
    for (var item in categoryItems) {
      filters.add(
        Container(
            // color: Colors.grey,
            decoration: BoxDecoration(
              color: _filterController[categoryItems.indexOf(item)]
                  ? Styles.greenColor
                  : Styles.whiteColor,
              border: Border.all(
                  color: _filterController[categoryItems.indexOf(item)]
                      ? Repository.textColor(context)
                      : getIconColor(item)),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(right: 10),
            height: 30,
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(
                  getIcon(item),
                  size: 15,
                  color: _filterController[categoryItems.indexOf(item)]
                      ? Styles.whiteColor
                      : getIconColor(item),
                ),
                const Gap(2),
                Text(
                  item,
                  style: TextStyle(
                      fontSize: 15,
                      color: _filterController[categoryItems.indexOf(item)]
                          ? Styles.whiteColor
                          : getIconColor(item)),
                ),
              ],
            )),
      );
    }
    return filters;
  }
}
