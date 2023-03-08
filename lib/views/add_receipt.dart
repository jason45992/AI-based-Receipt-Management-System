import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:intl/intl.dart';
import 'package:tripo/utils/functions.dart';
import 'package:tripo/utils/validation.dart';
import 'package:tripo/widgets/buttons.dart';
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
  List<bool> isSelectedWarranty = [false, true];
  GlobalKey<FormState> addFormKey = GlobalKey<FormState>();
  final TextEditingController _vendorName = TextEditingController();
  final TextEditingController _receiptAmount = TextEditingController();
  final TextEditingController _receiptDate = TextEditingController();
  final TextEditingController _receiptTime = TextEditingController();
  // final TextEditingController _receiptAddINfo = TextEditingController();
  String _receiptCatehory = 'Food';
  bool _receiptWarranty = false;

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
            body: Form(
              key: addFormKey,
              child: ListView(children: [
                CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 190,
                      enlargeCenterPage: true,
                      viewportFraction: 0.25,
                      // aspectRatio: 2.0,
                      initialPage: _current,
                      onPageChanged: (i, Null) {
                        setState(() {
                          _current = i;
                          _receiptCatehory = categoryItems[i];
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
                                const Gap(5),
                                Text(
                                  category,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: getIconColor(category)),
                                )
                              ]));
                    }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: [
                      DefaultTextField(
                        controller: _vendorName,
                        title: 'Vendor Name',
                        onFieldSubmitted: (String value) {
                          print(value + 'identifier');
                        },
                      ),
                      DefaultTextField(
                        controller: _receiptAmount,
                        title: 'Total Amount',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Value cannot be empty';
                          } else if (!amount.hasMatch(value)) {
                            return 'PLease enter amount with 2 decimal place';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: DefaultTextField(
                            readOnly: true,
                            controller: _receiptDate,
                            title: 'Date',
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  builder: (context, child) {
                                    return dateTimepickerTheme(context, child);
                                  },
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
                            readOnly: true,
                            controller: _receiptTime,
                            title: 'Time',
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                  builder: (context, child) {
                                    return dateTimepickerTheme(context, child);
                                  },
                                  context: context,
                                  initialTime: TimeOfDay.now());

                              if (pickedTime != null) {
                                print(
                                    pickedTime); //pickedDate output format => 2021-03-10 00:00:00.000
                                String formattedTime = DateFormat('HH:mm')
                                    .format(DateFormat('h:mm a')
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
                      // DefaultTextField(
                      //   controller: _receiptAddINfo,
                      //   mandatory: false,
                      //   title: 'Additional Information',
                      // )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 15, 15, 40),
                  child: Row(children: [
                    Text(
                      'Warranty: ',
                      style: TextStyle(
                          fontFamily: 'DMSans',
                          color: Repository.textColor(context),
                          fontWeight: FontWeight.w500,
                          fontSize: 17),
                    ),
                    const Gap(20),
                    ToggleButtons(
                      constraints: BoxConstraints(
                          minWidth:
                              (MediaQuery.of(context).size.width - 36) / 3,
                          minHeight: 40),
                      borderWidth: 2,
                      borderRadius: BorderRadius.circular(50),
                      color: Repository.selectedItemColor(context),
                      borderColor: Repository.textColor(context),
                      selectedBorderColor: Repository.textColor(context),
                      selectedColor: Colors.white,
                      fillColor: Repository.selectedItemColor(context),
                      children: const <Widget>[
                        Icon(Icons.done),
                        Icon(Icons.close)
                      ],
                      isSelected: isSelectedWarranty,
                      onPressed: (int newIndex) {
                        setState(() {
                          _receiptWarranty = newIndex == 0;
                          print(_receiptWarranty);
                          // looping through the list of booleans values
                          for (int index = 0;
                              index < isSelectedWarranty.length;
                              index++) {
                            // checking for the index value
                            if (index == newIndex) {
                              // one button is always set to true
                              isSelectedWarranty[index] = true;
                            } else {
                              // other two will be set to false and not selected
                              isSelectedWarranty[index] = false;
                            }
                          }
                        });
                      },
                    )
                  ]),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: elevatedButton(
                        color: Repository.selectedItemColor(context),
                        context: context,
                        text: 'Add Receipt',
                        callback: () {
                          print('Form Valid? ');
                          print(addFormKey.currentState?.validate().toString());
                          submitForm();
                        }))
              ]),
            )));
  }

  Theme dateTimepickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Repository.textColor(context), // <-- SEE HERE
          onPrimary: Repository.accentColor(context), // <-- SEE HERE
          onSurface: Repository.textColor(context), // <-- SEE HERE
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Repository.textColor(context), // button text color
          ),
        ),
      ),
      child: child!,
    );
  }

  void submitForm() {
    print(_receiptCatehory);
    print(_vendorName.text);
    print(_receiptAmount.text);
    print(_receiptDate.text);
    print(_receiptTime.text);
    // print(_receiptAddINfo.text);
    print(_receiptWarranty);

    final db = FirebaseFirestore.instance;

    //Create record in FireStore
    final receiptInfo = <String, dynamic>{
      'vendor_name': _vendorName.text.capitalizeFistWord(),
      'date_time': Timestamp.fromDate(DateFormat('dd/MM/yyyy HH:mm')
          .parseStrict(_receiptDate.text + ' ' + _receiptTime.text)),
      'category': _receiptCatehory,
      'total_amount': _receiptAmount.text,
      'user_email': currentUser?.email,
      // 'addtional_info': _receiptAddINfo.text,
      'with_warranty': _receiptWarranty,
      'lat': 0,
      'lng': 0,
      'image_url': ''
    };
    db.collection('receipts').add(receiptInfo).then((DocumentReference doc) {
      print('DocumentSnapshot added with ID: ${doc.id}');
      Navigator.of(context).restorablePush(_dialogSuccessBuilder);
    }).onError((error, stackTrace) {
      Navigator.of(context).restorablePush(_dialogFailBuilder);
    });
  }

  static Route<Object?> _dialogSuccessBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Receipt added successfully.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Route<Object?> _dialogFailBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
