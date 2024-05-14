import 'package:flutter/cupertino.dart';

class CapsuleImageWidget extends StatelessWidget {
  final String imageUrl;

  const CapsuleImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return imageUrl == ''
        ? Image.asset('image/defaultcapsult.png',
            fit: BoxFit.cover, height: double.infinity)
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: double.infinity,
          );
  }
}
