import re
from flask.ext.pymongo import PyMongo
from flask.ext.pymongo import ASCENDING, DESCENDING

def get_find_term(field, word):
	return {field: re.compile('^%s' % word, re.IGNORECASE)}

def find_attendees(db, search_term):
	words = search_term.split(' ')
	search_fields = ['lastname', 'city', 'firstname', 'middlename']

	word_queries = []
	for word in words:
		word_condition = [get_find_term(field, word) for field in search_fields]
		word_query = {'$or': word_condition}
		word_queries.append(word_query)

	query = {'$and': word_queries}
	attendees = db.attendees
	cursor = attendees.find(query, limit=15)
	cursor.sort([('lastname', ASCENDING), ('city', ASCENDING)])
	return cursor