import pymongo
import re

def get_find_term(field, word):
	return {field: re.compile('^%s' % word, re.IGNORECASE)}

def find_attendees(db, search_term):
	words = search_term.split(' ')
	search_fields = ['firstname', 'lastname', 'middlename']

	word_queries = []
	for word in words:
		word_condition = [get_find_term(field, word) for field in search_fields]
		word_query = {'$or': word_condition}
		word_queries.append(word_query)

	query = {'$and': word_queries}
	attendees = db.attendees
	return attendees.find(query, limit=15)