# -*- coding: utf-8 -*-
import json


def read_json_array(filename):
    with open(filename, 'r') as f:
        json_data = f.read()
        return json.loads(json_data)
    return {}


def find_record(identifier, filename):
    # Read JSON array data
    data = read_json_array(filename)

    # Search item [first match]
    rec = {}
    for item in data:
        if item['ID'] == identifier:
            rec = item

    return rec
