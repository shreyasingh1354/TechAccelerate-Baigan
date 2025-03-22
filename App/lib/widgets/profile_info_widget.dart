import 'package:flutter/material.dart';

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({
    Key? key,
    required this.name,
    required this.imgPath,
  }) : super(key: key);

  final String name;
  final String imgPath; // Asset image path

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          // Use the imgPath passed in through the constructor
          foregroundImage: AssetImage(imgPath),
          // The child is displayed if the foregroundImage fails to load
          child: const Text('data'),
        ),
        const SizedBox(height: 10),
        Text(name),
      ],
    );
  }
}
