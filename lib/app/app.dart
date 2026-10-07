import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import '../features/tasks/presentation/task_provider.dart';

class TasklyApp extends ConsumerStatefulWidget {
  const TasklyApp({super.key});

  @override
  ConsumerState<TasklyApp> createState() => _TasklyAppState();
}

class _TasklyAppState extends ConsumerState<TasklyApp> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        if (receivedAction.payload != null) {
          final actionType = receivedAction.payload!['action_type'];
          final taskId = receivedAction.payload!['task_id'];
          if (actionType == 'task_assigned' && taskId != null) {
            // Mark task as completed
            ref.read(taskNotifierProvider).markCompleted(taskId);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Taskly',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
