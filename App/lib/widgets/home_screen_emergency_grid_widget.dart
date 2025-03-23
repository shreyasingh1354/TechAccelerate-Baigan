import 'package:flutter/material.dart';
import 'package:baigan/theme/app_colors.dart';


class EmergencyServicesGrid extends StatelessWidget {
  const EmergencyServicesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data for emergency services
    final List<String> names = ['Police', 'Hospital', 'Fire', 'Ambulance', 'Emergency'];
    final List<IconData> icons = [
      Icons.local_police,
      Icons.local_hospital,
      Icons.local_fire_department,
      Icons.emergency,
      Icons.warning_amber,
    ];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];

    return Column(
      children: [
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
                  Icons.emergency,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emergency Services',
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
        Container(
          height: 300, // Fixed height for the grid
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
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: names.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors[index].withOpacity(0.3)),
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
                            color: colors[index].withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icons[index],
                        color: colors[index],
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      names[index],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}