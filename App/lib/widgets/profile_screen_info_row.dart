// lib/widgets/info_row.dart
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isImportant;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isImportant = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isImportant
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isImportant ? Colors.red : Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isImportant ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}