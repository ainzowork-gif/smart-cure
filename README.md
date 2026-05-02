<div align="center">

# 💊 Smart Cure
### Pharmacy Management System

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local%20DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-Desktop-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge)

**A complete pharmacy management desktop app — fast, professional, works fully offline.**

[Features](#-features) · [Getting Started](#-getting-started) · [Architecture](#%EF%B8%8F-architecture) · [Database](#%EF%B8%8F-database-schema) · [Design System](#-design-system)

</div>

---

## ✨ Features

| Module | Description |
|--------|-------------|
| 📦 **Inventory** | Full medicine CRUD — search, filter by status & category, visual stock bar, expiry date tracking |
| 🧾 **Sales (POS)** | Invoice creation with autocomplete search, per-item discount, multiple payment methods, automatic stock deduction |
| 🛒 **Purchases** | Purchase orders from suppliers, receive stock, automatic inventory update on receipt |
| 👥 **Customers** | Customer profiles with outstanding balance tracking and purchase history |
| 🏭 **Suppliers** | Supplier management with payable balance |
| 👨‍💼 **Employees** | Staff profiles, roles, salaries, join dates, and access permissions |
| 💰 **Treasury** | Income/expense ledger auto-linked to every sale — real-time cash balance |
| 📊 **Reports** | Sales analytics, top medicines by revenue, revenue vs. cost charts |
| ⚠️ **Expiry Alerts** | Medicines expired or expiring within 30 days, color-coded by urgency |
| 🔖 **Barcode** | Barcode label generator with printer-ready PDF export |
| 🔄 **Alternatives** | Find alternative medicines by active ingredient |
| 🔐 **Permissions** | Per-employee module access control |
| ⚙️ **Settings** | Pharmacy name, currency, tax rate, low-stock threshold, backup & restore |
| 📈 **Accounting** | Profit/loss overview and balance sheet snapshot |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.0 or later
- Windows 10 / 11
- Visual Studio 2022 with the **Desktop development with C++** workload

### Run in Debug Mode

```bash
git clone https://github.com/ainzowork-gif/smart-cure.git
cd smart-cure
flutter pub get
flutter run -d windows
```

Hot-reload: press `r` · Hot-restart: `R` · Quit: `q`

### Build Release EXE

```bash
flutter build windows --release
# Output: build\windows\x64\runner\Release\smart_cure.exe
```

### Reset the Database

Delete the local SQLite file to start fresh with sample seed data:

```
%USERPROFILE%\Documents\smart_cure\smart_cure.db
```

---

## 🏗️ Project Structure

```
smart_cure/
├── lib/
│   ├── main.dart                    # Entry: sqfliteFfiInit() + ProviderScope
│   ├── app.dart                     # AppShell: Sidebar | content area + StatusBar
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart      # Design tokens (blue900 → gray50)
│   │   │   └── app_theme.dart       # DM Sans + DM Mono text styles
│   │   ├── database/
│   │   │   └── database_helper.dart # SQLite singleton — insert/update/delete/query
│   │   └── utils/
│   │       └── helpers.dart         # formatCurrency, formatDate, generateId (UUID v4)
│   │
│   ├── models/                      # Pure Dart — fromMap / toMap / copyWith
│   │   ├── medicine.dart
│   │   ├── sale.dart                # Sale + SaleItem
│   │   ├── purchase.dart            # Purchase + PurchaseItem
│   │   ├── customer.dart
│   │   ├── supplier.dart
│   │   ├── employee.dart
│   │   └── treasury.dart            # TreasuryTransaction
│   │
│   ├── providers/                   # Riverpod AsyncNotifier per module
│   │   ├── app_provider.dart        # AppScreen enum + activeScreenProvider + searchQueryProvider
│   │   ├── inventory_provider.dart
│   │   ├── sales_provider.dart      # createSale → invoice + treasury + stock (atomic)
│   │   ├── purchases_provider.dart
│   │   ├── customers_provider.dart
│   │   ├── suppliers_provider.dart
│   │   ├── employees_provider.dart
│   │   └── treasury_provider.dart
│   │
│   ├── screens/                     # One ConsumerWidget per module
│   │   ├── dashboard_screen.dart
│   │   ├── inventory_screen.dart
│   │   ├── sales_screen.dart
│   │   ├── purchases_screen.dart
│   │   ├── customers_screen.dart
│   │   ├── suppliers_screen.dart
│   │   ├── employees_screen.dart
│   │   ├── treasury_screen.dart
│   │   ├── reports_screen.dart
│   │   ├── expiry_alerts_screen.dart
│   │   ├── barcode_screen.dart
│   │   ├── alternatives_screen.dart
│   │   ├── accounting_screen.dart
│   │   ├── permissions_screen.dart
│   │   └── settings_screen.dart
│   │
│   └── widgets/shared/              # Design-system components
│       ├── sc_panel.dart            # Card with header + body (LayoutBuilder-aware)
│       ├── sc_button.dart           # primary / success / ghost variants
│       ├── sc_text_field.dart       # Consistent form input wrapper
│       ├── sc_badge.dart            # success / warning / danger / info status chip
│       ├── stock_bar.dart           # Visual stock level bar
│       ├── kpi_card.dart            # Dashboard KPI metric card
│       ├── topbar.dart              # Title + breadcrumb + search + notification bell
│       ├── sidebar.dart             # Fixed navigation rail
│       └── status_bar.dart          # Bottom bar with clock + DB status
│
└── windows/                         # Windows runner (CMake)
```

---

## ⚙️ Architecture

### State Management — Riverpod

Every data module follows the same pattern:

```dart
final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, List<Medicine>>(InventoryNotifier.new);

class InventoryNotifier extends AsyncNotifier<List<Medicine>> {
  Future<List<Medicine>> build() => _load();       // runs automatically on first watch
  Future<void> add(Medicine m)   async { ... await refresh(); }
  Future<void> save(Medicine m)  async { ... await refresh(); } // NOTE: "save" not "update"
  Future<void> delete(String id) async { ... await refresh(); }
}
```

> **Important:** All CRUD update methods are named `save()`, not `update()` — Riverpod's `AsyncNotifier` base class already has a built-in `update()` method, which would conflict.

### Navigation

Navigation is driven by a single `StateProvider<AppScreen>`. No routing package needed:

```dart
// Navigate to any screen from anywhere
ref.read(activeScreenProvider.notifier).state = AppScreen.inventory;
```

### Sale Creation — Cascading Side Effects

`SalesNotifier.createSale()` performs three operations atomically:

1. ✅ Inserts the sale and its line items into `sales` / `sale_items`
2. ✅ Calls `inventoryProvider.adjustStock(-qty)` for each line item
3. ✅ Creates an income entry automatically in `treasury`

---

## 🗄️ Database Schema

Local SQLite via `sqflite_common_ffi` — no server or internet connection required.

| Table | Key Fields |
|-------|-----------|
| `medicines` | id, name, category, barcode, batch_no, expiry_date, purchase_price, sale_price, quantity, min_quantity, active_ingredient |
| `sales` | id, invoice_no, customer_name, total, discount, paid, status, payment_method |
| `sale_items` | id, sale_id, medicine_id, quantity, unit_price, discount |
| `purchases` | id, po_no, supplier_name, total, paid, status, due_date |
| `purchase_items` | id, purchase_id, medicine_id, quantity, unit_cost |
| `customers` | id, name, phone, email, balance |
| `suppliers` | id, name, contact_person, phone, balance |
| `employees` | id, name, role, salary, permissions, active |
| `treasury` | id, type (income/expense), category, amount, balance_after, reference_id |
| `settings` | key, value (pharmacy_name, currency, tax_rate, …) |

> All IDs are UUID v4 (32-char hex). Dates are stored as ISO-8601 strings. Foreign keys are enabled via `PRAGMA foreign_keys = ON`.

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `sqflite_common_ffi` | SQLite on Windows / Linux / macOS |
| `path_provider` | Resolve app documents directory for DB path |
| `google_fonts` | DM Sans + DM Mono typography |
| `intl` | Currency and date formatting |
| `uuid` | UUID v4 ID generation |
| `pdf` + `printing` | PDF export for barcode labels and invoices |
| `fl_chart` | Charts in Reports and Dashboard |
| `shared_preferences` | Lightweight local settings storage |

---

## 🎨 Design System

### Color Tokens

| Token | Hex | Usage |
|-------|-----|-------|
| `blue900` | `#0C2D6B` | Sidebar background |
| `blue600` | `#2563EB` | Primary actions, active states |
| `green600` | `#16A34A` | Success, in-stock status |
| `amber500` | `#F59E0B` | Warning, low stock, near expiry |
| `red500` | `#EF4444` | Danger, expired medicines |
| `gray50` | `#F9FAFB` | Main content background |

### Typography

- **DM Sans** — all UI text (labels, headings, body)
- **DM Mono** — prices, barcodes, IDs, numeric codes

---

## 📄 License

Private project — all rights reserved.

---

<div align="center">

Built with Flutter 💙 &nbsp;·&nbsp; Local-first &nbsp;·&nbsp; No internet required

</div>
