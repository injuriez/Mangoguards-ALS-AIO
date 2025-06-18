#!/usr/bin/env python3
"""
MangoGuards Unit Manager - Simple Desktop Application
A standalone desktop application that loads the HTML file directly using webview
"""

import os
import sys
import json

# Check for required modules and provide helpful error messages
try:
    import webview
except ImportError:
    print("ERROR: 'webview' module not found!")
    print("The webview module comes from the 'pywebview' package.")
    print("Please run setup_python_deps.bat to install required dependencies.")
    print("Or manually install with: pip install pywebview==4.4.1")
    print("NOTE: Install 'pywebview' NOT 'webview' - they are different packages!")
    input("Press Enter to exit...")
    sys.exit(1)

try:
    import win32gui
    import win32ui
    import win32con
    import win32api
except ImportError as e:
    print("ERROR: 'pywin32' module not found!")
    print(f"Import error details: {e}")
    print(f"Python executable: {sys.executable}")
    print(f"Python version: {sys.version}")
    print(f"Virtual environment: {os.environ.get('VIRTUAL_ENV', 'None')}")
    print(f"In virtual env: {hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix)}")
    print("")
    print("This module provides Windows API access.")
    print("")
    print("VIRTUAL ENVIRONMENT ISSUE DETECTED!" if os.environ.get('VIRTUAL_ENV') else "")
    print("Try these solutions in order:")
    print("1. If in virtual environment, install there: pip install pywin32")
    print("2. Or install globally: pip install --user pywin32")
    print("3. Run fix_pywin32.bat")
    print("4. Run setup_python_deps.bat as Administrator")
    print("5. Manual install: pip install pywin32")
    print("6. If that fails, try: pip install --upgrade pywin32")
    print("5. If still failing, try: pip install --user pywin32")
    print("6. After install, run: python Scripts/pywin32_postinstall.py -install")
    print("")
    print("Note: Make sure you're using the same Python that has pywin32 installed.")
    input("Press Enter to exit...")
    sys.exit(1)

try:
    import cv2
    import numpy as np
except ImportError:
    print("ERROR: 'opencv-python' or 'numpy' module not found!")
    print("Please run setup_python_deps.bat to install required dependencies.")
    print("Or manually install with: pip install opencv-python numpy")
    input("Press Enter to exit...")
    sys.exit(1)

try:
    import wscreenshot
except ImportError:
    print("ERROR: 'wscreenshot' module not found!")
    print("Please run setup_python_deps.bat to install required dependencies.")
    print("Or manually install with: pip install wscreenshot")
    input("Press Enter to exit...")
    sys.exit(1)

import time
from datetime import datetime
import subprocess
import ctypes
from ctypes import wintypes
import threading
import logging
import base64

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_FILE = os.path.join(SCRIPT_DIR, 'vanguards_config.txt')

# Set up logging
LOG_FILE = os.path.join(SCRIPT_DIR, 'Logs.log')
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()  # Also print to console
    ]
)
logger = logging.getLogger(__name__)

# Global variable to store configuration
unit_config = {}

class UnitManagerAPI:
    """API class to handle JavaScript calls from the web view"""
    
    def __init__(self):
        self.load_config()
        # Migrate existing PNG screenshots to base64 embedded format
        migration_result = self.migrate_screenshots_to_base64()
        if migration_result['migrated_count'] > 0:
            logger.info(f"Screenshot migration: {migration_result['message']}")
    def load_config(self):
        """Load unit configuration from vanguards_config.txt file"""
        global unit_config
        try:
            # First create default configuration for all slots
            self.create_default_config()
              # Then load and override with any existing configuration
            if os.path.exists(CONFIG_FILE):
                with open(CONFIG_FILE, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith('//'):
                            self.parse_config_line(line)
        except Exception as e:
            print(f"Error loading config: {e}")
            self.create_default_config()

    def parse_config_line(self, line):
        """Parse a single line from vanguards_config.txt"""
        global unit_config
        try:
            # Debug: print the line being parsed
            logger.info(f"Parsing config line: {line}")
              # Current format: SLOT#:placement:slot_number:unit_name:priority:auto_skill:coordinates|upgrade_level:priority|status
            # Format: SLOT#:placement:slot_number:unit_name:priority:auto_skill:coordinates|upgrade_level:priority|status
            
            # First, separate the status flag at the very end
            if '|' in line:
                line_parts = line.rsplit('|', 1)
                main_line = line_parts[0]
                status_is_set = len(line_parts) > 1 and line_parts[1] == '1'
            else:
                main_line = line
                status_is_set = False
            
            logger.info(f"Main line: {main_line}, Status set: {status_is_set}")
            
            # Now split the main line by colons
            parts = main_line.split(':')
            logger.info(f"Split parts: {parts}")            
            if len(parts) >= 7:  # New format: SLOT#:placement:slot_number:unit_name:priority:auto_skill:coordinates
                slot_name = parts[0]
                placement_str = parts[1]
                slot_number_part = parts[2]
                unit_name = parts[3]
                priority = parts[4]
                auto_skill = parts[5]  # Changed from upgrade_part to auto_skill
                coords_and_upgrades = ':'.join(parts[6:])  # Join remaining parts in case coordinates contain colons
                
                logger.info(f"Parsed - slot: {slot_name}, placement: {placement_str}, unit: {unit_name}")
                logger.info(f"Priority: {priority}, auto_skill: {auto_skill}, coords_and_upgrades: {coords_and_upgrades}")
                
            elif len(parts) >= 6:  # Fallback for older format
                slot_name = parts[0]
                placement_str = parts[1]
                priority = parts[2]
                unit_name = parts[3]
                skill_part = parts[4]
                auto_skill = 'none'  # Default for old format
                coords_and_upgrades = ':'.join(parts[5:])
                # Convert old skill to new format
                skill_map = {'1': 'skill1', '2': 'skill2', '3': 'skill3', '4': 'none'}
                auto_skill = skill_map.get(skill_part, 'none')
            else:
                logger.warning(f"Invalid config line format: {line}")
                return

            slot_number = slot_name.replace('SLOT', '')
            slot_key = f'slot{slot_number}'
            
            # Parse coordinates and upgrade data
            # Format might be: "522,65|1:1" (coordinates|upgrade_level:priority)
            parsed_coords_list = []
            marker_upgrades = {}
            
            if status_is_set and coords_and_upgrades:
                # Split by semicolon for multiple markers
                coord_pairs = coords_and_upgrades.split(';')
                
                for marker_index, pair_str in enumerate(coord_pairs):
                    logger.info(f"Processing marker {marker_index}: {pair_str}")
                    
                    if '|' in pair_str:
                        # Format: "x,y|upgrade_level:priority"
                        coord_part, upgrade_data = pair_str.split('|', 1)
                        
                        # Parse coordinates
                        if ',' in coord_part:
                            x_str, y_str = coord_part.split(',', 1)
                            try:
                                x, y = int(x_str.strip()), int(y_str.strip())
                                parsed_coords_list.append({'x': x, 'y': y, 'set': True})
                                logger.info(f"Coordinates: ({x}, {y})")
                            except ValueError:
                                parsed_coords_list.append({'x': 0, 'y': 0, 'set': False})
                                logger.warning(f"Invalid coordinates: {coord_part}")
                        else:
                            parsed_coords_list.append({'x': 0, 'y': 0, 'set': False})
                        
                        # Parse upgrade data "level:priority"
                        if ':' in upgrade_data:
                            level_str, priority_str = upgrade_data.split(':', 1)
                            marker_upgrades[marker_index] = {
                                'level': level_str.strip(),
                                'priority': priority_str.strip()
                            }
                            logger.info(f"Marker {marker_index} upgrades: level={level_str}, priority={priority_str}")
                        else:
                            # Just upgrade level
                            marker_upgrades[marker_index] = {
                                'level': upgrade_data.strip(),
                                'priority': '1'
                            }
                            logger.info(f"Marker {marker_index} upgrade level: {upgrade_data}")
                    
                    elif ',' in pair_str:
                        # Just coordinates, no upgrade data
                        x_str, y_str = pair_str.split(',', 1)
                        try:
                            x, y = int(x_str.strip()), int(y_str.strip())
                            parsed_coords_list.append({'x': x, 'y': y, 'set': True})
                        except ValueError:
                            parsed_coords_list.append({'x': 0, 'y': 0, 'set': False})
                        
                        marker_upgrades[marker_index] = {
                            'level': '1',
                            'priority': '1'
                        }
                    else:
                        # Invalid marker data
                        parsed_coords_list.append({'x': 0, 'y': 0, 'set': False})
                        marker_upgrades[marker_index] = {
                            'level': '1',
                            'priority': '1'
                        }
            else:
                # No coordinates set, create default structure
                num_placements = int(placement_str) if placement_str.isdigit() else 1
                for i in range(num_placements):
                    parsed_coords_list.append({'x': 0, 'y': 0, 'set': False})
                    marker_upgrades[i] = {'level': '1', 'priority': '1'}
              # Set default skill for new format
            if len(parts) >= 7:
                skill = auto_skill
            else:
                skill = auto_skill  # Already set in the old format conversion
            
            # Store the configuration
            unit_config[slot_key] = {
                'placement': placement_str,
                'priority': priority,
                'skill': skill,
                'upgrade': '0',  # Default upgrade value since individual marker upgrades are handled separately
                'unit_name': unit_name,
                'coords': parsed_coords_list,
                'marker_upgrades': marker_upgrades
            }
            
            logger.info(f"Successfully parsed slot {slot_key}: {unit_config[slot_key]}")
            
        except Exception as e:
            logger.error(f"Error parsing config line: {line}, error: {e}")
            print(f"Error parsing config line: {line}, error: {e}")
    
    def create_default_config(self):
        """Create default configuration"""
        global unit_config
        unit_config = {
            f'slot{i}': {
                'placement': '1',
                'priority': str(i),
                'skill': 'none',
                'upgrade': '0',  # Add default upgrade level
                'unit_name': '',
                'coords': [{'x': 0, 'y': 0, 'set': False}],  # Store as list for multi-marker support
                'marker_upgrades': {0: {'level': '1', 'priority': '1'}}  # Default marker upgrade levels as dict
            } for i in range(1, 7)
        }
        # Don't save the config here - let load_config() preserve existing data
    
    def save_config(self):
        """Save unit configuration to vanguards_config.txt file"""
        try:
            with open(CONFIG_FILE, 'w') as f:
                for i in range(1, 7):
                    slot_key = f'slot{i}'
                    if slot_key in unit_config:
                        slot = unit_config[slot_key]
                        
                        # Skip disabled slots - don't write them to the config file
                        if slot.get('disabled', False):
                            continue
                          # Skip disabled slots - don't write them to the config file
                        if slot.get('disabled', False):
                            continue
                          # Get auto skill value directly (supports new auto skills)
                        auto_skill = slot.get('skill', 'none')
                        coords_list = slot.get('coords', [])
                        marker_upgrades = slot.get('marker_upgrades', {})
                        placement_count = int(slot.get('placement', '1'))  # Get current placement count
                        
                        coords_with_upgrades = []
                        all_coords_set = True
                        
                        if isinstance(coords_list, list) and len(coords_list) > 0:
                            # Only process coordinates up to the current placement count
                            coords_to_process = coords_list[:placement_count]
                            for marker_index, coord_entry in enumerate(coords_to_process):
                                if isinstance(coord_entry, dict):
                                    x = coord_entry.get('x', 0)
                                    y = coord_entry.get('y', 0)
                                      # Get marker-specific upgrade level and priority, with fallbacks
                                    upgrade_data = marker_upgrades.get(str(marker_index), 
                                                   marker_upgrades.get(marker_index, 
                                                   slot.get('upgrade', '1')))
                                      # Handle both old format (just level) and new format (dict with level and priority)
                                    if isinstance(upgrade_data, dict):
                                        level = upgrade_data.get('level', '1')
                                        priority = upgrade_data.get('priority', '1')
                                        upgrade_str = f"{level}:{priority}"
                                    elif isinstance(upgrade_data, str) and upgrade_data.startswith('{'):
                                        # Handle case where upgrade_data is a JSON string
                                        try:
                                            import json
                                            parsed_data = json.loads(upgrade_data.replace("'", '"'))
                                            level = parsed_data.get('level', '1')
                                            priority = parsed_data.get('priority', '1')
                                            upgrade_str = f"{level}:{priority}"
                                        except:
                                            upgrade_str = "1:1"  # Fallback
                                    else:
                                        # Legacy format - just level
                                        upgrade_str = str(upgrade_data)
                                    
                                    coords_with_upgrades.append(f"{x},{y}|{upgrade_str}")
                                    
                                    if not coord_entry.get('set', False):
                                        all_coords_set = False
                                else:
                                    # Handle invalid entries
                                    coords_with_upgrades.append("0,0|1")
                                    all_coords_set = False
                            
                            if not coords_with_upgrades: # If list was empty or all items were invalid
                                coords_str_to_save = "0,0|1"
                                all_coords_set = False
                            else:
                                coords_str_to_save = ';'.join(coords_with_upgrades)
                        else: # Fallback for old format or uninitialized
                            coords_str_to_save = "0,0|1"
                            all_coords_set = False
                        
                        status_flag = '1' if all_coords_set and coords_with_upgrades else '0'
                        
                        unit_name = slot.get('unit_name', '')
                        placement_count = slot.get('placement', '1') # This should reflect actual number of coords intended
                          # Format: SLOT#:placement:slot_number:unit_name:priority:auto_skill:coords_with_upgrades|status
                        # Changed from skill_num to auto_skill to support new skill types
                        line = f"SLOT{i}:{placement_count}:{i}:{unit_name}:{slot.get('priority', str(i))}:{auto_skill}:{coords_str_to_save}|{status_flag}"
                        f.write(line + '\n')
            return True
        except Exception as e:
            print(f"Error saving config: {e}")
            return False
    
    def get_config(self):
        """Get current configuration"""
        return unit_config
    
    def update_config(self, data):
        """Update configuration"""
        try:
            unit_config.update(data)
            success = self.save_config()
            return {'success': success, 'message': 'Configuration saved' if success else 'Error saving configuration'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
    def set_coordinates(self, slot_number, x, y, marker_index=0):
        """Set custom coordinates for a slot (supports multiple markers based on placement)"""
        try:
            slot_key = f'slot{slot_number}'
            
            # Ensure the slot exists, create default if missing
            if slot_key not in unit_config:
                unit_config[slot_key] = {
                    'placement': '1', 
                    'priority': str(slot_number), 
                    'skill': 'none',
                    'upgrade': '0',
                    'unit_name': '',
                    'coords': [{'x': 0, 'y': 0, 'set': False}],
                    'marker_upgrades': {0: {'level': '1', 'priority': '1'}}
                }
            
            # Initialize coordinates as array if not exists
            if 'coords' not in unit_config[slot_key] or not isinstance(unit_config[slot_key]['coords'], list):
                unit_config[slot_key]['coords'] = []
            
            # Ensure we have enough coordinate slots for the placement count
            placement_count = int(unit_config[slot_key].get('placement', '1'))
            while len(unit_config[slot_key]['coords']) < placement_count:
                unit_config[slot_key]['coords'].append({'x': 0, 'y': 0, 'set': False})
            
            # Set the specific marker coordinate
            if marker_index < len(unit_config[slot_key]['coords']):
                unit_config[slot_key]['coords'][marker_index] = {
                    'x': x,
                    'y': y,
                    'set': True
                }
            else: # If marker_index is out of bounds, expand the array
                while len(unit_config[slot_key]['coords']) <= marker_index:
                    unit_config[slot_key]['coords'].append({'x': 0, 'y': 0, 'set': False})
                unit_config[slot_key]['coords'][marker_index] = {
                    'x': x,
                    'y': y,
                    'set': True
                }

            # Ensure marker_upgrades exists and has entry for this marker
            if 'marker_upgrades' not in unit_config[slot_key]:
                unit_config[slot_key]['marker_upgrades'] = {}
            if marker_index not in unit_config[slot_key]['marker_upgrades']:
                unit_config[slot_key]['marker_upgrades'][marker_index] = {'level': '1', 'priority': '1'}
            
            success = self.save_config()
            # Return all coords for the slot to update UI if needed
            return {'success': success, 'coords': unit_config[slot_key]['coords'], 'marker_index': marker_index, 'message': 'Coordinate saved'}
        except Exception as e:
            print(f"Error in set_coordinates: {e}")
            return {'success': False, 'message': str(e)}

    def set_multiple_coordinates(self, slot_number, coords_string, placement_count):
        """Set multiple coordinates for a slot from a formatted string."""
        try:
            slot_key = f'slot{slot_number}'
            
            if slot_key not in unit_config:
                # Initialize slot if it's somehow missing (shouldn't happen with load_config)
                self.create_default_config() # This might be too broad, consider initializing just one slot
                if slot_key not in unit_config: # if still not there
                     unit_config[slot_key] = {
                        'placement': str(placement_count), 
                        'priority': str(slot_number), 
                        'skill': 'none',
                        'unit_name': '',
                        'coords': []
                    }

            parsed_coords_list = []
            if coords_string:
                coord_pairs = coords_string.split('|')
                for pair_str in coord_pairs:
                    if ',' in pair_str:
                        x_str, y_str = pair_str.split(',')
                        parsed_coords_list.append({'x': int(x_str), 'y': int(y_str), 'set': True})
                    else: # Should not happen with correct frontend formatting
                        parsed_coords_list.append({'x': 0, 'y': 0, 'set': False}) 
            
            # Ensure the list has `placement_count` items, padding if necessary
            # This ensures that if fewer coords are sent than placement_count, remaining are marked not set
            final_coords_list = []
            for i in range(int(placement_count)):
                if i < len(parsed_coords_list):
                    final_coords_list.append(parsed_coords_list[i])
                else:
                    final_coords_list.append({'x':0, 'y':0, 'set': False})

            unit_config[slot_key]['coords'] = final_coords_list
            unit_config[slot_key]['placement'] = str(placement_count) # Update placement based on UI
            
            success = self.save_config()
            if success:
                # Reload config to ensure consistency after save, then return the updated slot
                self.load_config() 
                return {'success': True, 'message': f'Coordinates for slot {slot_number} updated.', 'new_config_slot': unit_config.get(slot_key)}
            else:
                return {'success': False, 'message': 'Error saving coordinates.'}

        except Exception as e:
            print(f"Error in set_multiple_coordinates: {e}")
            return {'success': False, 'message': str(e)} 
    def get_slot_markers(self, slot_number):
        """Get all coordinate markers for a slot"""
        try:
            slot_key = f'slot{slot_number}'
            
            # Ensure the slot exists, create default if missing
            if slot_key not in unit_config:
                unit_config[slot_key] = {
                    'placement': '1',
                    'priority': str(slot_number),
                    'skill': 'none',
                    'upgrade': '0',
                    'unit_name': '',
                    'coords': [{'x': 0, 'y': 0, 'set': False}],
                    'marker_upgrades': {0: {'level': '1', 'priority': '1'}}
                }
                self.save_config()  # Save the newly created slot
            
            slot_data = unit_config[slot_key]
            placement_count = int(slot_data.get('placement', '1'))
            coords = slot_data.get('coords', [])
              # Ensure coords is a list and has the right number of markers
            if not isinstance(coords, list):
                coords = []
            
            while len(coords) < placement_count:
                coords.append({'x': 0, 'y': 0, 'set': False})
            
            return {
                'success': True, 
                'markers': coords[:placement_count],
                'placement_count': placement_count
            }
        except Exception as e:
            return {'success': False, 'message': str(e)}

    def export_config(self):
        """Export configuration"""
        try:
            import time
            export_data = {
                'version': '1.0',
                'timestamp': time.time(),
                'config': unit_config
            }
            return export_data
        except Exception as e:
            return {'error': str(e)}
    
    def import_config(self, data):
        """Import configuration from data"""
        try:
            if 'config' in data:
                unit_config.update(data['config'])
                success = self.save_config()
                return {'success': success, 'message': 'Configuration imported successfully'}
            else:
                return {'success': False, 'message': 'Invalid configuration format'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
    
    def get_config_list(self):
        """Get list of available config files from configs folder"""
        try:
            configs_dir = os.path.join(SCRIPT_DIR, 'configs')
            if not os.path.exists(configs_dir):
                return []
            
            config_files = []
            for file in os.listdir(configs_dir):
                if file.endswith('.txt'):
                    config_files.append(file)
            
            return sorted(config_files)
        except Exception as e:
            print(f"Error getting config list: {e}")
            return []
    
    def load_config_file(self, config_filename):
        """Load a specific config file and replace vanguards_config.txt"""
        try:
            configs_dir = os.path.join(SCRIPT_DIR, 'configs')
            source_file = os.path.join(configs_dir, config_filename)
            
            if not os.path.exists(source_file):
                return {'success': False, 'message': f'Config file {config_filename} not found'}
            
            # Read the source config file
            with open(source_file, 'r') as f:
                config_content = f.read()
              # Write to vanguards_config.txt
            with open(CONFIG_FILE, 'w') as f:
                f.write(config_content)
            
            # Reload the configuration
            self.load_config()
            
            return {'success': True, 'message': f'Configuration loaded from {config_filename}'}
        except Exception as e:
            print(f"Error loading config file: {e}")
            return {'success': False, 'message': str(e)}
    def check_tutorial(self):
        """Check if tutorial has been completed"""
        try:
            tutorial_file = os.path.join(SCRIPT_DIR, 'Tutorial.txt')
            return os.path.exists(tutorial_file)
        except Exception as e:
            print(f"Error checking tutorial: {e}")
            return False
    
    def complete_tutorial(self):
        """Mark tutorial as completed by creating Tutorial.txt"""
        try:
            tutorial_file = os.path.join(SCRIPT_DIR, 'Tutorial.txt')
            with open(tutorial_file, 'w') as f:
                f.write('Tutorial completed\n')
            return {'success': True, 'message': 'Tutorial completed'}    
        except Exception as e:
            print(f"Error completing tutorial: {e}")
            return {'success': False, 'message': str(e)}
    
    def align_with_roblox(self):
        """Align the Unit Manager window inside the ALS.ahk window progress area"""
        try:
            import win32gui
            import win32con
            
            # Find ALS.ahk window (Mango window)
            als_hwnd = None
            
            def enum_windows_callback(hwnd, windows):
                if win32gui.IsWindowVisible(hwnd):
                    window_text = win32gui.GetWindowText(hwnd)
                    # More flexible matching for the ALS window
                    if ('mango' in window_text.lower() or 
                        'als' in window_text.lower() or 
                        'winterportal' in window_text.lower()):
                        windows.append((hwnd, window_text))
                return True
            
            windows = []
            win32gui.EnumWindows(enum_windows_callback, windows)
            
            if not windows:
                # Also try finding by window class or other patterns
                try:
                    # Try to find any window that might be the main application
                    all_windows = []
                    def enum_all_callback(hwnd, windows_list):
                        if win32gui.IsWindowVisible(hwnd):
                            window_text = win32gui.GetWindowText(hwnd)
                            class_name = win32gui.GetClassName(hwnd)
                            if window_text and len(window_text) > 2:  # Has meaningful title
                                windows_list.append((hwnd, window_text, class_name))
                        return True
                    
                    win32gui.EnumWindows(enum_all_callback, all_windows)
                    
                    # Look for windows that might be the main application
                    for hwnd, title, class_name in all_windows:
                        if (any(keyword in title.lower() for keyword in ['mango', 'als', 'winter', 'portal']) or
                            'autohotkey' in class_name.lower()):
                            windows.append((hwnd, title))
                            logger.info(f"Found potential ALS window: {title} (class: {class_name})")
                            break
                except Exception as e:
                    logger.warning(f"Error in fallback window search: {e}")
                
                if not windows:
                    return {'success': False, 'message': 'ALS.ahk (Mango) window not found. Make sure ALS.ahk is running and visible.'}
            
            # Use the first matching window found
            als_hwnd = windows[0][0]
            window_title = windows[0][1]
            logger.info(f"Found ALS window: {window_title}")
            
            # Get ALS window position and size
            als_rect = win32gui.GetWindowRect(als_hwnd)
            als_x, als_y, als_right, als_bottom = als_rect
            als_width = als_right - als_x
            als_height = als_bottom - als_y
            
            logger.info(f"ALS window: position=({als_x}, {als_y}), size=({als_width}x{als_height})")
            
            # Position Unit Manager to fit perfectly inside the progress bar
            # Progress bar in ALS.ahk: x0 y30 h700 w1000
            # So Unit Manager should be positioned at the progress bar coordinates
            um_x = als_x + 0  # Progress bar starts at x0
            um_y = als_y + 30  # Progress bar starts at y30 (accounting for topbar)
            um_width = min(1000, als_width)   # Progress bar width, but not exceeding ALS width
            um_height = min(700, als_height - 30)   # Progress bar height, but not exceeding available space
            
            logger.info(f"Target position for Unit Manager: ({um_x}, {um_y}), size=({um_width}x{um_height})")
            
            # Get current webview window handle
            if webview.windows:
                window = webview.windows[0]
                # Move and resize the window
                try:
                    # Use webview's move method if available
                    logger.info("Attempting to position using webview API...")
                    window.move(um_x, um_y)
                    window.resize(um_width, um_height)
                    logger.info(f"Successfully positioned using webview API")
                    return {'success': True, 'message': f'Window positioned perfectly inside ALS progress bar at ({um_x}, {um_y})'}
                except AttributeError:
                    logger.info("webview.move/resize not available, trying win32 API...")
                    # Fallback: try to get window handle and use win32 API
                    import time
                    time.sleep(0.2)  # Give time for window to be ready
                    
                    # Try multiple possible window titles
                    possible_titles = [
                        'MangoGuards Unit Manager',
                        'Unit Manager',
                        'pywebview'
                    ]
                    
                    our_hwnd = None
                    for title in possible_titles:
                        our_hwnd = win32gui.FindWindow(None, title)
                        if our_hwnd:
                            logger.info(f"Found Unit Manager window with title: {title}")
                            break
                    
                    if our_hwnd:
                        # Move and resize the window
                        win32gui.SetWindowPos(
                            our_hwnd, 
                            win32con.HWND_TOP,
                            um_x, um_y, um_width, um_height,
                            win32con.SWP_SHOWWINDOW
                        )
                        logger.info(f"Successfully positioned using win32 API")
                        return {'success': True, 'message': f'Window positioned perfectly inside ALS progress bar at ({um_x}, {um_y})'}
                    else:
                        return {'success': False, 'message': 'Could not find Unit Manager window handle. Tried titles: ' + ', '.join(possible_titles)}
                except Exception as e:
                    logger.error(f"Error during positioning: {e}")
                    return {'success': False, 'message': f'Error during positioning: {str(e)}'}
            
            return {'success': False, 'message': 'No webview window available'}
        except ImportError:
            return {'success': False, 'message': 'pywin32 not installed. Install with: pip install pywin32'}
        except Exception as e:
            logger.error(f"Error aligning with ALS window: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def get_roblox_window_info(self):
        """Get information about the ALS.ahk window for coordinate reference"""
        try:
            import win32gui
            
            def enum_windows_callback(hwnd, windows):
                if win32gui.IsWindowVisible(hwnd):
                    window_text = win32gui.GetWindowText(hwnd)
                    if 'mango' in window_text.lower():
                        rect = win32gui.GetWindowRect(hwnd)
                        windows.append({
                            'hwnd': hwnd,
                            'title': window_text,
                            'x': rect[0],
                            'y': rect[1],
                            'width': rect[2] - rect[0],
                            'height': rect[3] - rect[1],                            'progress_area': {
                                'x': rect[0] + 0,    # Progress bar x position (x0)
                                'y': rect[1] + 30,   # Progress bar y position (y30)
                                'width': 1000,       # Progress bar width
                                'height': 700        # Progress bar height
                            }})
                return True
            
            windows = []
            win32gui.EnumWindows(enum_windows_callback, windows)
            
            if windows:
                return {'success': True, 'windows': windows}
            else:
                return {'success': False, 'message': 'No ALS.ahk (Mango) windows found'}
                
        except ImportError:
            return {'success': False, 'message': 'pywin32 not installed'} 
        except Exception as e:
            print(f"Error getting ALS window info: {e}")
            return {'success': False, 'message': str(e)}
    def get_map_image(self, map_name):
        """Get map image as data URL for web display"""
        try:
            logger.info(f"Getting map image for: {map_name}")
            
            # Handle special case for maps with inconsistent naming
            special_cases = {
                'Essence Map': 'EssenceMap',
                'Devil Dungeon': 'DevilDungeon',
                'Hell Invasion': 'Hell_Invasion',
                'Villain Invasion': 'Villian_Invasion',  # Handle typo in filename
                'Destroyed Shinjuku': 'Destroyed_Shinjuku'
            }
            
            # Use special case mapping if available, otherwise clean the name
            if map_name in special_cases:
                clean_name = special_cases[map_name]
                logger.info(f"Using special case mapping: {map_name} -> {clean_name}")
            else:
                clean_name = map_name.replace(' ', '_').replace('(', '').replace(')', '')
                logger.info(f"Using default name cleaning: {map_name} -> {clean_name}")
            
            image_extensions = ['.png', '.jpg', '.jpeg', '.webp']
            
            maps_dir = os.path.join(SCRIPT_DIR, 'Images', 'Maps')
            logger.info(f"Looking for images in: {maps_dir}")
            
            for ext in image_extensions:
                image_path = os.path.join(maps_dir, f"{clean_name}{ext}")
                logger.info(f"Checking path: {image_path}")
                if os.path.exists(image_path):
                    logger.info(f"Found map image at: {image_path}")
                    # Convert image to base64 data URL for web display
                    import base64
                    with open(image_path, 'rb') as f:
                        image_data = f.read()
                    
                    # Determine MIME type
                    mime_type = 'image/png' if ext.lower() == '.png' else f'image/{ext[1:].lower()}'
                    
                    # Create data URL
                    data_url = f"data:{mime_type};base64,{base64.b64encode(image_data).decode('utf-8')}"
                    
                    return {'success': True, 'data_url': data_url, 'exists': True}
            
            return {'success': True, 'data_url': None, 'exists': False}
        except Exception as e:
            print(f"Error getting map image: {e}")
            return {'success': False, 'message': str(e)}
    
    def minimize_window(self):
        """Minimize the application window"""
        webview.windows[0].minimize()
    def close_window(self):
        """Close the application window"""
        webview.windows[0].destroy()

    def save_marker_upgrades(self, slot_number, upgrades):
        """Save marker upgrade levels and priorities for a specific slot"""
        try:
            slot_key = f'slot{slot_number}'
            
            if slot_key not in unit_config:
                return {'success': False, 'message': f'Slot {slot_number} not found'}
            
            # Store marker upgrades in the slot configuration
            if 'marker_upgrades' not in unit_config[slot_key]:
                unit_config[slot_key]['marker_upgrades'] = {}
            
            # Handle both old format (just level) and new format (level + priority)
            processed_upgrades = {}
            for marker_index, upgrade_data in upgrades.items():
                if isinstance(upgrade_data, dict):
                    # New format with level and priority
                    processed_upgrades[marker_index] = {
                        'level': upgrade_data.get('level', '0'),
                        'priority': upgrade_data.get('priority', '1')
                    }
                else:
                    # Legacy format - just upgrade level
                    processed_upgrades[marker_index] = {
                        'level': upgrade_data,
                        'priority': '1'  # Default priority
                    }
              # Update marker upgrades
            unit_config[slot_key]['marker_upgrades'].update(processed_upgrades)
            
            # Save to file
            success = self.save_config()
            return {'success': success, 'message': 'Marker upgrades saved' if success else 'Error saving marker upgrades'}
        except Exception as e:
            print(f"Error saving marker upgrades: {e}")
            return {'success': False, 'message': str(e)}
    
    def get_marker_upgrades(self, slot_number):
        """Get marker upgrade levels for a specific slot"""
        try:
            slot_key = f'slot{slot_number}'
            
            if slot_key not in unit_config:
                return {'success': False, 'message': f'Slot {slot_number} not found'}
            
            upgrades = unit_config[slot_key].get('marker_upgrades', {})
            return {'success': True, 'upgrades': upgrades}
        except Exception as e:
            print(f"Error getting marker upgrades: {e}")
            return {'success': False, 'message': str(e)}
    
    def get_all_marker_upgrades(self):
        """Get marker upgrade levels for all slots"""
        try:
            all_upgrades = {}
            for i in range(1, 7):
                slot_key = f'slot{i}'
                if slot_key in unit_config:
                    upgrades = unit_config[slot_key].get('marker_upgrades', {})
                    if upgrades:  # Only include slots that have upgrade data
                        all_upgrades[i] = upgrades
            return {'success': True, 'upgrades': all_upgrades}
        except Exception as e:
            print(f"Error getting all marker upgrades: {e}")
            return {'success': False, 'message': str(e)}
    def get_all_slot_markers(self):
        """Get all coordinate markers from all slots for global marker display"""
        try:
            all_markers = []
            for i in range(1, 7):
                slot_key = f'slot{i}'
                if slot_key in unit_config:
                    slot_data = unit_config[slot_key]
                    coords = slot_data.get('coords', [])
                    
                    if isinstance(coords, list):
                        for marker_index, coord in enumerate(coords):
                            if coord and coord.get('set', False):
                                all_markers.append({
                                    'x': coord.get('x', 0),
                                    'y': coord.get('y', 0),
                                    'slot_number': i,
                                    'marker_index': marker_index,
                                    'set': True
                                })
            return {'success': True, 'markers': all_markers}
        except Exception as e:
            print(f"Error getting all slot markers: {e}")
            return {'success': False, 'message': str(e)}

    def capture_roblox_units_screenshot(self):
        """Capture a screenshot of the bottom area of Roblox window where units are displayed using wscreenshot and cv2"""
        try:
            # Use wscreenshot for capturing and cv2 for processing
            logger.info("Starting screenshot capture using wscreenshot and cv2")
            
            # Find Roblox window - try multiple approaches for better detection
            roblox_window = None
            
            # Method 1: Try direct window titles
            window_titles = ["Roblox", "RobloxPlayerBeta", "RobloxPlayerBeta.exe"]
            
            for title in window_titles:
                try:
                    hwnd = win32gui.FindWindow(None, title)
                    if hwnd and win32gui.IsWindowVisible(hwnd):
                        roblox_window = hwnd
                        logger.info(f"Found Roblox window using title: {title}")
                        break
                except:
                    continue
            
            # Method 2: Try finding by process name
            if not roblox_window:
                try:
                    import psutil
                    for proc in psutil.process_iter(['pid', 'name']):
                        if 'roblox' in proc.info['name'].lower():
                            def enum_proc_windows(hwnd, windows):
                                if win32gui.IsWindowVisible(hwnd):
                                    _, pid = win32gui.GetWindowThreadProcessId(hwnd)
                                    if pid == proc.info['pid']:
                                        window_text = win32gui.GetWindowText(hwnd)
                                        if window_text:  # Only consider windows with titles
                                            windows.append(hwnd)
                                return True
                            
                            windows = []
                            win32gui.EnumWindows(enum_proc_windows, windows)
                            if windows:
                                roblox_window = windows[0]
                                logger.info(f"Found Roblox window via process: {proc.info['name']}")
                                break
                except ImportError:
                    logger.warning("psutil not available for process-based detection")
            
            # Method 3: Try finding by window class
            if not roblox_window:
                try:
                    hwnd = win32gui.FindWindow("WINDOWSCLIENT", None)
                    if hwnd and win32gui.IsWindowVisible(hwnd):
                        # Verify it's actually Roblox by checking window text
                        window_text = win32gui.GetWindowText(hwnd)
                        if 'roblox' in window_text.lower() or window_text == "":
                            roblox_window = hwnd
                            logger.info(f"Found Roblox window using class WINDOWSCLIENT")
                except:
                    pass
            
            # Method 4: Enumerate all windows and look for Roblox patterns
            if not roblox_window:
                def enum_windows_callback(hwnd, windows):
                    if win32gui.IsWindowVisible(hwnd):
                        try:
                            window_text = win32gui.GetWindowText(hwnd)
                            # Check for various Roblox window patterns
                            if (window_text and ("roblox" in window_text.lower() or 
                                                "anime" in window_text.lower() or
                                                "vanguards" in window_text.lower() or
                                                "tower defense" in window_text.lower())):
                                windows.append(hwnd)
                            # Also check windows with no title but Roblox-like dimensions
                            elif not window_text:
                                rect = win32gui.GetWindowRect(hwnd)
                                width = rect[2] - rect[0]
                                height = rect[3] - rect[1]
                                # Typical Roblox window dimensions
                                if 800 <= width <= 1920 and 600 <= height <= 1080:
                                    # Check if it's a game window by trying to get the class name
                                    class_name = win32gui.GetClassName(hwnd)
                                    if class_name in ["WINDOWSCLIENT", "RobloxWin"]:
                                        windows.append(hwnd)
                        except:
                            pass
                    return True
                
                windows = []
                win32gui.EnumWindows(enum_windows_callback, windows)
                if windows:
                    roblox_window = windows[0]
                    logger.info(f"Found Roblox window via enumeration")
            
            if not roblox_window:
                return {'success': False, 'message': 'Roblox window not found. Please make sure Roblox is running and visible.'}
            
            logger.info(f"Using Roblox window: {win32gui.GetWindowText(roblox_window)}")
            
            # Get window position and size
            rect = win32gui.GetWindowRect(roblox_window)
            x, y, right, bottom = rect
            width = right - x
            height = bottom - y
            
            logger.info(f"Roblox window dimensions: {width}x{height} at ({x}, {y})")
            
            # Focus on the Roblox window first
            try:
                win32gui.SetForegroundWindow(roblox_window)
                time.sleep(0.8)  # Give more time for window to come to front
                logger.info("Brought Roblox window to foreground")
            except Exception as e:
                logger.warning(f"Could not bring Roblox to foreground: {e}")
            
            # Calculate the bottom 30% of the window where units are typically displayed
            unit_area_height = int(height * 0.30)
            unit_area_y = bottom - unit_area_height
            
            logger.info(f"Capturing unit area: {width}x{unit_area_height} at ({x}, {unit_area_y})")
            
            # Use wscreenshot to capture the specific window area
            try:
                # Capture the entire screen first using wscreenshot
                screen_img = wscreenshot.screenshot()
                logger.info("Successfully captured screen using wscreenshot")
                
                # Convert to numpy array for cv2 processing
                img_array = np.array(screen_img)
                
                # Convert RGB to BGR for cv2 (OpenCV uses BGR format)
                img_bgr = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
                
                # Crop to the unit area (bottom 30% of Roblox window)
                cropped_img = img_bgr[unit_area_y:bottom, x:right]
                
                logger.info(f"Cropped image to unit area: {cropped_img.shape}")
                
                # Convert back to RGB for PIL saving
                final_img = cv2.cvtColor(cropped_img, cv2.COLOR_BGR2RGB)
                
                # Convert numpy array to PIL Image
                from PIL import Image
                screenshot = Image.fromarray(final_img)
                
            except Exception as e:
                logger.error(f"Error with wscreenshot/cv2 method: {e}")
                # Fallback to PIL ImageGrab if wscreenshot fails
                try:
                    from PIL import ImageGrab
                    screenshot = ImageGrab.grab(bbox=(x, unit_area_y, right, bottom))
                    logger.info("Used PIL ImageGrab as fallback")
                except Exception as fallback_error:
                    logger.error(f"Fallback method also failed: {fallback_error}")
                    return {'success': False, 'message': f'All screenshot methods failed. wscreenshot error: {e}, PIL error: {fallback_error}'}
            
            # Return focus to Unit Manager window after screenshot
            try:
                if webview.windows:
                    # Try to find and focus Unit Manager window
                    possible_titles = [
                        'MangoGuards Unit Manager',
                        'Unit Manager',
                        'pywebview'
                    ]
                    unit_manager_hwnd = None
                    for title in possible_titles:
                        unit_manager_hwnd = win32gui.FindWindow(None, title)
                        if unit_manager_hwnd:
                            win32gui.SetForegroundWindow(unit_manager_hwnd)
                            logger.info(f"Returned focus to Unit Manager window: {title}")
                            break
                    
                    if not unit_manager_hwnd:
                        logger.warning("Could not find Unit Manager window to return focus")
            except Exception as e:
                logger.error(f"Error returning focus to Unit Manager: {e}")
            
            # Generate unique filename with timestamp
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            screenshot_filename = f"units_screenshot_{timestamp}.png"
            screenshots_dir = os.path.join(SCRIPT_DIR, 'screenshots')
            
            # Create screenshots directory if it doesn't exist
            if not os.path.exists(screenshots_dir):
                os.makedirs(screenshots_dir)
            
            screenshot_path = os.path.join(screenshots_dir, screenshot_filename)
            
            # Save screenshot
            screenshot.save(screenshot_path)
            logger.info(f"Screenshot saved to: {screenshot_path}")
            return {'success': True, 'screenshot_path': screenshot_path, 'filename': screenshot_filename}
            
        except Exception as e:
            logger.error(f"Error capturing screenshot: {e}")
            return {'success': False, 'message': f'Error capturing screenshot: {str(e)}'}

    def save_config_with_screenshot(self, config_name):
        """Save current configuration with a screenshot to the configs folder"""
        try:
            if not config_name or not config_name.strip():
                return {'success': False, 'message': 'Configuration name is required'}
            
            config_name = config_name.strip()
            
            # Create configs directory if it doesn't exist
            configs_dir = os.path.join(SCRIPT_DIR, 'configs')
            if not os.path.exists(configs_dir):
                os.makedirs(configs_dir)
            
            # First, focus on Roblox window and capture screenshot
            screenshot_result = self.capture_roblox_units_screenshot()
            
            # Save the configuration file
            config_filename = f"{config_name}.txt"
            config_path = os.path.join(configs_dir, config_filename)
            
            # Copy current vanguards_config.txt to the new config file
            try:
                with open(CONFIG_FILE, 'r') as source:
                    config_content = source.read()
                
                with open(config_path, 'w') as dest:
                    dest.write(config_content)
                
            except Exception as e:
                return {'success': False, 'message': f'Error saving config file: {str(e)}'}
            
            # Convert screenshot to base64 for embedding in metadata
            screenshot_base64 = None
            if screenshot_result.get('success'):
                try:
                    screenshot_path = screenshot_result['screenshot_path']
                    if os.path.exists(screenshot_path):
                        # Convert screenshot to base64
                        with open(screenshot_path, 'rb') as f:
                            screenshot_data = f.read()
                        screenshot_base64 = base64.b64encode(screenshot_data).decode('utf-8')
                        
                        # Clean up the temporary screenshot file
                        os.remove(screenshot_path)
                        logger.info(f"Converted screenshot to base64 and cleaned up temporary file")
                        
                except Exception as e:
                    logger.error(f"Error converting screenshot to base64: {e}")
                    screenshot_base64 = None
            
            # Create a metadata file for the configuration with embedded screenshot
            metadata = {
                'name': config_name,
                'created_at': datetime.now().isoformat(),
                'has_screenshot': screenshot_result.get('success', False) and screenshot_base64 is not None,
                'screenshot_base64': screenshot_base64
            }
            
            metadata_path = os.path.join(configs_dir, f"{config_name}_metadata.json")
            with open(metadata_path, 'w') as f:
                json.dump(metadata, f, indent=2)
            
            message = f"Configuration '{config_name}' saved successfully"
            if metadata['has_screenshot']:
                message += " with unit screenshot"
            else:
                message += f" (screenshot failed: {screenshot_result.get('message', 'Unknown error')})"
            
            return {'success': True, 'message': message, 'has_screenshot': metadata['has_screenshot']}
        except Exception as e:
            print(f"Error saving config with screenshot: {e}")
            return {'success': False, 'message': f'Error saving configuration: {str(e)}'}
    def get_config_metadata(self, config_filename):
        """Get metadata for a specific configuration including screenshot info"""
        try:
            config_name = config_filename.replace('.txt', '')
            configs_dir = os.path.join(SCRIPT_DIR, 'configs')
            metadata_path = os.path.join(configs_dir, f"{config_name}_metadata.json")
            
            if os.path.exists(metadata_path):
                with open(metadata_path, 'r') as f:
                    metadata = json.load(f)
                
                # Handle both new format (screenshot_base64) and legacy format (screenshot_filename)
                if 'screenshot_base64' in metadata:
                    # New format: screenshot embedded as base64
                    metadata['has_screenshot'] = bool(metadata.get('screenshot_base64'))
                elif 'screenshot_filename' in metadata:
                    # Legacy format: check if separate PNG file exists
                    screenshot_path = os.path.join(configs_dir, metadata['screenshot_filename'])
                    metadata['has_screenshot'] = os.path.exists(screenshot_path)
                
                return {'success': True, 'metadata': metadata}
            else:
                # Return basic metadata for configs without metadata files
                has_screenshot = os.path.exists(os.path.join(configs_dir, f"{config_name}_units.png"))
                return {
                    'success': True, 
                    'metadata': {
                        'name': config_name,
                        'has_screenshot': has_screenshot,
                        'created_at': None
                    }
                }        
        except Exception as e:
            print(f"Error getting config metadata: {e}")
            return {'success': False, 'message': str(e)}

    def migrate_screenshots_to_base64(self):
        """Migrate existing separate PNG screenshot files to base64 data embedded in metadata files"""
        try:
            configs_dir = os.path.join(SCRIPT_DIR, 'configs')
            if not os.path.exists(configs_dir):
                return {
                    'success': True, 
                    'message': 'No configs directory found, nothing to migrate',
                    'migrated_count': 0,
                    'errors': []
                }
            
            migrated_count = 0
            errors = []
            
            # Find all PNG screenshot files
            png_files = [f for f in os.listdir(configs_dir) if f.endswith('_units.png')]
            
            for png_file in png_files:
                try:
                    config_name = png_file.replace('_units.png', '')
                    metadata_path = os.path.join(configs_dir, f"{config_name}_metadata.json")
                    png_path = os.path.join(configs_dir, png_file)
                    
                    # Check if metadata file exists
                    if os.path.exists(metadata_path):
                        # Load existing metadata
                        with open(metadata_path, 'r') as f:
                            metadata = json.load(f)
                        
                        # Check if already migrated (has screenshot_base64)
                        if 'screenshot_base64' in metadata and metadata['screenshot_base64']:
                            logger.info(f"Skipping {config_name}: already migrated")
                            continue
                    else:
                        # Create new metadata
                        metadata = {
                            'name': config_name,
                            'created_at': datetime.now().isoformat(),
                            'has_screenshot': False
                        }
                    
                    # Read and convert PNG to base64
                    with open(png_path, 'rb') as f:
                        screenshot_data = f.read()
                    screenshot_base64 = base64.b64encode(screenshot_data).decode('utf-8')
                    
                    # Update metadata with base64 data
                    metadata['has_screenshot'] = True
                    metadata['screenshot_base64'] = screenshot_base64
                    
                    # Remove old format fields if they exist
                    if 'screenshot_filename' in metadata:
                        del metadata['screenshot_filename']
                    
                    # Save updated metadata
                    with open(metadata_path, 'w') as f:
                        json.dump(metadata, f, indent=2)
                    
                    # Remove the PNG file
                    os.remove(png_path)
                    
                    migrated_count += 1
                    logger.info(f"Successfully migrated {config_name}")
                    
                except Exception as e:
                    error_msg = f"Error migrating {png_file}: {str(e)}"
                    logger.error(error_msg)
                    errors.append(error_msg)
            
            message = f"Migration completed: {migrated_count} screenshots converted to base64"
            if errors:
                message += f" ({len(errors)} errors encountered)"
            
            return {
                'success': True, 
                'message': message,
                'migrated_count': migrated_count,
                'errors': errors
            }
            
        except Exception as e:
            logger.error(f"Error during migration: {e}")
            return {'success': False, 'message': f'Migration failed: {str(e)}'}

    def get_config_screenshot(self, config_filename):
        """Get the screenshot for a specific configuration"""
        try:
            config_name = config_filename.replace('.txt', '')
            configs_dir = os.path.join(SCRIPT_DIR, 'configs')
            metadata_path = os.path.join(configs_dir, f"{config_name}_metadata.json")
            
            # First try to get screenshot from metadata (new base64 format)
            if os.path.exists(metadata_path):
                try:
                    with open(metadata_path, 'r') as f:
                        metadata = json.load(f)
                    
                    if metadata.get('has_screenshot') and metadata.get('screenshot_base64'):
                        return {'success': True, 'screenshot_data': metadata['screenshot_base64']}
                except Exception as e:
                    logger.error(f"Error reading metadata for screenshot: {e}")
            
            # Fallback: try to get screenshot from separate PNG file (legacy format)
            screenshot_path = os.path.join(configs_dir, f"{config_name}_units.png")
            if os.path.exists(screenshot_path):
                try:
                    with open(screenshot_path, 'rb') as f:
                        screenshot_data = base64.b64encode(f.read()).decode('utf-8')
                    return {'success': True, 'screenshot_data': screenshot_data}
                except Exception as e:
                    logger.error(f"Error reading PNG screenshot: {e}")
            
            return {'success': False, 'message': 'Screenshot not found'}
        except Exception as e:
            print(f"Error getting config screenshot: {e}")
            return {'success': False, 'message': str(e)}  
    def load_vanguards_config(self):
        """Load and return the current vanguards config data for marker editing"""
        try:
            # Return the current unit_config which contains all the loaded data
            # This includes coordinates, upgrades, placements, and priorities
            return {'success': True, 'data': unit_config}
        except Exception as e:
            print(f"Error loading vanguards config: {e}")
            return {'success': False, 'message': str(e)}
    def remove_slot_from_config(self, slot_number):
        """Remove a specific slot from the config file without affecting other slots"""
        try:
            slot_key = f'slot{slot_number}'
            
            # Remove from memory
            if slot_key in unit_config:
                del unit_config[slot_key]
            
            # Rewrite config file without this slot
            success = self.save_config()
            return {'success': success, 'message': f'Slot {slot_number} removed from config' if success else 'Error removing slot from config'}
        except Exception as e:
            print(f"Error removing slot {slot_number}: {e}")
            return {'success': False, 'message': str(e)}
    
    def clear_slot_from_config(self, slot_number):
        """Clear a specific slot from the config file (same as remove for our purposes)"""
        return self.remove_slot_from_config(slot_number)

def start_unit_manager():
    """Start the Unit Manager desktop application"""
    logger.info("Starting MangoGuards Unit Manager Desktop App...")
    
    # Get the path to the HTML file
    html_path = os.path.join(SCRIPT_DIR, 'unitmanager_simple.html')
    
    if not os.path.exists(html_path):
        logger.error(f"Error: unitmanager.html not found at {html_path}")
        return
    
    # Create API instance
    api = UnitManagerAPI()
    
    # Create webview window without topbar/title bar
    window = webview.create_window(
        title='MangoGuards Unit Manager',
        url=html_path,
        width=1000,
        height=700,
        min_size=(800, 500),
        resizable=False,  # Disable resizing to prevent movement
        js_api=api,
        
        frameless=True,  # Remove the window frame/topbar
        on_top=False,
        text_select=False  # Prevent text selection which could interfere
    )    # Auto-positioning function that runs immediately after webview starts
    def auto_position():
        """Auto-position the window every 5 seconds"""
        import threading
        import time
        
        def position_loop():
            # Wait a bit for the window to be ready
            time.sleep(2)
            
            while True:
                try:
                    # Call the align function to reposition the window
                    result = api.align_with_roblox()
                    if result.get('success'):
                        logger.info("Auto-repositioned window successfully")
                    else:
                        logger.warning(f"Auto-repositioning failed: {result.get('message', 'Unknown error')}")
                except Exception as e:
                    logger.error(f"Error during auto-positioning: {e}")
                
                # Wait 5 seconds before next repositioning
                time.sleep(5)
        
        # Start the positioning thread
        position_thread = threading.Thread(target=position_loop, daemon=True)
        position_thread.start()
        logger.info("Auto-positioning thread started (every 5 seconds)")
    
    # Start auto-positioning
    auto_position()
    
    # Start the webview with immediate positioning
    webview.start(debug=False)

    

if __name__ == "__main__":
    start_unit_manager()
