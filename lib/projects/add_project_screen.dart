import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'project_notifier.dart';

class AddProjectScreen extends ConsumerStatefulWidget {
  const AddProjectScreen({super.key});

  @override
  ConsumerState<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _repositoryUrlController = TextEditingController();
  final List<String> _technologies = [];
  final List<String> _images = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Project Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _projectUrlController,
                decoration: const InputDecoration(
                  labelText: 'Project URL',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _repositoryUrlController,
                decoration: const InputDecoration(
                  labelText: 'Repository URL',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter repository URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Technologies Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Technologies'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _technologies.map((tech) => Chip(
                          label: Text(tech),
                          onDeleted: () {
                            setState(() {
                              _technologies.remove(tech);
                            });
                          },
                        )).toList(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _addTechnologyField();
                    },
                    child: const Text('Add Technology'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Images'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _images.map((image) => Chip(
                          label: Text(image.split('/').last),
                          onDeleted: () {
                            setState(() {
                              _images.remove(image);
                            });
                          },
                        )).toList(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child: const Text('Add Image'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Project',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  void _addTechnologyField() {
    setState(() {
      _technologies.add('');
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null) {
        setState(() {
          _images.add(result.files.single.path!);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final projectData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'projectUrl': _projectUrlController.text,
        'repositoryUrl': _repositoryUrlController.text,
        'technologies': _technologies.where((tech) => tech.isNotEmpty).toList(),
        'images': _images,
      };
      
      await ref.read(projectNotifierProvider.notifier).addProject(Project(
        id: '', // Will be set by backend
        title: projectData['title'] as String,
        description: projectData['description'] as String,
        technologies: List<String>.from(projectData['technologies'] as List),
        images: List<String>.from(projectData['images'] as List),
        projectUrl: projectData['projectUrl'] as String,
        repositoryUrl: projectData['repositoryUrl'] as String,
        createdBy: '', // Will be set by backend
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    _repositoryUrlController.dispose();
    super.dispose();
  }
}
