# -*- coding: utf-8 -*-
"""
# $Id: sql_functions.py 43 2012-11-08 19:57:30Z heijer $
# $Date: 2012-11-08 20:57:30 +0100 (Thu, 08 Nov 2012) $
# $Author: heijer $
# $Revision: 43 $
# $HeadURL: https://subversion.assembla.com/svn/shef/python/store/sql_functions.py $
"""

import logging
FORMAT = '%(module)s\n  line %(lineno)s %(levelname)s %(message)s'
logging.basicConfig(format=FORMAT)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

import unittest
import time

class UnitTests(unittest.TestCase):
    def setUp(self):
        import waterbase
        self.Waterbase = waterbase.Waterbase(language='en')
        logger.info('host: %s', self.Waterbase.host)
        logger.info('language: %s', self.Waterbase.language)
    def test_themes(self):
        themes = zip(*self.Waterbase.themes)
        s = '\n'
        for theme,code in themes:
            s += '%s (%s)\n' %(theme,code)
        logger.info(s)
    def test_observations(self):
        observations = zip(*self.Waterbase.observations)
        s = '\n'
        for observation,code in observations:
            s += '%4i: %s\n' %(code,observation)
        logger.info(s)
    def test_locations(self):
        locations= zip(*self.Waterbase.get_locations(1))
        s = '\n'
        for abbrev,location in locations:
            s += '%s (%s)\n' %(location,abbrev)
        logger.info(s)
    def test_periods(self):
        period = self.Waterbase.get_periods(54, 'K13APFM')
        logger.info('from %s to %s', time.strftime('%Y-%m-%d %H:%M', period[0]), time.strftime('%Y-%m-%d %H:%M', period[1]))


if __name__ == '__main__':
    unittest.main()
