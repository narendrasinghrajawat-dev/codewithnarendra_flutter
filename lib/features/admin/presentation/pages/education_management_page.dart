import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/widgets/common_text.dart';
import '../../../../core/services/localization_service.dart';
import '../../../education/presentation/providers/education_provider.dart';
import '../../../education/presentation/providers/education_state.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_dialogs.dart';

class EducationManagementPage extends ConsumerStatefulWidget {
  const EducationManagementPage({super.key});

  @override
  ConsumerState<EducationManagementPage> createState() => _EducationManagementPageState();
}

class _EducationManagementPageState extends ConsumerState<EducationManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(educationNotifierProvider.notifier).getEducation();
    });
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _degreeController.dispose();
    _fieldController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final education = educationState.educationList?['data'] as List<dynamic>? ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(educationNotifierProvider.notifier).getEducation();
        },
        child: education.isEmpty && educationState.status != EducationStatus.loading
            ? Center(
                child: CommonText.medium(
                  l10n.noEducationFound,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AdminDataTable(
                  columns: [
                    AdminDataColumn(
                      key: 'institution',
                      title: l10n.institution,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'degree',
                      title: l10n.degree,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'field',
                      title: l10n.field,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'duration',
                      title: l10n.startDate,
                      sortable: false,
                      cellBuilder: (row) => Text(
                        '${row['startDate'] ?? ''} - ${row['endDate'] ?? l10n.present}',
                      ),
                    ),
                  ],
                  data: education.cast<Map<String, dynamic>>(),
                  isLoading: educationState.status == EducationStatus.loading,
                  emptyMessage: l10n.noEducationFound,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: (columnKey, ascending) {
                    setState(() {
                      _sortColumnIndex = ['institution', 'degree', 'field', 'duration'].indexOf(columnKey);
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
        label: Text(l10n.addEducation),
        backgroundColor: AppThemeColors.primary,
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppLocalizations l10n) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: l10n.addEducation,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: l10n.institution,
            isRequired: true,
            child: AdminTextField(
              controller: _institutionController,
              hintText: l10n.institutionHint,
              validator: (value) => value?.isEmpty ?? true ? l10n.institutionRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.degree,
            isRequired: true,
            child: AdminTextField(
              controller: _degreeController,
              hintText: l10n.degreeHint,
              validator: (value) => value?.isEmpty ?? true ? l10n.degreeRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.field,
            isRequired: true,
            child: AdminTextField(
              controller: _fieldController,
              hintText: l10n.fieldHint,
              validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.startDate,
            child: AdminTextField(
              controller: _startDateController,
              hintText: l10n.dateHint,
            ),
          ),
          AdminFormField(
            label: l10n.endDate,
            child: AdminTextField(
              controller: _endDateController,
              hintText: l10n.dateHint,
            ),
          ),
          AdminFormField(
            label: l10n.description,
            child: AdminTextField(
              controller: _descriptionController,
              hintText: l10n.descriptionHint,
              maxLines: 3,
            ),
          ),
        ],
        onSave: () => _createEducation(l10n),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> education, AppLocalizations l10n) {
    _institutionController.text = education['institution'] ?? '';
    _degreeController.text = education['degree'] ?? '';
    _fieldController.text = education['field'] ?? '';
    _startDateController.text = education['startDate'] ?? '';
    _endDateController.text = education['endDate'] ?? '';
    _descriptionController.text = education['description'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: l10n.editEducation,
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: l10n.institution,
            isRequired: true,
            child: AdminTextField(
              controller: _institutionController,
              validator: (value) => value?.isEmpty ?? true ? l10n.institutionRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.degree,
            isRequired: true,
            child: AdminTextField(
              controller: _degreeController,
              validator: (value) => value?.isEmpty ?? true ? l10n.degreeRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.field,
            isRequired: true,
            child: AdminTextField(
              controller: _fieldController,
              validator: (value) => value?.isEmpty ?? true ? l10n.fieldRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.startDate,
            child: AdminTextField(
              controller: _startDateController,
            ),
          ),
          AdminFormField(
            label: l10n.endDate,
            child: AdminTextField(
              controller: _endDateController,
            ),
          ),
          AdminFormField(
            label: l10n.description,
            child: AdminTextField(
              controller: _descriptionController,
              maxLines: 3,
            ),
          ),
        ],
        onSave: () => _updateEducation(education['_id'], l10n),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> education, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: l10n.deleteEducation,
        message: l10n.deleteConfirmMessage,
        itemName: education['institution'] ?? '',
        onConfirm: () => _deleteEducation(education['_id'], l10n),
      ),
    );
  }

  void _clearControllers() {
    _institutionController.clear();
    _degreeController.clear();
    _fieldController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
  }

  Future<void> _createEducation(AppLocalizations l10n) async {
    final data = {
      'institution': _institutionController.text,
      'degree': _degreeController.text,
      'field': _fieldController.text,
      'startDate': _startDateController.text,
      'endDate': _endDateController.text,
      'description': _descriptionController.text,
    };

    await ref.read(educationNotifierProvider.notifier).createEducation(data);
    
    if (mounted) {
      final educationState = ref.read(educationStateProvider);
      if (educationState.status == EducationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.educationAddFailed}: ${educationState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.educationAdded),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateEducation(String id, AppLocalizations l10n) async {
    final data = {
      'institution': _institutionController.text,
      'degree': _degreeController.text,
      'field': _fieldController.text,
      'startDate': _startDateController.text,
      'endDate': _endDateController.text,
      'description': _descriptionController.text,
    };

    await ref.read(educationNotifierProvider.notifier).updateEducation(id, data);
    
    if (mounted) {
      final educationState = ref.read(educationStateProvider);
      if (educationState.status == EducationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.educationUpdateFailed}: ${educationState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.educationUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteEducation(String id, AppLocalizations l10n) async {
    await ref.read(educationNotifierProvider.notifier).deleteEducation(id);
    
    if (mounted) {
      final educationState = ref.read(educationStateProvider);
      if (educationState.status == EducationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.educationDeleteFailed}: ${educationState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.educationDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
