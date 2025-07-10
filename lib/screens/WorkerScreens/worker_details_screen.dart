import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/worker.dart';
import '../../models/worker_payment.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final Worker worker;
  final int index;

  const WorkerDetailsScreen({
    super.key,
    required this.worker,
    required this.index,
  });

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  late Box<WorkerPayment> paymentBox;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    paymentBox = Hive.box<WorkerPayment>('worker_payments');
  }

  List<WorkerPayment> get workerPayments =>
      paymentBox.values.where((p) => p.workerId == widget.worker.key).toList();

  List<WorkerPayment> get filteredPayments {
    List<WorkerPayment> payments =
        (startDate == null || endDate == null)
            ? workerPayments
            : workerPayments.where((payment) {
              final date = payment.date;
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

  void _addOrEditPayment({WorkerPayment? payment}) {
    final amountController = TextEditingController(
      text: payment?.amount.toString(),
    );
    final noteController = TextEditingController(text: payment?.note);
    final dateController = TextEditingController(
      text:
          payment?.date.toString().split(' ')[0] ??
          DateTime.now().toString().split(' ')[0],
    );

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      payment == null ? "إضافة دفعة جديدة" : "تعديل الدفعة",
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
                                  ? Colors.blue.shade400
                                  : Colors.blue.shade700,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "يجب إدخال المبلغ";
                        }
                        if (double.tryParse(value) == null) {
                          return "يجب إدخال رقم صحيح";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: payment?.date ?? DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );
                        if (picked != null) {
                          dateController.text = picked.toString().split(' ')[0];
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: dateController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "التاريخ",
                            labelStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey : Colors.grey.shade700,
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
                              Icons.calendar_today,
                              color:
                                  isDark
                                      ? Colors.blue.shade400
                                      : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
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
                                  ? Colors.blue.shade400
                                  : Colors.blue.shade700,
                        ),
                      ),
                      maxLines: 2,
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
                          onPressed: () {
                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            final remainingBeforeEdit =
                                widget.worker.balance + (payment?.amount ?? 0);

                            if (amount <= 0) {
                              _showError("أدخل مبلغًا صحيحًا");
                              return;
                            }

                            if (amount > remainingBeforeEdit) {
                              _showError(
                                "لا يمكن دفع أكثر من المتبقي: $remainingBeforeEdit",
                              );
                              return;
                            }

                            if (payment == null) {
                              final newPayment = WorkerPayment(
                                workerId: widget.worker.key as int,
                                amount: amount,
                                date: DateTime.parse(dateController.text),
                                note: noteController.text,
                              );

                              paymentBox.add(newPayment);

                              widget.worker.totalPaid += amount;
                              widget.worker.save();

                              _showSuccess("تمت إضافة الدفعة بنجاح");
                            } else {
                              final diff = amount - payment.amount;
                              payment.amount = amount;
                              payment.note = noteController.text;
                              payment.date = DateTime.parse(
                                dateController.text,
                              );
                              payment.save();

                              widget.worker.totalPaid += diff;
                              widget.worker.save();

                              _showSuccess("تم تحديث الدفعة بنجاح");
                            }

                            setState(() {});
                            Navigator.pop(context);
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

  void _deletePayment(WorkerPayment payment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          title: Text(
            "تأكيد الحذف",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف الدفعة بقيمة ${payment.amount}؟",
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey.shade700,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "إلغاء",
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.worker.totalPaid -= payment.amount;
                widget.worker.save();

                payment.delete();
                setState(() {});
                Navigator.pop(context);

                _showSuccess("تم حذف الدفعة بنجاح");
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? Colors.red.shade800 : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? Colors.green.shade800 : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "تفاصيل العامل: ${worker.name}",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade700,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark
                  ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade900, Colors.black],
                  )
                  : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
                  ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: isDark ? Colors.grey.shade900 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color:
                                isDark
                                    ? Colors.blue.shade400
                                    : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            worker.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoItem(
                            "المتفق عليه",
                            "${worker.totalAgreed} ر.س",
                            Icons.assignment,
                            isDark
                                ? Colors.blue.shade400
                                : Colors.blue.shade700,
                            isDark,
                          ),
                          _buildInfoItem(
                            "المدفوع",
                            "${worker.totalPaid} ر.س",
                            Icons.payment,
                            isDark
                                ? Colors.green.shade400
                                : Colors.green.shade700,
                            isDark,
                          ),
                          _buildInfoItem(
                            "المتبقي",
                            "${worker.balance} ر.س",
                            Icons.money_off,
                            worker.balance > 0
                                ? (isDark
                                    ? Colors.red.shade400
                                    : Colors.red.shade700)
                                : (isDark
                                    ? Colors.green.shade400
                                    : Colors.green.shade700),
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                color: isDark ? Colors.grey.shade900 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "تصفية المدفوعات حسب التاريخ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.calendar_today,
                                size: 16,
                                color:
                                    isDark
                                        ? Colors.blue.shade400
                                        : Colors.blue.shade700,
                              ),
                              label: Text(
                                startDate == null
                                    ? "من تاريخ"
                                    : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              onPressed: _pickStartDate,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.calendar_today,
                                size: 16,
                                color:
                                    isDark
                                        ? Colors.blue.shade400
                                        : Colors.blue.shade700,
                              ),
                              label: Text(
                                endDate == null
                                    ? "إلى تاريخ"
                                    : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              onPressed: _pickEndDate,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (startDate != null || endDate != null)
                        TextButton(
                          onPressed: _clearDateFilter,
                          child: Text(
                            "مسح الفلتر",
                            style: TextStyle(color: Colors.blue.shade400),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "سجل المدفوعات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    filteredPayments.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color:
                                    isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "لا توجد مدفوعات في هذا النطاق الزمني",
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.grey
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.separated(
                          itemCount: filteredPayments.length,
                          separatorBuilder:
                              (context, index) => Divider(
                                height: 1,
                                color:
                                    isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                              ),
                          itemBuilder: (context, index) {
                            final p = filteredPayments[index];
                            return Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              color:
                                  isDark ? Colors.grey.shade900 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade300,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.blue.shade100,
                                  child: Icon(
                                    Icons.payment,
                                    color:
                                        isDark
                                            ? Colors.blue.shade400
                                            : Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  "${p.amount} ر.ي",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "التاريخ: ${p.date.toString().split(' ')[0]}",
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.grey
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                    if (p.note.isNotEmpty)
                                      Text(
                                        "ملاحظة: ${p.note}",
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.grey
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color:
                                            isDark
                                                ? Colors.blue.shade400
                                                : Colors.blue.shade700,
                                      ),
                                      onPressed:
                                          () => _addOrEditPayment(payment: p),
                                      tooltip: "تعديل",
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color:
                                            isDark
                                                ? Colors.red.shade400
                                                : Colors.red.shade700,
                                      ),
                                      onPressed: () => _deletePayment(p),
                                      tooltip: "حذف",
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

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
