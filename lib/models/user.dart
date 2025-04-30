class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String businessId; // Por ahora será fijo, pero preparado para futuro
  final String role;

  bool get needsOnboarding => businessId.isEmpty || role.isEmpty;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.businessId,
    required this.role,
    this.photoUrl,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      businessId: data['businessId'] ?? 'marthas_jewelry', // ID fijo por ahora
      role: data['role'] ?? 'empleado',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'businessId': businessId,
      'role': role,
      'photoUrl': photoUrl,
    };
  }
}
