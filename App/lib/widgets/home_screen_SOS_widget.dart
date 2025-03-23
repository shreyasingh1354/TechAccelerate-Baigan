import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baigan/controller/navbar_controller.dart';
import 'package:baigan/screens/home_screen.dart';
import 'package:baigan/screens/profile_screen.dart';
import 'package:baigan/theme/app_colors.dart';

class SosButton extends StatelessWidget {
  const SosButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        clipBehavior: Clip.antiAlias,
        style: ElevatedButton.styleFrom(
          overlayColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.4),
          fixedSize: const Size(100, 100),
          shape: const CircleBorder(),
          elevation: 18,
          shadowColor: Colors.red,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: const Text(
          'SOS',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}