import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MarthasArtApp());
}

class MarthasArtApp extends StatelessWidget {
  const MarthasArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Martha's Art Jewelry",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        // Aumentamos el tamaño predeterminado de los botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20.0),
            textStyle: const TextStyle(fontSize: 24),
            minimumSize: const Size(double.infinity, 60),
          ),
        ),
        // Texto más grande por defecto
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 28),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
