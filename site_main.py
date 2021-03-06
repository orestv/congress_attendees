#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask, render_template, _app_ctx_stack, request, url_for, redirect, flash, send_file
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
import logging
from logging import FileHandler
from TlsSMTPHandler import TlsSMTPHandler
import sys
import export

from time import sleep

app = Flask(__name__)
app.event_update_lock = Lock()

app.config.from_pyfile('config.cfg')

log_filename = app.config['LOG_FILENAME']
if log_filename:
    try:
        app.logger.addHandler(FileHandler(log_filename))
    except:
        pass
try:
    handler = TlsSMTPHandler(('smtp.gmail.com', 587),
        app.config['EMAIL_LOGIN'], [app.config['EMAIL_RECIPIENT']], 
        app.config['EMAIL_SUBJECT'],
        (app.config['EMAIL_LOGIN'], app.config['EMAIL_PASSWORD']))
    app.logger.addHandler(handler)
except Exception as ex:
    app.logger.exception(ex)


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
    password = request.form.get('password')
    user = users.get_user_by_credentials(get_db(), password)
    if user:
        flask_login.login_user(user)
        return redirect(url_for('index'))
    else:
        flash(u'Пароль невірний!')
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
    event_id = request.args.get('eid', None)
    if not event_id:
        event_id = request.form.get('eid', None)
    attendee_id = request.args.get('aid', None)
    if not attendee_id:
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
                cash = request.args.get('cash', 0)
                registered = bool(registered)
                model.set_attendee_registered(get_db(), id, user_id, registered, cash)
        valid_field_ids = [field['fieldId'] for field in fields.INFO_FIELDS]
        submitted_field_ids = filter(lambda x : x in request.form, valid_field_ids)
        if submitted_field_ids:
            attendee_info = {field: request.form[field] for field in submitted_field_ids}
            for field in fields.INFO_FIELDS:
                if field['type'] == 'checkbox' and field['fieldId'] in attendee_info:
                    value = attendee_info[field['fieldId']]
                    value = (value == u'true')
                    attendee_info[field['fieldId']] = value
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
        sort_attendees_by_name(result)
        for a in result:
            a['_id'] = str(a['_id'])
    elif id:
        attendee = find_attendee_by_id(id)
        result = {'attendee': attendee}
    return json.dumps(result, default=json_util.default)

@app.route('/admin/reset', methods=['GET', 'POST'])
@flask_login.login_required
def reset():
    if not flask_login.current_user.is_admin:
        return login_manager.unauthorized()
    if request.method == 'GET':
        return render_template('reset.html',
            user = flask_login.current_user)
    else:
        from init import init_events, init_attendees, init_users
        init_events(get_db())
        init_attendees(get_db(), app.config['FILES_ROOT'])
        init_users(get_db(), app.config['FILES_ROOT'])
        return redirect('/index')

@app.route('/attendee_edit', methods=['GET'])
@flask_login.login_required
def edit_attendee():
    aid = request.args.get('id', None)
    attendee = find_attendee_by_id(aid)
    reg_data = None
    r_id = attendee.get('registered_by', None)
    if r_id:
        reg_data = {
            'registrator': model.get_user_by_id(get_db(), r_id),
            'registered_on': attendee['registered_on'],
        }
    if aid and not attendee:
        return redirect('/index')
    if not flask_login.current_user.is_admin \
            and attendee and attendee.get('registered', False):
        return redirect('/index')
    return render_template('attendee.html',
        fields = fields.INFO_FIELDS,
        user = flask_login.current_user,
        events = get_all_events(),
        reg_data = reg_data,
        attendee_id = aid)

@app.route('/admin/events')
@flask_login.login_required
def admin_events():
    if not flask_login.current_user.is_admin:
        return login_manager.unauthorized()
    events_cursor = model.get_events(get_db())
    events = list(events_cursor)
    for event in events:
        event['attendee_count'] = model.get_event_attendees_count(get_db(), event['_id'])
        if event.get('limit', None):
            event['free_places'] = event['limit'] - event['attendee_count']
    return render_template('events.html',
        events = events,
        user = flask_login.current_user,
        fields = fields.INFO_FIELDS)

@app.route('/admin/report/download')
@flask_login.login_required
def download_admin_report():
    if not flask_login.current_user.is_admin:
        return login_manager.unauthorized()
    db = get_db()

    events = list(model.get_events(db))
    attendees = list(model.get_attendees(db))
    sort_attendees_by_name(attendees)
    users = model.get_attendee_count_by_registrators(db)
    sort_users_by_name(users)

    fname = export.export(attendees, events, users)
    send_file(fname, as_attachment=True)
    return send_file(fname, as_attachment=True)


@app.route('/admin/report')
@flask_login.login_required
def admin_report():
    if not flask_login.current_user.is_admin:
        return login_manager.unauthorized()
    db = get_db()
    total_attendee_count = model.get_all_attendee_count(db)
    registered_attendee_count = model.get_registered_attendee_count(db)
    registrators = model.get_attendee_count_by_registrators(db)
    sort_users_by_name(registrators)

    return render_template('report.html',
        user = flask_login.current_user,
        total_attendee_count = total_attendee_count,
        registered_attendee_count = registered_attendee_count,
        registrators = registrators)

@app.route('/events', methods=['GET'])
def events():
    request_type = request.args.get('type', None)
    eid = request.args.get('id', None)
    result = {}
    if request_type == 'free_places':
        if eid:
            result = {'event': model.get_event_free_places(get_db(), eid)}
        else:
            result = {'events': model.get_events_free_places(get_db())}
        return json.dumps(result)
    else:
        result = {'events': get_all_events()}
        return json.dumps(result)

@app.route('/logout')
def logout():
    flask_login.logout_user()
    return redirect('/')

def find_attendees_by_word(search_term):
    if not search_term:
        return {}
    db = get_db()
    attendees = model.find_attendees(db, search_term)
    sort_attendees_by_name(attendees)
    attendee_count = len(attendees)
    attendees = attendees[:30]
    for a in attendees:
        a['_id'] = str(a['_id'])
    result = {'count': attendee_count, 'attendees': attendees}
    return result

def sort_attendees_by_name(attendees):
    locale.setlocale(locale.LC_ALL, 'uk_UA.UTF-8')
    attendees.sort(cmp = model.get_comparer(['lastname', 'firstname', 'middlename']))

def sort_users_by_name(users):
    locale.setlocale(locale.LC_ALL, 'uk_UA.UTF-8')
    users.sort(cmp = model.get_comparer(['lastname', 'firstname']))

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

app.run(debug=True, threaded=True)
