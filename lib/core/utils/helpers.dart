import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _dateFormatter = DateFormat('dd/MM/yy');
final _fullDate = DateFormat('dd MMM yyyy');
final _dateTimeFormatter = DateFormat('dd MMM yyyy HH:mm');

String formatCurrency(double value) => _currency.format(value);

String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '—';
  try {
    final d = DateTime.parse(dateStr);
    return _dateFormatter.format(d);
  } catch (_) {
    return dateStr;
  }
}

String formatFullDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '—';
  try {
    final d = DateTime.parse(dateStr);
    return _fullDate.format(d);
  } catch (_) {
    return dateStr;
  }
}

String formatDateTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '—';
  try {
    final d = DateTime.parse(dateStr);
    return _dateTimeFormatter.format(d);
  } catch (_) {
    return dateStr;
  }
}

int daysUntilExpiry(String? expiryDate) {
  if (expiryDate == null || expiryDate.isEmpty) return 9999;
  try {
    final exp = DateTime.parse(expiryDate);
    return exp.difference(DateTime.now()).inDays;
  } catch (_) {
    return 9999;
  }
}

bool isExpired(String? expiryDate) => daysUntilExpiry(expiryDate) < 0;

bool isNearExpiry(String? expiryDate, {int days = 30}) {
  final d = daysUntilExpiry(expiryDate);
  return d >= 0 && d <= days;
}

String nowIso() => DateTime.now().toIso8601String();

String generateId() => _uuid.v4().replaceAll('-', '');

String generateInvoiceNo(int count) => 'INV-${(2842 + count).toString().padLeft(4, '0')}';
String generatePoNo(int count) => 'PO-${(2049 + count).toString().padLeft(4, '0')}';
