import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late Future<List<AppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AuthService.getAllUsers();
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
          ),
          body: FutureBuilder<List<AppUser>>(
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
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: user.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl!))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title:
                        Text(user.name.isNotEmpty ? user.name : 'Sin nombre'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text('Rol: ${user.role}'),
                      ],
                    ),
                    trailing:
                        currentUser.role == 'admin' && user.id != currentUser.id
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
        );
      },
    );
  }
}
