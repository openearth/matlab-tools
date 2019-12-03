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
    def __init__(self, optimization_problem, state, target_min, target_max, priority, weight):
        self.state = state
        # One goal can introduce a single or two constraints (min and/or max).
        # We might not always be able to realize our target water volume range,
        # but we want to have it achieved whenever possible (under given hydraulical conditions and physics).
        self.target_min = target_min
        self.target_max = target_max
        # priority
        self.priority = priority
        self.weight = weight
        # the function range and nominal should be specified in Modelica.
        # Call parent class constructor
        super(RangeStateGoal, self).__init__(optimization_problem)        

class RIBASIM(GoalProgrammingMixin, CSVMixin, ModelicaMixin, CollocatedIntegratedOptimizationProblem):
# Reference to the modelica file (*.mo)
    model_name = 'RIBASIM020'
    csv_equidistant = False

    def path_goals(self):
        _path_goals = super(RIBASIM, self).path_goals()        
        return self._path_goals
        
    def path_constraints(self, ensemble_member):
        # Call super() class to not overwrite the path constraints that are already existing (i. e. specified in Modelica)
        _constraints = super(RIBASIM, self).path_constraints(ensemble_member)
        return _constraints


    def solver_options(self):
        options = super().solver_options()
        solver = options['solver']
        options[solver]['nlp_scaling_method'] = 'none'
        options[solver]['linear_system_scaling'] = 'none'
        options[solver]['linear_scaling_on_demand'] = 'no'
        options[solver]['max_iter'] = 1000  # 3000
        #options[solver]['tol'] = 1e-10  # 1e-8
        # options[solver]['acceptable_tol'] = 1e-5
        #options['expand'] = True
        #options[solver]['bound_relax_factor'] = 1e-9
        #options[solver]['bound_push'] = 1e-8
        #options[solver]['bound_frac'] = 1e-8
        #options[solver]['honor_original_bounds'] = 'no'
        #options[solver]['jac_c_constant'] = 'yes'  # equality constraints are linear
        #options[solver]['jac_d_constant'] = 'yes'  # inequality constraints are linear
        return options

    def pre(self):
        super(RIBASIM,self).pre()
        # Path goals        
        # A path goal applies for every time step individually. If a goal is achieved for a specific time step has no impact on the goal on another time step.         
        # path goal for Reservoir 3, as specified in the time series from the CSV input file:        
        g = []     
        # physical limits for storage of the reservoir, accounting for dead storage and full reservoir storage.
        # The range must be within the Volume range specified in Modelica.
        g.append(RangeStateGoal(self, state="RSV_40_V", target_min=self.get_timeseries('RSV_40_Vmin'), target_max=self.get_timeseries('RSV_40_Vmax'), priority=1, weight=1))
        g.append(RangeStateGoal(self, state="RSV_70_V", target_min=self.get_timeseries('RSV_70_Vmin'), target_max=self.get_timeseries('RSV_70_Vmax'), priority=1, weight=1))
        # A volume target for the reservoirs
        g.append(RangeStateGoal(self, state="RSV_40_V", target_min=self.get_timeseries('RSV_40_Vtarget'), target_max=self.get_timeseries('RSV_40_Vtarget'), priority=20, weight=1))
        g.append(RangeStateGoal(self, state="RSV_70_V", target_min=self.get_timeseries('RSV_70_Vtarget'), target_max=self.get_timeseries('RSV_70_Vtarget'), priority=20, weight=1))
        # minimum discharge for low flow node
        g.append(RangeStateGoal(self, state="LOWFL_85_Q", target_min=self.get_timeseries('LOWFL_85'),target_max=999, priority=30, weight=1))
        # demand on irrigation nodes
        g.append(RangeStateGoal(self, state="PWS_15_forcing", target_min=self.get_timeseries('PWS_15_demand'), target_max=self.get_timeseries('PWS_15_demand'), priority=40, weight=1))
        g.append(RangeStateGoal(self, state="FIXIRR_30_forcing", target_min=self.get_timeseries('FIXIRR_30_demand'), target_max=self.get_timeseries('FIXIRR_30_demand'), priority=50, weight=1))
        g.append(RangeStateGoal(self, state="FIXIRR_80_forcing", target_min=self.get_timeseries('FIXIRR_80_demand'), target_max=self.get_timeseries('FIXIRR_80_demand'), priority=50, weight=1))

        self._path_goals = g

             

       
run_optimization_problem(RIBASIM, base_folder='..', log_level=logging.INFO)