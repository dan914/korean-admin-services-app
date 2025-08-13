#!/usr/bin/env python3
"""
Script to add const constructors to Flutter widgets for performance optimization
"""

import os
import re
from pathlib import Path

def add_const_to_widgets(content):
    """Add const to common widgets where appropriate"""
    
    # Patterns to replace - widgets with only literal values
    patterns = [
        # SizedBox with only literal height/width
        (r'(\s+)SizedBox\(height:\s*(\d+(?:\.\d+)?)\)', r'\1const SizedBox(height: \2)'),
        (r'(\s+)SizedBox\(width:\s*(\d+(?:\.\d+)?)\)', r'\1const SizedBox(width: \2)'),
        (r'(\s+)SizedBox\(\)', r'\1const SizedBox()'),
        
        # Divider with no parameters or only literal values
        (r'(\s+)Divider\(\)', r'\1const Divider()'),
        (r'(\s+)Divider\(height:\s*(\d+(?:\.\d+)?)\)', r'\1const Divider(height: \2)'),
        
        # Icon with literal icon and optional size
        (r'(\s+)Icon\(Icons\.\w+\)', r'\1const Icon(Icons.\1)'),
        (r'(\s+)Icon\(Icons\.\w+,\s*size:\s*(\d+(?:\.\d+)?)\)', r'\1const Icon(Icons.\1, size: \2)'),
        
        # Text with literal strings
        (r"(\s+)Text\('([^']+)'\)", r"\1const Text('\2')"),
        (r'(\s+)Text\("([^"]+)"\)', r'\1const Text("\2")'),
        
        # EdgeInsets
        (r'(\s+)EdgeInsets\.all\((\d+(?:\.\d+)?)\)', r'\1const EdgeInsets.all(\2)'),
        (r'(\s+)EdgeInsets\.symmetric\(', r'\1const EdgeInsets.symmetric('),
        (r'(\s+)EdgeInsets\.only\(', r'\1const EdgeInsets.only('),
        
        # CircularProgressIndicator
        (r'(\s+)CircularProgressIndicator\(\)', r'\1const CircularProgressIndicator()'),
        
        # Remove duplicate const
        (r'const\s+const\s+', r'const '),
    ]
    
    modified = content
    for pattern, replacement in patterns:
        # Skip if already has const
        if not re.search(r'const\s+' + pattern[6:], modified):
            modified = re.sub(pattern, replacement, modified)
    
    # Special handling for SizedBox with DesignTokens (these can't be const)
    # Revert const for DesignTokens usage
    modified = re.sub(
        r'const\s+SizedBox\((height|width):\s*(DesignTokens\.\w+)',
        r'SizedBox(\1: \2',
        modified
    )
    
    return modified

def process_file(filepath):
    """Process a single Dart file"""
    print(f"Processing {filepath}")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Skip test files
    if 'test' in str(filepath) or 'test_' in str(filepath):
        print(f"  Skipping test file")
        return
    
    # Apply const additions
    content = add_const_to_widgets(content)
    
    # Write back if changed
    if content != original_content:
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
            if 'korean_admin_source_code' not in str(dart_file):
                process_file(dart_file)

if __name__ == '__main__':
    main()