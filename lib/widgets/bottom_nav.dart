import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/views/home.dart';
import 'package:tripo/views/profile.dart';
import 'package:tripo/views/stats.dart';
import 'package:tripo/views/receipt_management.dart';

/// This is the stateful widget that the main application instantiates.
class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  _BottomNavState();

  List<Widget> _widgetOptions = [];
  User? user = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      _widgetOptions = <Widget>[
        const Home(),
        ReceiptManagement(user: user!),
        Stats(user: user!),
        const Profile(),
      ];
    }

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Repository.textColor(context),
        borderRadius: 50,
        width: MediaQuery.of(context).size.width * 0.9,
        selectedBackgroundColor: Colors.transparent,
        selectedItemColor: Repository.bg2Color(context),
        unselectedItemColor: Colors.grey.withOpacity(0.7),
        onTap: (int val) {
          _onItemTapped(val);
        },
        currentIndex: _selectedIndex,
        items: [
          FloatingNavbarItem(icon: IconlyBold.home),
          FloatingNavbarItem(icon: IconlyBold.wallet),
          FloatingNavbarItem(icon: IconlyBold.chart),
          FloatingNavbarItem(icon: IconlyBold.profile),
        ],
      ),
      // BottomNavigationBar(
      //   backgroundColor: Repository.navbarColor(context),
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   selectedLabelStyle: TextStyle(fontSize: 25, color: Styles.primaryColor),
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Repository.selectedItemColor(context),
      //   unselectedItemColor: Colors.grey.withOpacity(0.7),
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(IconlyBold.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(IconlyBold.wallet),
      //       label: 'Wallet',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(IconlyBold.chart),
      //       label: 'Stats',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(IconlyBold.profile),
      //       label: 'Profile',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}
