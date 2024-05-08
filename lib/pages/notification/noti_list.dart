import 'package:flutter/material.dart';

class NotiPage extends StatelessWidget {
  const NotiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'), 
      ),
      body: const Center(
        child: Text('Notification Page'),
      ),
    );
  }
}