import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/sidebar_nav.dart';
import 'dashboard/dashboard_screen.dart';
import 'menu/menu_screen.dart';
import 'orders/orders_screen.dart';
import 'pos/pos_screen.dart';
import 'reports/reports_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavItem _selectedNav = NavItem.pos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadDashboard();
    });
  }

  Widget _buildCurrentScreen() {
    switch (_selectedNav) {
      case NavItem.dashboard:
        return const DashboardScreen();
      case NavItem.pos:
        return const PosScreen();
      case NavItem.menu:
        return const MenuScreen();
      case NavItem.orders:
        return const OrdersScreen();
      case NavItem.reports:
        return const ReportsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMobile)
            SidebarNav(
              selected: _selectedNav,
              onSelect: (nav) => setState(() => _selectedNav = nav),
            ),
          Expanded(
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey(_selectedNav),
                  child: _buildCurrentScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<AuthProvider>().logout();
          context.go('/');
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Keluar Admin'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedNav.index,
              onTap: (index) => setState(() => _selectedNav = NavItem.values[index]),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
              items: NavItem.values
                  .map((item) => BottomNavigationBarItem(
                        icon: Icon(item.icon, size: 20),
                        label: item.label,
                      ))
                  .toList(),
            )
          : null,
    );
  }
}
