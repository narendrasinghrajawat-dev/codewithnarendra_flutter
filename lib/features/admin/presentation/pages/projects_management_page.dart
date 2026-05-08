import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/providers/project_state.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_dialogs.dart';

class ProjectsManagementPage extends ConsumerStatefulWidget {
  const ProjectsManagementPage({super.key});

  @override
  ConsumerState<ProjectsManagementPage> createState() => _ProjectsManagementPageState();
}

class _ProjectsManagementPageState extends ConsumerState<ProjectsManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _repositoryUrlController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _categoryController = TextEditingController();
  final _clientController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectNotifierProvider.notifier).getProjects();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    _repositoryUrlController.dispose();
    _technologiesController.dispose();
    _categoryController.dispose();
    _clientController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;

    final projects = projectState.projects?['data'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(projectNotifierProvider.notifier).getProjects();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark, isHindi, projects.length),
            const SizedBox(height: 20),
            AdminDataTable(
              columns: [
                AdminDataColumn(
                  key: 'title',
                  title: isHindi ? 'शीर्षक' : 'Title',
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'category',
                  title: isHindi ? 'श्रेणी' : 'Category',
                  sortable: true,
                ),
                AdminDataColumn(
                  key: 'technologies',
                  title: isHindi ? 'तकनीकें' : 'Technologies',
                  sortable: false,
                  cellBuilder: (row) => _buildTechChips(row['technologies'] ?? []),
                ),
                AdminDataColumn(
                  key: 'isFeatured',
                  title: isHindi ? 'विशेष' : 'Featured',
                  sortable: true,
                  cellBuilder: (row) => _buildFeaturedChip(row['isFeatured'] ?? false),
                ),
              ],
              data: projects.cast<Map<String, dynamic>>(),
              isLoading: projectState.status == ProjectStatus.loading,
              emptyMessage: isHindi ? 'कोई परियोजना नहीं मिली' : 'No projects found',
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSort: (columnKey, ascending) {
                setState(() {
                  _sortColumnIndex = ['title', 'category', 'technologies', 'isFeatured'].indexOf(columnKey);
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
              isHindi ? 'परियोजना प्रबंधन' : 'Projects Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count ${isHindi ? "परियोजनाएं" : "projects"} ${isHindi ? "पाई गईं" : "found"}',
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
          label: Text(isHindi ? 'परियोजना जोड़ें' : 'Add Project'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTechChips(List<dynamic> technologies) {
    if (technologies.isEmpty) return const Text('-');
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: technologies.take(3).map((tech) {
        return Chip(
          label: Text(
            tech.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: Colors.blue.shade100,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedChip(bool isFeatured) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFeatured ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isFeatured ? 'Yes' : 'No',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isFeatured ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, bool isHindi) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: isHindi ? 'परियोजना जोड़ें' : 'Add Project',
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: isHindi ? 'शीर्षक' : 'Title',
            isRequired: true,
            child: AdminTextField(
              controller: _titleController,
              hintText: isHindi ? 'उदाहरण: ई-कॉमर्स ऐप' : 'e.g., E-Commerce App',
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'शीर्षक आवश्यक है' : 'Title is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'विवरण' : 'Description',
            isRequired: true,
            child: AdminTextField(
              controller: _descriptionController,
              hintText: isHindi ? 'परियोजना का विवरण' : 'Project description',
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'विवरण आवश्यक है' : 'Description is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'श्रेणी' : 'Category',
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              hintText: isHindi ? 'उदाहरण: मोबाइल ऐप' : 'e.g., Mobile App',
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'श्रेणी आवश्यक है' : 'Category is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'तकनीकें (कॉमा से अलग)' : 'Technologies (comma separated)',
            isRequired: true,
            child: AdminTextField(
              controller: _technologiesController,
              hintText: 'Flutter, Firebase, Node.js',
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'तकनीकें आवश्यक हैं' : 'Technologies are required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'परियोजना URL' : 'Project URL',
            child: AdminTextField(
              controller: _projectUrlController,
              hintText: 'https://example.com',
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'रिपॉजिटरी URL' : 'Repository URL',
            child: AdminTextField(
              controller: _repositoryUrlController,
              hintText: 'https://github.com/username/repo',
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'क्लाइंट' : 'Client',
            child: AdminTextField(
              controller: _clientController,
              hintText: isHindi ? 'क्लाइंट का नाम' : 'Client name',
            ),
          ),
          AdminFormField(
            label: isHindi ? 'छवि URL' : 'Image URL',
            child: AdminTextField(
              controller: _imageUrlController,
              hintText: 'https://...',
              keyboardType: TextInputType.url,
            ),
          ),
        ],
        onSave: () => _createProject(isHindi),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> project, bool isHindi) {
    _titleController.text = project['title'] ?? '';
    _descriptionController.text = project['description'] ?? '';
    _categoryController.text = project['category'] ?? '';
    _technologiesController.text = (project['technologies'] as List<dynamic>?)?.join(', ') ?? '';
    _projectUrlController.text = project['projectUrl'] ?? '';
    _repositoryUrlController.text = project['repositoryUrl'] ?? '';
    _clientController.text = project['client'] ?? '';
    _imageUrlController.text = project['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: isHindi ? 'परियोजना संपादित करें' : 'Edit Project',
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: isHindi ? 'शीर्षक' : 'Title',
            isRequired: true,
            child: AdminTextField(
              controller: _titleController,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'शीर्षक आवश्यक है' : 'Title is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'विवरण' : 'Description',
            isRequired: true,
            child: AdminTextField(
              controller: _descriptionController,
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'विवरण आवश्यक है' : 'Description is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'श्रेणी' : 'Category',
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'श्रेणी आवश्यक है' : 'Category is required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'तकनीकें (कॉमा से अलग)' : 'Technologies (comma separated)',
            isRequired: true,
            child: AdminTextField(
              controller: _technologiesController,
              validator: (value) => value?.isEmpty ?? true ? (isHindi ? 'तकनीकें आवश्यक हैं' : 'Technologies are required') : null,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'परियोजना URL' : 'Project URL',
            child: AdminTextField(
              controller: _projectUrlController,
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'रिपॉजिटरी URL' : 'Repository URL',
            child: AdminTextField(
              controller: _repositoryUrlController,
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'क्लाइंट' : 'Client',
            child: AdminTextField(
              controller: _clientController,
            ),
          ),
          AdminFormField(
            label: isHindi ? 'छवि URL' : 'Image URL',
            child: AdminTextField(
              controller: _imageUrlController,
              keyboardType: TextInputType.url,
            ),
          ),
        ],
        onSave: () => _updateProject(project['_id'], isHindi),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> project, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: isHindi ? 'परियोजना हटाएं' : 'Delete Project',
        message: isHindi ? 'क्या आप वाकई इस परियोजना को हटाना चाहते हैं' : 'Are you sure you want to delete',
        itemName: project['title'] ?? '',
        onConfirm: () => _deleteProject(project['_id'], isHindi),
      ),
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _technologiesController.clear();
    _projectUrlController.clear();
    _repositoryUrlController.clear();
    _clientController.clear();
    _imageUrlController.clear();
  }

  Future<void> _createProject(bool isHindi) async {
    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _categoryController.text,
      'technologies': _technologiesController.text.split(',').map((e) => e.trim()).toList(),
      'projectUrl': _projectUrlController.text,
      'repositoryUrl': _repositoryUrlController.text,
      'client': _clientController.text,
      'imageUrl': _imageUrlController.text,
      'isFeatured': false,
    };

    await ref.read(projectNotifierProvider.notifier).createProject(data);
    
    if (mounted) {
      final projectState = ref.read(projectStateProvider);
      if (projectState.status == ProjectStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('projectAddFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${projectState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('projectAdded', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateProject(String id, bool isHindi) async {
    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _categoryController.text,
      'technologies': _technologiesController.text.split(',').map((e) => e.trim()).toList(),
      'projectUrl': _projectUrlController.text,
      'repositoryUrl': _repositoryUrlController.text,
      'client': _clientController.text,
      'imageUrl': _imageUrlController.text,
    };

    await ref.read(projectNotifierProvider.notifier).updateProject(id, data);
    
    if (mounted) {
      final projectState = ref.read(projectStateProvider);
      if (projectState.status == ProjectStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('projectUpdateFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${projectState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('projectUpdated', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(String id, bool isHindi) async {
    await ref.read(projectNotifierProvider.notifier).deleteProject(id);
    
    if (mounted) {
      final projectState = ref.read(projectStateProvider);
      if (projectState.status == ProjectStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('projectDeleteFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${projectState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('projectDeleted', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
