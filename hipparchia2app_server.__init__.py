# -*- coding: utf-8 -*-
from flask import Flask

hipparchia = Flask(__name__, template_folder='/Users/erik/hipparchia_venv/HipparchiaServer2app/dist/Hipparchia.app/Contents/Resources/templates',
	static_folder='/Users/erik/hipparchia_venv/HipparchiaServer2app/dist/Hipparchia.app/Contents/Resources/static')
hipparchia.config.from_object('config')

from server import startup
from server.routes import browseroute, frontpage, getterroutes, hintroutes, inforoutes, lexicalroutes, searchroute, \
	selectionroutes, textandindexroutes, websocketroutes
