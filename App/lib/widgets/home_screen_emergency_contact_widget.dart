import 'package:flutter/material.dart';

class EmergencyContactsWidget extends StatelessWidget {
  const EmergencyContactsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data for emergency contacts (name, phone, icon, color)
    final List<Map<String, dynamic>> contacts = [
      {
        'name': 'Aryan',
        'phone': '7738967429',
        'icon': Icons.person,
        'color': Colors.blue,
      },
      {
        'name': 'Shreya',
        'phone': '9082532164',
        'icon': Icons.person,
        'color': Colors.red,
      },
      {
        'name': 'Nithish',
        'phone': '9626231079',
        'icon': Icons.person,
        'color': Colors.green,
      },
      {
        'name': 'Maheep',
        'phone': '930777556',
        'icon': Icons.person,
        'color': Colors.orange,
      },
      {
        'name': 'Parth',
        'phone': '567-890-1234',
        'icon': Icons.person,
        'color': Colors.purple,
      },
    ];

    return Column(
      children: [
        // Section Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black12,
                      offset: Offset(0.5, 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal List of Contacts
        Container(
          height: 160, // Fixed height for the contacts
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            scrollDirection: Axis.horizontal,
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final Color color = contact['color'];
              return GestureDetector(
                onTap: () => _showContactDetails(context, contact),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          contact['icon'],
                          color: color,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        contact['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Show an AlertDialog with expanded contact info (name, phone).
  void _showContactDetails(BuildContext context, Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with bigger size
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: contact['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    contact['icon'],
                    color: contact['color'],
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  contact['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contact['phone'],
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}