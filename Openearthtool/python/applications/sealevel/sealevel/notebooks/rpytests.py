# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import pandas.rpy.common

def annual_means(station="DEN HELDER"):
    data = pandas.rpy.common.load_data('dutch', 'sealevel')
    stationdf = filter(lambda x:x['name'] ==station, data.values())[0]['data']
    return stationdf

# <codecell>

df = annual_means()

# <codecell>

import io
stream = io.BytesIO()
fig, ax = plt.subplots()
df.plot(x='year', y='waterlevel', ax=ax)
fig.savefig(stream)

# <codecell>

import rpy2.robjects
from rpy2.robjects.packages import importr

# <codecell>

sealevel = importr('sealevel')
fit = sealevel.nodal_fit(a[5][2])

# <codecell>

fit_dict = {fit.names[i]: fit[i] for i in range(len(fit))}
fit_dict.keys()

# <codecell>

from rpy2.robjects import r
pandas.rpy.common.convert_robj(r("""
library(sealevel)
data(dutch)
dh <- dutch[[6]]
df <- dh$data
fit <- nodal.fit(dh$zoo)
df$predicted <- predict(fit)
df
"""))

# <codecell>


# <codecell>


