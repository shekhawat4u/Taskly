import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/debouncer.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/custom_tab_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/task_card.dart';
import 'task_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

final tasksTabProvider = StateProvider<int>((ref) => 0);

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      ref.read(taskSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedFilter = ref.watch(taskFilterStatusProvider);
    final assignedToMe = ref.watch(filteredAssignedToMeTasksProvider);
    final assignedByMe = ref.watch(filteredAssignedByMeTasksProvider);
    final selectedTab = ref.watch(tasksTabProvider);
    final displayedTasks = selectedTab == 0 ? assignedToMe : assignedByMe;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Tasks',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, color: colors.textPrimary),
            color: colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'completed') {
                context.push('/completed-tasks');
              } else if (value == 'clear_filters') {
                ref.read(taskFilterStatusProvider.notifier).state =
                    TaskStatusFilter.all;
                _searchController.clear();
                ref.read(taskSearchQueryProvider.notifier).state = '';
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: colors.textPrimary),
                    const SizedBox(width: 8),
                    const Text('Completed History'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_filters',
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_off_outlined,
                        size: 18, color: colors.textPrimary),
                    const SizedBox(width: 8),
                    const Text('Reset Filters'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Segmented Tabs: "Assigned to me" & "Assigned by me"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomSegmentedTabBar(
                  tabs: const ['Assigned to me', 'Assigned by me'],
                  selectedIndex: selectedTab,
                  onTabSelected: (index) {
                    ref.read(tasksTabProvider.notifier).state = index;
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search tasks',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: colors.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: colors.textMuted,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: 18, color: colors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(taskSearchQueryProvider.notifier)
                                    .state = '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter Chips: All, To Do, In Progress, Due Today, Overdue
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: TaskStatusFilter.values.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterStatusChip(
                        filter: filter,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(taskFilterStatusProvider.notifier).state =
                              filter;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Tasks List
              Expanded(
                child: displayedTasks.isEmpty
                    ? EmptyState(
                        title: 'No tasks found',
                        message: _searchController.text.isNotEmpty
                            ? 'No tasks matching "${_searchController.text}"'
                            : 'No tasks under this filter right now.',
                        icon: Icons.checklist_rtl_rounded,
                        actionText: 'Create new task',
                        onAction: () => context.push('/create-task'),
                      )
                    : RefreshIndicator(
                        color: colors.accent,
                        onRefresh: () async {
                          ref.read(taskStateRevisionProvider.notifier).state++;
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                          itemCount: displayedTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayedTasks[index];
                            return TaskCard(
                              task: task,
                              showAssignerInsteadOfAssignee: selectedTab == 1,
                              onTap: () =>
                                  context.push('/task-details/${task.id}'),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),

          // Floating + Button in bottom right
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingCreateFab(
              onPressed: () => context.push('/create-task'),
            ),
          ),
        ],
      ),
    );
  }
}
