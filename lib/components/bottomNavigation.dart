import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/pages/capsule_management/capsule_list.dart';
import 'package:retro/pages/notification/noti_list.dart';
import 'package:retro/pages/user_management/view_profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  final screens = [
    const HomeScreen(),
    const ProfileView(),
    const NotiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        surfaceTintColor: AppColors.backgroundColor,
        indicatorColor: AppColors.backgroundColor,
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
    );
  }
}

