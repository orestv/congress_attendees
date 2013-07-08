# -*- coding: utf-8 -*-
import sqlite3 as sql
import random
import pymongo
from pymongo import MongoClient
import re
from string import digits


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
	{'caption': u'Обід 19.09'},
	{'caption': u'Обід 20.09'},
	{'caption': u'Екскурсія 19.09, 11:00', 'limit': 40},
	{'caption': u'Екскурсія 19.09, 12:00', 'limit': 40},
	{'caption': u'Екскурсія 20.09, 11:00', 'limit': 40},
	{'caption': u'Екскурсія 20.09, 12:00', 'limit': 40},
	{'caption': u'Урочиста вечеря 19.09'}
]

if __name__ == '__main__':
	# conn = pymongo.Connection('mongodb://application:master@ds027688.mongolab.com:027688/congress_new')
	conn = pymongo.MongoClient()
	db = conn.congress
	attendees = db.attendees
	firstnames = read_names('firstnames')
	lastnames = read_names('lastnames')
	cities = read_names('cities')
	fields = ['хірург', 'анестезіолог', 'педіатр', 'патологоанатом', 'пульмонолог']
	attendees.drop()

	local_attendees = []
	for i in xrange(100000):
		firstname = random.choice(firstnames)
		lastname = random.choice(lastnames)
		city = random.choice(cities)
		middlename = generate_middlename(random.choice(firstnames))
		phone = generate_phone()
		field = random.choice(fields)
		attendee = {'firstname': firstname,
			'middlename': middlename,
			'lastname': lastname,
			'city': city,
			'phone': phone,
			'field': field,
			'attended_events': []}
		local_attendees.append(attendee)
	attendees.insert(local_attendees)

	db.events.drop()
	db.events.insert(EVENTS)
	conn.close()
	# try:
	# 	con = db_connect()
	# 	cur = con.cursor()
	# 	print 'Connected'

		# for i in range(100000):
		# 	firstname = random.choice(firstnames)
		# 	lastname = random.choice(lastnames)
		# 	middlename = generate_middlename(random.choice(firstnames))
		# 	create_attendee(cur, firstname, middlename, lastname)

	# 	con.commit()
	# 	print 'Inserted!'
	# except sql.Error, e:
	# 	print 'Connection failed: %s' % e.args[0]
	# finally:
	# 	con.close()
	# 	print 'Disconnected!'