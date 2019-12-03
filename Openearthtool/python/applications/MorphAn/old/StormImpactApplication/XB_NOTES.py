BEGIN OF RECOMMENDATION PART
#region TODO
#	check if opendap jarkustransect script is available and give error if not
#inputscherm
#	default/current values maken voor inputscherm, cancel resulteert nu in default values maar dat is niet intuitief. OK bij lege values geeft crash (doordat raailist leeg blijft) waarbij vals niet veranderen, is dus de eigenlijke cancel
#	tooltips: zie comments. tooltips kunnen niet bij alle vakjes
#Matroos:
#	ophalen swell hmo eruit halen, wordt niet gebruikt
#!!	add exception when using Deltares but no Deltares-connection (else Error in urllib.py at line 209 : IOError, but is lost when using shortcuts). http://stackoverflow.com/questions/6471275/python-script-to-see-if-a-web-page-exists-without-downloading-the-whole-page, also for credentials RWS?
#!!	add exception for wrong RWS Matroos credentials, anders crasht DeltaShell
#	retrieve one matroos series for batch transect, saves time and doesn't matter if transects are relatively close to each other
#	Matroos chart datetime op x-as?
#2D Bathymetry and XB grid:
#	kaart onder jarkusselector is maar zichtbaar bij enkel zoomniveau, rest kapot
#	veel wave energy verloren bij thetaminmax=50, sensitivity runs met 90 gedaan ivm +-30deg, wat zou effect zijn op erosievolume?
#	combine multiple jarkus KB files? andere bathysources? (ahn, vaklodingen etc)
#	meerdere jaren mogelijk maken om te selecteren? in ieder geval jaartal goed in timeslider zetten
#	visualize 'transects' of bathymap before xbeach run?
#	draw grid size/omtrek/enveloppe already in XBRTPlot2DbathyGetcoords, so indication is given
##	color scale for Curvilineargrid in maplegend screen (zie mail Pieter), zie TESTS
#	colorscale marien voor bathy? krijg kleuren er niet uit, zie TESTS
#	wms laag default achter alle kaarten? (sommige coordinate systems van objecten zijn read only), coordinaatsysteem van getcoordsmap moet RD zijn!
#	implement error if opt=BW and BWfile=="" (none), or check if available/downloaded
#	4 ipv 2 tidelocs voor langsstroming? (timeseries sinterklaasstorm zijn op 5km niet erg verschillend)
#design GUI:
#	minder lijntjes in sideview plot en rwsos (per default uitzetten)
#	2D gebieds/casenaam oid toevoegen aan folder, anders kan zelfde storm met een ander gebied de eerste run overschrijven
#	icoontjes toevoegen aan shortcut buttons, zie postbox pieter
#	dit in shortcut zorgt voor scriptstart bij opstarten, maar inputscherm zorgt voor crash, dus moet anders: "C:\Users\veens_jr\AppData\Local\Programs\Deltares\MorphAn (Early Preview) (1.3.0.33377)\bin\DeltaShell.Gui.x86.exe" -f "D:\veens_jr\Dropbox\Studie\M2-A Afstuderen Morphan Deltares\Data\Scripts\Jelmer\XBeachRealtimedata.py"
#!!	2D: xboutput ook weergeven in map, zb door de tijd met timeslider, verder max waterlijn en bebouwing. ook erosievolume per m?
##	get XBlog.txt messages while running script/XBeach.exe, zie TESTS
#	2D: strandtent wordt bij 1D geplot als beschikbaar in 'strandtenten.txt' (met raainr, RSPsea, RSPland), flexibeler maken zodat voor 1D+2D kan?
#		strandtent toevoegen als object met vier coordinaten en op het hele vlak een waarde (eg 1) (shapefile?), deze laag evaluaten (als mogelijk niet alleen op 'transect' line maar ook +en- .5dy) geeft dan waardes voor sidechart
#!!		hoe shapefiles (Strandtentshp folder in Data) plotten/evaluaten? (zie TESTS, nu nog evaluaten)
#		shapefile eerst omzetten naar matrix array met 1/0, mogelijk? (vectorlayer and feature have no attribute Evaluate
#		evt ook hoogte toevoegen zodat dit goed geplot kan worden (of 'auto', die dan de hoogte van het strand aan de zeekant neemt)
#	2D: plot multiple y_sel at one time?
#	alles staat nu in shortcuts, maar return van ShowInputDialog werkt niet, evt deze vars ook wegschrijven naar txtfiles en script onzichtbaar maken
#	get raainummers by clicking in map, or list of available raaien met vinkjes en kaart ernaast
#	Overview jarkus raaien op kaart, matroos BC en XBresultaat op planview kaart, klikken geeft matroos en 1D XBeach grafiekjes. ook bebouwing en waterline
#	bathy uit meerdere tijdstappen selecteren mogelijk maken: evaluate pakt nu eerste (oudste) KB bathy in de tijd, omdat deze standaard actief is bij plotten. layerbathy is al gemaakt voordat map geplot wordt, dus kan dan alleen nog maar veranderen als dit in de GUI ingbouwd wordt. Voorloptig dus gewoon 1 jaar selecteren met ntime=1
#	ysel 2D runXBOplot evt met 'time'-slider varieren? (is nu statisch als input, misschien minder geheugen intensief). Or show y_sel number of points in map, over grid, when clicking, show XBresults for that 'transect'
#	2D XBrun kan lang duren, dus plot XBoutput netcdf files already during run (dus met variable timelength), evt met refresh knopje in chart (die grijs wordt zodra er "End of program xbeach" in XBlog staat)
#endregion
END OF RECOMMENDATION PART

#region MORE WORK
#Urlretrieve:
#	PrintMessage werkt niet tijdens matroosretrieve
#	rws matroos retrieve chart ophalen werkt wel, maar kan niet wegschrijven als file want openurl ipv urlretrieve
#	rws matroos moet met https ipv http (4x in code), maar was tijdelijk niet operationeel vanuit MorphAn dus is nu http
#	len_Sep and len_waves timeseries length are different if different data lenghts are retrieved (eg due to missing wave data 24h from 201511070000). XBeach crashes when there is not enough wave data for the run
#		quickfix: determine smallest timeseries length and use that in XBeach (is now sort of implemented: if not equal, the last values of tsmat_Sep are ommitted, assuming Sep is always larger or equal to waves, maar is vast ook soms andersom?)
#		Also possible that first values of Sep or wave are missing? Then implement another test (is possible, eg with 201401020000-201401140600 in swan_zuno, due to missing data. is no problem when tstart=NOW).
#		get startdates from timeseries (check if asked start is retrieved start)
#Delfland/later:
#	alle resultaten naar project schrijven (met AddToProject Hidde?), project openen ook mogelijk maken (waarbij input vars ingeladen worden en oude run gelijk kan worden geplot, anders moet user zelf kijken wat de getalletjes precies waren, waarbij bathy/matroos/ny niet gecheckt kunnen worden)
#		Dan is rekentijd van enkele uren geen groot probleem, omdat de eerste stormuren al vrij snel inzichtelijk zijn. (meanvars kunnen niet, want die worden alleen aan het eind geoutput. Kan wel genegeerd worden, want zb is het meest relevant? Als tintm aangepast wordt zodat het wel kan is er veel output en heeft eg zs een extra dimensie)
#		er is nu een messagelevel=0 als xbrun niet goed afgerond is, deze moet dan gedeactiveerd of naar hoger level
#	Workspace moet nu first item in RootFolder zijn, extract ItemId from RootFolder.Items (and put in def file) instead
#	tests gaan nu fout als er een extra map in het project staat (XBfolder naast workspace of extra workspace)
#	prevent scriptrun if project is not saved yet (disable tempfolder D:\MorphAnTemp with commented "raise Exception")
#	Retrieve Matroosdata kan ook met WGS84 (meer internationale flexibiliteit), MorphAn kan dit omrekenen naar RD.
#	opendap scriptpath staat nu op default, dus gaat goed als handleiding gevolgd wordt en scriptingfolder in defaultdir gezet wordt.
#endregion