# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Gerrit Hendriksen
#       gerrit.hendriksen@deltares.nl
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

def get_credentials(credentialfile, dbase=None):
    """Gets the credentials for a database from a file stored in local system
    """
    with open(credentialfile, 'r') as f:
        lines = f.readlines()
    credentials = {}
    if dbase is not None:
        credentials['dbname'] = dbase
    for i in lines:
        item = i.split('=')
        if str.strip(item[0]) == 'dbname':
            if dbase is None:
                credentials['dbname'] = str.strip(item[1])
        if str.strip(item[0]) == 'uname':
            credentials['user'] = str.strip(item[1])
        if str.strip(item[0]) == 'pwd':
            credentials['password'] = str.strip(item[1])
        if str.strip(item[0]) == 'host':
            credentials['host'] = str.strip(item[1])
    logging.info('credentials set for database %s on host %s' %
                 (credentials['dbname'], credentials['host']))
    logging.info('for user %s' % credentials['user'])
    return credentials


def executesqlfetch(strSql, data, cur):
    """Executes a fetch sql that is given into the function, returns data"""
    try:
        cur.execute(strSql, data)
        p = cur.fetchall()
        logging.info(cur.statusmessage)
        logging.debug(cur.query)
        return p
    except Exception as e:
        logging.info(e.message)


def perform_sql(strSql, cur, conn):
    """Executes any sql that is given into the function"""
    try:
        cur.execute(strSql)
        conn.commit()
        logging.info("query type, # rows affected) -- %s" % cur.statusmessage)
        return True
    except Exception as e:
        logging.info(e.message.__str__())
        if e.message.__str__().index('already exists') > 0:
            return True
        else:
            return False


def setup_logger(fpana_log):
    """Creates a standard logger that logs to file"""
    import logging
    logger = logging.getLogger(name=__name__)
    logger.setLevel(logging.DEBUG)

    fh = logging.FileHandler(fpana_log)
    fh.setLevel(logging.DEBUG)
    formatter = logging.Formatter("""%(asctime)s - %(name)s
                                  - %(levelname)s - %(message)s""")
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    return logger


def gap_filling(df, fill_value=None, method=None):
    if method is not None:
        df = df.fillna(method=method)
    elif fill_value is not None:
        df = df.fillna(fill_value)
    else:
        df = df.dropna(how='any')
    return df


def averaging(df, locations_x, locations_y):
    """Averages over rows for selection of locations, merges the two
    locationssets"""
    import pandas
    df_x = df.filter(locations_x).mean(axis=1)
    df_y = df.filter(locations_y).mean(axis=1)
    df_merged = pandas.concat([df_x, df_y], axis=1)
    df_merged.columns = ['x_locations', 'y_locations']
    return df_merged


def calculate_residual(df):
    """calculates the residual of a series: series - mean"""
    ts = df - df.mean()
    return ts


def rolling_mean(ts, window):
    """ Calculating the rolling mean within the window"""
    r = ts.rolling(window=window)
    return r.mean()


def aggregate_function(ts, freq, paramtype=0):
    """Based on timestep, timeseries and parametertype the series is aggregated
    this can only be done from small to larger timestep, or NaNs will be
    introduced. Timestep is in days. If there are not enough values for the
    last time step this timestep is removed."""
    mod = len(ts) / int(freq[:-1])
    paramtype = int(paramtype)
    if mod == 0:
        s = slice(None, None)
    else:
        s = slice(None, -1)

    if paramtype == 0:
        ts_new = ts.resample(freq).mean()[s]
        return ts_new
    if paramtype == 1:
        ts_new = ts.resample(freq).sum()[s]
        return ts_new


def make_tuple(variable):
    """checks whether input is a tuple, and if not it makes it a tuple.
    Works for list, string"""
    if isinstance(variable, tuple):
        return variable
    elif isinstance(variable, str):
        return tuple([variable])
    elif isinstance(variable, list):
        return tuple(variable)


def add_nans(df, col_name):
    import pandas as pd
    import numpy as np
    import datetime
    df_ori = df[:-1]
    df_shift = df[1:]
    dti_diff = df_shift.index - df_ori.index
    dummy_range = pd.DataFrame(data={"dummy": range(len(dti_diff))}).index
    df_mask = dummy_range.where(dti_diff > min(dti_diff) * 1.5)
    df_ind = df_mask.dropna()
    df_ins = df_ori
    for ind in df_ind[::-1]:
        ind = int(ind)
        ind2 = ind + 1
        index1 = df_ori.index[ind] + datetime.timedelta(milliseconds=1)
#        index1 = df_ori.index[ind] + min(dti_diff)
        insert = pd.DataFrame(data={col_name: np.NaN}, index=[index1])
        df_ins = pd.concat([df_ins[:ind2], insert, df_ins[ind2:]])
    df_final = pd.concat([df_ins, df.tail(1)])
    df_final.index.name = "timestamp"
    return df_final


class Parameter:
    def __init__(self, param_id, name, unit, parametertype):
        self.name = name
        self.param_id = param_id
        self.unit = unit
        self.parametertype = parametertype


class Timestepkey:
    def __init__(self, ts_id, ts_label):
        self.ts_id = ts_id
        self.ts_label = ts_label


def get_parameter_names(parameters):
    import os
    import psycopg2
    global logging
    import logging

    fpath_root = os.path.join(os.path.dirname(os.path.abspath(__file__)))

    fname_credentials = 'pgconnection.txt'
    fpana_credentials = os.path.join(fpath_root, fname_credentials)
    credentials = get_credentials(fpana_credentials)

    conn = psycopg2.connect(**credentials)
#    dsn = "host=localhost dbname=azerwis_local user=super_postgres"
#    conn = psycopg2.connect(dsn)
    cur = conn.cursor()

    query = """
        select p.id, p.name, pt.displayunit, pt.parametertype
        from fews.parameterstable p
        join fews.parametergroups pt on pt.groupkey = p.groupkey
        where p.id in %s
        """
    data = (make_tuple(parameters),)
    product = False
    param_dict = {}
    try:
        param_list = executesqlfetch(query, data, cur)
        for item in param_list:
            key = item[0]
            param_dict[key] = Parameter(*item)

        logging.info("Selected %s rows for %s parameters" %
                     (len(param_list), len(make_tuple(parameters))))
        product = param_dict
    except Exception as e:
        logging.info(e.message)

    finally:
        cur.close()
        conn.close()
        return product


def get_timesteps_names(timestepkeys):
    import os
    import psycopg2
    global logging
    import logging

    fpath_root = os.path.join(os.path.dirname(os.path.abspath(__file__)))

    fname_credentials = 'pgconnection.txt'
    fpana_credentials = os.path.join(fpath_root, fname_credentials)
    credentials = get_credentials(fpana_credentials)

    conn = psycopg2.connect(**credentials)
#    dsn = "host=localhost dbname=azerwis_local user=super_postgres"
#    conn = psycopg2.connect(dsn)
    cur = conn.cursor()

    query = """ select ts.id, ts.label
        from fews.timesteps ts
        where ts.timestepkey in %s
        """
    data = (make_tuple(timestepkeys),)
    product = False
    ts_dict = {}
    try:
        ts_list = executesqlfetch(query, data, cur)
        for item in ts_list:
            key = item[0]
            ts_dict[key] = Timestepkey(*item)

        logging.info("Selected %s rows for %s timestepkeys" %
                     (len(ts_list), len(data)))
        product = ts_dict
    except Exception as e:
        logging.info(e.message)

    finally:
        cur.close()
        conn.close()
        return product


def get_timeseries(locations, parameters, startdate, enddate):
    """SQL query to get timeseries from database, with credential file.
    Based on sets of locations and parameters, and start and end date."""
    import os
    import pandas as pd
    import psycopg2
    global logging
    import logging

    fpath_root = os.path.join(os.path.dirname(os.path.abspath(__file__)))

    fname_credentials = 'pgconnection.txt'
    fpana_credentials = os.path.join(fpath_root, fname_credentials)
    credentials = get_credentials(fpana_credentials)

    conn = psycopg2.connect(**credentials)
#    dsn = "host=localhost dbname=azerwis_local user=super_postgres"
#    conn = psycopg2.connect(dsn)
    cur = conn.cursor()

    query = """
            select t.datetime, t.scalarvalue, l.id, p.id, tk.timestepkey
            from fews.locations l
            join fews.timeserieskeys tk on tk.locationkey = l.locationkey
            join fews.parameterstable p on p.parameterkey = tk.parameterkey
            join fews.timeseriesvaluesandflags t on t.serieskey = tk.serieskey
            where l.id in %s
            and t.scalarvalue is not null
            and p.id in %s
            and to_char(datetime,'YYYYMMDD') BETWEEN %s and %s
            order by t.datetime
            """
    data = (make_tuple(locations), make_tuple(parameters), startdate, enddate)
    product = False
    try:
        df = pd.DataFrame(executesqlfetch(query, data, cur),
                          columns=["timestamp", "data_values",
                                   "location_id", "parameter_id",
                                   "timestepkey"])
        logging.info("Selected %s rows for %s locations" % (len(df),
                                                            len(locations)))
        product = df.set_index("timestamp")
    except Exception as e:
        logging.info(e.message)

    finally:
        cur.close()
        conn.close()
        return product


def create_df(df, locations, column):
    """Creates a dataframe with locations as columns and values are as
    specified in the column"""
    import pandas as pd
    ts = {}
    for ind, location in enumerate(locations):
        ts[location] = df[df.location_id == location]
        if ind == 0:
            df_out = pd.DataFrame(ts[location][column])
        else:
            df_out = pd.concat([df_out, ts[location][column]],
                               axis=1)
    if locations:
        df_out.columns = locations
    else:
        df_out = pd.DataFrame()
    return df_out


def check_timestep(df, unit_ui, multiplier_ui):
    import datetime
    import logging
    # Mapping is based on pandas.resample function
    # (http://pandas.pydata.org/pandas-docs/stable/timeseries.html
    # (search for Offset Aliases))
    ts_mapping = {"year": ["A", 31536000],
                  "month": ["M", 2628000],
                  "week": ["W", 604800],
                  "day": "D",
                  "daily": ["D", 86400],
                  "hour": "H",
                  "minute": "T",
                  "second": "S",
                  "nonequidistant": "NEQ"}

    timestepkeys = [str(item) for item in set(df["timestepkey"])]
    ts_dict = get_timesteps_names(timestepkeys)
    timesteps = {}
    for key, ts in ts_dict.items():
        if ts.ts_id == "NETS":
            msg = ("""Non equidistant timeseries found in database, user input
                   for timestep (%s, %s) is used.""" %
                   (multiplier_ui, unit_ui))
            logging.info(msg)
            unit = unit_ui
            multiplier = multiplier_ui
            timesteps["NETS"] = [multiplier, unit]

        elif ts.ts_id.startswith("SETS"):
            minutes = int(ts.ts_id.strip("SETS"))
            td = datetime.timedelta(minutes=minutes)

            _hulp1 = ts.ts_label.split(" ")
            timestep = _hulp1[-1]
            if timestep.endswith("s"):
                timestep = timestep[:-1]

            if len(_hulp1) > 1:
                unit = ts_mapping[timestep][0]
                multiplier = int(_hulp1[0])
            else:
                unit = "T"
                multiplier = minutes
            timesteps[td] = [multiplier, unit]

            # In principe gebruiken wat meegegeven is
            # Als die niet beschikbaar is dan de kleinste (met melding dat aggregatie plaatsvind) (moet kleiner zijn dan wat is gekozen)
            # Als er geen kleinere of gelijk aan is dan moet er iets anders gedaan worden (aangeven dat je een andere pakt) (mischien ook mmelden dat er geen data beschikbaar is)
        elif ts.ts_id.startswith("CTS"):
            _hulp1 = ts.ts_label.split(" ")
            timestep = _hulp1[-1]
            if timestep.endswith("s"):
                timestep = timestep[:-1]

            unit = ts_mapping[timestep][0]
            if len(_hulp1) > 1:
                multiplier = int(_hulp1[0])
            else:
                multiplier = 1

            if len(ts_mapping[timestep]) == 2:
                seconds = ts_mapping[timestep][-1] * multiplier
                td = datetime.timedelta(seconds=seconds)
            else:
                input_ts = timestep + "s"
                td = datetime.timedelta(**{input_ts: multiplier})
            timesteps[td] = [multiplier, unit]
            # Hier geldt hetzelfde als hierboven, dus gebruik wat meegegeven is, kleinste + aggregatie, no data (kleinste pakken)

    timedeltas = []
    for key, values in timesteps.items():
        if key != "NETS":
            timedeltas.append(key)
    if len(timedeltas) > 0:
        timestep = min(timedeltas)
        [multiplier, unit] = timesteps[timestep]

    if unit == unit_ui and multiplier == multiplier_ui:
        if len(timedeltas) > 0:
            return(unit, multiplier, False)
        else:
            return(unit, multiplier, True)
    else:
        for key, value in ts_mapping.items():
            if unit_ui in value:
                if len(value) == 2:
                    seconds = value[-1] * multiplier
                    td = datetime.timedelta(seconds=seconds)
                else:
                    input_ts = key + "s"
                    td = datetime.timedelta(**{input_ts: multiplier})
        if td > timesteps[timestep]:
            msg = """User input for timestep (%s, %s) varies from the timestep
                     (%s, %s) found in the database. Using the user input and
                     aggregating where necessary.""" % (multiplier_ui, unit_ui,
                                                        multiplier, unit)
            logging.info(msg)
            return(unit_ui, multiplier_ui, False)
        else:
            msg = """User input for timestep (%s, %s) varies from the smallest
                     timestep (%s, %s) found in the database. Using the user
                     input and plotting values as dots""" % (multiplier_ui,
                                                             unit_ui,
                                                             multiplier,
                                                             unit)
            logging.info(msg)
            return(unit_ui, multiplier_ui, True)


def generate_output(df_dict, wps):
    """ Takes a df that was turned into a dictionary
    pd.to_dict, with orient = 'records'
    Checks the version of python that is running and generates an json-output
    for the wps"""

    import sys
    import json

    if sys.version_info.major == 2:
        import StringIO
        version = sys.version_info.major
    else:
        import io as mod_io
        version = sys.version_info.major

    if wps:
        if version == 2:
            f = StringIO.StringIO()
            json.dump(df_dict, f)
            product = f
        else:
            g = mod_io.BytesIO()
            json.dump(df_dict, g)
            product = g
    else:
        product = df_dict
    return product


def double_mass(parameter, locations_x, locations_y,
                startdate, enddate, timestep=1, interp_method=None, wps=True):
    """Calculates double mass curves"""
    import numpy as np
    global logging
    import logging

#    locations_x = eval(locations_x)
#    locations_y = eval(locations_y)
    locations_x = locations_x.split(",")
    locations_y = locations_y.split(",")
    locations = tuple(np.unique(np.array(locations_x + locations_y)))

    df = get_timeseries(locations, parameter, startdate, enddate)
    logging.info('timeseries imported')

    df['_cumsum'] = df.groupby(df.location_id).cumsum()

    # creates a new dataframe with n_loc columns, where n_loc is the number of
    # locations and the values in hte columns are the values for each location.
    df_cumsum = create_df(df, locations, '_cumsum')

    df_filled = gap_filling(df_cumsum, method=interp_method)

    # Splitting series into x and y locations is done after interpolation to
    # make sure the same amount of timesteps is available for each station.
    # This might go wrong in case there is a station that has no data for
    # that period. In that case the script will return no data at all.
    df_merged = averaging(df_filled, locations_x, locations_y)

    df_merged_dict = df_merged.to_dict(orient='records')
    io = generate_output(df_merged_dict, wps)
    return io


def residual_function(parameter, locations,
                      startdate, enddate, interp_method=None, wps=True):
    """Caluclates the residual curves"""
    import pandas as pd
    global logging
    import logging

    locations = eval(locations)

    df = get_timeseries(locations, parameter, startdate, enddate)
    logging.info('timeseries imported')

    df_dict = {}
    df_merged_dict = {}
    for ind, location in enumerate(locations):
        df_dict[location] = df[df.location_id == location]
        col_name = '_residual'
        df_dict[location]['data_values'] = gap_filling(
            df_dict[location]['data_values'], method=interp_method)

        df_dict[location][col_name] = calculate_residual(
            df_dict[location]['data_values'])

        df_timestamp = pd.Series(df_dict[location].index,
                                 df_dict[location].index)
        df_str_time = df_timestamp.dt.strftime('%Y%m%d')

        df_merged_dict[location] = pd.concat([df_str_time,
                                              df_dict[location][col_name]],
                                             axis=1).to_dict(orient='records')

    io = generate_output(df_merged_dict, wps)
    return io


def aggregate(parameter, locations, startdate, enddate, multiplier, unit,
              wps=True):
    """Caluclates the aggregate function"""
    import pandas as pd
    global logging
    import logging

    locations = eval(locations)
    freq = "%s%s" % (multiplier, unit)

    df = get_timeseries(locations, parameter, startdate, enddate)
    logging.info('timeseries imported')
    df_dict = {}
    df_merged_dict = {}
    for key, grp in df.groupby(df.location_id):
        logging.info('create new series for %s', key)
        df_dict[key] = aggregate_function(grp, freq)
        df_timestamp = pd.Series(df_dict[key].index,
                                 df_dict[key].index)
        df_str_time = df_timestamp.dt.strftime('%Y%m%d')

        df_merged_dict[key] = pd.concat([df_str_time,
                                         df_dict[key]['data_values']],
                                        axis=1).to_dict(orient='records')

    io = generate_output(df_merged_dict, wps)
    return io


def probability_density(parameter, locations, startdate, enddate, wps=True):
    """Caluclates the aggregate function"""
    import numpy as np
    import pandas as pd
    from scipy.stats.kde import gaussian_kde
    global logging
    import logging
#    import matplotlib.pyplot as plt

    locations = eval(locations)

    df = get_timeseries(locations, parameter, startdate, enddate)
    logging.info('timeseries imported')

    df_merged_dict = {}
    for key, grp in df.groupby(df.location_id):
        KDEpdf = gaussian_kde(grp.data_values)
        x_app = list(np.linspace(np.min(grp.data_values),
                                 np.max(grp.data_values),
                                 1000))
        df_new = pd.DataFrame(data={'x': x_app,
                                    'pdf': KDEpdf(x_app)},
                              index=x_app, columns=['x', 'pdf'])

        df_merged_dict[key] = df_new.to_dict(orient='records')
    io = generate_output(df_merged_dict, wps)
    return io


def data_availability(parameter, locations, startdate, enddate, timestep=1,
                      wps=True):
    import pandas as pd
    import numpy as np
    global logging
    import logging

    locations = eval(locations)
    freq = "%sD" % timestep
    df = get_timeseries(locations, parameter, startdate, enddate)
    logging.info('timeseries imported')

    df_grouped = df.groupby(df.location_id)

    dr = pd.date_range(startdate, enddate, freq=freq)
    dummy_val = np.array(np.zeros((len(dr), 1)))
    dummy_val[dummy_val == 0] = np.NaN
    df_complete = pd.DataFrame(dummy_val, index=dr).to_period(freq=freq)
    df_complete.columns = ['Dummy']
    columns = ['Dummy']

    i = 1

    df_merged_dict = {}
    for key, grp in df_grouped:
        new_series = grp.data_values.to_period(freq=freq)
        df_complete = pd.concat([df_complete, new_series], axis=1)
        columns.append(key)
        df_complete.columns = columns
        df_mask = df_complete[key].isnull()
        df_complete[key] = df_complete[key].where(df_mask, i)

        df_timestamp = pd.Series(df_complete.index,
                                 df_complete.index)
        df_str_time = df_timestamp.dt.strftime('%Y%m%d')

        df_merged_dict[key] = pd.concat([df_str_time,
                                         df_complete[key]],
                                        axis=1).to_dict(orient='records')
        i += 1

    df_complete.drop('Dummy', axis=1, inplace=True)
    io = generate_output(df_merged_dict, wps)
    return io


def RMSE(ar1, ar2):
    import numpy as np
    rootmse = np.sqrt(((ar1 - ar2) ** 2).mean())
    return rootmse


class timeseries:

    def __init__(self, input_array):
        self.array = input_array

    def overview(self):
        import numpy as np
        self.maximum = np.max(self.array)
        self.minimum = np.min(self.array)
        self.mean = np.nanmean(self.array)
        self.median = np.nanmedian(self.array)
        self.std = np.nanstd(self.array)
        self.variance = self.std ** 2
        no_finite = np.isfinite(self.array)
        no_nan = np.isnan(self.array)
        self.count_finite = 0
        for boo in no_finite:
            if boo:
                self.count_finite += 1
        self.count_nan = 0
        for boo in no_nan:
            if boo:
                self.count_nan += 1


def Nash_Suthcliffe(ar_sim, ar_obs):
    import numpy as np
    ar_obs_mean = np.nanmean(ar_obs)
    sv1 = np.sum((ar_obs - ar_sim) ** 2)
    sv2 = np.sum((ar_obs - ar_obs_mean) ** 2)
    NS_coef = 1 - sv1 / sv2

    return NS_coef


def Abs_Error(ar_sim, ar_obs):
    import numpy as np
    ar_error = ar_sim - ar_obs
    ar_error_abs = np.array(abs(item) for item in ar_error)
    abs_error = np.sum(ar_error_abs)

    return ar_error, ar_error_abs, abs_error


def outlier_identification(input_array):
    pass


class Location:
    def __init__(self, name, loc_id, x_coord, y_coord, crs="WGS84",
                 catchment_id=None):
        self.name = name
        self.loc_id = loc_id
        self.x_coord = x_coord
        self.y_coord = y_coord
        self.crs = crs
        self.catchment_id = catchment_id


def inverse_distance(df, location, b=2):
    import numpy as np
    diff_x = abs(df["x"] - location.x_coord)
    diff_y = abs(df["y"] - location.y_coord)
    distance = np.sqrt(diff_x**2 + diff_y**2)
    weight = 1 / (distance ** b)
    total_weight = weight.sum()
    real_weight = weight/total_weight
    value = (df["P"] * real_weight).sum()

    return value


def parse_locations(locations_json):
    import logging
    import json
    locations_dict = json.loads(locations_json)
    locations = locations_dict['attributes']['id']
    logging.info("locations_json: ", locations_json)
    logging.info("locations: ", locations)
    return [locations]


def create_q_h_data(a, b, e_x, e_y):
    import numpy as np
    import pandas as pd

    x = np.linspace(0, 5, 200)
    x2 = x + np.random.normal(0, e_x, 200)

    y = a * x ** b
    y2 = y + np.random.normal(0, e_y, len(x))

    df = pd.DataFrame(data={"h": x, "Q": y})
    df2 = pd.DataFrame(data={"h": x2, "Q": y2})
    return df, df2


def Q_h_relation(df):
    import matplotlib.pyplot as plt
    import scipy.optimize
    import numpy as np

    def funct(x, a, b):
        return a * x ** b

    error = False

    Q = np.array(df["Q"])
    indices = np.where(Q < 0)
    Q[indices] = 0
    h = np.array(df["h"])
    indices = np.where(h < 0)
    h[indices] = 0

    try:
        popt, pcov = scipy.optimize.curve_fit(funct, h, Q)
    except RuntimeError as re:
        print(re)
        error = True

    plt.figure()
    plt.plot(df["Q"], df["h"], "ro", alpha=0.4)
    x = df["h"]

    if not error:
        y = funct(x, popt[0], popt[1])
        plt.plot(y, x, 'b')
    plt.xlabel("Q m3/s")
    plt.show()
    return funct, h, Q, pcov, popt


if __name__ == '__main__':
    import logging
    logger = logging.getLogger('logger1')
    logger.setLevel(logging.DEBUG)
    location_set1 = 'M_AZ_002'
    location_set2 = 'M_AZ_001'
    locations = "['M_AZ_001']"
    parameter = 'P.obs'
    startdate = '20090101'
    enddate = '20100101'
    interp_method = None
    timestep = 5

    df, df2 = create_q_h_data(45, 2.03, 0.05, 5)
    funct, h, Q, pcov, popt = Q_h_relation(df2)


#    io = double_mass(parameter, location_set1, location_set2,
#                     startdate, enddate, interp_method)

#    io = residual_function(parameter, locations, startdate, enddate)

#    io = aggregate(parameter, locations, startdate, enddate, timestep)

#    io = data_availability(parameter, locations, startdate, enddate)

#    io = probability_density(parameter, locations, startdate, enddate)

    # TODO Over de manier waarop de data uiteindelijk wordt
    # TODO aangeleverd moet nog overlegd worden.

#    contents = io.getvalue()
#    logger.info(contents)