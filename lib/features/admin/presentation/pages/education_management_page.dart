import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;

    final education = educationState.educationList?['data'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(educationNotifierProvider.notifier).getEducation();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark, isHindi, education.length),
            const SizedBox(height: 20),
            AdminDataTable(
              columns: [
                AdminDataColumn(
                  key: 'institution',
                  title: isHindi ? 'संस्थान' : 'Institution',
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'degree',
                  title: isHindi ? 'डिग्री' : 'Degree',
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'field',
                  title: isHindi ? 'क्षेत्र' : 'Field',
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'duration',
                  title: isHindi ? 'अवधि' : 'Duration',
                  sortable: false,
                  cellBuilder: (row) => Text(
                    '${row['startDate'] ?? ''} - ${row['endDate'] ?? (isHindi ? "वर्तमान" : "Present")}',
                  ),
                ),
              ],
              data: education.cast<Map<String, dynamic>>(),
              isLoading: educationState.status == EducationStatus.loading,
              emptyMessage: isHindi ? 'कोई शिक्षा नहीं मिली' : 'No education found',
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSort: (columnKey, ascending) {
                setState(() {
                  _sortColumnIndex = ['institution', 'degree', 'field', 'duration'].indexOf(columnKey);
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
              isHindi ? 'शिक्षा प्रबंधन' : 'Education Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count ${isHindi ? "शिक्षा" : "education"} ${isHindi ? "पाई गई" : "found"}',
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
          label: Text(isHindi ? 'शिक्षा जोड़ें' : 'Add Education'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, bool isHindi) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: isHindi ? 'शिक्षा जोड़ें' : 'Add Education',
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: isHindi ? 'संस्थान' : 'Institution',
            isRequired: true,
            child: AdminTextField(
              controller: _institutionController,
              hintText: isHindi ? 'उदाहरण: हार्वर्ड विश्वविद्यालय' : 'e.g., Harvard University',
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'संस्थान आवश्यक है' : 'Institution is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'डिग्री' : 'Degree',
            isRequired: true,
            child: AdminTextField(
              controller: _degreeController,
              hintText: isHindi ? 'उदाहरण: बैचलर ऑफ साइंस' : 'e.g., Bachelor of Science',
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'डिग्री आवश्यक है' : 'Degree is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'क्षेत्र' : 'Field',
            isRequired: true,
            child: AdminTextField(
              controller: _fieldController,
              hintText: isHindi ? 'उदाहरण: कंप्यूटर साइंस' : 'e.g., Computer Science',
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'क्षेत्र आवश्यक है' : 'Field is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'प्रारंभ तिथि' : 'Start Date',
            child: AdminTextField(
              controller: _startDateController,
              hintText: 'YYYY-MM-DD',
            ),
          ),
          AdminFormField(
            label: isHindi ? 'समाप्ति तिथि' : 'End Date',
            child: AdminTextField(
              controller: _endDateController,
              hintText: 'YYYY-MM-DD',
            ),
          ),
          AdminFormField(
            label: isHindi ? 'विवरण' : 'Description',
            child: AdminTextField(
              controller: _descriptionController,
              hintText: isHindi ? 'अतिरिक्त विवरण...' : 'Additional details...',
              maxLines: 3,
            ),
          ),
        ],
        onSave: () => _createEducation(isHindi),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> education, bool isHindi) {
    _institutionController.text = education['institution'] ?? '';
    _degreeController.text = education['degree'] ?? '';
    _fieldController.text = education['field'] ?? '';
    _startDateController.text = education['startDate'] ?? '';
    _endDateController.text = education['endDate'] ?? '';
    _descriptionController.text = education['description'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: isHindi ? 'शिक्षा संपादित करें' : 'Edit Education',
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: isHindi ? 'संस्थान' : 'Institution',
            isRequired: true,
            child: AdminTextField(
              controller: _institutionController,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'संस्थान आवश्यक है' : 'Institution is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'डिग्री' : 'Degree',
            isRequired: true,
            child: AdminTextField(
              controller: _degreeController,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'डिग्री आवश्यक है' : 'Degree is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'क्षेत्र' : 'Field',
            isRequired: true,
            child: AdminTextField(
              controller: _fieldController,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'क्षेत्र आवश्यक है' : 'Field is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'प्रारंभ तिथि' : 'Start Date',
            child: AdminTextField(
              controller: _startDateController,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'समाप्ति तिथि' : 'End Date',
            child: AdminTextField(
              controller: _endDateController,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'विवरण' : 'Description',
            child: AdminTextField(
              controller: _descriptionController,
              maxLines: 3,
            ),
          ),
        ],
        onSave: () => _updateEducation(education['_id'], isHindi),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> education, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: isHindi ? 'शिक्षा हटाएं' : 'Delete Education',
        message: isHindi ? 'क्या आप वाकई इस शिक्षा को हटाना चाहते हैं' : 'Are you sure you want to delete',
        itemName: education['institution'] ?? '',
        onConfirm: () => _deleteEducation(education['_id'], isHindi),
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

  Future<void> _createEducation(bool isHindi) async {
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
            content: Text('${getLocalizedString('educationAddFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${educationState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('educationAdded', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateEducation(String id, bool isHindi) async {
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
            content: Text('${getLocalizedString('educationUpdateFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${educationState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('educationUpdated', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteEducation(String id, bool isHindi) async {
    await ref.read(educationNotifierProvider.notifier).deleteEducation(id);
    
    if (mounted) {
      final educationState = ref.read(educationStateProvider);
      if (educationState.status == EducationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('educationDeleteFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${educationState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('educationDeleted', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
