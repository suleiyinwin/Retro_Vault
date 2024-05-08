import 'package:flutter/material.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/components/navigation/profile_nav.dart';
import 'package:retro/pages/capsule_management/capsule_list.dart';
import 'package:retro/pages/notification/noti_list.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  // final screens = [
  //   const HomeScreen(),
  //   const ProfileView(),
  //   const NotiPage(),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: screens[_selectedIndex],
      bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 0,bottom: 0),
          decoration: const BoxDecoration(
            color: AppColors.backgroundColor,
            border: Border(
              top: BorderSide(
                color: AppColors.primaryColor,
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            surfaceTintColor: AppColors.backgroundColor,
            indicatorColor: AppColors.systemGreay06Light,
            backgroundColor: AppColors.backgroundColor,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primaryColor), 
                label: "Home",),
                // selectedLabelStyle: TextStyle(color: AppColors.primaryColor),),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(Icons.account_circle, color: AppColors.primaryColor), 
                label: 'Profile'),
              NavigationDestination(
                icon: Icon(Icons.notifications_none),
                selectedIcon: Icon(Icons.notifications, color: AppColors.primaryColor), 
                label: 'Notifications'),
            ],
          ),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children:  const <Widget>[
            //Pages from Navigation
            HomeScreen(),
            ProfileNav(),
            NotiPage(),
          ],
        ),),
    );
  }
}

