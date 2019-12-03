# -*- coding: utf-8 -*-
"""Test suit for grid Classes
"""

import unittest
import numpy as np
from grid import Grid

class TestGrid(unittest.TestCase):
    def setUp(self):
        self.shape =(10, 10)
        self.props = {'Coordinate System': 'Cartesian', 'xori': '0', 'yori': '0', 'alfori': '0'}
        self.x = np.ones(self.shape)
        self.y = np.ones(self.shape)*2

    def test_write(self):
        grid = Grid(shape=self.shape, x=self.x,
                    y=self.y , properties=self.props)
        grid.write('filename.grd')

    def test_fromfile(self):
        grid = Grid.fromfile('filename.grd')
        np.testing.assert_array_equal(grid.x, self.x)
        np.testing.assert_array_equal(grid.y, self.y)
        print (grid.x == self.x).all()
        print (grid.y == self.y).all()

if __name__ == '__main__':
    unittest.main()