import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:intl/intl.dart';
import 'package:tripo/widgets/default_text_field.dart';
import 'package:tripo/widgets/my_app_bar.dart';

class AddReceipt extends StatefulWidget {
  const AddReceipt({Key? key}) : super(key: key);

  @override
  _AddReceiptState createState() => _AddReceiptState();
}

class _AddReceiptState extends State<AddReceipt> {
  User? currentUser;
  int _current = 0;
  final TextEditingController _vendorName = TextEditingController();
  final TextEditingController _receiptAmount = TextEditingController();
  final TextEditingController _receiptDate = TextEditingController();
  final TextEditingController _receiptTime = TextEditingController();
  final TextEditingController _receiptAddINfo = TextEditingController();

  @override
  void initState() {
    currentUser = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Repository.bgColor(context),
          appBar: myAppBar(
              title: 'Add Receipt', implyLeading: true, context: context),
          body: Stack(children: [
            CarouselSlider.builder(
                options: CarouselOptions(
                  height: 150,
                  enlargeCenterPage: true,
                  viewportFraction: 0.25,
                  // aspectRatio: 2.0,
                  initialPage: _current,
                  onPageChanged: (i, Null) {
                    setState(() {
                      _current = i;
                      print(categoryItems[i]);
                    });
                  },
                ),
                itemCount: categoryItems.length,
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) {
                  final category = categoryItems[index];
                  return Transform.scale(
                      scale: index == _current ? 1 : 0.8,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Repository.accentColor(context),
                                boxShadow: [
                                  index == _current
                                      ? const BoxShadow(
                                          offset: Offset(0, 1),
                                          color: Colors.grey,
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        )
                                      : const BoxShadow()
                                ],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(getIcon(category),
                                  color: getIconColor(category), size: 28),
                            ),
                            Gap(5),
                            Text(
                              category,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: getIconColor(category)),
                            )
                          ]));
                }),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 150, 15, 0),
              child: Column(
                children: [
                  DefaultTextField(
                      controller: _vendorName, title: 'Vendor Name'),
                  DefaultTextField(
                      controller: _receiptAmount, title: 'Total Amount'),
                  Row(
                    children: [
                      Flexible(
                          child: DefaultTextField(
                        controller: _receiptDate,
                        title: 'Date',
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(
                                  2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101));

                          if (pickedDate != null) {
                            print(
                                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(pickedDate);
                            print(
                                formattedDate); //formatted date output using intl package =>  2021-03-16
                            //you can implement different kind of Date Format here according to your requirement
                            setState(() {
                              _receiptDate.text =
                                  formattedDate; //set output date to TextField value.
                            });
                          } else {
                            print('Date is not selected');
                          }
                        },
                      )),
                      const Gap(20),
                      Flexible(
                          child: DefaultTextField(
                        controller: _receiptTime,
                        title: 'Time',
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());

                          if (pickedTime != null) {
                            print(
                                pickedTime); //pickedDate output format => 2021-03-10 00:00:00.000
                            String formattedTime = DateFormat('HH:mm').format(
                                DateFormat('h:mm a')
                                    .parse(pickedTime.format(context)));
                            print(
                                formattedTime); //formatted date output using intl package =>  2021-03-16
                            //you can implement different kind of Date Format here according to your requirement
                            setState(() {
                              _receiptTime.text =
                                  formattedTime; //set output date to TextField value.
                            });
                          } else {
                            print('Time is not selected');
                          }
                        },
                      ))
                    ],
                  ),
                  DefaultTextField(
                    controller: _receiptAddINfo,
                    title: 'Additional Information',
                  )
                ],
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(top: 500),
                child: SizedBox(
                    height: 150,
                    child: CupertinoDatePicker(
                      onDateTimeChanged: (DateTime dateTime) {
                        print(dateTime);
                      },
                    ))),
          ]),
        ));
  }
}
