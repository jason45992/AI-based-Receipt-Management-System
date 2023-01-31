import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripo/auth/login_page.dart';
import 'package:tripo/generated/assets.dart';
import 'package:tripo/json/shortcut_list.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/widgets/custom_list_tile.dart';
import 'package:tripo/utils/iconly/iconly_bold.dart';
import 'package:tripo/utils/styles.dart';
import 'package:tripo/widgets/my_app_bar.dart';
import 'package:gap/gap.dart';

class Profile extends StatefulWidget {
  final User user;

  const Profile({required this.user});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Repository.bgColor(context),
      appBar: myAppBar(title: 'Profile', implyLeading: false, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // const Gap(40),
          Stack(
            children: [
              Container(
                height: 270,
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Repository.accentColor(context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(60),
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
                      const Gap(25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: profilesShortcutList.map<Widget>((e) {
                          return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              // padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              // child: Icon(e['icon'], color: e['color']),
                              child: IconButton(
                                // iconSize: 20,
                                color: e['color'],
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                icon: Icon(e['icon']),
                              ));
                        }).toList(),
                      ),
                      const Gap(25)
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 30,
                right: 30,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.greenColor,
                  ),
                  child: Transform.scale(
                    scale: 0.8,
                    child: Image.asset(Assets.jw),
                  ),
                ),
              )
            ],
          ),
          const Gap(35),
          CustomListTile(
              icon: IconlyBold.Profile,
              color: const Color(0xFFFF736C),
              title: 'Information',
              context: context),
          CustomListTile(
              icon: IconlyBold.Shield_Done,
              color: const Color(0xFF229e76),
              title: 'Security',
              context: context),
          CustomListTile(
              icon: IconlyBold.Message,
              color: const Color(0xFFe17a0a),
              title: 'Contact us',
              context: context),
          CustomListTile(
              icon: IconlyBold.Document,
              color: const Color(0xFF064c6d),
              title: 'Support',
              context: context),
          CustomListTile(
              icon: Icons.dark_mode,
              color: const Color(0xFF474747),
              title: 'Dark Mode',
              isDarkMode: true,
              context: context),
        ],
      ),
    );
  }
}