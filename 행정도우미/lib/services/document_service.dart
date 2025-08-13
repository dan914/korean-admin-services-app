import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../utils/logger.dart';

class DocumentService {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxTotalSize = 50 * 1024 * 1024; // 50MB total
  static const int maxFileCount = 10; // Maximum 10 files
  
  static const List<String> allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png',  // Remove gif for security
    'doc', 'docx', 'xls', 'xlsx',
    'hwp', 'txt'
  ];
  
  // MIME types for additional validation
  static const List<String> allowedMimeTypes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
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
        // Check file count
        if (result.files.length > maxFileCount) {
          throw Exception('최대 $maxFileCount개의 파일만 업로드할 수 있습니다.');
        }
        
        // Calculate total size
        int totalSize = 0;
        for (final file in result.files) {
          totalSize += file.size;
        }
        
        if (totalSize > maxTotalSize) {
          throw Exception('전체 파일 크기가 50MB를 초과합니다.');
        }
        
        // Validate individual files
        final validFiles = <PlatformFile>[];
        for (final file in result.files) {
          // Check file size
          if (file.size > maxFileSize) {
            Logger.warning('File ${file.name} exceeds size limit');
            continue;
          }
          
          // Check file extension
          final ext = getFileExtension(file.name);
          if (!allowedExtensions.contains(ext)) {
            Logger.warning('File ${file.name} has invalid extension: $ext');
            continue;
          }
          
          // Additional security: check for double extensions
          if (file.name.split('.').length > 2) {
            Logger.warning('File ${file.name} has suspicious double extension');
            continue;
          }
          
          validFiles.add(file);
        }
        
        if (validFiles.isEmpty) {
          throw Exception('업로드 가능한 파일이 없습니다. 파일 형식과 크기를 확인해주세요.');
        }
        
        Logger.info('Selected ${validFiles.length} valid files for upload');
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