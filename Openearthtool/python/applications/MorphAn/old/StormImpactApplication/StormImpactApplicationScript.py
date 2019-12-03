dim1D2D = "2D"
filedir = "D:\\"

#dit script runnen, cancel bij inputscherm zorgt voor defaults (zie line 75 tot 105). 1D/2D keuze kan op line 1
#prerequisites:
#	morphan 1.4 installatie (met scripting function and XBeach plugin)
#	zet XBeach Kingsday release (met netcdf) in folder "[MorphAn install path]\plugins\DeltaShell.Plugins.XBeach.Common\XBeach" en delete oude xbeach versie
#	Calamity Function scripts via SVN repository (https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/MorphAn/)
#	hardcoded scriptpath + scriptname voor opendap jarkus retrieve (ook python nodig)
#	strandtenten txt file (shapefile?)
#	matroos rws credentials ('D:\\StormImpactApplication\\matrooscredentials.txt') (or provide in input screen, or work with deltares connection for deltaresmatroos)

#this prototype for a Storm Impact Application was developed by Jelmer Veenstra, a description of the application, as well as an installation and a usage guide is available in the thesis "Operational storm impact forecast information for the coast" (J. Veenstra, 2016) on essay.utwente.nl


from StormImpactApplication.DefinitionsJelmer import *
from Libraries.Utils.Project import PrintMessage
import os


def XBRTShowInputDialog():
	#create a custom input dialog (initially empty except for OK and Cancel button)
	import clr # import our dependencies
	clr.AddReference("System.Windows.Forms")
	from System import *
	from System.Collections.Generic import *
	from DelftTools.Controls.Swf import CustomInputDialog
	from System.Windows.Forms import TextBox
	from System.Windows.Forms import DialogResult
	from System.Windows.Forms import MessageBox
	from System.Windows.Forms import Label
	dialog = CustomInputDialog()
	dialog.Width = 350
	
	from System.Windows.Forms import PictureBox,DockStyle
	from System.Drawing import Bitmap
	
	box = PictureBox()
	box.Width = 50
	box.Height = 100
	box.BringToFront()
	box.Dock = DockStyle.Right
	dialog.Controls.Add(box)
	layout = dialog.Controls[0]

		
	#SCRIPT OPTIONS
	dialog.AddChoice('bathy (iii)', List[String]({'morphanJarkus','opendapJarkus','jarkusKB','BeachWizard'}))
	BeachWizardfile_inp = dialog.AddInput[String]('BeachWizardfile (iii)') #list on http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/beachwizard/output/egmond/catalog.html
	#BeachWizardfile_inp.Tooltip = "egmond.20110730.093000.nc"
	dialog.AddChoice('year (iii)', List[String]({'2015','2014','2013','2012'}))
	raailist_inp = dialog.AddInput[String]('raailist (iiii)')
	raailist_inp.ToolTip = "0 for 2D mode. 1D eg 9795, 11850(separated with commas)"
	dialog.AddChoice('jrkSetName (iiii)', List[String]({'Schiermonnikoog','Ameland','Terschelling','Vlieland','Texel','Noord-Holland','Rijnland','Delfland','Maasvlakte','Voorne','Goeree','Schouwen','Noord-Beveland','Walcheren','Zeeuws-Vlaanderen'}))
	
	dialog.AddChoice('matroos (ii)', List[String]({'deltares','rws'}))
	dialog.AddInput[String]('username')
	dialog.AddInput[String]('password')
	#dialog.AddInput[Double]('kf (ii)')
	tsmat_tstart_inp = dialog.AddInput[Double]('tsmat_tstart (GMT) (iiii)')
	#tsmat_tstart_inp.Tooltip = "In GMT. yyyymmddhhmm, e.g. 201601050000, never specify minutes (always 00 at the end)"
	datahours_inp = dialog.AddInput[Double]('datahours (iiii)')
	#datahours_inp.Tooltip = "amount of hours of data to retrieve from Matroos"
	#datahours2_inp = dialog.Controls.Add(TextBox(Text = "-1.2", Left = 160, Top = 20, Height = 20, Width = 60))
	
	dialog.AddInput[Double]('ny (iiii)')
	dialog.AddInput[Double]('XB_dy (iiii)')
	#dialog.AddInput[Double]('chart_start (i)')
	#dialog.AddInput[Double]('chart_stop (i)')
	dialog.AddInput[Double]('y_sel (i)')
	
	try:
		username = get_varstringlistfromtxt(filedir + 'StormImpactApplication\\matrooscredentials.txt')[0]
		password = get_varstringlistfromtxt(filedir + 'StormImpactApplication\\matrooscredentials.txt')[1]
	except:
		username = None
		password = None
		
	#cancel or close gives default values below
	if dim1D2D == "1D":
		matroos = 'deltares' # deltares // rws , #Let op: Deltares connectie nodig voor deltares matroos! (else Error in urllib.py at line 209 : IOError). Via RWS is met login en kan overal, maar duurt veel langer
		kf = 0 #staat nu niet op kf omdat rws en deltaresmatroos daar minder of later data hebben. kf is wel mooier, dus indien gewenst terugzetten (timestep staat op 1/6, dus niet-kf(dt=1u) wordt geinterpoleerd naar 10min)
		tsmat_tstart = 201503291600 #201601070000 #in GMT! moet op heel uur zijn om waves/tide gelijk te laten beginnen. 201503291600 was lentestormpje, stormpje op 20151115 02:00-04:00 (ook lange aanloop). 201312050000(72h) sinterklaasstorm (niet in deltaresmatroos), 201511171600 harde wind (niet in deltaresmatroos)
		datahours = 48 #48
		bathy = 'morphanJarkus' # morphanJarkus // opendapJarkus # morphanjarkus kan alleen als jarkusdata in project zit, python needed for opendapjarkus (moet eigenlijk in dit script (zonder python), maar netcdf reader kan geen url/opendap bevragen)
		BeachWizardfile = ""
		year = 2013 #for bathymetry
		raailist = [3650, 3675, 3700, 3725, 3750, 3775, 3800] #[9770, 9925, 10025, 11850] #[10025] #[9750, 9770, 9925, 10025, 10200, 10996, 11850] #10883 is midden van zandmotor. strandtenten: [9770, 9795, 9853, 9875, 9897, 9903, 9925, 9975, 9997, 10025, 11850]
		jrkSetName = 'Noord-Holland'
		ny = 0
		XB_dy = 0
		chart_start = 0
		chart_stop = -1
		y_sel = 0

	if dim1D2D == "2D":
		matroos = 'rws' # deltares // rws , #Let op: Deltares connectie nodig voor deltares matroos! (else Error in urllib.py at line 209 : IOError). Via RWS is met login en kan overal, maar duurt veel langer
		kf = 0 #staat nu niet op kf omdat rws en deltaresmatroos daar minder of later data hebben. kf is wel mooier, dus indien gewenst terugzetten (timestep staat op 1/6, dus niet-kf(dt=1u) wordt geinterpoleerd naar 10min)
		tsmat_tstart = 201503291600 #201312051200 #in GMT! moet op heel uur zijn om waves/tide gelijk te laten beginnen. 201503291600 was lentestormpje, stormpje op 20151115 02:00-04:00 (ook lange aanloop). 201312050000(72h) sinterklaasstorm (niet in deltaresmatroos), 201511171600 harde wind (niet in deltaresmatroos)
		datahours = 24
		bathy = 'jarkusKB' # jarkusKB // BeachWizard
		BeachWizardfile = "egmond.20110730.093000.nc" #"egmond.20110730.093000.nc"#BeachWizard file
		year = 2015 #is not used, always most recent bathy (hardcoded in evaluate function, or in plot function because only latest bathy is plotted)
		raailist = [0] #[0] triggers 2D mode
		jrkSetName = 'Delfland'
		ny = 60
		XB_dy = 40
		chart_start = 130
		chart_stop = -1
		y_sel = 1

	PrintMessage("(iiii): alles moet weer opnieuw, incl init/folders")
	PrintMessage("(iii): bathy data verandert (tenzij morphanJarkus naar opendapJarkus), XBrun (en evt matroosRetr) moet weer opnieuw")
	PrintMessage("(ii): niks, data verandert misschien een beetje, maar gebeurt ook bij matroos opnieuw ophalen")
	PrintMessage("(i): niks (alleen invloed op XBOplot)")

	#show dialog and wait for the user to click OK, then retrieve values as filled in by user (using label name)
	if dialog.ShowDialog() == DialogResult.OK:
		matroos = dialog['matroos (ii)']
		try:
			username = int(dialog['username'])
			password = int(dialog['password'])
		except:
			pass
		#kf = int(dialog['kf (i)'])
		kf = 0
		tsmat_tstart = int(dialog['tsmat_tstart (GMT) (iiii)'])
		datahours = int(dialog['datahours (iiii)'])
		bathy = dialog['bathy (iii)']
		BeachWizardfile = dialog['BeachWizardfile (iii)']
		year = int(dialog['year (iii)'])
		raailist = [int(x) for x in dialog['raailist (iiii)'].split(',')]
		jrkSetName = dialog['jrkSetName (iiii)']
		ny = int(dialog['ny (iiii)'])
		XB_dy = int(dialog['XB_dy (iiii)'])
		#chart_start = int(dialog['chart_start (i)'])
		chart_start = 0
		#chart_stop = int(dialog['chart_stop (i)'])
		chart_stop = -1
		y_sel = int(dialog['y_sel (i)'])
	else:
		PrintMessage("CANCEL or CLOSE, so default input values are used")
	
	#create/set current directory
	Stormfolder = "Data_%d_%dh\\" %(tsmat_tstart, datahours)
	if not ".dsproj_data" in str(Application.ProjectDataDirectory):
		#uncomment if tempdir is not allowed
		##os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		#PrintMessage("First save project", level=0)
		#thistextcauseserror
		projectPath = filedir + "StormImpactApplication\\"
		PrintMessage("WARNING: There is no saved project, so StormImpactApplication dir will be used")
	else:
		projectPath = Application.ProjectDataDirectory
	cd = projectPath + Stormfolder
	
	
	#INITIALIZE FOLDERS
	if raailist == [0]:
		PrintMessage("WARNING: raailist=[0], 2D mode enabled")
	else:
		PrintMessage("1D mode")
	for locationOffset in raailist:
		#create folders and use Datafolder as current dir. 
		LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
		if os.path.exists(cd + LocYearfolder + "Bathydata\\") == False:
			os.makedirs(cd + LocYearfolder + "Bathydata\\XBinrun\\")
			os.makedirs(cd + LocYearfolder + "Matroosdata\\")
			os.makedirs(cd + LocYearfolder + "XBmodel\\XBinrun\\")
	
	PrintMessage("folders created at %s" %(cd + LocYearfolder))
	
	
	PrintMessage("XBRTShowinputDialog has finished")
	return matroos, username, password, kf, tsmat_tstart, datahours, bathy, BeachWizardfile, year, raailist, jrkSetName, cd, ny, XB_dy, chart_start, chart_stop, y_sel


def XBRTShowInputValues(matroos, kf, tsmat_tstart, datahours, bathy, BeachWizardfile, year, raailist, jrkSetName, cd, ny, XB_dy, chart_start, chart_stop, y_sel):
	import clr # import our dependencies
	clr.AddReference("System.Windows.Forms")
	from System.Windows.Forms import MessageBox
	MessageBox.Show(' CURRENT INPUT VALUES \n\n matroos = %s \n kf = %d \n tsmat_tstart = %d \n datahours = %d \n\n bathy = %s \n BeachWizardfile = %s \n year = %d \n raailist = %s \n jrkSetName = %s \n\n cd = %s \n\n ny = %d \n XB_dy = %d \n chart_start = %d \n chart_stop = %d \n y_sel = %d' %(matroos, kf, tsmat_tstart, datahours, bathy, BeachWizardfile, year, raailist, jrkSetName, cd, ny, XB_dy, chart_start, chart_stop, y_sel))

	PrintMessage("XBRTShowInputValues has finished")
	return


def XBRT1Dbathy(cd, raailist, year, jrkSetName, ny, bathy): #only place where jrkSetName, locationOffset, year are used outside a string
	from Libraries.MorphAn import TransectOperations
	import subprocess

	if raailist == [0]:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("ERROR: raailist=[0] is 2D, XBRT1Dbathy not possible", level=0)
		thistextcauseserror
	
	for locationOffset in raailist:
		PrintMessage("locationOffset is %d" %locationOffset)
		#use Datafolder as current dir
		LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
		if os.path.exists(cd + LocYearfolder) == False:
			#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
			PrintMessage("No folders available, first run XBRTinit", level=0)
			thistextcauseserror
		os.chdir(cd + LocYearfolder)

		if bathy == 'morphanJarkus':
			# Check if Jarkus available in workspace, load Jarkus bathymetry from MorphAn files
			if RootFolder.Items.Count == 0:
				os.chdir(cd + LocYearfolder)
				PrintMessage("First add workspace (with Jarkus data) as first item in RootFolder", level=0)
				thistextcauseserror
			#itemId = None
			#for item in RootFolder.Items:
			#	if item.MorphAnData.JarkusMeasurementsList.Count == 1:
			#		if not item.MorphAnData.JarkusMeasurementsList.Item[0].Name == "Jarkus measurements":
			#			itemId = item #.Id werkt niet, is altijd 0
			#if itemId == None:
			#	os.chdir(cd + LocYearfolder)
			#	PrintMessage("First add Jarkus data to workspace (must be first item in RootFolder)", level=0)
			#	thistextcauseserror
			if RootFolder.Items[0].MorphAnData.JarkusMeasurementsList.Count == 1 and RootFolder.Items[0].MorphAnData.JarkusMeasurementsList.Item[0].Name == "Jarkus measurements":
				os.chdir(cd + LocYearfolder)
				PrintMessage("First add Jarkus data to workspace (which must be first item in RootFolder)", level=0)
				thistextcauseserror
			
			#get RSP location angle
			location = GetJarkusTransectLocation(jrkSetName,locationOffset)
			#xcoord_RSP = location.X #RD
			#ycoord_RSP = location.Y #RD
			raaihoek_RSP = location.Angle #in degree from north
			
			#get x and z values of entire transect
			x_jrk, z_jrk = GetJarkusTransect(jrkSetName,locationOffset,year)

			#extend Jarkus transect to at least -20m depth in seaward direction
			dx = 20 # x_jrk[-1] - x_jrk[-2] (=10, maar dit is minder gridcellen)
			offshore_slope = 1/50.0
			while z_jrk[-1] > -20:
				z_jrk.append(z_jrk[-1] - offshore_slope * dx)
				x_jrk.append(x_jrk[-1] + dx)
				
			#get coordinates of transect boundary (x[-1] is most seaward x value)
			xcoord_BC, ycoord_BC = TransectOperations.CrossShore2Coordinate(x_jrk[-1],location)
			
			os.chdir(cd + LocYearfolder + "Bathydata\\")
			write_varlisttotxt('x_jrk.txt', x_jrk)
			write_varlisttotxt('z_jrk.txt', z_jrk)
			write_vartotxt('xcoord_BC.txt', xcoord_BC)
			write_vartotxt('ycoord_BC.txt', ycoord_BC)
			write_vartotxt('raaihoek_RSP.txt', raaihoek_RSP)
			if os.path.isfile("xcoord_BC.txt") == False:
				os.chdir(cd + LocYearfolder)
				PrintMessage("No bathy data (eg xcoord_BC) available for %d(%d) (check if transect data exists for this year)" %(locationOffset,year), level=0)
				thistextcauseserror
			os.chdir(cd + LocYearfolder)
			
		if bathy == 'opendapJarkus':
			# load jarkus from opendap with python script and write to files
			areacode = areaname2areacode(jrkSetName)
			areaid = areacode*1e6 + locationOffset
			
			os.chdir(cd + LocYearfolder + "Bathydata\\")
			#python scripts writes x_jrk and z_jrk files including seaward append. Also writes xcoord_BC, ycoord_BC, raaihoek_RSP files
			scriptpath = GetDefaultScriptingPath() + "\\Scripts\\StormImpactApplication\\"
			#scriptpath = "D:\\Scripts\\"
			scriptname = "Python - FROM MORPHAN - opendap Jarkus netCDF profile write varfiles.py"
			command = 'python "%s%s" year %d areaid %d' % (scriptpath, scriptname, year, areaid)
			subprocess.check_call(command) #run and wait to finish
			if os.path.isfile("xcoord_BC.txt") == False:
				os.chdir(cd + LocYearfolder)
				PrintMessage("No bathy data (eg xcoord_BC) available for %d(%d) (remove transect from input and run again, also delete transect folder)" %(locationOffset,year), level=0)
				thistextcauseserror
			x_jrk = get_varlistfromtxt_ony0('x_jrk.txt')
			z_jrk = get_varlistfromtxt_ony0('z_jrk.txt')
			os.chdir(cd + LocYearfolder)
			
		[x_XB, z_XB] = jrktoXB(x_jrk, z_jrk)
		nx = len(x_jrk)-1
		dy_grid = 100
		os.chdir(cd + LocYearfolder + "XBmodel\\")
		writebeddep(z_XB, ny)
		writexgrd(x_XB, ny) #needs z in order to determine wheter to inverse x values
		writeygrd(dy_grid, ny, nx) #create y grid of ny+1 wide, print each value nx+1 times on a separate line
		os.chdir(cd + LocYearfolder)
		
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRT1Dbathy has finished")
	return


def XBRTselJarkusGridKB(cd, raailist, year, bathy):
	from DelftTools.Utils.NetCdf import NetCdfFile
	from System.Collections.Generic import List
	import urllib2, urllib
	
	if raailist != [0]:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("ERROR: raailist is not [0], XBRTselJarkusGridKB not possible", level=0)
		thistextcauseserror
	else:
		locationOffset = int(raailist[0])
	
	LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
	if os.path.exists(cd + LocYearfolder) == False:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("No folders available, first run XBRTinit", level=0)
		thistextcauseserror
	os.chdir(cd + LocYearfolder)
	
	if bathy == "jarkusKB":
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		if os.path.isfile("catalog.nc") == False:
			try:
				catalogurl = "http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/jarkus/grids/catalog.nc"
				urllib.urlretrieve(catalogurl, "catalog.nc")
				PrintMessage("catalog.nc was downloaded")
			except:
				os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
				PrintMessage("catalog.nc is not available, and download failed", level=0)
				thistextcauseserror
		else:
			PrintMessage("catalog.nc already exists")
			
		file = NetCdfFile.OpenExisting("catalog.nc")
		urlPath = file.Read(file.GetVariableByName("urlPath"))
		projectionCoverage_x = file.Read(file.GetVariableByName("projectionCoverage_x"))
		projectionCoverage_y = file.Read(file.GetVariableByName("projectionCoverage_y"))
	
		KBnrlist = List[str]()
		KBurllist = List[str]()
		for KBnr in range(len(urlPath)):
			url = ''.join(urlPath[KBnr])
			url = url.replace('dodsC','fileServer')
			KBnrlist.Add(url[-13:-3])
			KBurllist.Add(url)
		
		os.chdir(cd + LocYearfolder)
		
		###########################################################################
		
		from GisSharpBlog.NetTopologySuite.Geometries import Polygon
		from GisSharpBlog.NetTopologySuite.Geometries import LinearRing
		from GisSharpBlog.NetTopologySuite.Geometries import Coordinate
		from NetTopologySuite.Extensions.Features import Feature
		from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection
		from SharpMap.Data.Providers import FeatureCollection
		from SharpMap.Rendering.Thematics import ThemeFactory
		from SharpMap.Layers import VectorLayer
		from SharpMap.Extensions.Layers import BingLayer, OpenStreetMapLayer
		from Libraries.Utils.Charting import *
		from Libraries.Utils.Gis import *
		from StormImpactApplication.HiddeLibraries.StandardFunctions import *
		from StormImpactApplication.DefinitionsJelmer import *
		
		fList = List[Feature]()
		for i in range(len(urlPath)):
			minX = projectionCoverage_x[i,0]-10 #dimension = [~60,2]
			maxX = projectionCoverage_x[i,1]+10
			minY = projectionCoverage_y[i,0]-10
			maxY = projectionCoverage_y[i,1]+10
			
			coord1 = Coordinate()
			coord1.X = minX
			coord1.Y = minY
			coord2 = Coordinate()
			coord2.X = minX
			coord2.Y = maxY
			coord3 = Coordinate()
			coord3.X = maxX
			coord3.Y = maxY
			coord4 = Coordinate()
			coord4.X = maxX
			coord4.Y = minY
			
			ring = LinearRing((coord1, coord2, coord3, coord4, coord1))
			polygon = Polygon(ring)
			
			feat = Feature(Geometry = polygon)
			feat.Attributes = DictionaryFeatureAttributeCollection()
			feat.Attributes.Add("KBurl",KBurllist[i])
			feat.Attributes.Add("KBnr",KBnrlist[i])
			fList.Add(feat)
			
		fc = FeatureCollection(fList,Feature)
		fc.CoordinateSystem = GetCoordinateSystem(28992)
		layer = VectorLayer()
		layer.DataSource = fc
		layer.Selectable = True
		layer.Theme = ThemeFactory.CreateSingleFeatureTheme(Polygon,Color.FromArgb(20,Color.Brown),3)
		layer.Selectable = True
		layer.Name = "Polygon Jarkus bathy selector"
		
		GetKBnr = GetKBnr()
		GetKBnr.Layer = layer
		
		map = CreateMap()
		map.CoordinateSystem = GetCoordinateSystem(3857)# RD?:28992, WGS84:3857
		map.Layers.Add(layer)
		try:
			backgroundlayer = OpenStreetMapLayer()
			map.Layers.Add(backgroundlayer)
		except:
			pass
		mapview = OpenView(map)
		
		mapview.MapControl.Tools.Add(GetKBnr)
		GetKBnr.IsActive = True
		PrintMessage("Select which Jarkus grid Kaartbladen to download and press ENTER (currently only the first will be used for the other steps)")
	
	else:
		os.chdir(cd + LocYearfolder)
		PrintMessage("XBRTselJarkusGridKB is not yet possible for other bathymetry types than 'jarkusKB'", level=0)
		thistextcauseserror
	
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTselJarkusGridKB has finished")
	return


def XBRTdownload2Dbathy(cd, raailist, year, bathy, BeachWizardfile):
	from DelftTools.Utils.NetCdf import NetCdfFile
	import urllib2, urllib
	
	if raailist != [0]:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("ERROR: raailist is not [0], downloadJarkusKB not possible", level=0)
		thistextcauseserror
	else:
		locationOffset = int(raailist[0])
	
	LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
	if os.path.exists(cd + LocYearfolder) == False:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("No folders available, first run XBRTinit", level=0)
		thistextcauseserror
	os.chdir(cd + LocYearfolder)
	
	if bathy == "jarkusKB":
		if os.path.isfile("JarkusKBnrlist.txt") == False:
			os.chdir(cd + LocYearfolder)
			PrintMessage("JarkusKBnrlist.txt does not exists, first run XBRTselJarkusGridKB", level=0)
			thistextcauseserror
		
		amount_KB = sum(1 for line in open("JarkusKBnrlist.txt"))
		
		for num in range(amount_KB):
			KBnr = get_varstringlistfromtxt("JarkusKBnrlist.txt")[num]
			KBfilename = "jarkus%s.nc" %KBnr
			KBurl = "http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/jarkus/grids/" + KBfilename
			#PrintMessage(KBurl)
		
			os.chdir(cd + LocYearfolder + "Bathydata\\")
			if os.path.isfile(KBfilename) == False:
				try:
					urllib.urlretrieve(KBurl, KBfilename)
					PrintMessage("%s was downloaded" %KBfilename)
				except:
					os.chdir(cd + LocYearfolder)
					PrintMessage("%s is not available, and download failed" %KBfilename, level=0)
					thistextcauseserror
			else:
				PrintMessage("%s already exists locally, so not downloaded" %KBfilename)
			os.chdir(cd + LocYearfolder)
	
	if bathy == "BeachWizard":
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		
		BWurl = "http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/beachwizard/output/egmond/" + BeachWizardfile
	
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		if os.path.isfile(BeachWizardfile) == False:
			try:
				urllib.urlretrieve(BWurl, BeachWizardfile)
				PrintMessage("%s was downloaded" %BeachWizardfile)
			except:
				os.chdir(cd + LocYearfolder)
				PrintMessage("%s is not available, and download failed" %BeachWizardfile, level=0)
				thistextcauseserror
		else:
			PrintMessage("%s already exists locally, so not downloaded" %BeachWizardfile)
		os.chdir(cd + LocYearfolder)
		
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTdownload2Dbathy has finished")
	return
	
#only embedded in other definitions, move to DefinitionsJelmer.py?
def get2Dbathy(cd, raailist, year, bathy, BeachWizardfile, LocYearfolder):
	#GET BATHYMETRY FROM SOURCEFILE AND PLOT ON MAP
	from DelftTools.Utils.NetCdf import NetCdfFile
	from Libraries.Utils.Gis import *
	from NetTopologySuite.Extensions.Grids import CurvilinearGrid
	from SharpMap.Layers import DiscreteGridPointCoverageLayer
	from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
	
	# JARKUS KB BATHYMETRY AND PLOT ON MAP
	#open and read local jarkus grid netcdf file

	if bathy == 'jarkusKB':
		KBnr = get_varstringlistfromtxt("JarkusKBnrlist.txt")[0]
		KBfilename = "jarkus%s.nc" %KBnr
		
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		if os.path.isfile(KBfilename) == False:
			os.chdir(cd + LocYearfolder)
			PrintMessage("%s not available, first run XBRTdownloadJarkusKB" %KBfilename)
			thistextcauseserror
		file = NetCdfFile.OpenExisting(KBfilename)
		os.chdir(cd + LocYearfolder)
		
		# Show all variables and dimensions
		#for var in file.GetVariables():
		#	print file.GetVariableName(var)
		
		# Get and read variables, write to memory
		time = file.Read(file.GetVariableByName("time"))
		time_len = file.GetDimensionLength(file.GetDimension("time"))
		x = file.Read(file.GetVariableByName("x"))
		y = file.Read(file.GetVariableByName("y"))
		z = file.Read(file.GetVariableByName("z"))
		
		#values in comments are for KB118_3736?
		xcoordmin = min(x)-10 #70000
		xcoordmax = max(x)+10 #80000
		ycoordmin = min(y)-10 #450000
		ycoordmax = max(y)+10 #462500

		ntime = 1
		dx = 20
		dy = 20
		nx = (xcoordmax - xcoordmin) / dx #-300
		ny = (ycoordmax - ycoordmin) / dy #-450
		
		#plot bathy data on map with grid
		bathygrid = CreateRegularGridCoverage(nx, ny, dx, dy, xcoordmin, ycoordmin, z, time_len, ntime)
		bathygrid.CoordinateSystem = GetCoordinateSystem(28992)# RD?:28992, WGS84:3857
		layerbathy = CreateRegularGridCoverageLayer(bathygrid)
		layerbathy.Theme = getdefaultbathyTheme()
	
	# BATHYMETRY BEACHWIZARD AND PLOT ON MAP
	if bathy == 'BeachWizard':
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		if os.path.isfile(BeachWizardfile) == False:
			os.chdir(cd + LocYearfolder)
			PrintMessage("%s not available, first run XBRTdownloadJarkusKB" %KBfilename)
			thistextcauseserror
		file = NetCdfFile.OpenExisting(BeachWizardfile)
		os.chdir(cd + LocYearfolder)
		
		BW_nx = 155
		BW_ny = 71
	
		# Show all variables and dimensions
		#for var in file.GetVariables():
		#	print file.GetVariableName(var)
		# Get and read variables, write to memory
		BW_x = file.Read(file.GetVariableByName("x"))
		BW_y = file.Read(file.GetVariableByName("y"))
		BW_z = file.Read(file.GetVariableByName("z"))
		
		bathygrid = CurvilinearGrid(BW_nx, BW_ny, BW_x, BW_y, 'RDnew')
		bathygrid.SetValues(BW_z)
		layerbathy = DiscreteGridPointCoverageLayer()
		layerbathy.Name = 'BeachWizard bathymetry'
		layerbathy.Coverage = bathygrid
		layerbathy.DataSource = _FeatureCollection()
		layerbathy.Theme = getdefaultbathyTheme()
		layerbathy.ShowLines = False
		layerbathy.ShowInLegend = True
		layerbathy.CoordinateSystem = GetCoordinateSystem(28992)# RD?:28992, WGS84:3857
	os.chdir(cd + LocYearfolder)
	#geen message nodig, want alleen embedded
	return bathygrid, layerbathy


def XBRTPlot2DbathyGetcoords(cd, raailist, year, bathy, BeachWizardfile):
	from Libraries.Utils.Gis import *
	
	if raailist != [0]:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("ERROR: raailist is not [0], XBRTPlot2DbathyGetcoords not possible", level=0)
		thistextcauseserror
	else:
		locationOffset = int(raailist[0])
	
	LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
	if os.path.exists(cd + LocYearfolder) == False:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("No folders available, first run XBRTinit", level=0)
		thistextcauseserror
	os.chdir(cd + LocYearfolder)
	
	bathygrid, layerbathy = get2Dbathy(cd, raailist, year, bathy, BeachWizardfile, LocYearfolder)
	
	# GET COORDINATES FROM MAP
	#the getTwoMapCoordinatesTool class/definitions writes the coordland and coordsea to txt files
	#	moet met zelfde dir als standaard (cd+LocYearfolder), omdat de files pas geschreven worden als de definitie afgesloten is (vanuit de map)
	PrintMessage("Select transect coordinates, first click the landward coordinate and then seaward (click within the bathymetry data)")
	getTwoMapCoordinatesTool = GetTwoMapCoordinatesTool()
	featureLayer = CreateLayerForFeatures("Points",[],None)
	featureLayer.Style.Line.Color = Color.Red
	featureLayer.Style.Line.Width = 3
	getTwoMapCoordinatesTool.Layer = featureLayer
	
	# MAKE MAP WITH LAYERS
	map1 = CreateMap()
	map1.CoordinateSystem = GetCoordinateSystem(28992)# RD?:28992, WGS84:3857
	map1.Layers.Add(featureLayer)
	map1.Layers.Add(layerbathy)
	map1.ZoomToFit(layerbathy.Envelope,True)
	
	#ShowMap(map1)
	mapview = OpenView(map1)
	mapview.MapControl.SelectTool.IsActive = False
	mapview.MapControl.Tools.Add(getTwoMapCoordinatesTool)
	getTwoMapCoordinatesTool.IsActive = True
	

	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTPlotbathyGetcoords has finished")
	return


def XBRTplot2DbathyWrXB(cd, raailist, year, bathy, BeachWizardfile, ny, XB_dy):
	import numpy as np
	from System.Collections.Generic import List
	#from NetTopologySuite.Extensions.Coverages import CurvilinearCoverage
	from NetTopologySuite.Extensions.Grids import CurvilinearGrid
	from SharpMap.Layers import CurvilinearGridLayer
	from SharpMap.Layers import DiscreteGridPointCoverageLayer
	from GisSharpBlog.NetTopologySuite.Geometries import Coordinate
	from DeltaShell.Plugins.XBeach.Common.Models import GridOptimizationSettings
	from DeltaShell.Plugins.MorphAn.Domain import Transect
	from DeltaShell.Plugins.XBeach.Common.Models import XBeach1DModelBaseHelper
	from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
	import System
	from Libraries.Utils.Gis import CreateMap, GetCoordinateSystem, CreateLinesLayer
	import math
	
	if raailist != [0]:
		#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
		PrintMessage("ERROR: raailist is not [0], XBRTplot2DbathyWrXB not possible", level=0)
		thistextcauseserror
	else:
		locationOffset = int(raailist[0])
	
	LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
	if os.path.exists(cd + LocYearfolder) == False:
		PrintMessage("No folders available, first run XBRTinit", level=0)
		thistextcauseserror
	os.chdir(cd + LocYearfolder)
	
	bathygrid, layerbathy = get2Dbathy(cd, raailist, year, bathy, BeachWizardfile, LocYearfolder)
	
	#check if user defined coordinates (with click in map) are available, and load them
	if os.path.isfile("XB_coordland.txt") == False:
		os.chdir(cd + LocYearfolder)
		PrintMessage("No user coordinate files (eg XB_coordland.txt) available for %d(%d) (first run getbathyPlotbathyGetcoords)" %(locationOffset,year), level=0)
		thistextcauseserror
	XB_coordland = get_varlistfromtxt_ony0('XB_coordland.txt')
	XB_coordsea = get_varlistfromtxt_ony0('XB_coordsea.txt')
	PrintMessage("XB_coordland = [%f, %f]" %(XB_coordland[0], XB_coordland[1]))
	PrintMessage("XB_coordsea = [%f, %f]" %(XB_coordsea[0], XB_coordsea[1]))
	
	diffx = XB_coordland[0]-XB_coordsea[0]
	diffy = XB_coordland[1]-XB_coordsea[1]
	distx = abs(diffx)
	disty = abs(diffy)
	alpharad_raw = np.arctan(float(disty)/distx) # is omgekeerd tov normale XB rotatie, maar is in lijn met kustrotatie tov Noorden
	if diffx > 0 and diffy < 0:
		alpharadC = alpharad_raw # 0to90deg
	if diffx < 0 and diffy < 0:
		alpharadC = math.pi - alpharad_raw #180to90deg
	if diffx > 0 and diffy > 0:
		alpharadC = -alpharad_raw #0to-90deg
	if diffx < 0 and diffy > 0:
		alpharadC = -math.pi + alpharad_raw #-180to-90deg
	if diffx == 0 or diffy == 0:
		os.chdir(cd + LocYearfolder)
		PrintMessage("baseline is too straight, get other coords", level=0)
		thistextcauseserror
	
	alphadegC = alpharadC*180/math.pi
	os.chdir(cd + LocYearfolder + "Bathydata\\")
	write_vartotxt('raaihoek_RSP.txt', alphadegC)
	os.chdir(cd + LocYearfolder)
	
	PrintMessage('alphadegC is: %f (the coastline rotation w.r.t North)' %alphadegC)
	if alphadegC == 45 or alphadegC == 135 or alphadegC == 225 or alphadegC == 315:
		os.chdir(cd + LocYearfolder)
		PrintMessage("alphadegC is exactly 45/135/225/315deg, get new coords in Plot2DbathyGetcoords", level=0)
		thistextcauseserror
	
	#also show the red (and orange) baselines
	line = CreateLineGeometry( [ [XB_coordland[0], XB_coordland[1]],[XB_coordsea[0], XB_coordsea[1]] ] )
	userlinelayer = CreateLinesLayer('baseline', line)
	userlinelayer.Style.Line.Color = Color.Red
	userlinelayer.Style.Line.Width = 3
	#userlinelayer.CoordinateSystem = GetCoordinateSystem(28992)# RD?:28992, WGS84:3857 # kan niet, is read only, maar is al RD
	line2_xland = XB_coordland[0] + ny*XB_dy*np.sin(alpharadC)
	line2_yland = XB_coordland[1] + ny*XB_dy*np.cos(alpharadC)
	line2_xsea  = XB_coordsea[0]  + ny*XB_dy*np.sin(alpharadC)
	line2_ysea  = XB_coordsea[1]  + ny*XB_dy*np.cos(alpharadC)
	line2 = CreateLineGeometry( [ [line2_xland, line2_yland],[line2_xsea, line2_ysea] ] )
	userlinelayer2 = CreateLinesLayer('baseline_otherside', line2)
	userlinelayer2.Style.Line.Color = Color.Orange
	userlinelayer2.Style.Line.Width = 3
	#userlinelayer2.CoordinateSystem = GetCoordinateSystem(28992)# RD?:28992, WGS84:3857 # kan niet, is read only, maar is al RD



	if bathy == 'jarkusKB':
		dxstr = 20
	if bathy == 'BeachWizard':
		dxstr = 10
	
	dx0deg = dxstr*abs(np.cos(alpharadC))
	#prevent rounding dx0deg to let it become zero (happens if the angle is very close to 90deg)
	if dx0deg < 1:
		dx0deg = 1
		
	# GET ONE TRANSECT FROM BATHY TO DETERMINE DX
	if diffx > 0:
		xx_len = range(int(XB_coordsea[0]), int(XB_coordland[0])+1, int(dx0deg)) # to determine the length (amount of elements) of the transect
	else:
		xx_len = range(int(XB_coordland[0]), int(XB_coordsea[0])+1, int(dx0deg)) # to determine the length (amount of elements) of the transect
	PrintMessage("String properties: dx0deg=%fm, nx_str=%d" %(float(dx0deg), len(xx_len)))
	xx = np.linspace(XB_coordsea[0], XB_coordland[0], len(xx_len))
	dx0deg = abs(xx[0] - xx[1])
	yy = np.linspace(XB_coordsea[1], XB_coordland[1], len(xx_len))
	
	#get dxstr (dx of the one transect) and make a string with this dx
	dxstr = dx0deg/abs(np.cos(alpharadC))
	xxb = [x * float(dxstr) for x in range(0, len(xx))] #range from 0 to len(xx)*dxstr, with step dxstr

	#convert to floats for grid function:
	xrt = List[float]()
	for i in range(0,len(xx)):
		xrt.Add(xx[i])
	yrt = List[float]()
	for i in range(0,len(yy)):
		yrt.Add(yy[i])
	
	gridstr = CurvilinearGrid(1, float(len(xx)), xrt, yrt, 'RDnew')
	gridstr.CoordinateSystem = GetCoordinateSystem(28992)# RD?:28992, WGS84:3857
	gridstrbathy = [x*0.0 for x in range(0,len(xx))]
	for xloc in range(0,len(xx)):
		#print i
		coord = Coordinate()
		coord.X = gridstr.X.Values[xloc]
		coord.Y = gridstr.Y.Values[xloc]
		gridstrbathy[xloc] = bathygrid.Evaluate(coord) #moet ICoordinate zijn, 0,0 werkt niet
		#print i, coord.X, coord.Y, xloc, yloc, bathymetry[xloc,yloc]
	
	if gridstrbathy == []:
		os.chdir(cd + LocYearfolder)
		PrintMessage("Try XBRTPlot2DbathyGetcoords again, click within the available data (gridstrbathy == [])", level=0)
		thistextcauseserror
	if gridstrbathy[0] == None or gridstrbathy[-1] == None:
		os.chdir(cd + LocYearfolder)
		PrintMessage("Try XBRTPlot2DbathyGetcoords again, click within the available data (gridstrbathy[0 or -1] == None)", level=0)
		thistextcauseserror
	if gridstrbathy[0] > 1000 or gridstrbathy[-1] > 1000:
		os.chdir(cd + LocYearfolder)
		PrintMessage("Try XBRTPlot2DbathyGetcoords again, click within the available data (gridstrbathy[0 or -1] > 1000)", level=0)
		thistextcauseserror
		
	layerstr = CurvilinearGridLayer()
	layerstr.Name = 'gridstr'
	layerstr.CurviLinearGrid = gridstr
	
	XBgridsettings = GridOptimizationSettings()
	XBgridsettings.DepthFactor = 2
	XBgridsettings.NonHydrosatic = False
	XBgridsettings.DxMaximum = 30 #60
	XBgridsettings.DxMinimal = 3 #3 #5 or according to Pieter even 2 (for dry points)
	XBgridsettings.DxDryPoints = XBgridsettings.DxMinimal
	XBgridsettings.PointsPerWaveLength = 12
	XBgridsettings.ZMinimal = -20
	XBgridsettings.OffshoreSlope = 1/100.0
	
	transect = Transect(xxb,gridstrbathy)
	#XBeach1DModelBaseHelper.GenerateComputationGridAndBathymetry(ITransect transect, double waterLevel, double peakPeriod, double waveHeight, GridOptimizationSettings settings = null)
	optimalGridTransect = XBeach1DModelBaseHelper.GenerateComputationGridAndBathymetry(transect, 0, 5, 5, XBgridsettings)
	xoptimal = optimalGridTransect.XCoordinates
	zoptimal = optimalGridTransect.ZCoordinates
	transect_xlen = -xoptimal[0] + xoptimal[-1] #distance in m from most seaward to landward transect coordinates
	#print transect_xlen, -xoptimal[0], xoptimal[-1]
	PrintMessage(transect_xlen)
		


	
	#DEFINE EXTRA SIDE PARTS YLEN TO AVOID SHADOW ZONE IN INTEREST ZONE
	t_gr_deg_max = 50
	t_gr_deg_min = -50
	t_gr_max = t_gr_deg_max*math.pi/180
	t_gr_min = t_gr_deg_min*math.pi/180
	fac = 1.2
	
	#calculate extra y points at baseline1 (red) side
	yextra1_min = -transect_xlen*np.tan(t_gr_min)
	yextra1 = []
	yextra1.append(0)
	i = 1
	while yextra1[-1] > -yextra1_min:
	    yextra1.append(yextra1[-1] - XB_dy*fac**(i))
	    i = i + 1
	yextra1 = yextra1[::-1]
	yextra1 = yextra1[1:-1]
	
	#calculate extra y points at baseline2 (blue) side
	yextra2_min = transect_xlen*np.tan(t_gr_max)
	yextra2 = []
	yextra2.append(ny*XB_dy)
	i = 1
	while yextra2[-1] < yextra2_min+ny*XB_dy:
	    yextra2.append(yextra2[-1] + XB_dy*fac**(i))
	    i = i + 1
	yextra2 = yextra2[1:-1]
	
	ybegin = 0
	ystart = len(yextra1)
	ystop = ystart+(ny+1)
	yend = ystop+len(yextra2)
	PrintMessage("ny=%d, yextend1=%d, yextend2=%d, nytot=%d" %(ny, len(yextra1), len(yextra2), yend-1))

	
	#CREATE XB GRID with RD coordinates  
	xrt = List[float]()
	yrt = List[float]()
	
	#for n in range(ny+1):
	for n in range(yend):
		if 0 <= n < ystart:
			xcoordO = XB_coordsea[0] + yextra1[n]*np.sin(alpharadC)
			ycoordO = XB_coordsea[1] + yextra1[n]*np.cos(alpharadC)		
		if ystart <= n < ystop:
			nlocal = n-ystart
			xcoordO = XB_coordsea[0] + XB_dy*nlocal*np.sin(alpharadC)
			ycoordO = XB_coordsea[1] + XB_dy*nlocal*np.cos(alpharadC)
		if ystop <= n < yend:
			nlocal = n-ystop
			xcoordO = XB_coordsea[0] + yextra2[nlocal]*np.sin(alpharadC)
			ycoordO = XB_coordsea[1] + yextra2[nlocal]*np.cos(alpharadC)
		#print xcoordO, ycoordO
		xoptimalworld = [(xcoordO + x*np.cos(alpharadC)) for x in optimalGridTransect.XCoordinates]
		yoptimalworld = [(ycoordO - x*np.sin(alpharadC)) for x in optimalGridTransect.XCoordinates]
		for i in range(0,len(xoptimalworld)):
			xrt.Add(xoptimalworld[i])
			yrt.Add(yoptimalworld[i])
	
	
	#BC coordinates for Matroos data, write to vars
	middleseaward_index = yend/2*len(xoptimal) + 1
	
	xcoord_BC = xrt[middleseaward_index]
	ycoord_BC = yrt[middleseaward_index]
	os.chdir(cd + LocYearfolder + "Bathydata\\")#XBgridsettings.DxMinimal
	write_vartotxt('xcoord_BC.txt', xcoord_BC)
	write_vartotxt('ycoord_BC.txt', ycoord_BC)
	#raaihoek_RSP = alphadegC + 270
	#write_vartotxt('raaihoek_RSP.txt', raaihoek_RSP)
	os.chdir(cd + LocYearfolder)
	
	
	
	nx = len(xoptimal)-1
	PrintMessage('nx is: %d' %nx)
	nx_f = float(nx)
	ny_f = float(ny)
	nytot = yend-1
	nytot_f = float(nytot)
	
	os.chdir(cd + LocYearfolder + "Bathydata\\")#XBgridsettings.DxMinimal
	write_vartotxt('nytot.txt', nytot)
	os.chdir(cd + LocYearfolder)
	
	
	#grid_XB = CurvilinearGrid(ny_f+1, nx_f+1, xrt, yrt, 'RDnew') #X en Y zijn omgekeerd
	grid_XB = CurvilinearGrid(nytot_f+1, nx_f+1, xrt, yrt, 'RDnew') #X en Y zijn omgekeerd
	grid_XB.CoordinateSystem = GetCoordinateSystem(28992)
	
	# CREATE BATHYMETRY VARIABLE
	#bathymetry = System.Array.CreateInstance(float, ny+1, nx+1) #X en Y zijn omgekeerd, want hoogte is eerste indexnr
	bathymetry = System.Array.CreateInstance(float, yend, nx+1) #X en Y zijn omgekeerd, want hoogte is eerste indexnr
	#yflat = 10
	if diffx > 0:
		#xstart = next(x[0] for x in enumerate(grid_XB.X.Values) if x[1] > XB_coordsea[0]) #werkt niet goed met curved grid
		xstart = next(x[0] for x in enumerate(xoptimal) if x[1] > 0)
	else:
		#xstart = next(x[0] for x in enumerate(grid_XB.X.Values) if x[1] < XB_coordsea[0]) #werkt niet goed met curved grid
		xstart = next(x[0] for x in enumerate(xoptimal) if x[1] < 0)
	for yloc in range(0,yend):
		for xloc in range(xstart,nx+1):
			if yloc in range(0,ystart):
				i = ystart *(nx+1) + xloc
			if yloc in range(ystart,ystop):
				i = yloc*(nx+1) + xloc
			if yloc in range(ystop, yend):
				i = ystop *(nx+1) + xloc
			coordXB = Coordinate()
			coordXB.X = grid_XB.X.Values[i]
			coordXB.Y = grid_XB.Y.Values[i]
			
			if bathy == 'jarkusKB':
				if diffx > 0:
					xplus = next(x[0] for x in enumerate(list(bathygrid.X.Values)) if x[1] > grid_XB.X.Values[i])
				else:
					xplus = next(x[0] for x in enumerate(list(bathygrid.X.Values)) if x[1] > grid_XB.X.Values[i])
				if diffy > 0:
					yplus = next(x[0] for x in enumerate(list(bathygrid.Y.Values)) if x[1] > grid_XB.Y.Values[i])
				else:
					yplus = next(x[0] for x in enumerate(list(bathygrid.Y.Values)) if x[1] > grid_XB.Y.Values[i])
				
				xlocs = [xplus-1, xplus, xplus, xplus-1]
				ylocs = [yplus-1, yplus-1, yplus, yplus]
				zb = []
				dist = []
				invdist = []
				for locs in range(4):
					coordb = Coordinate()
					coordb.X = bathygrid.X.Values[xlocs[locs]]
					coordb.Y = bathygrid.Y.Values[ylocs[locs]]
					zb.append(bathygrid.Evaluate(coordb))
					dist.append(coordb.Distance(coordXB))
				#inverse distance weighing for the four surrounding points (werkt allen voor regulargrids!)
				bathymetry[yloc, xloc] = (zb[0]/dist[0]**2 +
										  zb[1]/dist[1]**2 +
										  zb[2]/dist[2]**2 +
										  zb[3]/dist[3]**2 )/(1/dist[0]**2 +
										  					  1/dist[1]**2 +
										  					  1/dist[2]**2 +
										  					  1/dist[3]**2 )
			if bathy == 'BeachWizard':
				bathymetry[yloc, xloc] = bathygrid.Evaluate(coordXB) #X en Y zijn omgekeerd, want hoogte is eerste indexnr   #moet ICoordinate zijn, 0,0 werkt niet
				
		for xloc in range(xstart):
			testtest = 1
			bathymetry[yloc,xloc] = zoptimal[xloc]
	
	#PrintMessage(bathymetry[1,1])
	#PrintMessage(bathymetry[1,10])
	#PrintMessage(bathymetry[1,100])
	#PrintMessage(bathymetry[1,xstart])
	
	
	#"""
	# write xbeach input files
	os.chdir(cd + LocYearfolder + "XBmodel\\")
	writebeddep2D(nx, nytot, bathymetry)
	writexgrd2D(xrt, nx, nytot)
	writeygrd2D(yrt, nx, nytot)
	os.chdir(cd + LocYearfolder)
	
	
	# EVALUATE BATHY TO XBGRID
	grid_XB.SetValues(bathymetry)
	#layerxbval = CreateCurvilinearCoverageLayer()
	#layerxbval = CurvilinearGridLayer()
	layerxbval = DiscreteGridPointCoverageLayer()
	layerxbval.Name = 'XBeach grid values'
	layerxbval.Coverage = grid_XB
	layerxbval.DataSource = _FeatureCollection()
	layerxbval.Theme = getdefaultbathyTheme()
	layerxbval.ShowLines = True
	layerxbval.ShowFaces = True
	layerxbval.ShowVertices = False
	#layerxbval.CoordinateSystem = GetCoordinateSystem(28992)
	
	# add xbrid to map
	map2 = CreateMap()
	map2.CoordinateSystem = GetCoordinateSystem(28992)# RD:28992, WGS84:3857
	map2.Layers.Add(layerstr)
	map2.Layers.Add(userlinelayer)
	map2.Layers.Add(userlinelayer2)
	map2.Layers.Add(layerxbval)
	map2.Layers.Add(layerbathy)
	map2.ZoomToFit(layerxbval.Envelope,True)
	
	#ShowMap(map2)
	mapview = OpenView(map2)
	#"""
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTplot2DbathyWrXB has finished")
	return


def XBRTmatroosRetr(cd, raailist, year, tsmat_tstart, datahours, matroos, kf, username, password):
	from multiprocessing.dummy import Pool
	import shutil
	import urllib2, urllib, base64
	import time
	
	PrintMessage("RWsOS data is being retrieved, this takes 5-20 seconds per transect") #wordt achteraf geprint, ook met PrintMessage, ook als dit in de SC definition staat ipv hier
	
	for locationOffset in raailist:
		#use Datafolder as current dir
		LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
		if os.path.exists(cd + LocYearfolder) == False:
			#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
			PrintMessage("No folders available, first run XBRTinit", level=0)
			thistextcauseserror
		os.chdir(cd + LocYearfolder)
		
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		if os.path.isfile("xcoord_BC.txt") == False:
			os.chdir(cd + LocYearfolder)
			PrintMessage("No bathy data (eg xcoord_BC) available for %d(%d) (first run XBRT1Dbathy or 'XBRT 2D bathy')" %(locationOffset,year), level=0)
			thistextcauseserror
		xcoord_BC = get_varfromtxt('xcoord_BC.txt')
		ycoord_BC = get_varfromtxt('ycoord_BC.txt')
		#raaihoek_RSP = get_varfromtxt('raaihoek_RSP.txt')
		os.chdir(cd + LocYearfolder)
		############################################################################################################
		############# retrieve tide and wave timeseries matroos file from web and write to files ################
		############################################################################################################
		tsmat_dt_Sep = 1.0/6 #timestep in hours, als <1 dan float maken ipv doubles. If smaller than available timestep, values are interpolated if interp_time=1
		tsmat_dt_waves = 1
		names = ['Sep','Hm0','th0','tm10']#,'swellHm0']
		urls = []
		
		days, hours = divmod(datahours, 24)
		tsmat_tstop = tsmat_tstart + days*10000 + hours*100 #never sure if the data exists up to tstop, so safety is built in later on (tsmat_real_tstop)
		#source=dcsmv6_zunov4_zuno_kf_hirlam (10min interval) or source=dcsmv6_zunov4_zuno_hirlam (60min interval) for waterlevel (sep), xvel (VELU), yvel (VELV)
		#source=swan_zuno (60min interval) for wave DIR (wave_dir_th0), HSIG (wave_height_hm0), HSWELL (swellwave_height_hm0), TM_10 (wave_period_tm10), waterlevel from dcsmv6_zuno(waterlevel)
		if kf == 1:
			sources = ['dcsmv6_zunov4_zuno_kf_hirlam','swan_zuno','swan_zuno','swan_zuno','swan_zuno']
		if kf == 0:
			sources = ['dcsmv6_zunov4_zuno_hirlam','swan_zuno','swan_zuno','swan_zuno','swan_zuno']
		units = ['sep','wave_height_hm0','wave_dir_th0','wave_period_tm10']#,'swellwave_height_hm0']
		tsmat_dt = [tsmat_dt_Sep, tsmat_dt_waves, tsmat_dt_waves, tsmat_dt_waves, tsmat_dt_waves]
		#tsmat_remote_path_all = [tsmat_remote_path_Sep, tsmat_remote_path_Hm0, tsmat_remote_path_th0, tsmat_remote_path_tm10, tsmat_remote_path_swellHm0]
		#tsmat_file_all = [tsmat_file_Sep, tsmat_file_Hm0, tsmat_file_th0, tsmat_file_tm10, tsmat_file_swellHm0]
		if matroos == 'deltares':
			tsmat_base_url = "http://matroos.deltares.nl/direct/get_map2series.php?"
			PrintMessage("Deltares RWsOS is used, Deltares connection needed")
		if matroos == 'rws':
			tsmat_base_url = "http://matroos.rws.nl/direct/get_map2series.php?"
			PrintMessage("RWS RWsOS is used, RWS matroos credentials needed")
		
		parallel = 1
		if parallel == 0:
			for var in range(4):
				tsmat_getVars = {
				'source': sources[var],
				'unit': units[var],
				'coordsys': 'RD', 'x': xcoord_BC, 'y': ycoord_BC,
				'tinc': tsmat_dt[var] * 60, 'interp_time': 1, #if interp_time is used without tinc, values are interpolated to 10min values (dont comment, tsmat_time is written with tsmat_dt)
				'tstart': tsmat_tstart, 'tstop': tsmat_tstop}
				tsmat_remote_path = str(tsmat_base_url + urllib.urlencode(tsmat_getVars))
				tsmat_file = "Matroos%s.txt" %names[var]
				if matroos == 'deltares':
					os.chdir(cd + LocYearfolder + "Matroosdata\\")
					urllib.urlretrieve(tsmat_remote_path, "Matroos%s.txt" %names[var])
					os.chdir(cd + LocYearfolder)
					if var == 0:
						tsmat_remote_path_img = "http://matroos.deltares.nl/matroos/php/image_series.php?type=image&source_id=%s&loc_id=%f,%f,RD&unit_id=SEP&colors=blue&ymin=0&ymax=0&pic_max_x=600&pic_max_y=320&database=maps2d&gap=1&tstart=%d&tstop=%d&anal_time=000000000000" %(sources[var], xcoord_BC, ycoord_BC, tsmat_tstart, tsmat_tstop)
						urllib.urlretrieve(tsmat_remote_path_img, "chartMatroosRetr.png")
				if matroos == 'rws':
					os.chdir(cd + LocYearfolder + "Matroosdata\\")
					#PrintMessage(os.getcwd())
					req = urllib2.Request(tsmat_remote_path)
					req.add_header("Authorization", "Basic %s" % base64.encodestring('%s:%s' % (username, password)).replace('\n', ''))
					
					tsmat_filecontent = urllib2.urlopen(req).read()
					file = open("Matroos%s.txt" %names[var],'w')
					file.write(tsmat_filecontent)
					file.close()
					os.chdir(cd + LocYearfolder)
					if var == 0:
						tsmat_remote_path_img = "http://matroos.rws.nl/matroos/php/image_series.php?type=image&source_id=%s&loc_id=%f,%f,RD&unit_id=SEP&colors=blue&ymin=0&ymax=0&pic_max_x=600&pic_max_y=320&database=maps2d&gap=1&tstart=%d&tstop=%d&anal_time=000000000000" %(sources[var], xcoord_BC, ycoord_BC, tsmat_tstart, tsmat_tstop)
						urllib.urlretrieve(tsmat_remote_path_img, "chartMatroosRetr.png")
		
		if parallel == 1:
			if matroos == 'deltares':
				tsmat_base_url = "http://matroos.deltares.nl/direct/get_map2series.php?"
			if matroos == 'rws':
				tsmat_base_url = "http://matroos.rws.nl/direct/get_map2series.php?"
			
			for var in range(4):
				tsmat_getVars = {
				'source': sources[var],
				'unit': units[var],
				'coordsys': 'RD', 'x': xcoord_BC, 'y': ycoord_BC,
				'tinc': tsmat_dt[var] * 60, 'interp_time': 1, #if interp_time is used without tinc, values are interpolated to 10min values (dont comment, tsmat_time is written with tsmat_dt)
				'tstart': tsmat_tstart, 'tstop': tsmat_tstop}
				tsmat_remote_path = str(tsmat_base_url + urllib.urlencode(tsmat_getVars))
				if matroos == 'deltares':
					urls.append(tsmat_remote_path)
					if var == 0:
						tsmat_remote_path_img = "http://matroos.deltares.nl/matroos/php/image_series.php?type=image&source_id=%s&loc_id=%f,%f,RD&unit_id=SEP&colors=blue&ymin=0&ymax=0&pic_max_x=600&pic_max_y=320&database=maps2d&gap=1&tstart=%d&tstop=%d&anal_time=000000000000" %(sources[var], xcoord_BC, ycoord_BC, tsmat_tstart, tsmat_tstop)
				if matroos == 'rws':
					req = urllib2.Request(tsmat_remote_path)
					req.add_header("Authorization", "Basic %s" % base64.encodestring('%s:%s' % (username, password)).replace('\n', ''))
					urls.append(req)
					if var == 0:
						tsmat_remote_path_img = "http://matroos.rws.nl/matroos/php/image_series.php?type=image&source_id=%s&loc_id=%f,%f,RD&unit_id=SEP&colors=blue&ymin=0&ymax=0&pic_max_x=600&pic_max_y=320&database=maps2d&gap=1&tstart=%d&tstop=%d&anal_time=000000000000" %(sources[var], xcoord_BC, ycoord_BC, tsmat_tstart, tsmat_tstop)
			urls.append(tsmat_remote_path_img) #moet hier want moet achteraan geappend
			
			os.chdir(cd + LocYearfolder + "Matroosdata\\")
			if matroos == 'deltares':
				result = Pool(5).map(urllib.urlretrieve, urls)
			if matroos == 'rws':
				result = Pool(5).map(urllib2.urlopen, urls)
				
			for var in range(4):
				if matroos == 'deltares':
					tsmat_file = "Matroos%s.txt" %names[var]
					shutil.copy(result[var][0], tsmat_file)
				if matroos == 'rws':
					with open("Matroos%s.txt" %names[var],'w') as file:
						file.write(result[var].read())
			os.chdir(cd + LocYearfolder)
			
			#write chartMatroosRetr to file, or provide link
			if matroos == 'deltares':
				shutil.copy(result[4][0], "chartMatroosRetr.png") #6e ding is de image
			if matroos == 'rws':
				write_varstringlisttotxt("chartMatroosRetr.txt", [tsmat_remote_path_img, ""])
				PrintMessage("chartMatroosRetr.png cannot be retrieved from rws matroos yet in parallel mode (a link is provided in the current folder). Hacks: disable parallel or uncomment extra retrieve (both making the retrieve slower)")
				#urllib.urlretrieve(tsmat_remote_path_img, "chartMatroosRetr.png") #is al binnen dus dit is niet nodig, het werkt wel maar laat het langer duren
			
		os.chdir(cd + LocYearfolder + "Matroosdata\\")
		RetrTime = time.strftime('%Y%m%d%H%M', time.gmtime()) #in GMT
		write_vartotxt('RetrTime.txt', float(RetrTime))
		
		#check for missing, empty or too small Matroos (Sep+waves) files (wordt ook bij matroosWrXBandPl gedaan, en missing gebeurt hier waarschijnlijk niet)
		for var in range(4):
			if os.path.isfile("Matroos%s.txt" %names[var]) == False:
				os.chdir(cd + LocYearfolder)
				PrintMessage("No Matroos%s.txt data file available for %d(%d) (first run XBRTmatroosRetr)" %(names[var],locationOffset,year), level=0)
				thistextcauseserror
			if os.stat("Matroos%s.txt" %names[var]).st_size == 0:
				os.chdir(cd + LocYearfolder)
				PrintMessage("Empty Matroos%s.txt data file for %d (%d) (check if the requested period is available in the Matroos database, or switch from kf=1 to kf=0)" %(names[var], locationOffset, year), level=0)
				thistextcauseserror
			if os.stat("Matroos%s.txt" %names[var]).st_size < 600:
				os.chdir(cd + LocYearfolder)
				PrintMessage("Too small Matroos%s.txt data file for %d (%d) (check if the requested period is available in the Matroos database)" %(names[var], locationOffset, year), level=0)
				thistextcauseserror
		os.chdir(cd + LocYearfolder)
		
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTmatroosRetr has finished")
	return


def XBRTmatroosWrXBandPl(cd, raailist, year, jrkSetName, ny, tsmat_tstart, datahours): #jrkSetName only for plot title
	import time
	import numpy as np
	from Libraries.Utils.Charting import *
		
	for locationOffset in raailist:
		############# Write matroos txt files to vars and plot
		############# Write matroos txt files to XBeach input files. Write params.txt
		
		#use Datafolder as current dir
		LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
		if os.path.exists(cd + LocYearfolder) == False:
			#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
			PrintMessage("No folders available, first run XBRTinit", level=0)
			thistextcauseserror
		os.chdir(cd + LocYearfolder)
		
		# copied from retrievematroos:
		tsmat_dt_Sep = 1.0/6 #timestep in hours, als <1 dan float maken ipv doubles. If smaller than available timestep, values are interpolated if interp_time=1
		tsmat_dt_waves = 1
		Mat_chart_dx_Sep = int(1/tsmat_dt_Sep)
		names = ['Sep','Hm0','th0','tm10'] #,'swellHm0']
		
		os.chdir(cd + LocYearfolder + "Bathydata\\")
		#xcoord_BC = get_varfromtxt('xcoord_BC.txt')
		#ycoord_BC = get_varfromtxt('ycoord_BC.txt')
		raaihoek_RSP = get_varfromtxt('raaihoek_RSP.txt')
		os.chdir(cd + LocYearfolder)
		
		os.chdir(cd + LocYearfolder + "Matroosdata\\")
		for var in range(4):
			#check for missing, empty or too small Matroos (Sep+waves) files (wordt ook bij matroosRetr gedaan, dus empty and too small gebeurt hier waarschijnlijk niet)
			if os.path.isfile("Matroos%s.txt" %names[var]) == False:
				os.chdir(cd + LocYearfolder)
				PrintMessage("No Matroos%s.txt data file available for %d(%d) (first run XBRTmatroosRetr)" %(names[var],locationOffset,year), level=0)
				thistextcauseserror
			if os.stat("Matroos%s.txt" %names[var]).st_size == 0:
				os.chdir(cd + LocYearfolder)
				PrintMessage("Empty Matroos%s.txt data file for %d (%d) (check if the requested period is available in the Matroos database, or switch from kf=1 to kf=0)" %(names[var], locationOffset, year), level=0)
				thistextcauseserror
			if os.stat("Matroos%s.txt" %names[var]).st_size < 600:
				os.chdir(cd + LocYearfolder)
				PrintMessage("Too small Matroos%s.txt data file for %d (%d) (check if the requested period is available in the Matroos database)" %(names[var], locationOffset, year), level=0)
				thistextcauseserror
		tsmat_Sep = np.loadtxt("Matroos%s.txt" %names[0], delimiter='   ', unpack=True)[1] #extract from file (# rows are ommitted)
		tsmat_Hm0 = np.loadtxt("Matroos%s.txt" %names[1], delimiter='   ', unpack=True)[1]
		tsmat_th0 = np.loadtxt("Matroos%s.txt" %names[2], delimiter='   ', unpack=True)[1]
		tsmat_tm10 = np.loadtxt("Matroos%s.txt" %names[3], delimiter='   ', unpack=True)[1]
		#tsmat_swellHm0 = np.loadtxt("Matroos%s.txt" %names[4], delimiter='   ', unpack=True)[1]
		RetrTime = int(get_varfromtxt('RetrTime.txt'))
		ATimeSep = getAnalysisTimefromtxt('MatroosSep.txt')
		ATimeHm0 = getAnalysisTimefromtxt('MatroosHm0.txt')
		Plottime = int(time.strftime('%Y%m%d%H%M', time.gmtime()))
		os.chdir(cd + LocYearfolder)
		
		tsmat_thetamax = max(tsmat_th0)
		tsmat_thetamin = min(tsmat_th0)
		tsmat_thetadiff = tsmat_thetamax - tsmat_thetamin
		PrintMessage("tsmat_thetamax = %f, tsmat_thetamin = %f, tsmat_thetadiff = %f" %(tsmat_thetamax, tsmat_thetamin, tsmat_thetadiff))
		
		len_Sep = int( tsmat_dt_Sep * (len(tsmat_Sep)-1) )
		len_waves = int( tsmat_dt_waves * (len(tsmat_Hm0)-1) )
		XB_wave_dir = tsmat_th0 #- raaihoek_RSP + 270 #geen conversie nodig want coords zijn al in RD, dus hoek komt goed. moet wel thetanaut=1 optie in params.txt, voor nautical conventie voor hoeken (tov N)
		
		#ommit last Sep data to make XBeach run possible when timeseries are not equal
		if len_waves == len_Sep:
			if len_Sep == datahours:
				PrintMessage("Length of waterlevel and wave timeseries is equal to given datahours parameter (%dh)" %datahours)
			else:
				PrintMessage("Length of waterlevel and wave timeseries (%dh) is shorter than the requested datalength (%dh) because of availablility" %(len_waves, datahours))
		if not len_waves == len_Sep: # equals "else:"
			if len_waves < len_Sep:
				PrintMessage("Waterlevel timeseries is longer (tsmat_Sep, %dh) than wave timeseries (tsmat_Hm0, %dh), last water level values are ommitted to make XBeach run possible. This (new) length is also shorter than the requested datalength (%dh)" %(len_Sep, len_waves, datahours))
				len_Sep_new = len_waves / tsmat_dt_Sep + 1
				tsmat_Sep = tsmat_Sep[0:len_Sep_new]
			if len_waves > len_Sep:
				os.chdir(cd + LocYearfolder)
				PrintMessage("Waterlevel timeseries is shorter (%dh) than wave timeseries (%dh), no quickfix built in" %(len_Sep, len_waves), level=0)
				thistextcauseserror
	
		tsmat_real_tstop = int(tsmat_dt_Sep * (len(tsmat_Sep)-1) * 3600)
		tsmat_time_Sep = range(0, tsmat_real_tstop+1, int(tsmat_dt_Sep * 3600)) #fixed dt value is used to make time vector for XBeach (in seconds, starting at 0)
		
		###### PLOT MATROOS DATA
		
		chartMat = CreateChart()
		chartMat.Name = "Matroos data"
		chartMat.Title = "Matroos data for %s (for %dh of requested %dh), on %d (%d) in %s" % (tsmat_tstart, len_Sep, datahours, locationOffset, year, jrkSetName) #\nAnalysis time is %d/%d, Retrieved on %d, Plottime is %d (all GMT)  , ATimeSep, ATimeHm0, RetrTime, Plottime)
		chartMat.TitleVisible = 1
		chartMat.BottomAxis.Title = "Time in hours from %d" %tsmat_tstart
		chartMat.LeftAxis.Title = "Waterlevel [m], Wave heigth [m], Wave period [s]"
		chartMat.RightAxis.Title = "Wave angle [degree w.r.t North]"
		chartMat.RightAxis.Automatic = False
		chartMat.RightAxis.Minimum = 0
		chartMat.RightAxis.Maximum = 360
		chartMat.Legend.Visible = 1
		chartMat.Legend.Alignment = LegendAlignment.Top

		#draw vertical line for Plottime and RetrTime
		minval = float(min(tsmat_Sep))
		maxval = float(max(tsmat_Sep))

		PT_dtime = Plottime-tsmat_tstart
		days, hourmin = divmod(PT_dtime, 10000)
		hours, minutes = divmod(hourmin, 100)
		PT_dtime_hours = days*24.0 + hours + minutes/60.0
		if not PT_dtime_hours > datahours:
			series = AddToChartAsLine(chartMat, [PT_dtime_hours,PT_dtime_hours], [minval,maxval], "Plottime")
		else:
			series = AddToChartAsLine(chartMat, [0,0], [0,0], "Plottime")
		series.Width = 1
		series.PointerVisible = 0
		series.Color = Color.Red
		RT_dtime = RetrTime-tsmat_tstart
		days, hourmin = divmod(RT_dtime, 10000)
		hours, minutes = divmod(hourmin, 100)
		RT_dtime_hours = days*24.0 + hours + minutes/60.0
		if not RT_dtime_hours > datahours:
			series = AddToChartAsLine(chartMat, [RT_dtime_hours,RT_dtime_hours], [minval,maxval], "Retrieve time")
		else:
			series = AddToChartAsLine(chartMat, [0,0], [0,0], "Retrieve time")
		series.Width = 1
		series.PointerVisible = 0
		series.Color = Color.Blue
		series = AddToChartAsLine(chartMat, [0,datahours], [0,0], "zero line")
		series.Color = Color.Black
		#series.ShowInLegend = False #werkt niet
		series.PointerVisible = 0
		series = AddToChartAsLine(chartMat, [x*tsmat_dt_Sep for x in range(len(tsmat_Sep))], tsmat_Sep, "tsmat_Sep")
		series.Color = Color.Blue

		series.Width = 2
		series.PointerVisible = 0
		
		ShowChart(chartMat)
		chartMat.ExportAsImage("chartMatroosDataSimple.png",1000,500)
		
		series = AddToChartAsLine(chartMat, range(0, len(tsmat_Hm0)), tsmat_Hm0, "tsmat_Hm0")
		series.Color = Color.DarkBlue
		series.Width = 2
		series.PointerVisible = 0
		#series = AddToChartAsLine(chartMat, range(0, len(tsmat_swellHm0)), tsmat_swellHm0,"tsmat_swellHm0")
		#series.Width = 2
		#series.PointerVisible = 0
		series = AddToChartAsLine(chartMat, range(0, len(tsmat_Hm0)), tsmat_Sep[0::Mat_chart_dx_Sep] + 0.5*tsmat_Hm0,"WL + 0.5*Hm0")
		series.Color = Color.Red
		series.Width = 2
		series.PointerVisible = 0
		series = AddToChartAsLine(chartMat, range(0, len(tsmat_th0)), tsmat_th0, "tsmat_th0 hoek tov Noorden")
		series.Color = Color.Orange
		series.Width = 2
		series.PointerVisible = 0
		series.VertAxis = VerticalAxis.Right
		series = AddToChartAsLine(chartMat, range(0, len(tsmat_tm10)), tsmat_tm10, "tsmat_tm10 periode")
		series.Color = Color.Green
		series.Width = 2
		series.PointerVisible = 0
		ShowChart(chartMat)
		
		#grid van de rightaxis uitzetten (code van pieter, uit de achterkamertjes van C#):
		view = None
		for v in Gui.DocumentViews:
			if v.Data == chartMat:
				view = v
		teeChart = view.Controls[0]
		teeChart.Axes.Right.Grid.Visible = False
		
		chartMat.ExportAsImage("chartMatroosData.png",1000,500)
		
		if raailist == [0]:
			os.chdir(cd + LocYearfolder + "Bathydata\\") #defines where to write new files to default (after MorphAn restart is the MorphAn program files folder)
			nytot = int(get_varfromtxt('nytot.txt'))
			os.chdir(cd + LocYearfolder)
		else:
			nytot = ny

		
		#CHANGE DIR FOR XBEACH MODEL INPUT
		os.chdir(cd + LocYearfolder + "XBmodel\\") #defines where to write new files to default (after MorphAn restart is the MorphAn program files folder)
		x_XB = get_varlistfromtxt_ony0('x.grd')
		y_XB = get_varlistfromtxt_ony0('y.grd')
		x_len = len(x_XB)
		nx = x_len - 1
		if raailist == [0]:
			snells = 0
			thetamin = -50 - raaihoek_RSP
			thetamax = 50 - raaihoek_RSP
			dtheta = 20
		else:
			snells = 1 #induces snellius law for refraction etc, only useful in 1D or very longshore uniform 2D settings
			thetamin = -90 - raaihoek_RSP
			thetamax = 90 - raaihoek_RSP
			dtheta = 180
		
		
		XBO_tint = 1800 #30 mins, staat ook bij XBRTrunXBOplot
		xb_tstart = 0
		xbo_globalvars = ['zb','H','u','v',''] #moeten er altijd vijf zijn!
		xbo_meanvars = ['H','zs','u','v','hh']  #moeten er altijd vijf zijn! #evt hh voor waterdiepte, maar is nooit nul (min 0.005m)
		writeparamstxt(nx, nytot, snells, thetamin, thetamax, dtheta, tsmat_real_tstop, XBO_tint, xb_tstart, xbo_globalvars, xbo_meanvars)
		
		with open('tide.txt','w') as tidetxt:
			for i in range(0,len(tsmat_Sep)):
				
				#edits for sensitivity analysis:
				#tsmat_Sep[i] = tsmat_Sep[i]+1.00
				
				#tsmat_Sep[i] = tsmat_Sep[i]-0.15
				#tsmat_Sep[i] = tsmat_Sep[i]+0.15
				#tsmat_Sep[i] = tsmat_Sep[i]-0.30
				#tsmat_Sep[i] = tsmat_Sep[i]+0.30
				
				tidetxt.write('%e %e %e' %(tsmat_time_Sep[i], tsmat_Sep[i], -5)) #-5 is waterlevel (tide) aan landward side, zodat binnenduinse gedeeltes niet onder water staan.
				tidetxt.write('\n')
		tidetxt.close()
		
		tsmat_dt_waves_lst = tsmat_dt_waves *3600
		with open('waves.lst','w') as waveslst:
			for i in range(0,len(tsmat_Hm0)-1): # min1, anders is er een uur te lang aan golven (geen error maar dit is netter). Komt doordat waves.lst lines met golfcondities voor een uur bevat en tsmat_Hm0 bevat golfcondities aan het begin van ieder uur, laatste regel daarvan valt buiten simulatie en kan dus genegeerd worden.
				#<Hm0+swellHm0> <Tp = Tm-1.0 * 1.1> <mainang> <gammajsp> <s> <duration> <dtbc>
				
				#edits for sensitivity analysis:
				#tsmat_Hm0[i] = tsmat_Hm0[i]/1.04
				#tsmat_Hm0[i] = tsmat_Hm0[i]/1.04*1.16
				#tsmat_Hm0[i] = tsmat_Hm0[i]/1.04*0.84
				#tsmat_tm10[i] = tsmat_tm10[i]/0.88
				#tsmat_tm10[i] = tsmat_tm10[i]/0.88*1.09
				#tsmat_tm10[i] = tsmat_tm10[i]/0.88*0.91
				#tsmat_Hm0[i] = tsmat_Hm0[i]/1.04*1.32
				#tsmat_Hm0[i] = tsmat_Hm0[i]/1.04*0.68
				#tsmat_tm10[i] = tsmat_tm10[i]/0.88*1.18
				#tsmat_tm10[i] = tsmat_tm10[i]/0.88*0.72
				
				waveslst.write('%f %f %d %f %f %e %f' %(tsmat_Hm0[i], tsmat_tm10[i]*1.1, XB_wave_dir[i], 3.3, 10.0, tsmat_dt_waves_lst, 1.0))
				waveslst.write('\n')
		waveslst.close()
		os.chdir(cd + LocYearfolder)
		
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTmatroosWrXBandPl has finished")
	return


def XBRTrunXBmodel(cd, raailist, year):
	import subprocess
	import shutil
	
	for locationOffset in raailist:
		#use Datafolder as current dir
		LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
		if os.path.exists(cd + LocYearfolder) == False:
			#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
			PrintMessage("No folders available, first run XBRTinit", level=0)
			thistextcauseserror
		os.chdir(cd + LocYearfolder)

		os.chdir(cd + LocYearfolder + "\\XBmodel\\")
		#check if params.txt is available
		if os.path.isfile("params.txt") == False:
			os.chdir(cd + LocYearfolder)
			PrintMessage("No XBeach input file (params.txt) available for %d(%d) (first run XBRTmatroosWrXBandPl)" %(locationOffset,year), level=0)
			thistextcauseserror
		
		#check if all XBfiles are up to date (compare files from 1Dbathy/XBRTplot2DbathyWrXB with matroosWrXBandPl
		nx_paramstxt, ny_paramstxt = get_nxnyfromparamstxt("params.txt")
		nx_xgrd, ny_xgrd = get_nxnyfromxgrd("x.grd")
		if nx_paramstxt != nx_xgrd:
			os.chdir(cd + LocYearfolder)
			PrintMessage("nx_xgrd (%d) differs from nx_paramstxt (%d), run WrXBvars(matroos) and/or bathy again" %(nx_xgrd, nx_paramstxt), level=0)
			thistextcauseserror
		else:
			if ny_paramstxt != ny_xgrd:
				os.chdir(cd + LocYearfolder)
				PrintMessage("ny_xgrd (%d) differs from ny_paramstxt (%d), run WrXBvars(matroos) and/or bathy again" %(ny_xgrd, ny_paramstxt), level=0)
				thistextcauseserror
			else:
				PrintMessage("XBeach ready to start with nx=%d/%d and ny=%d/%d" %(nx_paramstxt, nx_xgrd, ny_paramstxt, ny_xgrd))
		if os.path.isfile("xboutput.nc") == True and os.path.isfile("xboutput_overwrite.txt") == False:
			os.chdir(cd + LocYearfolder)
			PrintMessage("there is already XBeach output (xboutput.nc), first delete this file to start a new run. Or create a file named 'xboutput_overwrite.txt' in %s" %(cd + LocYearfolder), level=0)
			thistextcauseserror
		os.chdir(cd + LocYearfolder)
		
		try:
			os.chdir(cd + LocYearfolder + "\\Bathydata\\")
			shutil.copyfile('x_jrk.txt', 'XBinrun\\x_jrk.txt')
			shutil.copyfile('z_jrk.txt', 'XBinrun\\z_jrk.txt')
			os.chdir(cd + LocYearfolder)
		except:
			os.chdir(cd + LocYearfolder)
			
		os.chdir(cd + LocYearfolder + "\\XBmodel\\")
		shutil.copyfile('bed.dep', 'XBinrun\\bed.dep')
		shutil.copyfile('params.txt', 'XBinrun\\params.txt')
		shutil.copyfile('tide.txt', 'XBinrun\\tide.txt')
		shutil.copyfile('waves.lst', 'XBinrun\\waves.lst')
		shutil.copyfile('x.grd', 'XBinrun\\x.grd')
		shutil.copyfile('y.grd', 'XBinrun\\y.grd')
		
		# Run XBeach model
		waitXBmodel = 0
		if waitXBmodel == 0:
			subprocess.Popen(GetXBeachExecutablePath() + "\\XBeach\\xbeach.exe") # run and continue
		if waitXBmodel == 1:
			subprocess.check_call(GetXBeachExecutablePath() + "\\XBeach\\xbeach.exe") # run and wait to finish
		os.chdir(cd + LocYearfolder)

	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTrunXBmodel has finished (XBeach model is now running externally)")
	return


def XBRTrunXBOplot(cd, raailist, year, jrkSetName, ny, tsmat_tstart, datahours, chart_start, chart_stop, y_sel): #jrkSetName only for plot title
	from Libraries.Utils.Charting import CreateChart, LegendAlignment, AddToChartAsPolygon, AddToChartAsLine, AddToChartAsArea, ShowChart
	import numpy as np
	from DelftTools.Utils.NetCdf import NetCdfFile
	for locationOffset in raailist:
		#create folders and use Datafolder as current dir
		LocYearfolder = "%d_(%d)\\" %(locationOffset, year)
		if os.path.exists(cd + LocYearfolder) == False:
			#os.chdir(cd + LocYearfolder) #deze map bestaat nog niet
			PrintMessage("No folders available, first run XBRTinit", level=0)
			thistextcauseserror
		os.chdir(cd + LocYearfolder)
		
		############################################################################################################
		############# CHAPTER READ AND PLOT NETCDF XBOUTPUT.nc ######################################################################
		############################################################################################################
		os.chdir(cd + LocYearfolder + "\\XBmodel\\")		
		ncXBoutputfile = "xboutput.nc"
		if os.path.isfile(ncXBoutputfile) == False:
			PrintMessage("No NetCDF XBeach output file available for %d(%d) (first run XBRTrunXBmodel)" %(locationOffset,year), level=0)
			#raise Exception("No NetCDF XBeach output file available for %d(%d) (first run XBRTrunXBmodel)" %(locationOffset,year))
		with open("XBlog.txt") as file:
			line = file.readlines()[-1]
			if line.startswith("  End of "):
				PrintMessage("XBeach model has properly finished, plot is available")
			else:
				PrintMessage("XBeach model has not (properly) finished yet (run XBRTrunXBmodel again and/or first let it finish)", level=0)
		
		file = NetCdfFile.OpenExisting(ncXBoutputfile)
		
		# Show all variables
		#for var in file.GetVariables():
		#	print file.GetVariableName(var)
		
		# Get and read variables, write to memory
		xbo_x = file.Read(file.GetVariableByName("globalx"))
		xbo_y = file.Read(file.GetVariableByName("globaly"))
		xbo_time = file.Read(file.GetVariableByName("globaltime"))
		xbo_zb = file.Read(file.GetVariableByName("zb"))
		xbo_H_max_temp = file.Read(file.GetVariableByName("H_max")) #[tintm/tint, ny+1, cross_shore]
		#xbo_H_min_temp = file.Read(file.GetVariableByName("H_min"))
		xbo_zs_max_temp = file.Read(file.GetVariableByName("zs_max"))
		xbo_zs_min_temp = file.Read(file.GetVariableByName("zs_min"))
		xbo_u_max_temp = file.Read(file.GetVariableByName("u_max"))
		xbo_u_min_temp = file.Read(file.GetVariableByName("u_min"))
		xbo_v_max_temp = file.Read(file.GetVariableByName("v_max"))
		xbo_v_min_temp = file.Read(file.GetVariableByName("v_min"))
		#xbo_hh = file.Read(file.GetVariableByName("hh_max"))
		os.chdir(cd + LocYearfolder)
		
		if y_sel > ny:
			PrintMessage("y_sel(%d) is larger than ny(%d), choose lower y_sel" %(y_sel, ny), level=0)
		else:
			PrintMessage("y_sel=%d is plotted, possible range from ny=0 to ny=%d" %(y_sel, ny))
		
		os.chdir(cd + LocYearfolder + "XBmodel\\XBinrun\\")
		x_XB = get_varlistfromtxt_onysel('x.grd',y_sel)
		os.chdir(cd + LocYearfolder)
		x_len = len(x_XB)
		PrintMessage("nx=%d for chart" %(x_len-1))
		
		if chart_stop > x_len:
			PrintMessage("chart_stop(%d) is larger than x_len(%d), choose lower chart_stop" %(chart_stop, x_len), level=0)
		else:
			PrintMessage("chart_start=%d to chart_stop=%d is plotted, possible chart_stop range from chart_start to x_len=%d (end=-1)" %(chart_start, chart_stop, x_len))
		if chart_stop != -1:
			if chart_stop > chart_start:
				continue
			else:
				PrintMessage("chart_start (%d) is smaller then chart_stop (%d), adjust values" %(chart_start, chart_stop), level=0)
			
		XBO_tint = 1800 #30 mins, staat ook bij XBRTmatroosWrXBandPl
		xbo_tstop = max(xbo_time) #was ook defined in retrieveMatroos part as tsmat_real_tstop
		xbo_time_len = xbo_tstop / XBO_tint #number of timesteps in XBeach output, depends on timestep tint defined in params.txt
		
		xbo_H_max = np.empty(shape=[x_len])
		#xbo_H_min = np.empty(shape=[x_len]) # is altijd 0
		xbo_zs_max = np.empty(shape=[x_len])
		xbo_zs_min = np.empty(shape=[x_len])
		xbo_u_max = np.empty(shape=[x_len])
		xbo_u_min = np.empty(shape=[x_len])
		xbo_v_max = np.empty(shape=[x_len])
		xbo_v_min = np.empty(shape=[x_len])
		xbo_uv_maxabs = np.empty(shape=[x_len])

		for i in range(0, x_len):
			xbo_H_max[i] = xbo_H_max_temp[0,y_sel,i]
			#xbo_H_min[i] = xbo_H_min_temp[0,y_sel,i] # is altijd 0
			xbo_zs_max[i] = xbo_zs_max_temp[0,y_sel,i]
			xbo_zs_min[i] = xbo_zs_min_temp[0,y_sel,i]
			xbo_u_max[i] = xbo_u_max_temp[0,y_sel,i]
			xbo_u_min[i] = xbo_u_min_temp[0,y_sel,i]
			xbo_v_max[i] = xbo_v_max_temp[0,y_sel,i]
			xbo_v_min[i] = xbo_v_min_temp[0,y_sel,i]
			xbo_uv_abs = [ xbo_u_max[i], abs(xbo_u_min[i]), xbo_v_max[i], abs(xbo_v_min[i]) ]
			xbo_uv_maxabs[i] = max(xbo_uv_abs)
		
		xbo_maxzs_plusH = list(xbo_zs_max + 0.5*xbo_H_max)
		#PrintMessage(xbo_maxzs_plusH)
		xbo_maxzs_minH = list(xbo_zs_max - 0.5*xbo_H_max)
		xbo_minzs_plusH = xbo_zs_min + 0.5*xbo_H_max
		xbo_minzs_minH = xbo_zs_min - 0.5*xbo_H_max
		
		chart = CreateChart()
		chart.Name = "XBeach result"
		chart.Title = "XBeach result for %s (for %dh of requested %dh), on %d (%d) in %s, on y_sel=%d" % (tsmat_tstart, xbo_tstop/3600, datahours, locationOffset, year, jrkSetName, y_sel) #xbo_time_len/3600 is hetzelfde als len_sep in writeMatroos
		chart.TitleVisible = 1
		chart.BottomAxis.Title = "Cross-shore distance w.r.t. RSP [m]"
		chart.LeftAxis.Title = "Bed level w.r.t NAP, water level, wave height [m]. Velocity [m/s]"
		chart.Legend.Visible = 1
		chart.Legend.Alignment = LegendAlignment.Top
		
		#series = AddToChartAsLine(chart,x_XB[chart_start:chart_stop],z_XB2[chart_start:chart_stop],"Jarkusraai bed.dep")
		#series = AddToChartAsLine(chart,x_jrk,z_jrk,"Jarkusraai MorphAn project") #spiegelbeeld tov XBeach raaien
		#series.Color = Color.SandyBrown
		#series.Width = 2
		#series.PointerVisible = 0
		
		if raailist == [0]:
			PrintMessage("Buildingdata not yet available for 2D mode", level=1)
			PrintMessage("XBOutput not yet available on map 2D mode", level=1)
			#load xbeach output file
			xaxis = x_XB[::-1]
		
		else:
			os.chdir(cd + LocYearfolder + "Bathydata\\XBinrun\\")
			x_jrk = get_varlistfromtxt_ony0('x_jrk.txt')
			#z_jrk = get_varlistfromtxt_ony0('z_jrk.txt')
			os.chdir(cd + LocYearfolder)
			xaxis = x_jrk
		
			try:
				#read values from txt files for strandtenten
				STpath = filedir + "StormImpactApplication\\"
				STraailist = list(np.loadtxt(STpath + "strandtenten.txt", delimiter=None, unpack=True)[0])
				STxsealist = list(np.loadtxt(STpath + "strandtenten.txt", delimiter=None, unpack=True)[1])
				STxlandlist = list(np.loadtxt(STpath + "strandtenten.txt", delimiter=None, unpack=True)[2])
				STid = STraailist.index(locationOffset)
				STxsea = STxsealist[STid] #x_XB[-x_jrk.index(STxsealist[STid])] #latter for x_XB instead of x_jrk
				STxland = STxlandlist[STid] #x_XB[-x_jrk.index(STxlandlist[STid])] #latter for x_XB instead of x_jrk
				STymin = xbo_zb[0,y_sel,-x_jrk.index(STxsealist[STid])]
				STymax = STymin + 2
				polygon = AddToChartAsPolygon(chart, [STxsea, STxsea, STxland , STxland, STxsea], [STymax, STymin, STymin, STymax, STymax], 'strandtent')
			except:
				PrintMessage("no building data available for locationOffset/raai %d" %locationOffset)
		
		#plot H enveloppe around zs max
		series = AddToChartAsPolygon(chart, (xaxis[::-1][chart_start:chart_stop] + xaxis[::-1][chart_start:chart_stop][::-1]), (xbo_maxzs_plusH[chart_start:chart_stop] + xbo_maxzs_minH[chart_start:chart_stop][::-1]), "maxH_enveloppe")
		series.Color = Color.DarkBlue
		series.Transparency = 80
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_maxzs_plusH[chart_start:chart_stop],"maxzs_plusH")
		series.PointerVisible = 0
		series.Color = Color.Blue
		series.Width = 2
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_maxzs_minH[chart_start:chart_stop],"maxzs_minH")
		series.PointerVisible = 0
		series.Color = Color.Blue
		series.Width = 2
		
		#plot zs min en max
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_zs_max[chart_start:chart_stop],"zs_max")
		series.PointerVisible = 0
		series.Color = Color.LightSkyBlue
		series.Width = 3
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_zs_min[chart_start:chart_stop],"zs_min")
		series.PointerVisible = 0
		series.Color = Color.LightSkyBlue	
		series.Width = 3
		
		#plot velocity u and v
		"""
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_u_max[chart_start:chart_stop],"max u")
		series.PointerVisible = 0
		series.Color = Color.Red
		series.Width = 1
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_v_max[chart_start:chart_stop],"max v")
		series.PointerVisible = 0
		series.Color = Color.Yellow
		series.Width = 1
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_u_min[chart_start:chart_stop],"min u")
		series.PointerVisible = 0
		series.Color = Color.Red
		series.Width = 1
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_v_min[chart_start:chart_stop],"min v")
		series.PointerVisible = 0
		series.Color = Color.Yellow
		series.Width = 1
		"""
		series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_uv_maxabs[chart_start:chart_stop],"max uv abs")
		series.PointerVisible = 0
		series.Color = Color.DarkOrange
		series.Width = 2
		
		#plot timesteps of zb
		xbo_t_out = 5 #number of timesteps after init condition
		for times in range(0, xbo_t_out+1):
			xbo_zb_tx = np.empty(shape=[x_len])
			for i in range(0,x_len):
				xbo_zb_tx[i] = xbo_zb[float(times)/xbo_t_out * xbo_time_len, y_sel,i]
			if times == 0:
				area = AddToChartAsArea(chart,xaxis[::-1][chart_start:chart_stop],xbo_zb_tx[chart_start:chart_stop],"zb_tx%d" %times)
				area.LineWidth = 0
				area.Color = Color.SandyBrown
				area.Transparency = 50
			else:
				series = AddToChartAsLine(chart, xaxis[::-1][chart_start:chart_stop], xbo_zb_tx[chart_start:chart_stop],"zb_tx%d" %times)
				series.PointerVisible = 0
				if times == xbo_t_out:
					series.Width = 2

		minval = min(xbo_zb_tx[chart_start:chart_stop])
		maxval = max(xbo_zb_tx)
	
		#get and plot waterline
		h = np.empty(shape=[x_len])
		for i in range(0,len(h)):
			h[i] = xbo_zs_max[i] - xbo_zb[-1,y_sel,i]
		WLid = next((i for i, x in enumerate(h) if x == 0), None)
		line = AddToChartAsLine(chart, [xaxis[::-1][WLid], xaxis[::-1][WLid]], [minval, maxval], 'WLpoint')
		line.Width = 2
		line.Color = Color.DarkRed
		line.PointerVisible = 0
		
		ShowChart(chart)
		
		if raailist != [0]:
			view = None
			for v in Gui.DocumentViews:
				if v.Data == chart:
					view = v
			teeChart = view.Controls[0]
			teeChart.Axes.Bottom.Inverted = True
		
		chart.ExportAsImage("chartXBresult.png",1000,500)
		
	os.chdir(cd + LocYearfolder)
	PrintMessage("XBRTrunXBOplot has finished")
	return




#################################################
#GUI INITIALIZATION
#################################################

#from StormImpactApplication.StormImpactApplication import *
#from Libraries.Utils.Shortcuts import *
from StormImpactApplication.ShortcutsJelmer import *

RemoveShortcut("Show InputDialog", "Setup")
RemoveShortcut("Show InputValues", "Setup")
RemoveShortcut("1Dbathy", "1D Bathymetry")
RemoveShortcut("selJarkus GridKB", "2D Bathymetry")
RemoveShortcut("Plot2Dbathy Getcoords", "2D Bathymetry")
RemoveShortcut("download 2Dbathy", "2D Bathymetry")
RemoveShortcut("plot2Dbathy WrXB", "2D Bathymetry")
RemoveShortcut("matroos Retr", "RWsOS Matroos")
RemoveShortcut("matroos WrXBandPl", "RWsOS Matroos")
RemoveShortcut("runXB model", "XBeach model")
RemoveShortcut("runXBO plot", "XBeach model")

matroos, username, password, kf, tsmat_tstart, datahours, bathy, BeachWizardfile, year, raailist, jrkSetName, cd, ny, XB_dy, chart_start, chart_stop, y_sel = XBRTShowInputDialog()
#onderstaande geeft geen output
def SC_XBRTShowInputDialog():
	PrintMessage("This button is broken, but the input dialog appears when running the main script again", level=0)
	#
	return #
AddShortcut("Show InputDialog", "Setup", SC_XBRTShowInputDialog, None)

def SC_XBRTShowInputValues():
	XBRTShowInputValues(matroos, kf, tsmat_tstart, datahours, bathy, BeachWizardfile, year, raailist, jrkSetName, cd, ny, XB_dy, chart_start, chart_stop, y_sel)
AddShortcut("Show InputValues", "Setup", SC_XBRTShowInputValues, None)

def SC_XBRT1Dbathy():
	XBRT1Dbathy(cd, raailist, year, jrkSetName, ny, bathy)
AddShortcut("1Dbathy", "1D Bathymetry", SC_XBRT1Dbathy, None)

def SC_XBRTselJarkusGridKB():
	XBRTselJarkusGridKB(cd, raailist, year, bathy)
AddShortcut("selJarkus GridKB", "2D Bathymetry", SC_XBRTselJarkusGridKB, None)

def SC_XBRTdownload2Dbathy():
	XBRTdownload2Dbathy(cd, raailist, year, bathy, BeachWizardfile)
AddShortcut("download 2Dbathy", "2D Bathymetry", SC_XBRTdownload2Dbathy, None)

def SC_XBRTPlot2DbathyGetcoords():
	XBRTPlot2DbathyGetcoords(cd, raailist, year, bathy, BeachWizardfile)
AddShortcut("Plot2Dbathy Getcoords", "2D Bathymetry", SC_XBRTPlot2DbathyGetcoords, None)

def SC_XBRTplot2DbathyWrXB():
	XBRTplot2DbathyWrXB(cd, raailist, year, bathy, BeachWizardfile, ny, XB_dy)
AddShortcut("plot2Dbathy WrXB", "2D Bathymetry", SC_XBRTplot2DbathyWrXB, None)

def SC_XBRTmatroosRetr():
	XBRTmatroosRetr(cd, raailist, year, tsmat_tstart, datahours, matroos, kf, username, password)
AddShortcut("matroos Retr", "RWsOS Matroos", SC_XBRTmatroosRetr, None)

def SC_XBRTmatroosWrXBandPl():
	XBRTmatroosWrXBandPl(cd, raailist, year, jrkSetName, ny, tsmat_tstart, datahours)
AddShortcut("matroos WrXBandPl", "RWsOS Matroos", SC_XBRTmatroosWrXBandPl, None)

def SC_XBRTrunXBmodel():
	XBRTrunXBmodel(cd, raailist, year)
AddShortcut("runXB model", "XBeach model", SC_XBRTrunXBmodel, None)

def SC_XBRTrunXBOplot():
	XBRTrunXBOplot(cd, raailist, year, jrkSetName, ny, tsmat_tstart, datahours, chart_start, chart_stop, y_sel)
AddShortcut("runXBO plot", "XBeach model", SC_XBRTrunXBOplot, None)


PrintMessage("Click on the shortcuts that have just appeared")
