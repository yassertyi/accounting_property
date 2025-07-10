import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/material_cubit/material_cubit.dart';
import '../../cubits/material_cubit/material_state.dart' as myState;
import '../../models/material_item.dart';
import '../../models/supplier.dart';

class SupplierMaterialsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierMaterialsScreen({super.key, required this.supplier});

  @override
  State<SupplierMaterialsScreen> createState() =>
      _SupplierMaterialsScreenState();
}

class _SupplierMaterialsScreenState extends State<SupplierMaterialsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MaterialCubit>().loadMaterials(widget.supplier.key as int);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars(); // ✅ تنظيف الرسائل السابقة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

  void _addOrEditMaterial({MaterialItem? material}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(text: material?.name ?? '');
    final quantityController = TextEditingController(
      text: material?.quantity.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: material?.unitPrice.toString() ?? '',
    );
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
                      material == null ? "إضافة مادة جديدة" : "تعديل المادة",
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
                        labelText: "اسم المادة",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(
                          Icons.inventory,
                          color:
                              isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                        ),
                      ),
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? "يجب إدخال اسم المادة"
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "الكمية",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color:
                              isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "يجب إدخال الكمية";
                        final num = double.tryParse(value);
                        if (num == null || num <= 0)
                          return "يجب إدخال رقم صحيح أكبر من الصفر";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "سعر الوحدة",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
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
                        if (value == null || value.isEmpty)
                          return "يجب إدخال سعر الوحدة";
                        final num = double.tryParse(value);
                        if (num == null || num <= 0)
                          return "يجب إدخال رقم صحيح أكبر من الصفر";
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
                              final name = nameController.text.trim();
                              final quantity = double.parse(
                                quantityController.text.trim(),
                              );
                              final unitPrice = double.parse(
                                priceController.text.trim(),
                              );
                              final supplierId = widget.supplier.key as int;

                              if (material == null) {
                                final newMaterial = MaterialItem(
                                  supplierId: supplierId,
                                  name: name,
                                  quantity: quantity,
                                  unitPrice: unitPrice,
                                );

                                context.read<MaterialCubit>().addMaterial(
                                  newMaterial,
                                );
                                widget.supplier.totalCost +=
                                    newMaterial.totalPrice;
                                await widget.supplier.save();
                                Navigator.pop(context);
                                _showMessage("تم إضافة المادة بنجاح");
                              } else {
                                final confirmed = await _showConfirmDialog(
                                  "هل أنت متأكد من تعديل المادة؟",
                                );
                                if (!confirmed) return;

                                final oldTotal = material.totalPrice;
                                material.name = name;
                                material.quantity = quantity;
                                material.unitPrice = unitPrice;
                                await material.save();

                                widget.supplier.totalCost +=
                                    (material.totalPrice - oldTotal);
                                await widget.supplier.save();
                                Navigator.pop(context);
                                _showMessage("تم تعديل المادة بنجاح");
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            material == null ? "إضافة" : "تحديث",
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

  void _deleteMaterial(MaterialItem material) async {
    final confirmed = await _showConfirmDialog(
      "هل تريد حذف المادة '${material.name}'؟",
    );
    if (!confirmed) return;

    try {
      context.read<MaterialCubit>().deleteMaterialByKey(
        material.key,
        widget.supplier.key as int,
      );
      widget.supplier.totalCost -= material.totalPrice;
      await widget.supplier.save();
      _showMessage("تم حذف المادة بنجاح");
    } catch (_) {
      _showMessage("حدث خطأ أثناء حذف المادة", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("مواد المورد: ${widget.supplier.name}"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade700,
      ),
      body: BlocBuilder<MaterialCubit, myState.MaterialState>(
        builder: (context, state) {
          if (state is myState.MaterialLoaded) {
            if (state.materials.isEmpty) {
              return const Center(child: Text("لا توجد مواد مسجلة"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.materials.length,
              itemBuilder: (context, index) {
                final material = state.materials[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(material.name),
                    subtitle: Text(
                      "الكمية: ${material.quantity} | السعر: ${material.unitPrice}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              () => _addOrEditMaterial(material: material),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMaterial(material),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditMaterial(),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
