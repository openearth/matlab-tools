# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 13:35:30 2014

@author: heijer

$Id: dsx.py 12700 2016-04-22 09:01:51Z krogt_m $
$Date: 2016-04-22 02:01:51 -0700 (Fri, 22 Apr 2016) $
$Author: krogt_m $
$Revision: 12700 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/dgeostability/dsx.py $
"""

import logging
import xml.etree.ElementTree as ET
import numpy as np
import re
import os
from subprocess import check_output
import logging

class DGeoStability:
    options_RTO = ['-s', '-rto']
    options_WBI = ['-s', '-wbi']
    options_EQ = ['-s']
    def __init__(self, fname=None):
        self.set_binary()
        if not fname == None:
            self.fname = fname
            self.dsx_read(self.fname)
    
    def geostability_run(self, fname=None):
        """
        run D-GeoStability on specified file or path
        """
        if fname is None:
            self.dsx_write(self.fname)
            fname = self.fname
        
        if self.tree.find('.//Definitions').attrib['CalculationModel'] == 'RTO' :
            stdout = check_output([self.binary] + self.options_RTO + [fname])
        elif self.tree.find('.//Definitions').attrib['CalculationModel'] == 'WBI' :
            stdout = check_output([self.binary] + self.options_WBI + [fname])
                
        logging.debug(stdout)

    def geostabilityGUI_run(self, fname=None):
        """
        run D-GeoStability with User Interfact with a specified file or path
        """
        if fname is None:
            self.dsx_write(self.fname)
            fname = self.fname
            
        if self.tree.find('.//Definitions').attrib['CalculationModel'] == 'RTO' :
            stdout = check_output([self.binaryGUI] + self.options_RTO + [fname])
        elif self.tree.find('.//Definitions').attrib['CalculationModel'] == 'WBI' :
            stdout = check_output([self.binaryGUI] + self.options_RTO + [fname])    # allways open with rto command of the UI, 
                                                                                    # calculation must be made with WBI (check model)
                
        logging.debug(stdout)

    def geostability_run_EQ(self, fname=None):
        """
        run Delphi version of Macrostability on specified file or path
        """
        if fname is None:
            self.dsx_write(self.fname)
            fname = self.fname
            
        stdout = check_output([self.binary] + self.options_EQ + [fname])
        logging.debug(stdout)
    
    def binary_exists(self, binary):
        """
        check availability of binary in search path
        """
        if os.path.isabs(binary):
            return os.path.exists(binary)
        elif binary == None:
            return False
        else:
            searchpaths = [os.path.join(p, binary) for p in ['.'] + os.environ['path'].split(';')]
            pathexists = map(os.path.exists, searchpaths)
            return (True in pathexists)
            
        
    def set_binary(self, binary='Deltares.Stability.Console.exe',binaryGUI='MStab.exe'):
        if self.binary_exists(binary):
            self.binary = binary
            self.binaryGUI=binaryGUI
        else:
            self.binary = None
            self.binaryGUI=None
            print 'WARNING: binary "%s" not found in search path'%binary
            print 'WARNING: binaryGUI "%s" not found in search path'%binaryGUI
            print ' provide absolute path to binary or adjust the environment variable "PATH"'
        
        
    def dsx_read(self, fname):
        self.tree = ET.parse(fname)
    
    
    def dsx_write(self, fname):
        self.tree.write(fname)
    
    
    def setmodel(self, calcmodel):
        def_el = self.tree.find('.//Definitions').attrib
        m = def_el['ModelOption']
        if not m == calcmodel:
            if not 'Is%s'%calcmodel in def_el.keys():
                print 'WARNING: model "%s" not available'%calcmodel
            else:
                def_el['Is%s'%m] = 'False'
                def_el['ModelOption'] = calcmodel
                def_el['Is%s'%calcmodel] = 'True'
    
    
    def getmodel(self):
        def_el = self.tree.find('.//Definitions').attrib
        return def_el['ModelOption']
    
    
    def getslipplanenames(self, prefix='Slip plane '):
        """
        return the "Name" attributes of all SlipPlane elements that start with the (case-sensitive) predefined prefix
        """
        spnames = self.tree.findall('.//SlipPlane')
        re_spnames = re.compile(prefix)
#        spnames = [spn.attrib['Name'] for spn in spnames if re_spnames.match(spn.attrib['Name'])]
        spnames = [spn.attrib['Name'] for spn in spnames]       
        return spnames
        
        
    def getslipplane(self, name='Slip plane 1'):
        sp = self.tree.find('.//SlipPlane[@Name="%s"]/Points'%name)
        spxy = [(elem.attrib['X'],elem.attrib['Z']) for elem in sp.getchildren()]
        x,y = zip(*map(lambda elem: map(float, elem), spxy))
        return np.asarray(x),np.asarray(y)
    
    
    def clearslipplane(self, name='Slip plane 1'):
        # find slip plane
        sp = self.tree.find('.//SlipPlane[@Name="%s"]/Points'%name)
        if sp == None:
            msg = 'No slip plane "%s" found'%name
            logging.warning(msg)
            print 'WARNING:',msg
            return
        # remove points
        for a in sp.findall('.//Point'):
            sp.remove(a)
    
    
    def setwaterlevel(self, **kwargs):
        location = self.tree.find('.//Definitions/Location')
        location_piezometrichead= self.tree.find('.//Definitions/Location/PiezometricHeads')
        for key,val in kwargs.items():
            if key in location.attrib.keys():
                if key is 'WaterLevelRiver':               
                    location.attrib[key] = str(val)
                    location.attrib['HeadInPLLine3'] = str(val) ## always apply WLriver = HeadINPLLine3 by definition 
            elif 'PlLineOffset' in key:
                location.attrib['UseDefaultOffsets'] = "False" ##only needed in case of PL1 stochasts
                location_piezometrichead.attrib[key] = str(val)
            elif 'LeakageLength' in key:
                location_piezometrichead.attrib[key] = str(val)                
            else:
                msg = '"%s" is not a valid key (note: check is case-sensitive)'%key
                logging.warning(msg)
                print 'WARNING:',msg                
    
    
    def get_waterlevelriver(self):
        waterlevelriver = self.tree.find('.//Definitions/Location').attrib['WaterLevelRiver']
        return waterlevelriver
                
    
    def setslipplane(self, xy, name='Slip plane 1'):
        # clear current slip plane
        self.clearslipplane(name=name)
        sp = self.tree.find('.//SlipPlane[@Name="%s"]/Points'%name)
        # add new slip plane
        for elem in xy:
            ET.SubElement(sp, 'Point', attrib=dict(X=str(elem[0]), Z=str(elem[1]), PointType='XYZ'))


    def getminsafetycirle(self):
        # read safety curve features
        X = self.tree.find('.//MinimumSafetyCurve/Center').attrib['X']
        Y = self.tree.find('.//MinimumSafetyCurve/Center').attrib['Y']
        R = self.tree.find('.//MinimumSafetyCurve').attrib['Radius']
        sf= self.tree.find('.//MinimumSafetyCurve').attrib['SafetyFactor']
        return X,Y,R,sf


    def getminsafetyslices(self):
        # read safety curve features
        slcs = self.tree.findall('.//MinimumSafetyCurve/Slices/Slice/*')
        attr = []
        refdict = {}
        for elem in slcs:
            attr.append(elem.attrib)
            attr[-1]['tag'] = elem.tag
            if elem.attrib.has_key('Key'):
                refdict[elem.attrib['Key']] = {'X': elem.attrib['X'],
                                               'Y': elem.attrib['Y']}
        for att in attr:
            if att.has_key('RefKey'):
                att["X"] = refdict[att["RefKey"]]["X"]
                att["Y"] = refdict[att["RefKey"]]["Y"]                
        
        bottompoints = [att for att in attr if att['tag'].startswith('Bottom')]
        xy = [(bpt['X'], bpt['Y']) for bpt in bottompoints]        
#        sr = self.tree.findall('.//MinimumSafetyCurve/Slices/Slice/BottomRight')
#        xy = []
#        for elem in sr:
#            if 'RefKey' in elem.attrib:
#                elem = self.tree.find('.//MinimumSafetyCurve/Slices/Slice/*[@Key="%s"]' % elem.attrib['RefKey'])
#            xy.append((elem.attrib['X'],elem.attrib['Y']))
#                
#        sl = self.tree.findall('.//MinimumSafetyCurve/Slices/Slice/BottomLeft')
#        xy = [(elem.attrib['RefKey'],elem.attrib['X'],elem.attrib['Y']) for elem in sr\
#            if elem.attrib.haskey('X')]
#        xyl = [(elem.attrib['X'],elem.attrib['Y']) for elem in sl]
#        for elem in xyl:
#            if not elem in xy:
#                xy.insert(0,elem)
        x,y = zip(*map(lambda elem: (float(elem[0]),float(elem[1])), xy))
        return np.asarray(x),np.asarray(y)

#    
#    def getspencerslipplane(self):
#        mscs = self.tree.findall('.//MinimumSafetyCurve')
#        sfs = [float(msc.attrib['SafetyFactor']) for msc in mscs]
#        ssp = mscs[np.argmin(sfs)].getchildren()[0]
#        xy = [(elem.attrib['X'],elem.attrib['Y']) for elem in ssp.getchildren()]
#        x,y = zip(*map(lambda elem: (float(elem[0]),float(elem[1])), xy))
#        return np.asarray(x),np.asarray(y)
#    
    def getspencerslipplane(self):
        mscs = self.tree.findall('.//MinimumSafetyCurve')
        ## comment new dsx structure , therfore trick.
        ssp=mscs[0].getchildren()[0]        
#        sfs = [float(msc.attrib['SafetyFactor']) for msc in mscs]
#        ssp = mscs[np.argmin(sfs)].getchildren()[0]
        xy = [(elem.attrib['X'],elem.attrib['Y']) for elem in ssp.getchildren()]
        x,y = zip(*map(lambda elem: (float(elem[0]),float(elem[1])), xy))
        return np.asarray(x),np.asarray(y)
    
    
    def get_upliftvan_slipplane(self):
        """
        return Uplift Van slip plane in terms of Active/Passive circle (center and radius)
        """
        # minimum safety curve
        msc = self.tree.find('.//MinimumSafetyCurve')
        # passive circle
        pc = msc.find('.//PassiveCircle')
        # active circle
        ac = msc.find('.//ActiveCircle')
        
        # trick: if there is a Refkey statement in pc or ac
        if 'RefKey' in pc.attrib:
            pc=ac
        if 'RefKey' in ac.attrib:
            ac=pc
        
        X = np.array((float(pc.attrib['X']),float(ac.attrib['X'])))
        Y = np.array((float(pc.attrib['Y']),float(ac.attrib['Y'])))
        
        R = np.array(map(lambda rt: float(msc.attrib[rt]), ('PassiveRadius', 'ActiveRadius')))
        
        sf = float(self.tree.find('.//MinimumSafetyCurve').attrib['SafetyFactor'])
        return X,Y,R,sf        


    def get_safetyfactor(self):
        if self.tree.find('.//MinimumSafetyCurve') is not None:
            if len(self.tree.findall('.//MinimumSafetyCurve')) >1 and self.tree.findall('.//MinimumSafetyCurve')[0].get('SafetyFactor') is not None and self.tree.findall('.//MinimumSafetyCurve')[1].get('SafetyFactor') is not None:
                sf_hlp = self.tree.findall('.//MinimumSafetyCurve')
                sf_false = self.tree.find('.//SafetyZone/MinimumSafetyCurve').attrib['SafetyFactor']
                sf = []                    
                for i_ in np.arange(sf_hlp.__len__()):
                    sf_hlp_1=sf_hlp[i_].attrib['SafetyFactor']
                    if sf_hlp_1 is not sf_false and i_>0:
                        sf=np.append(sf,sf_hlp_1)
                sf=float(sf[0])
                if sf == 1001:
                    print '!!! the evaluation resulted in an error (i.e. sf=1001) !!! '
                    print 'file: %s'%(self.fname)
                    pass
                else: pass
            else:        
                sf = float(self.tree.find('.//MinimumSafetyCurve').attrib['SafetyFactor'])
        else:
            print '!!! no result of DGeostability is given !!! '
            exit()
#        sf = float(self.tree.find('.//MinimumSafetyCurve').attrib['SafetyFactor'])
        return sf
        
        
    def set_upliftvan_slipplane(self, Xleft, Yleft, Xright, Yright, Ytangent):            
        # slip plane uplift van
        spuv = self.tree.find('.//SlipPlaneUpliftVan')
        # left grid
        lg = spuv.find('.//LeftGrid')
        # right grid
        rg = spuv.find('.//RightGrid')
        # tangent lines
        tl = spuv.find('.//TangentLines')
        
        Xleft, Yleft, Xright, Yright, Ytangent = map(lambda x: np.array([x]), (Xleft, Yleft, Xright, Yright, Ytangent))
        # use fixed point for the left circle
        lg.attrib['GridZTop'] = '%g'%np.max(Yleft)
        lg.attrib['GridZBottom'] = '%g'%np.min(Yleft)
        lg.attrib['GridZNumber'] = '%i'%Yleft.shape[0]
        lg.attrib['ZIntervalNumber'] = '%i'%(Yleft.shape[0]-1)
        lg.attrib['GridXLeft'] = '%g'%np.max(Xleft)
        lg.attrib['GridXRight'] = '%g'%np.min(Xleft)
        lg.attrib['GridXNumber'] = '%i'%Xleft.shape[0]
        lg.attrib['XIntervalNumber'] = '%i'%(Xleft.shape[0]-1)
        # use fixed point for the right circle
        rg.attrib['GridZTop'] = '%g'%np.max(Yright)
        rg.attrib['GridZBottom'] = '%g'%np.min(Yright)
        rg.attrib['GridZNumber'] = '%i'%Yright.shape[0]
        rg.attrib['ZIntervalNumber'] = '%i'%(Yright.shape[0]-1)
        rg.attrib['GridXLeft'] = '%g'%np.max(Xright)
        rg.attrib['GridXRight'] = '%g'%np.min(Xright)
        rg.attrib['GridXNumber'] = '%i'%Xright.shape[0]
        rg.attrib['XIntervalNumber'] = '%i'%(Xright.shape[0]-1)
        # use one tangent line
        tl.attrib['TangentLineZTop'] = '%g'%np.max(Ytangent)
        tl.attrib['TangentLineZBottom'] = '%g'%np.min(Ytangent)
        tl.attrib['TangentLineNumber'] = '%i'%Ytangent.shape[0]  
    
    
    
    def set_MinimumLevelPhreaticLineAtDikeTop(self,MinimumLevelPhreaticLineAtDikeTop):
        location_help_ = self.tree.findall('.//Location')
        for i_lcoation in location_help_:
            if 'MinimumLevelPhreaticLineAtDikeTopRiver' in i_lcoation.attrib: 
                i_lcoation.attrib['MinimumLevelPhreaticLineAtDikeTopRiver']='%s'%MinimumLevelPhreaticLineAtDikeTop
                i_lcoation.attrib['MinimumLevelPhreaticLineAtDikeTopPolder']='%s'%MinimumLevelPhreaticLineAtDikeTop        



if __name__ == '__main__':
    fname = r'd:\checkouts\heijer\python\projects\WTI_macrostab\alter\UpliftVan.dsx'
    DG = DGeoStability()
    DG.dsx_read(fname)
    x,y = DG.getminsafetyslices()
    print len(zip(x,y))
    