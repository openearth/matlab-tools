#!/usr/bin/env python3
import flask
from flask_cors import CORS
import pywps
import os

# RI2DE
from pywps.app.Service import Service
from processes.wps_ri2de_roads import WpsRi2deRoads
from processes.wps_ri2de_calc import WpsRi2deCalc
from processes.wps_ri2de_slope import WpsRi2deSlope
#from processes.wps_ri2de_hand import WpsRi2deHand
from processes.wps_ri2de_landuse import WpsRi2deLandUse
from processes.wps_ri2de_init import WpsRi2deInit
from processes.wps_ri2de_susceptibilities import WpsRi2deSusceptibilities
from processes.wps_ri2de_culvert import WpsRi2deCulvert
from processes.wps_ri2de_water import WpsRi2deWater
from processes.wps_ri2de_custom import WpsRi2deCustom
from processes.wps_ri2de_soil import WpsRi2deSoil
from processes.wps_ri2de_risk import WpsRi2deRisk
from processes.wps_ri2de_csw import WpsGetRecordsUrl
#from processes.wps_ri2de_wave import WpsRi2deWave

# RA2CE
from processes.ra2ce_calc_ratio import WpsRa2ceRatio

# RI2DE processes
processes = [
    WpsRi2deRoads(), WpsRi2deInit(), WpsRi2deCalc(), WpsRi2deSlope(), WpsRi2deLandUse(), WpsRi2deCulvert(), WpsRi2deWater(), WpsRi2deCustom(), WpsRi2deSoil(), WpsRi2deRisk(),
    WpsRa2ceRatio(), WpsGetRecordsUrl(),WpsRi2deSusceptibilities()
]

# Description used in template
process_descriptor = {}
for process in processes:
    abstract = process.abstract
    identifier = process.identifier
    process_descriptor[identifier] = abstract

service = Service(processes, ['pywps.cfg'])
application = flask.Flask(__name__)
# only on localhost: CORS(application)

@application.route("/")
def hello():
    server_url = pywps.configuration.get_config_value("server", "url")
    request_url = flask.request.url
    return flask.render_template('index.html', request_url=request_url,
                                 server_url=server_url,
                                 title="Example service",
                                 process_descriptor=process_descriptor)

@application.route('/wps', methods=['GET', 'POST'])
def wps():
    return service

@application.route('/outputs/'+'<path:filename>')
def outputfile(filename):
    targetfile = os.path.join('outputs', filename)
    if os.path.isfile(targetfile):
        file_ext = os.path.splitext(targetfile)[1]
        with open(targetfile, mode='rb') as f:
            file_bytes = f.read()
        mime_type = None
        if 'xml' in file_ext:
            mime_type = 'text/xml'
        return flask.Response(file_bytes, content_type=mime_type)
    else:
        flask.abort(404)

@application.route('/static/'+'<path:filename>')
def staticfile(filename):
    targetfile = os.path.join('static', filename)
    if os.path.isfile(targetfile):
        with open(targetfile, mode='rb') as f:
            file_bytes = f.read()
        mime_type = None
        return flask.Response(file_bytes, content_type=mime_type)
    else:
        flask.abort(404)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="""Script for starting an example PyWPS
                       instance with sample processes""",
        epilog="""Do not use this service in a production environment.
         It's intended to be running in test environment only!
        For more documentation, visit http://pywps.org/doc
        """
        )
    parser.add_argument('-d', '--daemon',
                        action='store_true', help="run in daemon mode")
    parser.add_argument('-a','--all-addresses',
                        action='store_true', help="run flask using IPv4 0.0.0.0 (all network interfaces),"  +
                            "otherwise bind to 127.0.0.1 (localhost).  This maybe necessary in systems that only run Flask")
    args = parser.parse_args()

    if args.all_addresses:
        bind_host='0.0.0.0'
    else:
        bind_host='127.0.0.1'

    if args.daemon:
        pid = None
        try:
            pid = os.fork()
        except OSError as e:
            raise Exception("%s [%d]" % (e.strerror, e.errno))

        if (pid == 0):
            os.setsid()
            application.run(threaded=True,host=bind_host)
        else:
            os._exit(0)
    else:
        application.run(threaded=True,host=bind_host)
