#region Imports
import os
import inspect
import time
import ConfigParser
import dsget
import DelftModelApi.Net as DMA
import System
#endregion

# Global model API
# Note: alternative to use flowmodel.ModelEngine? --> is NoneType?
api = DMA.ModelApi()

class CustomRunner():
    """ 
    Add dredge/dump commmands, run model & produce output
    Deltares $ dec. 2014 
    """
    def __init__(self):
        
        # Find flowmodel on init
        self._flowmodel = dsget.GetFlow1DModel()
        if not(self._flowmodel):
            raise NoFlowModelException
        
        # Pre-allocation
        self._current_timestep = 0
        self.func_library = []
        # Defaults
        self._logpath = os.path.join(Application.ProjectFilePath, '..', Application.Project.Name+'.ddlog')
        self._totaltimesteps = int((self._flowmodel.StopTime-self._flowmodel.StartTime).TotalSeconds/self._flowmodel.TimeStep.TotalSeconds)
        self._timestep = 10 
        self._filename = Application.Project.Name
        self._outputfolder = os.path.join(Application.ProjectFilePath,'..')
        self._pref_outputcrosssections = True
    
    def _get_custom_functions(self):
        for name, func in inspect.getmembers(self):
            if callable(func):
                if name.split('_')[0] == 'custom':
                    self.func_library.append(func)
        
    def run(self):
        """Run model with custom functions"""
        self._get_custom_functions()
        self._inititiate_logger()
        try:
            # Subscribe function to event
            for func in self.func_library:
                self._flowmodel.StatusChanged += func
            
            # run model
            Application.RunActivity(self._flowmodel)
    
            # Unsubscribe from event
            for func in self.func_library:
                self._flowmodel.StatusChanged -= func
        finally:
            self._logger.close()
    
    # ============================        
    # Custom methods
    # Methods that start with 'custom_' will be ran at runtime
    #
    # ============================
    def NOcustom_modify(self, event, args):
        #region Conditions Check or _dd_event to execute. List of True/False
        conditions = [] 
        #Check to see if the time steps are multiples of eachother
        conditions.append(self._flowmodel.CurrentTimeStep % self._timestep == 0)
        #Check if within the total time steps
        conditions.append(self._flowmodel.CurrentTimeStep < self._totaltimesteps)
        #check that the current time step is positive
        conditions.append(self._flowmodel.CurrentTimeStep > 0)
        #check for loop repeat
        conditions.append(self._flowmodel.CurrentTimeStep is not self._current_timestep) # 'cause StatusChanged changes 2 times per timestep
        """
        if not all(conditions) : 
            #self._logger.write('Time: %s (timestep: %i). %s: Conditions Fail.  \n'%(self._flowmodel.CurrentTime.ToString(), self._flowmodel.CurrentTimeStep, str(list(conditions))))
            return
        #endregion
            
        else: #execute event at current time step
            # Update current timestep
            self._current_timestep = self._flowmodel.CurrentTimeStep
            
            # Write to logger
            self._logger.write('------------EVENT TRIGGERED. START--------------------\n')
            self._logger.write('Time: %s (timestep: %i) \n'%(self._flowmodel.CurrentTime.ToString(), self._flowmodel.CurrentTimeStep))
            
            #Loop through each computational node along the reach
            for index, gridpoint in enumerate(self._flowmodel.NetworkDiscretization.Locations.Values):
                
                #Get Existing Conditions
                print 'HERE??'
                widths, z_abs, z_bottom, length = self._get_profile_data(index+1)
                
                #Write current conditions
                self._logger.write('%s RAW = z_bottom:%+.2f,  widths: %s, z_abs: %s\n'%(gridpoint.Name, z_bottom, widths, z_abs))
                
                #Modify Conditions
                if self._current_timestep == 900: #execute modify once (4 times the event step)
                    #if index > 10 and index < 20: #Modify indexes 10 - 20
                    self._modify(index+1, gridpoint)
                
                #continue #end node loop
            
            self._logger.write('------------EVENT END--------------------\n')
            """
            
    def NOcustom_change_cross_section(self, event, args):
        # Conditions for _dd_event to execute
        conditions = []
        conditions.append(self._flowmodel.CurrentTimeStep == 648)
        conditions.append(self._flowmodel.CurrentTimeStep < self._totaltimesteps)
        conditions.append(self._flowmodel.CurrentTimeStep > 0)
        conditions.append(self._flowmodel.CurrentTimeStep is not self._current_timestep) # 'cause StatusChanged changes 2 times per timestep
        if all(conditions):
            for index, gridpoint in enumerate(self._flowmodel.NetworkDiscretization.Locations.Values):
                width, levels, length = self._get_profile_data(index+1)
                #width[0] = 70
                #print 'widths: {}'.format(width)
                #print 'level: {}'.format(levels)
                self._set_new_profiles(width, levels, index)
            
    def custom_export_crosssections(self, event, args):
        """"Dredge/dump main function"""
        # Conditions for _dd_event to execute
        conditions = []
        conditions.append(self._flowmodel.CurrentTimeStep % self._timestep == 0)
        conditions.append(self._flowmodel.CurrentTimeStep < self._totaltimesteps)
        conditions.append(self._flowmodel.CurrentTimeStep > 0)
        conditions.append(self._flowmodel.CurrentTimeStep is not self._current_timestep) # 'cause StatusChanged changes 2 times per timestep
        #conditions.append(bool(self.dad_commands))
        
        # DAD loop
        if all(conditions) :
            # Update current timestep
            self._current_timestep = self._flowmodel.CurrentTimeStep
            
            # Write to logger
            self._logger.write('--------------------------------------\n')
            self._logger.write('Time: %s (timestep: %i) \n'%(self._flowmodel.CurrentTime.ToString(), self._flowmodel.CurrentTimeStep))
            
            self._export_cross_sections()
    
    # ============================        
    # Private methods
    # ============================       
    def _set_new_profiles(self, widths, levels, loc):
        depth = min(levels)
        heights = [levels[i]-depth for i in range(len(levels))]
        depthArray = System.Array.CreateInstance(float,1)
        depthArray[0] = depth
        heightsArray = System.Array.CreateInstance(float,len(heights))
        for i in range(len(heights)):
            heightsArray[i] = heights[i]
        widthArray = System.Array.CreateInstance(float,len(widths))
        for i in range(len(widths)):
            widthArray[i] = widths[i]
        
        print widthArray        
        #api.SetValues(DMA.QuantityType.BottomLevel, DMA.ElementSet.BranchNodes, loc, depthArray)
        #api.SetValues(DMA.QuantityType.CrossLevels, DMA.ElementSet.CrossSection, loc, heightsArray)
        try:
            api.SetValues(DMA.QuantityType.CrossTotalWidths, DMA.ElementSet.CrossSection, loc, widthArray)
        except Exception as e:
            print e
        
    def _modify(self, index, gridpoint):
        #function to modify cross section values
        #Get Conditions
        widths, z_abs, z_bottom, length = self._get_profile_data(index)
        
        """ The following code modifies the CrossSection width.
        This produces a perturbation (shock) in the hydraulics
        However, after this shock, the flow returns to normal as if there was no cross sectional change
        """
        #region Modify Width
        widths_new = widths
        
        #modify bottom width
        widths_new[0] = 70
        widths_new[1] = 100
        
        #Send to API
        api.SetValues(DMA.QuantityType.CrossTotalWidths, DMA.ElementSet.CrossSection, index, widths_new)
        
        #Write Logger
        self._logger.write('%s API MODIFIED: new width =  %s \n'%(gridpoint.Name, widths_new))
        print ('%s API MODIFIED: new width =  %s \n'%(gridpoint.Name, widths_new))
        #endregion
        
    def _export_cross_sections(self, **kwargs):
        """Export cross-sections to file. 
        TODO: summerbed & widths of sections not yet supported! Need access to model API..
        Possible Keywords (not case sensitive):
            FileName        - filename of export cross-section. will be appended with timestep
            OutputFolder    - folder in which the output cross-sections are placed (Absolute Path!)
        """
        # defaults
        filename = self._filename
        folder = self._outputfolder
        for key, value in kwargs.iteritems():
            if key.lower() == 'filename':
                filename = value
            elif key.lower() == 'outputfolder':
                filename = value
                
        filepath = os.path.join(folder,'%s_%04i'%(filename, self._flowmodel.CurrentTimeStep))
        with open(filepath+'.csv','wb') as f:
            f.write('id,Name,Data_type,level,Total width,Flow width,Profile_type,branch,chainage,')
            f.write('width main channel,width floodplain 1,width floodplain 2,width sediment transport,')
            f.write('Use Summerdike,Crest level summerdike,Floodplain baselevel behind summerdike,')
            f.write('Flow area behind summerdike,Total area behind summerdike,Use groundlayer,Ground layer depth\n')
            for index, gridpoint in enumerate(self._flowmodel.NetworkDiscretization.Locations.Values):
                width, levels, length = self._get_profile_data(index+1)
                f.write('%i, %s, meta,,,,,ZW,%s,0,0,0,0,0,0,0,0,0,0,0,999\n'%(index+1, gridpoint.Name, gridpoint.Branch.Name))
                for i in range(len(levels)):
                    f.write('%i, %s, geom,%f,%f,%f,,,,,,,,,,,,,,,\n'%(index+1, gridpoint.Name,float(levels[i]),
                                                                       float(width[i]), float(width[i])))
        self._logger.write('CrossSections written to %s \n' % filepath)
            
    #def _get_profile_data(self, loc):
    #    width, levels = self._get_profile_from_api(loc)
    #    length = self._get_length(loc)
    #    return width, levels, length
    def _get_profile_data(self, index):

        #Command for pulling xsec data from the api
        #min Z value of xsection
        z_bottom = api.GetValue(DMA.QuantityType.BottomLevel, DMA.ElementSet.BranchNodes, index) 
        #Z values from ZW section (unadjusted)
        z_rels = api.GetValues(DMA.QuantityType.CrossLevels, DMA.ElementSet.CrossSection, index) 
        #'Width values from ZW section'
        widths = api.GetValues(DMA.QuantityType.CrossTotalWidths, DMA.ElementSet.CrossSection, index) 
        
        #Calculate bed levels relative to datum
        z_abs = [z_rels[i]+z_bottom for i in range(len(z_rels))] #'Z + levelshift values from ZW section'
        
        #Round List
        z_abs = [round(elem, 2) for elem in z_abs ]

        length = 1#self._get_length(index)
        return widths, z_abs, length
        
    def _inititiate_logger(self):
        self._logger = open(self._logpath,'wb')
        self._logger.write('SOBEK 3 Dredge/Dump script log \n')
        self._logger.write(time.strftime('%b-%d-%Y %H:%M:%S')+'\n')
        
    def _get_length(self, index):
        if (index > 0) and (index < len(self._flowmodel.NetworkDiscretization.Locations.Values)-2):
            ci_ante = self._flowmodel.NetworkDiscretization.Locations.Values[index-1].Chainage
            ci_post = self._flowmodel.NetworkDiscretization.Locations.Values[index+1].Chainage
            length = 0.5*(ci_post-ci_ante)
        elif index == 0:
            length = 0.5*self._flowmodel.NetworkDiscretization.Locations.Values[index+1].Chainage
        elif index == len(self._flowmodel.NetworkDiscretization.Locations.Values)-1:
            ci_post = self._flowmodel.NetworkDiscretization.Locations.Values[index-1].Chainage
            ci = self._flowmodel.NetworkDiscretization.Locations.Values[index].Chainage
            length = 0.5*(ci_post-ci)
        else:
            length = 0
        return length
        
    def _get_profile_from_api(self, index):
        depth = api.GetValue(DMA.QuantityType.BottomLevel, DMA.ElementSet.BranchNodes, index)
        heights = api.GetValues(DMA.QuantityType.CrossLevels, DMA.ElementSet.CrossSection, index)
        width = api.GetValues(DMA.QuantityType.CrossTotalWidths, DMA.ElementSet.CrossSection, index)
        #print api.GetValue(DMA.QuantityType.WidthMain, DMA.ElementSet.CrossSection, index)
        levels = [heights[i]+depth for i in range(len(heights))]
        return width, levels
    
    def _check_profile(self, levels, z_threshold):
        if levels[0] > z_threshold:
            return False
        else:
            return True
    

        
        
class NoFlowModelException(Exception):
    pass