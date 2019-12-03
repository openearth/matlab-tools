import sys
import logging
import setup as db
import pandas as pd
import pdb
import math

def cleanSchema(schema):
    # Removes all tables of a schema
    try:
        # load table names from the schema
        tables=db.engine.execute('''SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='{}' '''.format(schema))
    except:
        logging.error('''Error reading tables in schema - possibly no tables exist in schema "{s}"'''.format(s=schema))
        return
    # Create sql query and delete each table one at a time
    for table in tables:
        db.engine.execute('''DROP TABLE {}."{}" '''.format(schema, table[0]))
        #print('dropped table %s from schema %s' %(table[0], schema))
        logging.info('''dropped table {t} from schema {s}'''.format(t=table[0], s=schema))
    print('All tables dropped in schema "%s"' %schema)
    logging.info('''All tables dropped in schema "{s}"'''.format(s=schema))
    
def readdata2Dataframe(table,columns):
    # read data to pandas dataframe 
    if len(columns)>1 and isinstance(columns,list):
        expr=', '.join(columns)
    elif isinstance(columns,list):
        expr=columns[0]
    else:
        expr=columns
    # read columns into 'data' via sql-query
    data=pd.read_sql_query('SELECT '+expr+' FROM '+table,db.engine)

    # if first column is a string-type, pandas will add u'\ufeff' to the first object, 
    # thus we must remove it to preserve the index value
    if isinstance(data.iat[0,0],unicode):
        data.iat[0,0]=data.iat[0,0].replace(u'\ufeff','')
    return(data)

def regionextractor(region, scale, data_nuts0_column, data_nuts2_column, data):
    # Perform analysis only on certain NUTS2 regions:
    regiontable='regions'
    regionID='region_name'
    regiondata=readdata2Dataframe(regiontable,'*')
    regiondata=regiondata.set_index(regionID)
    
    if scale=='Member States' or scale=='NUTS0':
        regionlist=regiondata['nuts_0'][region].split(', ')
        data=data.loc[data[data_nuts0_column].isin(regionlist)]
    else:
    # Create a list with the NUTS2 codes that should be included in the analysis:
        regionlist=regiondata['nuts_2'][region].split(', ')
        data=data.loc[data[data_nuts2_column].isin(regionlist)]
    return(data)
    
def SendToDatabase(ser, table, schemastr, columname):
    # if data is a series then convert it to pandas dataframe
    if len(ser.shape)==1:
        df = ser.to_frame(name=columname)
    else:
        df=ser
    # use pandas to transfer the pandas dataframe to the database    
    df.to_sql(name=table, con=db.engine, schema=schemastr)
    
    ####### Faster alternative: #######
    # dataframe.head(0).to_sql('Results', engine,if_exists='replace',index=False) #truncates the table
    # conn = db.engine.raw_connection()
    # cur = conn.cursor()
    # output = io.StringIO()
    # dataframe.to_csv(output, sep='\t', header=False, index=False)
    # output.seek(0)
    # contents = output.getvalue()
    # cur.copy_from(output, 'Results', null="") # null values become ''
    # conn.commit()
def ScenarioNullSetter(module, scenario, cost):
    if cost==0 or cost==None:
        cost=None
    else:
        scenario=None
        
    if not module:
        scenario=None
        cost=None
    return(module, scenario, cost)

def irrigation_water_savings_calculation(data, typescenario, costscenario, scale, cost_bau, cost_mtfr, operation_bau, operation_mtfr, current_level, level_bau, level_mtfr, irr_area, impr_irr_area_mtfr):
    # calculates cost, performance and improvement for irrigation measures
    
    # Define cost in function of scenario type
    if costscenario==0 or costscenario==None:
        if typescenario == 'BAU':
            c = 0
        elif typescenario == '+10%':
            c = 0.1
        elif typescenario == '+25%':
            c = 0.25
        elif typescenario == '+50%':
            c = 0.5
        elif typescenario == '+75%':
            c = 0.75            
        else:
            c = 1.0
    else:
        c=costscenario/data[cost_mtfr].sum().sum()
        if c>1:
            logging.error('The specified investment amount is higher than costs of MTFR')
            sys.quit()
    
    if scale=='Member States' or scale=='NUTS0':
        # load table with nuts-codes
        nutscodes=readdata2Dataframe('nuts2013_index', ['nuts_0','nuts_2'])
        
        # remove duplicate nuts-2 regions, sort alphabetically and set the index.
        nutscodesunique=nutscodes.drop_duplicates(subset='nuts_2')
        nutscodesunique=nutscodesunique.sort_values('nuts_2')
        nutscodesunique=nutscodesunique.set_index('nuts_2')
        
        pctImprov_nuts2=data[level_mtfr[0]].multiply(c)
        # Normalised improvement via percentage and improved area
        improv_nuts2_n=pctImprov_nuts2.multiply(data['is_n2_current_irrigated_surface_eurostat'])
        improv_nuts2_n=pd.concat([improv_nuts2_n, nutscodesunique],axis=1, join_axes=[improv_nuts2_n.index])
        improv_ms_n=improv_nuts2_n.groupby('nuts_0').agg('sum')
        
        level_curr_n2 = data[current_level[0]].multiply(data['is_n2_current_irrigated_surface_eurostat'])
        level_curr_n2 = pd.concat([level_curr_n2, nutscodesunique],axis=1, join_axes=[level_curr_n2.index])
        level_curr_ms = level_curr_n2.groupby('nuts_0').agg('sum')
        
        level_bau_n2 = data[level_bau[0]].multiply(data['is_n2_current_irrigated_surface_eurostat'])
        level_bau_n2 = pd.concat([level_bau_n2, nutscodesunique],axis=1, join_axes=[level_bau_n2.index])
        level_bau_ms = level_bau_n2.groupby('nuts_0').agg('sum')
        
        # Aggregate values based on member states column
        data_ms=data.groupby('is_n2_member_state').agg('sum')
        data_ms.index.name='nuts_code'  
        
        # current efficiency, extra efficiency by reaching BAU and further efficiency with additional investment. The irrigated surface is replaced with 1 where 0 (eg. Luxenborg), otherwise the efficiency becomes 0 in the results. 
        level_curr_ms=level_curr_ms.divide(data_ms['is_n2_current_irrigated_surface_eurostat'], axis=0)
        level_bau_ms=level_bau_ms.divide(data_ms['is_n2_current_irrigated_surface_eurostat'], axis=0)
        pctImprov=improv_ms_n.divide(data_ms['is_n2_current_irrigated_surface_eurostat'], axis=0).fillna(0)
        
        
        # calculate cost distribution on MS-level
        costDistr=data_ms[cost_mtfr].sum(axis=1).multiply(c)
        AdditionalOperationCost=data_ms[operation_mtfr].multiply(c)
        
        # calculate improved irrigation area
        irr_improved_area=data_ms[impr_irr_area_mtfr[0]].multiply(c)
        
        # Calculate total efficiency
        total_efficiency=level_curr_ms.fillna(0).add(level_bau_ms.fillna(0)).add(pctImprov.fillna(0))
        
        #edit column names
        pctImprov.columns=['irr_performance_improvement']
        total_efficiency.columns=['irr_total_efficiency']
        
    else:   
        # Calculate distribution of investment cost
        costDistr=data[cost_mtfr].sum(axis=1).multiply(c)
        # calculate increase in operation cost
        AdditionalOperationCost=data[operation_mtfr].multiply(c)
        # calculate performance improvement
        pctImprov=costDistr.divide(data[cost_mtfr].sum(axis=1).divide(data[level_mtfr[0]])).fillna(0)
        # calculate estimated improved area
        irr_improved_area=data[impr_irr_area_mtfr[0]].multiply(c)
        # calculate the total efficiency after investment
        total_efficiency=data[current_level[0]].add(data[level_bau[0]]).add(pctImprov)
        
        #edit index name and column names
        pctImprov=pctImprov.to_frame(name='irr_performance_improvement')
        total_efficiency=total_efficiency.to_frame(name='irr_total_efficiency')
    
    #edit index name and column names
    AdditionalOperationCost.columns=['irr_additional_operation_cost']
    costDistr=costDistr.to_frame(name='irr_investment')
    irr_improved_area=irr_improved_area.to_frame(name='improved_irr_area_ha')
    
    return(costDistr, AdditionalOperationCost, pctImprov, total_efficiency, irr_improved_area)  
    
def urban_water_savings_calculation(data, typescenario, costscenario, scale, cost_bau, cost_mtfr, operation_bau, operation_mtfr, level_current, level_bau, level_mtfr, pop_current, pop_bau, pop_mtfr):

    # Define cost in function of scenario type
    if costscenario==0 or costscenario==None:
        if typescenario == 'BAU':
            c = 0
        elif typescenario == '+10%':
            c = 0.1
        elif typescenario == '+25%':
            c = 0.25
        elif typescenario == '+50%':
            c = 0.5
        elif typescenario == '+75%':
            c = 0.75            
        elif typescenario == 'MTFR':
            c = 1.0 
        else:
            logging.error('the value of "typescenario" is not a valid case')
            sys.quit()
    else:
        c=costscenario/data[cost_mtfr].sum().sum()
        if c>1:
            logging.error('The specified investment amount is higher than costs of MTFR')
            sys.quit()
    costDistr=data[cost_mtfr[0]].multiply(c)
    AdditionalOperationCost=data[operation_mtfr[0]].multiply(c)
    pctImprov=data[level_mtfr[0]].multiply(c)
    popImprov=data[pop_mtfr[0]].multiply(c)
    costDistr_tot=data[cost_bau[0]].add(costDistr)
    popImprov_tot=data[pop_bau[0]].add(popImprov)
    
    # calculate the total efficiency after investment
    total_efficiency=data[level_current[0]].add(data[level_bau[0]]).add(pctImprov.fillna(0))
    
    #edit index name and column names
    # costDistr.index.name='nuts_code'
    # AdditionalOperationCost.index.name='nuts_code'
    # pctImprov.index.name='nuts_code'
    # total_efficiency.index.name='nuts_code'
    # popImprov.index.name='nuts_code'
    costDistr=costDistr.to_frame(name='urb_investment')
    AdditionalOperationCost=AdditionalOperationCost.to_frame(name='urb_additional_operation_cost')
    pctImprov=pctImprov.to_frame(name='urb_performance_improvement')
    total_efficiency=total_efficiency.to_frame(name='urb_total_efficiency')
    popImprov=popImprov.to_frame(name='urb_improved_pop_eqv')
        
    return(costDistr, AdditionalOperationCost, pctImprov, total_efficiency, popImprov)
    
def UWWTP_NutrientLoads_calculation(data, typescenario, costscenario, scale, cost_bau, cost_bau_fc, cost_mtfr, operation_bau, operation_bau_fc, operation_mtfr, level_current_in, level_current_out, level_bau_fc, level_bau, level_mtfr):
    
    # aggregate data to MS-level from nuts2:
    if scale=='Member States' or scale=='NUTS0':
        # load table with nuts-codes
        nutscodes=readdata2Dataframe('nuts2013_index', ['nuts_0','nuts_2'])
        
        # remove duplicate nuts-2 regions, sort alphabetically and set the index.
        nutscodesunique=nutscodes.drop_duplicates(subset='nuts_2')
        nutscodesunique=nutscodesunique.sort_values('nuts_2')
        nutscodesunique=nutscodesunique.set_index('nuts_2')
        
        # add the nuts-0 id (member state) to the data and aggregate values based on this column
        temp=pd.concat([data, nutscodesunique],axis=1, join_axes=[data.index])
        data=temp.groupby('nuts_0').agg('sum')
        data.index.name='nuts_code'
    
    # Define cost in function of scenario type
    if costscenario==0 or costscenario==None:
        if typescenario == 'BAU':
            c = 0
            #investment costs in the BAU scenario:
            costDistr=data[cost_mtfr].multiply(c)
            costDistr.columns=['nu_investment']
            
            # operation cost in BAU scenario:
            add_operation_cost=data[operation_mtfr].multiply(c)
            add_operation_cost.columns=['nu_additional_operation_cost']
            
            # nutrient loads in kg/day in the BAU scenario:
            nutrientLoads=data[level_bau]
            nutrientLoads.columns=['nu_load_bod5', 'nu_load_n', 'nu_load_p']
            
            # removal efficiency of BOD5, nitrogen and phosphorus in percent:
            nu_treatment_efficiency=calculateTreatmentEfficiency(data,level_current_in,level_bau)
            
            # return these dataframes and skip remaining of function:
            return(costDistr, add_operation_cost, nutrientLoads, nu_treatment_efficiency)
            
        elif typescenario == '+10%':
            c = 0.1
        elif typescenario == '+25%':
            c = 0.25
        elif typescenario == '+50%':
            c = 0.5
        elif typescenario == '+75%':
            c = 0.75            
        elif typescenario == 'MTFR':
            c = 1.0 
            #investment costs in the MTFR scenario:
            costDistr=data[cost_mtfr]
            costDistr.columns=['nu_investment']
            
            # additional operation cost in MTFR scenario:
            add_operation_cost=data[operation_mtfr]
            add_operation_cost.columns=['nu_additional_operation_cost']
            
            # nutrient loads in kg/day in the MTFR scenario:
            nutrientLoads=data[level_mtfr]
            nutrientLoads.columns=['nu_load_bod5', 'nu_load_n', 'nu_load_p']
            
            # removal efficiency of BOD5, nitrogen and phosphorus in percent:
            nu_treatment_efficiency=calculateTreatmentEfficiency(data,level_current_in,level_mtfr)
            
            # return these dataframes and skip remaining of function:
            return(costDistr, add_operation_cost, nutrientLoads, nu_treatment_efficiency)
            
        elif typescenario == 'BAU-FC':
            # change columns for calculation to BAU-FC-data
            c=None
            #investment costs in the BAU-FC scenario:
            costDistr=data[cost_bau_fc]
            costDistr.columns=['nu_investment']
            
            # additional operation cost in MTFR scenario:
            add_operation_cost=data[operation_bau_fc]
            add_operation_cost.columns=['nu_additional_operation_cost']
            
            # nutrient loads in kg/day in the BAU-FC scenario:
            nutrientLoads=data[level_bau_fc]
            nutrientLoads.columns=['nu_load_bod5', 'nu_load_n', 'nu_load_p']
            
            # removal efficiency of BOD5, nitrogen and phosphorus in percent:
            nu_treatment_efficiency=calculateTreatmentEfficiency(data, level_current_in, level_bau_fc)
            
            # return these dataframes and skip remaining of function:
            return(costDistr, add_operation_cost, nutrientLoads, nu_treatment_efficiency)
            
        else: 
            logging.error('the value of "typescenario" is not a valid case')
            sys.quit()
    else:
        c=costscenario/data[cost_mtfr].sum().sum()
        if c>1:
            logging.error('The specified investment amount is higher than costs of MTFR')
            sys.quit()
        
    # distribution of cost (evenly distributed across EU):
    costDistr=data[cost_mtfr].multiply(c)
    costDistr.columns=['nu_investment']
    
    # additional operation cost:
    add_operation_cost=data[operation_mtfr].multiply(c)
    add_operation_cost.columns=['nu_additional_operation_cost']
    
    # Total load of BOD5, N and P:
    # BOD5Load_bau-((BOD5Load_bau-BOD5Load_mtfr)*c)
    BOD5_load=data[level_bau[0]].subtract((data[level_bau[0]].subtract(data[level_mtfr[0]]))*c)
    N_load=data[level_bau[1]].subtract((data[level_bau[1]].subtract(data[level_mtfr[1]]))*c)
    P_load=data[level_bau[2]].subtract((data[level_bau[2]].subtract(data[level_mtfr[2]]))*c)
    nutrientLoads=pd.concat([BOD5_load, N_load, P_load], axis=1, keys=['nu_load_bod5', 'nu_load_n', 'nu_load_p'])
    
    # removal efficiency of BOD5, nitrogen and phosphorus in percent. Calculated as removal efficiency = (BOD5_current_inlet-BOD5_outlet_BAU)/BOD5_current_inlet
    nu_eff_result_bod5=data[level_current_in[0]].subtract(BOD5_load).divide(data[level_current_in[0]])
    nu_eff_result_n=data[level_current_in[1]].subtract(N_load).divide(data[level_current_in[1]])
    nu_eff_result_p=data[level_current_in[2]].subtract(P_load).divide(data[level_current_in[2]])
    nu_treatment_efficiency=pd.concat([nu_eff_result_bod5, nu_eff_result_n, nu_eff_result_p], axis=1, keys=['nu_efficiency_bod5', 'nu_efficiency_n', 'nu_efficiency_p'])
    
    return(costDistr, add_operation_cost, nutrientLoads, nu_treatment_efficiency)

def calculateTreatmentEfficiency(data, currentLoad, newLoad):
    # index dependent!
    # removal efficiency of BOD5, nitrogen and phosphorus in percent. Calculated as removal efficiency = (BOD5_current_inlet-BOD5_outlet_BAU)/BOD5_current_inlet
    nu_eff_result_bod5=data[currentLoad[0]].subtract(data[newLoad[0]]).divide(data[currentLoad[0]])
    nu_eff_result_n=data[currentLoad[1]].subtract(data[newLoad[1]]).divide(data[currentLoad[1]])
    nu_eff_result_p=data[currentLoad[2]].subtract(data[newLoad[2]]).divide(data[currentLoad[2]])
    
    # Merge dataframes for BOD5, N and P removal into a single dataframe with headers:
    nu_treatment_efficiency=pd.concat([nu_eff_result_bod5, nu_eff_result_n, nu_eff_result_p], axis=1, keys=['nu_efficiency_bod5', 'nu_efficiency_n', 'nu_efficiency_p'])
    return(nu_treatment_efficiency)

def calculateCSOimprovement(data, level_bau, cost_mtfr, operation_mtfr, typescenario, costscenario, scale):
    # read the irrigation data table into a pandas dataframe
    # data=readdata2Dataframe(table, '*')
    # data=data.set_index(nuts[0]) # set index to Nuts-key
    if scale=='Member States' or scale=='NUTS0':
        data=data.groupby('ww_n2_country_code').sum()
        data.index.name='nuts_code'
    # Define cost in function of scenario type
    if costscenario==0 or costscenario==None:
        if typescenario == 'BAU':
            c = 0
        elif typescenario == '+10%':
            c = 0.1
        elif typescenario == '+25%':
            c = 0.25
        elif typescenario == '+50%':
            c = 0.5
        elif typescenario == '+75%':
            c = 0.75            
        else:
            c = 1.0
    else:
        c=costscenario/data[cost_mtfr].sum().sum()
        if c>1:
            logging.error('The specified investment amount is higher than costs of MTFR')
            sys.quit()
    # calculate investment cost for each region:
    costDistr=data[cost_mtfr].multiply(c)
    costDistr.columns=['cso_investment']
    
    # calculate additional operation cost:
    add_operation_cost=data[operation_mtfr].multiply(c)
    add_operation_cost.columns=['cso_additional_operation_cost']
    
    # Calculate loads in kg/day for BOD5, Nitrogen and Phosphorus:
    BOD5_load=data[level_bau[0]].subtract(data[level_bau[0]]*c)
    N_load=data[level_bau[1]].subtract(data[level_bau[1]]*c)
    P_load=data[level_bau[2]].subtract(data[level_bau[2]]*c)
    
    # Calculate reduction in %
    BOD5_red_pct=1-BOD5_load.divide(data[level_bau[0]])
    N_red_pct=1-N_load.divide(data[level_bau[1]])
    P_red_pct=1-P_load.divide(data[level_bau[2]])
    
    # collect results in dataframes
    CSO_loads=pd.concat([BOD5_load, N_load, P_load], axis=1, keys=['cso_load_bod5', 'cso_load_n', 'cso_load_p'])
    CSO_reduction_pct=pd.concat([BOD5_red_pct,N_red_pct,P_red_pct],axis=1,keys=['cso_improvement_bod5','cso_improvement_n','cso_improvement_p'])
    
    return(costDistr, add_operation_cost, CSO_loads, CSO_reduction_pct)
    
# Alter table 
def updateGeometriesNuts2(table, schema, nuts2_colname):    
	# Add new column with NUTS2 geometries to table. The NUTS codes of the existing table is attempted linked to geometries in the database
	sql = """ALTER TABLE {s}."{t}" ADD {c} {d};
	         WITH geomvalues as (select geom, nuts_id from {nuts2table} t1)
             UPDATE {s}."{t}" as t1
             SET geom = nv.geom
             FROM geomvalues nv
             WHERE nv.nuts_id = t1.{n};""".format(c='geom',s=schema,t=table, d='geometry(MultiPolygon)',n=nuts2_colname, nuts2table='public.nuts_rg_01m_2013_3035_levl_2') 
	db.engine.execute(sql)
    
def updateGeometriesMS(table, schema, nuts_colname):    
	# Add new column with NUTS0 geometries to table. The NUTS codes of the existing table is attempted linked to geometries in the database
	sql = """ALTER TABLE {s}."{t}" ADD {c} {d};
	         WITH geomvalues as (select geom, nuts_id from {nutstable} t1)
             UPDATE {s}."{t}" as t1
             SET geom = nv.geom
             FROM geomvalues nv
             WHERE nv.nuts_id = t1.{n};""".format(c='geom',s=schema,t=table, d='geometry(MultiPolygon)',n=nuts_colname, nutstable='public.nuts_rg_01m_2013_3035_levl_0') 
	db.engine.execute(sql)


