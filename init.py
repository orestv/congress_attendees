#!/usr/bin/env python
# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*-
import sqlite3 as sql
import random
import pymongo
from pymongo import MongoClient
import re
from string import digits
import crypt

INFO_FIELDS = [
	{'col': 0, 'id': 'lastname'},
	{'col': 1, 'id': 'firstname'},
	{'col': 2, 'id': 'middlename'},
	{'col': 3, 'id': 'city'},
	{'col': 4, 'id': 'region'},
	{'col': 5, 'id': 'organization'},
	{'col': 6, 'id': 'position'},
	{'col': 7, 'id': 'rank'},
	{'col': 8, 'id': 'email'},
	{'col': 9, 'id': 'phone'},
	{'col': 11, 'id': 'delegate', 'bool': True}
]
EVENT_FIELDS = [
	{'col': 12, 'id': 'registration'},
	{'col': 13, 'id': 'materials'},
	{'col': 14, 'id': 'ceremonial_dinner'},
	{'col': 15, 'id': 'dinner_19'},
	{'col': 16, 'id': 'dinner_20'},
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
	{'caption': u'Обов’язковий реєстраційний платіж',
		'import_id': 'registration', 'price': 200,
		'default': True,
		'item_caption': u'сертифікат і бейджик'},
	{'caption': u'Пакет матеріалів',
		'import_id': 'materials', 'price': 100,
		'limit': 900, 'default': True,
		'item_caption': u'пакет матеріалів'},
	{'caption': u'Обід 18.09 в 14 год.',
		'import_id': 'dinner_18',
		'limit': 300, 'default': True,
		'item_caption': u'квиток на обід 18.09'},
	{'caption': u'Обід 19.09 в 13 год.',
		'import_id': 'dinner_19',
		'price': 50, 'limit': 600, 'default': True,
		'item_caption': u'квиток на обід 19.09'},
	{'caption': u'Обід 20.09 в 13 год.',
		'import_id': 'dinner_20',
		'price': 50, 'limit': 600, 'default': True,
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
		'import_id': 'opening', 'limit': 500,
		'item_caption': u'квиток на церемонію відкриття'},
	{'caption': u'Урочиста вечеря 19.09 в 19 год.',
		'import_id': 'ceremonial_dinner',
		'price': 300, 'limit': 500,
		'item_caption': u'квиток на урочисту вечерю'}
]


def init_attendees(db):
	db.attendees.drop()
	events = {}
	for field in EVENT_FIELDS:
		event = db.events.find_one({'import_id': field['id']})
		events[field['id']] = str(event['_id'])
	with open('attendees.csv', 'r') as f:
		for line in f:
			if line.startswith('Прізвище'):
				continue
			items = line.split(',')
			attendee = {field['id']: items[field['col']].decode('utf-8') for field in INFO_FIELDS}
			for field in INFO_FIELDS:
				if field.get('bool', False):
					value = items[field['col']]
					attendee[field['id']] = (value == 'Так')
			# print attendee
			# return
			attended_events = []
			for field in EVENT_FIELDS:
				choice = items[field['col']].strip()
				if choice != 'Так':
					continue
				eid = events[field['id']]
				event = {'_id': eid, 'booked': True, 'paid': True}
				attended_events.append(event)
			attendee['attended_events'] = attended_events
			db.attendees.insert(attendee)

def init_users(db):
	db.users.drop()
	fields = {'firstname': 1, 'lastname': 0, 'password': 2}

	file_users = open('users_pwds', 'r')

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

	file_users.close()

def init_events(db):
	db.attendees.update({},
		{'$set':
			{'attended_events': []}
		},
		multi = True)
	db.events.drop()
	db.events.insert(EVENTS)

if __name__ == '__main__':
	conn = pymongo.MongoClient()
	db = conn.congress
	init_events(db)
	init_attendees(db)
	conn.close()