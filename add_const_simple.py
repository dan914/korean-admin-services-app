#!/usr/bin/env python3
"""
Simplified script to add const constructors to Flutter widgets
"""

import os
import re
from pathlib import Path

def add_const_to_widgets(content):
    """Add const to common widgets where appropriate"""
    
    replacements = [
        # Empty SizedBox
        ('SizedBox()', 'const SizedBox()'),
        
        # SizedBox with literal height
        ('SizedBox(height: 4)', 'const SizedBox(height: 4)'),
        ('SizedBox(height: 8)', 'const SizedBox(height: 8)'),
        ('SizedBox(height: 12)', 'const SizedBox(height: 12)'),
        ('SizedBox(height: 16)', 'const SizedBox(height: 16)'),
        ('SizedBox(height: 20)', 'const SizedBox(height: 20)'),
        ('SizedBox(height: 24)', 'const SizedBox(height: 24)'),
        
        # SizedBox with literal width
        ('SizedBox(width: 4)', 'const SizedBox(width: 4)'),
        ('SizedBox(width: 8)', 'const SizedBox(width: 8)'),
        ('SizedBox(width: 12)', 'const SizedBox(width: 12)'),
        ('SizedBox(width: 16)', 'const SizedBox(width: 16)'),
        
        # Empty Divider
        ('Divider()', 'const Divider()'),
        
        # CircularProgressIndicator
        ('CircularProgressIndicator()', 'const CircularProgressIndicator()'),
        
        # Common Icons
        ('Icon(Icons.close)', 'const Icon(Icons.close)'),
        ('Icon(Icons.close, size: 20)', 'const Icon(Icons.close, size: 20)'),
        ('Icon(Icons.check)', 'const Icon(Icons.check)'),
        ('Icon(Icons.add)', 'const Icon(Icons.add)'),
        ('Icon(Icons.edit)', 'const Icon(Icons.edit)'),
        ('Icon(Icons.delete)', 'const Icon(Icons.delete)'),
        ('Icon(Icons.download)', 'const Icon(Icons.download)'),
        ('Icon(Icons.upload)', 'const Icon(Icons.upload)'),
        ('Icon(Icons.refresh)', 'const Icon(Icons.refresh)'),
    ]
    
    modified = content
    for old, new in replacements:
        # Only replace if not already const
        if f'const {old}' not in modified:
            modified = modified.replace(old, new)
    
    # Remove double const
    modified = modified.replace('const const ', 'const ')
    
    return modified

def process_file(filepath):
    """Process a single Dart file"""
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Skip test files
    if 'test' in str(filepath) or 'test_' in str(filepath):
        return
    
    # Apply const additions
    content = add_const_to_widgets(content)
    
    # Write back if changed
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Updated {filepath.name}")

def main():
    updated_count = 0
    
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
            if 'korean_admin_source_code' not in str(dart_file):
                process_file(dart_file)

if __name__ == '__main__':
    main()