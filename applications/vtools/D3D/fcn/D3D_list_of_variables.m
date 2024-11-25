%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%List all variables
%
%TO DO:
% Link all numbers to strings and labels. 
% [var_str_read,var_id,var_str_save]=D3D_var_num2str(3);
% labels4all(var_str_read,1,'en')

function D3D_list_of_variables

%% FLOW

%   1   'bl'    = bed elevation (etab) [m]
%   2   'wd'    = flow depth (h) [m]
%   12  'wl'    = water level

%   10  'umag'       = depth averaged velocity [m/s]; call with <layers> to do an average of the selected layers
%       'umag_layer' = velocity magnitude in each layer (for 3D) [m/s]; use in combination with `layer`
%   11  'uv'         = velocity [m/s] 
%       'vpara'      = velocity parallel to a polyline [m/s] 
%       'vperp'      = velocity perpendicular to a polyline [m/s] 

%   18  'Q'     = water discharge (as u*h*B) [m^3/s]
%   16  'qsp'   = specific water discharge (as u*h) [m^2/2] -> I think at some point `q` was accepted. It should not. Better not to have case sensitive options. 

%   32  'czs'        = Chezy  [m/s^{1/2}]
%   43                      = horizontal eddy viscosity [m^2/s]
%   6                       = secondary flow intensity (I) [m/s]
%   36  'Fr'                = Froude number [-]
%   37                      = CFL [-]
%   33  'mesh2d_flowelem_ba'= cell area [m^2]
%   34                      = space step [m]
%   38                      = time step [s]
%       'E'                 = piezometric head [m]

%% MORPHODYNAMIC

%   9                   = detrended etab based on etab_0
%   15  'taub'          = bed shear stress [Pa]
%   17  (plot diff)     = cumulative bed elevation
%   25                  = total sediment mass (summation of all substrate layers, including active layer)

%       'umod'          = morphodynamic velocity [m/s]
%   48                  = total sediment transport at nodes [m^2/s]
%   44  'stot'          = total bed load transport at nodes [m^2/s]. This is sediment transport per size fraction. To plot as stacked area plot for all fractions, use `do_area=1`.
%   29                  = sediment transport magnitude at edges m^2/s
%   30                  = sediment transport magnitude at edges m^3/s

%	47  'ba_mor'        = morphodynamic cell area (cell area only if the total sediment thickness is not 0) [m^2] 

%       'detab_ds'      = slope in streamwise direction (only for <summerbed> analysis)

    %% his

%   22                            = cumulative nourished volume of sediment
%   23                            = suspended transport in streamwise direction
%   24                            = cumulative bed load transport
%   35                            = cumulative dredged volume of sediment [m^3]
%       'cross_section_discharge' = cross-sectional instantaneous discharge [m^3/s]

%% MIXED-SIZE SEDIMENT

%   3   'dm'    = arithmetic mean grain size of the active layer (dm Fak) [m]
%   26  'dg'    = geometric  mean grain size of the active layer (dg Fak) [m]

%       'd90'   = d90 at the bed surface [m]
%       'd50'   = d50 at the bed surface [m]
%       'd10'   = d10 at the bed surface [m]

%	8   'Fak'   = volume fraction content in the active layer (Fak) [-]
%	40          = volume fraction content per layer (including active layer) [-]

%   14  'La'    = active layer thickness [m]
%   27  'Ltot'  = total sediment thickness (summation of all substrate layers, including active layer) (Ltot) [m]
%	39  'thlyr' = sediment thickness of each layer (including active layer) [m] (use <layer> to specify which one to get).

%   19          = bed load transport for size fraction kf at nodes [m^3/s]

%% ILL-POSEDNESS

%   4 = arithmetic mean grain size of the interface between active layer and substrate (dm fIk)
%   5 = fIk
%   7 = elliptic

%% WAVES

%   41 'waveheigth' = wave height [m]
%   42              = wave forces [N]

%% ICE

%	45=thickness of the floating ice cover [m] 
%	46=pressure exerted by the floating ice cover [m] 

%% 1D

%   20  'mesh1d_umod'        = velocity at the main channel
%   21  'mesh1d_q1_main'     = discharge at main channel - NO   
%   28  'mesh1d_bl_ave'      = main channel averaged bed level
%   31  'mesh1d_mor_width_u' = morphodynamic width [m]

%% SALT

%   'clm2' mass of salt per unit surface 

%% CONSTITUENTS

%   'T_max'     = residence based on maximum time in the water column
%   'T_da'      = residence time based on depth-averaged concentration
%   'T_surf'    = residence time at the surface

%% OTHER

%   13=face indices


end %function