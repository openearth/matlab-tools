import numpy as np
import configparser
import pandas as pd
import glob

class Odv_new():
    
    def __init__(self):
        # instances for the header
        self.header= []  # raw header 
        self.odv_column= [] # column names such as cruise, ...e.t.c.
        self.odv_units= []  # units of each column
        self.meta_variables = [] # stores the names of meta variables
        self.data_variables = [] # stores the names of data variables
        
    def header2columns(self):
        # get local column names: last header line
        odvcolumnnames = self.header[-1].split('\t') # the last line of self.header has the column names.

        for col in odvcolumnnames:
            self.odv_column.append(col) # incl units, excl. spaces
            if len(col.split(' [')) ==2:
                self.odv_units.append(col.split(' [')[1].split(']')[0])
            else:
                self.odv_units.append('') # do not use None, as it does not print well in overviews
            
            
        for line in self.header:
            if ( line.find('<MetaVariable>') >= 0):
                string= line.split('<MetaVariable>')[1].split('</MetaVariable>')[0]
                upper_index= string.find("var_type")- 2 # -2  to remove space and comilla
                self.meta_variables.append( string[7: upper_index] )

            if ( line.find('<DataVariable>') >= 0):
                string= line.split('<DataVariable>')[1].split('</DataVariable>')[0]
                upper_index= string.find("value_type")- 2 # -2  to remove space and comilla
                self.data_variables.append( string[7: upper_index] )    
        
    
    ####################################################################
    def get_header(self, filename):
        f= open(filename ,'r',  encoding="utf8")
        
        # Here I get all the header from the file
        while True:
            l=f.readline()
            self.header.append(l)
            if l.find('//')==-1:  # if a specific line does not have the character \\
                print ('finished reading semantic header')
                break
        # Here I use the header to obtain column_names, units and variables  
        self.header2columns()
        
        #Get a table with raw header data
        #self.header_df= pd.DataFrame(index= np.arange(0, np.shape(self.header)[0]),
        #                             columns= ['filename', 'metadata'])
        #self.header_df.iloc[:, 0]= "Arctic-Sediment_harmonized_depth_profiles.txt"        
        #self.header_df.iloc[:, 1] = [i.replace('\n', '').replace('//', '') for i in self.header]
        
    ####################################################################   
    def from_odv_to_pandas(self, filename):
        """
        With this function I get a pandas dataframe from an odv file.
        """
        f= open(filename, 'r', encoding="utf8" )
       
        data= []    
        for i, line in enumerate(f): 
            if ( line.find('//')!= 0 ): # do not get lines starting with //
                data.append(line.split('\t')) 
        
    
        # creation of a pandas dataframe containing data from odv file
        print('shape data (numpy):', len(data))
        self.dataset= pd.DataFrame(data[1:], columns= data[0])
        self.dataset.iloc[:, -1]= [i.replace('\n', '') for i in self.dataset[self.dataset.columns[-1]]] # didn't work pd.series.replace()
        self.dataset.replace('', np.nan, inplace= True)
        self.dataset.fillna(method= 'ffill', inplace= True)
        print('shape of data (pandas df before filtering):', self.dataset.shape)
        
    ####################################################################    
    def get_metatable(self, filename):
        """
        This function gets the meta table needed for the emodnet project
        """
        
        self.get_header(filename) # to get data variables 
        self.from_odv_to_pandas(filename) 
        
        desired_metacols = self.dataset.columns[self.dataset.columns.str.match('cruise', case= False) ^
                                                self.dataset.columns.str.contains('longitude', case= False) ^
                                       self.dataset.columns.str.contains('latitude', case= False) ^
                                       self.dataset.columns.str.contains('local_cdi', case= False) ^
                                       self.dataset.columns.str.contains('edmo_code', case= False) ^
                                       self.dataset.columns.str.contains('Bot.', case= False) ^
                                       self.dataset.columns.str.contains('data set creation date', case= False) ^
                                       self.dataset.columns.str.contains(r'/ ordering', case= False) ^
                                       self.dataset.columns.str.contains('access', case= False) ^
                                       self.dataset.columns.str.contains('yyyy', case= False) ^
                                       self.dataset.columns.str.contains('cdi-record', case= False)
                                    ]
                                    
        # reduce the dataframe with desired metavariables + data
        self.dataset = self.dataset[list(desired_metacols)+ self.data_variables]
        
        if ("QV:SEADATANET" in self.dataset.columns):
            self.dataset.drop("QV:SEADATANET", axis=1, inplace= True)
        
        print('shape of data (pandas df after filtering):', self.dataset.shape)
        
        # Creation of the meta-table
        self.universal_df= pd.DataFrame(index= np.arange(0, self.dataset.shape[0]+1),
                                        columns= ['filename', 'recordnr', 'mainrecordnr']+['column%s'%str(i)for i in range(1, 1001)])
        
        # First column is the filename
        fn= np.repeat(filename, self.dataset.shape[0])
        self.universal_df.iloc[1:, 0]= fn
        
        # Second column is the record number
        recordnr =[]
        recordnr.append(0)
        for i in self.dataset.groupby('Cruise').size().values:
            counts= np.arange(1, i+1)
            for c in counts:
                recordnr.append(c)

        self.universal_df.iloc[:, 1]= recordnr
        
        # 3rd column is the main record number
        mainrecordnr= {}
        for i, j in enumerate(self.dataset.Cruise.unique()):
            mainrecordnr[j]= i+1
        self.universal_df.iloc[1:, 2]= self.dataset.Cruise.map(mainrecordnr).values
        self.universal_df.iloc[0, 2]= 0
        
        # Put the data from odv file
        print('shape universal:', self.universal_df.iloc[1:, 3:self.dataset.shape[1]+3].shape)
        self.universal_df.iloc[1:, 3:self.dataset.shape[1]+3]= self.dataset.values
        self.universal_df.iloc[0, 3:self.dataset.shape[1]+3]= self.dataset.columns
        self.universal_df.filename= self.universal_df.filename.fillna(method= 'bfill')

#if (__name__ == "__main__" ):

path= 'N:/Projects/1230500/1230915/B. Measurements and calculations/dataJan2019/Contaminants/Contaminants_ODV-collections_Jan2019_txt/'       
#path= 'N:/Projects/1230500/1230915/B. Measurements and calculations/dataJan2019/Eutrophication_all_withDIN/'
files= glob.glob(path+'*.txt')

#del files[17, 19, 21] #contaminants
files1= files[0:17]+ [files[18]]+ [files[20]]

print ('number of files:', len(files1))

##### To write tables in database##########
import psycopg2
from sqlalchemy import create_engine 

pghost = "localhost"
pgport = 5432
pgdatabase = "postgres"
pguser = "postgres"
pgpassword = ""

try:
    con = psycopg2.connect(f"host={pghost} port={pgport} dbname={pgdatabase} user={pguser} password={pgpassword}")
    con.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    engine= create_engine(f"postgresql+psycopg2://{pguser}:{pgpassword}@{pghost}:{pgport}/{pgdatabase}")
except psycopg2.OperationalError as e:
    print("Error while connecting to PostgreSQL --> {err}".format(err=e))
except psycopg2.Error as e:
    print("Error while connecting to PostgreSQL --> {err}".format(err=e.pgerror))
else:
    print("\nConnection with PostgreSQL successful\n")

engine.execute("DROP table if exists public.datalines ;")

i= 0
for file in files1[0:5]:
    print (file, i)
    odv= Odv_new()
    odv.get_metatable(file)
    for j in odv.universal_df.columns:
        odv.universal_df[j]= odv.universal_df[j].astype(str)
        
    odv.universal_df.to_sql('datalines', engine, schema= 'public', if_exists= 'append', index= False)
    print('file written into sql')
    i +=1
    



    





