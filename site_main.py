from flask import Flask, render_template, _app_ctx_stack, request
import pymongo
import json
import model
import time
from flask.ext.pymongo import PyMongo
from icu import Locale, Collator
import locale

app = Flask(__name__)

app.config['MONGO_DBNAME'] = 'congress'
mongo = PyMongo(app)
print mongo


def get_db():
    return mongo.db


@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')

def find_attendees_by_word(search_term):
    if not search_term:
        return {}
    db = get_db()
    attendees = model.find_attendees(db, search_term)
    locale.setlocale(locale.LC_ALL, 'uk_UA.UTF-8')
    attendee_count = len(attendees)
    attendees.sort(cmp = model.compare_attendees)
    attendees = attendees[:30]
    for attendee in attendees:
        attendee['_id'] = str(attendee['_id'])
    result = {'count': attendee_count, 'attendees': attendees}
    return result

def find_attendee_by_id(id):
    cursor = model.find_attendee(get_db(), id)
    if not cursor:
        return {}
    attendee = cursor[0]
    attendee['_id'] = str(attendee['_id'])
    return attendee

@app.route('/attendees')
def attendees():
    result = {}
    search_term = request.args.get('s', None)
    if search_term:
        result = find_attendees_by_word(search_term)
    id = request.args.get('id', None)
    if id:
        result = find_attendee_by_id(id)
    return json.dumps(result)
