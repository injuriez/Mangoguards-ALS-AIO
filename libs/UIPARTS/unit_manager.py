#!/usr/bin/env python3
'\nMangoGuards Unit Manager - Simple Desktop Application\nA standalone desktop application that loads the HTML file directly using webview\n'
_A2='screenshot_path'
_A1='autohotkey'
_A0='mangoguards'
_z='unit manager'
_y='firefox'
_x='chrome'
_w='browser'
_v='vs code'
_u='visual studio'
_t='file explorer'
_s='explorer'
_r='Tutorial.txt'
_q='markers'
_p='marker_index'
_o='VIRTUAL_ENV'
_n='created_at'
_m='windows'
_l='height'
_k='width'
_j='pywebview'
_i='Unit Manager'
_h='.txt'
_g='config'
_f='migrated_count'
_e='Please run setup_python_deps.bat to install required dependencies.'
_d='screenshot_filename'
_c='utf-8'
_b='rb'
_a='MangoGuards Unit Manager'
_Z='mango'
_Y='Press Enter to exit...'
_X='Unknown error'
_W='progress_area'
_V='upgrade'
_U='name'
_T='configs'
_S='unit_name'
_R='skill'
_Q='screenshot_base64'
_P='none'
_O='has_screenshot'
_N='placement'
_M='marker_upgrades'
_L='level'
_K='priority'
_J='coords'
_I='set'
_H=None
_G='y'
_F='x'
_E='1'
_D=True
_C='message'
_B='success'
_A=False
import os,sys,json
try:import webview
except ImportError:print("ERROR: 'webview' module not found!");print("The webview module comes from the 'pywebview' package.");print(_e);print('Or manually install with: pip install pywebview==4.4.1');print("NOTE: Install 'pywebview' NOT 'webview' - they are different packages!");input(_Y);sys.exit(1)
try:import win32gui,win32ui,win32con,win32api
except ImportError as e:print("ERROR: 'pywin32' module not found!");print(f"Import error details: {e}");print(f"Python executable: {sys.executable}");print(f"Python version: {sys.version}");print(f"Virtual environment: {os.environ.get(_o,'None')}");print(f"In virtual env: {hasattr(sys,'real_prefix')or hasattr(sys,'base_prefix')and sys.base_prefix!=sys.prefix}");print('');print('This module provides Windows API access.');print('');print('VIRTUAL ENVIRONMENT ISSUE DETECTED!'if os.environ.get(_o)else'');print('Try these solutions in order:');print('1. If in virtual environment, install there: pip install pywin32');print('2. Or install globally: pip install --user pywin32');print('3. Run fix_pywin32.bat');print('4. Run setup_python_deps.bat as Administrator');print('5. Manual install: pip install pywin32');print('6. If that fails, try: pip install --upgrade pywin32');print('5. If still failing, try: pip install --user pywin32');print('6. After install, run: python Scripts/pywin32_postinstall.py -install');print('');print("Note: Make sure you're using the same Python that has pywin32 installed.");input(_Y);sys.exit(1)
try:import cv2,numpy as np
except ImportError:print("ERROR: 'opencv-python' or 'numpy' module not found!");print(_e);print('Or manually install with: pip install opencv-python numpy');input(_Y);sys.exit(1)
try:import wscreenshot
except ImportError:print("ERROR: 'wscreenshot' module not found!");print(_e);print('Or manually install with: pip install wscreenshot');input(_Y);sys.exit(1)
import time,traceback
from datetime import datetime
import subprocess,ctypes
from ctypes import wintypes
import threading,logging,base64
try:import psutil
except ImportError:print("WARNING: 'psutil' module not found!");print('Process monitoring will fall back to window detection only.');print('For better ALS process detection, install with: pip install psutil');psutil=_H
SCRIPT_DIR=os.path.dirname(os.path.abspath(__file__))
CONFIG_FILE=os.path.join(SCRIPT_DIR,'vanguards_config.txt')
LOG_FILE=os.path.join(SCRIPT_DIR,'Logs.log')
logging.basicConfig(level=logging.INFO,format='%(asctime)s - %(levelname)s - %(message)s',handlers=[logging.FileHandler(LOG_FILE),logging.StreamHandler()])
logger=logging.getLogger(__name__)
unit_config={}
class UnitManagerAPI:
	'API class to handle JavaScript calls from the web view'
	def __init__(A):
		A.load_config();B=A.migrate_screenshots_to_base64()
		if B[_f]>0:logger.info(f"Screenshot migration: {B[_C]}")
	def load_config(B):
		'Load unit configuration from vanguards_config.txt file';global unit_config
		try:
			B.create_default_config()
			if os.path.exists(CONFIG_FILE):
				with open(CONFIG_FILE,'r')as C:
					for A in C:
						A=A.strip()
						if A and not A.startswith('//'):B.parse_config_line(A)
		except Exception as D:print(f"Error loading config: {D}");B.create_default_config()
	def parse_config_line(h,line):
		'Parse a single line from vanguards_config.txt';I=':';C=line;global unit_config
		try:
			logger.info(f"Parsing config line: {C}")
			if'|'in C:N=C.rsplit('|',1);O=N[0];P=len(N)>1 and N[1]==_E
			else:O=C;P=_A
			logger.info(f"Main line: {O}, Status set: {P}");A=O.split(I);logger.info(f"Split parts: {A}")
			if len(A)>=7:Q=A[0];F=A[1];i=A[2];R=A[3];S=A[4];G=A[5];J=I.join(A[6:]);logger.info(f"Parsed - slot: {Q}, placement: {F}, unit: {R}");logger.info(f"Priority: {S}, auto_skill: {G}, coords_and_upgrades: {J}")
			elif len(A)>=6:Q=A[0];F=A[1];S=A[2];R=A[3];b=A[4];G=_P;J=I.join(A[5:]);c={_E:'skill1','2':'skill2','3':'skill3','4':_P};G=c.get(b,_P)
			else:logger.warning(f"Invalid config line format: {C}");return
			d=Q.replace('SLOT','');T=f"slot{d}";B=[];E={}
			if P and J:
				e=J.split(';')
				for(D,H)in enumerate(e):
					logger.info(f"Processing marker {D}: {H}")
					if'|'in H:
						U,K=H.split('|',1)
						if','in U:
							V,W=U.split(',',1)
							try:L,M=int(V.strip()),int(W.strip());B.append({_F:L,_G:M,_I:_D});logger.info(f"Coordinates: ({L}, {M})")
							except ValueError:B.append({_F:0,_G:0,_I:_A});logger.warning(f"Invalid coordinates: {U}")
						else:B.append({_F:0,_G:0,_I:_A})
						if I in K:X,Y=K.split(I,1);E[D]={_L:X.strip(),_K:Y.strip()};logger.info(f"Marker {D} upgrades: level={X}, priority={Y}")
						else:E[D]={_L:K.strip(),_K:_E};logger.info(f"Marker {D} upgrade level: {K}")
					elif','in H:
						V,W=H.split(',',1)
						try:L,M=int(V.strip()),int(W.strip());B.append({_F:L,_G:M,_I:_D})
						except ValueError:B.append({_F:0,_G:0,_I:_A})
						E[D]={_L:_E,_K:_E}
					else:B.append({_F:0,_G:0,_I:_A});E[D]={_L:_E,_K:_E}
			else:
				f=int(F)if F.isdigit()else 1
				for g in range(f):B.append({_F:0,_G:0,_I:_A});E[g]={_L:_E,_K:_E}
			if len(A)>=7:Z=G
			else:Z=G
			unit_config[T]={_N:F,_K:S,_R:Z,_V:'0',_S:R,_J:B,_M:E};logger.info(f"Successfully parsed slot {T}: {unit_config[T]}")
		except Exception as a:logger.error(f"Error parsing config line: {C}, error: {a}");print(f"Error parsing config line: {C}, error: {a}")
	def create_default_config(A):'Create default configuration';global unit_config;unit_config={f"slot{A}":{_N:_E,_K:str(A),_R:_P,_V:'0',_S:'',_J:[{_F:0,_G:0,_I:_A}],_M:{0:{_L:_E,_K:_E}}}for A in range(1,7)}
	def save_config(b):
		'Save unit configuration to vanguards_config.txt file';R='disabled';M='0,0|1'
		try:
			with open(CONFIG_FILE,'w')as S:
				for E in range(1,7):
					N=f"slot{E}"
					if N in unit_config:
						A=unit_config[N]
						if A.get(R,_A):continue
						if A.get(R,_A):continue
						T=A.get(_R,_P);H=A.get(_J,[]);O=A.get(_M,{});I=int(A.get(_N,_E));C=[];D=_D
						if isinstance(H,list)and len(H)>0:
							U=H[:I]
							for(P,F)in enumerate(U):
								if isinstance(F,dict):
									V=F.get(_F,0);W=F.get(_G,0);B=O.get(str(P),O.get(P,A.get(_V,_E)))
									if isinstance(B,dict):J=B.get(_L,_E);K=B.get(_K,_E);G=f"{J}:{K}"
									elif isinstance(B,str)and B.startswith('{'):
										try:import json;Q=json.loads(B.replace("'",'"'));J=Q.get(_L,_E);K=Q.get(_K,_E);G=f"{J}:{K}"
										except:G='1:1'
									else:G=str(B)
									C.append(f"{V},{W}|{G}")
									if not F.get(_I,_A):D=_A
								else:C.append(M);D=_A
							if not C:L=M;D=_A
							else:L=';'.join(C)
						else:L=M;D=_A
						X=_E if D and C else'0';Y=A.get(_S,'');I=A.get(_N,_E);Z=f"SLOT{E}:{I}:{E}:{Y}:{A.get(_K,str(E))}:{T}:{L}|{X}";S.write(Z+'\n')
			return _D
		except Exception as a:print(f"Error saving config: {a}");return _A
	def get_config(A):'Get current configuration';return unit_config
	def update_config(B,data):
		'Update configuration'
		try:unit_config.update(data);A=B.save_config();return{_B:A,_C:'Configuration saved'if A else'Error saving configuration'}
		except Exception as C:return{_B:_A,_C:str(C)}
	def set_coordinates(E,slot_number,x,y,marker_index=0):
		'Set custom coordinates for a slot (supports multiple markers based on placement)';C=slot_number;B=marker_index
		try:
			A=f"slot{C}"
			if A not in unit_config:unit_config[A]={_N:_E,_K:str(C),_R:_P,_V:'0',_S:'',_J:[{_F:0,_G:0,_I:_A}],_M:{0:{_L:_E,_K:_E}}}
			if _J not in unit_config[A]or not isinstance(unit_config[A][_J],list):unit_config[A][_J]=[]
			F=int(unit_config[A].get(_N,_E))
			while len(unit_config[A][_J])<F:unit_config[A][_J].append({_F:0,_G:0,_I:_A})
			if B<len(unit_config[A][_J]):unit_config[A][_J][B]={_F:x,_G:y,_I:_D}
			else:
				while len(unit_config[A][_J])<=B:unit_config[A][_J].append({_F:0,_G:0,_I:_A})
				unit_config[A][_J][B]={_F:x,_G:y,_I:_D}
			if _M not in unit_config[A]:unit_config[A][_M]={}
			if B not in unit_config[A][_M]:unit_config[A][_M][B]={_L:_E,_K:_E}
			G=E.save_config();return{_B:G,_J:unit_config[A][_J],_p:B,_C:'Coordinate saved'}
		except Exception as D:print(f"Error in set_coordinates: {D}");return{_B:_A,_C:str(D)}
	def set_multiple_coordinates(C,slot_number,coords_string,placement_count):
		'Set multiple coordinates for a slot from a formatted string.';G=coords_string;E=placement_count;D=slot_number
		try:
			A=f"slot{D}"
			if A not in unit_config:
				C.create_default_config()
				if A not in unit_config:unit_config[A]={_N:str(E),_K:str(D),_R:_P,_S:'',_J:[]}
			B=[]
			if G:
				K=G.split('|')
				for H in K:
					if','in H:L,M=H.split(',');B.append({_F:int(L),_G:int(M),_I:_D})
					else:B.append({_F:0,_G:0,_I:_A})
			F=[]
			for I in range(int(E)):
				if I<len(B):F.append(B[I])
				else:F.append({_F:0,_G:0,_I:_A})
			unit_config[A][_J]=F;unit_config[A][_N]=str(E);N=C.save_config()
			if N:C.load_config();return{_B:_D,_C:f"Coordinates for slot {D} updated.",'new_config_slot':unit_config.get(A)}
			else:return{_B:_A,_C:'Error saving coordinates.'}
		except Exception as J:print(f"Error in set_multiple_coordinates: {J}");return{_B:_A,_C:str(J)}
	def get_slot_markers(F,slot_number):
		'Get all coordinate markers for a slot';D=slot_number
		try:
			B=f"slot{D}"
			if B not in unit_config:unit_config[B]={_N:_E,_K:str(D),_R:_P,_V:'0',_S:'',_J:[{_F:0,_G:0,_I:_A}],_M:{0:{_L:_E,_K:_E}}};F.save_config()
			E=unit_config[B];C=int(E.get(_N,_E));A=E.get(_J,[])
			if not isinstance(A,list):A=[]
			while len(A)<C:A.append({_F:0,_G:0,_I:_A})
			return{_B:_D,_q:A[:C],'placement_count':C}
		except Exception as G:return{_B:_A,_C:str(G)}
	def export_config(C):
		'Export configuration'
		try:import time;A={'version':'1.0','timestamp':time.time(),_g:unit_config};return A
		except Exception as B:return{'error':str(B)}
	def import_config(A,data):
		'Import configuration from data'
		try:
			if _g in data:unit_config.update(data[_g]);B=A.save_config();return{_B:B,_C:'Configuration imported successfully'}
			else:return{_B:_A,_C:'Invalid configuration format'}
		except Exception as C:return{_B:_A,_C:str(C)}
	def get_config_list(E):
		'Get list of available config files from configs folder'
		try:
			A=os.path.join(SCRIPT_DIR,_T)
			if not os.path.exists(A):return[]
			B=[]
			for C in os.listdir(A):
				if C.endswith(_h):B.append(C)
			return sorted(B)
		except Exception as D:print(f"Error getting config list: {D}");return[]
	def load_config_file(E,config_filename):
		'Load a specific config file and replace vanguards_config.txt';A=config_filename
		try:
			F=os.path.join(SCRIPT_DIR,_T);C=os.path.join(F,A)
			if not os.path.exists(C):return{_B:_A,_C:f"Config file {A} not found"}
			with open(C,'r')as B:G=B.read()
			with open(CONFIG_FILE,'w')as B:B.write(G)
			E.load_config();return{_B:_D,_C:f"Configuration loaded from {A}"}
		except Exception as D:print(f"Error loading config file: {D}");return{_B:_A,_C:str(D)}
	def check_tutorial(C):
		'Check if tutorial has been completed'
		try:A=os.path.join(SCRIPT_DIR,_r);return os.path.exists(A)
		except Exception as B:print(f"Error checking tutorial: {B}");return _A
	def complete_tutorial(D):
		'Mark tutorial as completed by creating Tutorial.txt'
		try:
			B=os.path.join(SCRIPT_DIR,_r)
			with open(B,'w')as C:C.write('Tutorial completed\n')
			return{_B:_D,_C:'Tutorial completed'}
		except Exception as A:print(f"Error completing tutorial: {A}");return{_B:_A,_C:str(A)}
	def align_with_roblox(W):
		'Align the Unit Manager window inside the ALS.ahk window progress area'
		try:
			import win32gui as B,win32con as E;L=_H
			def R(hwnd,windows):
				C=hwnd
				if B.IsWindowVisible(C):
					A=B.GetWindowText(C);D=B.GetClassName(C)
					if _Z in A.lower()and len(A)<20 and _s not in A.lower()and _t not in A.lower()and _u not in A.lower()and _v not in A.lower()and _w not in A.lower()and _x not in A.lower()and _y not in A.lower()and'edge'not in A.lower()and _z not in A.lower()and _A0 not in A.lower()and(A.lower().strip()==_Z or _A1 in D.lower()):windows.append((C,A))
				return _D
			F=[];B.EnumWindows(R,F)
			if not F:return{_B:_A,_C:'ALS.ahk (Mango) window not found. Make sure ALS.ahk is running and visible.'}
			L=F[0][0];S=F[0][1];logger.info(f"Found ALS window: {S}");T=B.GetWindowRect(L);H,I,U,V=T;M=U-H;N=V-I;logger.info(f"ALS window: position=({H}, {I}), size=({M}x{N})");A=H+0;C=I+30;J=min(1000,M);K=min(700,N-30);logger.info(f"Target position for Unit Manager: ({A}, {C}), size=({J}x{K})")
			if webview.windows:
				O=webview.windows[0]
				try:logger.info('Attempting to position using webview API...');O.move(A,C);O.resize(J,K);logger.info(f"Successfully positioned using webview API");return{_B:_D,_C:f"Window positioned perfectly inside ALS progress bar at ({A}, {C})"}
				except AttributeError:
					logger.info('webview.move/resize not available, trying win32 API...');import time;time.sleep(.2);P=[_a,_i,_j];G=_H
					for Q in P:
						G=B.FindWindow(_H,Q)
						if G:logger.info(f"Found Unit Manager window with title: {Q}");break
					if G:B.SetWindowPos(G,E.HWND_TOP,A,C,J,K,E.SWP_SHOWWINDOW|E.SWP_NOACTIVATE|E.SWP_ASYNCWINDOWPOS);logger.info(f"Successfully positioned using win32 API");return{_B:_D,_C:f"Window positioned perfectly inside ALS progress bar at ({A}, {C})"}
					else:return{_B:_A,_C:'Could not find Unit Manager window handle. Tried titles: '+', '.join(P)}
				except Exception as D:logger.error(f"Error during positioning: {D}");return{_B:_A,_C:f"Error during positioning: {str(D)}"}
			else:return{_B:_A,_C:'No webview window available'}
		except ImportError:return{_B:_A,_C:'pywin32 not installed. Install with: pip install pywin32'}
		except Exception as D:logger.error(f"Error aligning with ALS window: {D}");return{_B:_A,_C:f"Error: {str(D)}"}
	def get_roblox_window_info(E):
		'Get information about the ALS.ahk window for coordinate reference'
		try:
			import win32gui as C
			def D(hwnd,windows):
				D=hwnd
				if C.IsWindowVisible(D):
					A=C.GetWindowText(D);E=C.GetClassName(D)
					if _Z in A.lower()and len(A)<20 and _s not in A.lower()and _t not in A.lower()and _u not in A.lower()and _v not in A.lower()and _w not in A.lower()and _x not in A.lower()and _y not in A.lower()and'edge'not in A.lower()and _z not in A.lower()and _A0 not in A.lower()and(A.lower().strip()==_Z or _A1 in E.lower()):B=C.GetWindowRect(D);windows.append({'hwnd':D,'title':A,_F:B[0],_G:B[1],_k:B[2]-B[0],_l:B[3]-B[1],_W:{_F:B[0]+0,_G:B[1]+30,_k:1000,_l:700}})
				return _D
			A=[];C.EnumWindows(D,A)
			if A:return{_B:_D,_m:A}
			else:return{_B:_A,_C:'No ALS.ahk (Mango) windows found'}
		except ImportError:return{_B:_A,_C:'pywin32 not installed'}
		except Exception as B:print(f"Error getting ALS window info: {B}");return{_B:_A,_C:str(B)}
	def get_map_image(Y,map_name):
		'Get map image as data URL for web display';R='exists';Q='data_url';P='.png';O='Hog Town';N='Hollow Night Palace';M='Demon Skull Village';L='Abandoned Cathedral';K='Soul Society';J='Dragon Heaven';I='Giants District';E='FireFighters Base';A=map_name
		try:
			logger.info(f"Getting map image for: {A}");F={'Essence Map':'EssenceMap','Devil Dungeon':'DevilDungeon','Hell Invasion':'Hell_Invasion','Villain Invasion':'Villian_Invasion','Destroyed Shinjuku':'Destroyed_Shinjuku',I:I,J:J,K:K,L:L,M:M,'Firefighters Base':E,E:E,N:N,O:O}
			if A in F:B=F[A];logger.info(f"Using special case mapping: {A} -> {B}")
			else:B=A.replace(' ','_').replace('(','').replace(')','');logger.info(f"Using default name cleaning: {A} -> {B}")
			S=[P,'.jpg','.jpeg','.webp'];G=os.path.join(SCRIPT_DIR,'Images','Maps');logger.info(f"Looking for images in: {G}")
			for D in S:
				C=os.path.join(G,f"{B}{D}");logger.info(f"Checking path: {C}")
				if os.path.exists(C):
					logger.info(f"Found map image at: {C}");import base64 as T
					with open(C,_b)as U:V=U.read()
					W='image/png'if D.lower()==P else f"image/{D[1:].lower()}";X=f"data:{W};base64,{T.b64encode(V).decode(_c)}";return{_B:_D,Q:X,R:_D}
			return{_B:_D,Q:_H,R:_A}
		except Exception as H:print(f"Error getting map image: {H}");return{_B:_A,_C:str(H)}
	def minimize_window(A):'Minimize the application window';webview.windows[0].minimize()
	def close_window(A):'Close the application window';webview.windows[0].destroy()
	def save_marker_upgrades(H,slot_number,upgrades):
		'Save marker upgrade levels and priorities for a specific slot';D=slot_number
		try:
			A=f"slot{D}"
			if A not in unit_config:return{_B:_A,_C:f"Slot {D} not found"}
			if _M not in unit_config[A]:unit_config[A][_M]={}
			C={}
			for(E,B)in upgrades.items():
				if isinstance(B,dict):C[E]={_L:B.get(_L,'0'),_K:B.get(_K,_E)}
				else:C[E]={_L:B,_K:_E}
			unit_config[A][_M].update(C);F=H.save_config();return{_B:F,_C:'Marker upgrades saved'if F else'Error saving marker upgrades'}
		except Exception as G:print(f"Error saving marker upgrades: {G}");return{_B:_A,_C:str(G)}
	def get_marker_upgrades(E,slot_number):
		'Get marker upgrade levels for a specific slot';A=slot_number
		try:
			B=f"slot{A}"
			if B not in unit_config:return{_B:_A,_C:f"Slot {A} not found"}
			D=unit_config[B].get(_M,{});return{_B:_D,'upgrades':D}
		except Exception as C:print(f"Error getting marker upgrades: {C}");return{_B:_A,_C:str(C)}
	def get_all_marker_upgrades(F):
		'Get marker upgrade levels for all slots'
		try:
			A={}
			for B in range(1,7):
				C=f"slot{B}"
				if C in unit_config:
					D=unit_config[C].get(_M,{})
					if D:A[B]=D
			return{_B:_D,'upgrades':A}
		except Exception as E:print(f"Error getting all marker upgrades: {E}");return{_B:_A,_C:str(E)}
	def get_all_slot_markers(I):
		'Get all coordinate markers from all slots for global marker display'
		try:
			B=[]
			for C in range(1,7):
				D=f"slot{C}"
				if D in unit_config:
					G=unit_config[D];E=G.get(_J,[])
					if isinstance(E,list):
						for(H,A)in enumerate(E):
							if A and A.get(_I,_A):B.append({_F:A.get(_F,0),_G:A.get(_G,0),'slot_number':C,_p:H,_I:_D})
			return{_B:_D,_q:B}
		except Exception as F:print(f"Error getting all slot markers: {F}");return{_B:_A,_C:str(F)}
	def capture_roblox_units_screenshot(l):
		'Capture a screenshot of the bottom area of Roblox window where units are displayed using wscreenshot and cv2';Y='WINDOWSCLIENT';X='pid';N='roblox'
		try:
			logger.info('Starting screenshot capture using wscreenshot and cv2');A=_H;Z=['Roblox','RobloxPlayerBeta','RobloxPlayerBeta.exe']
			for E in Z:
				try:
					C=win32gui.FindWindow(_H,E)
					if C and win32gui.IsWindowVisible(C):A=C;logger.info(f"Found Roblox window using title: {E}");break
				except:continue
			if not A:
				try:
					import psutil as a
					for I in a.process_iter([X,_U]):
						if N in I.info[_U].lower():
							def b(hwnd,windows):
								A=hwnd
								if win32gui.IsWindowVisible(A):
									D,B=win32gui.GetWindowThreadProcessId(A)
									if B==I.info[X]:
										C=win32gui.GetWindowText(A)
										if C:windows.append(A)
								return _D
							D=[];win32gui.EnumWindows(b,D)
							if D:A=D[0];logger.info(f"Found Roblox window via process: {I.info[_U]}");break
				except ImportError:logger.warning('psutil not available for process-based detection')
			if not A:
				try:
					C=win32gui.FindWindow(Y,_H)
					if C and win32gui.IsWindowVisible(C):
						O=win32gui.GetWindowText(C)
						if N in O.lower()or O=='':A=C;logger.info(f"Found Roblox window using class WINDOWSCLIENT")
				except:pass
			if not A:
				def c(hwnd,windows):
					D=windows;A=hwnd
					if win32gui.IsWindowVisible(A):
						try:
							B=win32gui.GetWindowText(A)
							if B and(N in B.lower()or'anime'in B.lower()or'vanguards'in B.lower()or'tower defense'in B.lower()):D.append(A)
							elif not B:
								C=win32gui.GetWindowRect(A);E=C[2]-C[0];F=C[3]-C[1]
								if 800<=E<=1920 and 600<=F<=1080:
									G=win32gui.GetClassName(A)
									if G in[Y,'RobloxWin']:D.append(A)
						except:pass
					return _D
				D=[];win32gui.EnumWindows(c,D)
				if D:A=D[0];logger.info(f"Found Roblox window via enumeration")
			if not A:return{_B:_A,_C:'Roblox window not found. Please make sure Roblox is running and visible.'}
			logger.info(f"Using Roblox window: {win32gui.GetWindowText(A)}");d=win32gui.GetWindowRect(A);F,P,J,G=d;Q=J-F;R=G-P;logger.info(f"Roblox window dimensions: {Q}x{R} at ({F}, {P})")
			try:win32gui.SetForegroundWindow(A);time.sleep(.8);logger.info('Brought Roblox window to foreground')
			except Exception as B:logger.warning(f"Could not bring Roblox to foreground: {B}")
			S=int(R*.3);K=G-S;logger.info(f"Capturing unit area: {Q}x{S} at ({F}, {K})")
			try:e=wscreenshot.screenshot();logger.info('Successfully captured screen using wscreenshot');f=np.array(e);g=cv2.cvtColor(f,cv2.COLOR_RGB2BGR);T=g[K:G,F:J];logger.info(f"Cropped image to unit area: {T.shape}");h=cv2.cvtColor(T,cv2.COLOR_BGR2RGB);from PIL import Image;U=Image.fromarray(h)
			except Exception as B:
				logger.error(f"Error with wscreenshot/cv2 method: {B}")
				try:from PIL import ImageGrab as i;U=i.grab(bbox=(F,K,J,G));logger.info('Used PIL ImageGrab as fallback')
				except Exception as V:logger.error(f"Fallback method also failed: {V}");return{_B:_A,_C:f"All screenshot methods failed. wscreenshot error: {B}, PIL error: {V}"}
			try:
				if webview.windows:
					j=[_a,_i,_j];H=_H
					for E in j:
						H=win32gui.FindWindow(_H,E)
						if H:win32gui.SetForegroundWindow(H);logger.info(f"Returned focus to Unit Manager window: {E}");break
					if not H:logger.warning('Could not find Unit Manager window to return focus')
			except Exception as B:logger.error(f"Error returning focus to Unit Manager: {B}")
			k=datetime.now().strftime('%Y%m%d_%H%M%S');W=f"units_screenshot_{k}.png";L=os.path.join(SCRIPT_DIR,'screenshots')
			if not os.path.exists(L):os.makedirs(L)
			M=os.path.join(L,W);U.save(M);logger.info(f"Screenshot saved to: {M}");return{_B:_D,_A2:M,'filename':W}
		except Exception as B:logger.error(f"Error capturing screenshot: {B}");return{_B:_A,_C:f"Error capturing screenshot: {str(B)}"}
	def save_config_with_screenshot(J,config_name):
		'Save current configuration with a screenshot to the configs folder';A=config_name
		try:
			if not A or not A.strip():return{_B:_A,_C:'Configuration name is required'}
			A=A.strip();C=os.path.join(SCRIPT_DIR,_T)
			if not os.path.exists(C):os.makedirs(C)
			D=J.capture_roblox_units_screenshot();K=f"{A}.txt";L=os.path.join(C,K)
			try:
				with open(CONFIG_FILE,'r')as M:N=M.read()
				with open(L,'w')as O:O.write(N)
			except Exception as B:return{_B:_A,_C:f"Error saving config file: {str(B)}"}
			E=_H
			if D.get(_B):
				try:
					F=D[_A2]
					if os.path.exists(F):
						with open(F,_b)as G:P=G.read()
						E=base64.b64encode(P).decode(_c);os.remove(F);logger.info(f"Converted screenshot to base64 and cleaned up temporary file")
				except Exception as B:logger.error(f"Error converting screenshot to base64: {B}");E=_H
			H={_U:A,_n:datetime.now().isoformat(),_O:D.get(_B,_A)and E is not _H,_Q:E};Q=os.path.join(C,f"{A}_metadata.json")
			with open(Q,'w')as G:json.dump(H,G,indent=2)
			I=f"Configuration '{A}' saved successfully"
			if H[_O]:I+=' with unit screenshot'
			else:I+=f" (screenshot failed: {D.get(_C,_X)})"
			return{_B:_D,_C:I,_O:H[_O]}
		except Exception as B:print(f"Error saving config with screenshot: {B}");return{_B:_A,_C:f"Error saving configuration: {str(B)}"}
	def get_config_metadata(J,config_filename):
		'Get metadata for a specific configuration including screenshot info';F='metadata'
		try:
			B=config_filename.replace(_h,'');C=os.path.join(SCRIPT_DIR,_T);D=os.path.join(C,f"{B}_metadata.json")
			if os.path.exists(D):
				with open(D,'r')as G:A=json.load(G)
				if _Q in A:A[_O]=bool(A.get(_Q))
				elif _d in A:H=os.path.join(C,A[_d]);A[_O]=os.path.exists(H)
				return{_B:_D,F:A}
			else:I=os.path.exists(os.path.join(C,f"{B}_units.png"));return{_B:_D,F:{_U:B,_O:I,_n:_H}}
		except Exception as E:print(f"Error getting config metadata: {E}");return{_B:_A,_C:str(E)}
	def migrate_screenshots_to_base64(R):
		'Migrate existing separate PNG screenshot files to base64 data embedded in metadata files';N='_units.png';M='errors'
		try:
			C=os.path.join(SCRIPT_DIR,_T)
			if not os.path.exists(C):return{_B:_D,_C:'No configs directory found, nothing to migrate',_f:0,M:[]}
			G=0;D=[];O=[A for A in os.listdir(C)if A.endswith(N)]
			for H in O:
				try:
					E=H.replace(N,'');I=os.path.join(C,f"{E}_metadata.json");J=os.path.join(C,H)
					if os.path.exists(I):
						with open(I,'r')as B:A=json.load(B)
						if _Q in A and A[_Q]:logger.info(f"Skipping {E}: already migrated");continue
					else:A={_U:E,_n:datetime.now().isoformat(),_O:_A}
					with open(J,_b)as B:P=B.read()
					Q=base64.b64encode(P).decode(_c);A[_O]=_D;A[_Q]=Q
					if _d in A:del A[_d]
					with open(I,'w')as B:json.dump(A,B,indent=2)
					os.remove(J);G+=1;logger.info(f"Successfully migrated {E}")
				except Exception as F:K=f"Error migrating {H}: {str(F)}";logger.error(K);D.append(K)
			L=f"Migration completed: {G} screenshots converted to base64"
			if D:L+=f" ({len(D)} errors encountered)"
			return{_B:_D,_C:L,_f:G,M:D}
		except Exception as F:logger.error(f"Error during migration: {F}");return{_B:_A,_C:f"Migration failed: {str(F)}"}
	def get_config_screenshot(J,config_filename):
		'Get the screenshot for a specific configuration';H='screenshot_data'
		try:
			D=config_filename.replace(_h,'');E=os.path.join(SCRIPT_DIR,_T);F=os.path.join(E,f"{D}_metadata.json")
			if os.path.exists(F):
				try:
					with open(F,'r')as B:C=json.load(B)
					if C.get(_O)and C.get(_Q):return{_B:_D,H:C[_Q]}
				except Exception as A:logger.error(f"Error reading metadata for screenshot: {A}")
			G=os.path.join(E,f"{D}_units.png")
			if os.path.exists(G):
				try:
					with open(G,_b)as B:I=base64.b64encode(B.read()).decode(_c)
					return{_B:_D,H:I}
				except Exception as A:logger.error(f"Error reading PNG screenshot: {A}")
			return{_B:_A,_C:'Screenshot not found'}
		except Exception as A:print(f"Error getting config screenshot: {A}");return{_B:_A,_C:str(A)}
	def load_vanguards_config(B):
		'Load and return the current vanguards config data for marker editing'
		try:return{_B:_D,'data':unit_config}
		except Exception as A:print(f"Error loading vanguards config: {A}");return{_B:_A,_C:str(A)}
	def remove_slot_from_config(E,slot_number):
		'Remove a specific slot from the config file without affecting other slots';A=slot_number
		try:
			B=f"slot{A}"
			if B in unit_config:del unit_config[B]
			C=E.save_config();return{_B:C,_C:f"Slot {A} removed from config"if C else'Error removing slot from config'}
		except Exception as D:print(f"Error removing slot {A}: {D}");return{_B:_A,_C:str(D)}
	def clear_slot_from_config(A,slot_number):'Clear a specific slot from the config file (same as remove for our purposes)';return A.remove_slot_from_config(slot_number)
def start_unit_manager():
	'Start the Unit Manager desktop application';logger.info('Starting MangoGuards Unit Manager Desktop App...');B=os.path.join(SCRIPT_DIR,'unitmanager_simple.html')
	if not os.path.exists(B):logger.error(f"Error: unitmanager.html not found at {B}");return
	E=UnitManagerAPI();webview.create_window(title=_a,url=B,width=1000,height=700,min_size=(800,500),resizable=_A,js_api=E,frameless=_D,on_top=_A,text_select=_A);A=_D
	def C():
		'Monitor window position and reposition when it moves';nonlocal A;import threading as B,time as H
		def I():
			R='Forced repositioning successful - maintaining perfect alignment';Q='Forcing repositioning after 10 seconds to ensure perfect alignment';nonlocal A;H.sleep(2);logger.info('Performing initial positioning...')
			try:
				P=E.align_with_roblox()
				if P.get(_B):logger.info('Initial positioning successful')
				else:logger.warning(f"Initial positioning failed: {P.get(_C,_X)}")
			except Exception as N:logger.error(f"Error during initial positioning: {N}")
			J=_H;C=_H;F=H.time()
			while A:
				try:
					if not A:logger.info('Monitoring thread shutdown requested - exiting cleanly');return
					O=E.get_roblox_window_info()
					if not O.get(_B)or not O.get(_m):
						logger.info('ALS window not found - closing Unit Manager immediately');A=_A
						if webview.windows:webview.windows[0].destroy()
						return
					L=O[_m][0];C=L[_W][_F],L[_W][_G],L[_W][_k],L[_W][_l];B=H.time()
					if B-F>=1e1 and A:
						logger.info(Q);D=E.align_with_roblox()
						if D.get(_B):logger.info(R);F=B
						else:logger.warning(f"Forced repositioning failed: {D.get(_C,_X)}");F=B
					if A and webview.windows:
						S=[_a,_i,_j];M=_H
						for T in S:
							M=win32gui.FindWindow(_H,T)
							if M:break
						if M and A:
							G=win32gui.GetWindowRect(M);K=G[0],G[1],G[2]-G[0],G[3]-G[1];B=H.time()
							if B-F>=1e1 and A:
								logger.info(Q);D=E.align_with_roblox()
								if D.get(_B):logger.info(R);J=C;F=B
								else:logger.warning(f"Forced repositioning failed: {D.get(_C,_X)}");F=B
							elif J is not _H and C is not _H and K!=C and A:
								U=abs(K[0]-C[0]);V=abs(K[1]-C[1])
								if U>20 or V>20:
									logger.info(f"Window moved significantly from target position. Current: {K}, Target: {C}")
									if not hasattr(I,'last_reposition_time'):I.last_reposition_time=0
									if B-I.last_reposition_time>3. and A:
										D=E.align_with_roblox()
										if D.get(_B):logger.info('Auto-repositioned window back to target location');J=C;I.last_reposition_time=B
										else:logger.warning(f"Auto-repositioning failed: {D.get(_C,_X)}")
									elif A:logger.info('Repositioning skipped due to cooldown (preventing bounce effect)')
							elif J is _H and A:J=K
				except Exception as N:
					if A:logger.error(f"Error during position monitoring: {N}")
					else:logger.info('Exception occurred during shutdown - ignoring')
				if A:H.sleep(2.)
				else:logger.info('Monitoring disabled during sleep - exiting thread');return
		C=B.Thread(target=I,daemon=_D);C.start();logger.info('Position monitoring thread started (monitors for movement)')
	C()
	def D():nonlocal A;A=_A;logger.info('Monitoring thread cleanup requested')
	try:webview.start(debug=_A)
	finally:D()
if __name__=='__main__':start_unit_manager()