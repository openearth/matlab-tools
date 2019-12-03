import os
import re
import json

import codecs

import sys

reload(sys)
sys.setdefaultencoding('utf8')

class CDL:
    markers_file = "markers.json"
    markers = None
    dimdict = {}
    fname = ""
    txt = ""

    def __init__(self, fname):
        self.fname = fname

    def read(self):
        with codecs.open(self.fname) as fobj:
            self.txt = fobj.read()

    def write(self):
        with codecs.open(self.fname, 'w') as fobj:
            fobj.write(self.txt)

    def _json_read(self):
        with open(self.markers_file) as fobj:
            self.markers = json.load(fobj)
        for item in self.markers:
            if item['category'] in ('dim',):
                self.dimdict[item['key']] = "${{dim.%s}}" % item['key']

    def global_markers(self):
        for item in self.markers:
            if item['category'] in ('user', 'sys'):
                self.place_global_marker(item)

    def place_global_marker(self, markerdict):
        key = markerdict["key"]
        cat = markerdict["category"]
        pattern = '^\s+:%s.*?//[.]+' % key
        # print(pattern)
        match = re.search(pattern, self.txt, re.MULTILINE)
        if match:
            old_str = match.group()
            new_str = re.sub('""', '"${{%s.%s}}"' %(cat, key), old_str)
            txt = re.sub(pattern, new_str, self.txt, re.MULTILINE)
            self.txt = self.txt.replace(old_str, new_str)
        else:
            print('No match',key)

    def variable_markers(self):
        for item in self.markers:
            if item['category'] in ('var',) and item['key'] != 'name':
                self.place_variable_attribute_marker(item)

    def place_variable_marker(self):
        self.txt = self.txt.replace('geophysical_variable_1', '${{var.name}}')
        self.variable_markers()

    def place_variable_attribute_marker(self, markerdict):
        key = markerdict["key"]
        cat = markerdict["category"]
        pattern = '^\s+\${{var.name}}:%s.*?//[.]+' % key
        match = re.search(pattern, self.txt, re.MULTILINE)
        if match:
            old_str = match.group()
            new_str = re.sub('""', '"${{%s.%s}}"' % (cat, key), old_str)
            txt = re.sub(pattern, new_str, self.txt, re.MULTILINE)
            self.txt = self.txt.replace(old_str, new_str)
        else:
            print('No match', key)

    def place_dim_markers(self):
        r = re.compile('(?P<dimname>[a-z0-9]+)\s+=\s+(?P<dimvalue><.*?>)', re.IGNORECASE)
        matches = [m.groupdict() for m in r.finditer(self.txt)]
        # print(matches)
        for match in matches:
            if match["dimname"].lower() in self.dimdict:
                # print(match["dimname"], self.dimdict[match["dimname"].lower()])
                self.txt = self.txt.replace(match["dimvalue"], self.dimdict[match["dimname"].lower()])
            else:
                print('dimension %s not found' % match["dimname"].lower())
        # with open(f) as fobj:
        #     for i in range(10):
        #         line = fobj.readline()
        #         if "variables" in line:
        #             break
        #         elif "dim" in line:
        #             print(line)
        #         else:
        #             pass


if __name__ == '__main__':
    cdl_files = [f for f in os.listdir(os.path.dirname(os.path.abspath(__file__))) if f.endswith('.cdl')]
    for f in cdl_files:
        print(f)
        cdl = CDL(f)
        cdl._json_read()
        cdl.read()

        cdl.global_markers()
        cdl.place_variable_marker()
        cdl.place_dim_markers()

        cdl.write()