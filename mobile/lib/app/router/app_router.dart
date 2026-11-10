import 'package:go_router/go_router.dart';

import '../../features/guide/presentation/screens/guide_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/result/presentation/screens/result_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import 'app_routes.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.scan,
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.result,
      builder: (context, state) => const ResultScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.guide,
      builder: (context, state) => const GuideScreen(),
    ),
  ],
);
