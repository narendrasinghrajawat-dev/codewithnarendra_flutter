import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../about/presentation/providers/about_provider.dart';
import '../../../about/presentation/providers/about_state.dart';
import '../widgets/admin_dialogs.dart';

class AboutManagementPage extends ConsumerStatefulWidget {
  const AboutManagementPage({super.key});

  @override
  ConsumerState<AboutManagementPage> createState() => _AboutManagementPageState();
}

class _AboutManagementPageState extends ConsumerState<AboutManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _resumeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aboutNotifierProvider.notifier).getAbout();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final aboutState = ref.watch(aboutStateProvider);
    final aboutList = _getAboutList(aboutState);

    return Scaffold(
      body: aboutState.status == AboutStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : aboutState.status == AboutStatus.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.errorConnection}: ${aboutState.errorMessage}',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.read(aboutNotifierProvider.notifier).getAbout(),
                        child: Text(l10n.actionRetry),
                      ),
                    ],
                  ),
                )
              : aboutList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No record found',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => _showAddDialog(l10n),
                            child: Text(l10n.adminAddNew),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildAboutCard(aboutList.first, isDark, l10n),
                    ),
      floatingActionButton: aboutList.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.adminAddNew),
            )
          : null,
    );
  }

  List<Map<String, dynamic>> _getAboutList(AboutState aboutState) {
    if (aboutState.about == null) return [];
    final about = aboutState.about!;
    final data = about['data'];
    if (data == null) return [];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Widget _buildAboutCard(Map<String, dynamic> about, bool isDark, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and edit button
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    about['title'] ?? l10n.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: l10n.commonEdit,
                  onPressed: () => _showEditDialog(about, l10n),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: l10n.commonDelete,
                  onPressed: () => _showDeleteDialog(about, l10n),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Description
            Text(
              about['description'] ?? l10n.description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            
            // Contact Information
            _buildInfoSection('Contact Information', [
              if (about['email'] != null && about['email'].toString().isNotEmpty)
                _buildInfoItem(Icons.email, about['email']),
              if (about['phone'] != null && about['phone'].toString().isNotEmpty)
                _buildInfoItem(Icons.phone, about['phone']),
              if (about['location'] != null && about['location'].toString().isNotEmpty)
                _buildInfoItem(Icons.location_on, about['location']),
            ], isDark),
            
            const SizedBox(height: 20),
            
            // Social Links
            _buildInfoSection('Social Links', [
              if (about['website'] != null && about['website'].toString().isNotEmpty)
                _buildInfoItem(Icons.language, about['website']),
              if (about['linkedin'] != null && about['linkedin'].toString().isNotEmpty)
                _buildInfoItem(Icons.link, about['linkedin']),
              if (about['github'] != null && about['github'].toString().isNotEmpty)
                _buildInfoItem(Icons.code, about['github']),
            ], isDark),
            
            const SizedBox(height: 20),
            
            // Resume
            if (about['resumeUrl'] != null && about['resumeUrl'].toString().isNotEmpty)
              _buildInfoSection('Resume', [
                _buildInfoItem(Icons.description, about['resumeUrl']),
              ], isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, bool isDark) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _bioController.clear();
    _emailController.clear();
    _phoneController.clear();
    _locationController.clear();
    _websiteController.clear();
    _linkedinController.clear();
    _githubController.clear();
    _resumeController.clear();
  }

  void _fillControllers(Map<String, dynamic> about) {
    _titleController.text = about['title'] ?? '';
    _bioController.text = about['description'] ?? '';
    _emailController.text = about['email'] ?? '';
    _phoneController.text = about['phone'] ?? '';
    _locationController.text = about['location'] ?? '';
    _websiteController.text = about['website'] ?? '';
    _linkedinController.text = about['linkedin'] ?? '';
    _githubController.text = about['github'] ?? '';
    _resumeController.text = about['resumeUrl'] ?? '';
  }

  void _showAddDialog(AppLocalizations l10n) {
    _clearControllers();
    _showFormDialog(l10n, null);
  }

  void _showEditDialog(Map<String, dynamic> about, AppLocalizations l10n) {
    _fillControllers(about);
    _showFormDialog(l10n, about);
  }

  void _showFormDialog(AppLocalizations l10n, Map<String, dynamic>? about) {
    final isEditing = about != null;
    final title = isEditing ? l10n.adminEditItem : l10n.adminAddNew;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminFormField(
                  label: l10n.title,
                  isRequired: true,
                  child: AdminTextField(
                    controller: _titleController,
                    hintText: l10n.titleHint,
                    validator: (value) => value?.isEmpty ?? true
                        ? l10n.titleRequired
                        : null,
                  ),
                ),
                AdminFormField(
                  label: l10n.bio,
                  isRequired: true,
                  child: AdminTextField(
                    controller: _bioController,
                    hintText: l10n.bioHint,
                    maxLines: 4,
                    validator: (value) => value?.isEmpty ?? true
                        ? l10n.errorValidation
                        : null,
                  ),
                ),
                AdminFormField(
                  label: l10n.email,
                  isRequired: true,
                  child: AdminTextField(
                    controller: _emailController,
                    hintText: l10n.enterEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value?.isEmpty ?? true
                        ? l10n.errorValidation
                        : null,
                  ),
                ),
                AdminFormField(
                  label: l10n.phone,
                  child: AdminTextField(
                    controller: _phoneController,
                    hintText: l10n.phoneHint,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                AdminFormField(
                  label: l10n.location,
                  child: AdminTextField(
                    controller: _locationController,
                    hintText: l10n.locationHint,
                  ),
                ),
                AdminFormField(
                  label: l10n.website,
                  child: AdminTextField(
                    controller: _websiteController,
                    hintText: l10n.websiteHint,
                    keyboardType: TextInputType.url,
                  ),
                ),
                AdminFormField(
                  label: 'LinkedIn',
                  child: AdminTextField(
                    controller: _linkedinController,
                    hintText: l10n.linkedinHint,
                    keyboardType: TextInputType.url,
                  ),
                ),
                AdminFormField(
                  label: 'GitHub',
                  child: AdminTextField(
                    controller: _githubController,
                    hintText: l10n.githubHint,
                    keyboardType: TextInputType.url,
                  ),
                ),
                AdminFormField(
                  label: l10n.resumeUrl,
                  child: AdminTextField(
                    controller: _resumeController,
                    hintText: l10n.resumeUrlHint,
                    keyboardType: TextInputType.url,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              if (isEditing) {
                _updateAbout(about['_id'], l10n);
              } else {
                _createAbout(l10n);
              }
            },
            child: Text(isEditing ? l10n.actionUpdate : l10n.actionCreate),
          ),
        ],
      ),
    );
  }

  Future<void> _createAbout(AppLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = {
      'title': _titleController.text.trim(),
      'description': _bioController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'website': _websiteController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'github': _githubController.text.trim(),
      'resumeUrl': _resumeController.text.trim(),
    };

    await ref.read(aboutNotifierProvider.notifier).createAbout(data);

    if (mounted) {
      Navigator.of(context).pop();
      final aboutState = ref.read(aboutStateProvider);
      if (aboutState.status == AboutStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.aboutSaveFailed}: ${aboutState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.successCreate),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateAbout(String id, AppLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = {
      'title': _titleController.text.trim(),
      'description': _bioController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'website': _websiteController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'github': _githubController.text.trim(),
      'resumeUrl': _resumeController.text.trim(),
    };

    await ref.read(aboutNotifierProvider.notifier).updateAbout(id, data);

    if (mounted) {
      Navigator.of(context).pop();
      final aboutState = ref.read(aboutStateProvider);
      if (aboutState.status == AboutStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.aboutSaveFailed}: ${aboutState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.successUpdate),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(Map<String, dynamic> about, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminDeleteItem),
        content: Text('${l10n.deleteConfirmMessage}\n\n${about['title'] ?? l10n.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAbout(about['_id'], l10n);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAbout(String id, AppLocalizations l10n) async {
    await ref.read(aboutNotifierProvider.notifier).deleteAbout(id);

    if (mounted) {
      final aboutState = ref.read(aboutStateProvider);
      if (aboutState.status == AboutStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.aboutSaveFailed}: ${aboutState.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.successDelete),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
