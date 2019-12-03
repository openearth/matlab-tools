"""
Models for sea level package
"""

import pyramid.renderers
import pandas.rpy.common
from rpy2.robjects import r



def annual_means(station="DEN HELDER"):
    data = pandas.rpy.common.load_data('dutch', 'sealevel')
    stationdf = filter(lambda x:x['name'] ==station, data.values())[0]['data']
    return stationdf




def fill_r_template(name, **values):
    """fill in the R template"""
    code = pyramid.renderers.render(name, values)
    return code

def run_r_model(code):
    """apply the model in the code and return the df and fit object"""
    objects = r(code)
    return objects
