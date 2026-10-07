import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../shared/models/task_status.dart';
import '../../../shared/widgets/completion_bottom_sheet.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/priority_badge.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/presentation/auth_provider.dart';
import 'task_provider.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  void _onCompletePressed(BuildContext context, WidgetRef ref, String title) {
    CompletionBottomSheet.show(
      context,
      taskTitle: title,
      onConfirm: () {
        ref.read(taskNotifierProvider).markCompleted(taskId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task marked as completed! Moved to History.'),
            backgroundColor: context.colors.success,
          ),
        );
      },
    );
  }

  void _onStartPressed(BuildContext context, WidgetRef ref) {
    ref.read(taskNotifierProvider).markStarted(taskId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task started! Status updated to In Progress.'),
        backgroundColor: context.colors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final task = ref.watch(taskDetailProvider(taskId));
    final activities = ref.watch(taskActivitiesProvider(taskId));

    if (task == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          title: const Text('Task Details'),
        ),
        body: const Center(child: Text('Task not found')),
      );
    }

    final isCompleted = task.status == TaskStatus.completed;
    final isTodo = task.status == TaskStatus.todo;
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final canDelete = currentUser?.id == task.assignedById;

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
          'Task Details',
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task link copied: ${task.title}'),
                    backgroundColor: colors.accent,
                  ),
                );
              } else if (val == 'delete') {
                ref.read(taskNotifierProvider).deleteTask(taskId);
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task deleted.'),
                    backgroundColor: colors.error,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined,
                        size: 18, color: colors.textPrimary),
                    const SizedBox(width: 8),
                    const Text('Share Task'),
                  ],
                ),
              ),
              if (canDelete)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: colors.error),
                      const SizedBox(width: 8),
                      Text('Delete Task',
                          style: TextStyle(color: colors.error)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom + 8
              : 20,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border, width: 1)),
        ),
        child: isCompleted
            ? CustomButton(
                text: 'Completed 🎉',
                variant: ButtonVariant.secondary,
                onPressed: () {},
              )
            : isTodo
                ? CustomButton(
                    text: 'Start Task',
                    variant: ButtonVariant.primary,
                    onPressed: () => _onStartPressed(context, ref),
                  )
                : CustomButton(
                    text: 'Mark as Completed',
                    variant: ButtonVariant.primary,
                    onPressed: () =>
                        _onCompletePressed(context, ref, task.title),
                  ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Text(
              task.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            StatusChip(status: task.status),

            const SizedBox(height: 24),

            // Assigned By & Assigned To Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                children: [
                  // Assigned By
                  Row(
                    children: [
                      UserAvatar(
                        name: task.assignedBy?.name ?? 'Assigner',
                        avatarUrl: task.assignedBy?.avatarUrl,
                        size: 38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned By',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              task.assignedBy?.name ?? 'Rahul Mehta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.todoBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.assignedBy?.role.label ?? 'Co-founder',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: colors.border, thickness: 0.8),
                  ),
                  // Assigned To
                  Text(
                    'Assigned To',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (task.assignedTo.isEmpty)
                    const Text('No assignees')
                  else
                    ...task.assignedTo.map((assignee) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              UserAvatar(
                                name: assignee.name,
                                avatarUrl: assignee.avatarUrl,
                                size: 38,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      assignee.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.todoBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  assignee.role.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Task Information Section
            Text(
              'Task Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Due Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        task.dueDate != null
                            ? '${DateFormat('d MMM yyyy').format(task.dueDate!)} — ${task.dueDate!.shortDate}'
                            : 'No due date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: colors.border, thickness: 0.8),
                  ),

                  // Priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      PriorityBadge(
                        priority: task.priority,
                        showLabel: true,
                        dotSize: 7,
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: colors.border, thickness: 0.8),
                  ),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description ?? 'No description provided.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subtasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final ctrl = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: colors.surface,
                        title: const Text('Add Subtask'),
                        content: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(hintText: 'Subtask title'),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (ctrl.text.trim().isNotEmpty) {
                                ref
                                    .read(taskNotifierProvider)
                                    .addSubtask(task.id, ctrl.text.trim());
                              }
                              Navigator.pop(ctx);
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.add_circle_outline, color: colors.accent),
                ),
              ],
            ),
            if (task.subtasks.isEmpty)
              Text(
                'No subtasks yet.',
                style: TextStyle(color: colors.textMuted, fontSize: 14),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: task.subtasks.map((sub) {
                    return Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: sub.isCompleted,
                        title: Text(
                          sub.title,
                          style: TextStyle(
                            decoration: sub.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: sub.isCompleted
                                ? colors.textMuted
                                : colors.textPrimary,
                          ),
                        ),
                        activeColor: colors.success,
                        checkColor: colors.surface,
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: colors.error,
                          onPressed: () {
                            ref
                                .read(taskNotifierProvider)
                                .deleteSubtask(task.id, sub.id);
                          },
                        ),
                        onChanged: (val) {
                          ref
                              .read(taskNotifierProvider)
                              .toggleSubtask(task.id, sub.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Attachments Section
            if (task.attachmentName != null || task.localAttachmentPath != null || task.attachmentBase64 != null) ...[
              Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      (task.attachmentName ?? task.localAttachmentPath ?? '').toLowerCase().endsWith('.pdf')
                          ? Icons.picture_as_pdf_outlined
                          : Icons.insert_drive_file_outlined,
                      size: 20,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.attachmentName ??
                            task.localAttachmentPath?.split('/').last ??
                            'Attachment',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.download_rounded,
                          size: 20, color: colors.textPrimary),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 20),
                                Text("Downloading..."),
                              ],
                            ),
                          ),
                        );

                        try {
                          String? targetPath = task.localAttachmentPath;
                          bool fileExists = targetPath != null && await File(targetPath).exists();

                          if (!fileExists && task.attachmentBase64 != null) {
                            // Decode base64 and save locally on this device
                            final directory = await getApplicationDocumentsDirectory();
                            final fileName = task.attachmentName ?? 'attachment_${task.id.substring(0, 5)}';
                            final file = File('${directory.path}/$fileName');
                            final bytes = base64Decode(task.attachmentBase64!);
                            await file.writeAsBytes(bytes);
                            targetPath = file.path;
                            fileExists = true;
                          }

                          await Future.delayed(const Duration(milliseconds: 600));

                          if (context.mounted) Navigator.pop(context); // Close loading dialog

                          if (fileExists && targetPath != null) {
                            final result = await OpenFile.open(targetPath);
                            if (result.type != ResultType.done && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open file: ${result.message}'),
                                  backgroundColor: colors.error,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('File content is not available in cloud or local storage.'),
                                  backgroundColor: colors.error,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error opening file: $e'),
                                backgroundColor: colors.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Activity Timeline Section
            Text(
              'Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Column(
                children: [
                  if (activities.isEmpty)
                    const Text('No activity yet.', style: TextStyle(color: Colors.grey)),
                  for (int i = 0; i < activities.length; i++)
                    _ActivityTimelineItem(
                      title: '${activities[i].userName ?? 'Someone'} ${activities[i].action}',
                      time: activities[i].createdAt.dateTimeLabel,
                      isFirst: i == 0,
                      isLast: i == activities.length - 1,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Comments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final ctrl = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: colors.surface,
                        title: const Text('Add Comment'),
                        content: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                            hintText: 'Type a comment...',
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (ctrl.text.trim().isNotEmpty) {
                                ref
                                    .read(taskNotifierProvider)
                                    .addComment(task.id, ctrl.text.trim());
                              }
                              Navigator.pop(ctx);
                            },
                            child: const Text('Post'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.add_comment_outlined, color: colors.accent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (task.comments.isEmpty)
              Text(
                'No comments yet.',
                style: TextStyle(color: colors.textMuted, fontSize: 14),
              )
            else
              Column(
                children: task.comments.map((comment) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  comment.createdAt.dateTimeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(taskNotifierProvider)
                                        .deleteComment(task.id, comment.id);
                                  },
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: colors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          comment.text,
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ActivityTimelineItem extends StatelessWidget {
  const _ActivityTimelineItem({
    required this.title,
    required this.time,
    required this.isFirst,
    required this.isLast,
  });

  final String title;
  final String time;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 28,
                color: colors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
