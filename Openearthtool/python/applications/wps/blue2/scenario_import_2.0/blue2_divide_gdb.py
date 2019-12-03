# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2019 Deltares
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
# $Keywords: $

from sqlalchemy import *
import json
import sys, os

## MAIN ##
if __name__ == "__main__":

	# Check params
	if len(sys.argv) != 2:
		print("blue2_divide_gdb requires a configuration file in JSON format, ex: blue2_divide_gdb <conf.json>")
		sys.exit()

	# Read configuration into dictionary
	with open(sys.argv[1]) as handle:
		conf = json.loads(handle.read())

	# Output dir create if necessary
	if not os.path.exists(conf['outputDir']):
		os.mkdir(conf['outputDir'])

	# Creating SQLAlchemy's engine to use
	engine = create_engine('postgresql://{u}:{p}@{h}:5432/{d}'.format(
				u=conf['outputDB']['user'], d=conf['outputDB']['db'], p=conf['outputDB']['pass'], h=conf['outputDB']['host']
			)
	)

	# Create output schema if it does not exists
	create_sql = '''CREATE SCHEMA IF NOT EXISTS {}'''.format(conf['outputDB']['schema']+'_input')
	engine.execute(create_sql)

	# Input DB -> GDB import [bat to be executed]
	cmd = '''ogr2ogr -a_srs {crs} -f "PostgreSQL" PG:"host={h} port=5432 dbname={db} user={u} password={p}" {gdb} -lco SCHEMA={s} -overwrite -progress'''.format(
		h=conf["outputDB"]["host"], u=conf["outputDB"]["user"], p=conf["outputDB"]["pass"], db=conf["outputDB"]["db"], s=conf["outputDB"]["schema"]+'_input', gdb=conf["inputGDB"],
		crs='EPSG:{}'.format(conf['crs']))	
	#os.system(cmd)

	# Create mapping table 
	fields=['fecid integer', 'feccode varchar(12)']
	for s,sp in conf['shapefiles'].items():
		fields.append('{} varchar(255)'.format(s))
	create_sql = '''DROP TABLE IF EXISTS {s}.mapping; CREATE TABLE {s}.mapping({f})'''.format(s=conf['outputDB']['schema']+'_input', f=",".join(fields))
	#engine.execute(create_sql)

	# Insert objectids [copy columns from fec, create mapping columns from shapefiles]
	insert_sql = 'INSERT INTO {s}.mapping(fecid, feccode) SELECT fecid, feccode FROM {s}.fec'.format(s=conf['outputDB']['schema']+'_input')
	#engine.execute(insert_sql)

	# Input DB -> division files import
	for s,sp in conf['shapefiles'].items():		
		cmd = '''ogr2ogr -a_srs {crs} -nlt MULTIPOLYGON -select {f} -nln {t} -f "PostgreSQL" PG:"host={h} port=5432 dbname={db} user={u} password={p}" {shp} -lco SCHEMA={s} -overwrite -progress'''.format(
			h=conf["outputDB"]["host"], u=conf["outputDB"]["user"], p=conf["outputDB"]["pass"], db=conf["outputDB"]["db"], 
			s=conf["outputDB"]["schema"]+'_input', shp=sp['file'], t=s, f=sp['field'], crs='EPSG:{}'.format(conf['crs']))
		#os.system(cmd)
		
		# For every geometry from division [Mapping]		
		select_sql = '''SELECT {i} from {s}.{t}'''.format(t=s, s=conf["outputDB"]["schema"]+'_input', i=sp['field'])		
		res = engine.execute(select_sql)
		for r in res:
			#print('Updating {} ...'.format(r[0]))
			update_sql='''
				UPDATE {s}.mapping
				SET {f} = '{i}'
				WHERE fecid IN (SELECT fecid FROM green.fec f WHERE ST_Intersects(ST_GeomFromWKB(f.wkb_geometry), (select ST_GeomFromWKB(wkb_geometry) from green.{f} where {ff} = '{i}')))
			'''.format(f=s, s=conf["outputDB"]["schema"]+'_input', i=r[0], ff=sp['field'])			
			#engine.execute(update_sql)

	# TODO: For every scenario/variable
	create_sql = '''CREATE SCHEMA {}'''.format(conf['outputDB']['schema'])
	engine.execute(create_sql)	
	
	for sc,scp in conf['scenarios'].items():
		print ('Creating tables for scenario {}'.format(sc))
		# Every variable
		for v in scp['variables']:

			# Alter table, add column [variable]
			for s,sp in conf['shapefiles'].items():	

				# Create new table
				pgtable = '{}_{}_{}_{}'.format(s, 'green', scp['name'], v) 
				print (pgtable)
				create_sql = '''CREATE TABLE {os}.{nt} AS 
				(SELECT {s}.mapping.{div}, AVG({s}.{t}.{var}) as {var}
				FROM {s}.mapping, {s}.{t}
				WHERE {s}.mapping.fecid={s}.{t}.fecid and {div} IS NOT NULL
				GROUP BY {s}.mapping.{div})
				'''.format(s=conf["outputDB"]["schema"]+'_input', os=conf["outputDB"]["schema"], t=sc, div=s, var=v, nt=pgtable)				
				engine.execute(create_sql)
		print('-------------------')
