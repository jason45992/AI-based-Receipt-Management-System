import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:tripo/json/category_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:tripo/utils/size_config.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/utils/validation.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:tripo/widgets/default_text_field.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ReceiptDetail extends StatefulWidget {
  final Map<String, dynamic> transaction;
  const ReceiptDetail({required this.transaction});

  @override
  _ReceiptDetailState createState() => _ReceiptDetailState();
}

class _ReceiptDetailState extends State<ReceiptDetail> {
  String imagePath = '';
  String saveButtonText = 'Save to Album';
  late Map<String, dynamic> _currentTransaction;
  late GoogleMapController mapController;
  LatLng _center = const LatLng(0, 0);
  bool _editable = false;
  GlobalKey<FormState> upateFormKey = GlobalKey<FormState>();
  final TextEditingController _vendorName = TextEditingController();
  String _receiptCategory = 'Others';
  final TextEditingController _receiptAmount = TextEditingController();
  final TextEditingController _receiptDate = TextEditingController();
  final TextEditingController _receipWarranty = TextEditingController();
  List<bool> isSelectedWarranty = [false, true];
  bool _receiptWarranty = false;
  bool validDatetime = false;
  bool _isProcessing = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    _currentTransaction = widget.transaction;
    imagePath = _currentTransaction['image_url'];
    _center = LatLng(_currentTransaction['lat'].toDouble(),
        _currentTransaction['lng'].toDouble());
    _vendorName.text = _currentTransaction['vendor_name'];
    _receiptCategory = _currentTransaction['category'];
    _receiptAmount.text = _currentTransaction['total_amount'];
    _receiptDate.text = _currentTransaction['date_time'];
    _receipWarranty.text = _currentTransaction['with_warranty'] ? 'Yes' : 'No';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);

    SizeConfig.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Repository.bgColor(context),
      appBar: myAppBar(
          title: 'Receipt Detail', implyLeading: true, context: context),
      body: _isProcessing
          ? CircularProgressIndicator(
              color: Styles.primaryColor,
            )
          : SnappingSheet(
              snappingPositions: [
                  SnappingPosition.pixels(
                    positionPixels: MediaQuery.of(context).size.height * 0.45,
                    snappingCurve: Curves.elasticOut,
                    snappingDuration: const Duration(milliseconds: 1750),
                  ),
                  const SnappingPosition.factor(
                    positionFactor: 0.98,
                    snappingCurve: Curves.bounceOut,
                    snappingDuration: Duration(seconds: 1),
                    grabbingContentOffset: GrabbingContentOffset.bottom,
                  ),
                ],
              child: imagePath.isNotEmpty
                  ? Container(
                      color: Repository.textColor(context),
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 400),
                      // height: 200.0,
                      child: ClipRect(
                        child: PhotoView.customChild(
                          // wantKeepAlive: true,
                          backgroundDecoration: BoxDecoration(
                              color: Repository.accentColor(context)),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Repository.accentColor(context)),
                              padding: const EdgeInsets.all(10.0),
                              child: Image.network(imagePath,
                                  fit: BoxFit.contain)),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              grabbingHeight: 50,
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
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Repository.iconColor(context),
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    ],
                  )),
              sheetBelow: SnappingSheetContent(
                  sizeBehavior: SheetSizeStatic(size: 300),
                  draggable: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    color: Colors.white,
                    child: ListView(children: [
                      Form(
                        key: upateFormKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultTextField(
                                readOnly: !_editable,
                                controller: _vendorName,
                                title: 'Vendor Name',
                              ),
                              const Gap(5),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 80,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Category',
                                            style: TextStyle(
                                                color: Repository.textColor(
                                                    context),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15),
                                          ),
                                          const Gap(4),
                                          CustomDropdownButton2(
                                              hint: '',
                                              value: _receiptCategory,
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                color: Repository.fieldColor(
                                                    context),
                                              ),
                                              iconSize: 30,
                                              buttonHeight: 48,
                                              buttonWidth: 180,
                                              dropdownDecoration: BoxDecoration(
                                                color: Styles.purewhiteColor,
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
                                                        _receiptCategory,
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
                                              onChanged: _editable
                                                  ? (value) {
                                                      _receiptCategory =
                                                          value.toString();
                                                    }
                                                  : null)
                                        ]),
                                  ),
                                  const Gap(5),
                                  Flexible(
                                    child: DefaultTextField(
                                      readOnly: !_editable,
                                      controller: _receiptAmount,
                                      title: 'Amount',
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Value cannot be empty';
                                        } else if (!amount.hasMatch(value)) {
                                          return 'PLease enter 2 d.p. value';
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              ),
                              const Gap(5),
                              Row(
                                children: [
                                  Flexible(
                                    child: DefaultTextField(
                                      readOnly: !_editable,
                                      controller: _receiptDate,
                                      title: 'Date Time',
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          validDatetime = false;
                                          return 'Value cannot be empty';
                                        } else if (!isValidDate(
                                                value, 'dd/MM/yyyy HH:mm') ||
                                            !appDate.hasMatch(value)) {
                                          validDatetime = false;
                                          return 'Not in \'dd/MM/yyyy HH:mm\'';
                                        }
                                        validDatetime = true;
                                        return null;
                                      },
                                    ),
                                  ),
                                  const Gap(10),
                                  _editable
                                      ? SizedBox(
                                          height: 85,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Warranty',
                                                  style: TextStyle(
                                                      color:
                                                          Repository.textColor(
                                                              context),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15),
                                                ),
                                                const Gap(6),
                                                ToggleButtons(
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 80,
                                                            minHeight: 40),
                                                    borderWidth: 2,
                                                    borderRadius: BorderRadius
                                                        .circular(50),
                                                    color: Repository
                                                        .selectedItemColor(
                                                            context),
                                                    borderColor:
                                                        Repository
                                                            .textColor(context),
                                                    selectedBorderColor:
                                                        Repository
                                                            .textColor(context),
                                                    selectedColor: Colors.white,
                                                    fillColor:
                                                        Repository
                                                            .selectedItemColor(
                                                                context),
                                                    children: const <Widget>[
                                                      Icon(Icons.done),
                                                      Icon(Icons.close)
                                                    ],
                                                    isSelected:
                                                        isSelectedWarranty,
                                                    onPressed: (int newIndex) {
                                                      setState(() {
                                                        _receiptWarranty =
                                                            newIndex == 0;
                                                        print(_receiptWarranty);
                                                        // looping through the list of booleans values
                                                        for (int index = 0;
                                                            index <
                                                                isSelectedWarranty
                                                                    .length;
                                                            index++) {
                                                          // checking for the index value
                                                          if (index ==
                                                              newIndex) {
                                                            // one button is always set to true
                                                            isSelectedWarranty[
                                                                index] = true;
                                                          } else {
                                                            // other two will be set to false and not selected
                                                            isSelectedWarranty[
                                                                index] = false;
                                                          }
                                                        }
                                                      });
                                                    })
                                              ])
                                          // DefaultTextField(
                                          //   readOnly: !_editable,
                                          //   controller: _receipWarranty,
                                          //   title: 'Warranty',
                                          // ),
                                          )
                                      : Flexible(
                                          child: DefaultTextField(
                                            readOnly: true,
                                            controller: _receipWarranty,
                                            title: 'Warranty',
                                          ),
                                        ),
                                ],
                              ),
                            ]),
                      ),
                      const Gap(5),
                      (_center.latitude == 0 || _editable)
                          ? const Gap(0)
                          : SizedBox(
                              height: 200,
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: _center,
                                  zoom: 16,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('marker_1'),
                                    position: _center,
                                  )
                                },
                                myLocationButtonEnabled: false,
                              ),
                            ),
                      const Gap(20),
                      (imagePath.isNotEmpty && !_editable)
                          ? elevatedButton(
                              color: Repository.selectedItemColor(context),
                              context: context,
                              text: saveButtonText,
                              callback: () {
                                GallerySaver.saveImage(imagePath + '&ext=.jpg')
                                    .then((value) {
                                  setState(() {
                                    saveButtonText = 'Image saved';
                                  });
                                }).onError((error, stackTrace) {
                                  print(error);
                                  setState(() {
                                    saveButtonText = 'Please try again';
                                  });
                                });
                              })
                          : const SizedBox.shrink(),
                      const Gap(10),
                      _editable
                          ? elevatedButton(
                              color: Repository.selectedItemColor(context),
                              context: context,
                              text: 'Update Receipt',
                              callback: () {
                                if (upateFormKey.currentState!.validate() &&
                                    validDatetime) {
                                  updateReceipt();
                                }
                              })
                          : elevatedButton(
                              color: Repository.selectedItemColor(context),
                              context: context,
                              text: 'Edit Receipt',
                              callback: () {
                                setState(() {
                                  _editable = true;
                                });
                                // Navigator.of(context)
                                //     .push(_dialogConfirmBuilder(context, null));
                              }),
                      const Gap(10),
                      !_editable
                          ? elevatedButton(
                              color: Repository.selectedItemColor(context),
                              context: context,
                              text: 'Delete Receipt',
                              callback: () {
                                Navigator.of(context)
                                    .push(_dialogConfirmBuilder(context, null));
                              })
                          : const SizedBox.shrink(),
                    ]),
                  ))),
    );
  }

  Route<Object?> _dialogConfirmBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure to delete this receipt?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                deleteReceipt();
              },
              child: const Text('Yes'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  deleteReceipt() async {
    final db = FirebaseFirestore.instance;
    final _firebaseStorage = FirebaseStorage.instance;
    // Create a reference to the file to delete
    if (imagePath.isNotEmpty) {
      final desertRef = _firebaseStorage.ref().child('images/' +
          imagePath.split('images%2F')[1].split('.jpg')[0] +
          '.jpg');
      // Delete the file
      await desertRef.delete();
    }

    db
        .collection('receipts')
        .doc(_currentTransaction['id'])
        .delete()
        .then((doc) {
      print('Document deleted');
      Navigator.of(context).restorablePush(_dialogDeleteSuccessBuilder);
    }).onError((error, stackTrace) {
      Navigator.of(context).restorablePush(_dialogErrorBuilder);
    });
  }

  updateReceipt() async {
    final data = <String, dynamic>{
      'vendor_name': _vendorName.text,
      'category': _receiptCategory,
      'total_amount': _receiptAmount.text,
      'date_time': Timestamp.fromDate(
          DateFormat('dd/MM/yyyy HH:mm').parseStrict(_receiptDate.text)),
      'with_warranty': _receiptWarranty,
    };
    print(data.toString());
    final db = FirebaseFirestore.instance;
    db
        .collection('receipts')
        .doc(_currentTransaction['id'])
        .update(data)
        .then((doc) {
      print('Document Updated');
      Navigator.of(context).restorablePush(_dialogUpdateSuccessBuilder);
    }).onError((error, stackTrace) {
      Navigator.of(context).restorablePush(_dialogErrorBuilder);
    });
  }

  static Route<Object?> _dialogDeleteSuccessBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Receipt is deleted successfully.'),
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

  static Route<Object?> _dialogUpdateSuccessBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Receipt updated successfully.'),
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

  static Route<Object?> _dialogErrorBuilder(
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
