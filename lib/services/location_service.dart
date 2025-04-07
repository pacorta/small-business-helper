import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationKey = 'current_location';

  static const List<String> predefinedLocations = [
    'Farmers Market',
    'Tienda',
    'Evento Especial',
    'Pop-up Shop',
    'Online',
  ];

  static Future<String?> getCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_locationKey);
  }

  static Future<void> setCurrentLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, location);
  }
}
