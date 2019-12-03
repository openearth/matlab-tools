import logging
import requests
import json
from urllib.parse import urlparse
from owslib.wms import WebMapService
from owslib.wfs import WebFeatureService
from owslib.wmts import WebMapTileService
from urllib.parse import unquote, urlencode
from owslib.util import bind_url
from owslib.util import ServiceException
from shapely.geometry import shape
logging.basicConfig(level=logging.INFO)


failed_resp = {
    "errors": "This is a test messsage.",
    "layers": []
}

partly_resp = {
    "errors": "",
    "layers": [
        {
            "errors": "",
            "id": "WMS_img.nj.gov_natural2015",
            "name": "Natural2015",
            "tiles": "https://img.nj.gov/imagerywms/Natural2015?service=WMS&version=1.1.1&request=GetMap&layers=Natural2015&styles=&width=256&height=256&srs=EPSG:3857&bbox={bbox-epsg-3857}&format=image/png&transparent=TRUE&bgcolor=0xFFFFFF&exceptions=None"
        },
        {
            "errors": "EPSG-3857 CRS not supported.",
            "id": "ESRI_server.arcgisonline.com_world_imagery",
            "name": "World Imagery",
            "tiles": ""
        }
    ]
}

def wfs_area_parser(url, layer, area, field, srs=28992):
    """Parse WFS layer and return field in first intersecting feature with bbox."""
    try:
        wfs = WebFeatureService(url, version="2.0.0")
    except Exception as e:  # OWSLIB will fail hard on random urls as it expects at least parsable xml
        return {"errors": "Can't parse url as WFS service.", "value": None}

    geom = shape(area.get("geometry", {}))
    point = geom.centroid
    bbox = [point.x, point.y, point.x, point.y]

    response = wfs.getfeature(typename=layer, bbox=bbox, outputFormat="application/json")
    featurecollection = json.loads(response.read())
    for feature in featurecollection.get("features", []):
        if field in feature.get("properties", {}):
            return {"errors": "", "value": feature["properties"][field]}

    return {"errors": "Field not found", "value": None}


def esri_url_parser(url):

    wmts = False
    arcrest = False

    layers_wmts = wmts_layers(url + "/WMTS")
    if len(layers_wmts.get("errors", "")) == 0:
        wmts = True

    if not wmts:
        arcrest_layers = arcgis_exporttiles_layers(url)
        if len(arcrest_layers.get("errors", "")) == 0:
            arcrest = True

    if wmts:
        return layers_wmts
    elif arcrest:
        return arcrest_layers
    else:
        return {"errors": "Couldn't parse url.", "layers": []}


def layerurl(url, type="MOCK"):
    if type == "WMS":
        return wms_layers(url)
    elif type == "WMTS":
        return wmts_layers(url)
    elif type == "ESRI":
        return esri_url_parser(url)
    elif type == "MOCK":
        wms = wms_layers("https://img.nj.gov/imagerywms/Natural2015?")
        wmts = wmts_layers(
            "https://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/WMTS")
        # wmts2 = wmts_layers("https://tiles.arcgis.com/tiles/nSZVuSZjHpEZZbRo/arcgis/rest/services/Waterdiepte_bij_intense_neerslag_1_per_1000_jaar/MapServer", rest=False)
        arcrest = arcgis_exporttiles_layers(
            "https://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/")

        wms["layers"].extend(wmts["layers"])
        # wms["layers"].extend(wmts2["layers"])
        wms["layers"].extend(arcrest["layers"])

        return {"errors": "", "layers": wms["layers"]}
    elif type == "MOCK2":
        return failed_resp
    elif type == "MOCK3":
        return partly_resp
    else:
        return {"errors": "Unknown type"}


# WMS example
# https://img.nj.gov/imagerywms/Natural2015?bbox={bbox-epsg-3857}&format=image/png&service=WMS&version=1.1.1&request=GetMap&srs=EPSG:3857&transparent=true&width=256&height=256&layers=Natural2015
def wms_layers(url):
    """Retrieve layers from WMS url."""

    try:
        wms = WebMapService(url, version="1.1.1")
    except Exception as e:  # OWSLIB will fail hard on random urls as it expects at least parsable xml
        return {"errors": "Can't parse url as WMS service.", "layers": []}

    layers = []
    messages = ""
    domain = urlparse(url).netloc.split(":")[0]

    for layer in list(wms.contents):

        id = "WMS_{}_{}".format(domain, layer.lower().replace(" ", "_"))

        if 'EPSG:3857' in wms[layer].crsOptions:
            layer_url = wms._WebMapService_1_1_1__build_getmap_request(
                layers=[layer], bgcolor='#FFFFFF', bbox=[], srs="EPSG:3857", size=(256, 256), format="image/png", transparent=True)
            layer_url = bind_url(url) + unquote(urlencode(layer_url))
            layer_url = layer_url.replace("bbox=", "bbox={bbox-epsg-3857}")
            layers.append({"errors": "", "id": id, "name": layer, "tiles": layer_url})

        else:
            logging.warning("Layer {layer} has the wrong CRS.".format(layer=layer))
            layers.append({"errors": "EPSG-3857 CRS not supported.",
                           "id": id, "name": layer, "tiles": []})

    return {"errors": messages, "layers": layers}


accepted_names = ["3857", "GoogleMapsCompatible"]


def filter_tilematrix_crs(tilematrixsetlinks):
    def check_name(tilematrix):
        return any(name in tilematrix for name in accepted_names)

    tilematrices = [tilematrix for tilematrix in tilematrixsetlinks if check_name(tilematrix)]
    return tilematrices


# WMTS example
# https://www.wmts.nrw.de/geobasis/wmts_nw_dop20/tiles/nw_dop20/EPSG_3857_16/{z}/{x}/{y}.jpeg
def wmts_layers(url, rest=True):
    """Retrieve layers from WMS url."""
    try:
        wmts = WebMapTileService(url, version="1.0.0")
    except Exception as e:  # OWSLIB will fail hard on random urls as it expects at least parsable xml
        return {"errors": "Can't parse url as WMTS service.", "layers": []}

    layers = []
    messages = ""
    domain = urlparse(url).netloc.split(":")[0]

    for layer in list(wmts.contents):
        id = "WMTS_{}_{}".format(domain, layer.lower().replace(" ", "_"))

        matrixsets = []
        for matrix in wmts[layer].tilematrixsetlinks:
            crs = wmts.tilematrixsets[matrix].crs
            if crs is not None and "3857" in wmts.tilematrixsets[matrix].crs:
                matrixsets.append(matrix)

        # matrixsets = filter_tilematrix_crs(wmts[layer].tilematrixsetlinks)
        if len(matrixsets) == 0:
            layers.append({"errors": "EPSG-3857 CRS not supported.",
                           "id": id, "name": layer, "tiles": layer_url})
            continue

        # Rest based URL
        if wmts.restonly or rest:
            logging.info("Rest only layer.")
            layer_url = wmts.buildTileResource(
                layer=layer, tilematrixset=matrixsets[0], tilematrix="{z}", row="{y}", column="{x}")
        else:
            layer_url_data = wmts.buildTileRequest(
                layer=layer, tilematrixset=matrixsets[0], tilematrix="{z}", row="{y}", column="{x}")
            layer_url = bind_url(url) + unquote(layer_url_data)

        layers.append({"errors": "", "id": id, "name": layer, "tiles": layer_url})

    return {"errors": messages, "layers": layers}


# ExportMap ArcGIS
# https://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/
#   export?bbox={bbox-epsg-3857}&bboxSR=EPSG%3A3857&layers=&size=256,256&imageSR=EPSG%3A3857&format=png&transparent=true&dpi=&f=image
def arcgis_exporttiles_layers(url):
    """Retrieve layers from WMS url."""
    template = "export?bbox={{bbox-epsg-3857}}&bboxSR=EPSG%3A3857&layers=show:{}&size=256,256&imageSR=EPSG%3A3857&format=png&transparent=true&dpi=&f=image"
    try:
        mapserver = requests.get(url + "?f=pjson").json()
    except Exception as e:
        return {"errors": "Can't parse url as ARCGIS export tiles service.", "layers": []}

    layers = []
    messages = ""
    domain = urlparse(url).netloc.split(":")[0]

    validsrs = False
    for (k, v) in mapserver.get("spatialReference", {}).items():
        if "wkid" in k and v == 3857:
            validsrs = True
            break

    for layer in mapserver.get("layers", []):
        layer_url = url + unquote(template.format(layer["id"]))
        id = "ESRI_{}_{}".format(domain, layer["name"].lower().replace(" ", "_").replace(" ", "_"))
        if validsrs:
            layers.append({"errors": "", "id": id, "name": layer["name"], "tiles": layer_url})
        else:
            layers.append({"errors": "EPSG-3857 CRS not supported.", "id": id, "name": layer["name"], "tiles": ""})

    return {"errors": messages, "layers": layers}


if __name__ == "__main__":
    url = "https://img.nj.gov/imagerywms/Natural2015?"
    # wms_layers(url)

    url = "https://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/WMTS"
    url = "https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/WMTS"
    # url = "https://tiles.arcgis.com/tiles/nSZVuSZjHpEZZbRo/arcgis/rest/services/Waterdiepte_bij_intense_neerslag_1_per_1000_jaar/MapServer/WMTS"
    # print(wmts_layers(url))

    url = "https://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/"
    # arcgis_exporttiles_layers(url)

    layers = layerurl("", "MOCK")["layers"]
    for layer in layers:
        print(layer)
