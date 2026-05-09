import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/widgets/common_text.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final skills = skillState.skills?['data'] as List<dynamic>? ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(skillNotifierProvider.notifier).getSkills();
        },
        child: skills.isEmpty && skillState.status != SkillStatus.loading
            ? Center(
                child: CommonText.medium(
                  l10n.noSkillsFound,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AdminDataTable(
                  columns: [
                    AdminDataColumn(
                      key: 'name',
                      title: l10n.name,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'category',
                      title: l10n.category,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'level',
                      title: l10n.level,
                      sortable: true,
                      cellBuilder: (row) => _buildLevelChip(row['level'] ?? 'Beginner'),
                    ),
                    AdminDataColumn(
                      key: 'yearsOfExperience',
                      title: l10n.experience,
                      sortable: true,
                      cellBuilder: (row) => Text(
                        '${row['yearsOfExperience'] ?? 0} ${l10n.years}',
                      ),
                    ),
                  ],
                  data: skills.cast<Map<String, dynamic>>(),
                  isLoading: skillState.status == SkillStatus.loading,
                  emptyMessage: l10n.noSkillsFound,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: (columnKey, ascending) {
                    setState(() {
                      _sortColumnIndex = ['name', 'category', 'level', 'yearsOfExperience'].indexOf(columnKey);
                      _sortAscending = ascending;
                    });
                  },
                  onEdit: (index, row) => _showEditDialog(context, row, l10n),
                  onDelete: (index, row) => _showDeleteDialog(context, row, l10n),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSkill),
        backgroundColor: AppThemeColors.primary,
      ),
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
      child: CommonText.small(
        level,
        fontWeight: FontWeight.w600,
        color: color,
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

  void _showAddDialog(BuildContext context, AppLocalizations l10n) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: l10n.addSkill,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: l10n.name,
            isRequired: true,
            child: AdminTextField(
              controller: _nameController,
              hintText: l10n.nameHint,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: l10n.category,
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              hintText: l10n.categoryHint,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.categoryRequired;
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: l10n.level,
            isRequired: true,
            child: AdminDropdownField<String>(
              value: _levelController.text.isEmpty ? 'Beginner' : _levelController.text,
              hint: l10n.selectLevel,
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
                  return l10n.levelRequired;
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: l10n.experienceYears,
            isRequired: true,
            child: AdminTextField(
              controller: _yearsController,
              hintText: l10n.experienceYears,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.experienceRequired;
                }
                return null;
              },
            ),
          ),
        ],
        onSave: () => _createSkill(l10n),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> skill, AppLocalizations l10n) {
    _nameController.text = skill['name'] ?? '';
    _categoryController.text = skill['category'] ?? '';
    // Capitalize first letter to match dropdown items
    final level = skill['level'] ?? 'Beginner';
    _levelController.text = level.isNotEmpty ? level[0].toUpperCase() + level.substring(1) : 'Beginner';
    _yearsController.text = (skill['yearsOfExperience'] ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: l10n.editSkill,
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: l10n.name,
            isRequired: true,
            child: AdminTextField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: l10n.category,
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.categoryRequired;
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: l10n.level,
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
                  return l10n.levelRequired;
                }
                return null;
              },
            ),
          ),
          AdminFormField(
            label: l10n.experienceYears,
            isRequired: true,
            child: AdminTextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.experienceRequired;
                }
                return null;
              },
            ),
          ),
        ],
        onSave: () => _updateSkill(skill['_id'], l10n),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> skill, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: l10n.deleteSkill,
        message: l10n.deleteSkillConfirm,
        itemName: skill['name'] ?? '',
        onConfirm: () => _deleteSkill(skill['_id'], l10n),
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _categoryController.clear();
    _levelController.text = 'Beginner';
    _yearsController.clear();
  }

  Future<void> _createSkill(AppLocalizations l10n) async {
    final data = {
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim(),
      'level': _levelController.text.toLowerCase().trim(),
      'yearsOfExperience': int.tryParse(_yearsController.text) ?? 0,
    };

    await ref.read(skillNotifierProvider.notifier).createSkill(data);
    
    if (mounted) {
      final skillState = ref.read(skillStateProvider);
      if (skillState.status == SkillStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.skillAddFailed}: ${skillState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.skillAdded),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateSkill(String id, AppLocalizations l10n) async {
    final data = {
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim(),
      'level': _levelController.text.toLowerCase().trim(),
      'yearsOfExperience': int.tryParse(_yearsController.text) ?? 0,
    };

    await ref.read(skillNotifierProvider.notifier).updateSkill(id, data);
    
    if (mounted) {
      final skillState = ref.read(skillStateProvider);
      if (skillState.status == SkillStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.skillUpdateFailed}: ${skillState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.skillUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteSkill(String id, AppLocalizations l10n) async {
    await ref.read(skillNotifierProvider.notifier).deleteSkill(id);
    
    if (mounted) {
      final skillState = ref.read(skillStateProvider);
      if (skillState.status == SkillStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.skillDeleteFailed}: ${skillState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.skillDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
