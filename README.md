<div align="center">

# 💊 Smart Cure
### Pharmacy Management System

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local%20DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-Desktop-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge)

**نظام إدارة صيدلية متكامل — سريع، احترافي، يعمل بدون إنترنت**

</div>

---

## ✨ الميزات

| الوحدة | الوصف |
|--------|--------|
| 📦 **Inventory** | إدارة كاملة للأدوية — بحث، فلتر، شريط مخزون، تتبع انتهاء الصلاحية |
| 🧾 **Sales (POS)** | فواتير مع بحث تلقائي للدواء، خصم، طرق دفع متعددة، خصم تلقائي من المخزون |
| 🛒 **Purchases** | طلبات شراء من الموردين، استلام مخزون، تحديث تلقائي للمستودع |
| 👥 **Customers** | ملفات العملاء مع تتبع الرصيد وسجل المشتريات |
| 🏭 **Suppliers** | إدارة الموردين مع الرصيد المستحق |
| 👨‍💼 **Employees** | ملفات الموظفين، الأدوار، الرواتب، الصلاحيات |
| 💰 **Treasury** | دفتر الإيرادات والمصروفات مرتبط تلقائياً بالمبيعات |
| 📊 **Reports** | تحليلات المبيعات، أعلى الأدوية مبيعاً، مخططات الإيرادات |
| ⚠️ **Expiry Alerts** | تنبيهات الأدوية المنتهية أو القريبة من الانتهاء |
| 🔖 **Barcode** | مولد باركود وتصدير PDF جاهز للطباعة |
| 🔄 **Alternatives** | إيجاد بدائل الدواء بناءً على المادة الفعّالة |
| 🔐 **Permissions** | تحكم في صلاحيات كل موظف لكل وحدة |
| ⚙️ **Settings** | اسم الصيدلية، العملة، نسبة الضريبة، النسخ الاحتياطي |
| 📈 **Accounting** | نظرة عامة على الأرباح والخسائر والميزانية العمومية |

---

## 🚀 تشغيل المشروع

### المتطلبات

- [Flutter SDK](https://flutter.dev/docs/get-started/install) نسخة 3.0 أو أحدث
- Windows 10/11
- Visual Studio 2022 مع **Desktop development with C++**

### التشغيل

```bash
git clone https://github.com/ainzowork-gif/smart-cure.git
cd smart-cure
flutter pub get
flutter run -d windows
```

### بناء الـ EXE النهائي

```bash
flutter build windows --release
# الناتج: build/windows/x64/runner/Release/smart_cure.exe
```

### إعادة ضبط قاعدة البيانات

احذف الملف التالي للبدء من جديد مع بيانات تجريبية:

```
%USERPROFILE%\Documents\smart_cure\smart_cure.db
```

---

## 🏗️ هيكل المشروع

```
smart_cure/
├── lib/
│   ├── main.dart                    # نقطة البداية: sqfliteFfiInit + ProviderScope
│   ├── app.dart                     # AppShell: Sidebar + Screen switcher + StatusBar
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart      # ألوان التصميم (blue900 → gray50)
│   │   │   └── app_theme.dart       # خطوط DM Sans + DM Mono
│   │   ├── database/
│   │   │   └── database_helper.dart # SQLite singleton — كل عمليات CRUD
│   │   └── utils/
│   │       └── helpers.dart         # formatCurrency, formatDate, generateId (UUID v4)
│   │
│   ├── models/                      # Dart خالص — fromMap / toMap / copyWith
│   │   ├── medicine.dart
│   │   ├── sale.dart                # Sale + SaleItem
│   │   ├── purchase.dart            # Purchase + PurchaseItem
│   │   ├── customer.dart
│   │   ├── supplier.dart
│   │   ├── employee.dart
│   │   └── treasury.dart
│   │
│   ├── providers/                   # Riverpod AsyncNotifier لكل وحدة
│   │   ├── app_provider.dart        # AppScreen enum + التنقل + البحث العام
│   │   ├── inventory_provider.dart
│   │   ├── sales_provider.dart      # createSale → فاتورة + خزينة + مخزون
│   │   ├── purchases_provider.dart
│   │   ├── customers_provider.dart
│   │   ├── suppliers_provider.dart
│   │   ├── employees_provider.dart
│   │   └── treasury_provider.dart
│   │
│   ├── screens/                     # شاشة لكل وحدة (ConsumerWidget)
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
│   └── widgets/shared/              # مكونات نظام التصميم
│       ├── sc_panel.dart            # بطاقة بعنوان + محتوى (LayoutBuilder-aware)
│       ├── sc_button.dart           # primary / success / ghost
│       ├── sc_text_field.dart       # حقل إدخال موحد
│       ├── sc_badge.dart            # success / warning / danger / info
│       ├── stock_bar.dart           # شريط مستوى المخزون
│       ├── kpi_card.dart            # بطاقة مؤشر الداشبورد
│       ├── topbar.dart              # العنوان + البحث + جرس الإشعارات
│       ├── sidebar.dart             # شريط التنقل الجانبي
│       └── status_bar.dart          # الشريط السفلي (وقت + حالة DB)
│
└── windows/                         # مشغّل Windows (CMake)
```

---

## ⚙️ Architecture

### إدارة الحالة — Riverpod

كل وحدة تتبع نفس النمط:

```dart
final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, List<Medicine>>(InventoryNotifier.new);

class InventoryNotifier extends AsyncNotifier<List<Medicine>> {
  Future<List<Medicine>> build() => _load();       // يُشغَّل تلقائياً
  Future<void> add(Medicine m)   async { ... refresh(); }
  Future<void> save(Medicine m)  async { ... refresh(); } // "save" وليس "update"
  Future<void> delete(String id) async { ... refresh(); }
}
```

> **ملاحظة:** اسم الدالة `save` وليس `update` لأن `AsyncNotifier` يحتوي على دالة `update()` مدمجة.

### التنقل

```dart
// الانتقال لأي شاشة من أي مكان
ref.read(activeScreenProvider.notifier).state = AppScreen.inventory;
```

### تسلسل عمليات إنشاء الفاتورة

`SalesNotifier.createSale()` تنفّذ 3 عمليات دفعة واحدة:

1. ✅ تُدرج الفاتورة وبنودها في `sales` و `sale_items`
2. ✅ تستدعي `adjustStock(-qty)` لكل دواء
3. ✅ تُنشئ إيراداً تلقائياً في `treasury`

---

## 🗄️ قاعدة البيانات

SQLite محلي — لا يحتاج إنترنت أو سيرفر.

| الجدول | الحقول الرئيسية |
|--------|----------------|
| `medicines` | id, name, category, barcode, batch_no, expiry_date, purchase_price, sale_price, quantity, min_quantity, active_ingredient |
| `sales` | id, invoice_no, customer_name, total, discount, paid, status, payment_method |
| `sale_items` | id, sale_id, medicine_id, quantity, unit_price |
| `purchases` | id, po_no, supplier_name, total, paid, status, due_date |
| `purchase_items` | id, purchase_id, medicine_id, quantity, unit_cost |
| `customers` | id, name, phone, email, balance |
| `suppliers` | id, name, contact_person, phone, balance |
| `employees` | id, name, role, salary, permissions, active |
| `treasury` | id, type (income/expense), category, amount, balance_after |
| `settings` | key, value |

> جميع الـ IDs بصيغة UUID v4 (32 حرف hex). التواريخ مخزنة كـ ISO-8601.

---

## 📦 المكتبات

| المكتبة | الغرض |
|---------|-------|
| `flutter_riverpod` | إدارة الحالة |
| `sqflite_common_ffi` | SQLite على Windows/Linux/macOS |
| `path_provider` | مسار قاعدة البيانات |
| `google_fonts` | خطوط DM Sans + DM Mono |
| `intl` | تنسيق العملة والتاريخ |
| `uuid` | توليد معرّفات فريدة |
| `pdf` + `printing` | تصدير PDF (باركود، فواتير) |
| `fl_chart` | الرسوم البيانية |
| `shared_preferences` | إعدادات محلية |

---

## 🎨 نظام التصميم

| المتغير | القيمة | الاستخدام |
|---------|--------|-----------|
| `blue900` | `#0C2D6B` | خلفية الشريط الجانبي |
| `blue600` | `#2563EB` | الإجراءات الرئيسية |
| `green600` | `#16A34A` | نجاح، متوفر في المخزون |
| `amber500` | `#F59E0B` | تحذير، مخزون منخفض |
| `red500` | `#EF4444` | خطر، منتهي الصلاحية |
| `gray50` | `#F9FAFB` | خلفية المحتوى |

**الخطوط:** DM Sans لنصوص الواجهة · DM Mono للأسعار والأكواد والمعرّفات

---

<div align="center">

Built with Flutter 💙 · Local-first · No internet required

</div>
