import 'package:flutter/material.dart';
import 'package:baigan/theme/app_colors.dart';
import 'package:baigan/widgets/profile_info_widget.dart';

class EmergencyContactsWidget extends StatelessWidget {
  const EmergencyContactsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black26,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              ProfileInfoWidget(name: 'Aryan', imgPath: 'assets/images/profile2.jpg'),
              SizedBox(width: 10),
              ProfileInfoWidget(name: 'Shreya', imgPath: 'assets/images/profile1.jpg'),
              SizedBox(width: 10),
              ProfileInfoWidget(name: 'Nithish', imgPath: 'assets/images/profile3.jpg'),
              SizedBox(width: 10),
              ProfileInfoWidget(name: 'Maheep', imgPath: 'assets/images/profile4.jpg'),
              SizedBox(width: 10),
              ProfileInfoWidget(name: 'Parth', imgPath: 'assets/images/profile5.jpg'),
            ],
          ),
        ),
      ],
    );
  }
}