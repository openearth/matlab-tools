import sys
import logging
import unittest

import requests
import pandas
import lxml.etree
from lxml.etree import ElementTree

from rainbow_logging_handler import RainbowLoggingHandler

# Setup logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("[%(asctime)s] \t%(message)s")  # same as default

# setup `RainbowLoggingHandler`
handler = RainbowLoggingHandler(sys.stderr, color_funcName=('black', 'yellow', True))
handler.setFormatter(formatter)
logger.addHandler(handler)

class TestCase(unittest.TestCase):
    def test_urls(self):
        df = pandas.read_csv('urls.txt', names=['url'], sep="\t")
        for i, row in df.iterrows():
            url = row.ix['url']
            r = requests.get(url)
            self.assertEqual(r.status_code, 200, msg=url)
            if 'xml' in r.headers['content-type']:
                tree = lxml.etree.fromstring(r.content)
                msg = "%s wps:ProcessFailed" % (url, )
                element = '{http://www.opengis.net/wps/1.0.0}ProcessFailed'
                fails = list(tree.iter(element))
                self.assertFalse(any(fails), msg=msg)

if __name__ == '__main__':
    unittest.main()

