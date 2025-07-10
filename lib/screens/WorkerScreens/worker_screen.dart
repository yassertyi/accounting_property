import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_accounting_app/cubits/worker_cubit.dart';
import 'package:my_accounting_app/cubits/worker_state.dart';
import 'package:my_accounting_app/screens/WorkerScreens/worker_details_screen.dart';
import '../../models/worker.dart';

class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة العمال"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [Colors.grey.shade900, Colors.grey.shade800]
                      : [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [Colors.grey.shade900, Colors.black]
                    : [Colors.grey.shade100, Colors.grey.shade200],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'ابحث عن عامل',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                onChanged: (value) {
                  context.read<WorkerCubit>().filterWorkers(value);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<WorkerCubit, WorkerState>(
                builder: (context, state) {
                  if (state is WorkerLoaded) {
                    if (state.workers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color:
                                  isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "لا يوجد عمال مسجلين",
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
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.workers.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                          ),
                      itemBuilder: (context, index) {
                        final worker = state.workers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 0,
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => WorkerDetailsScreen(
                                        worker: worker,
                                        index: index,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        isDark
                                            ? Colors.blue.shade900
                                            : Colors.blue.shade100,
                                    child: Text(
                                      worker.name.isNotEmpty
                                          ? worker.name[0].toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.blue.shade200
                                                : Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "المتفق عليه: ${worker.totalAgreed} ر.س",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          "المدفوع: ${worker.totalPaid} ر.س",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${worker.balance} ر.س",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              worker.balance > 0
                                                  ? Colors.red.shade400
                                                  : Colors.green.shade400,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditWorkerDialog(
                                              context,
                                              worker,
                                              index,
                                              isDark,
                                            );
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(
                                              context,
                                              index,
                                              isDark,
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      color:
                                                          isDark
                                                              ? Colors
                                                                  .blue
                                                                  .shade300
                                                              : Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "تعديل",
                                                      style: TextStyle(
                                                        color:
                                                            isDark
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color:
                                                          isDark
                                                              ? Colors
                                                                  .red
                                                                  .shade300
                                                              : Colors.red,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "حذف",
                                                      style: TextStyle(
                                                        color:
                                                            isDark
                                                                ? Colors.white
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkerDialog(context),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddWorkerDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    final agreedController = TextEditingController();
    final paidController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "إضافة عامل جديد",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "اسم العامل",
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
                        Icons.person,
                        color:
                            isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يجب إدخال اسم العامل";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: agreedController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "المبلغ المتفق عليه",
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
                        return "يجب إدخال المبلغ المتفق عليه";
                      }
                      if (double.tryParse(value) == null) {
                        return "يجب إدخال رقم صحيح";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: paidController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "المبلغ المدفوع",
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
                        Icons.payment,
                        color:
                            isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يجب إدخال المبلغ المدفوع";
                      }
                      if (double.tryParse(value) == null) {
                        return "يجب إدخال رقم صحيح";
                      }
                      return null;
                    },
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
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final agreed = double.parse(agreedController.text);
                            final paid = double.parse(paidController.text);

                            if (paid > agreed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "المبلغ المدفوع لا يمكن أن يكون أكبر من المتفق عليه",
                                  ),
                                  backgroundColor:
                                      isDark ? Colors.red.shade800 : Colors.red,
                                ),
                              );
                              return;
                            }

                            final worker = Worker(
                              name: nameController.text,
                              totalAgreed: agreed,
                              totalPaid: paid,
                            );
                            context.read<WorkerCubit>().addWorker(worker);
                            Navigator.pop(context);
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
                        child: const Text("إضافة"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditWorkerDialog(
    BuildContext context,
    Worker worker,
    int index,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: worker.name);
    final agreedController = TextEditingController(
      text: worker.totalAgreed.toString(),
    );
    final paidController = TextEditingController(
      text: worker.totalPaid.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "تعديل بيانات العامل",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "اسم العامل",
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
                        Icons.person,
                        color:
                            isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يجب إدخال اسم العامل";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: agreedController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "المبلغ المتفق عليه",
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
                        return "يجب إدخال المبلغ المتفق عليه";
                      }
                      if (double.tryParse(value) == null) {
                        return "يجب إدخال رقم صحيح";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: paidController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "المبلغ المدفوع",
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
                        Icons.payment,
                        color:
                            isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يجب إدخال المبلغ المدفوع";
                      }
                      if (double.tryParse(value) == null) {
                        return "يجب إدخال رقم صحيح";
                      }
                      return null;
                    },
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
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newName = nameController.text;
                            final newAgreed = double.parse(
                              agreedController.text,
                            );
                            final newPaid = double.parse(paidController.text);

                            if (newPaid > newAgreed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "المبلغ المدفوع لا يمكن أن يكون أكبر من المتفق عليه",
                                  ),
                                  backgroundColor:
                                      isDark ? Colors.red.shade800 : Colors.red,
                                ),
                              );
                              return;
                            }

                            worker.name = newName;
                            worker.totalAgreed = newAgreed;
                            worker.totalPaid = newPaid;
                            worker.save();

                            context.read<WorkerCubit>().loadWorkers();
                            Navigator.pop(context);
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
                        child: const Text("حفظ التعديلات"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index, bool isDark) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          title: Text(
            "تأكيد الحذف",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف هذا العامل؟",
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
                context.read<WorkerCubit>().deleteWorker(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("تم حذف العامل بنجاح"),
                    backgroundColor:
                        isDark ? Colors.green.shade800 : Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );
  }
}
