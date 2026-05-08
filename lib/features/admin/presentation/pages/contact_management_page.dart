import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/localization_service.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/responsive_builder.dart';
import '../widgets/admin_form_components.dart';

class ContactManagementPage extends ConsumerStatefulWidget {
  const ContactManagementPage({super.key});

  @override
  ConsumerState<ContactManagementPage> createState() => _ContactManagementPageState();
}

class _ContactManagementPageState extends ConsumerState<ContactManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _contacts = [];
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Form(
          key: _formKey,
          child: ResponsiveColumn(
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.spacingLG),
              _buildContactList(),
              const SizedBox(height: AppSizes.spacingLG),
              _buildAddContactButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: Form(
                key: _formKey,
                child: ResponsiveColumn(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSizes.spacingXL),
                    _buildContactList(),
                    const SizedBox(height: AppSizes.spacingXL),
                    _buildAddContactButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              child: Form(
                key: _formKey,
                child: ResponsiveColumn(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSizes.spacingXL),
                    _buildContactList(),
                    const SizedBox(height: AppSizes.spacingXL),
                    _buildAddContactButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveContainer(
      mobilePadding: const EdgeInsets.all(AppSizes.paddingMD),
      desktopPadding: const EdgeInsets.all(AppSizes.paddingLG),
      child: ResponsiveRow(
        children: [
          Expanded(
            child: AppText.h3('Contact Management'),
          ),
          ResponsiveRow(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadContactData,
              ),
              const SizedBox(width: AppSizes.spacingSM),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveContactData,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return ResponsiveColumn(
      children: [
        ..._contacts.asMap().entries.map((entry) {
          final index = entry.key;
          final contact = entry.value;
          return _buildContactCard(index, contact);
        }).toList(),
      ],
    );
  }

  Widget _buildContactCard(int index, Map<String, dynamic> contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingMD),
      child: ResponsiveContainer(
        mobileDecoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.grey300),
      ),
      desktopDecoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: ResponsiveColumn(
          children: [
            ResponsiveRow(
              children: [
                Expanded(
                  child: AppText.medium(
                    contact['name'] ?? 'Unknown Contact',
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSM),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editContact(index);
                  },
                ),
                const SizedBox(width: AppSizes.spacingSM),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {
                    _deleteContact(index);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSM),
            AppText.small(contact['email'] ?? 'No email'),
            const SizedBox(height: AppSizes.spacingSM),
            AppText.small(contact['phone'] ?? 'No phone'),
            const SizedBox(height: AppSizes.spacingSM),
            AppText.small(contact['message'] ?? 'No message'),
            const SizedBox(height: AppSizes.spacingSM),
            AppText.small(
              'Created: ${contact['createdAt'] ?? 'Unknown date'}',
              style: TextStyle(color: AppColors.grey600), 
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAddContactButton() {
    return ResponsiveContainer(
      mobilePadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSM),
      desktopPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeightLG,
        child: ElevatedButton(
          onPressed: _showAddContactDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
          ),
          child: AppText.button('Add New Contact'),
        ),
      ),
    );  
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Contact'),
          content: SizedBox(
            width: 400,
            child: ResponsiveColumn(
              children: [
                AdminFormComponents.buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  hintText: 'e.g. John Doe',
                ),
                const SizedBox(height: AppSizes.spacingMD),
                AdminFormComponents.buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'john.doe@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                AdminFormComponents.buildTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  hintText: '+1 (555) 123-4567',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                AdminFormComponents.buildTextArea(
                  label: 'Message',
                  controller: _messageController,
                  hintText: 'Enter your message here...',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addNewContact,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNewContact() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _contacts.add({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'message': _messageController.text,
          'createdAt': DateTime.now().toIso8601String(),
        });
      });

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
    }
  }

  void _editContact(int index) {
    final contact = _contacts[index];
    _nameController.text = contact['name'] ?? '';
    _emailController.text = contact['email'] ?? '';
    _phoneController.text = contact['phone'] ?? '';
    _messageController.text = contact['message'] ?? '';
    
    _showEditContactDialog(index);
  }

  void _showEditContactDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Contact'),
          content: SizedBox(
            width: 400,
            child: ResponsiveColumn(
              children: [
                AdminFormComponents.buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  hintText: 'e.g. John Doe',
                ),
                const SizedBox(height: AppSizes.spacingMD),
                AdminFormComponents.buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'john.doe@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                AdminFormComponents.buildTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  hintText: '+1 (555) 123-4567',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                AdminFormComponents.buildTextArea(
                  label: 'Message',
                  controller: _messageController,
                  hintText: 'Enter your message here...',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateContact(index);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateContact(int index) {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _contacts[index] = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'message': _messageController.text,
          'createdAt': _contacts[index]['createdAt'] ?? DateTime.now().toIso8601String(),
        };
      });

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
    }
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  void _loadContactData() {
    // TODO: Load contact data from API/storage
    setState(() {
      _contacts.addAll([
        {
          'name': 'Alice Johnson',
          'email': 'alice@example.com',
          'phone': '+1 (555) 123-4567',
          'message': 'Interested in collaboration opportunities',
          'createdAt': '2024-01-15T10:00:00Z',
        },
        {
          'name': 'Bob Smith',
          'email': 'bob@example.com',
          'phone': '+1 (555) 987-6543',
          'message': 'Looking for Flutter developers',
          'createdAt': '2024-01-10T14:30:00Z',
        },
      ]);
    });
  }

  Future<void> _saveContactData() async {
    final localizations = ref.read(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;
    
    try {
      // TODO: Save contact data to API/storage
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizedString('contactSaved', isHindi ? AppLanguage.hi : AppLanguage.en)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedString('contactSaveFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
