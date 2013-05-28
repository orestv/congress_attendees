from flask import Flask, render_template, _app_ctx_stack, request
import pymongo
import json
import model
import time
from flask.ext.pymongo import PyMongo
from icu import Locale, Collator

app = Flask(__name__)
app.config['MONGO_HOST'] = 'ds027688.mongolab.com'
app.config['MONGO_PORT'] = 27688
app.config['MONGO_DBNAME'] = 'congress_new'
app.config['MONGO_USERNAME'] = 'application'
app.config['MONGO_PASSWORD'] = 'master'
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
    t1 = time.time()
    attendees = model.find_attendees(db, searchTerm)

    print time.time() - t1
    t2 = time.time()

    result = [{'id': str(a['_id']),
               'firstname': a['firstname'],
               'middlename': a['middlename'],
               'lastname': a['lastname'],
               'city': a['city']} for a in attendees]

    collator = Collator.createInstance(Locale('uk_UA.UTF-8'))
    # attendees = sorted(attendees, key=lambda attendee: attendee[
    #                    'lastname'], cmp=collator.compare)

    result.sort(key=lambda attendee: attendee['lastname'])
    print 'Time spent forming result: %f' % (time.time() - t2)
    return json.dumps(result)

app.run(debug=True)
