"""
This is a setup.py script generated by py2applet

Usage:
    python setup.py py2app
"""

from setuptools import setup

APP = ['Hipparchia.py']
DATA_FILES = []
OPTIONS = {
	'packages': ['flask', 'werkzeug', 'config', 'psycopg2', 'jinja2'],
	'resources': ['./server/templates', './server/static'],
	'iconfile': '',
	 'plist': {
		'LSBackgroundOnly': False,
		'LSUIElement': False,	 		
		'CFBundleName': 'HipparchiaServer',
		'CFBundleShortVersionString':'0.9b.3', 
		'CFBundleVersion': '0.0.1', 
		'CFBundleIdentifier':'unidentified.edu.Hipparchia', 
		'NSHumanReadableCopyright': '@ e-gun 2017'}
	}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
