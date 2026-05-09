import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/widgets/common_text.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final projects = projectState.projects?['data'] as List<dynamic>? ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(projectNotifierProvider.notifier).getProjects();
        },
        child: projects.isEmpty && projectState.status != ProjectStatus.loading
            ? Center(
                child: CommonText.medium(
                  l10n.noProjectsFound,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AdminDataTable(
                  columns: [
                    AdminDataColumn(
                      key: 'title',
                      title: l10n.name,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'category',
                      title: l10n.category,
                      sortable: true,
                    ),
                    AdminDataColumn(
                      key: 'technologies',
                      title: l10n.technologiesLabel,
                      sortable: false,
                      cellBuilder: (row) => _buildTechChips(row['technologies'] ?? []),
                    ),
                    AdminDataColumn(
                      key: 'isFeatured',
                      title: l10n.featured,
                      sortable: true,
                      cellBuilder: (row) => _buildFeaturedChip(row['isFeatured'] ?? false),
                    ),
                  ],
                  data: projects.cast<Map<String, dynamic>>(),
                  isLoading: projectState.status == ProjectStatus.loading,
                  emptyMessage: l10n.noProjectsFound,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: (columnKey, ascending) {
                    setState(() {
                      _sortColumnIndex = ['title', 'category', 'technologies', 'isFeatured'].indexOf(columnKey);
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
        label: Text(l10n.addProject),
        backgroundColor: AppThemeColors.primary,
      ),
    );
  }

  Widget _buildTechChips(List<dynamic> technologies) {
    final l10n = AppLocalizations.of(context)!;
    if (technologies.isEmpty) return Text(l10n.emptyDash);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: technologies.take(3).map((tech) {
        return Chip(
          label: CommonText.verySmall(
            tech.toString(),
          ),
          backgroundColor: Colors.blue.shade100,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedChip(bool isFeatured) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFeatured ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CommonText.small(
        isFeatured ? l10n.yes : l10n.no,
        fontWeight: FontWeight.w600,
        color: isFeatured ? Colors.green : Colors.grey,
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppLocalizations l10n) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: l10n.addProject,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: l10n.name,
            isRequired: true,
            child: AdminTextField(
              controller: _titleController,
              hintText: l10n.projectTitleHint,
              validator: (value) => value?.isEmpty ?? true ? l10n.nameRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.description,
            isRequired: true,
            child: AdminTextField(
              controller: _descriptionController,
              hintText: l10n.projectDescriptionHint,
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? l10n.descriptionRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.category,
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              hintText: l10n.categoryHint,
              validator: (value) => value?.isEmpty ?? true ? l10n.categoryRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.technologiesLabel,
            isRequired: true,
            child: AdminTextField(
              controller: _technologiesController,
              hintText: l10n.technologiesHint,
              validator: (value) => value?.isEmpty ?? true ? l10n.technologiesRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.projectUrl,
            child: AdminTextField(
              controller: _projectUrlController,
              hintText: l10n.projectUrlHint,
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: l10n.repositoryUrl,
            child: AdminTextField(
              controller: _repositoryUrlController,
              hintText: l10n.repositoryUrlHint,
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: l10n.client,
            child: AdminTextField(
              controller: _clientController,
              hintText: l10n.clientHint,
            ),
          ),
          AdminFormField(
            label: l10n.imageUrl,
            child: AdminTextField(
              controller: _imageUrlController,
              hintText: l10n.imageUrlHint,
              keyboardType: TextInputType.url,
            ),
          ),
        ],
        onSave: () => _createProject(l10n),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> project, AppLocalizations l10n) {
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
        title: l10n.editProject,
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: l10n.name,
            isRequired: true,
            child: AdminTextField(
              controller: _titleController,
              validator: (value) => value?.isEmpty ?? true ? l10n.nameRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.description,
            isRequired: true,
            child: AdminTextField(
              controller: _descriptionController,
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? l10n.descriptionRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.category,
            isRequired: true,
            child: AdminTextField(
              controller: _categoryController,
              validator: (value) => value?.isEmpty ?? true ? l10n.categoryRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.technologiesLabel,
            isRequired: true,
            child: AdminTextField(
              controller: _technologiesController,
              validator: (value) => value?.isEmpty ?? true ? l10n.technologiesRequired : null,
            ),
          ),
          AdminFormField(
            label: l10n.projectUrl,
            child: AdminTextField(
              controller: _projectUrlController,
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: l10n.repositoryUrl,
            child: AdminTextField(
              controller: _repositoryUrlController,
              keyboardType: TextInputType.url,
            ),
          ),
          AdminFormField(
            label: l10n.client,
            child: AdminTextField(
              controller: _clientController,
            ),
          ),
          AdminFormField(
            label: l10n.imageUrl,
            child: AdminTextField(
              controller: _imageUrlController,
              keyboardType: TextInputType.url,
            ),
          ),
        ],
        onSave: () => _updateProject(project['_id'], l10n),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> project, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: l10n.deleteProject,
        message: l10n.deleteConfirmMessage,
        itemName: project['title'] ?? '',
        onConfirm: () => _deleteProject(project['_id'], l10n),
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

  Future<void> _createProject(AppLocalizations l10n) async {
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
            content: Text('${l10n.projectAddFailed}: ${projectState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.projectAdded),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateProject(String id, AppLocalizations l10n) async {
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
            content: Text('${l10n.projectUpdateFailed}: ${projectState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.projectUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(String id, AppLocalizations l10n) async {
    await ref.read(projectNotifierProvider.notifier).deleteProject(id);
    
    if (mounted) {
      final projectState = ref.read(projectStateProvider);
      if (projectState.status == ProjectStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.projectDeleteFailed}: ${projectState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.projectDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
