import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationSelector extends StatefulWidget {
  final String? currentLocation;
  final Function(String) onLocationChanged;

  const LocationSelector({
    super.key,
    required this.currentLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  List<String> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await LocationService.getAllLocations();
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      // Manejar el error apropiadamente
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _locations.map((location) {
                  final isSelected = location == widget.currentLocation;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(location),
                    onSelected: (_) => widget.onLocationChanged(location),
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
