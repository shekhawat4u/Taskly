class OrganizationSettings {
  const OrganizationSettings({
    required this.organizationId,
    required this.completedTaskRetentionDays,
  });

  final String organizationId;
  final int completedTaskRetentionDays;

  factory OrganizationSettings.fromMap(Map<String, dynamic> map) {
    return OrganizationSettings(
      organizationId: map['organization_id'] as String,
      completedTaskRetentionDays:
          (map['completed_task_retention_days'] as num?)?.toInt() ?? 180,
    );
  }
}

class HomeStats {
  const HomeStats({
    required this.assignedToMe,
    required this.dueToday,
    required this.inProgress,
    required this.completedThisWeek,
  });

  final int assignedToMe;
  final int dueToday;
  final int inProgress;
  final int completedThisWeek;
}
