import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripo/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:tripo/widgets/default_text_field.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:tripo/json/category_list.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({Key? key, required this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  var imagePath;
  final TextEditingController _vendor = TextEditingController();
  final TextEditingController _receiptInfo = TextEditingController();

  String? selectedValue = 'Others';
  late Image resultImg;
  String receiptVendorName = '';
  String receiptDateTime = '';
  String receiptCategory = '';
  String receiptTotalPrice = '';

  @override
  void initState() {
    imagePath = widget.imagePath;
    super.initState();
  }

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    await getInfo();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    resultImg = Image.file(File(imagePath));
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
                            Expanded(
                              child: ListView(children: [
                                DefaultTextField(
                                    controller: _vendor,
                                    title: 'Vendor Name',
                                    label: receiptVendorName),
                                DefaultTextField(
                                    controller: _receiptInfo,
                                    title: 'Date Time',
                                    label: receiptDateTime),
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
                                              value: selectedValue,
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                color: Repository.fieldColor(
                                                    context),
                                              ),
                                              iconSize: 30,
                                              buttonHeight: 50,
                                              buttonWidth: 180,
                                              dropdownDecoration: BoxDecoration(
                                                color: Repository.cardColor3(
                                                    context),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              buttonDecoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1.5,
                                                  color: Styles.darkGreyColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              selectedItemBuilder: (context) {
                                                return categoryItems.map(
                                                  (item) {
                                                    return Container(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .centerStart,
                                                      child: Text(
                                                        selectedValue!,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Repository
                                                              .textColor(
                                                                  context),
                                                          overflow: TextOverflow
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
                                                // showDialog<String>(
                                                //   context: context,
                                                //   builder: (BuildContext context) => AlertDialog(
                                                //     title: const Text('AlertDialog Title'),
                                                //     content: Text(value.toString()),
                                                //     actions: <Widget>[
                                                //       TextButton(
                                                //         onPressed: () =>
                                                //             Navigator.pop(context, 'Cancel'),
                                                //         child: const Text('Cancel'),
                                                //       ),
                                                //       TextButton(
                                                //         onPressed: () =>
                                                //             Navigator.pop(context, 'OK'),
                                                //         child: const Text('OK'),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // );
                                                // setState(() {
                                                selectedValue =
                                                    value.toString();
                                                // });
                                              }),
                                          const Gap(10),
                                        ]),
                                    const Gap(20),
                                    Flexible(
                                      child: DefaultTextField(
                                          controller: _receiptInfo,
                                          title: 'Total Price',
                                          label: receiptTotalPrice),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                elevatedButton(
                                    color:
                                        Repository.selectedItemColor(context),
                                    context: context,
                                    text: 'Add Receipt',
                                    callback: () async {}),
                              ]),
                            )
                          ],
                        ));
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
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
          } else if (element['Type'] == 'receipt_date') {
            receiptDate = element['Value'];
          } else if (element['Type'] == 'purchase_time') {
            receiptTime = element['Value'];
          }
        }

        imagePath = filePath;
        receiptDateTime = receiptDate + ' ' + receiptTime;

        if (receiptVendorName.isNotEmpty) {
          // get category
          // Optionally the request above could also be done as
          Response cateResponse = await dio.get(
              'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=name%2Cformatted_address%2Ctype&inputtype=textquery',
              queryParameters: {
                'input': receiptVendorName,
                'key': 'AIzaSyBEpmr8uq2K8mqIEND9eIBe_FTjbdx9oRI'
              });

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
                  selectedValue = element.first.capitalize();
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
}
