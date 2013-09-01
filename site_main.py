#!/usr/bin/env python
# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*
from flask import Flask, render_template, _app_ctx_stack, request, url_for, redirect, flash
import pymongo
import json
import model, users
import time
from flask.ext.pymongo import PyMongo
from icu import Locale, Collator
import locale
import fields
from bson import json_util
import flask.ext.login as flask_login
from threading import Lock

from time import sleep

app = Flask(__name__)
app.event_update_lock = Lock()

app.config.from_pyfile('config.cfg')
mongo = PyMongo(app)

login_manager = flask_login.LoginManager()
login_manager.login_view = 'root'
login_manager.init_app(app)

def get_db():
    return mongo.db

@login_manager.user_loader
def load_user(uid):
    return users.get_user_by_id(get_db(), uid.encode('utf-8'))

@app.route('/')
@app.route('/login', methods=['GET'])
def root():
    if not flask_login.current_user.is_authenticated():
        return render_template('login.html', 
            user = flask_login.current_user)
    else:
        return redirect(url_for('index'))

@app.route('/login', methods=['POST'])
def login_request():
    login, password = request.form.get('login'), request.form.get('password')
    user = users.get_user_by_credentials(get_db(), login, password)
    if user:
        flask_login.login_user(user)
        return redirect(url_for('index'))
    else:
        flash(u'Логін чи пароль невірні!')
        return redirect(url_for('root'))

@app.route('/index')
@flask_login.login_required
def index():
    events = get_all_events()
    return render_template('index.html', 
        fields=fields.INFO_FIELDS, 
        events = events, 
        user = flask_login.current_user)

@app.route('/attendee_event', methods=['PUT', 'DELETE'])
@flask_login.login_required
def attendee_event():
    event_id = request.form.get('eid', None)
    attendee_id = request.form.get('aid', None)
    if not event_id or not attendee_id:
        return json.dumps({'success': False, 'error': {
            'type': 'exception',
            'message': 'Event Id or Attendee Id not specified'}
            })
    if request.method == 'PUT':
        with app.event_update_lock:
            db_evt = model.get_event(get_db(), event_id)
            if 'limit' in db_evt:
                evt = model.get_event_free_places(get_db(), event_id)
                if evt['free_places'] <= 0:
                    return json.dumps({'success': False, 'error': {
                        'type': 'outofplaces'
                        }})
            model.book_attendee_event(get_db(), attendee_id, event_id)
    elif request.method == 'DELETE':
        with app.event_update_lock:
            model.unbook_attendee_event(get_db(), attendee_id, event_id)        
    return json.dumps({'success': True})

@app.route('/events', methods=['GET'])
def events():
    request_type = request.args.get('type', None)
    eid = request.args.get('id', None)
    print "event id is %s" % (eid)
    result = {}
    if request_type == 'free_places':
        if eid:
            result = {'event': model.get_event_free_places(get_db(), eid)}
        else:
            result = {'events': model.get_events_free_places(get_db())}
    else:
        result = {'events': get_all_events()}
    return json.dumps(result)

@app.route('/attendees', methods=['POST'])
@flask_login.login_required
def add_attendee():
    aid = model.add_attendee(get_db())

    valid_field_ids = [field['fieldId'] for field in fields.INFO_FIELDS]
    submitted_field_ids = filter(lambda x : x in request.form, valid_field_ids)
    if submitted_field_ids:
        attendee_info = {field: request.form[field] for field in submitted_field_ids}
        model.set_attendee_info(get_db(), id, attendee_info)

    attendee = find_attendee_by_id(aid)
    return json.dumps({'attendee': attendee})

@app.route('/attendees', methods=['PUT', 'DELETE'])
@flask_login.login_required
def update_attendee():
    id = request.args.get('id', None)
    user_id = flask_login.current_user.get_id()
    if request.method == 'DELETE':
        model.delete_attendee(get_db(), id)
    else:
        events = request.form.get('events', None)
        if id is not None:
            if events is not None:
                events = events.split(',') if events else []
                model.set_attendee_events(get_db(), id, events)
            registered = request.args.get('registered', None)
            if registered is not None:
                registered = bool(registered)
                model.set_attendee_registered(get_db(), id, user_id, registered)
        # if flask_login.current_user.is_admin:
        print 'Admin updating an attendee!'
        valid_field_ids = [field['fieldId'] for field in fields.INFO_FIELDS]
        print valid_field_ids
        submitted_field_ids = filter(lambda x : x in request.form, valid_field_ids)
        print submitted_field_ids
        if submitted_field_ids:
            attendee_info = {field: request.form[field] for field in submitted_field_ids}
            print attendee_info
            model.set_attendee_info(get_db(), id, attendee_info)
    return json.dumps({})

@app.route('/attendees', methods=['GET'])
@flask_login.login_required
def attendees():
    result = {}
    search_term = request.args.get('s', None)
    event_id = request.args.get('eventId', None)
    id = request.args.get('id', None)
    if search_term:
        result = find_attendees_by_word(search_term)
    elif event_id:
        result = model.get_event_attendees(get_db(), event_id)
    elif id:
        attendee = find_attendee_by_id(id)
        result = {'attendee': attendee}
    return json.dumps(result, default=json_util.default)

@app.route('/attendee_edit', methods=['GET'])
@flask_login.login_required
def edit_attendee():
    mode = request.args.get('mode', 'add')
    aid = request.args.get('id', None)   
    return render_template('attendee.html', 
        fields = fields.INFO_FIELDS,
        user = flask_login.current_user,
        events = get_all_events(),
        mode = mode, 
        attendee_id = aid)

@app.route('/dashboard')
@flask_login.login_required
def dashboard():
    if not flask_login.current_user.is_admin:
        return login_manager.unauthorized()
    events_cursor = model.get_events(get_db())
    events = list(events_cursor)
    for event in events:
        event['attendee_count'] = model.get_event_attendees_count(get_db(), event['_id'])
    return render_template('dashboard.html',
        events = events, 
        user = flask_login.current_user,
        fields=fields.INFO_FIELDS)

@app.route('/logout')
def logout():
    flask_login.logout_user()
    return redirect('/')

def find_attendees_by_word(search_term):
    if not search_term:
        return {}
    db = get_db()
    attendees = model.find_attendees(db, search_term)
    locale.setlocale(locale.LC_ALL, 'uk_UA.UTF-8')
    attendee_count = len(attendees)
    attendees.sort(cmp = model.compare_attendees)
    attendees = attendees[:30]
    for a in attendees:
        a['_id'] = str(a['_id'])
    result = {'count': attendee_count, 'attendees': attendees}
    return result

def find_attendee_by_id(id):
    attendee = model.find_attendee(get_db(), id)
    if not attendee:
        return {}
    attendee['_id'] = str(attendee['_id'])
    return attendee

def get_all_events():
    events_cursor = model.get_events(get_db())
    events = []
    for event in events_cursor:
        event['_id'] = str(event['_id'])
        events.append(event)
    return events
