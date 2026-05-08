import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/localization_service.dart';
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
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _resumeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    final localizations = ref.watch(localizationStateProvider);
    final isHindi = localizations.language == AppLanguage.hi;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark, isHindi),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'व्यक्तिगत जानकारी' : 'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFormFields(isHindi),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : () => _saveAboutData(isHindi),
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                        label: Text(isHindi ? 'जानकारी सहेजें' : 'Save Information'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi ? 'बारे में प्रबंधन' : 'About Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isHindi ? 'अपनी व्यक्तिगत जानकारी प्रबंधित करें' : 'Manage your personal information',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(bool isHindi) {
    return Column(
      children: [
        AdminFormField(
          label: isHindi ? 'नाम' : 'Name',
          isRequired: true,
          child: AdminTextField(
            controller: _nameController,
            hintText: isHindi ? 'आपका पूरा नाम' : 'Your full name',
            validator: (value) => value?.isEmpty ?? true 
              ? (isHindi ? 'नाम आवश्यक है' : 'Name is required') 
              : null,
          ),
        ),
        AdminFormField(
          label: isHindi ? 'पद' : 'Title',
          isRequired: true,
          child: AdminTextField(
            controller: _titleController,
            hintText: isHindi ? 'उदाहरण: सीनियर फ्लटर डेवलपर' : 'e.g., Senior Flutter Developer',
            validator: (value) => value?.isEmpty ?? true 
              ? (isHindi ? 'पद आवश्यक है' : 'Title is required') 
              : null,
          ),
        ),
        AdminFormField(
          label: isHindi ? 'बायो' : 'Bio',
          child: AdminTextField(
            controller: _bioController,
            hintText: isHindi ? 'अपने बारे में कुछ बताएं...' : 'Tell us about yourself...',
            maxLines: 5,
          ),
        ),
        AdminFormField(
          label: isHindi ? 'ईमेल' : 'Email',
          isRequired: true,
          child: AdminTextField(
            controller: _emailController,
            hintText: 'john@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.isEmpty ?? true 
              ? (isHindi ? 'ईमेल आवश्यक है' : 'Email is required') 
              : null,
          ),
        ),
        AdminFormField(
          label: isHindi ? 'फोन' : 'Phone',
          child: AdminTextField(
            controller: _phoneController,
            hintText: '+1 (555) 123-4567',
            keyboardType: TextInputType.phone,
          ),
        ),
        AdminFormField(
          label: isHindi ? 'स्थान' : 'Location',
          child: AdminTextField(
            controller: _locationController,
            hintText: isHindi ? 'उदाहरण: मुंबई, भारत' : 'e.g., Mumbai, India',
          ),
        ),
        AdminFormField(
          label: isHindi ? 'वेबसाइट' : 'Website',
          child: AdminTextField(
            controller: _websiteController,
            hintText: 'https://yourwebsite.com',
            keyboardType: TextInputType.url,
          ),
        ),
        AdminFormField(
          label: 'LinkedIn',
          child: AdminTextField(
            controller: _linkedinController,
            hintText: 'https://linkedin.com/in/username',
            keyboardType: TextInputType.url,
          ),
        ),
        AdminFormField(
          label: 'GitHub',
          child: AdminTextField(
            controller: _githubController,
            hintText: 'https://github.com/username',
            keyboardType: TextInputType.url,
          ),
        ),
        AdminFormField(
          label: isHindi ? 'रिज्यूमे URL' : 'Resume URL',
          child: AdminTextField(
            controller: _resumeController,
            hintText: 'https://...',
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }

  Future<void> _loadAboutData() async {
    await ref.read(aboutNotifierProvider.notifier).getAbout();
    
    final aboutState = ref.read(aboutStateProvider);
    if (aboutState.about != null) {
      final about = aboutState.about!;
      final data = about['data'];
      if (data != null && data is List && data.isNotEmpty) {
        final aboutItem = data[0];
        _nameController.text = aboutItem['title'] ?? '';
        _titleController.text = aboutItem['title'] ?? '';
        _bioController.text = aboutItem['description'] ?? '';
        _emailController.text = aboutItem['email'] ?? '';
        _phoneController.text = aboutItem['phone'] ?? '';
        _locationController.text = aboutItem['location'] ?? '';
        _websiteController.text = aboutItem['website'] ?? '';
        _linkedinController.text = aboutItem['linkedin'] ?? '';
        _githubController.text = aboutItem['github'] ?? '';
        _resumeController.text = aboutItem['resumeUrl'] ?? '';
      }
    }
  }

  Future<void> _saveAboutData(bool isHindi) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        final data = {
          'title': _titleController.text,
          'description': _bioController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'website': _websiteController.text,
          'linkedin': _linkedinController.text,
          'github': _githubController.text,
          'resumeUrl': _resumeController.text,
        };
        
        final aboutState = ref.read(aboutStateProvider);
        final about = aboutState.about;
        String? aboutId;
        if (about != null) {
          final aboutData = about['data'];
          if (aboutData != null && aboutData is List && aboutData.isNotEmpty) {
            aboutId = aboutData[0]['_id'];
          }
        }
        
        if (aboutId != null) {
          await ref.read(aboutNotifierProvider.notifier).updateAbout(aboutId, data);
        } else {
          await ref.read(aboutNotifierProvider.notifier).createAbout(data);
        }
        
        setState(() => _isLoading = false);
        
        if (mounted) {
          final updatedState = ref.read(aboutStateProvider);
          if (updatedState.status == AboutStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${getLocalizedString('aboutSaveFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: ${updatedState.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(getLocalizedString('aboutSaved', isHindi ? AppLanguage.hi : AppLanguage.en)),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${getLocalizedString('aboutSaveFailed', isHindi ? AppLanguage.hi : AppLanguage.en)}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
