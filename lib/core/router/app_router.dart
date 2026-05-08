import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/membaca/presentation/membaca_screen.dart';
import '../../features/menulis/presentation/menulis_screen.dart';
import '../../features/berhitung/presentation/berhitung_screen.dart';
import '../../features/competitive/presentation/competitive_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/membaca',
        name: 'membaca',
        builder: (context, state) => const MembacaScreen(),
      ),
      GoRoute(
        path: '/menulis',
        name: 'menulis',
        builder: (context, state) => const MenulisScreen(),
      ),
      GoRoute(
        path: '/berhitung',
        name: 'berhitung',
        builder: (context, state) => const BerhitungScreen(),
      ),
      GoRoute(
        path: '/competitive',
        name: 'competitive',
        builder: (context, state) => const CompetitiveScreen(),
      ),
    ],
  );
}
