import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late Future<List<AppUser>> _usersFuture;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersFuture = AuthService.getAllUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(AppUser user, String newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'role': newRole});
      setState(() {
        _usersFuture = AuthService.getAllUsers();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar rol: $e')),
      );
    }
  }

  // Método para mostrar el diálogo de invitación
  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitar Empleado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el Gmail del empleado:'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'ejemplo@gmail.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_emailController.text.isEmpty ||
                  !_emailController.text.endsWith('@gmail.com')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor ingresa un Gmail válido')),
                );
                return;
              }
              _showConfirmationDialog(context, _emailController.text);
            },
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmación
  void _showConfirmationDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Invitación'),
        content:
            Text('¿Estás seguro que deseas invitar a $email como empleado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _sendInvitation(email);
              Navigator.of(context).pop(); // Cierra el diálogo de confirmación
              Navigator.of(context).pop(); // Cierra el diálogo de invitación
              _emailController.clear();
            },
            child: const Text('Enviar Invitación'),
          ),
        ],
      ),
    );
  }

  // Método para enviar la invitación
  Future<void> _sendInvitation(String email) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) throw Exception('No hay usuario autenticado');

      final code = generateInvitationCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 15));
      //El codigo deja de funcionar despues de 15 minutos, pero no se borra de firebase.
      //Para esto es necesario usar una Cloud Function programada para borrar los codigos expirados.

      await FirebaseFirestore.instance.collection('invitations').add({
        'email': email.toLowerCase(),
        'businessId': currentUser.businessId,
        'status': 'pending',
        'createdAt': DateTime.now(),
        'createdBy': currentUser.id,
        'code': code,
        'expiresAt': expiresAt,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitación enviada. Código: $code'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error al enviar invitación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la invitación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //Considerar mover a un archivo de utilidades. Seria un codigo mas limpio y facil de mantener
  String generateInvitationCode({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Sin 0, O, 1, I
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // Widget para mostrar las invitaciones pendientes
  Widget _buildPendingInvitations() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('invitations')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si hay error, mostrar mensaje más descriptivo
        if (snapshot.hasError) {
          print('Error en invitaciones: ${snapshot.error}'); // Para debug
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'No se pudieron cargar las invitaciones\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        final invitations = snapshot.data?.docs ?? [];

        if (invitations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay invitaciones pendientes',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invitations.length,
          itemBuilder: (context, index) {
            final invitation = invitations[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.mail_outline),
                ),
                title: Text(invitation['email'] ?? 'Email no disponible'),
                subtitle: Text(
                  'Invitado el: ${_formatDate(invitation['createdAt'] as Timestamp)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _showCancelInvitationDialog(invitation.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Nuevo método para confirmar cancelación
  void _showCancelInvitationDialog(String invitationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Invitación'),
        content:
            const Text('¿Estás seguro que deseas cancelar esta invitación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelInvitation(invitationId);
            },
            child: const Text('Sí, Cancelar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _cancelInvitation(String invitationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(invitationId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitación cancelada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar la invitación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthService.userStream,
      builder: (context, snapshot) {
        final currentUser = snapshot.data;

        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (currentUser.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Empleados')),
            body: const Center(
              child: Text(
                  'Acceso denegado: solo el admin puede ver esta pantalla.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Empleados'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _showInviteDialog(context),
                tooltip: 'Invitar Empleado',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Empleados Activos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<List<AppUser>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final users = snapshot.data ?? [];
                    if (users.isEmpty) {
                      return const Center(
                          child: Text('No hay empleados registrados.'));
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: user.photoUrl != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoUrl!))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                              user.name.isNotEmpty ? user.name : 'Sin nombre'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              Text('Rol: ${user.role}'),
                            ],
                          ),
                          trailing: currentUser.role == 'admin' &&
                                  user.id != currentUser.id
                              ? PopupMenuButton<String>(
                                  onSelected: (newRole) =>
                                      _updateUserRole(user, newRole),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'admin',
                                      child: Text('Admin'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'empleado',
                                      child: Text('Empleado'),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Invitaciones Pendientes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPendingInvitations(),
              ],
            ),
          ),
        );
      },
    );
  }
}
