import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
//import 'package:firebase_auth/firebase_auth.dart';  //para probar firebase
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'models/user.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Prueba simple de Firebase
  /*
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
*/
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      routes: {
        '/': (context) => const AuthWrapper(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No autenticado -> Login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        // Usuario nuevo o sin configurar -> Role Selection
        if (user.needsOnboarding) {
          return const RoleSelectionScreen();
        }

        // Usuario configurado -> Home
        return const HomeScreen();
      },
    );
  }
}
