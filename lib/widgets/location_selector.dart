import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationSelector extends StatelessWidget {
  final String? currentLocation;
  final Function(String) onLocationChanged;

  const LocationSelector({
    super.key,
    required this.currentLocation,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.purple.shade300),
                const SizedBox(width: 8),
                const Text(
                  'Ubicación de Venta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LocationService.predefinedLocations.map((location) {
                final isSelected = location == currentLocation;
                return FilterChip(
                  selected: isSelected,
                  label: Text(location),
                  onSelected: (_) => onLocationChanged(location),
                  selectedColor: Colors.purple.shade100,
                  checkmarkColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.purple : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
