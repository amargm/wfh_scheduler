import 'package:flutter/material.dart';
import '../presentation/preferences_setup_screen/preferences_setup_screen.dart';
import '../presentation/home_dashboard_screen/home_dashboard_screen.dart';
import '../presentation/calendar_sync_screen/calendar_sync_screen.dart';
import '../presentation/schedule_optimization_screen/schedule_optimization_screen.dart';

class AppRoutes {
  static const String initial = '/preferences-setup-screen';
  static const String preferencesSetupScreen = '/preferences-setup-screen';
  static const String homeDashboardScreen = '/home-dashboard-screen';
  static const String scheduleOptimizationScreen = '/schedule-optimization-screen';
  static const String calendarSyncScreen = '/calendar-sync-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const PreferencesSetupScreen(),
    preferencesSetupScreen: (context) => const PreferencesSetupScreen(),
    homeDashboardScreen: (context) => const HomeDashboardScreen(),
    scheduleOptimizationScreen: (context) => const ScheduleOptimizationScreen(),
    calendarSyncScreen: (context) => const CalendarSyncScreen(),
  };
}