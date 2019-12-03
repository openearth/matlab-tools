# -*- coding: utf-8 -*-
"""
Created on 2014-12-23 09:22

@author: heijer

$Id: oetnewscript.py 11595 2014-12-23 09:24:58Z heijer $
$Date: 2014-12-23 01:24:58 -0800 (Tue, 23 Dec 2014) $
$Author: heijer $
$Revision: 11595 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/misc/oetnewscript.py $
"""

__author__ = 'heijer'


import argparse
from mako.template import Template
import os
import datetime


class OEscript:

    template = Template('''${coding}
"""
Created on ${date}

@author: ${username}

% for key in ('Id', 'Date', 'Author', 'Revision', 'HeadURL'):
$${key}: $
% endfor
"""

__author__ = "${username}"
__license__ = "${license}"

import argparse


def main():
    parser = argparse.ArgumentParser(description='Put here your custom description')
    args = parser.parse_args()


if __name__ == '__main__':
    main()
''')
    arguments = dict(date=datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M'),
                     coding='# -*- coding: utf-8 -*-',
                     license='LGPL')
    fname = None
    username = getattr(os, "getlogin()", None)

    def __init__(self, fname):
        self.set_filename(fname)
        self.get_username()
        self.arguments['username'] = self.username

    def set_filename(self, fname):
        self.fname = fname

    def get_username(self):

        if not self.username:
            for var in ['USER', 'USERNAME','LOGNAME']:
                if  var in os.environ:
                    self.username = os.environ[var]

    def write(self):
        txt = self.template.render(**self.arguments)
        with open(self.fname, 'w') as fobj:
            fobj.write(txt)

def main():
    parser = argparse.ArgumentParser(description='Create OpenEarthTools template script')
    parser.add_argument('scriptname',
                        type=str,
                        help='name of the python script to create')
    args = parser.parse_args()

    script = OEscript(fname=args.scriptname)
    script.write()


if __name__ == '__main__':
    main()
