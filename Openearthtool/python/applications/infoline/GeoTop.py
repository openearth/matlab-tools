from __future__ import with_statement
from __future__ import division
from __future__ import absolute_import
from collections import OrderedDict
import netCDF4
import numpy
import logging
from io import open
from itertools import izip

__author__ = 'Edwin Bos, Maarten Pronk'

# @TODO(Maarten) Also return strat (formatie)

strat_translation_long = {
    'AAOP': 'Antropogeen',
    'NIGR': 'Nieuwkoop, Griendtsveen',
    'NINB': 'Nieuwkoop, Nij Beets',
    'NASC': 'Naaldwijk, Schoorl',
    'ONAWA': 'Naaldwijk, Walcheren',
    'NAZA': 'Naaldwijk, Zandvoort',
    'NAWA': 'Naaldwijk, Walcheren',
    'BHEC': 'Echteld (buiten Nieuwkoop, Hollandveen)',
    'OEC': 'Echteld (boven Nieuwkoop, Hollandveen)',
    'NAWOBE': 'Naaldwijk, Wormer, Laag van Bergen',
    'NIHO': 'Nieuwkoop, Hollandveen',
    'NAWO': 'Naaldwijk, Wormer',
    'NWNZ': 'Naaldwijk, Wormer en Zandvoort',
    'NAWOVE': 'Naaldwijk, Wormer, Laag van Velsen',
    'NIBA': 'Nieuwkoop, Basisveen',
    'NA': 'Naaldwijk',
    'EC': 'Echteld',
    'NI': 'Nieuwkoop',
    'KK': 'Kreekrak',
    'BXKO': 'Boxtel, Kootwijk',
    'BXSI': 'Boxtel, Singraven',
    'BXWI': 'Boxtel, Wierden',
    'BXWISIKO': 'Boxtel, Wierden, Singraven en Kootwijk',
    'BXDE': 'Boxtel, Delwijnen',
    'BXSC': 'Boxtel, Schimmert',
    'BXLM': 'Boxtel, Liempde',
    'BXBS': 'Boxtel, Best',
    'BX': 'Boxtel',
    'KRWY': 'Kreftenheye, Wijchen',
    'KRBXDE': 'Kreftenheye en Boxtel, Delwijnen',
    'KRZU': 'Kreftenheye, Zutphen',
    'KROE': 'Kreftenheye, onder Eem',
    'KRTW': 'Kreftenheye, Twello',
    'KR': 'Kreftenheye',
    'BEWY': 'Beegden, Wijchen',
    'BERO': 'Beegden, Rosmalen',
    'BE': 'Beegden',
    'KW': 'Koewacht',
    'WB': 'Woudenberg',
    'EE': 'Eem',
    'EEWB': 'Woudenberg en Eem',
    'DR': 'Drente',
    'DRGI': 'Drente, Gieten',
    'GE': 'Gestuwde afzettingen',
    'DN': 'Drachten',
    'URTY': 'Urk, Tijnje',
    'PE': 'Peelo',
    'UR': 'Urk',
    'ST': 'Sterksel',
    'AP': 'Appelscha',
    'SY': 'Stramproy',
    'PZ': 'Peize',
    'WA': 'Waalre',
    'PZWA': 'Peize en Waalre',
    'MS': 'Maassluis',
    'KI': 'Kiezelooliet ',
    'OO': 'Oosterhout',
    'IE': 'Inden',
    'VI': 'Ville',
    'BR': 'Breda',
    'RUBO': 'Rupel, Boom',
    'RU': 'Rupel',
    'TOZEWA': 'Tongeren, Zelzate, Laag van Watervliet',
    'TOGO': 'Tongeren, Goudsberg',
    'TO': 'Tongeren',
    'DOAS': 'Dongen, Asse',
    'DOIE': 'Dongen, Ieper',
    'DO': 'Dongen',
    'LA': 'Landen',
    'HT': 'Heijenrath',
    'HO': 'Holset',
    'MT': 'Maastricht',
    'GU': 'Gulpen',
    'VA': 'Vaals',
    'AK': 'Aken',
    'AEC': 'Echteld (geulafz. A)',
    'ANAWA': 'Naaldwijk, Walcheren (geulafz. A)',
    'ANAWO': 'Naaldwijk, Wormer (geulafz. A)',
    'BEC': 'Echteld (geulafz. B)',
    'BNAWA': 'Naaldwijk, Walcheren (geulafz. B)',
    'BNAWO': 'Naaldwijk, Wormer (geulafz. B)',
    'CEC': 'Echteld (geulafz. C)',
    'CNAWA': 'Naaldwijk, Walcheren (geulafz. C)',
    'CNAWO': 'Naaldwijk, Wormer (geulafz. C)',
    'DEC': 'Echteld (geulafz. D)',
    'DNAWA': 'Naaldwijk, Walcheren (geulafz. D)',
    'DNAWO': 'Naaldwijk, Wormer (geulafz. D)',
    'EEC': 'Echteld (geulafz. E)',
    'ENAWA': 'Naaldwijk, Laagpakket van Walcheren (geulafz. E)',
    'ENAWO': 'Naaldwijk, Laagpakket van Wormer (geulafz. E)',
    'NN': 'Onbekend'
    }

strat_translation = {
    1000: 'AAOP',
    1010: 'NIGR',
    1045: 'NINB',
    1020: 'NASC',
    1030: 'ONAWA',
    1040: 'NAZA',
    1050: 'NAWA',
    1060: 'BHEC',
    1070: 'OEC',
    1080: 'NAWOBE',
    1090: 'NIHO',
    1100: 'NAWO',
    1110: 'NWNZ',
    1120: 'NAWOVE',
    1130: 'NIBA',
    2000: 'NA',
    2010: 'EC',
    2020: 'NI',
    2030: 'KK',
    3000: 'BXKO',
    3010: 'BXSI',
    3020: 'BXWI',
    3030: 'BXWISIKO',
    3040: 'BXDE',
    3050: 'BXSC',
    3060: 'BXLM',
    3090: 'BXBS',
    3100: 'BX',
    4000: 'KRWY',
    4010: 'KRBXDE',
    4020: 'KRZU',
    4030: 'KROE',
    4040: 'KRTW',
    4050: 'KR',
    4060: 'BEWY',
    4070: 'BERO',
    4080: 'BE',
    4090: 'KW',
    4100: 'WB',
    4110: 'EE',
    4120: 'EEWB',
    5000: 'DR',
    5010: 'DRGI',
    5020: 'GE',
    5030: 'DN',
    5040: 'URTY',
    5050: 'PE',
    5060: 'UR',
    5070: 'ST',
    5080: 'AP',
    5090: 'SY',
    5100: 'PZ',
    5110: 'WA',
    5120: 'PZWA',
    5130: 'MS',
    5140: 'KI',
    5150: 'OO',
    5160: 'IE',
    5170: 'VI',
    5180: 'BR',
    5190: 'RUBO',
    5200: 'RU',
    5210: 'TOZEWA',
    5220: 'TOGO',
    5230: 'TO',
    5240: 'DOAS',
    5250: 'DOIE',
    5260: 'DO',
    5270: 'LA',
    5280: 'HT',
    5290: 'HO',
    5300: 'MT',
    5310: 'GU',
    5320: 'VA',
    5330: 'AK',
    6000: 'AEC',
    6010: 'ANAWA',
    6020: 'ANAWO',
    6100: 'BEC',
    6110: 'BNAWA',
    6120: 'BNAWO',
    6200: 'CEC',
    6210: 'CNAWA',
    6220: 'CNAWO',
    6300: 'DEC',
    6310: 'DNAWA',
    6320: 'DNAWO',
    6400: 'EEC',
    6410: 'ENAWA',
    6420: 'ENAWO',
    0: 'NN',
    -32767: 'NN'
}

lithok_translation = {
    0: 'antropogeen',
    1: 'organisch materiaal (veen)',
    2: 'klei',
    3: 'klei zandig, leem, kleiig fijn zand',
    5: 'zand fijn',
    6: 'zand matig grof',
    7: 'zand grof',
    8: 'grind',
    9: 'schelpen',
    -127: 'NN'
}


class NetcdfIndexVariable(object):
    """Convenience wrapper around the netCDF4._netCDF4.Variable class."""

    def __init__(self, variable):
        self.variable = variable
        self.stride = self.variable[1] - self.variable[0]
        self.offset = self.variable[0] + self.stride/2.
        self.type = self.variable.datatype.type

    def values(self):
        return self.variable[:]

    def nearest_index(self, value):
        idx = (numpy.abs(self.variable[:] - value)).argmin()
        return idx

class NetcdfValueVariable(object):
    """Convenience wrapper around the netCDF4._netCDF4.Variable class."""

    def __init__(self, variable):
        self.variable = variable
        self.type = self.variable.datatype.type

    def values(self, x, y):
        return self.variable[x, y, :]


class NetcdfOnOpendap(object):
    """Access a NetCDF file, exposed by an OPeNDAP server."""

    def __init__(self, url, index_variable_names, value_variable_names):
        """
        index_variables -- NetCDF variable names which index the value_variables' dimensions.
        value_variables -- NetCDF variable names of the quantities of interest.
        """
        self.dataset = netCDF4.Dataset(url)
        self.index_variables = OrderedDict((name, NetcdfIndexVariable(self.dataset.variables[name])) for name in index_variable_names)
        self.value_variables = OrderedDict((name, NetcdfValueVariable(self.dataset.variables[name])) for name in value_variable_names)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.dataset.close()


class GeoTopOnOpendap(NetcdfOnOpendap):
    """Access the GeoTop NetCDF file, exposed by an OPeNDAP server."""

    def __init__(self, url, path=None):
        NetcdfOnOpendap.__init__(self, url, index_variable_names=('x', 'y', 'z'), value_variable_names=('lithok', 'strat'))
        self.output_file = None
        if path is not None:
            self.output_file = open(path, 'w')

    def __exit__(self, exc_type, exc_val, exc_tb):
        NetcdfOnOpendap.__exit__(self, exc_type, exc_val, exc_tb)
        if self.output_file is not None:
            self.output_file.close()

    def __layers(self, x_index, y_index, max_depth):
        """
        x_index -- X-dimension index representing the user's x-coordinate.
        y_index -- Y-dimension index representing the user's y-coordinate.
        max_depth -- Report layers up to this depth.
        """
        results = []
        if x_index < 0 or y_index < 0:
            return results
        strat_values = self.value_variables['strat'].values(x_index, y_index)
        lithok_values = self.value_variables['lithok'].values(x_index, y_index)
        height_stride = self.index_variables['z'].stride
        layer_top_heights = [value+height_stride for value in self.index_variables['z'].values()]
        strat_type = self.value_variables['strat'].type
        lithok_type = self.value_variables['lithok'].type
        prev_strat = None
        prev_lithok = None
        surface_layer_height = None
        for strat, lithok, height in izip(reversed(strat_values), reversed(lithok_values), reversed(layer_top_heights)):
            # hardcoded nodata values because online netcdf doesn't have correct FillValue
            if type(strat) == strat_type and type(lithok) == lithok_type and strat != -32767 and lithok != -127: 
                if strat != prev_strat or lithok != prev_lithok:
                    if surface_layer_height is None:
                        surface_layer_height = height
                    prev_strat = strat
                    prev_lithok = lithok
                    depth = surface_layer_height-height
                    if depth < max_depth:
                        if len(results) > 0: results[-1][-1] = depth
                        results.append([strat_translation_long[strat_translation[strat]], lithok_translation[lithok], depth, max_depth])
        if self.output_file is not None:
            for result in results:
                self.output_file.write('%s; %s; %s\n' % result)
        return results

    def get_all_layers(self, x, y):
        """
        Retrieve the stratification, lithoclass and depth below the surface layer
        for all layers at the location nearest (x,y).
        """
        # Input validation
        x_index = self.index_variables['x'].nearest_index(x)
        y_index = self.index_variables['y'].nearest_index(y)
        max_depth = self.index_variables['z'].type(50)#numpy.inf)
        return self.__layers(x_index, y_index, max_depth)

    def get_layers(self, x, y, z):
        """
        Retrieve the stratification, lithoclass and depth below the surface layer
        for layers above depth (z) at the location nearest (x,y).
        """
        x_index = self.index_variables['x'].nearest_index(x)
        y_index = self.index_variables['y'].nearest_index(y)
        return self.__layers(x_index, y_index, z)

if __name__ == "__main__":
        url, x, y, z = "http://opendap.dinoservices.nl/GeoTOP/geotop.nc", 85924, 444374, 47.5
        lstvals = GeoTopOnOpendap(url).get_all_layers(x, y)
        print lstvals
        # with GeoTopOnOpendap(url, path=None) as data:
            # for line in data.get_layers(x, y, z):
                # print 'Geologische eenheid: %s, lithoklasse: %s, diepte: %s m' % line