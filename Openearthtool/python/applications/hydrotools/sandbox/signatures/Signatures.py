# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

#### IMPORT PACKAGES ####
import numpy as np
import pandas
import re, glob, os, sys
import mx.DateTime
import matplotlib.pyplot as plt
import matplotlib.dates as mpld
import datetime
%matplotlib inline

# <codecell>

#### DEFINITIONS ####
def read_file(filename, column=-1):
    """Read the file, assuming the format YYYY[Y]? MM DD HH MM VALUE, yield years"""
    with open(filename) as f:
        ### Export from FEWS data, skip first two (header) rows
        f.next()
        f.next()
        for line in f:
            row = re.split('-|,| ',line)
            date= datetime.date(int(row[0]), int(row[1]), int(row[2]))
            value = float(row[column])
            yield (date.year, date, date.timetuple().tm_yday, value)

# <codecell>

#### THIS SCRIPT IS BASED ON "NORMAL" YEARS FROM 01-01-YYYY - 31-12-YYYY ####
""" TO DO:
- Add 10 day minimum
"""

### Read the data into a Pandas dataframe
path_to_data = r'd:\tools\HYDTools\sandbox\signatures'
path_to_figs = r'd:\tools\HYDTools\sandbox\signatures\figures'
dataFile = path_to_data + '\\lobith_grade.csv'

data = pandas.DataFrame.from_records(read_file(dataFile, -1), columns=['year', 'date', 'day_of_year', 'discharge'])

### DEFINE HYDROLOGICAL YEAR
years_for_hydyear = np.hstack([np.array(np.ones(365, dtype='int')* np.array(data['year'])[0]-1), 
                               np.array(data['year']),
                               np.array(np.ones(365, dtype='int')* np.array(data['year'])[-1]+1)])

delta = 271   #### HYDROLOGICAL YEAR STARTS AT 1st OF OCTOBER ###
years = np.zeros(len(data))
for i in range(0,len(data)):
    years[i] = years_for_hydyear[data.index[i]+365-delta]
    
data['hyd_year'] = years

### HERE STARTS THE PLOTTING
#fig00, ax00 = plt.subplots(figsize=(10,8))
#ax00.plot(data['date'][15704:16500], data['hyd_year'][15704:16500], linewidth=2)
#ax00.xaxis.set_major_formatter(mpld.DateFormatter('%Y/%m/%d'))
#fig00.autofmt_xdate()
#ax00.set_ylim([min(data['hyd_year'][15704:16500]), max(data['hyd_year'][15704:16500])])
#ax00.set_title('Hydrological years from 1993-1995', fontsize=20)
#ax00.grid(True)

# <codecell>

#### To check the data, print first and last rows
print data[0:3]
print data[-4:-1]

# <codecell>

#### And check hydrograph
fig0, ax0 = plt.subplots(figsize=(10,8))
ax0.plot(data['date'][15500:16500], data['discharge'][15500:16500], linewidth=2)
ax0.xaxis.set_major_formatter(mpld.DateFormatter('%Y/%m/%d'))
fig0.autofmt_xdate()
ax0.set_title('Hydrograph for 1993 and 1995', fontsize=20)
ax0.grid(True)

plt.savefig(path_to_figs + '\\hydrograph.png', dpi=300, bbox_tight=True)

# <codecell>

### Plot the annual flow duration curves (AFDC)
group_by_year = data.groupby(['hyd_year'])
all_data      = data['discharge']
D0=[]
for n in range(0,len(all_data)):
    D0.append(float(n)/(len(all_data)+1.))


f1 = plt.figure(figsize=(10,8))
ax1= f1.add_subplot(1,1,1)
for year, event in iter(group_by_year):
    D1=[]
    for n in range(0,len(event['discharge'])):
        D1.append(float(n)/(len(event['discharge'])+1.))
    ax1.plot(D1,np.sort(event['discharge'])[::-1],'grey', linewidth=1, label=year)
    ax1.plot(D0,np.sort(all_data)[::-1],'red', linewidth=2, label="all years")

#ax1.set_xlim(0.1,0.9)
handles,labels = ax1.get_legend_handles_labels()
ax1.legend([handles[0], handles[-1]],[str('1951-2006'), labels[-1]],loc='best')

ax1.set_xlabel('D [-]', fontsize=15)
ax1.set_ylabel('Discharge [m3/s]', fontsize=15)
ax1.set_title('Annual flow duration curves', fontsize=20)
ax1.grid(True)

plt.savefig(path_to_figs + '\\annual_FDC.png', dpi=300, bbox_tight=True)

# <codecell>

### Now plot the median, mean and quantile FDCs
key1 = data['hyd_year']
key2 = data['discharge'].rank(ascending=True)
sorter = np.lexsort((key2, key1))

sorted_data = data.take(sorter, )
sorted_data.set_index(np.arange(0,len(sorted_data)),inplace=True)
sorted_data['old_day_of_year'] = pandas.Series(data['day_of_year'])
piv = sorted_data.pivot(index='hyd_year', columns='old_day_of_year', values='discharge')

piv_mean = []; piv_median = []
for day_of_year, arg in piv.iterkv():
    piv_mean.append(np.mean(piv[day_of_year].dropna().values))
    piv_median.append(np.median(piv[day_of_year].dropna().values))

D2 = []
for n in range(0,len(piv_median)):
     D2.append(float(n)/(len(piv_median)+1.))

#### HERE THE PLOTTING STARTS ####
f2 = plt.figure(figsize=(10,8))
ax2= f2.add_subplot(1,1,1)
ax2.plot(D0,np.sort(all_data)[::-1],'m--', linewidth=2, label="all years")
ax2.plot(D2,np.sort(piv_mean)[::-1], 'g', linewidth=2, label="Mean")
ax2.plot(D2,np.sort(piv_median)[::-1], 'r', linewidth=2, label="Median")
ax2.plot(D2,np.sort(piv.quantile(0.05))[::-1], 'b', linewidth=2, label='Quantile 0.05')
ax2.plot(D2,np.sort(piv.quantile(0.95))[::-1], 'b', linewidth=2, label='Quantile 0.95')

ax2.set_xlabel('D [-]', fontsize=15)
ax2.set_ylabel('Discharge [m3/s]', fontsize=15)
ax2.set_title('Statistics of the flow duration curves', fontsize=20)
ax2.grid(True)
handles,labels = ax2.get_legend_handles_labels()
ax2.legend(handles,labels,loc='best')

plt.savefig(path_to_figs + '\\statistics_FDC.png', dpi=300, bbox_tight=True)

# <codecell>

#### NOW LOOK AT THE PEAKS ####
annualMaxima     = group_by_year['discharge'].max()
idxAnnualMaxima  = group_by_year['discharge'].idxmax()
dates = data['date']

annualMean = group_by_year['discharge'].mean()  ### One value per year
rng = data.year ### Len data, filled with year for all days of the year

ar = np.zeros((len(rng),1))
index = np.zeros((len(rng),1))
for i in range(0,len(rng)):
    index[i] = np.array(annualMean.index[rng[i]==np.array(annualMean.index)])
    ar[i] = annualMean[np.array(annualMean.index[rng[i]==np.array(annualMean.index)])]

#### NOW PLOT
fig3, ax3 = plt.subplots(figsize=(10,8))
ax3.plot(dates, data['discharge'], linewidth=2)
ax3.plot(dates[idxAnnualMaxima], annualMaxima, 'ro')
ax3.plot(dates, ar, 'r')
fig3.autofmt_xdate()
ax3.set_title('Annual maxima', fontsize=20)
ax3.grid(True)
ax3.set_xlabel('Date [-]', fontsize=15)
ax3.set_ylabel('Discharge [m3/s]', fontsize=15)

#plt.savefig(path_to_figs + '\\annualMaxima.png', dpi=300, bbox_tight=True)

# <codecell>

#### NOW PLOT THE ANNUAL MAXIMA AGAINST RP ####
a=0.3
b = 1.-2.*a

p  = ((np.arange(1,len(annualMaxima)+1.)-a))/(len(annualMaxima)+b)
rp = 1/(1-p)
gumbel_p = -np.log(-np.log(1.-1./rp))

fig4, ax4 = plt.subplots(figsize=(10,8))
ax4.plot(gumbel_p,np.sort(annualMaxima),'bo')

ax4.set_title('Gumbelplot annual maxima', fontsize=20)
ax4.grid(True)
ax4.set_xlabel('Return period [1/year]', fontsize=15)
ax4.set_ylabel('Discharge [m3/s]', fontsize=15)

font_labels = 15
plt.tick_params(axis='both', which='major', labelsize=20)
Ts = [2.,10.,25.,100.,500.]
for T in Ts:
    plt.vlines(-np.log(-np.log(1-(1./T))),0,16000,'r')
    plt.text(-np.log(-np.log(1-(1./T))),2000,'T=%.0f' %T,fontsize=font_labels)

plt.savefig(path_to_figs + '\\gumbelAnnualMaxima.png', dpi=300, bbox_tight=True)

# <codecell>

#### NOW LOOK AT LOW FLOWS ####
annualMinima     = group_by_year['discharge'].min()
idxAnnualMinima  = group_by_year['discharge'].idxmin()
dates = data['date']

#### NOW PLOT
fig6, ax6 = plt.subplots(figsize=(10,8))
ax6.plot(dates, data['discharge'], linewidth=2)
ax6.plot(dates[idxAnnualMinima[1:]], annualMinima[1:], 'ro')
ax6.plot(dates, ar, 'r')
fig6.autofmt_xdate()
ax6.set_title('Annual minima', fontsize=20)
ax6.grid(True)
ax6.set_xlabel('Date [-]', fontsize=15)
ax6.set_ylabel('Discharge [m3/s]', fontsize=15)

plt.savefig(path_to_figs + '\\annualMinima.png', dpi=300, bbox_tight=True)

# <codecell>

#### NOW PLOT THE ANNUAL MAXIMA AGAINST RP ####
a=0.3
b = 1.-2.*a

p  = ((np.arange(1,len(annualMinima)+1.)-a))/(len(annualMinima)+b)
rp = 1/(1-p)
gumbel_p = -np.log(-np.log(1.-1./rp))

fig4, ax4 = plt.subplots(figsize=(10,8))
ax4.plot(gumbel_p,np.sort(annualMinima)[::-1],'bo')

ax4.set_title('Gumbelplot annual minima', fontsize=20)
ax4.grid(True)
ax4.set_xlabel('Return period [1/year]', fontsize=15)
ax4.set_ylabel('Discharge [m3/s]', fontsize=15)

font_labels = 15
plt.tick_params(axis='both', which='major', labelsize=20)
Ts = [2.,10.,25.,100.,500.]
for T in Ts:
    plt.vlines(-np.log(-np.log(1-(1./T))),0,2500,'r')
    plt.text(-np.log(-np.log(1-(1./T))),2000,'T=%.0f' %T,fontsize=font_labels)

plt.savefig(path_to_figs + '\\gumbelAnnualMinima.png', dpi=300, bbox_tight=True)

# <codecell>


