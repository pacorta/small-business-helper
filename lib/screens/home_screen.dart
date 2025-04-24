import 'package:flutter/material.dart';
import 'new_sale/select_items_screen.dart';
import 'previous_sales_screen.dart';
import '../services/location_service.dart';
import '../widgets/location_selector.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? currentLocation;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    setState(() {
      currentLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Martha's Art Jewelry"),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LocationSelector(
              currentLocation: currentLocation,
              onLocationChanged: (location) async {
                await LocationService.setCurrentLocation(location);
                setState(() {
                  currentLocation = location;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: currentLocation != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectItemsScreen(
                              currentLocation: currentLocation!,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Agregar Venta'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreviousSalesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Ventas Anteriores'),
              ),
            ),
            const Spacer(),
            if (currentLocation != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.purple.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ubicación actual: $currentLocation',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
