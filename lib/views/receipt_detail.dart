import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/layouts.dart';
import 'package:tripo/utils/size_config.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';

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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    _currentTransaction = widget.transaction;
    imagePath = _currentTransaction['image_url'];
    _center = LatLng(_currentTransaction['lat'].toDouble(),
        _currentTransaction['lng'].toDouble());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);

    SizeConfig.init(context);
    return Scaffold(
        backgroundColor: Repository.bgColor(context),
        appBar: myAppBar(
            title: 'Receipt Detail', implyLeading: true, context: context),
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Column(
              children: [
                imagePath.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                        height: 260.0,
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
                Expanded(
                  child: ListView(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vendor Name: ' +
                                _currentTransaction['vendor_name'],
                            style: TextStyle(
                                color: Repository.textColor(context),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            // textAlign: TextAlign.left,
                          ),
                          const Gap(5),
                          Text(
                            'Category: ' + _currentTransaction['category'],
                            style: TextStyle(
                                color: Repository.textColor(context),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            // textAlign: TextAlign.left,
                          ),
                          const Gap(5),
                          Text(
                            'Amount: ' + _currentTransaction['total_amount'],
                            style: TextStyle(
                                color: Repository.textColor(context),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            // textAlign: TextAlign.left,
                          ),
                          const Gap(5),
                          Text(
                            'Date Time: ' + _currentTransaction['date_time'],
                            style: TextStyle(
                                color: Repository.textColor(context),
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            // textAlign: TextAlign.left,
                          ),
                          const Gap(5),
                        ]),
                    _center.latitude == 0
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
                    imagePath.isNotEmpty
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
                    elevatedButton(
                        color: Repository.selectedItemColor(context),
                        context: context,
                        text: 'Delete Receipt',
                        callback: () {
                          Navigator.of(context)
                              .push(_dialogConfirmBuilder(context, null));
                        }),
                  ]),
                )
              ],
            )));
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
      Navigator.of(context).restorablePush(_dialogSuccessBuilder);
    }).onError((error, stackTrace) {
      Navigator.of(context).restorablePush(_dialogErrorBuilder);
    });
  }

  static Route<Object?> _dialogSuccessBuilder(
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
