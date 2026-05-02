class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double balance;
  final String? notes;
  final String? createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.balance = 0,
    this.notes,
    this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> m) => Customer(
        id: m['id'] as String,
        name: m['name'] as String,
        phone: m['phone'] as String?,
        email: m['email'] as String?,
        address: m['address'] as String?,
        balance: (m['balance'] as num?)?.toDouble() ?? 0,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'balance': balance,
        'notes': notes,
        'created_at': createdAt,
      };

  Customer copyWith({String? name, String? phone, String? email, String? address, double? balance, String? notes}) =>
      Customer(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        balance: balance ?? this.balance,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
