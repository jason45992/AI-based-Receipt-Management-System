import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripo/generated/assets.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/widgets/buttons.dart';
import 'package:iconly/iconly.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';

class UserProfile extends StatefulWidget {
  final User user;

  const UserProfile({required this.user});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late User _currentUser;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  String documentId = '';
  String profileImgUrl = '';

  @override
  void initState() {
    _currentUser = widget.user;
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Repository.bgColor(context),
      appBar:
          myAppBar(title: 'Edit Profile', implyLeading: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // const Gap(40),
          Stack(
            children: [
              Container(
                height: 240,
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // color: Repository.accentColor(context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(50),
                      Center(
                          child: Text('${_currentUser.displayName}',
                              style: TextStyle(
                                  color: Repository.textColor(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold))),
                      const Gap(10),
                      Text('${_currentUser.email}',
                          style: TextStyle(
                              color: Repository.subTextColor(context))),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 30,
                right: 30,
                child: DottedBorder(
                    borderType: BorderType.Circle,
                    dashPattern: const [20, 5],
                    color: Colors.grey,
                    strokeWidth: 3,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(93, 5, 5, 5),
                      height: 100,
                      width: 100,
                      // color: Colors.amber,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.greenColor,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Styles.greenColor,
                        radius: 50,
                        backgroundImage: profileImgUrl != ''
                            ? Image.network(profileImgUrl).image
                            : const AssetImage(Assets.defaultUserProfileImg),
                      ),
                    )),
              ),
              Positioned(
                  top: 75,
                  left: 100,
                  right: 30,
                  child: InkWell(
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Styles.primaryColor,
                          border:
                              Border.all(color: Styles.whiteColor, width: 2),
                        ),
                        child: Icon(
                          IconlyBold.edit,
                          color: Styles.greyColor,
                          size: 20,
                        ),
                      ),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: new Icon(Icons.upload),
                                  title: new Text('Upload New Profile Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    uploadNewProfileImage();
                                    setState(() {});
                                  },
                                ),
                                ListTile(
                                  leading: new Icon(Icons.delete),
                                  title: new Text('Rmove Profile Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    deleteProfileImg();
                                    setState(() {});
                                    //set to default photo
                                  },
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }))
            ],
          ),
          const Gap(20),
          Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Styles.greyColor, width: 2),
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    IconlyBroken.profile,
                    size: 25,
                    color: Repository.textColor(context),
                  ),
                ),
                VerticalDivider(
                  color: Styles.greyColor,
                  indent: 10,
                  endIndent: 10,
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(color: Repository.textColor(context)),
                      ),
                      SizedBox(
                        width: 275,
                        height: 30,
                        child: TextFormField(
                          cursorColor: Repository.textColor(context),
                          controller: _name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Repository.textColor(context)),
                          decoration: InputDecoration(
                            hintText: _currentUser.displayName,
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Repository.textColor(context)),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Gap(20),
          Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Styles.greyColor, width: 2),
              // color: Repository.accentColor(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    IconlyBroken.message,
                    size: 25,
                    color: Repository.textColor(context),
                  ),
                ),
                VerticalDivider(
                  color: Styles.greyColor,
                  indent: 10,
                  endIndent: 10,
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(color: Repository.textColor(context)),
                      ),
                      SizedBox(
                        width: 275,
                        height: 30,
                        child: TextFormField(
                          readOnly: true,
                          cursorColor: Repository.textColor(context),
                          controller: _email,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Repository.textColor(context)),
                          decoration: InputDecoration(
                            hintText: _currentUser.email,
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Styles.darkGreyColor),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Gap(40),
          elevatedButton(
              color: Repository.selectedItemColor(context),
              context: context,
              text: 'Update',
              callback: () async {
                // print('Form Valid? ');
                // print(autoAddFormKey.currentState
                //     ?.validate()
                //     .toString());
                // if (autoAddFormKey.currentState!
                //         .validate() &&
                //     validDatetime) {
                //   uploadImage();
                // }
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
        ],
      ),
    );
  }

  getUserData() async {
    final db = FirebaseFirestore.instance;
    await db
        .collection('users')
        .where('email', isEqualTo: _currentUser.email)
        .get()
        .then((res) {
      documentId = res.docs[0].id;
      profileImgUrl = res.docs[0].get('profile_photo_url');
      setState(() {});
    });
  }

  Future<bool> uploadNewProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image!.path.isNotEmpty) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        // ],
        uiSettings: [
          IOSUiSettings(
              title: 'Crop Image',
              aspectRatioPickerButtonHidden: true,
              resetAspectRatioEnabled: false,
              aspectRatioLockEnabled: true),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile != null) {
        await deleteProfileImg();
        await uploadImage(croppedFile.path);
        return true;
      }
    }
    return false;
  }

  uploadImage(imgPath) async {
    final _firebaseStorage = FirebaseStorage.instance;
    final db = FirebaseFirestore.instance;
    //Select Image
    var file = File(imgPath);

    //Upload to Firebase
    var snapshot = await _firebaseStorage
        .ref()
        .child('profile/' + imgPath.split('/').last)
        .putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    print('imageUrl: ' + downloadUrl);

    if (documentId.isNotEmpty) {
      final data = <String, dynamic>{'profile_photo_url': downloadUrl};
      await db
          .collection('users')
          .doc(documentId)
          .update(data)
          .then((value) => setState(() {
                profileImgUrl = downloadUrl;
              }))
          .onError((error, stackTrace) {
        print('object');
      });
    }
  }

  deleteProfileImg() async {
    if (profileImgUrl.isNotEmpty) {
      final db = FirebaseFirestore.instance;
      final _firebaseStorage = FirebaseStorage.instance;
      final desertRef = _firebaseStorage.ref().child('profile/' +
          profileImgUrl.split('profile%2F')[1].split('.jpg')[0] +
          '.jpg');
      // Delete the file
      await desertRef.delete();

      final data = <String, dynamic>{'profile_photo_url': ''};
      db
          .collection('users')
          .doc(documentId)
          .update(data)
          .then((value) => setState(() {
                profileImgUrl = '';
              }))
          .onError((error, stackTrace) {
        print(error);
      });
    }
  }
}
