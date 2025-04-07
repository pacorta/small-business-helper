import 'package:flutter/material.dart';

class CurrentLocationHeader extends StatelessWidget {
  final String location;

  const CurrentLocationHeader({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border(bottom: BorderSide(color: Colors.purple.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: Colors.purple.shade300, size: 20),
          const SizedBox(width: 8),
          Text(
            location,
            style: TextStyle(
              color: Colors.purple.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
