#!/usr/bin/env python
import lol.model as model
import netCDF4
def test_coast():
    coast = model.Coast()
    assert isinstance(coast.dataset, netCDF4.Dataset)
    
