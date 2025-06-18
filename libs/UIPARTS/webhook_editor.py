#!/usr/bin/env python3
"""
MangoGuards Webhook Editor - Desktop Application
A standalone desktop application for editing Discord webhooks with live preview
"""

import os
import sys
import json

# Check for required modules and provide helpful error messages
try:
    import webview
except ImportError:
    print("ERROR: 'webview' module not found!")
    print("Please run setup_python_deps.bat to install required dependencies.")
    print("Or manually install with: pip install pywebview==4.4.1")
    input("Press Enter to exit...")
    sys.exit(1)

try:
    import requests
except ImportError:
    print("ERROR: 'requests' module not found!")
    print("Please run setup_python_deps.bat to install required dependencies.")
    print("Or manually install with: pip install requests")
    input("Press Enter to exit...")
    sys.exit(1)

import time
from datetime import datetime

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WEBHOOK_FILE = os.path.join(SCRIPT_DIR, '..', 'settings', 'webhook.txt')

class WebhookEditorAPI:
    """API class to handle JavaScript calls from the web view"""
    
    def __init__(self):
        self.webhook_url = self.load_webhook_url()
        self.webhook_data = self.load_default_webhook_data()
    
    def load_webhook_url(self):
        """Load webhook URL from file"""
        try:
            if os.path.exists(WEBHOOK_FILE):
                with open(WEBHOOK_FILE, 'r', encoding='utf-8') as f:
                    return f.read().strip()
            return ""
        except Exception as e:
            print(f"Error loading webhook URL: {e}")
            return ""
    
    def save_webhook_url(self, url):
        """Save webhook URL to file"""
        try:
            # Ensure the directory exists
            os.makedirs(os.path.dirname(WEBHOOK_FILE), exist_ok=True)
            
            with open(WEBHOOK_FILE, 'w', encoding='utf-8') as f:
                f.write(url.strip())
            return {'success': True, 'message': 'Webhook URL saved successfully'}
        except Exception as e:
            return {'success': False, 'message': f'Error saving webhook URL: {e}'}
    
    def load_default_webhook_data(self):
        """Load default webhook configuration"""
        return {
            'content': '🥭 **MangoGuards Bot Update** 🥭\n\nYour bot has completed a map! Check the details below.',
            'username': 'MangoGuards',
            'avatar_url': 'https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png',
            'embeds': [
                {
                    'title': '📊 Map Completion Report',
                    'description': '**Congratulations!** Your MangoGuards bot has successfully completed another map run.\n\n*You can customize this message in the webhook editor.*',
                    'color': 16760628,  # Gold color
                    'fields': [
                        {
                            'name': '🏆 Win Rate',
                            'value': '{wins} wins / {losses} losses',
                            'inline': True
                        },
                        {
                            'name': '⏱️ Session Time',
                            'value': '{time}',
                            'inline': True
                        },
                        {
                            'name': '🏃 Total Runs',
                            'value': '{runs}',
                            'inline': True
                        }
                    ],
                    'author': {
                        'name': 'MangoGuards Bot',
                        'icon_url': 'https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png'
                    },
                    'footer': {
                        'text': 'MangoGuards | Powered by AutoHotkey',
                        'icon_url': 'https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png'
                    },
                    'timestamp': datetime.utcnow().isoformat() + 'Z'
                }
            ]
        }
    
    def get_webhook_url(self):
        """Get current webhook URL"""
        return self.webhook_url
    
    def update_webhook_url(self, url):
        """Update webhook URL"""
        self.webhook_url = url
        return self.save_webhook_url(url)
    
    def get_webhook_data(self):
        """Get current webhook data"""
        return self.webhook_data
    
    def update_webhook_data(self, data):
        """Update webhook data"""
        try:
            self.webhook_data.update(data)
            return {'success': True, 'message': 'Webhook data updated'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
    
    def validate_webhook_url(self, url):
        """Validate webhook URL format"""
        import re
        webhook_pattern = r'https?://discord\.com/api/webhooks/\d{17,19}/[\w-]+'
        return bool(re.match(webhook_pattern, url))
    
    def test_webhook(self, webhook_data=None):
        """Test the webhook by sending a message"""
        try:
            if not self.webhook_url:
                return {'success': False, 'message': 'No webhook URL configured'}
            
            if not self.validate_webhook_url(self.webhook_url):
                return {'success': False, 'message': 'Invalid webhook URL format'}
            
            # Use provided data or default
            data_to_send = webhook_data or self.webhook_data
            
            # Add timestamp to embeds if they exist
            if 'embeds' in data_to_send:
                for embed in data_to_send['embeds']:
                    if 'timestamp' not in embed:
                        embed['timestamp'] = datetime.utcnow().isoformat() + 'Z'
            
            # Send the webhook
            response = requests.post(
                self.webhook_url,
                json=data_to_send,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 204:
                return {'success': True, 'message': 'Webhook sent successfully!'}
            else:
                return {'success': False, 'message': f'Webhook failed with status {response.status_code}: {response.text}'}
                
        except requests.exceptions.Timeout:
            return {'success': False, 'message': 'Request timed out. Check your internet connection.'}
        except requests.exceptions.ConnectionError:
            return {'success': False, 'message': 'Connection error. Check your internet connection.'}
        except Exception as e:
            return {'success': False, 'message': f'Error sending webhook: {str(e)}'}
    
    def get_embed_colors(self):
        """Get predefined embed colors"""
        return {
            'Red': 16711680,
            'Green': 65280,
            'Blue': 255,
            'Yellow': 16776960,
            'Orange': 16753920,
            'Purple': 8388736,
            'Pink': 16761035,
            'Gold': 16760628,
            'Cyan': 65535,
            'White': 16777215,
            'Black': 0,
            'Discord Blurple': 5793266,
            'Discord Green': 5763719,
            'Discord Yellow': 16705372,
            'Discord Fuchsia': 15418782,
            'Discord Red': 15548997
        }
    
    def export_webhook_config(self):
        """Export webhook configuration to JSON"""
        try:
            export_data = {
                'webhook_url': self.webhook_url,
                'webhook_data': self.webhook_data,
                'exported_at': datetime.utcnow().isoformat() + 'Z',
                'version': '1.0'
            }
            return export_data
        except Exception as e:
            return {'error': str(e)}
    
    def import_webhook_config(self, config_data):
        """Import webhook configuration from JSON"""
        try:
            if 'webhook_url' in config_data:
                self.webhook_url = config_data['webhook_url']
                self.save_webhook_url(self.webhook_url)
            
            if 'webhook_data' in config_data:
                self.webhook_data.update(config_data['webhook_data'])
            
            return {'success': True, 'message': 'Configuration imported successfully'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
    
    def get_webhook_info(self):
        """Get webhook information from Discord API"""
        try:
            if not self.webhook_url:
                return {'success': False, 'message': 'No webhook URL configured'}
            
            # Extract webhook info endpoint
            info_url = self.webhook_url.split('?')[0]  # Remove query params if any
            
            response = requests.get(info_url, timeout=10)
            
            if response.status_code == 200:
                webhook_info = response.json()
                return {
                    'success': True,
                    'info': {
                        'name': webhook_info.get('name', 'Unknown'),
                        'channel_id': webhook_info.get('channel_id', 'Unknown'),
                        'guild_id': webhook_info.get('guild_id', 'Unknown'),
                        'avatar': webhook_info.get('avatar'),
                        'type': webhook_info.get('type', 'Unknown')
                    }
                }
            else:
                return {'success': False, 'message': f'Failed to get webhook info: {response.status_code}'}
                
        except Exception as e:
            return {'success': False, 'message': f'Error getting webhook info: {str(e)}'}
    
    def minimize_window(self):
        """Minimize the application window"""
        webview.windows[0].minimize()
    
    def close_window(self):
        """Close the application window"""
        webview.windows[0].destroy()
    
    def align_with_roblox(self):
        """Align the Webhook Editor window inside the ALS.ahk window progress area"""
        try:
            import win32gui
            import win32con
            
            # Find ALS.ahk window (Mango window)
            als_hwnd = None
            
            def enum_windows_callback(hwnd, windows):
                if win32gui.IsWindowVisible(hwnd):
                    window_text = win32gui.GetWindowText(hwnd)
                    if 'mango' in window_text.lower():
                        windows.append((hwnd, window_text))
                return True
            
            windows = []
            win32gui.EnumWindows(enum_windows_callback, windows)
            
            if not windows:
                return {'success': False, 'message': 'ALS.ahk (Mango) window not found. Make sure ALS.ahk is running.'}
            
            # Use the first Mango window found
            als_hwnd = windows[0][0]
            window_title = windows[0][1]
            print(f"Found ALS window: {window_title}")
            
            # Get ALS window position and size
            als_rect = win32gui.GetWindowRect(als_hwnd)
            als_x, als_y, als_right, als_bottom = als_rect
            als_width = als_right - als_x
            als_height = als_bottom - als_y
            
            print(f"ALS window: position=({als_x}, {als_y}), size=({als_width}x{als_height})")
            
            # Position Webhook Editor to fit perfectly inside the progress bar
            # Progress bar in ALS.ahk: x0 y30 h700 w1000
            # So Webhook Editor should be positioned at the progress bar coordinates
            we_x = als_x + 0  # Progress bar starts at x0
            we_y = als_y + 30  # Progress bar starts at y30 (accounting for topbar)
            we_width = 1000   # Progress bar width
            we_height = 700   # Progress bar height
            
            print(f"Target position for Webhook Editor: ({we_x}, {we_y}), size=({we_width}x{we_height})")
            
            # Get current webview window handle
            if webview.windows:
                window = webview.windows[0]
                # Move and resize the window
                try:
                    # Use webview's move method if available
                    print("Attempting to position using webview API...")
                    window.move(we_x, we_y)
                    window.resize(we_width, we_height)
                    print(f"Successfully positioned using webview API")
                    return {'success': True, 'message': f'Window positioned perfectly inside ALS progress bar at ({we_x}, {we_y})'}
                except AttributeError:
                    print("webview.move/resize not available, trying win32 API...")
                    
                    # Fallback: try to get window handle and use win32 API
                    import time
                    time.sleep(0.1)  # Give time for window to be ready
                    
                    # Try multiple possible window titles
                    possible_titles = [
                        'MangoGuards Webhook Editor',
                        'Webhook Editor',
                        'pywebview'
                    ]
                    
                  
                    our_hwnd = None
                    for title in possible_titles:
                        our_hwnd = win32gui.FindWindow(None, title)
                        if our_hwnd:
                            print(f"Found Webhook Editor window with title: {title}")
                            break
                    
                    if our_hwnd:
                        # Move and resize the window
                        win32gui.SetWindowPos(
                            our_hwnd, 
                            win32con.HWND_TOP,
                            we_x, we_y, we_width, we_height,
                            win32con.SWP_SHOWWINDOW
                        )        
                        print(f"Successfully positioned using win32 API")
                        return {'success': True, 'message': f'Window positioned perfectly inside ALS progress bar at ({we_x}, {we_y})'}
                    else:
                        return {'success': False, 'message': 'Could not find Webhook Editor window handle. Tried titles: ' + ', '.join(possible_titles)}
                except Exception as e:
                    print(f"Error during positioning: {e}")
                    return {'success': False, 'message': f'Error during positioning: {str(e)}'}
            
            return {'success': False, 'message': 'No webview window available'}
        except ImportError:
            return {'success': False, 'message': 'pywin32 not installed. Install with: pip install pywin32'}
        except Exception as e:
            print(f"Error aligning with ALS window: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}

def start_webhook_editor():
    """Start the Webhook Editor desktop application"""
    print("Starting MangoGuards Webhook Editor...")
    
    # Get the path to the HTML file
    html_path = os.path.join(SCRIPT_DIR, 'webhook_editor.html')
    
    if not os.path.exists(html_path):
        print(f"Error: webhook_editor.html not found at {html_path}")
        return
    
    # Create API instance
    api = WebhookEditorAPI()
    
    # Create webview window
    window = webview.create_window(
        title='MangoGuards Webhook Editor',
        url=html_path,
        width=1200,
        height=800,
        min_size=(900, 600),
        resizable=True,
        js_api=api,
        frameless=True
    )
    
    # Start the webview
    webview.start(debug=False)

if __name__ == "__main__":
    start_webhook_editor()
