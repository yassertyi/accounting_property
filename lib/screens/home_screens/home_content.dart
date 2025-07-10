import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:my_accounting_app/screens/ExportUtils/export_utils.dart';
import '../../cubits/supplier_cubit/supplier_cubit.dart';
import '../../cubits/supplier_cubit/supplier_state.dart';
import '../../cubits/worker_cubit.dart';
import '../../cubits/worker_state.dart';
import '../WorkerScreens/worker_screen.dart';
import '../SupplierScreens/supplier_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.grey[800]!;

    return BlocBuilder<WorkerCubit, WorkerState>(
      builder: (context, workerState) {
        return BlocBuilder<SupplierCubit, SupplierState>(
          builder: (context, supplierState) {
            final workers =
                workerState is WorkerLoaded ? workerState.workers : [];
            final suppliers =
                supplierState is SupplierLoaded ? supplierState.suppliers : [];

            final workerPaid = workers.fold(0.0, (sum, w) => sum + w.totalPaid);
            final workerRemaining = workers.fold(
              0.0,
              (sum, w) => sum + w.balance,
            );
            final supplierPaid = suppliers.fold(
              0.0,
              (sum, s) => sum + s.totalPaid,
            );
            final supplierRemaining = suppliers.fold(
              0.0,
              (sum, s) => sum + s.balance,
            );

            final totalPaid = workerPaid + supplierPaid;
            final totalRemaining = workerRemaining + supplierRemaining;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(
                    context,
                    theme,
                    cardColor,
                    textColor,
                    totalPaid,
                    totalRemaining,
                  ),
                  const SizedBox(height: 30),
                  _buildQuickActionsSection(context, theme),
                  const SizedBox(height: 30),
                  _buildExportButton(context, workers, suppliers),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    ThemeData theme,
    Color? cardColor,
    Color textColor,
    double totalPaid,
    double totalRemaining,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "ملخص الحسابات",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(
                  context,
                  icon: Icons.upload,
                  title: "المدفوع",
                  value: totalPaid,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  context,
                  icon: Icons.download,
                  title: "المتبقي",
                  value: totalRemaining,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Divider(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[300],
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: "الإجمالي",
                  value: totalPaid + totalRemaining,
                  color: theme.primaryColor,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "الأقسام",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 5),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.people,
              label: "العمال",
              color: Colors.blue,
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider.value(
                            value: BlocProvider.of<WorkerCubit>(context),
                            child: const WorkerScreen(),
                          ),
                    ),
                  ).then((_) {
                    context.read<SupplierCubit>().loadSuppliers();
                    context.read<WorkerCubit>().loadWorkers();
                  }),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.store,
              label: "المواد",
              color: Colors.orange,
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider.value(
                            value: BlocProvider.of<SupplierCubit>(context),
                            child: const SupplierScreen(),
                          ),
                    ),
                  ).then((_) {
                    context.read<SupplierCubit>().loadSuppliers();
                    context.read<WorkerCubit>().loadWorkers();
                  }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    List workers,
    List suppliers,
  ) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          onPressed: () => _showExportOptions(context, workers, suppliers),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_download),
              SizedBox(width: 8),
              Text("تصدير البيانات"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double value,
    required Color color,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                "${value.toStringAsFixed(2)} ريال",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? theme.primaryColor : color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, List workers, List suppliers) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "تصدير البيانات",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "اختر نوع البيانات المراد تصديرها",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildExportOption(
                context,
                icon: Icons.people,
                label: "تصدير بيانات العمال",
                onPressed: () async {
                  try {
                    final path = await exportWorkersToExcel(workers);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSuccess(context, path);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("فشل التصدير: ${e.toString()}")),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                context,
                icon: Icons.store,
                label: "تصدير بيانات المواد",
                onPressed: () async {
                  try {
                    final path = await exportSuppliersToExcel(suppliers);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSuccess(context, path);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("فشل التصدير: ${e.toString()}")),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                context,
                icon: Icons.all_inclusive,
                label: "تصدير جميع البيانات",
                onPressed: () async {
                  try {
                    final path = await exportAllToExcel(workers, suppliers);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSuccess(context, path);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("فشل التصدير: ${e.toString()}")),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            const Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("تم التصدير بنجاح"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "فتح الملف",
          onPressed: () => OpenFile.open(path),
        ),
      ),
    );
  }
}
