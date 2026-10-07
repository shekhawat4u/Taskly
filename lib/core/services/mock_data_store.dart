import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/app_notification.dart';
import '../../shared/models/notification_type.dart';
import '../../shared/models/organization.dart';
import '../../shared/models/organization_settings.dart';
import '../../shared/models/task_activity.dart';
import '../../shared/models/task_attachment.dart';
import '../../shared/models/task_item.dart';
import '../../shared/models/task_priority.dart';
import '../../shared/models/task_status.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/user_role.dart';
import '../../shared/models/subtask.dart';
import '../../shared/models/task_comment.dart';

class MockDataStore {
  MockDataStore._() {
    _init();
  }

  static final MockDataStore instance = MockDataStore._();
  static const _uuid = Uuid();

  // Organization
  static const String orgId = 'org-taskly-labs-001';
  late Organization organization;
  late OrganizationSettings organizationSettings;

  // Users
  late UserProfile anuragAdmin;
  late UserProfile anuragFounder;
  late UserProfile anuragIntern;
  late List<UserProfile> users;

  // Active Session User
  late UserProfile currentUser;

  // Tasks, Activities, Attachments, Notifications
  List<TaskItem> tasks = [];
  List<TaskActivity> activities = [];
  List<TaskAttachment> attachments = [];
  List<AppNotification> notifications = [];

  void _init() {
    organization = const Organization(
      id: orgId,
      name: 'Deep Basics',
      logoUrl: null,
    );

    organizationSettings = const OrganizationSettings(
      organizationId: orgId,
      completedTaskRetentionDays: 180,
    );

    users = [
      const UserProfile(
        id: 'usr-harsh-admin-v2',
        organizationId: orgId,
        name: 'Harsh',
        email: 'harsh@deepbasics.in',
        role: UserRole.admin,
        password: 'Ks@210109',
        avatarUrl: null,
        activeTaskCount: 0,
      ),
    ];

    currentUser = users.first; // Set Admin as default active user

    _initInitialData();
  }

  void _initInitialData() {
    tasks = [];
    activities = [];
    attachments = [];
    notifications = [];
  }

  bool _isFirebaseInitialized = false;

  // Callback for when the current user is deleted or session invalidated from Firestore
  VoidCallback? onCurrentUserDeleted;

  void initFirebaseSync(void Function() onUpdate) {
    if (_isFirebaseInitialized) return;
    _isFirebaseInitialized = true;
    final db = FirebaseFirestore.instance;

    // Sync users from Firestore so all registered members are available
    db.collection('users').snapshots().listen((snap) {
      if (snap.docs.isNotEmpty) {
        users = snap.docs.map((d) => UserProfile.fromMap(d.data())).toList();
        // Check if current user was deleted or password changed
        final updated = users.where((u) => u.id == currentUser.id);
        if (updated.isNotEmpty) {
          final newProfile = updated.first;
          if (currentUser.password != null &&
              newProfile.password != null &&
              currentUser.password != newProfile.password) {
            // Password changed remotely - log out immediately
            onCurrentUserDeleted?.call();
            return;
          }
          currentUser = newProfile;
        } else {
          // Current user was deleted — trigger logout
          onCurrentUserDeleted?.call();
        }
      } else {
        // All users deleted
        onCurrentUserDeleted?.call();
      }
      onUpdate();
    });

    db.collection('tasks').snapshots().listen((snap) {
      tasks = snap.docs.map((d) => TaskItem.fromMap(d.data())).toList();
      onUpdate();
    });
    db.collection('activities').snapshots().listen((snap) {
      activities = snap.docs.map((d) => TaskActivity.fromMap(d.data())).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      onUpdate();
    });
    db.collection('attachments').snapshots().listen((snap) {
      attachments = snap.docs.map((d) => TaskAttachment.fromMap(d.data())).toList();
      onUpdate();
    });
    db.collection('notifications').snapshots().listen((snap) {
      notifications = snap.docs.map((d) => AppNotification.fromMap(d.data())).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      onUpdate();
    });
  }

  // Switch Active User (For instant demo switching)
  void switchUser(UserProfile user) {
    currentUser = user;
  }

  void addMember({
    required String name,
    required String email,
    required UserRole role,
  }) {
    final newUser = UserProfile(
      id: 'usr-${_uuid.v4().substring(0, 8)}',
      organizationId: orgId,
      name: name,
      email: email.trim().toLowerCase(),
      role: role,
      avatarUrl: null,
      activeTaskCount: 0,
    );
    users.add(newUser);
    // Sync to Firestore
    FirebaseFirestore.instance.collection('users').doc(newUser.id).set(newUser.toMap());
  }

  void editMember({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) {
    final idx = users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      final updatedUser = UserProfile(
        id: id,
        organizationId: orgId,
        name: name,
        email: email,
        role: role,
        avatarUrl: users[idx].avatarUrl,
        activeTaskCount: users[idx].activeTaskCount,
      );
      users[idx] = updatedUser;
      FirebaseFirestore.instance.collection('users').doc(id).set(updatedUser.toMap());
    }
  }

  void deleteMember(String id) {
    users.removeWhere((u) => u.id == id);
    FirebaseFirestore.instance.collection('users').doc(id).delete();
  }

  void _sendNotificationIfDifferentUser({
    required TaskItem task,
    required NotificationType type,
    required String title,
    required String message,
  }) {
    // Notify all assignees if the current user is the assigner
    // If the current user is an assignee, notify the assigner
    final targetUserIds = <String>{};
    if (currentUser.id == task.assignedById) {
      targetUserIds.addAll(task.assignedToIds);
    } else {
      targetUserIds.add(task.assignedById);
    }

    targetUserIds.remove(currentUser.id); // Don't notify self

    for (final targetUserId in targetUserIds) {
      final notif = AppNotification(
        id: 'notif-${_uuid.v4().substring(0, 8)}',
        organizationId: orgId,
        userId: targetUserId,
        taskId: task.id,
        type: type,
        title: title,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
      );
      FirebaseFirestore.instance.collection('notifications').doc(notif.id).set(notif.toMap());
    }
  }

  TaskItem createTask({
    required String title,
    String? description,
    required List<String> assignedToIds,
    required TaskPriority priority,
    DateTime? dueDate,
    String? attachmentName,
    String? attachmentBase64,
    String? localAttachmentPath,
  }) {
    final assignedToUsers = users.where((u) => assignedToIds.contains(u.id)).toList();

    final newTask = TaskItem(
      id: 'tsk-${_uuid.v4().substring(0, 8)}',
      organizationId: orgId,
      title: title,
      description: description,
      assignedById: currentUser.id,
      assignedToIds: assignedToIds,
      status: TaskStatus.todo,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      assignedBy: currentUser,
      assignedTo: assignedToUsers,
      localAttachmentPath: localAttachmentPath,
      attachmentName: attachmentName,
      attachmentBase64: attachmentBase64,
    );

    final db = FirebaseFirestore.instance;
    db.collection('tasks').doc(newTask.id).set(newTask.toMap());

    // Record creation activity
    final act = TaskActivity(
      id: 'act-${_uuid.v4().substring(0, 8)}',
      organizationId: orgId,
      taskId: newTask.id,
      userId: currentUser.id,
      action: 'task_created',
      createdAt: DateTime.now(),
      userName: currentUser.name,
    );
    db.collection('activities').doc(act.id).set(act.toMap());

    // Add notification for assignees
    for (var assigneeId in assignedToIds) {
      if (assigneeId != currentUser.id) {
        final notif = AppNotification(
          id: 'notif-${_uuid.v4().substring(0, 8)}',
          organizationId: orgId,
          userId: assigneeId,
          taskId: newTask.id,
          type: NotificationType.taskAssigned,
          title: 'New task assigned',
          message: '${currentUser.name} assigned you ${newTask.title}',
          isRead: false,
          createdAt: DateTime.now(),
        );
        db.collection('notifications').doc(notif.id).set(notif.toMap());
      }
    }

    return newTask;
  }

  Future<void> addSubtask(String taskId, String title) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final existing = tasks[index];
    final newSubtask = Subtask(
      id: 'sub-${_uuid.v4().substring(0, 8)}',
      title: title,
    );
    
    final updatedSubtasks = List<Subtask>.from(existing.subtasks)..add(newSubtask);
    
    tasks[index] = existing.copyWith(subtasks: updatedSubtasks);
    
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'subtasks': updatedSubtasks.map((e) => e.toMap()).toList(),
    });
    
    _sendNotificationIfDifferentUser(
      task: existing,
      type: NotificationType.taskUpdated,
      title: 'Task updated',
      message: '${currentUser.name} added a subtask: $title',
    );
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final existing = tasks[index];
    final subtaskIndex = existing.subtasks.indexWhere((s) => s.id == subtaskId);
    if (subtaskIndex == -1) return;

    final subtask = existing.subtasks[subtaskIndex];
    final updatedSubtask = subtask.copyWith(isCompleted: !subtask.isCompleted);
    
    final updatedSubtasks = List<Subtask>.from(existing.subtasks);
    updatedSubtasks[subtaskIndex] = updatedSubtask;
    
    tasks[index] = existing.copyWith(subtasks: updatedSubtasks);
    
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'subtasks': updatedSubtasks.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final existing = tasks[index];
    final updatedSubtasks = List<Subtask>.from(existing.subtasks)
      ..removeWhere((s) => s.id == subtaskId);
    
    tasks[index] = existing.copyWith(subtasks: updatedSubtasks);
    
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'subtasks': updatedSubtasks.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> addComment(String taskId, String text) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final existing = tasks[index];
    final newComment = TaskComment(
      id: 'cmt-${_uuid.v4().substring(0, 8)}',
      taskId: taskId,
      userId: currentUser.id,
      userName: currentUser.name,
      text: text,
      createdAt: DateTime.now(),
    );
    
    final updatedComments = List<TaskComment>.from(existing.comments)..add(newComment);
    
    tasks[index] = existing.copyWith(comments: updatedComments);
    
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'comments': updatedComments.map((e) => e.toMap()).toList(),
    });

    _sendNotificationIfDifferentUser(
      task: existing,
      type: NotificationType.taskCommented,
      title: 'New comment',
      message: '${currentUser.name} commented: $text',
    );
  }

  Future<void> deleteComment(String taskId, String commentId) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final existing = tasks[index];
    final updatedComments = List<TaskComment>.from(existing.comments)
      ..removeWhere((c) => c.id == commentId);
    
    tasks[index] = existing.copyWith(comments: updatedComments);
    
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'comments': updatedComments.map((e) => e.toMap()).toList(),
    });
  }

  TaskItem? markTaskCompleted(String taskId) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;

    final existing = tasks[index];
    final updated = existing.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );

    tasks[index] = updated;
    final db = FirebaseFirestore.instance;
    db.collection('tasks').doc(updated.id).update({
      'status': 'completed',
      'completed_at': updated.completedAt?.toIso8601String(),
    });

    // Record activity
    final act = TaskActivity(
      id: 'act-${_uuid.v4().substring(0, 8)}',
      organizationId: orgId,
      taskId: existing.id,
      userId: currentUser.id,
      action: 'task_completed',
      createdAt: DateTime.now(),
      userName: currentUser.name,
    );
    activities.insert(0, act);
    db.collection('activities').doc(act.id).set(act.toMap());

    _sendNotificationIfDifferentUser(
      task: existing,
      type: NotificationType.taskCompleted,
      title: 'Task completed',
      message: '${currentUser.name} completed: ${existing.title}',
    );

    return updated;
  }

  TaskItem? markTaskStarted(String taskId) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return null;

    final existing = tasks[index];
    final updated = existing.copyWith(
      status: TaskStatus.inProgress,
      startedAt: DateTime.now(),
    );

    tasks[index] = updated;
    final db = FirebaseFirestore.instance;
    db.collection('tasks').doc(updated.id).update({
      'status': 'in_progress',
      'started_at': updated.startedAt?.toIso8601String(),
    });

    final act = TaskActivity(
      id: 'act-${_uuid.v4().substring(0, 8)}',
      organizationId: orgId,
      taskId: taskId,
      userId: currentUser.id,
      action: 'task_started',
      createdAt: DateTime.now(),
      userName: currentUser.name,
    );
    activities.insert(0, act);
    db.collection('activities').doc(act.id).set(act.toMap());

    if (existing.assignedById != currentUser.id) {
      final notif = AppNotification(
        id: 'notif-${_uuid.v4().substring(0, 8)}',
        organizationId: orgId,
        userId: existing.assignedById,
        taskId: taskId,
        type: NotificationType.taskStarted,
        title: 'Task started',
        message: '${currentUser.name} started working on ${existing.title}',
        isRead: false,
        createdAt: DateTime.now(),
      );
      notifications.insert(0, notif);
      db.collection('notifications').doc(notif.id).set(notif.toMap());
    }

    return updated;
  }

  void deleteTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
    FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }

  void markAllNotificationsAsRead() {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    for (final n in notifications) {
      if (!n.isRead) {
        batch.update(db.collection('notifications').doc(n.id), {'is_read': true});
      }
    }
    batch.commit();
    
    notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
    notifications.removeWhere((n) => n.id == notificationId);
  }

  HomeStats computeStatsForUser(String userId) {
    final assignedToMeList = tasks
        .where((t) => t.assignedToIds.contains(userId) && t.status != TaskStatus.completed)
        .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueToday = assignedToMeList.where((t) {
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due == today;
    }).length;

    final inProgress =
        assignedToMeList.where((t) => t.status == TaskStatus.inProgress).length;

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final completedThisWeek = tasks.where((t) {
      if (t.completedAt == null) return false;
      return (t.assignedToIds.contains(userId) || t.completedById == userId) &&
          t.completedAt!.isAfter(startOfWeek);
    }).length;

    return HomeStats(
      assignedToMe: assignedToMeList.length,
      dueToday: dueToday,
      inProgress: inProgress,
      completedThisWeek: completedThisWeek,
    );
  }
}
