import 'package:flutter/material.dart';

class ContactCardWidget extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String imagePath;

  const ContactCardWidget({
    Key? key,
    required this.name,
    required this.phoneNumber,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          foregroundImage: AssetImage(imagePath),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          phoneNumber,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Handle more actions (e.g., show a popup menu)
          },
        ),
      ),
    );
  }
}
