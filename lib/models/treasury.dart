class TreasuryTransaction {
  final String id;
  final String type; // income, expense
  final String? category;
  final String description;
  final double amount;
  final double? balanceAfter;
  final String? referenceId;
  final String? referenceType;
  final String? createdAt;

  const TreasuryTransaction({
    required this.id,
    required this.type,
    this.category,
    required this.description,
    required this.amount,
    this.balanceAfter,
    this.referenceId,
    this.referenceType,
    this.createdAt,
  });

  factory TreasuryTransaction.fromMap(Map<String, dynamic> m) => TreasuryTransaction(
        id: m['id'] as String,
        type: m['type'] as String,
        category: m['category'] as String?,
        description: m['description'] as String,
        amount: (m['amount'] as num?)?.toDouble() ?? 0,
        balanceAfter: (m['balance_after'] as num?)?.toDouble(),
        referenceId: m['reference_id'] as String?,
        referenceType: m['reference_type'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'category': category,
        'description': description,
        'amount': amount,
        'balance_after': balanceAfter,
        'reference_id': referenceId,
        'reference_type': referenceType,
        'created_at': createdAt,
      };

  bool get isIncome => type == 'income';
}
