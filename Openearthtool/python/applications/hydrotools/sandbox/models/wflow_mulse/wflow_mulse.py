'''
!!    ~ ~ ~ PURPOSE ~ ~ ~
!!    this subroutine computes splash erosion by raindrop impact and flow erosion by overland flow

!!    ~ ~ ~ INCOMING VARIABLES ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    cht(:)      |m             |canopy height
!!    fimp(:)     |fraction      |fraction of HRU area that is
!!                               |impervious (both directly and
!!                               |indirectly connected)
!!    hhqday(:)   |mm H2O        |surface runoff generated each timestep 
!!                               |of day in HRU
!!    hru_km(:)   |km2           |area of HRU in square kilometers
!!    idt         |minutes       |length of time step used to report
!!    inum1       |none          |subbasin number
!!    laiday(:)   |m2/m2         |leaf area index
!!    rainsub(:,:)|mm H2O        |precipitation for the time step during the
!!                               |day in HRU
!!    eros_spl	  |none          |coefficient of splash erosion varing 0.9-3.1
!!    urblu(:)    |none          |urban land type identification number from
!!                               |urban.dat
!!    usle_k(:)   |              |USLE equation soil erodibility (K) factor
!!
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ OUTGOING VARIABLES ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    hhsedy(:,:)|tons           |sediment yield from HRU drung a time step
!!                               |applied to HRU

!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ LOCAL DEFINITIONS ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!	  bed_shear		|N/m2		   |shear stress b/w stream bed and flow	
!!	  erod_k		|g/J		   |soil detachability value	
!!    jj			|none          |HRU number
!!    kk			|none          |time step of the day
!!	  ke_direct		|J/m2/mm	   |rainfall kinetic energy of direct throughfall
!!	  ke_leaf		|J/m2/mm	   |rainfall kinetic energy of leaf drainage
!!	  ke_total		|J/m2   	   |total kinetic energy of rainfall
!!	  percent_clay	|percent	   |percent clay
!!	  percent_sand	|percent	   |percent sand
!!	  percent_silt	|percent	   |percent silt
!!	  pheff     	|m			   |effective plant height
!!	  rdepth_direct	|mm			   |rainfall depth of direct throughfall
!!	  rdepth_leaf	|mm			   |rainfall depth of leaf drainage
!!	  rdepth_tot	|mm			   |total rainfall depth 
!!    rintnsty	    |mm/hr         |rainfall intensity
!!	  sedspl		|tons		   |sediment yield by rainfall impact during time step
!!	  sedov 		|tons		   |sediment yield by overland flow during time step
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ SUBROUTINES/FUNCTIONS CALLED ~ ~ ~
!!    Intrinsic: log10, Exp, Real
!!
!!    ~ ~ ~ ~ ~ ~ END SPECIFICATIONS ~ ~ ~ ~ ~ ~

!!  Splash erosion model is adopted from EUROSEM model developed by Morgan (2001).
!!	Rill/interill erosion model is adoped from Modified ANSWERS model by Park et al.(1982)
!!  Code developed by J. Jeong and N. Kannan, BRC.
'''

import pcraster as pcr
import numpy as np

''' constants '''
timestepsecs=86400/24
timesteps = 10
_firstTimeStep = 1
_lastTimeStep = 10
Gamma_Water = 9807

eros_spl = 1 #(0.9-3.1)
idt = timestepsecs/60  # minutes in model timestep

''' import maps '''
percent_clay=pcr.scalar(pcr.readmap("staticmaps/wflow_clay.map"))
percent_silt=pcr.scalar(pcr.readmap("staticmaps/wflow_silt.map"))
laiday=pcr.scalar(pcr.readmap("staticmaps/wflow_lai.map"))
cht=pcr.scalar(pcr.readmap("staticmaps/wflow_canopy_height.map"))
fimp=pcr.scalar(pcr.readmap("staticmaps/wflow_impervious.map"))
idplt=pcr.scalar(pcr.readmap("staticmaps/wflow_idplt.map"))
sol_cov=pcr.scalar(pcr.readmap("staticmaps/wflow_sol_cov.map"))
Altitude=pcr.scalar(pcr.readmap("staticmaps/wflow_dem.map"))
P_mapstack="inmaps/P"
RUN_mapstack="inmaps/RUN"
SED_mapstack="outmaps/SED"
SPL_mapstack="outmaps/SPL"
OVL_mapstack="outmaps/OVL"
TEST_mapstack="outmaps/test"
celllength = 50.
hru_km = (celllength/1000.)**2

''' misc constants to calculate sediment yield by overland flow '''
''' !!! DON'T KNOW THE MEANING OF THESE PARAMETERS (YET) !!! ''' 
rill_mult = 1 #???
usle_k = 1  #erodibility
c_factor = 1 #???
eros_expo = 1 #???
idplt_cvm = 1 #natural log of the USLE_C (the minimum value of the USLE C factor for the lad cover) for a specific land cover type
dratio = 1 #???

pcr.setclone("staticmaps/wflow_dem.map")

'''' calculate slope'''
Slope = pcr.slope(Altitude)
pcr.report(Slope,'slope.map')

''' lelijke methode om te testen of het werkt '''
def readmapstack(mapstack,timestep):
    root= mapstack[0:mapstack.rfind('/')+1]
    var = mapstack[P_mapstack.rfind('/')+1:len(mapstack)]
    timestep = ("00" + str(timestep))[len("00" + str(timestep))-3:len("00" + str(timestep))]
    timestep = "00000000." + str(timestep)
    filestring = var + timestep[len(timestep)-12+len(var):len(timestep)]
    pcrmap = pcr.readmap(root+filestring)
    return pcrmap
    
def writemapstack(param,mapstack,timestep):
    root= mapstack[0:mapstack.rfind('/')+1]
    var = mapstack[P_mapstack.rfind('/')+1:len(mapstack)]
    timestep = ("00" + str(timestep))[len("00" + str(timestep))-3:len("00" + str(timestep))]
    timestep = "00000000." + str(timestep)
    filestring = var + timestep[len(timestep)-13+len(var):len(timestep)]
    pcrmap = pcr.report(param,root+filestring)
    return pcrmap
      
# parts that should go to the initial section

''' calculate the fraction of sand ''' 

percent_sand= 100-percent_clay-percent_silt
erod_k= percent_sand * 0

''' Soil detachability values adopted from EUROSEM User Guide (Table 1)'''

''' Maybe relate to soiltype.map? '''

erod_k = pcr.ifthenelse(pcr.pcrand(percent_clay>=40.,pcr.pcrand(percent_sand>=20.,percent_sand<=45.)),2.0, 
         pcr.ifthenelse(pcr.pcrand(percent_clay>=27.,pcr.pcrand(percent_sand>=20.,percent_sand<=45.)),1.7,
         pcr.ifthenelse(pcr.pcrand(percent_silt<=40.,percent_sand<=20.),2.0,
         pcr.ifthenelse(pcr.pcrand(percent_silt>40.,percent_clay>=40.),1.6,
         pcr.ifthenelse(pcr.pcrand(percent_clay>=35.,percent_sand>=45.),1.9,
         pcr.ifthenelse(pcr.pcrand(percent_clay>=27.,percent_sand<20.),1.6,
         pcr.ifthenelse(pcr.pcrand(percent_clay<=10.,percent_silt>=80.),1.2,
         pcr.ifthenelse(percent_silt>=50,1.5,
         pcr.ifthenelse(pcr.pcrand(percent_clay>=7.,pcr.pcrand(percent_sand<=52.,percent_silt>=28.)),2.0,
         pcr.ifthenelse(percent_clay>=20.,2.1,
         pcr.ifthenelse(percent_clay>=percent_sand-70.,2.6,
         pcr.ifthenelse(percent_clay>=(2.*percent_sand)-170.,3,pcr.scalar(1.9))))))))))))) 
pcr.report(erod_k,'erod_k.map')

''' canopy cover based on leaf area index '''
''' canopy cover is assumed to be 100% if LAI>=1 '''
''' maybe relate to canopygapfraction? '''

canopy_cover = pcr.ifthenelse(laiday>=1.,1.,laiday)

pcr.report(canopy_cover,'canopy_cover.map')

for k in range(_firstTimeStep,_lastTimeStep+1):
    print 'calculating sediment yield for timestep: ' + str(k)
    ''' calculate rainfall intensity'''
    precipitation = pcr.ifthen(readmapstack(P_mapstack,k)>0,readmapstack(P_mapstack,k))
    rintnsty = 60.*precipitation/idt
    rain_d50 = 0.188 * rintnsty ** 0.182

    ''' Rainfall kinetic energy generated by direct throughfall (J/m^2/mm) '''
    ke_direct = pcr.max(8.95 + 8.44 * pcr.log10(rintnsty),0)
    pheff = 0.5 * cht
    ke_leaf = pcr.max(15.8 * pheff ** 0.5 - 5.87,0)
    
    ''' Depth of rainfall '''
    rdepth_tot = pcr.max(precipitation / (idt * 60.),0)
    rdepth_leaf = pcr.max(rdepth_tot * canopy_cover,0)
    rdepth_direct = pcr.max(rdepth_tot - rdepth_leaf,0)
    
    ''' total kinetic energy by rainfall (J/m^2) '''
    ke_total = 0.001 * (rdepth_direct * ke_direct + rdepth_leaf * ke_leaf)
    
    ''' total soil detachment by raindrop impact (tons) '''
    hhqday = readmapstack(RUN_mapstack,k)
    sedspl = erod_k * ke_total * pcr.exp(-eros_spl * hhqday / 1000.) * hru_km # tons per cell
        
    ''' Impervious area of HRU '''   
    sedspl = sedspl * (1.- fimp)
       
    
    ''' maximum water depth that allows splash erosion '''
    sedspl = pcr.ifthenelse(pcr.pcror(hhqday>=3.*rain_d50,hhqday<=1.e-6),0.,sedspl)
    writemapstack(sedspl,SPL_mapstack,k)
        
    ''' Overland flow erosion '''
    ''' cover and management factor used in usle equation (ysed.f) '''   
    c = pcr.exp((-.2231 - idplt_cvm) * pcr.exp(-.00115 * sol_cov + idplt_cvm))
    
    ''' calculate shear stress (N/m2) '''
    bed_shear = 9807 * (hhqday / 1000.) * Slope
    
    ''' sediment yield by overland flow (kg/hour/m2) '''
    sedov = 11.02 * rill_mult * usle_k * c_factor * c * bed_shear ** eros_expo
    
    
    ''' sediment yield by overland flow (tons per time step) '''
    sedov = 16.667 * sedov * hru_km * idt
    
    ''' Impervious area of HRU '''   
    sedov = sedov * (1.- fimp)
    writemapstack(sedov,OVL_mapstack,k)
     
    
    ''' Report sediment yield '''
    hhsedy = dratio * (sedspl + sedov)
    hhsedy = pcr.cover(pcr.ifthenelse(hhsedy< 1.e-10,0,hhsedy),pcr.scalar(0))
    
    
    ''' reporting '''
    writemapstack(hhsedy,SED_mapstack,k)
    