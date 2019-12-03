### Main Scripte for BLUE2 tool ###
import sys, os 
import pdb
import math
import time
from datetime import datetime
from decimal import *
from functions import *

# Append script directory to PATH variable
wd=os.path.dirname(os.path.realpath(__file__))
sys.path.append(wd)

### Import external packages ###
import numpy as np
import pandas as pd
import sqlalchemy as sql

### Import SQLAlchemy-modules ###
from sqlalchemy.engine.url import URL
from sqlalchemy import create_engine
from sqlalchemy import inspect
from sqlalchemy.orm import sessionmaker 
from sqlalchemy import MetaData
from sqlalchemy import Table

# Database address and login details:
import setup as db
    
def ws_savings_irrig(typescenario, costscenario, scale, region):
    # Connect to database
    postgres_db = {'drivername': 'Blue2',
               'database': 'blue2_scenario_generation',
               'username': 'postgres',
               'password': 'postgres',
               'host': 'localhost',
               'port': 5432}
               
    db.databaseConnect(postgres_db)
    db.engine.connect()
    
    # Specify table with data and columsn name for NUTS-ID
    table='ws_savings_irrigation_nuts2'
    nuts='is_n2_nuts2'
    
    # read the irrigation data table into a pandas dataframe
    data=readdata2Dataframe(table, '*')
    
    # Perform analysis only on certain regions:
    if region != 'EU28':
        data=regionextractor(region, scale, 'is_n2_member_state', 'is_n2_nuts2', data)
    
    # set index to Nuts-code
    data=data.set_index(nuts)
    data.index.name='nuts_code'
    
    # Table selection
    bau_cost=['is_n2_public_investment_bau_2016_2027','is_n2_private_investment_bau_2016_2027']
    mtfr_cost=['is_n2_public_investment_mtfr_2016_2027','is_n2_private_investment_mtfr_2016_2027']
    bau_operation=['is_n2_operations_bau_2016_2027']
    mtfr_operation=['is_n2_operations_mtfr_2016_2027']
    performance_current=['is_n2_current_efficiency_est_pct']
    performance_bau=['is_n2_performance_improvement_bau_pct']
    performance_mtfr=['is_n2_performance_improvement_mtfr_pct']
    irr_area_current=['is_n2_current_irrigated_surface_eurostat']
    irr_area_impr_mtfr=['is_n2_surface_improvement_mtfr_2016_2027_ha_est']
      
    # call function and calculate investment cost and performance on smallest available spatial scale for JRC
    [irr_cost_n2, irr_ope_cost_n2, irr_improvement_n2, irr_total_efficiency_n2, irr_improved_area_n2]=irrigation_water_savings_calculation(data, typescenario, costscenario, 'NUTS2', bau_cost, mtfr_cost, bau_operation, mtfr_operation, performance_current, performance_bau, performance_mtfr, irr_area_current, irr_area_impr_mtfr)
    
    # collect results in dataframe
    irr_results_nuts2=pd.concat([irr_cost_n2, irr_ope_cost_n2, irr_improvement_n2, irr_total_efficiency_n2, irr_improved_area_n2],axis=1)
    irr_results_nuts2.index.name='nuts_code'  
    if scale!='NUTS2':
        # produce results in other spatial scale for viewer
        [irr_cost, irr_ope_cost, irr_improvement, irr_total_efficiency, irr_improved_area]=irrigation_water_savings_calculation(data, typescenario, costscenario, scale, bau_cost, mtfr_cost, bau_operation, mtfr_operation, performance_current, performance_bau, performance_mtfr, irr_area_current, irr_area_impr_mtfr)
        # collect results in dataframe
        irr_results_viewer=pd.concat([irr_cost, irr_ope_cost, irr_improvement, irr_total_efficiency, irr_improved_area],axis=1)
        irr_results_viewer.index.name='nuts_code'  
        return(irr_results_nuts2, irr_results_viewer)
    else:
        # result already in NUTS2 level. No need for extra calculation.
        return(irr_results_nuts2, [])
    
def ws_savings_urban_ms(typescenario, costscenario, scale, region):
    # Connect to database
    postgres_db = {'drivername': 'Blue2',
               'database': 'blue2_scenario_generation',
               'username': 'postgres',
               'password': 'postgres',
               'host': 'localhost',
               'port': 5432}
    
    
    # {'drivername': 'Blue2',
               # 'database': 'blue2_scenario_generation',
               # 'username': 'postgres',
               # 'password': 'postgres',
               # 'host': 'localhost',
               # 'port': 5432}
    db.databaseConnect(postgres_db)
    db.engine.connect()
    
    # Specify table with data and columsn name for NUTS-ID
    table='ws_savings_urban_ms'
    nuts='us_ms_member_state_code'    
    
    # read data from database
    data=readdata2Dataframe(table, '*')
    
    # Perform analysis only on certain regions:
    if region != 'EU28':
        data=regionextractor(region, 'Member States', 'us_ms_member_state_code', None, data)

    # set index to Nuts-code
    data=data.set_index(nuts)
    data.index.name='nuts_code'

    # Specify name of columns 
    bau_c=['us_ms_public_investment_bau_2016_2027']
    mtfr_c=['us_ms_public_investment_mtfr_2016_2027']
    bau_operation=['us_ms_operations_bau_2016_2027']
    mtfr_operation=['us_ms_operations_mtfr_2016_2027']
    current_level=['us_ms_current_efficiency_est_pct']
    bau_level=['us_ms_performance_improvement_bau_pct']
    mtfr_level=['us_ms_performance_improvement_mtfr_2016_2027_pct']
    current_pop=['us_ms_current_population_eurostat']
    bau_pop=['us_ms_population_equivalent_improvement_bau_2016_2027_est']
    mtfr_pop=['us_ms_population_equivalent_improvement_mtfr_2016_2027_est']
    
    # call function and calculate investment cost and performance
    [ws_cost, ws_ope_cost, ws_improvement, ws_total_efficiency, ws_pop_eq]=urban_water_savings_calculation(data, typescenario, costscenario, scale, bau_c, mtfr_c, bau_operation, mtfr_operation, current_level, bau_level, mtfr_level, current_pop, bau_pop, mtfr_pop)
    
    # collect results in dataframe
    ws_urban_results=pd.concat([ws_cost, ws_ope_cost, ws_improvement, ws_total_efficiency, ws_pop_eq],axis=1)
    
    return(ws_urban_results)
	
def nutient_loads(typescenario, costscenario, scale, region): 
    # Connect to database
    postgres_db = {'drivername': 'Blue2',
               'database': 'blue2_scenario_generation',
               'username': 'postgres',
               'password': 'postgres',
               'host': 'localhost',
               'port': 5432}
    db.databaseConnect(postgres_db)
    db.engine.connect()
    
    # Specify table with data and columsn name for NUTS-ID
    table='nu_results_summary_nuts2'
    nuts='nu_nuts2_code'
    
    # read data from database
    data=readdata2Dataframe(table,'*')
    
    # Perform analysis only on certain regions:
    if region != 'EU28':
        data=regionextractor(region, scale, 'nu_country_code', 'nu_nuts2_code', data)
    
    # set index to Nuts-code
    data=data.set_index(nuts)
    data.index.name='nuts_code'
    
    # Specify name of columns 
    level_current_in=['nu_bod5_inlet_current', 'nu_n_inlet_current', 'nu_p_inlet_current']
    level_current_out=['nu_bod5_outlet_current', 'nu_n_outlet_current', 'nu_p_outlet_current']
    cost_bau_fc=['nu_uwwtd_investment_bau_fc']
    ope_bau_fc=['nu_operation_cost_bau_fc']
    level_bau_fc=['nu_bod5_outlet_bau_fc', 'nu_n_outlet_bau_fc', 'nu_p_outlet_bau_fc']
    cost_bau=['nu_uwwtd_investment_bau']
    ope_bau=['nu_operation_cost_bau']
    level_bau=['nu_bod5_outlet_bau', 'nu_n_outlet_bau', 'nu_p_outlet_bau']
    cost_mtfr=['nu_uwwtd_investment_mtfr']
    ope_mtfr=['nu_operation_cost_mtfr']
    level_mtfr=['nu_bod5_outlet_mtfr', 'nu_n_outlet_mtfr', 'nu_p_outlet_mtfr']
    
    # call function and calculate investment cost and performance on smallest available spatial scale for JRC
    [costDistr_n2, add_operation_cost_n2, nutrientLoads_n2, nu_treatment_efficiency_n2]=UWWTP_NutrientLoads_calculation(data, typescenario, costscenario, 'NUTS2', cost_bau, cost_bau_fc, cost_mtfr, ope_bau, ope_bau_fc, ope_mtfr, level_current_in, level_current_out, level_bau_fc, level_bau, level_mtfr)
    
    # collect results in dataframe
    nu_results_nuts2=pd.concat([costDistr_n2, add_operation_cost_n2, nutrientLoads_n2, nu_treatment_efficiency_n2], axis=1)
    
    if scale!='NUTS2':
        # produce results in other spatial scale for viewer
        [costDistr, add_operation_cost, nutrientLoads, nu_treatment_efficiency]=UWWTP_NutrientLoads_calculation(data, typescenario, costscenario, scale, cost_bau, cost_bau_fc, cost_mtfr, ope_bau, ope_bau_fc, ope_mtfr, level_current_in, level_current_out, level_bau_fc, level_bau, level_mtfr)
        # collect results in dataframe
        nu_results_viewer=pd.concat([costDistr, add_operation_cost, nutrientLoads, nu_treatment_efficiency], axis=1)
        return(nu_results_nuts2, nu_results_viewer)
    else:
        # result already in NUTS2 level. No need for extra calculation.
        return(nu_results_nuts2, [])

def cso_loadings(typescenario, costscenario, scale, region):
    # Connect to database
    postgres_db = {'drivername': 'Blue2',
               'database': 'blue2_scenario_generation',
               'username': 'postgres',
               'password': 'postgres',
               'host': 'localhost',
               'port': 5432}
    db.databaseConnect(postgres_db)
    db.engine.connect()
    
    # Specify table with data and columsn name for NUTS-ID
    table='ww_cso_results_n2'
    nuts=['ww_n2_nuts2_code']
    
    # read data from database
    data=readdata2Dataframe(table,'*')
    
    # Perform analysis only on certain regions:
    if region != 'EU28':
        data=regionextractor(region, scale, 'ww_n2_country_code', 'ww_n2_nuts2_code', data)
    
    # Set index to NUTS2 column:
    data=data.set_index(nuts)
    data.index.name='nuts_code'
    
    # Specify name of columns 
    level_bau=['ww_n2_bau_bod5_discharge_comb_wwcn_kg_day', 'ww_n2_bau_n_discharge_comb_wwcn_kg_day', 'ww_n2_bau_p_discharge_comb_wwcn_kg_day']
    cost_mtfr=['ww_n2_mtfr_inv_euro']
    operation_mtfr=['ww_n2_mtfr_ops_cost_euro']
    
    # call function and calculate investment cost and performance on smallest available spatial scale for JRC
    [costDistr_n2, add_operation_cost_n2, cso_loads_n2, cso_improvement_n2]=calculateCSOimprovement(data, level_bau, cost_mtfr, operation_mtfr, typescenario, costscenario, 'NUTS2')
    
    # collect results in dataframe
    cso_results_nuts2=pd.concat([costDistr_n2, add_operation_cost_n2, cso_loads_n2, cso_improvement_n2],axis=1)
    
    if scale!='NUTS2':
        # produce results in other spatial scale for viewer
        [costDistr, add_operation_cost, cso_loads, cso_improvement]=calculateCSOimprovement(data, level_bau, cost_mtfr, operation_mtfr, typescenario, costscenario, scale)
        # collect results in dataframe
        cso_results_viewer=pd.concat([costDistr, add_operation_cost, cso_loads, cso_improvement],axis=1)
        return(cso_results_nuts2, cso_results_viewer)
    else:
        # result already in NUTS2 level. No need for extra calculation.
        return(cso_results_nuts2, [])
    
def recordMetadata(ID, ws_irr, ws_irr_scenario, ws_irr_cost, ws_urban, ws_urban_scenario, ws_urban_cost, nu_loads, nu_scenario, nu_cost, cso_loads, cso_scenario, cso_cost, region, JRC_status):
    # Connect to database
    postgres_db = {'drivername': 'Blue2',
               'database': 'blue2_scenario_generation',
               'username': 'postgres',
               'password': 'postgres',
               'host': 'localhost',
               'port': 5432}
    db.databaseConnect(postgres_db)
    db.engine.connect()
    
    # record metadata 
    toschema='metadata'
    table='metadata'
    
    # set unused variables to Null:
    [ws_irr, ws_irr_scenario, ws_irr_cost]=ScenarioNullSetter(ws_irr, ws_irr_scenario, ws_irr_cost)
    [ws_urban, ws_urban_scenario, ws_urban_cost]=ScenarioNullSetter(ws_urban, ws_urban_scenario, ws_urban_cost)
    [nu_loads, nu_scenario, nu_cost]=ScenarioNullSetter(nu_loads, nu_scenario, nu_cost)
    [cso_loads, cso_scenario, cso_cost]=ScenarioNullSetter(cso_loads, cso_scenario, cso_cost)
    
    # data={'ID': [ID], 
    # 'ws_irr_module': [ws_irr], 
    # 'ws_urban_module': [ws_urban], 
    # 'nu_loads_module': [nu_loads], 
    # 'ws_irr_scenario': [ws_irr_scenario],
    # 'ws_urban_scenario': [ws_urban_scenario],
    # 'nu_loads_scenario': [nu_scenario],
    # 'ws_irr_cost': [ws_irr_cost],
    # 'ws_urban_cost': [ws_urban_cost],
    # 'nu_load_cost': [nu_cost],
    # 'region': [region],
    # 'JRC_status': [JRC_status]}
    
    datalist=[ID, ws_irr, ws_urban, nu_loads, cso_loads, ws_irr_scenario, ws_urban_scenario, nu_scenario, cso_scenario, ws_irr_cost, ws_urban_cost, nu_cost, cso_cost, region, JRC_status]
    headers=['ID', 'ws_irr_module', 'ws_urban_module', 'nu_loads_module', 'cso_loads_module', 'ws_irr_scenario', 'ws_urban_scenario', 'nu_loads_scenario', 'cso_loads_scenario', 'ws_irr_cost', 'ws_urban_cost', 'nu_load_cost', 'cso_load_cost', 'region', 'JRC_status']
    metadata=pd.DataFrame([datalist], columns=headers)
    metadata.to_sql(con=db.engine, name=table, schema=toschema, if_exists='append')
    
# eof