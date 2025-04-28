import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para mantener el estado de autenticación
  static Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc.data()!);
    });
  }

  // Obtener usuario actual
  static AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return AppUser(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      businessId: 'marthas_jewelry', // Por ahora fijo
      photoUrl: user.photoURL,
      role: 'empleado',
    );
  }

  // Login con Google
  static Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      // Verificar si es el primer usuario (será admin)
      final querySnapshot = await _firestore.collection('users').get();
      final isFirstUser = querySnapshot.docs.isEmpty;

      // Verificar si el usuario ya existe
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        // Si el usuario ya existe, mantener su rol actual
        return AppUser.fromFirestore(userDoc.data()!);
      }

      // Crear o actualizar usuario en Firestore
      final appUser = AppUser(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        businessId: 'marthas_jewelry', // Por ahora fijo
        photoUrl: user.photoURL,
        role: isFirstUser ? 'admin' : 'empleado',
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(appUser.toFirestore());

      return appUser;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener todos los usuarios registrados
  static Future<List<AppUser>> getAllUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => AppUser.fromFirestore(doc.data()))
        .toList();
  }

  // Verificar si un usuario es admin
  static Future<bool> isUserAdmin(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return false;
    return doc.data()?['role'] == 'admin';
  }

  // Actualizar rol de usuario
  static Future<void> updateUserRole(String userId, String newRole) async {
    // Verificar que no sea el último admin
    if (newRole != 'admin') {
      final admins = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      if (admins.docs.length == 1 && admins.docs.first.id == userId) {
        throw Exception('No se puede cambiar el rol del último administrador');
      }
    }

    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }
}
