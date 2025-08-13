#!/usr/bin/env python3
"""
Script to replace print statements with Logger calls in Dart files
"""

import os
import re
from pathlib import Path

# Define replacements for different types of print statements
replacements = [
    # Success patterns
    (r"print\('✅\s*(.*?)'\);?", r"Logger.success('\1');"),
    (r'print\("✅\s*(.*?)"\);?', r"Logger.success('\1');"),
    
    # Error patterns  
    (r"print\('❌\s*(.*?)'\);?", r"Logger.error('\1');"),
    (r'print\("❌\s*(.*?)"\);?', r"Logger.error('\1');"),
    
    # Warning patterns
    (r"print\('⚠️\s*(.*?)'\);?", r"Logger.warning('\1');"),
    (r'print\("⚠️\s*(.*?)"\);?', r"Logger.warning('\1');"),
    
    # Info patterns (various emoji indicators)
    (r"print\('🔔\s*(.*?)'\);?", r"Logger.info('\1');"),
    (r"print\('📧\s*(.*?)'\);?", r"Logger.info('\1');"),
    (r"print\('📤\s*(.*?)'\);?", r"Logger.info('\1');"),
    (r"print\('🚀\s*(.*?)'\);?", r"Logger.info('\1');"),
    (r'print\("🔔\s*(.*?)"\);?', r"Logger.info('\1');"),
    
    # Debug patterns
    (r"print\('🔍\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r"print\('📋\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r"print\('📌\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r"print\('📍\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r"print\('🎯\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r"print\('➡️\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r"print\('📊\s*(.*?)'\);?", r"Logger.debug('\1');"),
    (r'print\("🔍\s*(.*?)"\);?', r"Logger.debug('\1');"),
    
    # Generic patterns (fallback to debug)
    (r"print\('(.*?)'\);?", r"Logger.debug('\1');"),
    (r'print\("(.*?)"\);?', r"Logger.debug('\1');"),
]

def add_logger_import(content):
    """Add Logger import if not already present"""
    if "import '../utils/logger.dart';" in content or "import 'package:admin_app/utils/logger.dart';" in content:
        return content
    
    # Find the last import statement
    import_pattern = r"^import\s+['\"].*?['\"];?\s*$"
    lines = content.split('\n')
    last_import_idx = -1
    
    for i, line in enumerate(lines):
        if re.match(import_pattern, line.strip()):
            last_import_idx = i
    
    if last_import_idx >= 0:
        # Determine the right import path based on the file
        if 'admin_app' in str(Path.cwd()):
            import_stmt = "import '../utils/logger.dart';"
        else:
            import_stmt = "import '../utils/logger.dart';"
        
        lines.insert(last_import_idx + 1, import_stmt)
        return '\n'.join(lines)
    
    return content

def process_file(filepath):
    """Process a single Dart file"""
    print(f"Processing {filepath}")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Skip logger.dart itself
    if 'logger.dart' in str(filepath):
        print(f"  Skipping logger.dart")
        return
    
    # Skip test files
    if 'test' in str(filepath) or 'test_' in str(filepath):
        print(f"  Skipping test file")
        return
    
    # Apply replacements
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)
    
    # Add import if needed and print statements were replaced
    if content != original_content:
        content = add_logger_import(content)
        
        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ Updated {filepath}")
    else:
        print(f"  No changes needed")

def main():
    # Process 행정도우미 app
    app_dir = Path('/Users/yujumyeong/coding projects/행정사/행정도우미')
    if app_dir.exists():
        print("Processing 행정도우미 app...")
        for dart_file in app_dir.rglob('*.dart'):
            if 'korean_admin_source_code' not in str(dart_file):
                process_file(dart_file)
    
    # Process admin_app
    admin_dir = Path('/Users/yujumyeong/coding projects/행정사/admin_app')
    if admin_dir.exists():
        print("\nProcessing admin_app...")
        for dart_file in admin_dir.rglob('*.dart'):
            if 'korean_admin_source_code' not in str(dart_file) and 'test_auth.dart' not in str(dart_file):
                process_file(dart_file)

if __name__ == '__main__':
    main()