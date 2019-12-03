# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Joan Sala
#
#       joan.salacalero@deltares.nl
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

# $Id: coords.py 13711 2017-09-13 14:52:48Z sala $
# $Date: 2017-09-13 16:52:48 +0200 (Wed, 13 Sep 2017) $
# $Author: sala $
# $Revision: 13711 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/blue2/utils_thresholds.py $
# $Keywords: $

import logging
from sqlalchemy import create_engine
import numpy as np
import pandas as pd

# Calculate a layer, save it to PostGIS
def getThresholds(cf, variable, division, division_id, def_thr):
    # DB connections
    engine = create_engine('postgresql+psycopg2://'+cf.get('PostGIS', 'user')
        +':'+cf.get('PostGIS', 'pass')+'@'+cf.get('PostGIS', 'host')+':'+str(cf.get('PostGIS', 'port'))
        +'/'+cf.get('PostGIS', 'db_thresholds'), strategy='threadlocal')

    # Perform sql query
    #column = getColumn(variable) --- TODO
    column = def_thr
    sqlStr = 'select {},{} from {}."{}"'.format(division_id, column, 'public', division)            
    logging.info(sqlStr)
    res = engine.execute(sqlStr)
    header = res.keys()        

    # Extract values        
    df = pd.DataFrame(columns=['threshold'])
    for r in res:    
        # Identifier         
        iden = r[0]
        val = r[1]                  
        df.loc[iden] = pd.Series({'threshold': val})
    
    return df
