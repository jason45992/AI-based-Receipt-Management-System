import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:tripo/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/utils/validation.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:tripo/widgets/default_text_field.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:tripo/json/category_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({Key? key, required this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  String imagePath = '';
  User? currentUser;
  String orignalImgPath = '';
  List<bool> isSelectedWarranty = [false, true];
  bool validDatetime = false;
  bool _isProcessing = false;
  GlobalKey<FormState> autoAddFormKey = GlobalKey<FormState>();
  final TextEditingController _vendor = TextEditingController();
  final TextEditingController _receiptDate = TextEditingController();
  final TextEditingController _receiptAmount = TextEditingController();

  late Image resultImg;
  String receiptVendorName = '';
  String receiptVendorAddress = '';
  String receiptDateTime = '';
  String receiptCategory = 'Others';
  String receiptTotalPrice = '';
  String _receiptWarranty = 'No';
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    imagePath = widget.imagePath;
    orignalImgPath = widget.imagePath;
    currentUser = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    await getInfo();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            backgroundColor: Repository.bgColor(context),
            appBar: myAppBar(
                title: 'Preview', implyLeading: true, context: context),
            body: FutureBuilder(
                future: _initializeFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              height: 260.0,
                              child: ClipRect(
                                child: PhotoView.customChild(
                                  // wantKeepAlive: true,
                                  backgroundDecoration: BoxDecoration(
                                      color: Repository.accentColor(context)),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Repository.accentColor(context)),
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.file(File(imagePath),
                                          fit: BoxFit.contain)),
                                ),
                              ),
                            ),
                            const Gap(20),
                            Form(
                                key: autoAddFormKey,
                                child: Expanded(
                                  child: ListView(children: [
                                    DefaultTextField(
                                        controller: _vendor,
                                        title: 'Vendor Name',
                                        label: receiptVendorName),
                                    DefaultTextField(
                                      controller: _receiptDate,
                                      title: 'Date Time',
                                      label: receiptDateTime,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          validDatetime = false;
                                          return 'Value cannot be empty';
                                        } else if (!isValidDate(
                                                value, 'dd/MM/yyyy HH:mm') ||
                                            !appDate.hasMatch(value)) {
                                          validDatetime = false;
                                          return 'PLease enter a valid date (dd/MM/yyyy HH:mm)';
                                        }
                                        validDatetime = true;
                                        return null;
                                      },
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Category',
                                                style: TextStyle(
                                                    color: Repository.textColor(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                                // textAlign: TextAlign.left,
                                              ),
                                              const Gap(5),
                                              CustomDropdownButton2(
                                                  hint: '',
                                                  value: receiptCategory,
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color:
                                                        Repository.fieldColor(
                                                            context),
                                                  ),
                                                  iconSize: 30,
                                                  buttonHeight: 50,
                                                  buttonWidth: 180,
                                                  dropdownDecoration:
                                                      BoxDecoration(
                                                    color:
                                                        Repository.cardColor3(
                                                            context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  buttonDecoration:
                                                      BoxDecoration(
                                                    border: Border.all(
                                                      width: 1.5,
                                                      color:
                                                          Styles.darkGreyColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  selectedItemBuilder:
                                                      (context) {
                                                    return categoryItems.map(
                                                      (item) {
                                                        return Container(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          child: Text(
                                                            receiptCategory,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Repository
                                                                  .textColor(
                                                                      context),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                        );
                                                      },
                                                    ).toList();
                                                  },
                                                  dropdownItems: categoryItems,
                                                  onChanged: (value) {
                                                    receiptCategory =
                                                        value.toString();
                                                  }),
                                              const Gap(10),
                                            ]),
                                        const Gap(20),
                                        Flexible(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(
                                                'Warranty',
                                                style: TextStyle(
                                                    color: Repository.textColor(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15),
                                                // textAlign: TextAlign.left,
                                              ),
                                              const Gap(5),
                                              CustomDropdownButton2(
                                                  hint: '',
                                                  value: _receiptWarranty,
                                                  icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color:
                                                        Repository.fieldColor(
                                                            context),
                                                  ),
                                                  iconSize: 30,
                                                  buttonHeight: 50,
                                                  buttonWidth: 180,
                                                  dropdownDecoration:
                                                      BoxDecoration(
                                                    color:
                                                        Repository.cardColor3(
                                                            context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  buttonDecoration:
                                                      BoxDecoration(
                                                    border: Border.all(
                                                      width: 1.5,
                                                      color:
                                                          Styles.darkGreyColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  selectedItemBuilder:
                                                      (context) {
                                                    return categoryItems.map(
                                                      (item) {
                                                        return Container(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          child: Text(
                                                            _receiptWarranty,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Repository
                                                                  .textColor(
                                                                      context),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                        );
                                                      },
                                                    ).toList();
                                                  },
                                                  dropdownItems: const [
                                                    'Yes',
                                                    'No'
                                                  ],
                                                  onChanged: (value) {
                                                    _receiptWarranty =
                                                        value.toString();
                                                  }),
                                              const Gap(10),
                                            ])),
                                      ],
                                    ),
                                    DefaultTextField(
                                      controller: _receiptAmount,
                                      title: 'Total Price',
                                      label: receiptTotalPrice,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Value cannot be empty';
                                        } else if (!amount.hasMatch(value)) {
                                          return 'PLease enter amount with 2 decimal place';
                                        }
                                        return null;
                                      },
                                    ),
                                    const Gap(10),
                                    _isProcessing
                                        ? CircularProgressIndicator(
                                            color: Styles.primaryColor,
                                          )
                                        : elevatedButton(
                                            color: Repository.selectedItemColor(
                                                context),
                                            context: context,
                                            text: 'Add Receipt',
                                            callback: () async {
                                              print('Form Valid? ');
                                              print(autoAddFormKey.currentState
                                                  ?.validate()
                                                  .toString());
                                              if (autoAddFormKey.currentState!
                                                      .validate() &&
                                                  validDatetime) {
                                                setState(() {
                                                  _isProcessing = true;
                                                });
                                                uploadImage();
                                              }
                                              //   print(_vendor.text
                                              //       .capitalizeFistWord());
                                              //   print(Timestamp.fromDate(DateFormat(
                                              //           'dd/MM/yyyy HH:mm')
                                              //       .parseStrict(_receiptDate.text)));
                                              //   print(receiptCategory);
                                              //   print(
                                              //       double.parse(_receiptAmount.text)
                                              //           .toStringAsFixed(2));
                                              //   print(_receiptWarranty.toString());
                                            }),
                                  ]),
                                ))
                          ],
                        ));
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: Styles.primaryColor,
                    ),
                  );
                })));
  }

  Future<void> getInfo() async {
    var dio = Dio();
    print(imagePath);

    String fileName = imagePath.split('/').last;
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
    });
    final response = await dio.post('https://image-ocr-jkabdnncda-as.a.run.app',
        data: formData, options: Options(responseType: ResponseType.bytes));
    // print(ocrResult);
    List<dynamic> ocrResult = jsonDecode(response.headers['result']!.first);
    if (response.statusCode == 200) {
      try {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath = '$tempPath/$fileName';
        var file = File(filePath);
        await file.writeAsBytes(response.data);
        print(filePath);

        String receiptDate = '';
        String receiptTime = '';
        for (var element in ocrResult) {
          if (element['Type'] == 'total_amount') {
            receiptTotalPrice = element['Value'];
          } else if (element['Type'] == 'supplier_name') {
            receiptVendorName = element['Value'];
          } else if (element['Type'] == 'supplier_address') {
            receiptVendorAddress = element['Value'];
          } else if (element['Type'] == 'receipt_date') {
            receiptDate = element['Value'];
          } else if (element['Type'] == 'purchase_time') {
            receiptTime = element['Value'];
          }
        }

        imagePath = filePath;
        receiptDateTime = formatDatetime(receiptDate, receiptTime);

        _vendor.text = receiptVendorName.replaceAll('\n', ' ');
        _receiptDate.text = receiptDateTime.replaceAll('\n', ' ');
        _receiptAmount.text = receiptTotalPrice.replaceAll('\n', '');

        if (receiptVendorName.isNotEmpty) {
          // get category
          // Optionally the request above could also be done as
          Response cateResponse = await dio.get(
              'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cformatted_address%2Ctype%2Cgeometry&inputtype=textquery',
              queryParameters: {
                'input': receiptVendorName + ' ' + receiptVendorAddress,
                'key': 'AIzaSyBEpmr8uq2K8mqIEND9eIBe_FTjbdx9oRI'
              });
          print(cateResponse);

          //set location
          lat =
              cateResponse.data['candidates'][0]['geometry']['location']['lat'];
          lng =
              cateResponse.data['candidates'][0]['geometry']['location']['lng'];

          //set category
          List<dynamic> returnedCateList =
              cateResponse.data['candidates'][0]['types'];
          returnedCateList.remove('point_of_interest');
          returnedCateList.remove('establishment');

          String returnedCate = cateResponse.data['candidates'][0]['types'][1];
          print('tempCate ' + returnedCate);
          if (returnedCate.isNotEmpty) {
            for (var element in categoryList) {
              for (var item in element) {
                if (returnedCate.contains(item)) {
                  receiptCategory = element.first.capitalize();
                  break;
                }
              }
            }
          }
        }
      } catch (ex) {
        print(ex);
      }
    }
  }

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final db = FirebaseFirestore.instance;
    //Select Image
    var file = File(orignalImgPath);

    if (orignalImgPath != '') {
      //Upload to Firebase
      var snapshot = await _firebaseStorage
          .ref()
          .child('images/' + orignalImgPath.split('/').last)
          .putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      print('imageUrl: ' + downloadUrl);

      //Create record in FireStore
      final receiptInfo = <String, dynamic>{
        'vendor_name': _vendor.text.capitalizeFistWord(),
        'date_time': Timestamp.fromDate(
            DateFormat('dd/MM/yyyy HH:mm').parseStrict(_receiptDate.text)),
        'category': receiptCategory,
        'total_amount': double.parse(_receiptAmount.text).toStringAsFixed(2),
        'image_url': downloadUrl,
        'user_email': currentUser?.email,
        'lat': lat,
        'lng': lng,
        'with_warranty': _receiptWarranty == 'Yes'
      };

      db.collection('receipts').add(receiptInfo).then((DocumentReference doc) {
        print('DocumentSnapshot added with ID: ${doc.id}');
        setState(() {
          _isProcessing = false;
        });
        Navigator.of(context).restorablePush(_dialogSuccessBuilder);
      }).onError((error, stackTrace) {
        setState(() {
          _isProcessing = false;
        });
        Navigator.of(context).restorablePush(_dialogFailBuilder);
      });
    } else {
      print('No Image Path Received');
    }
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

  String formatDatetime(String date, String time) {
    //prase date
    if (date.isNotEmpty && !isValidDate(date, 'dd/MM/yyyy')) {
      String dateFormat = '';
      if (isValidDate(date, 'dd-MM-yyyy')) {
        dateFormat = 'dd-MM-yyyy';
      } else if (isValidDate(date, 'dd MM yyyy')) {
        dateFormat = 'dd MM yyyy';
      } else if (isValidDate(date, 'MM/dd/yyyy')) {
        dateFormat = 'MM/dd/yyyy';
      } else if (isValidDate(date, 'MM-dd-yyyy')) {
        dateFormat = 'MM-dd-yyyy';
      } else if (isValidDate(date, 'MM dd yyyy')) {
        dateFormat = 'MM dd yyyy';
      } else if (isValidDate(date, 'yyyy/MM/dd')) {
        dateFormat = 'yyyy/MM/dd';
      } else if (isValidDate(date, 'yyyy-MM-dd')) {
        dateFormat = 'yyyy-MM-dd';
      } else if (isValidDate(date, 'yyyy MM dd')) {
        dateFormat = 'yyyy MM dd';
      } else if (isValidDate(date, 'dd/MM/yy')) {
        dateFormat = 'dd/MM/yy';
      } else if (isValidDate(date, 'dd-MM-yy')) {
        dateFormat = 'dd-MM-yy';
      } else if (isValidDate(date, 'dd MM yy')) {
        dateFormat = 'dd MM yy';
      } else if (isValidDate(date, 'MM/dd/yy')) {
        dateFormat = 'MM/dd/yy';
      } else if (isValidDate(date, 'MM-dd-yy')) {
        dateFormat = 'MM-dd-yy';
      } else if (isValidDate(date, 'MM dd yy')) {
        dateFormat = 'MM dd yy';
      } else if (isValidDate(date, 'yy/MM/dd')) {
        dateFormat = 'yy/MM/dd';
      } else if (isValidDate(date, 'yy-MM-dd')) {
        dateFormat = 'yy-MM-dd';
      } else if (isValidDate(date, 'yy MM dd')) {
        dateFormat = 'yy MM dd';
      } else if (isValidDate(date, 'yy MMM dd')) {
        dateFormat = 'yy MMM dd';
      } else if (isValidDate(date, 'MMM dd yy')) {
        dateFormat = 'MMM dd yy';
      } else if (isValidDate(date, 'yy MMMM dd')) {
        dateFormat = 'yy MMMM dd';
      } else if (isValidDate(date, 'MMMM dd yy')) {
        dateFormat = 'MMMM dd yy';
      } else if (isValidDate(date, 'yyyy MMM dd')) {
        dateFormat = 'yyyy MMM dd';
      } else if (isValidDate(date, 'MMM dd yyyy')) {
        dateFormat = 'MMM dd yyyy';
      } else if (isValidDate(date, 'yyyy MMMM dd')) {
        dateFormat = 'yyyy MMMM dd';
      } else if (isValidDate(date, 'MMMM dd yyyy')) {
        dateFormat = 'MMMM dd yyyy';
      }
      if (dateFormat.isNotEmpty) {
        date = DateFormat('dd/MM/yyyy')
            .format(DateFormat(dateFormat).parseStrict(date));
      }
    }

    if (time.isNotEmpty && !isValidDate(time, 'HH:mm')) {
      String timeFormat = '';
      if (isValidDate(time, 'Hms')) {
        timeFormat = 'Hms';
      } else if (isValidDate(time, 'jm')) {
        timeFormat = 'jm';
      } else if (isValidDate(time, 'jms')) {
        timeFormat = 'jms';
      } else if (isValidDate(time, 'hh:mm a')) {
        timeFormat = 'hh:mm a';
      } else if (isValidDate(time, 'hh:mma')) {
        timeFormat = 'hh:mma';
      }
      if (timeFormat.isNotEmpty) {
        time = DateFormat.Hm().format(DateFormat(timeFormat).parseStrict(time));
      }
    }

    print(date + ' ' + time);

    return date + ' ' + time;
  }
}
