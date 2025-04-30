import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  //El controlador del codigo de invitacion se elimina cuando se cierra la pantalla. Pantalla entera o el dialogo? Respuesta: Pantalla entera
  //En el metodo _verifyInvitationCode se elimina el controlador del codigo de invitacion y se cierra el dialogo
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showJoinBusinessDialog() {
    showDialog(
      context: context,
      //barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Unirse a un Negocio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el código de invitación que recibiste:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'Código de invitación',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.pop(context);
                _codeController.clear();
              }
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _verifyInvitationCode,
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBusiness() async {
    // Solo crear el usuario en Firestore cuando crea un negocio
    final user = AuthService.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'email': user.email,
        'name': user.name,
        'role': 'admin',
        'businessId': 'nuevo_negocio_id',
        // ... otros campos
      });
    }
  }

  Future<void> _verifyInvitationCode() async {
    final code = _codeController.text.trim();

    // Cierra el diálogo SIEMPRE al presionar "Verificar"
    if (mounted) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (code.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un código')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool _navigated = false;

    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) throw Exception('No hay usuario autenticado');

      // Buscar la invitación en Firestore
      final QuerySnapshot invitationQuery = await FirebaseFirestore.instance
          .collection('invitations')
          .where('code', isEqualTo: code)
          .where('status', isEqualTo: 'pending')
          .where('email', isEqualTo: currentUser.email.toLowerCase())
          .get();

      if (invitationQuery.docs.isEmpty) {
        throw Exception(
            'Código de invitación inválido o no corresponde a tu email');
      }

      final invitationDoc = invitationQuery.docs.first;
      final invitationData = invitationDoc.data() as Map<String, dynamic>;

      // Verificar si la invitación ha expirado
      final expiresAt = (invitationData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('El código de invitación ha expirado');
      }

      // Actualizar el usuario con el businessId de la invitación
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .set({
        'email': currentUser.email,
        'name': currentUser.name,
        'role': 'empleado',
        'businessId': invitationData['businessId'],
        // ... otros campos
      });

      // Marcar la invitación como usada
      await invitationDoc.reference.update({
        'status': 'used',
        'usedBy': currentUser.id,
        'usedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
        _navigated = true;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted && !_navigated) {
        setState(() => _isLoading = false);
        _codeController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.store_rounded,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '¿Qué deseas hacer?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Esta función estará disponible próximamente'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Text(
                      'Registrar un Nuevo Negocio',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showJoinBusinessDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Text(
                      'Unirme a un Negocio Existente',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: () async {
                      final currentUser = AuthService.currentUser;
                      if (currentUser != null) {
                        // Eliminar el documento del usuario
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.id)
                            .delete();
                      }
                      // Cerrar sesión
                      await AuthService.signOut();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
