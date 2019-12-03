from odv2orm_model import *

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Gerben J. de Boer
#
#       gerben.deboer@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: odv2orm_testdict.py 10985 2014-07-23 12:45:50Z boer_g $
# $Date: 2014-07-23 05:45:50 -0700 (Wed, 23 Jul 2014) $
# $Author: boer_g $
# $Revision: 10985 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_testdict.py $
# $Keywords: $

D = {}

## controlled vocabularies

D["Edmo"] = []
D["Edmo"].append(Edmo(code = 1528      , name='Ifremer', geom='srid=4326;POINT(4 52)'))
D["Edmo"].append(Edmo(code = 630       , name='NIOZ'   , geom='srid=4326;POINT(3 54)'))

D["P01"] = []
D["P01"].append(P01 (identifier = 'TEMPPR01', prefLabel='Temperature of the water body',        altLabel='Temp',  definition = 'The degree of hotness of the water column expressed against a standard scale.  Includes both IPTS-68 and ITS-90 scales.'))
D["P01"].append(P01 (identifier = 'PSLTZZ01', prefLabel='Practical salinity of the water body', altLabel='P_sal', definition = 'The quantity of dissolved ions (predominantly salt in seawater) expressed on a scale (PSS-78) based on the conductivity ratio of a seawater sample to a standard KCl solution.'))

D["P06"] = []
D["P06"].append(P06 (identifier = 'UPAA',     prefLabel='Degrees Celsius',                      altLabel='degC'   , definition = 'Unavailable'))
D["P06"].append(P06 (identifier = 'UUUU',     prefLabel='Dimensionless',                        altLabel='Dmnless', definition = 'Unavailable'))

## data

D["Cdi"] = []
D["Cdi"].append(Cdi(cdi='5523',local_cdi_id="CTDCAST_78___210",edmo_code='630'))
D["Cdi"].append(Cdi(cdi='5524',local_cdi_id="CTDCAST_78___213",edmo_code='630'))
D["Cdi"].append(Cdi(cdi='5525',local_cdi_id="CTDCAST_78___216",edmo_code='630'))

D["Odvfile"] = []
D["Odvfile"].append(Odvfile(name="CTDCAST_78___210",cdi='5523',filename="CTDCAST_78___210_20081124"))
D["Odvfile"].append(Odvfile(name="CTDCAST_78___213",cdi='5524',filename="CTDCAST_78___213_20081124"))
D["Odvfile"].append(Odvfile(name="CTDCAST_78___216",cdi='5525',filename="CTDCAST_78___216_20081124"))

D["Observation"] = []
D["Observation"].append(Observation(value = 25.4531, p01_id = "TEMPPR01", p06_id = "UPAA", cdi_id = 5523, odvfile_id = 1, flag_id = 1))
D["Observation"].append(Observation(value = 25.4529, p01_id = "TEMPPR01", p06_id = "UPAA", cdi_id = 5523, odvfile_id = 1, flag_id = 1))
D["Observation"].append(Observation(value = 25.4526, p01_id = "TEMPPR01", p06_id = "UPAA", cdi_id = 5523, odvfile_id = 1, flag_id = 1))
