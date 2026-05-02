class Supplier {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final double balance;
  final String? notes;
  final String? createdAt;

  const Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.balance = 0,
    this.notes,
    this.createdAt,
  });

  factory Supplier.fromMap(Map<String, dynamic> m) => Supplier(
        id: m['id'] as String,
        name: m['name'] as String,
        contactPerson: m['contact_person'] as String?,
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
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
        'balance': balance,
        'notes': notes,
        'created_at': createdAt,
      };

  Supplier copyWith({
    String? name, String? contactPerson, String? phone, String? email,
    String? address, double? balance, String? notes,
  }) =>
      Supplier(
        id: id,
        name: name ?? this.name,
        contactPerson: contactPerson ?? this.contactPerson,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        balance: balance ?? this.balance,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
