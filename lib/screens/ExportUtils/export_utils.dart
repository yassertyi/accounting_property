import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

Future<String> exportWorkersToExcel(List workers) async {
  final data = workers.map((w) => {
    "الاسم": w.name,
    "الإجمالي": w.totalCost,
    "المدفوع": w.totalPaid,
    "المتبقي": w.balance,
  }).toList();

  return await _exportToExcel(data, "العمال");
}

Future<String> exportSuppliersToExcel(List suppliers) async {
  final data = suppliers.map((s) => {
    "الاسم": s.name,
    "الإجمالي": s.totalCost,
    "المدفوع": s.totalPaid,
    "المتبقي": s.balance,
  }).toList();

  return await _exportToExcel(data, "الموردين");
}

Future<String> exportAllToExcel(List workers, List suppliers) async {
  final data = [
    ...workers.map((w) => {
      "النوع": "عامل",
      "الاسم": w.name,
      "الإجمالي": w.totalCost,
      "المدفوع": w.totalPaid,
      "المتبقي": w.balance,
    }),
    ...suppliers.map((s) => {
      "النوع": "مورد",
      "الاسم": s.name,
      "الإجمالي": s.totalCost,
      "المدفوع": s.totalPaid,
      "المتبقي": s.balance,
    }),
  ];

  return await _exportToExcel(data, "جميع_البيانات");
}

Future<String> _exportToExcel(List<Map<String, dynamic>> data, String fileName) async {
  try {
    // الحصول على مجلد التطبيق الداخلي
    final Directory appDir = await getApplicationDocumentsDirectory();
    
    // إنشاء مجلد مخصص للتصدير إذا لم يكن موجوداً
    final Directory exportDir = Directory('${appDir.path}/تصدير_الحسابات');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    // إنشاء مسار الملف مع التاريخ والوقت
    final String filePath = '${exportDir.path}/$fileName-${DateTime.now().toString().replaceAll(':', '-')}.xlsx';
    
    // إنشاء ملف Excel
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    // كتابة العناوين
    if (data.isNotEmpty) {
      sheet.appendRow(data.first.keys.toList());
    }

    // كتابة البيانات
    for (var row in data) {
      sheet.appendRow(row.values.toList());
    }

    // حفظ الملف
    final fileBytes = excel.encode();
    if (fileBytes == null) throw Exception('فشل في إنشاء ملف Excel');
    
    final File file = File(filePath);
    await file.writeAsBytes(fileBytes);
    
    print('تم التصدير بنجاح إلى: $filePath');
    return filePath;
  } catch (e) {
    print('حدث خطأ أثناء التصدير: $e');
    throw Exception('فشل في التصدير: ${e.toString()}');
  }
}