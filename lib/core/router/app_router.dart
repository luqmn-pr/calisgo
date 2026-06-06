import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/landing/presentation/landing_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/membaca/presentation/membaca_screen.dart';
import '../../features/menulis/presentation/menulis_screen.dart';
import '../../features/berhitung/presentation/berhitung_screen.dart';
import '../../features/competitive/presentation/competitive_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    // App dimulai dari Splash Screen
    initialLocation: '/splash',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
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
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
}
