import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/document_service.dart';
import '../ui/design_tokens.dart';

class DocumentUpload extends StatefulWidget {
  final Function(List<PlatformFile>) onFilesSelected;
  final List<PlatformFile> selectedFiles;

  const DocumentUpload({
    super.key,
    required this.onFilesSelected,
    required this.selectedFiles,
  });

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final files = await DocumentService.pickDocuments();
      if (files != null) {
        // Add new files to existing ones
        final updatedFiles = [...widget.selectedFiles, ...files];
        widget.onFilesSelected(updatedFiles);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFile(int index) {
    final updatedFiles = [...widget.selectedFiles];
    updatedFiles.removeAt(index);
    widget.onFilesSelected(updatedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관련 서류 첨부',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: DesignTokens.spacingSmall),
        Text(
          '상담에 필요한 서류를 첨부해 주세요 (선택사항)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: DesignTokens.spacingBase),
        
        // Upload button
        InkWell(
          onTap: _isLoading ? null : _pickDocuments,
          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spacingSection),
            decoration: BoxDecoration(
              border: Border.all(
                color: DesignTokens.border,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
              color: DesignTokens.bgAlt,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: DesignTokens.primary,
                ),
                SizedBox(height: DesignTokens.spacingBase),
                Text(
                  '파일 선택',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: DesignTokens.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DesignTokens.spacingSmall),
                Text(
                  '최대 10MB, PDF/이미지/문서 파일',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (_isLoading) ...[
                  SizedBox(height: DesignTokens.spacingBase),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),

        // Error message
        if (_errorMessage != null) ...[
          SizedBox(height: DesignTokens.spacingBase),
          Container(
            padding: EdgeInsets.all(DesignTokens.spacingBase),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                SizedBox(width: DesignTokens.spacingBase),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Selected files list
        if (widget.selectedFiles.isNotEmpty) ...[
          SizedBox(height: DesignTokens.spacingSection),
          Text(
            '첨부된 파일 (${widget.selectedFiles.length}개)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: DesignTokens.spacingBase),
          ...widget.selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: DesignTokens.spacingSmall),
              padding: EdgeInsets.all(DesignTokens.spacingBase),
              decoration: BoxDecoration(
                border: Border.all(color: DesignTokens.border),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(
                    DocumentService.getFileIcon(file.name),
                    style: const TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: DesignTokens.spacingBase),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DocumentService.getFileSizeString(file.size),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removeFile(index),
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }).toList(),
        ],

        // Info box
        SizedBox(height: DesignTokens.spacingBase),
        Container(
          padding: EdgeInsets.all(DesignTokens.spacingBase),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: DesignTokens.spacingBase),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '파일 첨부 안내',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacingSmall),
                    Text(
                      '• 처분 통지서, 신청서, 관련 서류 등\n'
                      '• 개인정보는 안전하게 보호됩니다\n'
                      '• 파일은 상담 목적으로만 사용됩니다',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}