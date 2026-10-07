class TaskAttachment {
  const TaskAttachment({
    required this.id,
    required this.taskId,
    required this.uploadedBy,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String uploadedBy;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int fileSize;
  final DateTime createdAt;

  factory TaskAttachment.fromMap(Map<String, dynamic> map) {
    return TaskAttachment(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      uploadedBy: map['uploaded_by'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      mimeType: map['mime_type'] as String,
      fileSize: (map['file_size'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'uploaded_by': uploadedBy,
      'file_name': fileName,
      'file_path': filePath,
      'mime_type': mimeType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
