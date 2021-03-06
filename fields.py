#!/usr/bin/env python
# -*- coding: utf-8 -*-

INFO_FIELDS = [
	{'caption': u'Прізвище', 'type': 'text', 'input_id': 'txtLastname', 'fieldId': 'lastname'},
    {'caption': u'Ім’я', 'type': 'text', 'input_id': 'txtFirstname', 'fieldId': 'firstname'},
    {'caption': u'По батькові', 'type': 'text', 'input_id': 'txtMiddlename', 'fieldId': 'middlename'},
    {'caption': u'Місто', 'type': 'text', 'input_id': 'txtCity', 'fieldId': 'city'},
    {'caption': u'Область', 'type': 'text', 'input_id': 'txtRegion', 'fieldId': 'region', 'list': True},
    {'caption': u'Організація', 'type': 'text', 'input_id': 'txtOrganization', 'fieldId': 'organization'},
    {'caption': u'Посада', 'type': 'text', 'input_id': 'txtPosition', 'fieldId': 'position'},
    {'caption': u'Звання', 'type': 'text', 'input_id': 'txtRank', 'fieldId': 'rank'},
    {'caption': u'Телефон', 'type': 'tel', 'input_id': 'txtPhone', 'fieldId': 'phone'},
    {'caption': u'Делегат', 'type': 'checkbox', 'input_id': 'cbDelegate', 'fieldId': 'delegate'}
]

ATTEND_FIELDS = [
	{'caption': u'Обід 19.09', 'id': 'dinner_19_09'},
	{'caption': u'Обід 20.09', 'id': 'dinner_20_09'},
	{'caption': u'Екскурсія 19.09, 11:00', 'id': 'excursion_19_09_1100'},
	{'caption': u'Екскурсія 19.09, 12:00', 'id': 'excursion_19_09_1200'},
	{'caption': u'Екскурсія 20.09, 11:00', 'id': 'excursion_20_09_1100'},
	{'caption': u'Екскурсія 20.09, 12:00', 'id': 'excursion_20_09_1200'},
	{'caption': u'Урочиста вечеря 19.09', 'id': 'ceremony_19_09'}
]