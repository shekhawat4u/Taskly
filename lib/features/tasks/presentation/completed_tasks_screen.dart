import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/completed_task_card.dart';
import '../../../shared/widgets/custom_tab_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import 'task_provider.dart';

class CompletedTasksScreen extends ConsumerStatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  ConsumerState<CompletedTasksScreen> createState() =>
      _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends ConsumerState<CompletedTasksScreen> {
  int _selectedTab = 0; // 0 = Completed by me, 1 = Assigned by me

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final completedByMe = ref.watch(completedByMeTasksProvider);
    final completedAssignedByMe =
        ref.watch(completedAssignedByMeTasksProvider);
    final displayedTasks =
        _selectedTab == 0 ? completedByMe : completedAssignedByMe;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Completed Tasks',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, size: 20, color: colors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tabs: Completed by me / Assigned by me
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomSegmentedTabBar(
              tabs: const ['Completed by me', 'Assigned by me'],
              selectedIndex: _selectedTab,
              onTabSelected: (index) {
                setState(() => _selectedTab = index);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Completed Task Cards List
          Expanded(
            child: displayedTasks.isEmpty
                ? const EmptyState(
                    title: 'No completed tasks yet',
                    message: 'Tasks you complete will appear here in history.',
                    icon: Icons.done_all_rounded,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      return CompletedTaskCard(
                        task: task,
                        onTap: () =>
                            context.push('/task-details/${task.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
