import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/customer/customer_main_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isAuth = auth.isAuthenticated;
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
      
      if (isGoingToAdmin && !isAuth && state.matchedLocation != '/admin/login') {
        return '/admin/login';
      }

      if (isAuth && state.matchedLocation == '/admin/login') {
        return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CustomerMainScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const MainScreen(), // Refactored to act as Admin Layout
      ),
    ],
  );
}
