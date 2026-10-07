import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/task_status.dart';
import '../../tasks/presentation/task_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import 'team_provider.dart';

class TeamMembersScreen extends ConsumerStatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  ConsumerState<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends ConsumerState<TeamMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final teamMembers = ref.watch(teamMembersProvider);
    final allTasks = ref.watch(allTasksProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final canManage = currentUser?.role.canManageUsers == true;

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
          'Team Members',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: colors.accent, size: 24),
            onPressed: () {
              _showAddMemberDialog(context, ref, colors);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  ref.read(teamSearchQueryProvider.notifier).state = query;
                },
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search members',
                  hintStyle:
                      TextStyle(fontSize: 13, color: colors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 19, color: colors.textMuted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Member List with Lightweight Dividers
          Expanded(
            child: teamMembers.isEmpty
                ? const EmptyState(
                    title: 'No members found',
                    message: 'Try a different search query.',
                    icon: Icons.person_search_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: teamMembers.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: colors.border, height: 1),
                    itemBuilder: (context, index) {
                      final member = teamMembers[index];
                      final activeCount = allTasks.where((t) => t.assignedToIds.contains(member.id) && t.status != TaskStatus.completed).length;

                      return InkWell(
                        onTap: () {
                          // Quick option to assign task
                          context.push('/create-task');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              UserAvatar(
                                name: member.name,
                                avatarUrl: member.avatarUrl,
                                size: 42,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.role.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.todoBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$activeCount tasks',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                              if (canManage && member.id != currentUser?.id)
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert_rounded, color: colors.textMuted, size: 20),
                                  color: colors.surface,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showEditMemberDialog(context, ref, colors, member);
                                    } else if (val == 'delete') {
                                      ref.read(teamProvider).deleteMember(member.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${member.name} removed from team.'),
                                          backgroundColor: colors.error,
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                                          const SizedBox(width: 8),
                                          const Text('Edit Details'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_remove_outlined, size: 18, color: colors.error),
                                          const SizedBox(width: 8),
                                          Text('Remove Member', style: TextStyle(color: colors.error)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref, AppColors colors) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    UserRole selectedRole = UserRole.employee;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: colors.surface,
            title: Text(
              'Add New Member',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Name',
                    hintText: 'Full Name',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'user@company.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: passController,
                    labelText: 'Password',
                    hintText: '••••••••',
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: selectedRole,
                        isExpanded: true,
                        dropdownColor: colors.surface,
                        icon: Icon(Icons.keyboard_arrow_down, color: colors.textMuted),
                        items: UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.label,
                                style: TextStyle(color: colors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.textMuted),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty || emailController.text.isEmpty) return;
                  ref.read(teamProvider).addMember(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        role: selectedRole,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text} added to team!'),
                      backgroundColor: colors.accent,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditMemberDialog(BuildContext context, WidgetRef ref, AppColors colors, UserProfile member) {
    final nameController = TextEditingController(text: member.name);
    final emailController = TextEditingController(text: member.email);
    UserRole selectedRole = member.role;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: colors.surface,
            title: Text(
              'Edit Member',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Name',
                    hintText: 'Full Name',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'user@company.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: selectedRole,
                        isExpanded: true,
                        dropdownColor: colors.surface,
                        icon: Icon(Icons.keyboard_arrow_down, color: colors.textMuted),
                        items: UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.label,
                                style: TextStyle(color: colors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.textMuted),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty || emailController.text.isEmpty) return;
                  ref.read(teamProvider).editMember(
                        id: member.id,
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        role: selectedRole,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text} updated successfully.'),
                      backgroundColor: colors.accent,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }
}
