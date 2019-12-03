from bokeh.plotting import figure, show
from bokeh.models.tiles import WMTSTileSource
from bokeh.io import output_notebook, push_notebook
from pyproj import Proj, transform
from bokeh.models import ColumnDataSource, HoverTool, Div, ColorBar, LinearColorMapper, TapTool, CustomJS
from bokeh.palettes import Category10

colors = [Category10[3][-1], Category10[3][-2]]
color_mapper = LinearColorMapper(low=0, high=1, palette=colors)

def make_point_df_WMTS(point_feats):
    outProj = Proj(init='epsg:3857')
    inProj = Proj(init='epsg:4326')
    df = {}
    df['x'], df['y'] = zip(*[transform(inProj, outProj, c['geometry'].xy[0][0], c['geometry'].xy[1][0]) for c in point_feats])
    for key in point_feats[0]['properties'].keys():
        df[key] = [c['properties'][key] for c in point_feats]
    return df

def make_line_df_WMTS(line_feats):
    outProj = Proj(init='epsg:3857')
    inProj = Proj(init='epsg:4326')
    df = {}
    df['x'], df['y'] = zip(*[transform(inProj, outProj, c['geometry'].xy[0].tolist(), c['geometry'].xy[1].tolist()) for c in line_feats])
    for key in line_feats[0]['properties'].keys():
        df[key] = [c['properties'][key] for c in line_feats]
    return df


def init_dashboard(extent, urls=None, url_names=None, attributions=None):
    # make an empty data frame for lines and points
    psource = ColumnDataSource(dict(x=[], y=[], flag=[], osm_id_waterway=[], osm_id_highway=[], structure=[]))
    lsource_highway = ColumnDataSource(dict(x=[], y=[]))
    lsource_waterway = ColumnDataSource(dict(x=[], y=[]))

    url_osm='http://c.tile.openstreetmap.org/{z}/{x}/{y}.png'  # this we always want
    attribution_osm = (
                       'Map tiles by <a href="http://stamen.com">Stamen Design</a>, '
                       'under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>.'
                       'Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, '
                       'under <a href="http://www.openstreetmap.org/copyright">ODbL</a>'
                       )
    name_osm = 'OpenStreetMap'
    # attribution=
    if isinstance(urls, str):
        urls = [urls]
        attributions = [attributions]
        url_names = [url_names]
    if urls:
        urls.append(url_osm)
        attributions.append(attribution_osm)
        url_names.append(name_osm)

    bkg_tiles = []
    wms = []

    basic_tools = 'pan,wheel_zoom,box_zoom,reset'
    # start with empty tooltips

    p = figure(x_range=(-20000000, 20000000), y_range=(-8400000, 8400000), plot_height=550, plot_width=900, tools=basic_tools, title='Crossings check dashboard', webgl=True, lod_threshold=100, lod_factor=10)  # x_range=(xmin, xmax), y_range=(ymin, ymax),
    p.axis.visible = False
    for url, attribution in reversed(zip(urls, attributions)):
        bkg_tile = WMTSTileSource(url=url,
                                  attribution=attribution
                                  )
        wms.append(p.add_tile(bkg_tile))
    p.multi_line(xs='x', ys='y', color='white', alpha=0.5, line_width=4., source=lsource_waterway)
    p.multi_line(xs='x', ys='y', color='white', alpha=0.5, line_width=4., source=lsource_highway)
    p.multi_line(xs='x', ys='y', color='#6699cc', alpha=0.5, line_width=2., source=lsource_waterway)
    p.multi_line(xs='x', ys='y', color='#ffcc33', alpha=0.5, line_width=2., source=lsource_highway)
    p.scatter(x='x', y='y', fill_color={'field': 'flag', 'transform': color_mapper}, line_color='white', name='crossings', source=psource, alpha=1., size=10)
    tooltips = []
    # tooltips=[
    #         (key, '@{:s}'.format(key)) for key in psource.to_df().keys() if key not in ['x', 'y']
    #     ]
    map_hover = HoverTool(tooltips=tooltips, names=['crossings'])

    color_bar = ColorBar(orientation='horizontal', color_mapper=color_mapper, height=10, width=150, location=(80, 100))
    p.add_layout(color_bar)
    p.add_tools(map_hover)
    return p, wms, url_names, map_hover, psource, lsource_highway, lsource_waterway
