import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/config/app_theme_colors.dart';
import '../../../../core/widgets/common_text.dart';
import '../../../../core/services/localization_service.dart';
import '../../../services/presentation/providers/service_provider.dart';
import '../../../services/presentation/providers/service_state.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_dialogs.dart';

class ServicesManagementPage extends ConsumerStatefulWidget {
  const ServicesManagementPage({super.key});

  @override
  ConsumerState<ServicesManagementPage> createState() => _ServicesManagementPageState();
}

class _ServicesManagementPageState extends ConsumerState<ServicesManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceNotifierProvider.notifier).getServices();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = ref.watch(currentLanguageProvider);
    final isHindi = language == AppLanguage.hi;
    final l10n = AppLocalizations.of(context)!;

    final services = serviceState.services;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(serviceNotifierProvider.notifier).getServices();
        },
        child: services.isEmpty && serviceState.status != ServiceStatus.loading
            ? Center(
                child: CommonText.medium(
                  l10n.noServicesFound,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AdminDataTable(
                  columns: [
                    AdminDataColumn(
                      key: 'title',
                      title: getLocalizedString('title', isHindi ? AppLanguage.hi : AppLanguage.en),
                      sortable: true,
                      cellBuilder: (row) => _buildServiceTitle(row),
                    ),
                    AdminDataColumn(
                      key: 'description',
                      title: getLocalizedString('description', isHindi ? AppLanguage.hi : AppLanguage.en),
                      sortable: false,
                      cellBuilder: (row) => Text(
                        row['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AdminDataColumn(
                      key: 'icon',
                      title: getLocalizedString('icon', isHindi ? AppLanguage.hi : AppLanguage.en),
                      sortable: true,
                      cellBuilder: (row) => _buildIconPreview(row['icon'], row['color']),
                    ),
                  ],
                  data: services.map((s) => s.toJson()..['_id'] = s.id).toList(),
                  isLoading: serviceState.status == ServiceStatus.loading,
                  emptyMessage: getLocalizedString('noServicesFound', isHindi ? AppLanguage.hi : AppLanguage.en),
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: (columnKey, ascending) {
                    setState(() {
                      _sortColumnIndex = ['title', 'description', 'icon'].indexOf(columnKey);
                      _sortAscending = ascending;
                    });
                  },
                  onEdit: (index, row) => _showEditDialog(context, row, isHindi),
                  onDelete: (index, row) => _showDeleteDialog(context, row, isHindi),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, isHindi),
        icon: const Icon(Icons.add),
        label: Text(l10n.addService),
        backgroundColor: AppThemeColors.primary,
      ),
    );
  }

  Widget _buildServiceTitle(Map<String, dynamic> row) {
    return Row(
      children: [
        _buildIconPreview(row['icon'], row['color'], size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText.small(
            row['title'] ?? '',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIconPreview(String? iconName, String? colorString, {double size = 32}) {
    final color = _getColorFromString(colorString ?? '#2196F3');
    final icon = _getIconFromString(iconName ?? 'design_services');
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: size * 0.6,
        color: color,
      ),
    );
  }

  void _showAddDialog(BuildContext context, bool isHindi) {
    _clearControllers();
    
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: getLocalizedString('addService', isHindi ? AppLanguage.hi : AppLanguage.en),
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: getLocalizedString('title', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _titleController,
              hintText: getLocalizedString('titleHint', isHindi ? AppLanguage.hi : AppLanguage.en),
              validator: (value) => value?.isEmpty ?? true ? getLocalizedString('titleRequired', isHindi ? AppLanguage.hi : AppLanguage.en) : null,
            ),
          ),
          AdminFormField(
            label: getLocalizedString('description', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _descriptionController,
              hintText: getLocalizedString('descriptionHint', isHindi ? AppLanguage.hi : AppLanguage.en),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? getLocalizedString('descriptionRequired', isHindi ? AppLanguage.hi : AppLanguage.en) : null,
            ),
          ),
          AdminFormField(
            label: getLocalizedString('iconName', isHindi ? AppLanguage.hi : AppLanguage.en),
            child: AdminTextField(
              controller: _iconController,
              hintText: 'smartphone, web, cloud, code',
            ),
          ),
          AdminFormField(
            label: getLocalizedString('color', isHindi ? AppLanguage.hi : AppLanguage.en),
            child: AdminTextField(
              controller: _colorController,
              hintText: '#2196F3',
            ),
          ),
        ],
        onSave: () => _createService(isHindi),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> service, bool isHindi) {
    _titleController.text = service['title'] ?? '';
    _descriptionController.text = service['description'] ?? '';
    _iconController.text = service['icon'] ?? '';
    _colorController.text = service['color'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(
        title: getLocalizedString('editService', isHindi ? AppLanguage.hi : AppLanguage.en),
        isEditing: true,
        formKey: _formKey,
        formFields: [
          AdminFormField(
            label: getLocalizedString('title', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _titleController,
              validator: (value) => value?.isEmpty ?? true ? getLocalizedString('titleRequired', isHindi ? AppLanguage.hi : AppLanguage.en) : null,
            ),
          ),
          AdminFormField(
            label: getLocalizedString('description', isHindi ? AppLanguage.hi : AppLanguage.en),
            isRequired: true,
            child: AdminTextField(
              controller: _descriptionController,
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? getLocalizedString('descriptionRequired', isHindi ? AppLanguage.hi : AppLanguage.en) : null,
            ),
          ),
          AdminFormField(
            label: getLocalizedString('iconName', isHindi ? AppLanguage.hi : AppLanguage.en),
            child: AdminTextField(
              controller: _iconController,
            ),
          ),
          AdminFormField(
            label: getLocalizedString('color', isHindi ? AppLanguage.hi : AppLanguage.en),
            child: AdminTextField(
              controller: _colorController,
            ),
          ),
        ],
        onSave: () => _updateService(service['_id'], isHindi),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> service, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AdminDeleteDialog(
        title: getLocalizedString('deleteService', isHindi ? AppLanguage.hi : AppLanguage.en),
        message: getLocalizedString('deleteServiceConfirm', isHindi ? AppLanguage.hi : AppLanguage.en),
        itemName: service['title'] ?? '',
        onConfirm: () => _deleteService(service['_id'], isHindi),
      ),
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _iconController.clear();
    _colorController.clear();
  }

  Future<void> _createService(bool isHindi) async {
    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'icon': _iconController.text.isEmpty ? 'design_services' : _iconController.text,
      'color': _colorController.text.isEmpty ? '#2196F3' : _colorController.text,
    };

    await ref.read(serviceNotifierProvider.notifier).createService(data);
    
    if (mounted) {
      final serviceState = ref.read(serviceStateProvider);
      if (serviceState.status == ServiceStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('serviceAddFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${serviceState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('serviceAdded', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateService(String id, bool isHindi) async {
    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'icon': _iconController.text,
      'color': _colorController.text,
    };

    await ref.read(serviceNotifierProvider.notifier).updateService(id, data);
    
    if (mounted) {
      final serviceState = ref.read(serviceStateProvider);
      if (serviceState.status == ServiceStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('serviceUpdateFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${serviceState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('serviceUpdated', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteService(String id, bool isHindi) async {
    await ref.read(serviceNotifierProvider.notifier).deleteService(id);
    
    if (mounted) {
      final serviceState = ref.read(serviceStateProvider);
      if (serviceState.status == ServiceStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('serviceDeleteFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${serviceState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('serviceDeleted', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Color _getColorFromString(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconFromString(String iconName) {
    final iconMap = {
      'smartphone': Icons.smartphone,
      'web': Icons.web,
      'cloud': Icons.cloud,
      'storage': Icons.storage,
      'code': Icons.code,
      'design_services': Icons.design_services,
      'app': Icons.apps,
      'api': Icons.api,
    };
    return iconMap[iconName] ?? Icons.design_services;
  }
}
