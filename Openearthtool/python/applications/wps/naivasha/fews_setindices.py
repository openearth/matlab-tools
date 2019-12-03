# -*- coding: utf-8 -*-
"""
Created on Thu Jul 07 07:51:47 2016

@author: fews
"""

import sqlfunctions
cf = r'C:\pywps\pywps_processes\pgconnection.txt'

credentials = sqlfunctions.get_credentials(cf)

#indices on location table
strSql = """
CREATE INDEX idx_location_geom
  ON fews.locations
  USING gist
  (wgs_geom);"""
sqlfunctions.perform_sql(strSql,credentials)  

strSql = """CREATE INDEX idx_location_id
  ON fews.locations
  USING btree
  (id COLLATE pg_catalog."default");"""
sqlfunctions.perform_sql(strSql,credentials)  

strSql = """CREATE INDEX idx_location_key
  ON fews.locations
  USING btree
  (locationkey);"""
sqlfunctions.perform_sql(strSql,credentials)  

# indices on timeserieskey
strSql = """CREATE INDEX idx_ts_key
  ON fews.timeserieskeys
  USING btree
  (serieskey);"""
sqlfunctions.perform_sql(strSql,credentials)  
  
strSql = """CREATE INDEX idx_ts_lkey
  ON fews.timeserieskeys
  USING btree
  (locationkey);"""
sqlfunctions.perform_sql(strSql,credentials)  

strSql = """CREATE INDEX idx_ts_parameterkey
  ON fews.timeserieskeys
  USING btree
  (parameterkey);"""
sqlfunctions.perform_sql(strSql,credentials)  

# indices on timeserieskeysvaluesandflags
strSql = """CREATE INDEX idx_ts_date
  ON fews.timeseriesvaluesandflags
  USING btree
  (datetime);"""
sqlfunctions.perform_sql(strSql,credentials)  

strSql = """CREATE INDEX idx_ts_serieskey
  ON fews.timeseriesvaluesandflags
  USING btree
  (serieskey);"""
sqlfunctions.perform_sql(strSql,credentials)    