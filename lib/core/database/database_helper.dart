import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'smart_cure', 'smart_cure.db');
    await Directory(dirname(path)).create(recursive: true);
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        scientific_name TEXT,
        category TEXT,
        barcode TEXT,
        batch_no TEXT,
        expiry_date TEXT,
        purchase_price REAL,
        sale_price REAL,
        quantity INTEGER DEFAULT 0,
        min_quantity INTEGER DEFAULT 10,
        unit TEXT DEFAULT 'unit',
        supplier_id TEXT,
        active_ingredient TEXT,
        alternatives TEXT,
        location TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact_person TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT,
        phone TEXT,
        email TEXT,
        salary REAL DEFAULT 0,
        join_date TEXT,
        permissions TEXT,
        active INTEGER DEFAULT 1,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        invoice_no TEXT NOT NULL,
        customer_id TEXT,
        customer_name TEXT,
        total REAL DEFAULT 0,
        discount REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        paid REAL DEFAULT 0,
        status TEXT DEFAULT 'paid',
        payment_method TEXT DEFAULT 'cash',
        notes TEXT,
        employee_id TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        medicine_id TEXT NOT NULL,
        medicine_name TEXT,
        batch_no TEXT,
        expiry_date TEXT,
        quantity INTEGER DEFAULT 1,
        unit_price REAL,
        discount REAL DEFAULT 0,
        total REAL,
        FOREIGN KEY (sale_id) REFERENCES sales(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        po_no TEXT NOT NULL,
        supplier_id TEXT,
        supplier_name TEXT,
        total REAL DEFAULT 0,
        paid REAL DEFAULT 0,
        status TEXT DEFAULT 'received',
        due_date TEXT,
        notes TEXT,
        employee_id TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_items (
        id TEXT PRIMARY KEY,
        purchase_id TEXT NOT NULL,
        medicine_id TEXT NOT NULL,
        medicine_name TEXT,
        batch_no TEXT,
        expiry_date TEXT,
        quantity INTEGER DEFAULT 1,
        unit_cost REAL,
        total REAL,
        FOREIGN KEY (purchase_id) REFERENCES purchases(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE treasury (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        balance_after REAL,
        reference_id TEXT,
        reference_type TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Seed default settings
    await db.insert('settings', {'key': 'pharmacy_name', 'value': 'Al-Shifa Pharmacy'});
    await db.insert('settings', {'key': 'license_until', 'value': '2026-12-31'});
    await db.insert('settings', {'key': 'currency', 'value': '\$'});
    await db.insert('settings', {'key': 'tax_rate', 'value': '0'});
    await db.insert('settings', {'key': 'low_stock_threshold', 'value': '10'});
    await db.insert('settings', {'key': 'expiry_warning_days', 'value': '30'});

    // Seed sample data
    await _seedSampleData(db);
  }

  Future<void> _seedSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final medicines = [
      {'id': 'm001', 'name': 'Amoxicillin 500mg', 'scientific_name': 'Amoxicillin', 'category': 'Antibiotic', 'barcode': '6001001', 'batch_no': 'B0042', 'expiry_date': '2026-04-15', 'purchase_price': 5.0, 'sale_price': 8.50, 'quantity': 80, 'min_quantity': 50, 'active_ingredient': 'Amoxicillin', 'created_at': now, 'updated_at': now},
      {'id': 'm002', 'name': 'Paracetamol 1g', 'scientific_name': 'Paracetamol', 'category': 'Analgesic', 'barcode': '6001002', 'batch_no': 'C0018', 'expiry_date': '2026-05-05', 'purchase_price': 1.5, 'sale_price': 3.20, 'quantity': 220, 'min_quantity': 100, 'active_ingredient': 'Acetaminophen', 'created_at': now, 'updated_at': now},
      {'id': 'm003', 'name': 'Metformin 850mg', 'scientific_name': 'Metformin', 'category': 'Antidiabetic', 'barcode': '6001003', 'batch_no': 'A0077', 'expiry_date': '2026-09-12', 'purchase_price': 3.0, 'sale_price': 5.80, 'quantity': 14, 'min_quantity': 50, 'active_ingredient': 'Metformin HCl', 'created_at': now, 'updated_at': now},
      {'id': 'm004', 'name': 'Omeprazole 20mg', 'scientific_name': 'Omeprazole', 'category': 'Antacid', 'barcode': '6001004', 'batch_no': 'E0034', 'expiry_date': '2026-11-03', 'purchase_price': 4.0, 'sale_price': 7.10, 'quantity': 22, 'min_quantity': 40, 'active_ingredient': 'Omeprazole', 'created_at': now, 'updated_at': now},
      {'id': 'm005', 'name': 'Atorvastatin 10mg', 'scientific_name': 'Atorvastatin', 'category': 'Cholesterol', 'barcode': '6001005', 'batch_no': 'D0091', 'expiry_date': '2026-05-28', 'purchase_price': 7.0, 'sale_price': 12.40, 'quantity': 60, 'min_quantity': 30, 'active_ingredient': 'Atorvastatin Calcium', 'created_at': now, 'updated_at': now},
      {'id': 'm006', 'name': 'Ibuprofen 400mg', 'scientific_name': 'Ibuprofen', 'category': 'Anti-inflammatory', 'barcode': '6001006', 'batch_no': 'F0012', 'expiry_date': '2027-02-08', 'purchase_price': 2.5, 'sale_price': 4.60, 'quantity': 340, 'min_quantity': 50, 'active_ingredient': 'Ibuprofen', 'created_at': now, 'updated_at': now},
      {'id': 'm007', 'name': 'Vitamin D3 1000IU', 'scientific_name': 'Cholecalciferol', 'category': 'Supplement', 'barcode': '6001007', 'batch_no': 'G0055', 'expiry_date': '2027-06-15', 'purchase_price': 5.5, 'sale_price': 9.90, 'quantity': 18, 'min_quantity': 30, 'active_ingredient': 'Cholecalciferol', 'created_at': now, 'updated_at': now},
      {'id': 'm008', 'name': 'Cetirizine 10mg', 'scientific_name': 'Cetirizine', 'category': 'Antihistamine', 'barcode': '6001008', 'batch_no': 'H0029', 'expiry_date': '2026-12-20', 'purchase_price': 1.5, 'sale_price': 2.75, 'quantity': 500, 'min_quantity': 50, 'active_ingredient': 'Cetirizine HCl', 'created_at': now, 'updated_at': now},
      {'id': 'm009', 'name': 'Lisinopril 10mg', 'scientific_name': 'Lisinopril', 'category': 'Antihypertensive', 'barcode': '6001009', 'batch_no': 'I0011', 'expiry_date': '2027-01-15', 'purchase_price': 6.0, 'sale_price': 11.00, 'quantity': 120, 'min_quantity': 30, 'active_ingredient': 'Lisinopril', 'created_at': now, 'updated_at': now},
      {'id': 'm010', 'name': 'Azithromycin 500mg', 'scientific_name': 'Azithromycin', 'category': 'Antibiotic', 'barcode': '6001010', 'batch_no': 'J0007', 'expiry_date': '2026-08-10', 'purchase_price': 8.0, 'sale_price': 15.00, 'quantity': 75, 'min_quantity': 20, 'active_ingredient': 'Azithromycin', 'created_at': now, 'updated_at': now},
    ];
    for (final m in medicines) {
      await db.insert('medicines', m);
    }

    final customers = [
      {'id': 'c001', 'name': 'Sarah K.', 'phone': '+1 555-0101', 'email': 'sarah.k@email.com', 'balance': 0.0, 'created_at': now},
      {'id': 'c002', 'name': 'James T.', 'phone': '+1 555-0102', 'email': 'james.t@email.com', 'balance': 0.0, 'created_at': now},
      {'id': 'c003', 'name': 'Hana R.', 'phone': '+1 555-0103', 'email': 'hana.r@email.com', 'balance': 89.75, 'created_at': now},
      {'id': 'c004', 'name': 'Omar B.', 'phone': '+1 555-0104', 'email': 'omar.b@email.com', 'balance': 0.0, 'created_at': now},
      {'id': 'c005', 'name': 'Linda P.', 'phone': '+1 555-0105', 'email': 'linda.p@email.com', 'balance': 0.0, 'created_at': now},
      {'id': 'c006', 'name': 'Ali M.', 'phone': '+1 555-0106', 'email': 'ali.m@email.com', 'balance': 0.0, 'created_at': now},
    ];
    for (final c in customers) {
      await db.insert('customers', c);
    }

    final suppliers = [
      {'id': 's001', 'name': 'PharmaTrade Co.', 'contact_person': 'David Lee', 'phone': '+1 555-2001', 'email': 'david@pharmatrade.com', 'balance': 2500.0, 'created_at': now},
      {'id': 's002', 'name': 'MediSupply Ltd.', 'contact_person': 'Emma Wilson', 'phone': '+1 555-2002', 'email': 'emma@medisupply.com', 'balance': 0.0, 'created_at': now},
      {'id': 's003', 'name': 'Global Pharma', 'contact_person': 'Mike Chen', 'phone': '+1 555-2003', 'email': 'mike@globalpharma.com', 'balance': 1200.0, 'created_at': now},
    ];
    for (final s in suppliers) {
      await db.insert('suppliers', s);
    }

    final employees = [
      {'id': 'e001', 'name': 'Ahmed M.', 'role': 'Pharmacist', 'phone': '+1 555-3001', 'salary': 4500.0, 'join_date': '2022-01-15', 'permissions': 'all', 'active': 1, 'created_at': now},
      {'id': 'e002', 'name': 'Sara J.', 'role': 'Cashier', 'phone': '+1 555-3002', 'salary': 2800.0, 'join_date': '2023-03-10', 'permissions': 'sales,customers', 'active': 1, 'created_at': now},
      {'id': 'e003', 'name': 'Tom R.', 'role': 'Stock Manager', 'phone': '+1 555-3003', 'salary': 3200.0, 'join_date': '2022-07-20', 'permissions': 'inventory,purchases,suppliers', 'active': 1, 'created_at': now},
    ];
    for (final e in employees) {
      await db.insert('employees', e);
    }

    final sales = [
      {'id': 'inv001', 'invoice_no': 'INV-2841', 'customer_id': 'c001', 'customer_name': 'Sarah K.', 'total': 64.20, 'discount': 0.0, 'tax': 0.0, 'paid': 64.20, 'status': 'paid', 'payment_method': 'cash', 'employee_id': 'e001', 'created_at': now},
      {'id': 'inv002', 'invoice_no': 'INV-2840', 'customer_id': 'c002', 'customer_name': 'James T.', 'total': 112.50, 'discount': 0.0, 'tax': 0.0, 'paid': 112.50, 'status': 'paid', 'payment_method': 'card', 'employee_id': 'e001', 'created_at': now},
      {'id': 'inv003', 'invoice_no': 'INV-2839', 'customer_name': 'Walk-in', 'total': 28.00, 'discount': 0.0, 'tax': 0.0, 'paid': 28.00, 'status': 'paid', 'payment_method': 'cash', 'employee_id': 'e002', 'created_at': now},
      {'id': 'inv004', 'invoice_no': 'INV-2838', 'customer_id': 'c003', 'customer_name': 'Hana R.', 'total': 89.75, 'discount': 0.0, 'tax': 0.0, 'paid': 0.0, 'status': 'pending', 'payment_method': 'credit', 'employee_id': 'e002', 'created_at': now},
      {'id': 'inv005', 'invoice_no': 'INV-2837', 'customer_id': 'c004', 'customer_name': 'Omar B.', 'total': 210.00, 'discount': 10.0, 'tax': 0.0, 'paid': 210.00, 'status': 'paid', 'payment_method': 'cash', 'employee_id': 'e001', 'created_at': now},
    ];
    for (final s in sales) {
      await db.insert('sales', s);
    }

    final purchases = [
      {'id': 'po001', 'po_no': 'PO-2048', 'supplier_id': 's001', 'supplier_name': 'PharmaTrade Co.', 'total': 2500.0, 'paid': 0.0, 'status': 'pending', 'due_date': '2026-05-02', 'employee_id': 'e003', 'created_at': now},
      {'id': 'po002', 'po_no': 'PO-2047', 'supplier_id': 's002', 'supplier_name': 'MediSupply Ltd.', 'total': 1800.0, 'paid': 1800.0, 'status': 'received', 'due_date': '2026-04-20', 'employee_id': 'e003', 'created_at': now},
    ];
    for (final p in purchases) {
      await db.insert('purchases', p);
    }

    final treasury = [
      {'id': 't001', 'type': 'income', 'category': 'Sales', 'description': 'Daily sales INV-2841', 'amount': 64.20, 'balance_after': 18350.0, 'reference_id': 'inv001', 'reference_type': 'sale', 'created_at': now},
      {'id': 't002', 'type': 'income', 'category': 'Sales', 'description': 'Daily sales INV-2840', 'amount': 112.50, 'balance_after': 18220.0, 'reference_id': 'inv002', 'reference_type': 'sale', 'created_at': now},
      {'id': 't003', 'type': 'expense', 'category': 'Salaries', 'description': 'April salaries paid', 'amount': 10500.0, 'balance_after': 18107.5, 'reference_type': 'expense', 'created_at': now},
    ];
    for (final t in treasury) {
      await db.insert('treasury', t);
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> args) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: args);
  }

  Future<int> delete(String table, String where, List<dynamic> args) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: args);
  }

  Future<List<Map<String, dynamic>>> query(String table, {
    String? where, List<dynamic>? whereArgs, String? orderBy, int? limit,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  Future<String?> getSetting(String key) async {
    final rows = await query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
