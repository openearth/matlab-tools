# coding: utf-8
import os, configparser, logging

from gdal import ogr
from collections import OrderedDict
from reader_sobek3.Sobek3Model import Sobek3Model

class Sobek3Reader:
    """Reads all Sobek3 input files"""

    dir_path = ''
    input_dir = ''
    grid_file = ''

    def read_all(self, input_file):   # path directory files
        logger = logging.getLogger('sobek3Reader')
        logger.info('Reading Sobek files')
        self.input_dir = os.path.dirname(input_file)

        model = Sobek3Model()
        model.runid = os.path.splitext(os.path.basename(input_file))[0]

        # Convert md1d file to ini file with unique section names
        tmp_md1d = os.path.join(self.input_dir, "TMPmd1d.ini")
        self.prepare_inifile(input_file, tmp_md1d, model.md1d_sections)
        model.md1d_config = configparser.ConfigParser()
        model.md1d_config.read(tmp_md1d)
        os.remove(tmp_md1d)

        model.file_names["network"]           = os.path.join(self.input_dir, model.md1d_config["Files1"]["networkFile"])
        model.file_names["bound_loc"]         = os.path.join(self.input_dir, model.md1d_config["Files1"]["boundLocFile"])
        model.file_names["bound_def"]         = os.path.join(self.input_dir, model.md1d_config["Files1"]["boundCondFile"])
        model.file_names["cross_loc"]         = os.path.join(self.input_dir, model.md1d_config["Files1"]["crossLocFile"])
        model.file_names["cross_def"]         = os.path.join(self.input_dir, model.md1d_config["Files1"]["crossDefFile"])
        model.file_names["roughness"]         = os.path.join(self.input_dir, model.md1d_config["Files1"]["roughnessFile"])
        model.file_names["structure"]         = os.path.join(self.input_dir, model.md1d_config["Files1"]["structureFile"])
        model.file_names["observationpoints"] = os.path.join(self.input_dir, model.md1d_config["Files1"]["obsPointsFile"])
        model.file_names["observationcrosssections"] = ""
        if "initialWaterLevelFile" in model.md1d_config["Files1"] and str(model.md1d_config["Files1"]["initialWaterLevelFile"]).strip() != "":
            model.file_names["iniwaterlevel"]     = os.path.join(self.input_dir, model.md1d_config["Files1"]["initialWaterLevelFile"])
        if "initialWaterDepthFile" in model.md1d_config["Files1"] and str(model.md1d_config["Files1"]["initialWaterDepthFile"]).strip() != "":
            model.file_names["iniwaterdepth"]     = os.path.join(self.input_dir, model.md1d_config["Files1"]["initialWaterDepthFile"])
        if "initialDischargeFile" in model.md1d_config["Files1"] and str(model.md1d_config["Files1"]["initialDischargeFile"]).strip() != "":
            model.file_names["inidischarge"]      = os.path.join(self.input_dir, model.md1d_config["Files1"]["initialDischargeFile"])
        if "initialSalinityFile" in model.md1d_config["Files1"] and str(model.md1d_config["Files1"]["initialSalinityFile"]).strip() != "":
            model.file_names["inisalinity"]       = os.path.join(self.input_dir, model.md1d_config["Files1"]["initialSalinityFile"])
        if "initialTemperatureFile" in model.md1d_config["Files1"] and str(model.md1d_config["Files1"]["initialTemperatureFile"]).strip() != "":
            model.file_names["initemperature"]    = os.path.join(self.input_dir, model.md1d_config["Files1"]["initialTemperatureFile"])

        # Convert network file to ini file with unique section names
        tmp_network = os.path.join(self.input_dir, "TMPnetwork.ini")
        self.prepare_inifile(model.file_names.get("network"), tmp_network, model.network_sections)
        model.network_config = configparser.ConfigParser()
        model.network_config.read(tmp_network)
        os.remove(tmp_network)

        # Convert BoundaryLocations file to ini file with unique section names
        tmp_bndloc = os.path.join(self.input_dir, "TMPBoundaryLocations.ini")
        self.prepare_inifile(model.file_names.get("bound_loc"), tmp_bndloc, model.bndloc_sections)
        model.bndloc_config = configparser.ConfigParser()
        model.bndloc_config.read(tmp_bndloc)
        os.remove(tmp_bndloc)

        model.nnodes    = model.network_sections["Node"]
        model.nbranches = model.network_sections["Branch"]
        if "Boundary" in model.bndloc_sections:
            model.nbounds   = model.bndloc_sections["Boundary"]
        else:
            model.nbounds   = 0
        logger.info("Number of Nodes     :" + str(model.nnodes))
        logger.info("Number of Branches  :" + str(model.nbranches))
        logger.info("Number of Boundaries:" + str(model.nbounds))

        return model

    def file_2_dict(self, file_path):
        dict=OrderedDict()
        ogr.UseExceptions()
        gml = ogr.Open(file_path)
        layer = gml.GetLayer()
        layer_definition = layer.GetLayerDefn()
        fields = []

        for i in range(layer_definition.GetFieldCount()):
            fields.append(layer_definition.GetFieldDefn(i).GetName())

        for feature in layer:
            f_data   = []
            f_id     = feature.GetField(fields[0])
            geometry = feature.GetGeometryRef()
            points   = geometry.GetPoints()
            f_data.append(points)

            if len(points) > 1:
                length = geometry.Length()
                f_data.append(length)
            else:
                f_data.append(0.0)

            for field in fields:
                f_data.append(feature.GetField(field))
            dict[f_id] = f_data

        return dict

    # Convert ini file to ini file with unique section names (by adding a counter)
    # and removing comments (starting with the character "#"
    def prepare_inifile(self, ini_file, tmp_file, sections):
        with open(ini_file, "r") as infilehandle:
            with open(tmp_file, "w") as outfilehandle:
                for line in infilehandle:
                    if line[0] == '[':
                        section = line[1:-2]
                        if section in sections:
                            sections[section] += 1
                        else:
                            sections[section] = 1
                        line = '[' + section + str(sections[section]) + ']\n'
                    startComments = line.find('#')
                    if startComments > -1:
                        line = line[:startComments] + '\n'
                    outfilehandle.write(line)
