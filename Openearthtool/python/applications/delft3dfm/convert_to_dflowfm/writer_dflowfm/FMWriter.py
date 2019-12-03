# coding: utf-8
import os, shutil, time, logging, re, numpy
from pathlib import Path
from collections import defaultdict
from writer_dflowfm.FMModel import FMModel
from writer_dflowfm.UgridWriter import UgridWriter


class FMWriter:
    """Writer for FM files"""

    def __init__(self, model = FMModel()):
        self.model = model

    def write_all(self, input_dir, output_dir, converter_version):  # write all fm input files
        logger = logging.getLogger('FMWriter')
        logger.info('Writing FM files')

        # mdu file
        src_mdu = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'resources', 'FMmdu.txt')
        target_mdu = os.path.join(output_dir, self.model.runid + '.mdu')
        self.write_from_template(src_mdu, target_mdu, converter_version)

        # dimr_config file
        src_mdu = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'resources', 'dimr_config.xml')
        target_mdu = os.path.join(output_dir, 'dimr_config.xml')
        self.write_from_template(src_mdu, target_mdu, converter_version)

        # run.bat script
        shutil.copy2(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'resources', 'run.bat'), os.path.join(output_dir, 'run.bat'))

        # Net file
        ugrid_writer = UgridWriter()
        ugrid_writer.write(output_dir, self.model.networkdata, self.model.griddata, self.model.runid, converter_version)

        # Ext file
        self.write_extfile(output_dir, converter_version)

        # Boundary conditions
        file_base_name = os.path.basename(self.model.file_names["bound_def"])
        source_file = os.path.join(input_dir, file_base_name)
        target_file = os.path.join(output_dir, file_base_name)
        self.copy_and_update_versionnr(source_file, target_file)

        # Crosssection locations
        file_base_name = os.path.basename(self.model.file_names["cross_loc"])
        source_file = os.path.join(input_dir, file_base_name)
        target_file = os.path.join(output_dir, file_base_name)
        self.copy_and_update_crosssection_locations(source_file, target_file)

        # Crosssection definitions
        file_base_name = os.path.basename(self.model.file_names["cross_def"])
        source_file = os.path.join(input_dir, file_base_name)
        target_file = os.path.join(output_dir, file_base_name)
        self.copy_and_update_crosssection_definitions(source_file, target_file)

        # Roughness
        file_base_name = os.path.basename(self.model.file_names["roughness"])
        for aRoughnessFile in file_base_name.split(';'):
            source_file = os.path.join(input_dir, aRoughnessFile)
            target_file = os.path.join(output_dir, aRoughnessFile)
            self.copy_and_update_roughness(source_file, target_file)

        # Structure
        file_base_name = os.path.basename(self.model.file_names["structure"])
        for aStructureFile in file_base_name.split(';'):
            source_file = os.path.join(input_dir, aStructureFile)
            target_file = os.path.join(output_dir, aStructureFile)
            self.copy_and_update_structure(source_file, target_file)

        # Observation points and cross sections
        file_base_name = os.path.basename(self.model.file_names["observationpoints"])
        obscrslist = []
        for aObsPntFile in file_base_name.split(';'):
            source_file = os.path.join(input_dir, aObsPntFile)
            target_file_pts = os.path.join(output_dir, aObsPntFile)

            start, ext = os.path.splitext(aObsPntFile)
            obscrsFile = start+'_crs'+ext
            obscrslist.append(obscrsFile)

            target_file_crs = os.path.join(output_dir, obscrsFile)
            self.copy_and_update_obspoints_and_obscrs(source_file, target_file_pts, target_file_crs)

        self.model.file_names["observationcrosssections"] = '; '.join(obscrslist)

        # Initial field files (waterlevel and waterdepth)
        if "InifieldFileInterpolate" in self.model.keyvalue: self.model.keyvalue.pop("InifieldFileInterpolate")
        if self.model.keyvalue["UseInitialWaterDepth"] == '1':
            if "iniwaterdepth" in self.model.file_names:
                file_base_name = os.path.basename(self.model.file_names["iniwaterdepth"])
                for aIniFile in file_base_name.split(';'):
                    dataFileName = aIniFile
                    source_file = os.path.join(input_dir, aIniFile)
                    target_file = os.path.join(output_dir, aIniFile)
                    self.copy_and_update_inifieldfile(source_file, target_file)
            else:
                dataFileName = "InitialWaterDepth.ini"
                self.create_minimum_inifielddatafile(output_dir, dataFileName)
        else:
            # useInitialWaterLevel
            if "iniwaterlevel" in self.model.file_names:
                file_base_name = os.path.basename(self.model.file_names["iniwaterlevel"])
                for aIniFile in file_base_name.split(';'):
                    dataFileName = aIniFile
                    source_file = os.path.join(input_dir, aIniFile)
                    target_file = os.path.join(output_dir, aIniFile)
                    self.copy_and_update_inifieldfile(source_file, target_file)
            else:
                dataFileName = "InitialWaterLevel.ini"
                self.create_minimum_inifielddatafile(output_dir, dataFileName)
        self.write_inifieldfile(output_dir, dataFileName)

        #
        # Can be removed?:
        # self.write_crosssection_definitions(output_dir)
        # self.write_crosssections(output_dir)

        return True

    # Write the mdu file
    # Use a template mdu file and replace some markers by real values
    def write_from_template(self, template_file, output_file, converter_version):

        with open(template_file, "r") as infilehandle:
            with open(output_file, "w") as outfilehandle:
                for line in infilehandle:
                    #
                    # DateTime
                    startpos = line.find('<DATETIME>')
                    if startpos > -1:
                        line = line[:startpos] + time.strftime("%Y-%m-%d %H:%M") + line[startpos+10:]
                    #
                    # Converter
                    startpos = line.find('<CONVERTERVERSION>')
                    if startpos > -1:
                        line = line[:startpos] + "Sobek3 To D-Flow FM converter, version " + converter_version + line[startpos+18:]
                    #
                    # Runid
                    startpos = line.find('<RUNID>')
                    if startpos > -1:
                        line = line[:startpos] + self.model.runid + line[startpos+7:]
                    #
                    # CROSSLOC
                    startpos = line.find('<CROSSLOC>')
                    if startpos > -1:
                        line = line[:startpos] + os.path.basename(self.model.file_names.get("cross_loc")) + line[startpos+10:]
                    #
                    # CROSSDEF
                    startpos = line.find('<CROSSDEF>')
                    if startpos > -1:
                        line = line[:startpos] + os.path.basename(self.model.file_names.get("cross_def")) + line[startpos+10:]
                    #
                    # ROUGHNESS
                    startpos = line.find('<ROUGHNESS>')
                    if startpos > -1:
                        line = line[:startpos] + os.path.basename(self.model.file_names.get("roughness")) + line[startpos+11:]
                    #
                    # STRUCTURES
                    startpos = line.find('<STRUCTS>')
                    if startpos > -1:
                        line = line[:startpos] + os.path.basename(self.model.file_names.get("structure")) + line[startpos+11:]
                    #
                    # OBSERVATION POINTS
                    startpos = line.find('<OBSPNTS>')
                    if startpos > -1:
                        line = line[:startpos] + os.path.basename(self.model.file_names.get("observationpoints")) + line[startpos+9:]
                    #
                    # OBSERVATION POINTS
                    startpos = line.find('<OBSCRS>')
                    if startpos > -1:
                        line = line[:startpos] + os.path.basename(self.model.file_names.get("observationcrosssections")) + line[startpos+9:]
                    #
                    # REFDATE
                    startpos = line.find('<REFDATE>')
                    if startpos > -1:
                        line = line[:startpos] + self.model.keyvalue.get("RefDate") + line[startpos+9:]
                    #
                    # DTUSER
                    startpos = line.find('<DTUSER>')
                    if startpos > -1:
                        line = line[:startpos] + self.model.keyvalue.get("DtUser") + line[startpos+8:]
                    #
                    # TSTOP
                    startpos = line.find('<TSTOP>')
                    if startpos > -1:
                        line = line[:startpos] + self.model.keyvalue.get("TStop") + line[startpos+8:]
                    #
                    # HISINTERVAL
                    startpos = line.find('<HISINTERVAL>')
                    if startpos > -1:
                        line = line[:startpos] + self.model.keyvalue.get("HisInterval") + line[startpos+13:]
                    #
                    # MAPINTERVAL
                    startpos = line.find('<MAPINTERVAL>')
                    if startpos > -1:
                        line = line[:startpos] + self.model.keyvalue.get("MapInterval") + line[startpos+13:]
                    #
                    # Initial waterlevel
                    startpos = line.find('<WLINIVAL>')
                    if startpos > -1:
                        line = line[:startpos] + "-999.0" + line[startpos+10:]


                    # And finally write the line
                    outfilehandle.write(line)

        return True




    # Write the ext file from scratch
    def write_extfile(self, output_dir, converter_version):
        extfile_name = os.path.join(output_dir, self.model.runid + '.ext')
        with open(extfile_name, "w") as outfilehandle:
            outfilehandle.write('[General]\n')
            outfilehandle.write('fileVersion = 2.00\n')
            outfilehandle.write('fileType    = extForce\n\n')
            for i in range(0, len(self.model.boundarydata["node_ids"])):
                outfilehandle.write('[boundary]\n')
                outfilehandle.write('quantity    = ' + self.model.boundarydata["types"][i] + '\n')
                outfilehandle.write('nodeId      = ' + self.model.boundarydata["node_ids"][i] + '\n')
                outfilehandle.write('forcingfile = ' + os.path.basename(self.model.file_names["bound_def"]) + '\n\n')
        return True




    # Create a new, minimum inifield data file from scratch
    def create_minimum_inifielddatafile(self, output_dir, filename):
        extfile_name = os.path.join(output_dir, filename)
        with open(extfile_name, "w") as outfilehandle:
            outfilehandle.write('[General]\n')
            outfilehandle.write('    fileVersion = 2.00\n')
            outfilehandle.write('    fileType    = 1dField\n\n')
            outfilehandle.write('[Global]\n')
            if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                outfilehandle.write('    quantity            = waterdepth\n')
            else:
                outfilehandle.write('    quantity            = waterlevel\n')
            outfilehandle.write('    unit                = m\n')
            if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                outfilehandle.write('    value            = ' + self.model.keyvalue.get("InitialWaterDepth") + '          # default value\n')
            else:
                outfilehandle.write('    value            = ' + self.model.keyvalue.get("InitialWaterLevel") + '          # default value\n')
        return True




    # Write the inifieldfile from scratch
    def write_inifieldfile(self, output_dir, datafilename):
        extfile_name = os.path.join(output_dir, "initialFields.ini")
        with open(extfile_name, "w") as outfilehandle:
            outfilehandle.write('[General]\n')
            outfilehandle.write('    fileVersion = 2.00\n')
            outfilehandle.write('    fileType    = iniField\n\n')
            outfilehandle.write('[Initial]\n')
            if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                outfilehandle.write('    quantity            = waterdepth\n')
            else:
                outfilehandle.write('    quantity            = waterlevel\n')
            outfilehandle.write('    dataFile            = ' + datafilename + '\n')
            outfilehandle.write('    dataFileType        = 1dField\n')
            if "InifieldFileInterpolate" in self.model.keyvalue:
                outfilehandle.write('    ' + self.model.keyvalue["InifieldFileInterpolate"] + '\n')
        return True




    # Copy an ini file, updating the version number
    def copy_and_update_versionnr(self, source_file, target_file):
        with open(source_file, "r") as infilehandle:
            with open(target_file, "w") as outfilehandle:
                section = " "
                majorVersion = -1
                minorVersion = -1
                for line in infilehandle:
                    #
                    # DateTime
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                    #
                    # majorVersion
                    indent = line.find('majorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        majorVersion = int(line[startpos+1:])
                    indent = line.find('minorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        minorVersion = int(line[startpos+1:]) + 1
                    if section == "General":
                        if majorVersion != -1 and minorVersion != -1:
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(startpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion != -1 or minorVersion != -1:
                                continue
                    #
                    # Replace SOBEK keywords by D-Flow FM keywords
                    startpos = line.find('water_level')
                    if startpos > -1:
                        line = line[:startpos] + "waterlevelbnd" + line[startpos+11:]

                    startpos = line.find('water_discharge')
                    if startpos > -1:
                        line = line[:startpos] + "dischargebnd" + line[startpos+15:]

                    startpos = line.find('[Boundary]')
                    if startpos > -1:
                        line = line[:startpos] + "[forcing]" + line[startpos+10:]

                    startpos = line.find('linear-extrapolate')
                    if startpos > -1:
                        line = line[:startpos] + "linear" + line[startpos+18:]

                    #startpos = line.find('time-interpolation')
                    #if startpos > -1:
                    #    line = line[:startpos] + "time interpolation" + line[startpos+18:]

                    outfilehandle.write(line)

        return True


    # Copy the roughness file, and update it
    def copy_and_update_roughness(self, source_file, target_file):
        logger = logging.getLogger('FMWriter')
        fmType = {'1':'Chezy', '4':'Manning', '5':'StricklerNikuradse', '6':'Strickler', '7':'WhiteColebrook', '9':'deBosBijkerk '}
        functionType = {'0':'constant', '1':'absDischarge', '2':'waterLevel'}
        branches = {}
        branch = {}
        branchId = ''
        stpos = 0
        with open(source_file, "r") as infilehandle:
            with open(target_file, "w") as outfilehandle:
                section = " "
                majorVersion = -1
                minorVersion = -1
                for line in infilehandle:
                    #
                    # DateTime
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                    #
                    # majorVersion
                    indent = line.find('majorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        majorVersion = int(line[startpos+1:])
                    indent = line.find('minorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        minorVersion = int(line[startpos+1:]) + 1
                    if section == "General":
                        if majorVersion != -1 and minorVersion != -1:
                            if majorVersion == 1:
                                # This script converts version 1.xx into 2.00
                                majorVersion = 3
                                minorVersion = 0
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(startpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion != -1 or minorVersion != -1:
                                continue
                    #

                    if section == 'Content':
                        startpos = line.find('[Content]')
                        if startpos > -1:
                            line = '[Global]\n'
                        #
                        startpos = line.find('sectionId')
                        if startpos > -1:
                            stpos = startpos
                            line  = line[:startpos] + "frictionId" + line[startpos+10:]
                            eqpos = line.find('=')
                            value = line[eqpos+1:].strip()
                            line  = line[:eqpos+1] + " #" + value + "#\n"
                        #
                        startpos = line.find('flowDirection')
                        if startpos > -1:
                            continue
                        #
                        startpos = line.find('interpolate')
                        if startpos > -1:
                            continue
                        #
                        startpos = line.find('globalType')
                        if startpos > -1:
                            eqpos = line.find('=')
                            sobekType = line[eqpos+1:].strip()
                            if sobekType in fmType:
                                line = line[:startpos] + "frictionType" + line[startpos+12:eqpos+2] + fmType[sobekType] + "\n"
                            else:
                                logger.error('Unknown value found in file "' + os.path.basename(source_file) + '":\n\t\t\t globalType = '+str(sobekType))
                                raise Exception

                        #
                        startpos = line.find('globalValue')
                        if startpos > -1:
                            line = line[:startpos] + "frictionValue" + line[startpos+13:]

                    if section == 'BranchProperties':
                        startpos = line.find('[BranchProperties]')
                        if startpos > -1:
                            continue
                        #
                        startpos = line.find('branchId')
                        if startpos > -1:
                            if not branchId == '':
                                branches[branchId] = branch
                                branch = {}
                            eqpos = line.find('=')
                            branchId = line[eqpos+1:].strip()
                        #
                        startpos = line.find('roughnessType')
                        if startpos > -1:
                            eqpos = line.find('=')
                            sobekType = line[eqpos+1:].strip()
                            if sobekType in fmType:
                                branch['frictionType'] = fmType[sobekType]
                            else:
                                logger.error('Unknown value found in file "' + os.path.basename(source_file) + '":\n\t\t\t roughnessType = '+str(sobekType))
                                raise Exception
                        #
                        startpos = line.find('functionType')
                        if startpos > -1:
                            eqpos = line.find('=')
                            sobekType = line[eqpos+1:].strip()
                            if sobekType in functionType:
                                branch['functionType'] = functionType[sobekType]
                            else:
                                logger.error('Unknown value found in file "' + os.path.basename(source_file) + '":\n\t\t\t functionType = '+str(sobekType))
                                raise Exception
                        #
                        startpos = line.find('numLevels')
                        if startpos > -1:
                            eqpos = line.find('=')
                            branch['numLevels'] = line[eqpos+1:].strip()
                        #
                        startpos = line.find('levels')
                        if startpos > -1:
                            eqpos = line.find('=')
                            branch['levels'] = line[eqpos+1:].strip()

                        continue

                    if section == 'Definition':

                        startpos = line.find('branchId')
                        if startpos > -1:
                            branches[branchId] = branch # save last BranchProperties or latest Definition 
                            eqpos    = line.find('=')
                            branchId = line[eqpos+1:].strip()
                            branch   = branches[branchId]
                            if not 'chainage' in branch:
                                branch['chainage'] = []
                                branch['values'] = []

                        startpos = line.find('chainage')
                        if startpos > -1:
                            eqpos = line.find('=')
                            branch['chainage'].append(line[eqpos+1:].strip())

                        startpos = line.find('value') # value or values
                        if startpos > -1:
                            eqpos = line.find('=')
                            branch['values'].append(line[eqpos+1:].strip().split(' '))

                        continue

                    outfilehandle.write(line)

                #save the last branch information to the branches dictionary
                if not branchId == '':
                    branches[branchId] = branch

                #save all Branch blocks
                for branchId,branch in branches.items():
                    newline = '[Branch]\n'
                    outfilehandle.write(newline)
                    #
                    newline  = 'branchId'.rjust(stpos+8, ' ')
                    newline  = newline.ljust(eqpos, ' ') + "= #" + branchId + "#\n"
                    outfilehandle.write(newline)
                    #
                    newline  = 'frictionType'.rjust(stpos+12, ' ')
                    newline  = newline.ljust(eqpos, ' ') + "= " + branch['frictionType'] + "\n"
                    outfilehandle.write(newline)
                    #
                    newline  = 'functionType'.rjust(stpos+12, ' ')
                    newline  = newline.ljust(eqpos, ' ') + "= " + branch['functionType'] + "\n"
                    outfilehandle.write(newline)
                    #
                    if 'numLevels' in branch:
                        newline  = 'numLevels'.rjust(stpos+9, ' ')
                        newline  = newline.ljust(eqpos, ' ') + "= " + branch['numLevels'] + "\n"
                        outfilehandle.write(newline)
                        #
                        newline  = 'levels'.rjust(stpos+6, ' ')
                        newline  = newline.ljust(eqpos, ' ') + "= " + branch['levels'] + "\n"
                        outfilehandle.write(newline)

                    newline  = 'numLocations'.rjust(stpos+12, ' ')
                    newline  = newline.ljust(eqpos, ' ') + "= " + str(len(branch['chainage'])) + "\n"
                    outfilehandle.write(newline)
                    #
                    newline  = 'chainage'.rjust(stpos+8, ' ')
                    chainagelist = ''
                    for ch in branch['chainage']:
                        chainagelist += ch + ' '
                    newline  = newline.ljust(eqpos, ' ') + "= " + chainagelist + "\n"
                    outfilehandle.write(newline)
                    #
                    first = True
                    for i in range(len(branch['values'][0])):
                        if first:
                            newline  = 'frictionValues'.rjust(stpos+14, ' ')
                            newline  = newline.ljust(eqpos, ' ') + "= "
                            first = False
                        else:
                            newline = ''.ljust(eqpos, ' ') + "  "
                        #
                        for j in range(len(branch['chainage'])):
                            newline += branch['values'][j][i] + ' '
                        outfilehandle.write(newline[:-1] + "\n")
                    #
                    outfilehandle.write('\n')
        return True


    # Copy the obspoints file, and update it into an observation points file for FM.
    # And also, copy the same file and update it into an observation crosssection file
    # Note, this function first collects all obspoints during reading, and
    # in a second loop subsequently write all of them as obspt/obscrs.
    def copy_and_update_obspoints_and_obscrs(self, source_file, target_file_pts, target_file_crs):
        obsPoints = {}
        obsPointEmpty = {'id':'', 'name':'', 'branchId':'', 'chainage':[]}
        obsPoint = obsPointEmpty.copy()
        obsId = ''

        with open(source_file, "r") as infilehandle:
            with open(target_file_pts, "w") as outfilehandlepts, open(target_file_crs, "w") as outfilehandlecrs:
                section = " "
                majorVersion = -1
                minorVersion = -1
                for line in infilehandle:
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                        newSection = True
                    else:
                        newSection = False


                    #
                    # majorVersion
                    indent = line.find('majorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        majorVersion = int(line[startpos+1:])
                    indent = line.find('minorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        minorVersion = int(line[startpos+1:]) + 1

                    if section == "General":
                        if majorVersion != -1 and minorVersion != -1:
                            if majorVersion == 1:
                                # This script converts version 1.xx into 2.00
                                majorVersion = 2
                                minorVersion = 0
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(startpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion != -1 or minorVersion != -1:
                                continue
                    #
                    # fileType, replace by obsCross
                    startpos = line.find('fileType')
                    if startpos > -1:
                        eqpos = line.find('=')
                        line  = line[:eqpos+1] + " obsPoint\n"
                        outfilehandlepts.write(line)
                        line  = line[:eqpos+1] + " obsCross\n"
                        outfilehandlecrs.write(line)
                        continue

                    if section == 'ObservationPoint':
                        # obsPoints will only be read and use a postponed write
                        # once all blocks have been read.
                        if newSection:
                            continue

                        #
                        # id
                        # Don't use str.find(), because 'id' could be in a 'branchid =' line.
                        match = re.search(r"\bid\b", line.lower())
                        if match:
                            eqpos    = line.find('=')
                            obsId = line[eqpos+1:].strip()
                            obsPoint['id'] = obsId
                            continue # postponed write

                        #
                        # name
                        startpos = line.lower().find('name')
                        if startpos > -1:
                            eqpos    = line.find('=')
                            obsPoint['name'] = line[eqpos+1:].strip()
                            continue # postponed write

                        #
                        # branchid
                        startpos = line.lower().find('branchid')
                        if startpos > -1:
                            eqpos    = line.find('=')
                            obsPoint['branchId'] = line[eqpos+1:].strip()
                            continue # postponed write

                        #
                        # chainage
                        startpos = line.lower().find('chainage')
                        if startpos > -1:
                            eqpos    = line.find('=')
                            obsPoint['chainage'] = line[eqpos+1:].strip()
                            continue # postponed write

                        #
                        # If all fields of current ObservationPoint have been read,
                        # store it in the obsPoints set, for postponed write.
                        if obsPoint['id'] != '' and obsPoint['branchId'] != '' and obsPoint['chainage'] != []:
                            obsPoints[obsId] = obsPoint
                            obsPoint = obsPointEmpty.copy()

                    if line and not line.isspace():
                        outfilehandlepts.write(line)
                        outfilehandlecrs.write(line)


                # Separate header from [ObservationPoint] and [ObservationCrossSection] blocks.
                outfilehandlepts.write('\n')
                outfilehandlecrs.write('\n')

                # Now postponed write of all [ObservationPoint] and [ObservationCrossSection] blocks.
                for obsId,obsPoint in obsPoints.items():
                    outfilehandlepts.write('[ObservationPoint]\n')
                    outfilehandlecrs.write('[ObservationCrossSection]\n')
                    # FM only reads 'name', (not 'id'). So, use SOBEK's 'name' if present, and use SOBEK's 'id' when name is absent.
                    if not obsPoint['name'] == '':
                        outfilehandlepts.write('    {f1:{width1}} = {f2}\n'.format(f1='name', width1 = 9, f2=obsPoint['name']))
                        outfilehandlecrs.write('    {f1:{width1}} = {f2}\n'.format(f1='name', width1 = 9, f2='obsCross_' + obsPoint['name']))
                    else:
                        outfilehandlepts.write('    {f1:{width1}} = {f2}\n'.format(f1='name', width1 = 9, f2=obsPoint['id']))
                        outfilehandlecrs.write('    {f1:{width1}} = {f2}\n'.format(f1='name', width1 = 9, f2='obsCross_' + obsPoint['id']))
                    outfilehandlepts.write('    {f1:{width1}} = {f2}\n'.format(f1='branchId', width1 = 9, f2=obsPoint['branchId']))
                    outfilehandlecrs.write('    {f1:{width1}} = {f2}\n'.format(f1='branchId', width1 = 9, f2=obsPoint['branchId']))
                    outfilehandlepts.write('    {f1:{width1}} = {f2}\n'.format(f1='chainage', width1 = 9, f2=obsPoint['chainage']))
                    outfilehandlecrs.write('    {f1:{width1}} = {f2}\n'.format(f1='chainage', width1 = 9, f2=obsPoint['chainage']))
                    outfilehandlepts.write('\n')
                    outfilehandlecrs.write('\n')

        return True



    # Copy the inifield file, and update it
    def copy_and_update_inifieldfile(self, source_file, target_file):
        logger = logging.getLogger('FMWriter')

        if not Path(source_file).resolve().exists():
            return
        stpos = 0
        interpolationFound = False
        if_chainage = {}
        if_values   = {}
        with open(target_file, "w") as outfilehandle:
            with open(source_file, "r") as infilehandle:
                section      = " "
                majorVersion = -1
                minorVersion = -1
                indent       = 0
                sectionContentStarted = False
                for line in infilehandle:
                    # Section
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                    #
                    # majorVersion
                    startpos = line.find('majorVersion')
                    if startpos > -1:
                        indent   = startpos
                        eqpos = line.find('=')
                        majorVersion = int(line[eqpos+1:])
                    startpos = line.find('minorVersion')
                    if startpos > -1:
                        eqpos = line.find('=')
                        minorVersion = int(line[eqpos+1:]) + 1
                    if section == "General":
                        if majorVersion != -1 and minorVersion != -1:
                            if majorVersion == 1:
                                # This script converts version 1.xx into 2.00
                                majorVersion = 2
                                minorVersion = 0
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(eqpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion * minorVersion < 0:
                                continue
                    #
                    # fileType
                    startpos = line.find('fileType')
                    if startpos > -1:
                        eqpos = line.find('=')
                        line  = line[:eqpos+1] + " 1dField"
                    if section == "Content":
                        sectionContentStarted = True
                        indent = line.find('interpolate')
                        if indent > -1:
                            interpolationFound = True
                            eqpos = line.find('=')
                            value = int(line[eqpos+1:])
                            if value == 0:
                                logger.warning('File "' + os.path.basename(source_file) + '" contains "interpolate = 0". D-Flow FM only supports "interpolate = 1 (linear)". No specification added.')
                        # Section "Content" will be removed
                        continue
                    else:
                        if sectionContentStarted:
                            # section "Content" is finished. Write section "Global"
                            sectionContentStarted = False
                            outfilehandle.write('\n[Global]\n')
                            if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                                outfilehandle.write('    quantity            = waterdepth\n')
                            else:
                                outfilehandle.write('    quantity            = waterlevel\n')
                            outfilehandle.write('    unit                = m\n')
                            if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                                outfilehandle.write('    value               = ' + self.model.keyvalue.get("InitialWaterDepth") + '          # default value\n')
                            else:
                                outfilehandle.write('    value               = ' + self.model.keyvalue.get("InitialWaterLevel") + '          # default value\n')
                            if "InifieldFileInterpolate" in self.model.keyvalue:
                                outfilehandle.write('    ' + self.model.keyvalue["InifieldFileInterpolate"] + '\n')
                            outfilehandle.write('\n')

                    #
                    if section == "Definition":
                        startpos = line.find('branchId')
                        if startpos > -1:
                            eqpos = line.find('=')
                            id  = str(line[eqpos+1:]).strip()

                        startpos = line.find('chainage')
                        if startpos > -1:
                            eqpos = line.find('=')
                            chainage  = str(line[eqpos+1:]).strip()
                            if id in if_chainage:
                                if_chainage[id] = if_chainage[id] + " " + str(chainage)
                            else:
                                if_chainage[id] = str(chainage)

                        startpos = line.find('value')
                        if startpos > -1:
                            eqpos = line.find('=')
                            value  = str(line[eqpos+1:]).strip()
                            if id in if_values:
                                if_values[id] = if_values[id] + " " + str(value)
                            else:
                                if_values[id] = str(value)
                    else: # section != "Definition"
                        outfilehandle.write(line)

            # Finished reading, write Global block if it hasn't been written already
            # This will happen when the input file is empty (e.g. only contains a [General] and a [Content] block)
            if sectionContentStarted:
                sectionContentStarted = False
                outfilehandle.write('\n[Global]\n')
                if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                    outfilehandle.write('    quantity            = waterdepth\n')
                else:
                    outfilehandle.write('    quantity            = waterlevel\n')
                outfilehandle.write('    unit                = m\n')
                if self.model.keyvalue["UseInitialWaterDepth"] == '1':
                    outfilehandle.write('    value               = ' + self.model.keyvalue.get("InitialWaterDepth") + '          # default value\n')
                else:
                    outfilehandle.write('    value               = ' + self.model.keyvalue.get("InitialWaterLevel") + '          # default value\n')
                if "InifieldFileInterpolate" in self.model.keyvalue:
                    outfilehandle.write('    ' + self.model.keyvalue["InifieldFileInterpolate"] + '\n')
                outfilehandle.write('\n')

            # Write branches
            for id in if_chainage:
                outfilehandle.write("[Branch]\n")
                outfilehandle.write("    branchId              = " + str(id) + "\n")
                numloc = if_values[id].count(" ") + 1
                if numloc > 1:
                    outfilehandle.write("    numLocations          = " + str(numloc) + "\n")
                    outfilehandle.write("    chainage              = " + if_chainage[id] + "\n")
                outfilehandle.write("    values                = " + if_values[id] + "\n\n")

        if interpolationFound == False:
            # Throw a warning that the default interpolation is changed
            logger.warning('File "' + os.path.basename(source_file) + '" does not contain an interpolation specification. The default method in D-Flow FM ("interpolate = 1 (linear)") differs from the default method in SOBEK3 ("interpolate = 0 (none)").')
        
        return True


    # Copy the crosssection location file, and update it
    def copy_and_update_crosssection_locations(self, source_file, target_file):
        logger = logging.getLogger('FMWriter')
        locNames = []
        with open(source_file, "r") as infilehandle:
            with open(target_file, "w") as outfilehandle:
                section = " "
                majorVersion = -1
                minorVersion = -1
                for line in infilehandle:
                    #
                    # DateTime
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                    #
                    # majorVersion
                    indent = line.find('majorVersion')
                    if indent > -1:
                        eqpos    = line.find('=')
                        majorVersion = int(line[eqpos+1:])
                    indent = line.find('minorVersion')
                    if indent > -1:
                        eqpos    = line.find('=')
                        minorVersion = int(line[eqpos+1:]) + 1
                    if section == "General":
                        if majorVersion != -1 and minorVersion != -1:
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(eqpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion != -1 or minorVersion != -1:
                                continue
                    #
                    # Replace SOBEK keywords by D-Flow FM keywords
                    startpos = line.find(' id ')
                    if startpos > -1:
                        eqpos    = line.find('=')
                        value    = line[eqpos+1:].strip()
                        if value in locNames:
                            # This id is already used
                            # Create a new, unique id and write a warning
                            iadd    = 0
                            newname = value
                            while newname in locNames:
                                iadd += 1
                                newname = value +'(' + str(iadd) + ')'
                            logger.warning('Cross section location id "' + value + '" is not unique. Renaming duplicate occurrence to "' + newname + '".')
                            value = newname
                        locNames.append(value)
                        line     = line[:eqpos+1] + " #" + value + "#\n"

                    # branchid => branchId and # around the value
                    startpos = line.find('branchid')
                    if startpos > -1:
                        line     = line[:startpos] + "branchId" + line[startpos+8:]
                        eqpos    = line.find('=')
                        value    = line[eqpos+1:].strip()
                        line     = line[:eqpos+1] + " #" + value + "#\n"

                    # Remove the line with keyword name
                    startpos = line.find(' name ')
                    if startpos > -1:
                        continue

                    # definition => definitionId and # around the value
                    startpos = line.find('definition')
                    if startpos > -1:
                        line     = line[:startpos] + "definitionId" + line[startpos+12:]
                        eqpos    = line.find('=')
                        value    = line[eqpos+1:].strip()
                        line     = line[:eqpos+1] + " #" + value + "#\n"

                    outfilehandle.write(line)

        return True


    # Copy the crosssection location file, and update it
    def copy_and_update_structure(self, source_file, target_file):
        logger = logging.getLogger('FMWriter')
        allowedflowdirType = {'0':'both', '1':'positive', '2':'negative', '3':'none'}
        controlSideType = {'1':'suctionSide', '2':'deliverySide', '3':'both'}
        structureType = ['weir', 'universalweir', 'culvert', 'bridge', 'pump', 'orifice', 'gate', 'generalstructure', 'compound']
        fmType = {'1':'Chezy', '4':'Manning', '5':'StricklerNikuradse', '6':'Strickler', '7':'WhiteColebrook', '9':'deBosBijkerk '}
        compoundStructures = defaultdict(dict)
        with open(source_file, "r") as infilehandle:
            with open(target_file, "w") as outfilehandle:
                section = " "
                structype    = 'None'
                majorVersion = -1
                minorVersion = -1
                for line in infilehandle:
                    #
                    # DateTime
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                        # Start with an undefined crestlevel/crestwidth every section
                        crestlevel   = -999.0
                        crestwidth   = -999.0
                        structype    = 'None'
                        id           = 'None'
                        branchId     = 'None'
                    #
                    # majorVersion
                    indent = line.find('majorVersion')
                    if indent > -1:
                        eqpos    = line.find('=')
                        majorVersion = int(line[eqpos+1:])
                    indent = line.find('minorVersion')
                    if indent > -1:
                        eqpos    = line.find('=')
                        minorVersion = int(line[eqpos+1:]) + 1
                    if section == 'General':
                        if majorVersion != -1 and minorVersion != -1:
                            if majorVersion < 2:
                                # Minimum version number is 2.0
                                majorVersion = 2
                                minorVersion = 0
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(eqpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion != -1 or minorVersion != -1:
                                continue
                    #
                    # Store id, needed later
                    startpos = line.lower().find('id ')
                    if startpos > -1 and (startpos == 0 or line[startpos-1:startpos] == ' '):
                        eqpos = line.find('=')
                        id = line[eqpos+1:].strip()

                    #
                    # Store branchId, needed later
                    startpos = line.lower().find('branchid')
                    if startpos > -1 and (startpos == 0 or line[startpos-1:startpos] == ' '):
                        eqpos = line.find('=')
                        branchId = line[eqpos+1:].strip()

                    # Store structure type, needed later
                    startpos = line.lower().find('type')
                    if startpos > -1 and (startpos == 0 or line[startpos-1:startpos] == ' '):
                        eqpos = line.find('=')
                        structype = line[eqpos+1:].strip()
                        if structype.lower() not in structureType:
                            logging.warning('In "' + os.path.basename(source_file) + '": structure type "' + structype + '" is not supported in D-Flow FM')

                    # Replace SOBEK keywords by D-Flow FM keywords

                    # nrStages -> numStages
                    line = re.sub('nrStages ','numStages', line, flags=re.IGNORECASE)

                    # reductionFactorLevels -> numReductionLevels
                    line = re.sub('reductionFactorLevels','numReductionLevels   ', line, flags=re.IGNORECASE)

                    # reductionfactor -> reductionFactor
                    line = re.sub('reductionfactor','reductionFactor', line, flags=re.IGNORECASE)

                    # lossCoeffCount -> numLossCoeff
                    line = re.sub('lossCoeffCount','numLossCoeff  ', line, flags=re.IGNORECASE)

                    # lossCoefficient -> lossCoeff
                    line = re.sub('lossCoefficient','lossCoeff      ', line, flags=re.IGNORECASE)

                    # relativeOpening -> relOpening
                    line = re.sub('relativeOpening','relOpening     ', line, flags=re.IGNORECASE)

                    # levelsCount -> numLevels
                    line = re.sub('levelsCount','numLevels  ', line, flags=re.IGNORECASE)

                    # crestwidth -> crestWidth
                    line = re.sub('crestwidth','crestWidth', line, flags=re.IGNORECASE)

                    # widthcenter -> crestWidth
                    line = re.sub('widthcenter','crestWidth ', line, flags=re.IGNORECASE)

                    startpos = line.lower().find('crestwidth')
                    if startpos > -1:
                        eqpos = line.find('=')
                        crestwidth = float(line[eqpos+1:].strip())
                        if structype in ['orifice', 'gate', 'generalstructure']:
                            # Then add gateOpeningWidth
                            outfilehandle.write(line)
                            line  = 'gateOpeningWidth'.rjust(startpos+16, ' ')
                            value = '{0:.3f}'.format(crestwidth)
                            line  = line.ljust(eqpos, ' ') + "= " + value + "             # crestWidth is used as default value\n"

                    # iniValveOpen -> valveOpeningHeight
                    line = re.sub('iniValveOpen      ','valveOpeningHeight', line, flags=re.IGNORECASE)

                    # widthleftW1 -> upstream1Width
                    line = re.sub('widthleftW1   ','upstream1Width', line, flags=re.IGNORECASE)

                    # widthleftWsdl -> upstream2Width
                    line = re.sub('widthleftWsdl ','upstream2Width', line, flags=re.IGNORECASE)

                    # widthrightWsdr -> downstream1Width
                    line = re.sub('widthrightwsdr  ', 'downstream1Width', line, flags=re.IGNORECASE)

                    # widthrightW2 -> downstream2Width
                    line = re.sub('widthrightW2    ','downstream2Width', line, flags=re.IGNORECASE)

                    # levelleftZb1 -> upstream1Level
                    line = re.sub('levelleftZb1  ','upstream1Level', line, flags=re.IGNORECASE)

                    # levelleftZbsl -> upstream2Level
                    line = re.sub('levelleftZbsl ','upstream2Level', line, flags=re.IGNORECASE)

                    # levelrightZbsr -> downstream1Level
                    line = re.sub('levelrightZbsr  ','downstream1Level', line, flags=re.IGNORECASE)

                    # levelrightZb2 -> downstream2Level
                    line = re.sub('levelrightZb2   ','downstream2Level', line, flags=re.IGNORECASE)

                    # gateheight -> gateLowerEdgeLevel
                    line = re.sub('gateheight        ','gateLowerEdgeLevel', line, flags=re.IGNORECASE)

                    # dischargecoeff ...
                    if structype.lower() in ['universalweir']:
                        # -> dischargeCoeff
                        line = re.sub('dischargecoeff','dischargeCoeff', line, flags=re.IGNORECASE)
                    else:
                        # -> corrCoeff
                        line = re.sub('dischargecoeff','corrCoeff     ', line, flags=re.IGNORECASE)

                    # latcontrcoeff -> corrCoeff
                    line = re.sub('latcontrcoeff','corrCoeff    ', line, flags=re.IGNORECASE)

                    # crestlevel -> crestLevel
                    # read value, needed for gateLowerEdgeLevel
                    line = re.sub('levelcenter','crestLevel ', line, flags=re.IGNORECASE)
                    line = re.sub('crestlevel','crestLevel', line, flags=re.IGNORECASE)
                    startpos = line.lower().find('crestlevel')
                    if startpos > -1:
                        eqpos = line.find('=')
                        crestlevel = float(line[eqpos+1:].strip())

                    # openlevel -> gateLowerEdgeLevel = openlevel + crestlevel
                    startpos = line.lower().find('openlevel')
                    if startpos > -1:
                        if crestlevel <= -998.9:
                            logger.error(os.path.basename(source_file) + ':\n\t\t\t "openlevel" found but "crestlevel" not (yet)')
                            raise Exception
                        eqpos = line.find('=')
                        openlevel = float(line[eqpos+1:].strip())
                        line  = 'gateLowerEdgeLevel'.rjust(startpos+18, ' ')
                        value = '{0:.3f}'.format(crestlevel+openlevel)
                        line  = line.ljust(eqpos, ' ') + '= ' + value + '              # "crestLevel+openLevel" is used as default value\n'

                    # For orifice, gate and generalstructure:
                    # Add gateHeight after crestlevel
                    # crestlevel appears on a lot of places; search for crestlevel at the start of a line
                    found = re.search('^ *crestlevel', line.lower())
                    if found and structype in ['orifice', 'gate', 'generalstructure']:
                        # startpos is used for alignment
                        startpos = line.lower().find('crestlevel')
                        eqpos = line.find('=')
                        # First write the current line
                        outfilehandle.write(line)
                        # Then add gateHeight, with default value 1.0e10
                        line  = 'gateHeight'.rjust(startpos+10, ' ')
                        line  = line.ljust(eqpos, ' ') + "= 1.0e10             # Default value. Check manual.\n"



                    # Remove "latdiscoeff =" line, raise a warning when its value <> 1.0
                    startpos = line.lower().find('latdiscoeff')
                    if startpos > -1:
                        eqpos = line.find('=')
                        latdiscoeff = float(line[eqpos+1:].strip())
                        if abs(latdiscoeff - 1.0) > 1e-4:
                            logging.warning('In "' + os.path.basename(source_file) + '": parameter "latdiscoeff" unequal to 1.0 is not supported in D-Flow FM')
                        continue

                    # Remove "freesubmergedfactor =" line, raise a warning when its value <> 0.667
                    startpos = line.lower().find('freesubmergedfactor')
                    if startpos > -1:
                        eqpos = line.find('=')
                        value = float(line[eqpos+1:].strip())
                        if abs(value - 0.667) > 1e-4:
                            logging.warning('In "' + os.path.basename(source_file) + '": parameter "freesubmergedfactor " unequal to 0.667 is not supported in D-Flow FM')
                        continue

                    # Remove "compound =" line
                    if re.search('compound *=', line.lower()):
                        continue

                    # Add compoundName to compoundStructures and Remove it here
                    startpos = line.lower().find('compoundname')
                    if startpos > -1:
                        eqpos = line.find('=')
                        value = line[eqpos+1:].strip()
                        if value in compoundStructures:
                            # CompoundStructrure already exists:
                            # Check branchID
                            if compoundStructures[value]['branchId'] != branchId:
                                logger.error(os.path.basename(source_file) + ':\n\t\t\t branchId of structure "' + id +'" differs from "' + compoundStructures[value]['structureIds'] + '"')
                                raise Exception
                            # Increase numStructures
                            compoundStructures[value]['numStructures'] += 1
                            # Add ";id" to structureIds
                            compoundStructures[value]['structureIds'] = compoundStructures[value]['structureIds'] + ';' + id
                        else:
                            # CompoundStructrure does not exist yet:
                            compoundStructures[value]['branchId'] = branchId
                            compoundStructures[value]['numStructures'] = 1
                            compoundStructures[value]['structureIds'] = id
                        continue

                    # Remove "uselimitflowpos =" line
                    if re.search('uselimitflowpos *=', line.lower()):
                        continue

                    # Remove "limitflowpos =" line
                    if re.search('limitflowpos *=', line.lower()):
                        continue

                    # Remove "uselimitflowneg =" line
                    if re.search('uselimitflowneg *=', line.lower()):
                        continue

                    # Remove "limitflowneg =" line
                    if re.search('limitflowneg *=', line.lower()):
                        continue

                    # Remove "contractioncoeff =" line, raise a warning when its value <> 1.0
                    startpos = line.lower().find('contractioncoeff')
                    if startpos > -1:
                        eqpos = line.find('=')
                        value = float(line[eqpos+1:].strip())
                        if abs(value - 1.000) > 1e-4:
                            logging.warning('In "' + os.path.basename(source_file) + '": parameter "contractioncoeff" unequal to 1.000 is not supported in D-Flow FM')
                        continue

                    # Remove "groundFrictionType =" line
                    if re.search('groundfrictiontype *=', line.lower()):
                        logging.warning('In "' + os.path.basename(source_file) + '": parameter "groundFrictionType" is not supported in D-Flow FM')
                        continue

                    # Remove "groundFriction =" line
                    if re.search('groundfriction *=', line.lower()):
                        logging.warning('In "' + os.path.basename(source_file) + '": parameter "groundFriction" is not supported in D-Flow FM')
                        continue

                    # Remove "pillar* =" line
                    if re.search('pillar.* *=', line.lower()):
                        logging.warning('In "' + os.path.basename(source_file) + '": "pillar Bridge" related parameters are not supported in D-Flow FM')
                        continue

                    # Bridge: bedFrictionType -> frictionType
                    # Convert integer to string using dictionary fmType
                    startpos = line.lower().find('bedfrictiontype')
                    if startpos > -1:
                        eqpos = line.find('=')
                        sobekType = line[eqpos+1:].strip()
                        if sobekType in fmType:
                            if structype == 'bridge':
                                line  = 'frictionType'.rjust(startpos+12, ' ')
                            else:
                                line  = 'bedFrictionType'.rjust(startpos+15, ' ')
                            line  = line.ljust(eqpos, ' ') + "= " + fmType[sobekType] + "\n"
                        else:
                            logger.error('Unknown value found in file "' + os.path.basename(source_file) + '":\n\t\t\t bedFrictionType = '+str(sobekType))
                            raise Exception
                    else:
                        # bridge: bedFriction -> friction
                        # Inside "else" to avoid clash with "bedFrictionType" handling
                        startpos = line.lower().find('bedfriction')
                        if startpos > -1:
                            eqpos = line.find('=')
                            friction = float(line[eqpos+1:].strip())
                            if structype == 'bridge':
                                line  = 'friction'.rjust(startpos+8, ' ')
                            else:
                                line  = 'bedFriction'.rjust(startpos+11, ' ')
                            value = '{0:.3f}'.format(friction)
                            line  = line.ljust(eqpos, ' ') + "= " + value + "\n"

                    # allowedflowdir: convert integer to string
                    startpos = line.lower().find('allowedflowdir')
                    if startpos > -1:
                        if structype in ['weir']:
                            logging.warning('In "' + os.path.basename(source_file) + '": parameter "allowedflowdir" is not supported for weirs in D-Flow FM ')
                            continue
                        else:
                            eqpos = line.find('=')
                            sobekType = line[eqpos+1:].strip()
                            if sobekType in allowedflowdirType:
                                line  = 'allowedFlowDir'.rjust(startpos+14, ' ')
                                line  = line.ljust(eqpos, ' ') + "= " + allowedflowdirType[sobekType] + "\n"
                            else:
                                logger.error('Unknown value found in file "' + os.path.basename(source_file) + '":\n\t\t\t allowedFlowDir = '+str(sobekType))
                                raise Exception

                    # direction -> : orientation, controlSide
                    startpos = line.lower().find('direction')
                    if startpos > -1:
                        eqpos = line.find('=')
                        sobekType = int(line[eqpos+1:].strip())
                        # First controlSide
                        if str(abs(sobekType)) in controlSideType:
                            line  = 'controlSide'.rjust(startpos+11, ' ')
                            line  = line.ljust(eqpos, ' ') + "= " + controlSideType[str(abs(sobekType))] + "\n"
                        else:
                            logger.error('Unknown value found in file "' + os.path.basename(source_file) + '":\n\t\t\t direction = '+str(sobekType))
                            raise Exception
                        outfilehandle.write(line)
                        # Then orientation
                        if numpy.sign(sobekType) == 1:
                            orientation = 'positive'
                        else:
                            orientation = 'negative'
                        line  = 'orientation'.rjust(startpos+11, ' ')
                        line  = line.ljust(eqpos, ' ') + "= " + orientation + "\n"

                    outfilehandle.write(line)

                # Add compound structures to output file
                for aCompound in compoundStructures:
                    outfilehandle.write('[Structure]\n')
                    outfilehandle.write('    id            = ' + aCompound + '\n')
                    outfilehandle.write('    branchId      = ' + compoundStructures[aCompound]['branchId'] + '\n')
                    outfilehandle.write('    type          = compound' + '\n')
                    outfilehandle.write('    numStructures = ' + str(compoundStructures[aCompound]['numStructures']) + '\n')
                    outfilehandle.write('    structureIds  = ' + compoundStructures[aCompound]['structureIds'] + '\n\n')
        return True

    # Copy the crosssection location file, and update it
    def copy_and_update_crosssection_definitions(self, source_file, target_file):
        logger = logging.getLogger('FMWriter')
        profType = ''
        profNames = []
        kwPlural = False
        with open(source_file, "r") as infilehandle:
            with open(target_file, "w") as outfilehandle:
                section = " "
                majorVersion = -1
                minorVersion = -1
                for line in infilehandle:
                    #
                    # DateTime
                    startpos = line.find('[')
                    if startpos == 0:
                        # New section found
                        endpos       = line.find(']')
                        section      = line[startpos+1:endpos]
                        majorVersion = -1
                        minorVersion = -1
                        # New section, default: duplicateId = False
                        # When reading the id, it might become True
                        duplicateId = False
                    #
                    # majorVersion
                    indent = line.find('majorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        majorVersion = int(line[startpos+1:])
                    indent = line.find('minorVersion')
                    if indent > -1:
                        startpos = line.find('=')
                        minorVersion = int(line[startpos+1:]) + 1
                    if section == "General":
                        if majorVersion != -1 and minorVersion != -1:
                            if majorVersion == 1:
                                # This script converts version 1.xx into 3.00
                                majorVersion = 3
                                minorVersion = 0
                            line =  '{f1:{width1}}fileVersion{f2:{width2}}= {f3:d}.{f4:02d}\n'.format(f1=' ', width1=str(indent),f2=' ', width2=str(startpos-indent-11), f3=majorVersion, f4=minorVersion)
                            majorVersion = -1
                            minorVersion = -1
                        else:
                            if majorVersion != -1 or minorVersion != -1:
                                continue
                    #
                    # Replace SOBEK keywords by D-Flow FM keywords

                    startpos =  line.find('[Definition]')
                    if startpos > -1:
                        # Do not write this line yet, only when we found a unique id
                        continue

                    # Add # arround id
                    startpos = line.find(' id ')
                    if startpos > -1:
                        startpos = line.find('=')
                        profName = line[startpos+1:].strip()
                        if profName in profNames:
                            # This  profile is not unique: warning and skip it
                            logging.warning('Duplicate cross section found: "' + profName + '". Skipping second occurrence.')
                            duplicateId = True
                        else:
                            profNames.append(profName)
                            # Write the "[Definition]" line
                            outfilehandle.write('[Definition]\n')
                            line = line[:startpos+1] + " #" + profName + "#\n"

                    # Skip the rest if this is a duplicate profile
                    if duplicateId:
                        continue

                    # type =  tabulated => type = zw
                    startpos = line.find('type')
                    if startpos > -1:
                        profType = ''
                        kwPlural = False
                        tabpos = line.find('rectangle')
                        if tabpos > -1:
                            profType = 'rectangle'
                        tabpos = line.find('circle')
                        if tabpos > -1:
                            profType = 'circle'
                        tabpos = line.find('yz')
                        if tabpos > -1:
                            profType = 'yz'
                            kwPlural = True
                        tabpos = line.find('xyz')
                        if tabpos > -1:
                            profType = 'xyz'
                            kwPlural = True

                        tabpos = line.find('tabulated')
                        if tabpos > -1:
                            profType = 'tabulated'
                            line   = line[:tabpos] + "zwRiver\n"

                        tabpos = line.find('arch')
                        if tabpos > -1:
                            profType = 'arch'
                            line   = line[:tabpos] + "zw\n"
                        tabpos = line.find('egg')
                        if tabpos > -1:
                            profType = 'egg'
                            line   = line[:tabpos] + "zw\n"
                        tabpos = line.find('ellipse')
                        if tabpos > -1:
                            profType = 'ellipse'
                            line   = line[:tabpos] + "zw\n"
                        tabpos = line.find('steelcunette')
                        if tabpos > -1:
                            profType = 'steelcunette'
                            line   = line[:tabpos] + "zw\n"
                        tabpos = line.find('cunette')
                        if tabpos > -1:
                            profType = 'cunette'
                            line   = line[:tabpos] + "zw\n"
                        tabpos = line.find('trapezium')
                        if tabpos > -1:
                            profType = 'trapezium'
                            line   = line[:tabpos] + "zw\n"

                        #check whether cross section type has been set
                        #if profType == '':
                        #    unknown cross section type

                    # changes for circle cross sections
                    if profType == 'circle':
                        # diameter will be read by kernel, remove the tabulated records
                        startpos = line.find('numLevels')
                        if startpos > -1:
                            continue
                        startpos = line.find('levels')
                        if startpos > -1:
                            continue
                        startpos = line.find('flowWidths')
                        if startpos > -1:
                            continue

                    # changes for egg cross sections
                    if profType == 'egg':
                        startpos = line.find('width')
                        if startpos > -1:
                            newline  = 'template'.rjust(startpos+8, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= egg\n"
                            outfilehandle.write(newline)

                    # changes for ellipse cross sections
                    if profType == 'ellipse':
                        startpos = line.find('width')
                        if startpos > -1:
                            newline  = 'template'.rjust(startpos+8, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= ellipse\n"
                            outfilehandle.write(newline)

                    # no special changes for rectangle cross sections
                    #if profType == 'rectangle':

                    # changes for arch cross sections
                    if profType == 'arch':
                        startpos = line.find('height')
                        if startpos > -1:
                            newline  = 'template'.rjust(startpos+8, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= arch\n"
                            outfilehandle.write(newline)

                    # changes for cunette cross sections
                    if profType == 'cunette':
                        startpos = line.find('width')
                        if startpos > -1:
                            newline  = 'template'.rjust(startpos+8, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= mouth\n"
                            outfilehandle.write(newline)

                    # changes for steelcunette cross sections
                    if profType == 'steelcunette':
                        startpos = line.find('height')
                        if startpos > -1:
                            newline  = 'template'.rjust(startpos+8, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= steelMouth\n"
                            outfilehandle.write(newline)

                    # changes for trapezium cross sections
                    if profType == 'trapezium':
                        startpos = line.find('slope')
                        if startpos > -1:
                            newline  = 'template'.rjust(startpos+8, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= trapezium\n"
                            outfilehandle.write(newline)
                            #
                            newline  = 'closed'.rjust(startpos+6, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= no\n"
                            outfilehandle.write(newline)
                            #
                            slope = line[eqpos+1:].strip()
                        startpos = line.find('maximumFlowWidth')
                        if startpos > -1:
                            line     = line[:startpos] + "width           " + line[startpos+16:]
                            eqpos    = line.find('=')
                            maximumFlowWidth = line[eqpos+1:].strip()
                        startpos = line.find('bottomWidth')
                        if startpos > -1:
                            newline  = 'baseWidth'.rjust(startpos+9, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + line[eqpos:]
                            outfilehandle.write(newline)
                            baseWidth = line[eqpos+1:].strip()
                            depth = (float(maximumFlowWidth) - float(baseWidth))/2.0/float(slope)
                            depthstr = '%.5f' % depth
                            #
                            newline  = 'numLevels'.rjust(startpos+9, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= 2\n"
                            outfilehandle.write(newline)
                            #
                            newline  = 'levels'.rjust(startpos+6, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= 0.00000 " + depthstr + "\n"
                            outfilehandle.write(newline)
                            #
                            newline  = 'flowWidths'.rjust(startpos+10, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= " + baseWidth + " " + maximumFlowWidth + "\n"
                            line     = newline

                    # changes for YZ cross sections
                    if profType == 'yz':
                        startpos = line.find('xValues')
                        if startpos > -1:
                            line = line[:startpos] + "xCoordinates" + line[startpos+12:]
                        startpos = line.find('yValues')
                        if startpos > -1:
                            line = line[:startpos] + "yCoordinates" + line[startpos+12:]
                        startpos = line.find('zValues')
                        if startpos > -1:
                            line = line[:startpos] + "zCoordinates" + line[startpos+12:]
                        # Remove deltaZStorage line
                        startpos = line.find('deltaZStorage')
                        if startpos > -1:
                            continue
                        # Add singleValuedZ, just before the yzCount line
                        startpos = line.find('yzCount')
                        if startpos > -1:
                            newline  = 'singleValuedZ'.rjust(startpos+13, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= yes\n"
                            outfilehandle.write(newline)

                    # changes for XYZ cross sections
                    if profType == 'xyz':
                        startpos = line.find('xCoors')
                        if startpos > -1:
                            line = line[:startpos] + "xCoordinates" + line[startpos+12:]
                        startpos = line.find('yCoors')
                        if startpos > -1:
                            line = line[:startpos] + "yCoordinates" + line[startpos+12:]
                        startpos = line.find('zCoors')
                        if startpos > -1:
                            line = line[:startpos] + "zCoordinates" + line[startpos+12:]
                        # Remove yValues and zValues lines
                        startpos = line.find('yValues')
                        if startpos > -1:
                            continue
                        startpos = line.find('zValues')
                        if startpos > -1:
                            continue
                        # Remove deltaZStorage line
                        startpos = line.find('deltaZStorage')
                        if startpos > -1:
                            continue

                    startpos = line.find('groundlayerUsed')
                    if startpos > -1:
                        continue
                    startpos = line.find('groundlayer')
                    if startpos > -1:
                        continue

                    # changes for tabulated cross sections
                    if profType == 'tabulated':
                        startpos = line.find('sd_crest')
                        if startpos > -1:
                            line = line[:startpos] + "leveeCrestLevel" + line[startpos+15:]
                        startpos = line.find('sd_baseLevel')
                        if startpos > -1:
                            line = line[:startpos] + "leveeBaseLevel" + line[startpos+14:]
                        startpos = line.find('sd_flowArea')
                        if startpos > -1:
                            line = line[:startpos] + "leveeFlowArea" + line[startpos+13:]
                        startpos = line.find('sd_totalArea')
                        if startpos > -1:
                            line = line[:startpos] + "leveeTotalArea" + line[startpos+14:]
                        startpos = line.find('main')
                        if startpos > -1:
                            line = line[:startpos] + "mainWidth" + line[startpos+9:]
                        startpos = line.find('floodPlain1')
                        if startpos > -1:
                            line = line[:startpos] + "fp1Width   " + line[startpos+11:]
                        startpos = line.find('floodPlain2')
                        if startpos > -1:
                            line = line[:startpos] + "fp2Width   " + line[startpos+11:]

                    startpos = line.find('sectionCount')
                    if startpos > -1:
                        # add conveyance line just before sectionCount for YZ and XYZ cross sections
                        if profType == 'yz' or profType == 'xyz':
                            newline  = 'conveyance'.rjust(startpos+10, ' ')
                            eqpos    = line.find('=')
                            newline  = newline.ljust(eqpos, ' ') + "= segmented\n"
                            outfilehandle.write(newline)

                    startpos = line.find('closed')
                    if startpos > -1:
                        line = line.replace('0','no').replace('1','yes')

                    startpos = line.find('conveyance')
                    if startpos > -1:
                        line = line.replace('0','lumped').replace('1','segmented')

                    startpos = line.find('singleValuedZ')
                    if startpos > -1:
                        line = line.replace('0','no').replace('1','yes')

                    # changes to roughness keywords
                    startpos = line.find('roughnessNames')
                    if startpos > -1:
                        if kwPlural:
                            line = line[:startpos] + "frictionIds   " + line[startpos+14:]
                        else:
                            line = line[:startpos] + "frictionId    " + line[startpos+14:]
                    startpos = line.find('roughnessPositions')
                    if startpos > -1:
                        line = line[:startpos] + "frictionPositions " + line[startpos+18:]
                    startpos = line.find('roughnessTypesPos') # remove type pos
                    if startpos > -1:
                        continue
                    startpos = line.find('roughnessValuesPos') # remove values pos
                    if startpos > -1:
                        continue
                    startpos = line.find('roughnessTypesNeg') # remove type neg
                    if startpos > -1:
                        continue
                    startpos = line.find('roughnessValuesNeg') # remove values neg
                    if startpos > -1:
                        continue

                    outfilehandle.write(line)

        return True





    def write_crosssections(self, output_dir):  # write cross-sections

        file_cs_loc = open(os.path.join(output_dir, self.model.runid + '_cross_section_locations.ini'), 'w')
        file_rough  = open(os.path.join(output_dir, self.model.runid + '_roughness.ini'), 'w')

        # header location
        file_cs_loc.write('[general]\n')
        file_cs_loc.write('majorVersion = 1\n')
        file_cs_loc.write('minorVersion = 0\n')
        file_cs_loc.write('fileType = crossLoc\n')
        file_cs_loc.write('\n')

        # header roughness
        file_rough.write('[general]\n')
        file_rough.write('majorVersion = 1\n')
        file_rough.write('minorVersion = 0\n')
        file_rough.write('fileType = roughness\n')
        file_rough.write('\n')
        file_rough.write('[content]\n')

        file_rough.write('sectionId = SectionName\n')
        file_rough.write('flowDirection = False\n')
        file_rough.write('interpolate = 1\n')
        file_rough.write('globalType = 1\n')
        file_rough.write('globalValue = 45.0\n')
        file_rough.write('\n')

        for cs in self.model.crosssections:

            id        = str(cs[0])
            branch_id = str(cs[1])
            offset    = str(cs[2])

            file_cs_loc.write('[crosssection]\n')
            file_cs_loc.write('id = ' + id + '\n')
            file_cs_loc.write('branchid = ' + branch_id + '\n')
            file_cs_loc.write('chainage = ' + offset + '\n')
            file_cs_loc.write('shift = 0.0\n')
            file_cs_loc.write('definition = def_' + id + '\n')
            file_cs_loc.write('\n')

            # roughness per cross-section
            file_rough.write('[definition]\n')
            file_rough.write('branchid = ' + branch_id + '\n')
            file_rough.write('chainage = ' + offset + '\n')
            file_rough.write('value = 45.0\n')
            file_rough.write('\n')

        file_cs_loc.close()
        file_rough.close()
        return True

    def write_crosssection_definitions(self, output_dir):

        file_cs_def = open(os.path.join(output_dir, self.model.runid + '_cross_section_definitions.ini'), 'w')

        # header
        file_cs_def.write('[general]\n')
        file_cs_def.write('majorVersion = 1\n')
        file_cs_def.write('minorVersion = 0\n')
        file_cs_def.write('fileType = crossDef\n')
        file_cs_def.write('\n')

        # [Definition]
        # type = yz (String)
        # yzCount  Int
        # y_values Double[]
        # z_values Double[]
        # sectionCount Int
        # roughnessNames String[]
        # roughnessPositions Double[]

        for cs in self.model.crosssections:

            id      = str(cs[0])
            y_values = []
            z_values = []
            for point in cs[3]:
                y_values.append(point[0])
                z_values.append(point[1])

            file_cs_def.write('[definition]\n')
            file_cs_def.write('id = def_' + id + '\n')
            file_cs_def.write('type = yz\n')
            file_cs_def.write('yzCount = ' + str(len(y_values)) + '\n')
            file_cs_def.write('y_values = ' + " ".join(str(y) for y in y_values) + '\n')
            file_cs_def.write('z_values = ' + " ".join(str(z) for z in z_values) + '\n')
            file_cs_def.write('sectionCount = 1\n')
            file_cs_def.write('roughnessNames = roughnessName\n')
            file_cs_def.write('roughnessPositions = 0.0 ' + str(y_values[-1]) + '\n')
            file_cs_def.write('\n')

        file_cs_def.close()
        return True

    def to_2_dec(selfselft, str_value):
        result = str("%.2f" % round(float(str_value),2))
        return result;

