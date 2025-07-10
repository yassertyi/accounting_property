import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_accounting_app/cubits/supplier_cubit/supplier_cubit.dart';
import 'package:my_accounting_app/cubits/worker_cubit.dart';
import 'package:my_accounting_app/screens/home_screens/home_content.dart';
import 'package:my_accounting_app/screens/settings_screen/settings_screen.dart';
import '../WorkerScreens/worker_screen.dart';
import '../SupplierScreens/supplier_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const HomeContent(),
          BlocProvider.value(
            value: BlocProvider.of<WorkerCubit>(context),
            child: const WorkerScreen(),
          ),
          BlocProvider.value(
            value: BlocProvider.of<SupplierCubit>(context),
            child: const SupplierScreen(),
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isDarkMode, theme),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showUnselectedLabels: true,
          elevation: 0,
          onTap: _onItemTapped,
          items: [
            _buildNavBarItem(
              context,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: "الرئيسية",
              isSelected: _selectedIndex == 0,
            ),
            _buildNavBarItem(
              context,
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: "العمال",
              isSelected: _selectedIndex == 1,
            ),
            _buildNavBarItem(
              context,
              icon: Icons.store_outlined,
              activeIcon: Icons.store,
              label: "المواد",
              isSelected: _selectedIndex == 2,
            ),
            _buildNavBarItem(
              context,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: "الإعدادات",
              isSelected: _selectedIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.primaryColor.withOpacity(0.15) : Colors.transparent,
        ),
        child: Icon(icon, size: 24),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.primaryColor.withOpacity(0.15),
        ),
        child: Icon(activeIcon, size: 24, color: theme.primaryColor),
      ),
      label: label,
    );
  }
}