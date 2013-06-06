from flask import Flask, render_template, _app_ctx_stack, request
import pymongo
import json
import model
import time
from flask.ext.pymongo import PyMongo
from icu import Locale, Collator

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


@app.route('/find_attendee')
def find_attendee():
    searchTerm = request.args.get('s', '')
    if not searchTerm:
        return '{}'
    db = get_db()
    attendees = model.find_attendees(db, searchTerm)
    attendees = attendees[:30]
    for attendee in attendees:
        attendee['_id'] = str(attendee['_id'])
    return json.dumps(attendees)
