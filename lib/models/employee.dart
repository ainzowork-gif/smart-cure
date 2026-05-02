class Employee {
  final String id;
  final String name;
  final String? role;
  final String? phone;
  final String? email;
  final double salary;
  final String? joinDate;
  final String? permissions;
  final bool active;
  final String? notes;
  final String? createdAt;

  const Employee({
    required this.id,
    required this.name,
    this.role,
    this.phone,
    this.email,
    this.salary = 0,
    this.joinDate,
    this.permissions,
    this.active = true,
    this.notes,
    this.createdAt,
  });

  factory Employee.fromMap(Map<String, dynamic> m) => Employee(
        id: m['id'] as String,
        name: m['name'] as String,
        role: m['role'] as String?,
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        salary: (m['salary'] as num?)?.toDouble() ?? 0,
        joinDate: m['join_date'] as String?,
        permissions: m['permissions'] as String?,
        active: (m['active'] as int? ?? 1) == 1,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
        'email': email,
        'salary': salary,
        'join_date': joinDate,
        'permissions': permissions,
        'active': active ? 1 : 0,
        'notes': notes,
        'created_at': createdAt,
      };

  Employee copyWith({
    String? name, String? role, String? phone, String? email,
    double? salary, String? joinDate, String? permissions, bool? active, String? notes,
  }) => Employee(
    id: id,
    name: name ?? this.name,
    role: role ?? this.role,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    salary: salary ?? this.salary,
    joinDate: joinDate ?? this.joinDate,
    permissions: permissions ?? this.permissions,
    active: active ?? this.active,
    notes: notes ?? this.notes,
    createdAt: createdAt,
  );

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}
