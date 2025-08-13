import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../utils/logger.dart';

class DocumentService {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'gif',
    'doc', 'docx', 'xls', 'xlsx',
    'hwp', 'txt'
  ];

  static Future<List<PlatformFile>?> pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: true, // For web support
      );
      
      if (result != null) {
        // Validate file sizes
        final validFiles = result.files.where((file) {
          if (file.size > maxFileSize) {
            return false;
          }
          return true;
        }).toList();
        
        if (validFiles.isEmpty) {
          throw Exception('파일 크기가 10MB를 초과합니다.');
        }
        
        return validFiles;
      }
      return null;
    } catch (e) {
      Logger.debug('Error picking documents: $e');
      rethrow;
    }
  }

  static String getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }

  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  static String getFileIcon(String filename) {
    final extension = getFileExtension(filename);
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'doc':
      case 'docx':
      case 'hwp':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      default:
        return '📎';
    }
  }
}