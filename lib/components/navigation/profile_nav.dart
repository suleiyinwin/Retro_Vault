import 'package:flutter/material.dart';
import 'package:retro/pages/user_management/edit_profile.dart';

import '../../pages/user_management/view_profile.dart';

class ProfileNav extends StatefulWidget {
  const ProfileNav({super.key});

  @override
  State<ProfileNav> createState() => _ProfileNavState();
}

class _ProfileNavState extends State<ProfileNav> {
  GlobalKey<NavigatorState> profileNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: profileNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if(settings.name == '/editProfile') {
              print(settings.name);
              return const EditProfile(
              );
            }
            //main page of the profile section
            return const ProfileView();
            
          },
        );
      },
    );
  }
}