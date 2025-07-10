import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_accounting_app/cubits/material_cubit/material_cubit.dart';
import 'package:my_accounting_app/cubits/supplier_cubit/supplier_cubit.dart';
import 'package:my_accounting_app/cubits/worker_cubit.dart';
import 'package:my_accounting_app/models/material_item.dart';
import 'package:my_accounting_app/models/supplier.dart';
import 'package:my_accounting_app/models/supplier_payment.dart';
import 'package:my_accounting_app/models/worker.dart';
import 'package:my_accounting_app/models/worker_payment.dart';
import 'package:my_accounting_app/screens/home_screens/home_screen.dart';
import 'package:my_accounting_app/screens/settings_screen/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(WorkerAdapter());
  Hive.registerAdapter(WorkerPaymentAdapter());
  Hive.registerAdapter(SupplierAdapter());
  Hive.registerAdapter(MaterialItemAdapter());
  Hive.registerAdapter(SupplierPaymentAdapter());

  await Future.wait([
    Hive.openBox<Worker>('workers'),
    Hive.openBox<WorkerPayment>('worker_payments'),
    Hive.openBox<Supplier>('suppliers'),
    Hive.openBox<MaterialItem>('materials'),
    Hive.openBox<SupplierPayment>('supplier_payments'),
    Hive.openBox('app_settings'),
  ]);

  await loadAppSettings();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkerCubit()..loadWorkers()),
        BlocProvider(create: (_) => SupplierCubit()..loadSuppliers()),
        BlocProvider(create: (_) => MaterialCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'نظام محاسبي شخصي',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          locale: const Locale('ar'),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl, 
              child: child!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
