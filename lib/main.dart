import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Prueba simple de Firebase
  try {
    // Intenta acceder a Firebase Auth
    FirebaseAuth auth = FirebaseAuth.instance;
    print('Firebase Auth inicializado correctamente');

    // Opcional: Intenta una operación anónima
    UserCredential userCredential = await auth.signInAnonymously();
    print('Login anónimo exitoso: ${userCredential.user?.uid}');
  } catch (e) {
    print('Error al probar Firebase: $e');
  }

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
