import 'package:flutter/material.dart';
import '../../components/colors.dart';
import 'package:retro/pages/capsule_management/create_capsule.dart';

class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primaryColor,
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateCapsule()),
            );
          },
          child: const IconTheme(
            data: IconThemeData(color: AppColors.backgroundColor, size: 40),
            child: Icon(Icons.add),
          )),
    );
  }
}
