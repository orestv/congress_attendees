from flask import Flask, render_template, _app_ctx_stack, request
import pymongo
import json
import model
import time
from bson import BSON
from bson import json_util
from flask.ext.pymongo import PyMongo

app = Flask(__name__)
app.config['MONGO_HOST'] = 'ds027688.mongolab.com'
app.config['MONGO_PORT'] = 27688
app.config['MONGO_DBNAME'] = 'congress_new'
app.config['MONGO_USERNAME'] = 'application'
app.config['MONGO_PASSWORD'] = 'master'
mongo = PyMongo(app)
print mongo

def get_db():
	print mongo.db
	return mongo.db
    # top = _app_ctx_stack.top
    # if not hasattr(top, 'dbconn'):    	
    # 	print 'Connecting to database...'
    # 	t1 = time.time()
    #     dbconn = pymongo.Connection('mongodb://application:master@ds027338.mongolab.com:27338/congress')
    #     print "connected in %s" % (time.time() - t1,)
    #     top.dbconn = dbconn
    #     print top.dbconn
    # return top.dbconn.congress

# @app.teardown_appcontext
# def close_db_connection(exception):
#     """Closes the database again at the end of the request."""
#     top = _app_ctx_stack.top
#     if hasattr(top, 'dbconn'):
#         # top.dbconn.disconnect()
#         pass

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
		'lastname': a['lastname']} for a in attendees]
	print time.time() - t2
	return json.dumps(result)

app.run(debug = True)
