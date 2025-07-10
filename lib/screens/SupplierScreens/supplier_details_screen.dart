import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import 'supplier_materials_screen.dart';
import 'supplier_payments_screen.dart';

class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;
  final int index;

  const SupplierDetailsScreen({
    super.key,
    required this.supplier,
    required this.index,
  });

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supplier = widget.supplier;

    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل المورد: ${supplier.name}"),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: isDark ? Colors.grey.shade900 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            color:
                                isDark
                                    ? Colors.blue.shade400
                                    : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            supplier.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // هنا التعديل: مدفوع ومتُبقي جنب بعض، والإجمالي تحتهم
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  "المدفوع",
                                  supplier.totalPaid.toStringAsFixed(2),
                                  "ريال",
                                  Icons.payment,
                                  Colors.green,
                                  isDark,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  "المتبقي",
                                  supplier.balance.toStringAsFixed(2),
                                  "ريال",
                                  Icons.money_off,
                                  supplier.balance > 0
                                      ? Colors.red
                                      : Colors.green,
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildInfoItem(
                              "الإجمالي",
                              supplier.totalCost.toStringAsFixed(2),
                              "ريال",
                              Icons.money,
                              Colors.blue,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "الخيارات المتاحة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildOptionCard(
                      context,
                      "المواد المرتبطة",
                      Icons.inventory,
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    SupplierMaterialsScreen(supplier: supplier),
                          ),
                        );
                      },
                      isDark,
                    ),
                    _buildOptionCard(
                      context,
                      "الدفعات المالية",
                      Icons.payments,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    SupplierPaymentsScreen(supplier: supplier),
                          ),
                        ).then((_) {
                          setState(() {}); // إعادة بناء الواجهة لتحديث البيانات
                        });
                      },
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            Text(unit, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
