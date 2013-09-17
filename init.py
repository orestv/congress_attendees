#!/usr/bin/env python
# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*-
import sqlite3 as sql
import random
import pymongo
from pymongo import MongoClient
import re
from string import digits
import os
import crypt

INFO_FIELDS = [
	{'col': 0, 'id': 'lastname'},
	{'col': 1, 'id': 'firstname'},
	{'col': 2, 'id': 'middlename'},
	{'col': 3, 'id': 'position'},
	{'col': 4, 'id': 'rank'},
	{'col': 5, 'id': 'city'},
	{'col': 6, 'id': 'region'},
	# {'col': 5, 'id': 'organization'},
	{'col': 7, 'id': 'email'},
	{'col': 8, 'id': 'phone'},
	# {'col': 11, 'id': 'delegate', 'bool': True}
]
EVENT_FIELDS = [
	{'col': 10, 'id': ['registration', 'doctor', 'materials', 'dinner_18', 'dinner_19', 'dinner_20']},
	{'col': 11, 'id': ['ceremonial_dinner']},
]

def read_names(filename):
	input_file = open(filename, 'r')
	result = [name.replace('\n', '') for name in input_file]
	result = [name.decode('utf-8') for name in result]
	input_file.close()
	return result

def generate_middlename(firstname):
	suffix = u'вич'
	if firstname[-2:] != u'о':
		firstname += u'о'
	return firstname + suffix

def generate_digit_sequence(length):
	return ''.join(random.choice(digits) for d in xrange(length))

def generate_phone():
	country = generate_digit_sequence(2)
	city = generate_digit_sequence(3)
	phone = generate_digit_sequence(7)
	return '+%s (%s) %s' % (country, city, phone)

def db_connect():
	con = sql.connect('congress.db')
	return con

def create_attendee(cursor, firstname, middlename, lastname):
	cur.execute(u'INSERT INTO attendees (firstname, middlename, lastname) VALUES (:firstname, :middlename, :lastname)',
		{'firstname': firstname,
		'middlename': middlename,
		'lastname': lastname})

EVENTS = [
	{'caption': u'Обов’язковий внесок інтерна',
		'import_id': 'registration', 'price': 100,
		'default': True,
		'item_caption': u'сертифікат і бейджик'},
	{'caption': u'Доплата лікаря',
		'import_id': 'doctor', 'price': 100,
		'default': True},
	{'caption': u'Пакет матеріалів',
		'import_id': 'materials', 'price': 100,
		'limit': 1000, 'default': True,
		'item_caption': u'пакет матеріалів'},
	{'caption': u'Обід 18.09 в 14 год.',
		'import_id': 'dinner_18',
		'limit': 400, 'default': True,
		'item_caption': u'квиток на обід 18.09'},
	{'caption': u'Обід 19.09 в 13 год.',
		'import_id': 'dinner_19',
		'price': 50, 'limit': 1000, 'default': True,
		'item_caption': u'квиток на обід 19.09'},
	{'caption': u'Обід 20.09 в 13 год.',
		'import_id': 'dinner_20',
		'price': 50, 'limit': 1000, 'default': True,
		'item_caption': u'квиток на обід 20.09'},
	{'caption': u'Екскурсія 19.09 в 14 год.',
		'import_id': 'excursion_19',
		'price': 40, 'limit': 90,
		'item_caption': u'квиток на екскурсію 19.09'},
	{'caption': u'Екскурсія 20.09 в 14 год.',
		'import_id': 'excursion_20',
		'price': 40, 'limit': 90,
		'item_caption': u'квиток на екскурсію 20.09'},
	{'caption': u'Церемонія відкриття 18.09 в 19 год.',
		'import_id': 'opening', 'limit': 820,
		'item_caption': u'квиток на церемонію відкриття'},
	{'caption': u'Урочиста вечеря 19.09 в 19 год.',
		'import_id': 'ceremonial_dinner',
		'price': 300, 'limit': 500,
		'item_caption': u'квиток на урочисту вечерю'}
]


def init_attendees(db, root=None):
	db.attendees.drop()
	events = {}
	free_events = []
	for field in EVENT_FIELDS:
		for import_id in field['id']:
			event = db.events.find_one({'import_id': import_id})
			if not event.get('price', None):
				free_events.append(str(event['_id']))
			events[import_id] = str(event['_id'])
	path = 'attendees.csv'
	if root:
		path = os.path.join(root, path)
	with open(path, 'r') as f:
		for line in f:
			if line.startswith('Прізвище'):
				continue
			items = line.split('/')
			attendee = {field['id']: items[field['col']].decode('utf-8') for field in INFO_FIELDS}
			for field in INFO_FIELDS:
				if field.get('bool', False):
					value = items[field['col']]
					attendee[field['id']] = (value == '1')
			attended_events = []
			for field in EVENT_FIELDS:
				choice = items[field['col']].strip()
				if choice != '1':
					continue
				for import_id in field['id']:
					eid = events[import_id]
					event = {'_id': eid, 'booked': True}
					if not eid in free_events:
						event['paid'] = True
					attended_events.append(event)
			attendee['attended_events'] = attended_events
			db.attendees.insert(attendee)

def init_users(db, root=None):
	db.users.drop()
	fields = {'firstname': 1, 'lastname': 0, 'password': 2}
	path = 'users_pwds'
	if root:
		path = os.path.join(root, path)

	with open(path, 'r') as file_users:
		for line in file_users:
			line = line.rstrip()
			line_split = line.split()
			user = {key : line_split[fields[key]] for key in fields}
			user['password_hash'] = crypt.crypt(user['password'], 'sha2')
			user['admin'] = (len(line_split) > 3 and line_split[3] == '*')
			del user['password']
			db.users.insert(user)

	db.attendees.update({},
		{'$set': {
			'registered': False
		}}, multi = True)
	db.attendees.update({},
		{'$unset': {
			'registered_on': None,
			'registered_by': None
		}}, multi = True)

def init_events(db):
	db.attendees.update({},
		{'$set':
			{'attended_events': []}
		},
		multi = True)
	db.events.drop()
	db.events.insert(EVENTS)

def init_vip(db, root):
	fields = filter(lambda f : f['id'] in ['firstname', 'lastname', 'middlename'], INFO_FIELDS)
	print fields
	path = 'vip.csv'
	if root:
		path = os.path.join(root, path)
	with open(path) as f:
		for line in f:
			condition = {}
			items = line.split('/')
			for field in fields:
				condition[field['id']] = items[field['col']]
			db.attendees.update(condition,
				{'$set': {'vip': True}},
				multi=True)

if __name__ == '__main__':
	conn = pymongo.MongoClient()
	db = conn.congress
	root = 'files'
	init_vip(db, root)
	conn.close()