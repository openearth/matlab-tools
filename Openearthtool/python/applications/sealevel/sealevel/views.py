from pyramid.view import view_config
from pyramid.response import Response
from beaker.cache import cache_region

import matplotlib
matplotlib.use('Agg') # non window backend
import string
from rpy2.robjects import r
import pandas.rpy.common
import matplotlib.pyplot as plt

import json
import models
import io
import numpy as np
import pandas
MIMES = {"png": "image/png",
         "pdf": "application/pdf",
         "json": "application/json",
         "csv": "text/csv",
         "excel": 'application/vnd.ms-excel'}

def parse_bool(boolstr):
    if boolstr.lower() in {"yes", "y", "ok", "on", "true"}:
        return True
    return False
def get_params(request):
    """parse the request parameters"""
    params = {}

    # Expected parameters
    # sometimes strings are empty
    params["startyear"] = int(request.params.get("startyear", 1906) or 1906)
    params["endyear"] = int(request.params.get("endyear", 2012) or 2012)
    params["station"] = str(request.params.get("station", "DEN HELDER"))

    # Use model for now
    params["model"] = str(request.params.get("model", "linear"))

    params["polynomial"] = int(request.params.get("polynomial", 1) or 1)
    params["wind"] = int(parse_bool(request.params.get("wind", "")))
    params["nodal"] = int(parse_bool(request.params.get("nodal", "")))

    params["polynomial_loess"] = int(request.params.get("polynomial_loess", 1) or 1)
    params["span"] = float(request.params.get("span", 1) or 1)

    params["gia"] = int(parse_bool(request.params.get("gia", "")))
    params["ib"] = int(parse_bool(request.params.get("ib", "")))

    params["format"] = str(request.params.get("format", "json"))
    return params

@view_config(route_name='main', renderer="main.mak")
def main(request):
    # no dynamic content yet
    params = get_params(request)
    return params

@view_config(route_name="home")
def my_view(request):
    from pyramid.i18n import TranslationString
    ts = TranslationString('Add')
    _ = request.translate
    return Response(_("Welcome home"))

@view_config(route_name='map', renderer="map.mak")
def map(request):
    # no dynamic content yet
    params = get_params(request)
    return params

@view_config(route_name="rscript", renderer="model.mak")
def make_rscript(request):
    # parameters
    request.response.content_type = "text/plain"
    return get_params(request)

@view_config(route_name='description', renderer="description.mak")
def make_description(request):
    """plot annual means"""
    # observations
    annualdf = models.annual_means()

    # parameters
    params = get_params(request)
    #
    code = models.fill_r_template("model.mak", **params)
    objects = models.run_r_model(code)
    df, summary = objects
    df = pandas.rpy.common.convert_robj(df)
    return {"summary": summary, 'station': params['station']}



class CustomExcelWriter(pandas.ExcelWriter):
    """
    Class for writing DataFrame objects into excel sheets in memory

    Parameters
    ----------
    stream : io.BytesIO
    """
    def __init__(self, stream):
        """custom initialize, path is now a io.BytesIO"""
        self.use_xlsx = False
        import xlwt
        self.book = xlwt.Workbook()
        self.fm_datetime = xlwt.easyxf(
            num_format_str='YYYY-MM-DD HH:MM:SS')
        self.fm_date = xlwt.easyxf(num_format_str='YYYY-MM-DD')
        self.path = stream
        self.sheets = {}
        self.cur_sheet = None



@view_config(route_name='data')
def make_data(request):
    """return annual means as data"""
    # parameters
    params = get_params(request)

    code = models.fill_r_template("model.mak", **params)
    df, summary = models.run_r_model(code)
    df = pandas.rpy.common.convert_robj(df)

    mime = MIMES[params.get('format', 'json')]

    if params['format'] == 'excel':
        stream = io.BytesIO()
        excelwriter = CustomExcelWriter(stream)
        df.to_excel(excelwriter)
        excelwriter.save()
    elif params["format"] == "csv":
        stream = io.BytesIO()
        df.to_csv(stream)
    else:
        stream = io.StringIO(unicode(df.to_json(orient='records')))
    response = Response(
        stream.getvalue(),
        content_type=mime
    )
    if params['format'] == 'excel':
        response.content_disposition = 'attachment; filename="data.xls"'
    elif params['format'] == 'csv':
        response.content_disposition = 'attachment; filename="data.csv"'
    return response





@view_config(route_name='plot')
def make_plot(request):
    """plot annual means"""
    # parameters
    params = get_params(request)


    code = models.fill_r_template("model.mak", **params)
    df, summary = models.run_r_model(code)
    df = pandas.rpy.common.convert_robj(df)
    format = request.params.get("format", "png")
    mime = MIMES.get(format, "image/png")
    stream = io.BytesIO()
    fig, ax = plt.subplots(figsize=(8,6), dpi=100)
    ax.set_title(params["station"])
    if request.params.get("observed"):
        ax.plot(df.year, df.waterlevel, label='observed')
    if request.params.get("fit"):
        ax.plot(df.year, df.predicted, label='fitted')
    if request.params.get("confidence"):
        ax.fill_between(np.array(df.year),
                        y1=np.array(df['confidence.lwr']),
                        y2=np.array(df['confidence.upr']),
                        alpha=0.3, label="confidence")
    if request.params.get("prediction"):
        ax.fill_between(np.array(df.year),
                        y1=np.array(df['prediction.lwr']),
                        y2=np.array(df['prediction.upr']),
                        alpha=0.1, label="prediction")
    ax.legend(loc="best")
    ax.set_xlabel("time [year]")
    ax.set_ylabel("water level [mm relative to revised local reference level]")
    ax.set_xlim(1800,2050)
    fig.savefig(stream, format=format, bbox_inches="tight")
    plt.close(fig)
    response = Response(
        stream.getvalue(),
        content_type=mime
    )
    return response
