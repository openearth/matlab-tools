from rtctools.optimization.collocated_integrated_optimization_problem \
    import CollocatedIntegratedOptimizationProblem    
from rtctools.optimization.goal_programming_mixin \
    import GoalProgrammingMixin, Goal, StateGoal
from rtctools.optimization.modelica_mixin import ModelicaMixin
from rtctools.optimization.csv_mixin import CSVMixin
from rtctools.util import run_optimization_problem
import numpy as np
from numpy import inf
import logging

class RangeGoal(Goal):

    def __init__(self, RangeGoal_state, RangeGoal_min, RangeGoal_max, priority, weight, function_range, function_nominal):
        self.target_min = RangeGoal_min
        self.target_max = RangeGoal_max
        self.state = RangeGoal_state
        self.priority = priority
        self.weight = weight
        self.function_range = function_range
        self.function_nominal = function_nominal 
    def function(self, optimization_problem, ensemble_member):
        return optimization_problem.state(self.state)
        
class RangeStateGoal(StateGoal):
    # This goal inherits StateGoal from the GoalProgrammingMixin. 
    # Applying a goal to every time step is easily done by returning the
    # optimization_problem.state('var') method and then passing the goal using
    # the path_goals() method. Note that each timestep is implemented as an
    # independent goal- if we cannot satisfy our min/max on time step A, it will
    # not affect our desire to satisfy the goal at time step B.
    def __init__(self, optimization_problem, state, target_min, target_max, priority):
        self.state = state
        # One goal can introduce a single or two constraints (min and/or max).
        # We might not always be able to realize our target water volume range,
        # but we want to have it achieved whenever possible (under given hydraulical conditions and physics).
        self.target_min = target_min
        self.target_max = target_max
        # priority
        self.priority = priority
        # the function range and nominal should be specified in Modelica. 
        # Call parent class constructor
        super(RangeStateGoal, self).__init__(optimization_problem)        

class RIBASIM(GoalProgrammingMixin, CSVMixin, ModelicaMixin, CollocatedIntegratedOptimizationProblem):
# Reference to the modelica file (*.mo)
    model_name = 'RIBASIM020'
    
    def path_goals(self):
        _path_goals = super(RIBASIM, self).path_goals()        
        return self._path_goals
        
    def path_constraints(self, ensemble_member):
        # Call super() class to not overwrite the path constraints that are already existing (i. e. specified in Modelica)
        _constraints = super(RIBASIM, self).path_constraints(ensemble_member)
        return _constraints        
        
    def pre(self):
        super(RIBASIM,self).pre()
        # Path goals        
        # A path goal applies for every time step individually. If a goal is achieved for a specific time step has no impact on the goal on another time step.         
        # path goal for Reservoir 3, as specified in the time series from the CSV input file:        
        g = []     
        # physical limits for storage of the reservoir. The range should be within the Volume range specified in Modelica. 
        g.append(RangeStateGoal(self, state="RSV_3_V", target_min=4042800000, target_max=9293000000, priority=1))        
        g.append(RangeStateGoal(self, 'RSV_47_V', 4042800000, 9293000000, 1))
        g.append(RangeStateGoal(self, 'RSV_565_V', 2486800000, 6499000000, 1))                
        # physical limits for release are specified in the Modelica model. 

        # time-variant operational range for the reservoir volume: between flood control volume and firm storage volume. 
        g.append(RangeStateGoal(self, state="RSV_3_V", target_min=self.get_timeseries('RSV_3_FirmStorageVolume'), target_max=self.get_timeseries('RSV_3_FloodControlVolume'), priority=20))        
        g.append(RangeStateGoal(self, 'RSV_47_V', self.get_timeseries('RSV_47_FirmStorageVolume'), self.get_timeseries('RSV_47_FloodControlVolume'), 20))
        g.append(RangeStateGoal(self, 'RSV_565_V', self.get_timeseries('RSV_565_FirmStorageVolume'), self.get_timeseries('RSV_565_FloodControlVolume'), 20))        

        # time-variant operational target for the reservoir volume, the rule curve.
        g.append(RangeStateGoal(self, state="RSV_3_V", target_min=self.get_timeseries('RSV_3_TargetStorageVolume'), target_max=self.get_timeseries('RSV_3_TargetStorageVolume'), priority=30))        
        g.append(RangeStateGoal(self, 'RSV_47_V', self.get_timeseries('RSV_47_TargetStorageVolume'), self.get_timeseries('RSV_47_TargetStorageVolume'), 30))
        g.append(RangeStateGoal(self, 'RSV_565_V', self.get_timeseries('RSV_565_TargetStorageVolume'), self.get_timeseries('RSV_565_TargetStorageVolume'), 30))        
        
        # minimum flow for low flow nodes
        g.append(RangeStateGoal(self, 'LOWFL_1_Q', self.get_timeseries('LOWFL_1_Q_Min'), 500, 25))


        # g.append(RangeGoal('RSV_3_V', self.get_timeseries('RSV_3_V_min'), self.get_timeseries('RSV_3_V_max'), 2, 1, [0, 9999999], 9999))
        
        self._path_goals = g
             

       
run_optimization_problem(RIBASIM, base_folder='..', log_level=logging.INFO)