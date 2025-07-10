import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_accounting_app/models/material_item.dart';
import 'package:my_accounting_app/models/supplier.dart';
import 'package:my_accounting_app/models/supplier_payment.dart';
import 'package:my_accounting_app/models/worker.dart';
import 'package:my_accounting_app/models/worker_payment.dart';
import 'package:my_accounting_app/screens/settings_screen/about_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_accounting_app/screens/settings_screen/theme_controller.dart';
import 'package:my_accounting_app/screens/settings_screen/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsController _settingsController;
  bool _isLoading = true;
  ThemeMode _currentTheme = ThemeMode.system;
  bool _backupEnabled = false;
  bool _notificationsEnabled = true;
  bool _biometricAuthEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _checkBiometricAvailability();
  }

  Future<void> _initSettings() async {
    try {
      final settingsBox = await Hive.openBox('app_settings');
      _settingsController = SettingsController(settingsBox);
      _loadSettings();
    } catch (e) {
      debugPrint("Error initializing settings: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      setState(() {
        _isBiometricAvailable = canAuthenticate;
      });
    } catch (e) {
      debugPrint("Error checking biometric availability: $e");
    }
  }

  void _loadSettings() {
    try {
      setState(() {
        _currentTheme = _settingsController.themeMode;
        _backupEnabled = _settingsController.backupEnabled;
        _notificationsEnabled = _settingsController.notificationsEnabled;
        _biometricAuthEnabled = _settingsController.biometricAuthEnabled;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading settings: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File(
        '${directory.path}/accounting_backup_$timestamp.json',
      );

      // الحصول على الصناديق المفتوحة بدلاً من محاولة فتحها مجدداً
      final workersBox = Hive.box<Worker>('workers');
      final workerPaymentsBox = Hive.box<WorkerPayment>('worker_payments');
      final suppliersBox = Hive.box<Supplier>('suppliers');
      final materialsBox = Hive.box<MaterialItem>('materials');
      final supplierPaymentsBox = Hive.box<SupplierPayment>(
        'supplier_payments',
      );

      // تحويل البيانات إلى JSON
      final backupMap = {
        'workers': workersBox.values.map((e) => e.toJson()).toList(),
        'worker_payments':
            workerPaymentsBox.values.map((e) => e.toJson()).toList(),
        'suppliers': suppliersBox.values.map((e) => e.toJson()).toList(),
        'materials': materialsBox.values.map((e) => e.toJson()).toList(),
        'supplier_payments':
            supplierPaymentsBox.values.map((e) => e.toJson()).toList(),
        'metadata': {
          'backupDate': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
        },
      };

      // حفظ النسخة الاحتياطية
      await backupFile.writeAsString(jsonEncode(backupMap));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم النسخ الاحتياطي بنجاح إلى: ${backupFile.path}'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error during backup: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في النسخ الاحتياطي: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'اختر ملف النسخة الاحتياطية',
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final backupData = jsonDecode(jsonString);

        // Restore each box
        await _restoreBox('workers', backupData['workers']);
        await _restoreBox('worker_payments', backupData['worker_payments']);
        await _restoreBox('suppliers', backupData['suppliers']);
        await _restoreBox('materials', backupData['materials']);
        await _restoreBox('supplier_payments', backupData['supplier_payments']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم استعادة البيانات بنجاح"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل في استعادة البيانات: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreBox(String boxName, List<dynamic> data) async {
    final box = Hive.box(boxName);
    await box.clear();

    for (var item in data) {
      switch (boxName) {
        case 'workers':
          await box.add(
            Worker(
              name: item['name'],
              totalAgreed: item['totalAgreed'],
              totalPaid: item['totalPaid'],
            ),
          );
          break;
        case 'worker_payments':
          await box.add(
            WorkerPayment(
              workerId: item['workerId'],
              amount: item['amount'],
              date: DateTime.parse(item['date']),
              note: item['note'],
            ),
          );
          break;
        case 'suppliers':
          await box.add(
            Supplier(
              name: item['name'],
              totalCost: item['totalCost'],
              totalPaid: item['totalPaid'],
            ),
          );
          break;
        case 'materials':
          await box.add(
            MaterialItem(
              supplierId: item['supplierId'],
              name: item['name'],
              quantity: item['quantity'],
              unitPrice: item['unitPrice'],
            ),
          );
          break;
        case 'supplier_payments':
          await box.add(
            SupplierPayment(
              supplierId: item['supplierId'],
              amount: item['amount'],
              date: DateTime.parse(item['date']),
              note: item['note'],
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات"), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingsSection(
                      title: "المظهر",
                      icon: Icons.palette,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text("فاتح"),
                                icon: Icon(Icons.light_mode),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text("داكن"),
                                icon: Icon(Icons.dark_mode),
                              ),
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text("النظام"),
                                icon: Icon(Icons.settings),
                              ),
                            ],
                            selected: {_currentTheme},
                            onSelectionChanged: (
                              Set<ThemeMode> newSelection,
                            ) async {
                              await _settingsController.updateThemeMode(
                                newSelection.first,
                              );
                              themeNotifier.value = newSelection.first;
                              setState(() {
                                _currentTheme = newSelection.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    _SettingsSection(
                      title: "النسخ الاحتياطي",
                      icon: Icons.backup,
                      children: [
                        _SettingsTile(
                          icon: Icons.cloud_upload,
                          title: "النسخ الاحتياطي التلقائي",
                          trailing: Switch(
                            value: _backupEnabled,
                            onChanged: (value) async {
                              await _settingsController.updateBackupEnabled(
                                value,
                              );
                              setState(() {
                                _backupEnabled = value;
                              });
                            },
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.backup,
                          title: "إنشاء نسخة احتياطية الآن",
                          onTap: () => _backupData(context),
                        ),
                        _SettingsTile(
                          icon: Icons.restore,
                          title: "استعادة من نسخة احتياطية",
                          onTap: () => _restoreData(context),
                        ),
                      ],
                    ),
                    _SettingsSection(
                      title: "عن التطبيق",
                      icon: Icons.info_outline,
                      children: [
                        _SettingsTile(
                          icon: Icons.info,
                          title: "معلومات حول المشروع والمطور",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
