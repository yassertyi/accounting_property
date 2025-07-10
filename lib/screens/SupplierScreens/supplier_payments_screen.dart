import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/supplier.dart';
import '../../models/supplier_payment.dart';

class SupplierPaymentsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierPaymentsScreen({super.key, required this.supplier});

  @override
  State<SupplierPaymentsScreen> createState() => _SupplierPaymentsScreenState();
}

class _SupplierPaymentsScreenState extends State<SupplierPaymentsScreen> {
  late final Box<SupplierPayment> _paymentBox;
  List<SupplierPayment> _payments = [];

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _paymentBox = Hive.box<SupplierPayment>('supplier_payments');
    _loadPayments();
  }

  void _loadPayments() {
    final supplierId = widget.supplier.key as int;
    _payments =
        _paymentBox.values.where((p) => p.supplierId == supplierId).toList();
    setState(() {});
  }

  List<SupplierPayment> get filteredPayments {
    List<SupplierPayment> payments =
        (startDate == null || endDate == null)
            ? _payments
            : _payments.where((p) {
              final date = p.date;
              return !date.isBefore(startDate!) && !date.isAfter(endDate!);
            }).toList();

    payments.sort((a, b) => b.date.compareTo(a.date));
    return payments;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: endDate ?? DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && startDate!.isAfter(endDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? now,
      firstDate: startDate ?? DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        if (startDate != null && endDate!.isBefore(startDate!)) {
          startDate = null;
        }
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  void _addOrEditPayment({SupplierPayment? payment}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountController = TextEditingController(
      text: payment?.amount.toString() ?? '',
    );
    final noteController = TextEditingController(text: payment?.note ?? '');
    DateTime selectedDate = payment?.date ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      payment == null ? "إضافة دفعة" : "تعديل الدفعة",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "المبلغ",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color:
                              isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "يجب إدخال المبلغ";
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return "يجب إدخال رقم صحيح أكبر من الصفر";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: noteController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "ملاحظة",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.note,
                          color:
                              isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color:
                                  isDark
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "إلغاء",
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final amount =
                                  double.tryParse(amountController.text) ?? 0;
                              final note = noteController.text.trim();
                              if (amount <= 0) return;

                              if (payment == null) {
                                final newPayment = SupplierPayment(
                                  supplierId: widget.supplier.key as int,
                                  amount: amount,
                                  date: selectedDate,
                                  note: note,
                                );
                                await _paymentBox.add(newPayment);
                                widget.supplier.totalPaid += amount;
                                await widget.supplier.save();
                                _loadPayments();
                                Navigator.pop(context);
                                _showMessage("تم إضافة الدفعة بنجاح");
                              } else {
                                final confirmed = await _showConfirmDialog(
                                  "هل أنت متأكد من تعديل هذه الدفعة؟",
                                );
                                if (confirmed) {
                                  final diff = amount - payment.amount;
                                  payment.amount = amount;
                                  payment.note = note;
                                  payment.date = selectedDate;
                                  await payment.save();

                                  widget.supplier.totalPaid += diff;
                                  await widget.supplier.save();
                                  _loadPayments();
                                  Navigator.pop(context);
                                  _showMessage("تم تعديل الدفعة بنجاح");
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            payment == null ? "إضافة" : "تحديث",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deletePayment(SupplierPayment payment) async {
    final confirmed = await _showConfirmDialog(
      "هل تريد حذف الدفعة بقيمة ${payment.amount}؟",
    );
    if (confirmed) {
      widget.supplier.totalPaid -= payment.amount;
      await payment.delete();
      await widget.supplier.save();
      _loadPayments();
      _showMessage("تم حذف الدفعة بنجاح");
    }
  }

  Future<bool> _showConfirmDialog(String message) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
              title: Text(
                "تأكيد",
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              content: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade700,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "إلغاء",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("نعم"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("دفعات المورد: ${widget.supplier.name}"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade700,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [Colors.grey.shade900, Colors.black]
                    : [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.date_range,
                        color: isDark ? Colors.white : Colors.white,
                      ),
                      label: Text(
                        startDate == null
                            ? "من تاريخ"
                            : "${startDate!.year}-${startDate!.month}-${startDate!.day}",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.white,
                        ),
                      ),
                      onPressed: _pickStartDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? Colors.blue.shade800
                                : Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.date_range,
                        color: isDark ? Colors.white : Colors.white,
                      ),
                      label: Text(
                        endDate == null
                            ? "إلى تاريخ"
                            : "${endDate!.year}-${endDate!.month}-${endDate!.day}",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.white,
                        ),
                      ),
                      onPressed: _pickEndDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? Colors.blue.shade800
                                : Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (startDate != null || endDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: _clearDateFilter,
                    child: const Text("مسح الفلتر"),
                  ),
                ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    filteredPayments.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment,
                                size: 64,
                                color:
                                    isDark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "لا توجد دفعات",
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = filteredPayments[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 0,
                              color:
                                  isDark ? Colors.grey.shade900 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade300,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          isDark
                                              ? Colors.blue.shade900
                                              : Colors.blue.shade100,
                                      child: Icon(
                                        Icons.payment,
                                        color:
                                            isDark
                                                ? Colors.blue.shade200
                                                : Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${payment.amount.toStringAsFixed(2)} ر.س",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${payment.date.toLocal().toString().split(' ')[0]}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade700,
                                            ),
                                          ),
                                          if (payment.note.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              payment.note,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color:
                                                isDark
                                                    ? Colors.blue.shade300
                                                    : Colors.blue,
                                            size: 20,
                                          ),
                                          onPressed:
                                              () => _addOrEditPayment(
                                                payment: payment,
                                              ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color:
                                                isDark
                                                    ? Colors.red.shade300
                                                    : Colors.red,
                                            size: 20,
                                          ),
                                          onPressed:
                                              () => _deletePayment(payment),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditPayment(),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
