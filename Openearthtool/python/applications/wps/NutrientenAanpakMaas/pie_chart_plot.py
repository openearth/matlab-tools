# -*- coding: utf-8 -*-
"""
Created on Fri Feb 01 17:31:17 2019

@author: Lilia Angelova 
"""

#bokeh imports
import bokeh
import os 
from bokeh.models import ColumnDataSource,LabelSet, Legend
from bokeh.io import output_file, show, save
from bokeh.plotting import figure
from bokeh.layouts import row
from bokeh.transform import cumsum
import logging
#additional libs
import configparser
from sqlalchemy import create_engine
from math import pi
import pandas as pd


def readconf(path):
        confpath = path
        # Parse and load
        cf = configparser.ConfigParser() 
        cf.read(confpath)
        return cf


def sql_engine(path):
        
        path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config_database.txt') #requires config file with section header 
        cf = readconf(path)
        engine = create_engine("postgresql+psycopg2://"+cf.get("postgis", "user")
                                        +":"+cf.get("postgis", "pass")+"@"+cf.get("postgis", "host")+":"+str(cf.get("postgis", "port"))
                                        +"/"+cf.get("postgis", "db"), strategy="threadlocal") 
        return engine
        


class Pie_plot:

        def __init__(self,name,param,input_data, engine,color_dict):
                self.name = name
                self.param = param
                self.input_data = input_data
                self.engine = engine
                self.color_dict = color_dict 

        def to_dict(self):
            
                for row in self.input_data:                        
                        dic_n = dict((key, value) for key, value in row.items()) #sqlalchemy object to dict
                
                #dict with fields only for the plotting        
                sub = [u'act_bem_{}',u'his_bem_{}', u'nlev_bod_{}',u'ua_nat_{}',u'ua_kwel_{}',u'landb_ov_{}',u'rwzi_{}',u'overst_{}',u'antrop_{}',u'dep_op_{}',u'buitenl_{}',u'rijkswat_{}',u'rwzi_afw_{}',u'afw_ov_{}',u'nat_bovenstr',u'landb_bovenstr']
                fields = []
                for i in sub:
                        fields.append(i.format(self.param)) #fields names depend on the table (p and n)
                
                newdict_n = dict((k,str(dic_n[k])) for k in fields ) #convert values to strings (engine returns custom decimal types)
                s = pd.Series(newdict_n)
                to_plot = pd.to_numeric(s) #converting the strings to numeric
                return to_plot

        def plot(self):

                raw_data = self.to_dict()
                data = pd.Series(raw_data).reset_index(name="value").rename(columns={"index":"source"})
                acc  = 0
                for i, row  in  data.iterrows():
                        if row["value"]*100 <5: #combining all sources with contribution less than 5%
                                acc += row["value"]
                                data.drop(i,inplace=True)
                        else:
                                continue

                df_accum = pd.DataFrame([["combined",acc]], columns=["source","value"]) #new refined dataframe with combined sources (contribution less than 5%)
                data.sort_values("value", ascending=False, inplace=True)
                new_data = data.append(df_accum)                        
                new_data["value"]*= 100 #percentages
                new_data["angle"] = new_data["value"]/new_data["value"].sum() * 2*pi
                                
                #renaming sources
                column_names = {"act_bem":"actuele bemesting", "afw_ov":"overig bovenstr.", "antrop":"overig antropog.", "buitenl":"buitenland", "dep_op":"depos. op water", "his_bem":"hist. bemesting", "landb_bovens":"landb. bovenstr.",
                                "landb_ov": "landbouw overig", "nat_bovens":"natuur bovenstr.", "nlev_bod":"bodem", "overst":"overstorten", "rijkswat":"kanalen/rijksw.", "rwzi_afw":"rwzi bovenstr.", "rwzi":"rwzi",
                                "ua_kwel":"kwel/depo/OW", "ua_nat":"natuur" , "combin": "ovrg. bronnen <5%"}
                                
                new_data["source"] = new_data["source"].map(lambda x: str(x)[:-2])
                new_data["color"] = new_data["source"].map(self.color_dict)
                new_data["source"] = new_data["source"].map(column_names)


                p = figure(plot_height=450, plot_width = 500, title="Bronnenverhouding {} (% bijdrage per bron)".format(self.name), toolbar_location="below",
                        tooltips="@source: @value")                

                p.wedge(x=0, y=1, radius=0.36,
                        start_angle=cumsum("angle", include_zero=True), end_angle=cumsum("angle"),
                        line_color="white", fill_color="color", legend = "source", source=new_data)

                #format values for labels on the plot
                data_round = new_data.round({"value": 1})
                data_round["value"] = data_round["value"].astype(str) + "%"
                data_round["value"] = data_round["value"].str.pad(30, side = "left")
                source = ColumnDataSource(data_round)
                labels = LabelSet(x=0, y=1, text="value",text_font_size= '10pt', level="glyph",
                        angle=cumsum("angle",include_zero=True), source=source, render_mode="canvas")
                 
                p.legend.background_fill_alpha = 0.3
                p.add_layout(labels)                
                p.xgrid.visible =True
                p.ygrid.visible = True
                p.axis.visible = False

                return p