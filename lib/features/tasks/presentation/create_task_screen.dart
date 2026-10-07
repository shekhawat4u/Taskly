import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/task_priority.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_dropdown.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../team/presentation/team_provider.dart';
import 'task_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<UserProfile> _selectedAssignees = [];
  DateTime? _selectedDueDate;
  TaskPriority _selectedPriority = TaskPriority.high;
  String? _attachmentName;
  String? _attachmentPath;
  String? _attachmentBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDueDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickAssignee(List<UserProfile> team) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assign to Teammates',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Done'),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    ...team.map((member) {
                      final isSelected = _selectedAssignees.any((m) => m.id == member.id);
                      return ListTile(
                        leading: UserAvatar(name: member.name, size: 36),
                        title: Text(
                          member.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          member.role.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                _selectedAssignees.add(member);
                              } else {
                                _selectedAssignees.removeWhere((m) => m.id == member.id);
                              }
                            });
                            setState(() {});
                          },
                        ),
                        onTap: () {
                            setModalState(() {
                              if (!isSelected) {
                                _selectedAssignees.add(member);
                              } else {
                                _selectedAssignees.removeWhere((m) => m.id == member.id);
                              }
                            });
                            setState(() {});
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now.add(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        final name = result.files.single.name;
        if (path != null) {
          final file = File(path);
          final bytes = await file.readAsBytes();
          final base64Str = base64Encode(bytes);
          final directory = await getApplicationDocumentsDirectory();
          final savedImage = file.copySync('${directory.path}/$name');
          setState(() {
            _attachmentPath = savedImage.path;
            _attachmentName = name;
            _attachmentBase64 = base64Str;
          });
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  void _submitTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final team = ref.read(teamMembersProvider);
      
      // Default to first member if none selected
      if (_selectedAssignees.isEmpty && team.isNotEmpty) {
        _selectedAssignees.add(team.first);
      }

      setState(() => _isLoading = true);

      ref.read(taskNotifierProvider).createTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            assignedToIds: _selectedAssignees.map((a) => a.id).toList(),
            priority: _selectedPriority,
            dueDate: _selectedDueDate,
            attachmentName: _attachmentName,
            attachmentBase64: _attachmentBase64,
            localAttachmentPath: _attachmentPath,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task assigned to ${_selectedAssignees.length} teammate(s)!'),
          backgroundColor: context.colors.accent,
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final team = ref.watch(teamMembersProvider);

    if (_selectedAssignees.isEmpty && team.isNotEmpty) {
      _selectedAssignees.add(team.firstWhere(
        (m) => m.name.contains('Riya'),
        orElse: () => team.first,
      ));
    }

    String dueDateString = 'Select due date';
    if (_selectedDueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(
          _selectedDueDate!.year, _selectedDueDate!.month, _selectedDueDate!.day);

      if (target == today.add(const Duration(days: 1))) {
        dueDateString = 'Tomorrow, ${DateFormat('d MMM').format(_selectedDueDate!)}';
      } else if (target == today) {
        dueDateString = 'Today, ${DateFormat('d MMM').format(_selectedDueDate!)}';
      } else {
        dueDateString = DateFormat('EEE, d MMM yyyy').format(_selectedDueDate!);
      }
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Task',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded, color: colors.accent, size: 26),
            onPressed: _submitTask,
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
        child: CustomButton(
          text: 'Assign Task',
          isLoading: _isLoading,
          onPressed: _submitTask,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              CustomTextField(
                controller: _titleController,
                labelText: 'Task Title *',
                hintText: 'e.g. Prepare investor deck',
                validator: Validators.requiredTitle,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 20),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Add context, subtasks, or key deliverables...',
                maxLines: 4,
                minLines: 3,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 20),

              // Assign To
              Text(
                'Assign To *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: Row(
                  children: [
                    if (_selectedAssignees.length == 1)
                      UserAvatar(
                        name: _selectedAssignees.first.name,
                        size: 36,
                      )
                    else if (_selectedAssignees.length > 1)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '+${_selectedAssignees.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      const UserAvatar(name: 'User', size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAssignees.isEmpty
                                ? 'Select teammate'
                                : _selectedAssignees.length == 1
                                    ? _selectedAssignees.first.name
                                    : '${_selectedAssignees.length} teammates selected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedAssignees.isEmpty
                                ? ''
                                : _selectedAssignees.length == 1
                                    ? _selectedAssignees.first.role.label
                                    : _selectedAssignees.map((e) => e.name.split(' ').first).join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _pickAssignee(team),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Due Date
              Text(
                'Due Date *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dueDateString,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Priority Dropdown
              PriorityDropdown(
                labelText: 'Priority',
                value: _selectedPriority,
                onChanged: (p) => setState(() => _selectedPriority = p),
              ),

              const SizedBox(height: 20),

              // Attachment
              Text(
                'Attachment',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              if (_attachmentName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined,
                          size: 20, color: colors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _attachmentName!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 18, color: colors.textMuted),
                        onPressed: () => setState(() {
                          _attachmentName = null;
                          _attachmentPath = null;
                          _attachmentBase64 = null;
                        }),
                      ),
                    ],
                  ),
                )
              else
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusInput),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file_rounded,
                            size: 18, color: colors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Add file',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
