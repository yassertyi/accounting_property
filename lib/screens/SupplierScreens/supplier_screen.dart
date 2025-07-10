import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/supplier_cubit/supplier_cubit.dart';
import '../../cubits/supplier_cubit/supplier_state.dart';
import '../../models/supplier.dart';
import 'supplier_details_screen.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Supplier> filteredSuppliers = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    final cubit = context.read<SupplierCubit>();
    final allSuppliers =
        cubit.state is SupplierLoaded
            ? (cubit.state as SupplierLoaded).suppliers
            : <Supplier>[];

    if (query.isEmpty) {
      setState(() {
        filteredSuppliers = allSuppliers;
      });
    } else {
      setState(() {
        filteredSuppliers =
            allSuppliers
                .where(
                  (supplier) => supplier.name.toLowerCase().contains(query),
                )
                .toList();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الموردين"),
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
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "ابحث عن مورد",
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
              ),
            ),
            Expanded(
              child: BlocBuilder<SupplierCubit, SupplierState>(
                builder: (context, state) {
                  if (state is SupplierLoaded) {
                    final suppliersToShow =
                        searchController.text.isEmpty
                            ? state.suppliers
                            : filteredSuppliers;

                    if (suppliersToShow.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color:
                                  isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "لا يوجد موردين مسجلين",
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
                      itemCount: suppliersToShow.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                          ),
                      itemBuilder: (context, index) {
                        final supplier = suppliersToShow[index];
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
                                      (_) => SupplierDetailsScreen(
                                        supplier: supplier,
                                        index: index,
                                      ),
                                ),
                              ).then((_) {
                                context.read<SupplierCubit>().loadSuppliers();
                              });
                            },

                            onLongPress: () {
                              _showDeleteSupplierDialog(
                                context,
                                index,
                                supplier.name,
                                isDark,
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
                                    child: Icon(
                                      Icons.inventory,
                                      color:
                                          isDark
                                              ? Colors.blue.shade200
                                              : Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supplier.name,
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
                                          "الإجمالي: ${supplier.totalCost} ر.س",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          "المدفوع: ${supplier.totalPaid} ر.س",
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
                                        "${supplier.balance} ر.س",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              supplier.balance > 0
                                                  ? Colors.red.shade400
                                                  : Colors.green.shade400,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          _showOptionsMenu(
                                            context,
                                            index,
                                            supplier,
                                            isDark,
                                          );
                                        },
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
        onPressed: () => _showAddSupplierDialog(context, isDark),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showOptionsMenu(
    BuildContext context,
    int index,
    Supplier supplier,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
                title: Text(
                  "تعديل",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditSupplierDialog(context, supplier, index, isDark);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: isDark ? Colors.red.shade300 : Colors.red,
                ),
                title: Text(
                  "حذف",
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteSupplierDialog(
                    context,
                    index,
                    supplier.name,
                    isDark,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSupplierDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
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
                    "إضافة مورد جديد",
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
                      labelText: "اسم المورد",
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
                        Icons.inventory,
                        color:
                            isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يجب إدخال اسم المورد";
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
                            final supplier = Supplier(
                              name: nameController.text,
                            );
                            context.read<SupplierCubit>().addSupplier(supplier);
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

  void _showEditSupplierDialog(
    BuildContext context,
    Supplier supplier,
    int index,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: supplier.name);
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
                    "تعديل بيانات المورد",
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
                      labelText: "اسم المورد",
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
                        Icons.inventory,
                        color:
                            isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يجب إدخال اسم المورد";
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
                            supplier.name = nameController.text;
                            supplier.save();
                            context.read<SupplierCubit>().loadSuppliers();
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

  void _showDeleteSupplierDialog(
    BuildContext context,
    int index,
    String name,
    bool isDark,
  ) {
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
            "هل أنت متأكد أنك تريد حذف المورد $name؟",
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
                context.read<SupplierCubit>().deleteSupplier(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("تم حذف المورد بنجاح"),
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
