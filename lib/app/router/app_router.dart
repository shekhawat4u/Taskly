import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/admin_panel_screen.dart';
import '../../features/admin/presentation/analytics_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/design_system/presentation/design_system_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_dashboard_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/tasks/presentation/completed_tasks_screen.dart';
import '../../features/tasks/presentation/create_task_screen.dart';
import '../../features/tasks/presentation/task_details_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/team/presentation/team_members_screen.dart';
import 'main_navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
          ],
        ),
        // Tab 1: Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),
        // Tab 2: Calendar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        // Tab 3: Notifications
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Standalone / Modal routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/create-task',
      builder: (context, state) => const CreateTaskScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/task-details/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id'] ?? '';
        return TaskDetailsScreen(taskId: taskId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/completed-tasks',
      builder: (context, state) => const CompletedTasksScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/team',
      builder: (context, state) => const TeamMembersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin',
      builder: (context, state) => const AdminPanelScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/design-system',
      builder: (context, state) => const DesignSystemScreen(),
    ),
  ],
);
