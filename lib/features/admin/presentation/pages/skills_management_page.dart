import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../skills/presentation/providers/skill_provider.dart';
import '../../../skills/presentation/providers/skill_state.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_dialogs.dart';

class SkillsManagementPage extends ConsumerStatefulWidget {
  const SkillsManagementPage({super.key});

  @override
  ConsumerState<SkillsManagementPage> createState() => _SkillsManagementPageState();
}

class _SkillsManagementPageState extends ConsumerState<SkillsManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _categoryController = TextEditingController();
  final _yearsController = TextEditingController();
  
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Load skills when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(skillNotifierProvider.notifier).getSkills();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _categoryController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skillState = ref.watch(skillStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;

    final skills = skillState.skills?['data'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(skillNotifierProvider.notifier).getSkills();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with add button
            _buildHeader(context, isDark, isHindi, skills.length),
            const SizedBox(height: 20),
            // Data Table
            AdminDataTable(
              columns: [
                AdminDataColumn(
                  key: 'name',
                  title: getLocalizedString('name', isHindi ? AppLanguage.hi : AppLanguage.en),
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'category',
                  title: getLocalizedString('category', isHindi ? AppLanguage.hi : AppLanguage.en),
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'level',
                  title: getLocalizedString('level', isHindi ? AppLanguage.hi : AppLanguage.en),
                  sortable: true,
                  cellBuilder: (row) => _buildLevelChip(row['level'] ?? 'Beginner'),
                ),
                AdminDataColumn(
                  key: 'yearsOfExperience',
                  title: getLocalizedString('experience', isHindi ? AppLanguage.hi : AppLanguage.en),
                  sortable: true,
                  cellBuilder: (row) => Text(
                    '${row['yearsOfExperience'] ?? 0} ${getLocalizedString('years', isHindi ? AppLanguage.hi : AppLanguage.en)}',
                  ),
                ),
              ],
              data: skills.cast<Map<String, dynamic>>(),
              isLoading: skillState.status == SkillStatus.loading,
              emptyMessage: getLocalizedString('noSkillsFound', isHindi ? AppLanguage.hi : AppLanguage.en),
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSort: (columnKey, ascending) {
                setState(() {
                  _sortColumnIndex = ['name', 'category', 'level', 'yearsOfExperience'].indexOf(columnKey);
                  _sortAscending = ascending;
                });
              },
              onEdit: (index, row) => _showEditDialog(context, row, isHindi),
              onDelete: (index, row) => _showDeleteDialog(context, row, isHindi),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isHindi, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getLocalizedString('skillsManagement', isHindi ? AppLanguage.hi : AppLanguage.en),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count ${getLocalizedString('skills', isHindi ? AppLanguage.hi : AppLanguage.en)} ${getLocalizedString('skillsFound', isHindi ? AppLanguage.hi : AppLanguage.en)}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () => _showAddDialog(context, isHindi),
          icon: const Icon(Icons.add, size: 20),
          label: Text(getLocalizedString('addSkill', isHindi ? AppLanguage.hi : AppLanguage.en)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChip(String level) {
    final color = _getLevelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'expert':
        return Colors.green;
      case 'advanced':
        return Colors.blue;
      case 'intermediate':
        return Colors.orange;
      case 'beginner':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  void _showAddDialog(BuildContext context, bool isHindi) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: getLocalizedString('addSkill', isHindi ? AppLanguage.hi : AppLanguage.en),
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: getLocalizedString('name', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _nameController,
              hintText: getLocalizedString('nameHint', isHindi ? AppLanguage.hi : AppLanguage.en),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('nameRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: getLocalizedString('category', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              hintText: getLocalizedString('categoryHint', isHindi ? AppLanguage.hi : AppLanguage.en),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('categoryRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: getLocalizedString('level', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminDropdownField<String>(
              value: _levelController.text.isEmpty ? 'Beginner' : _levelController.text,
              hint: getLocalizedString('selectLevel', isHindi ? AppLanguage.hi : AppLanguage.en),
              items: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _levelController.text = value ?? 'Beginner';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('levelRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: getLocalizedString('experienceYears', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _yearsController,
              hintText: '3',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('experienceRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
        ],
        onSave: () => _createSkill(isHindi),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> skill, bool isHindi) {
    _nameController.text = skill['name'] ?? '';
    _categoryController.text = skill['category'] ?? '';
    _levelController.text = skill['level'] ?? 'Beginner';
    _yearsController.text = (skill['yearsOfExperience'] ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: getLocalizedString('editSkill', isHindi ? AppLanguage.hi : AppLanguage.en),
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: getLocalizedString('name', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('nameRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: getLocalizedString('category', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('categoryRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: getLocalizedString('level', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminDropdownField<String>(
              value: _levelController.text,
              items: ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _levelController.text = value ?? 'Beginner';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('levelRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: getLocalizedString('experienceYears', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getLocalizedString('experienceRequired', isHindi ? AppLanguage.hi : AppLanguage.en);
                }
                return null;
              },
            ),
          ),
        ],
        onSave: () => _updateSkill(skill['_id'], isHindi),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> skill, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: getLocalizedString('deleteSkill', isHindi ? AppLanguage.hi : AppLanguage.en),
        message: getLocalizedString('deleteSkillConfirm', isHindi ? AppLanguage.hi : AppLanguage.en),
        itemName: skill['name'] ?? '',
        onConfirm: () => _deleteSkill(skill['_id'], isHindi),
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _categoryController.clear();
    _levelController.text = 'Beginner';
    _yearsController.clear();
  }

  Future<void> _createSkill(bool isHindi) async {
    final data = {
      'name': _nameController.text,
      'category': _categoryController.text,
      'level': _levelController.text,
      'yearsOfExperience': int.tryParse(_yearsController.text) ?? 0,
    };

    await ref.read(skillNotifierProvider.notifier).createSkill(data);
    
    if (mounted) {
      final skillState = ref.read(skillStateProvider);
      if (skillState.status == SkillStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('skillAddFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${skillState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('skillAdded', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateSkill(String id, bool isHindi) async {
    final data = {
      'name': _nameController.text,
      'category': _categoryController.text,
      'level': _levelController.text,
      'yearsOfExperience': int.tryParse(_yearsController.text) ?? 0,
    };

    await ref.read(skillNotifierProvider.notifier).updateSkill(id, data);
    
    if (mounted) {
      final skillState = ref.read(skillStateProvider);
      if (skillState.status == SkillStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('skillUpdateFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${skillState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('skillUpdated', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteSkill(String id, bool isHindi) async {
    await ref.read(skillNotifierProvider.notifier).deleteSkill(id);
    
    if (mounted) {
      final skillState = ref.read(skillStateProvider);
      if (skillState.status == SkillStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('skillDeleteFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${skillState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('skillDeleted', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
