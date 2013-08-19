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

app = Flask(__name__)

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
        return render_template('login.html')
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
    events_cursor = model.get_events(get_db())
    events = []
    for event in events_cursor:
        event['_id'] = str(event['_id'])
        events.append(event)
    return render_template('index.html', 
        fields=fields.INFO_FIELDS, 
        events = events, 
        user = flask_login.current_user)

@app.route('/attendees', methods=['PUT'])
@flask_login.login_required
def update_attendee():
    id = request.args.get('id', None)
    events = request.form.get('events', None)
    if events is not None:
        events = events.split(',') if events else []
        model.set_attendee_events(get_db(), id, events)
    registered = request.args.get('registered', None)
    if registered is not None:
        registered = bool(registered)
        model.set_attendee_registered(get_db(), id, registered)
    if flask_login.current_user.is_admin:
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
        result = [r for r in result]
        print result
    elif id:
        attendee = find_attendee_by_id(id)
        events_db = model.get_events(get_db())
        events = []
        for event in events_db:
            if 'limit' in event:
                event['attendees'] = model.get_event_attendees_count(get_db(), event['_id'])
            events.append(event)
        result = {'attendee': attendee, 'events': events}
    return json.dumps(result, default=json_util.default)

@app.route('/dashboard')
@flask_login.login_required
def dashboard():
    if not flask_login.current_user.is_admin:
        return login_manager.unauthorized()
    events_cursor = model.get_events(get_db())
    events = list(events_cursor)
    for event in events:
        event['attendee_count'] = model.get_event_attendees_count(get_db(), event['_id'])
    return render_template('dashboard.html', events = events)

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
    result = {'count': attendee_count, 'attendees': attendees}
    return result

def find_attendee_by_id(id):
    cursor = model.find_attendee(get_db(), id)
    if not cursor:
        return {}
    attendee = cursor[0]
    return attendee
