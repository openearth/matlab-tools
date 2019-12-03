"""
Visualization for OSM validation (bokeh app)
"""
import sys, os
import logging

from bokeh.io import curdoc
from bokeh.layouts import layout, widgetbox
from bokeh.models.widgets import RadioGroup, Button
from bokeh.models import ColumnDataSource, CustomJS, Range1d

import numpy as np
import dashboard
sys.path.append(r'.')
import check_data_model as utils

# java stuff
import StringIO
import base64


def file_callback(attr,old,new):
    print 'filename:', os.path.abspath(file_source.data['file_name'][0])
    raw_contents = file_source.data['file_contents'][0]

    # options, logger, ch = utils.create_options()  # TODO connect the file from the button instead of the input argument
    logger = logging
    options = lambda: None  # create empty object
    # remove the prefix that JS adds
    prefix, b64_contents = raw_contents.split(",", 1)
    file_contents = base64.b64decode(b64_contents)
    file_io = StringIO.StringIO(file_contents)
    options.inifile = file_io
    options.dest_path = os.path.abspath('.')
    options.osm_download = True
    options.prefix = 'bokeh_'
    options = utils.add_ini(options, logger=logger)
    p.title.text = 'Data is being loaded and processed, please wait....'
    ## OSM DOWNLOAD
    if options.osm_download:
        utils.get_osm_data(options, logger=logger)

    if options.bounds:
        bbox = utils.create_bounds(options, logger=logger)
    else:
        bbox = None

    highways, waterways, crossings = utils.get_crossings_check(options, bbox, logger=logger)
    df_crossings = dashboard.make_point_df_WMTS(crossings)
    df_highway = dashboard.make_line_df_WMTS(highways)
    df_waterway = dashboard.make_line_df_WMTS(waterways)
    x = df_crossings['x']
    y = df_crossings['y']
    extent = (np.min(x), np.max(x), np.min(y), np.max(y))
    set_aspect(extent, margin=0.1)
    update_data(df_crossings, df_waterway, df_highway)
    # update_extent(extent)
    # p.title.text = 'All data is loaded and processed'


def set_aspect(extent, aspect=1, margin=0.1):
    """Set the plot ranges to achieve a given aspect ratio.
    Adapted from https://stackoverflow.com/questions/26674779/bokeh-plot-with-equal-axes

    Args:
      fig (bokeh Figure): The figure object to modify.
      x (iterable): The x-coordinates of the displayed data.
      y (iterable): The y-coordinates of the displayed data.
      aspect (float, optional): The desired aspect ratio. Defaults to 1.
        Values larger than 1 mean the plot is squeezed horizontally.
      margin (float, optional): The margin to add for glyphs (as a fraction
        of the total plot range). Defaults to 0.1
    """
    xmin, xmax, ymin, ymax = extent
    width = (xmax - xmin) * (1 + 2 * margin)
    if width <= 0:
        width = 1.0
    height = (ymax - ymin) * (1 + 2 * margin)
    if height <= 0:
        height = 1.0
    xcenter = 0.5 * (xmax + xmin)
    ycenter = 0.5 * (ymax + ymin)
    r = aspect * (p.plot_width / p.plot_height)
    if width < r * height:
        width = r * height
    else:
        height = width / r
    # p.x_range = Range1d(xcenter - 0.5 * width, xcenter + 0.5 * width)
    # p.y_range = Range1d(ycenter - 0.5 * height, ycenter + 0.5 * height)


    p.x_range.start = xcenter - 0.5 * width
    p.x_range.end = xcenter + 0.5 * width
    p.y_range.start = ycenter - 0.5 * height
    p.y_range.end = ycenter + 0.5 * height


# def update_extent(extent):
#     xmin, xmax, ymin, ymax = extent
#     p.x_range.start = xmin
#     p.x_range.end = xmax
#     p.y_range.start = ymin
#     p.y_range.end = ymax



def update_background():
    print('Active layer is {:d}'.format(radio_group.active))
    for n, w in enumerate(wms):
        if n == radio_group.active:
            w.visible = True
        else:
            w.visible = False
    print('Layer 1 is {:s}'.format(str(wms[0].visible)))
    print('Layer 2 is {:s}'.format(str(wms[1].visible)))


def update_data(df_crossings, df_waterway, df_highway):
    psource.data = df_crossings
    lsource_waterway.data = df_waterway
    lsource_highway.data = df_highway
    print psource.to_df().keys()
    map_hover.tooltips = [(key, '@{:s}'.format(key)) for key in psource.to_df().keys() if key not in ['x', 'y']]
    # set extent to right extent

def radio_group_change(attrname, old, new):
    update_background()

file_source = ColumnDataSource({'file_contents':[], 'file_name':[]})

file_source.on_change('data', file_callback)

button = Button(label="Select .ini", button_type="success")
button.callback = CustomJS(args=dict(file_source=file_source), code = """
function read_file(filename) {
    var reader = new FileReader();
    reader.onload = load_handler;
    reader.onerror = error_handler;
    // readAsDataURL represents the file's data as a base64 encoded string
    reader.readAsDataURL(filename);
}

function load_handler(event) {
    var b64string = event.target.result;
    file_source.data = {'file_contents' : [b64string], 'file_name':[input.files[0].name]};
    file_source.trigger("change");
}

function error_handler(evt) {
    if(evt.target.error.name == "NotReadableError") {
        alert("Can't read file!");
    }
}

var input = document.createElement('input');
input.setAttribute('type', 'file');
input.onchange = function(){
    if (window.FileReader) {
        read_file(input.files[0]);
    } else {
        alert('FileReader is not supported in this browser');
    }
}
input.click();
""")

# read data and process

# options, logger, ch = utils.create_options()


# ## OSM DOWNLOAD
# if options.osm_download:
#     utils.get_osm_data(options, logger=logger)
#
# if options.bounds:
#     bbox = utils.create_bounds(options, logger=logger)
# else:
#     bbox = None
#
# if options.check == 'crossings':
#     highways, waterways, crossings = utils.get_crossings_check(options, bbox, logger=logger)
#     df_crossings = dashboard.make_point_df_WMTS(crossings)
#     df_highway = dashboard.make_line_df_WMTS(highways)
#     df_waterway = dashboard.make_line_df_WMTS(waterways)
#     x = df_crossings['x']
#     y = df_crossings['y']
#     extent = (np.min(x), np.max(x), np.min(y), np.max(y))

# Initiate plot (p) using data fields
p, wms, url_names, map_hover, psource, lsource_highway, lsource_waterway = dashboard.init_dashboard((),
                         urls='http://b.tiles.mapbox.com/v3/worldbank-education.pebkgmlc/{z}/{x}/{y}.png',
                         url_names='Dar drone data', attributions='')

# Widgets and callbacks
radio_group = RadioGroup(
    labels=url_names, active=0)
radio_group.on_change('active', radio_group_change)

# update_data()
# initiate updates
update_background()

# add to curdoc
controls = widgetbox(radio_group, button)
sizing_mode = 'fixed'
l = layout([[p, controls]], sizing_mode=sizing_mode)

curdoc().add_root(l)
curdoc().title = 'OSM crossing check'
