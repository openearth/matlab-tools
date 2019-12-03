#
# This code converts the river branches to an ldb file and translates the cross-section profiles to FM format.
#
# Author: Sepehr Eslami Arab 14-08-2017, Utrecht University

from datetime import datetime
from Libraries.StandardFunctions import *
from Libraries.MapFunctions import CreateLineGeometry, CreatePointGeometry
from Libraries.NetworkFunctions import *
from Libraries.SobekWaterFlowFunctions import *
import datetime as dt
import DeltaShell.Plugins.DelftModels as _DM
from shutil import copyfile
from Libraries.fm_fun import * 

############################################
################## Inputs ##################

fldr    = "h:\\06_FM\\vmd1d2d\\vmd\\vmd13\\"    # the folder to store the FM input files
ldb     = "m1d.ldb"    # name of the land boundary file
fm_name = "m1d"        # name of the fm file

temp_file   = "ext_template.ext" # a template for *.ext file
RefDate     = (2016,1,1)         # the boundary data is written relative to this reference date
fmgridsize  = 500.0  # grid size of the 1D FM model

#####################################################
################## Inputs finished ##################

#####################################################
################# required functions ################
def GetFlow1DModel():
    """
    Returns the first Flow1D model it finds
   
    :return obj, Flow1DModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            for submodel in model.Models:
                if type(submodel) == _DM.WaterFlowModel.WaterFlowModel1D:
                    return submodel
        elif type(model) == _DM.WaterFlowModel.WaterFlowModel1D:
            return model

# some functions for FM conversion
def write_pli(fname,pli_dict):
    """
    write an *.ldb file from a *.gen file with a gen_file = input link to the gen_file.
	
	Authur: Sepehr Eslami Arab
    """
    fname = fname + '.pli'
    fhand = open(fname,'w')
    i=1
    for key in pli_dict.keys():
        new_line = 'L' + str(i).zfill(4)
        fhand.write(new_line + '\n')
        shp      = len(pli_dict[key])
        new_line = str(shp).rjust(6) + str(2).rjust(6)
        fhand.write(new_line + '\n')
        for j in range(len(pli_dict[key])):
            new_line = '{:.7f}'.format(pli_dict[key][j][0]) + ' ' + '{:.7f}'.format(pli_dict[key][j][1])
            fhand.write(new_line + '\n')
        i = i + 1
    fhand.close()
    return pli_dict

def write_tim_file(fname, timesteps, sample, RefDate, timeshift = 0, timeunit='m'):
    """
    the function writes a *.tim file (input time-series for the fm model)
    Authur: Sepehr Eslami Arab
	
    inputs:
        fname     = The file name to write
        timesteps = a datetime array of boundary condition timesteps
        sample    = an iterable (list, tuple or numpy array) with the samples
        timeshift = time-difference to be added or subtracted (e.g. -7.0 if I want to convert from HCMC time to GMT)
        RefDate   = a tuple or list with (year, month, day, hour, min, sec) such as (2016,1,1,0,0,0) for the reference simulation time
        timeunit  = unit of time for the input itme-series file, default = 'min' other options: 'sec', 'hour', 'day'

    """
    fname = fname + '_0001.tim'
    # time unit conversion
    if timeunit[0].lower() == 'm':
        time_factor = 24.*60.
    elif timeunit[0].lower() == 's':
        time_factor = 24.*60.*60.
    elif timeunit[0].lower() == 'd':
        time_factor = 1.0
    elif timeunit[0].lower() == 'h':
        time_factor = 24.
    
    # shift the time
    timeshift = dt.timedelta(hours = timeshift)
    timesteps = [dt.datetime(t.Year, t.Month, t.Day, t.Hour, t.Minute, t.Second, t.Millisecond) for t in timesteps]
    timesteps = [t+timeshift for t in timesteps]
    
    # interpolate for the reference time
    reftime  = dt.datetime(*RefDate)
    
    fhand = open(fname,'w')
    fhand.write('* COLUMNN=2\n')
    fhand.write('* COLUMN1=Period (min) or Astronomical Componentname\n')
    fhand.write('* COLUMN2=Amplitude (ISO)v\n')
    fhand.write('* COLUMN3=Phase (deg)\n')

    for i in range(len(timesteps)):
    	timestep = timesteps[i]-reftime
        fhand.write(str(round(timestep.total_seconds()/60.,3)).ljust(3)+ ' ' + str(round(sample[i],3)).rjust(3) + '\n')
    fhand.close()
    return timesteps, sample			
			
minz    = 10000.0     # A dummy maximum bed level, which, in the model, every bed level is defeinitely smaller than

# read the Flow1D model
Flow1D = GetFlow1DModel()

# open a landboundary file
fname = fldr + ldb
fhand = open(fname,'w')

# per branch write the coordinates of the branch
count = 1
for branch in Flow1D.Network.Branches:
	new_line = 'L' + str(count).zfill(4) # write the name of the land boundary element
	new_line = branch.Name 
	fhand.write(new_line + '\n')
	dims     = branch.Geometry.CoordinateSequence.Count
	new_line = str(dims).rjust(6) + str(2).rjust(6) # write the dimensions
	fhand.write(new_line + '\n')
	for i in range(branch.Geometry.CoordinateSequence.Count):
		x_ldb = branch.Geometry.CoordinateSequence.GetX(i)   # X-point Geometry along the branch
		y_ldb = branch.Geometry.CoordinateSequence.GetY(i)   # Y-point Geometry along the branch
		new_line = '{:.7f}'.format(x_ldb) + ' ' + '{:.7f}'.format(y_ldb)
		fhand.write(new_line + '\n')
	count = count + 1
fhand.close()

##########################################
############# Cross-profiles #############
##########################################
# open two files for profile definistions and the xyz
fname   = fldr + fm_name+ "_profdef.txt"
profdef = open(fname,'w')
profdef.write('* TYPE=1  : PIPE' + '\n')
profdef.write('* TYPE=2  : RECTAN   ,  HYDRAD = AREA / PERIMETER                           ALSO SPECIFY: HEIGHT=' + '\n')
profdef.write('* TYPE=3  : RECTAN   ,  HYDRAD = 1D ANALYTIC CONVEYANCE = WATERDEPTH        ALSO SPECIFY: HEIGHT=' + '\n')
profdef.write('* TYPE=4  : V-SHAPE  ,  HYDRAD = AREA / PERIMETER                           ALSO SPECIFY: HEIGHT=' + '\n')
profdef.write('* TYPE=5  : V-SHAPE  ,  HYDRAD = 1D ANALYTIC CONVEYANCE                     ALSO SPECIFY: HEIGHT=' + '\n')
profdef.write('* TYPE=6  : TRAPEZOID,  HYDRAD = AREA / PERIMETER                           ALSO SPECIFY: HEIGHT=  BASE=' + '\n')
profdef.write('* TYPE=7  : TRAPEZOID,  HYDRAD = 1D ANALYTIC CONVEYANCE                     ALSO SPECIFY: HEIGHT=  BASE=' + '\n')
profdef.write('* TYPE=200: XYZPROF  ,  HYDRAD = AREA / PERIMETER' + '\n')
profdef.write('* TYPE=201: XYZPROF  ,  HYDRAD = 1D ANALYTIC CONVEYANCE METHOD' + '\n')
profdef.write('\n')

fname   = fldr + "conversion.txt"
conversionlog = open(fname,'w')

fname   = fldr + fm_name + "_profdefxyz.pliz"
profdefxyz = open(fname,'w')

fname   = fldr + fm_name + "_profloc.xyz"
profloc = open(fname,'w')

fname   = fldr + fm_name + "_thalweg.xyz"
thalweg_file = open(fname,'w')

profnr = 1

for crs in Flow1D.Network.CrossSections:
	# If the profile is defined at the chainage = 0.0 then change the location to further downstream
	if crs.Chainage==0.0:
		new_chng = crs.Branch.Length/200.0
		for feat in crs.Branch.CrossSections:
			if feat.Chainage>0:
				new_chng = min(new_chng,feat.Chainage)
		new_chng = new_chng/2.0
		crs.Chainage = new_chng
	
	if crs.Chainage==crs.Branch.Length:
		new_chng = crs.Branch.Length-200.0
		for feat in crs.Branch.CrossSections:
			if feat.Chainage>new_chng:
				new_chng = max(new_chng,feat.Chainage)
		new_chng = new_chng/2.0
		crs.Chainage = new_chng
	
	tline = 'PROFNR=' + str(profnr).ljust(6) + 'TYPE=201' + '\n'
	profdef.write(tline)
	#if profnr==284:
	#	print profnr, crs.Branch.Name, crs.Name
	# write the header per cross-section
	profdefxyz.write('PROFNR=' + str(profnr) + '\n')
	conversionlog.write('PROFNR=' + str(profnr) + ',  branch:' + crs.Branch.Name + ', cross-section:' + crs.Name + '\n')
	if crs.Definition.IsProxy is False:              # if the definition is local 
		nlines = crs.Definition.YZDataTable.Count    # number of profile points
	else:
		nlines = crs.Definition.InnerDefinition.YZDataTable.Count    # number of profile points
	profdefxyz.write('     ' + str(nlines).ljust(6) + str(3) + '\n')
	
	# extract the beginning and the end of the cross-sections
	x1   = crs.Geometry.StartPoint.Coordinate.X
	y1   = crs.Geometry.StartPoint.Coordinate.Y
	x2   = crs.Geometry.EndPoint.Coordinate.X
	y2   = crs.Geometry.EndPoint.Coordinate.Y
	
	### test thalweg depth
	wdth = ((x2-x1)**2 + (y2-y1)**2)**0.5
	vertical_line = False      # A variable to check the slope of the profile line (whether it is infinity)
	if (x2-x1)!=0 :
		m    = (y2-y1)/(x2-x1)
	else:
		# when the profile is vertical, we replace slope with a +/-1 value 
		# which determines whether the distance from the left bank has to be #
		# added or has to be deducted from the y1 of the left bank
		m    = (y2-y1)/wdth   
		vertical_line=True     # the profile is a vertical line with slope = infinity
	
	# write the profile location
	thalweg = crs.Definition.Thalweg
	
	if vertical_line==False:
		xt     = x1 + thalweg*(x2-x1)/wdth
		yt     = m * (xt-x1) + y1
	else:
		xt     = x1 
		yt = m*thalweg + y1

	new_line = '    ' + "{0:.7f}".format(xt) + '    ' + "{0:.7f}".format(yt) + '    ' + "{0:.7f}".format(float(profnr)) + '\n'
	profloc.write(new_line)
	
	zmin = minz
	# write the coordinates
	if crs.Definition.IsProxy is False: # if the definition is local
		for i in range(nlines):
			delta = crs.Definition.YZDataTable.Rows[i][0]
			z     = crs.Definition.YZDataTable.Rows[i][1]
			zmin  = min([z,zmin])
 			x     = x1 + delta*(x2-x1)/wdth
			if vertical_line==False:
				y     = m * (x-x1) + y1
			else:
				y     = m * delta + y1
			tline = '    ' + "{0:.6f}".format(x) + '    ' + "{0:.6f}".format(y) + '    ' + "{0:.2f}".format(z) + '\n'
			profdefxyz.write(tline)
	else:  # If the definition is from a shared profile
		for i in range(nlines): 
			delta = crs.Definition.InnerDefinition.YZDataTable.Rows[i][0]
			z     = crs.Definition.InnerDefinition.YZDataTable.Rows[i][1]
			zmin  = min([z,zmin])
			x     = x1 + delta*(x2-x1)/wdth
			if vertical_line==False:    
				y     = m * (x-x1) + y1
			else:
				y     = m * delta + y1
			tline = '    ' + "{0:.6f}".format(x) + '    ' + "{0:.6f}".format(y) + '    ' + "{0:.2f}".format(z) + '\n'
			profdefxyz.write(tline)
	
	new_line = '    ' + "{0:.7f}".format(xt) + '    ' + "{0:.7f}".format(yt) + '    ' + "{0:.7f}".format(zmin) + '\n'
	thalweg_file.write(new_line)
	# add the profile number
	profnr = profnr+1

profdef.close()	
profloc.close()	
profdefxyz.close()
thalweg_file.close()
conversionlog.close()

# convert the boundary conditions
# copy and read an *.ext template file
copyfile(temp_file, fldr+ fm_name + '.ext')  # copy the template to the FM folder
ext_file = open(fldr+ fm_name + '.ext','a')  # open the *.ext file to write the boundary condition types

fm_bnd_type = ["waterlevelbnd", "velocitybnd", "dischargebnd", "tangentialvelocitybnd", "normalvelocitybnd"]

for condition in Flow1D.BoundaryConditions:
	if condition.DataType.ToString()!='None':
		if str(condition.DataType)=='WaterLevelTimeSeries':
			quantity = "waterlevelbnd"
		elif str(condition.DataType)=='FlowTimeSeries' or str(condition.DataType)=='FlowConstant':
			quantity = "dischargebnd"
		filename = condition.Node.Name
		filetype = "9"
		method   = "3"
		operand  = "O"
		ext_file.write('QUANTITY=' + quantity + '\n')
		ext_file.write('FILENAME=' + condition.Node.Name + '.pli\n')
		ext_file.write('FILETYPE=' + filetype + '\n')
		ext_file.write('METHOD=' + method + '\n')
		ext_file.write('OPERAND=' + operand + '\n')
		ext_file.write('\n')
		
		# make a file with the *.pli
		pli_dict        = dict()
		if len(condition.Node.OutgoingBranches)==0:
			x1   = condition.Node.IncomingBranches[0].Geometry.Coordinates[-1].X
			x2   = condition.Node.IncomingBranches[0].Geometry.Coordinates[-2].X
			y1   = condition.Node.IncomingBranches[0].Geometry.Coordinates[-1].Y
			y2   = condition.Node.IncomingBranches[0].Geometry.Coordinates[-2].Y
		elif len(condition.Node.IncomingBranches)==0:
			x1   = condition.Node.OutgoingBranches[0].Geometry.Coordinates[0].X
			x2   = condition.Node.OutgoingBranches[0].Geometry.Coordinates[1].X
			y1   = condition.Node.OutgoingBranches[0].Geometry.Coordinates[0].Y
			y2   = condition.Node.OutgoingBranches[0].Geometry.Coordinates[1].Y
			
		dist = ((x2-x1)**2 + (y2-y1)**2)**0.5 
		vertical_line = False      # A variable to check the slope of the profile line (whether it is infinity)
		if (x2-x1)!=0 :
			m    = (y2-y1)/(x2-x1)
		else:
			# when the profile is vertical, we replace slope with a +/-1 value
			# which determines whether the distance from the left bank has to be #
			# added or has to be deducted from the y1 of the left bank
			m    = (y2-y1)/wdth
			vertical_line=True            # the profile is a vertical line with slope = infinity
			
		if y2-y1 == 0:
			horizontal_line = True
		else:
			horizontal_line = False
		
		if vertical_line==True:
			xp = x1
			yp = m * fmgridsize/2.0 + y1
			mp = 0                              # the slope of the polygon perpendicular to the branch
			pli_dict['L1']  = [[xp+fmgridsize/4., yp], [xp-fmgridsize/4., yp]]
		elif horizontal_line==True:
			xp = abs(x1-x2)/(x1-x2)*fmgridsize/2.0 + x1
			yp = y1
			pli_dict['L1']  = [[xp, yp+fmgridsize/4.], [xp, yp-fmgridsize/4.]]
		else:
			xp  = x1 + fmgridsize/2.0*(x1-x2)/dist  # the center point of the boundary condition polygo
			yp  = m * (xp-x1) + y1
			mp  = -1./m                             # the slope of the polygon perpendicular to the branch
			xp1 = xp + fmgridsize/6.0
			yp1 = mp * (xp1-xp) + yp
			xp2 = xp - fmgridsize/6.0
			yp2 = mp * (xp2-xp) + yp
			pli_dict['L1']  = [[xp1, yp1], [xp2, yp2]]
				
		write_pli(fname = fldr + condition.Node.Name,pli_dict=pli_dict)
		# write a *.tim file
		if str(condition.DataType)=='WaterLevelTimeSeries' or str(condition.DataType)=='FlowTimeSeries':
			write_tim_file(fname = fldr + condition.Node.Name, timesteps = condition.Data.Time.AllValues,sample  = condition.Data.GetValues(), RefDate = RefDate, timeshift = 0, timeunit='m')
		elif str(condition.DataType)=='WaterLevelConstant' or str(condition.DataType)=='FlowConstant':
			write_tim_file(fname = fldr + condition.Node.Name, timesteps = [Flow1D.StartTime, Flow1D.StopTime],sample  = [condition.Data.AllValues[0],condition.Data.AllValues[0]], RefDate = RefDate, timeshift = 0, timeunit='m')
			
ext_file.close()		



