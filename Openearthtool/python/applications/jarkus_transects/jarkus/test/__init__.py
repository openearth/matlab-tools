"""
$Id: __init__.py 9847 2013-12-06 20:03:12Z heijer $
$Date: 2013-12-06 21:03:12 +0100 (Fri, 06 Dec 2013) $
$Author: heijer $
$Revision: 9847 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/jarkus_transects/jarkus/test/__init__.py $
"""

import unittest
import numpy as np

class UnitTests(unittest.TestCase):
    def setUp(self):
        from jarkus.transects import Transects
        self.tr = Transects()
    def test_initurl(self):
        from jarkus.transects import Transects
        url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'
        self.assertEqual(Transects(url=url).url, url)
    def test_set_filter_bool(self):
        shape = self.tr.ds.variables['id'].shape
        B = np.ones(shape) == 0 # all false
        idx = -1
        B[-1] = True
        self.tr.set_filter(alongshore=B)
        self.assertEqual(self.tr.get_data('id'), self.tr.ds.variables['id'][idx])
    def test_set_filter_id(self):
        id = 7e6
        self.tr.set_filter(id=id)
        self.assertEqual(self.tr.get_data('id'), id)
    def test_set_filter_idx(self):
        idx = -10
        self.tr.set_filter(alongshore=idx)
        self.assertEqual(self.tr.get_data('id'), self.tr.ds.variables['id'][idx])
    def test_set_filter_year(self):
        self.tr.set_filter(year=2006)
    def test_get_jrk(self):
        idx = 100
        self.tr.reset_filter()
        self.tr.set_filter(time=-1)
        ids = self.tr.get_data('id')
        idx = np.nonzero(ids==8006000)[0]
        self.tr.set_filter(alongshore=idx[0])
        self.tr.get_jrk()

if __name__ == '__main__':
    unittest.main()
