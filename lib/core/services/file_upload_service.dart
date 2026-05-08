import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'firebase_storage_service.dart';

/// Service to handle file uploads from device to Firebase Storage
class FileUploadService {
  final FirebaseStorageService _storageService;
  final ImagePicker _imagePicker = ImagePicker();

  FileUploadService(this._storageService);

  /// Pick and upload image from gallery
  Future<String?> pickAndUploadImage({
    required BuildContext context,
    required String folderPath,
    String? fileName,
    int quality = 80,
  }) async {
    try {
      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      // Show loading
      if (context.mounted) {
        _showLoadingDialog(context, 'Uploading image...');
      }

      // Upload to Firebase
      final file = File(pickedFile.path);
      final name = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      final path = '$folderPath/$name.jpg';

      final downloadUrl = await _storageService.uploadImage(
        imageFile: file,
        path: path,
        quality: quality,
      );

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return downloadUrl;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, 'Failed to upload image: $e');
      }
      return null;
    }
  }

  /// Pick and upload image from camera
  Future<String?> captureAndUploadImage({
    required BuildContext context,
    required String folderPath,
    String? fileName,
    int quality = 80,
  }) async {
    try {
      // Capture image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      // Show loading
      if (context.mounted) {
        _showLoadingDialog(context, 'Uploading image...');
      }

      // Upload to Firebase
      final file = File(pickedFile.path);
      final name = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      final path = '$folderPath/$name.jpg';

      final downloadUrl = await _storageService.uploadImage(
        imageFile: file,
        path: path,
        quality: quality,
      );

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return downloadUrl;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, 'Failed to upload image: $e');
      }
      return null;
    }
  }

  /// Pick and upload any file
  Future<String?> pickAndUploadFile({
    required BuildContext context,
    required String folderPath,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.single.path == null) return null;

      // Show loading
      if (context.mounted) {
        _showLoadingDialog(context, 'Uploading file...');
      }

      // Upload to Firebase
      final file = File(result.files.single.path!);
      final name = result.files.single.name;
      final path = '$folderPath/$name';

      final downloadUrl = await _storageService.uploadFile(
        file: file,
        path: path,
      );

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return downloadUrl;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, 'Failed to upload file: $e');
      }
      return null;
    }
  }

  /// Show image picker options (Gallery or Camera)
  Future<String?> showImagePickerOptions({
    required BuildContext context,
    required String folderPath,
    String? fileName,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return null;

    if (source == ImageSource.gallery) {
      return await pickAndUploadImage(
        context: context,
        folderPath: folderPath,
        fileName: fileName,
      );
    } else {
      return await captureAndUploadImage(
        context: context,
        folderPath: folderPath,
        fileName: fileName,
      );
    }
  }

  /// Delete file from Firebase Storage
  Future<bool> deleteFile({
    required BuildContext context,
    required String fileUrl,
  }) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(fileUrl);
      final path = uri.pathSegments.join('/');

      await _storageService.deleteFile(path);
      return true;
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to delete file: $e');
      }
      return false;
    }
  }

  /// Show loading dialog
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
