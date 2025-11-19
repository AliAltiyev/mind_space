#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Script to check and add missing translation keys to all language files"""

import json
import os
from pathlib import Path

def get_all_keys(obj, prefix=""):
    """Recursively get all keys from a nested dictionary"""
    keys = []
    for key, value in obj.items():
        full_key = f"{prefix}.{key}" if prefix else key
        keys.append(full_key)
        if isinstance(value, dict):
            keys.extend(get_all_keys(value, full_key))
    return keys

def get_nested_value(obj, key_path):
    """Get value from nested dictionary using dot notation"""
    keys = key_path.split('.')
    value = obj
    for key in keys:
        if isinstance(value, dict) and key in value:
            value = value[key]
        else:
            return None
    return value

def set_nested_value(obj, key_path, value):
    """Set value in nested dictionary using dot notation"""
    keys = key_path.split('.')
    current = obj
    for key in keys[:-1]:
        if key not in current:
            current[key] = {}
        current = current[key]
    current[keys[-1]] = value

def load_json(file_path):
    """Load JSON file with UTF-8 encoding"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return {}

def save_json(file_path, data):
    """Save JSON file with UTF-8 encoding and proper formatting"""
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

def main():
    translations_dir = Path("assets/translations")
    base_file = translations_dir / "en.json"
    
    # Load base file (English)
    base_data = load_json(base_file)
    if not base_data:
        print("Error: Could not load base file (en.json)")
        return
    
    # Get all keys from base file
    base_keys = get_all_keys(base_data)
    print(f"Found {len(base_keys)} keys in en.json")
    
    # Language files to check
    lang_files = ["ru.json", "es.json", "fr.json", "hi.json", "tk.json", "tr.json", "zh.json"]
    
    for lang_file in lang_files:
        file_path = translations_dir / lang_file
        if not file_path.exists():
            print(f"Warning: {lang_file} does not exist, skipping...")
            continue
        
        print(f"\nChecking {lang_file}...")
        lang_data = load_json(file_path)
        missing_keys = []
        
        # Check for missing keys
        for key in base_keys:
            if get_nested_value(lang_data, key) is None:
                missing_keys.append(key)
                # Get value from base file
                base_value = get_nested_value(base_data, key)
                if base_value is not None:
                    set_nested_value(lang_data, key, base_value)
                    print(f"  Added missing key: {key} (using English as placeholder)")
        
        if missing_keys:
            # Save updated file
            save_json(file_path, lang_data)
            print(f"  Updated {lang_file} with {len(missing_keys)} missing keys")
        else:
            print(f"  ✓ {lang_file} is complete!")

if __name__ == "__main__":
    main()

