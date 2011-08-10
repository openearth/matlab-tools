% DELFT3D - tools related to <a href="http://www.delft3d.nl">Delft3d</a>
%
% For most functionality, you need the proprietery Delft3D Matlab toolbox first:
%
%    addpath('C:\Delft3D\w32\matlab\')
%
% Note functions in C:\Delft3D\w32\matlab\private\ only work when you copy them one level up.
%
% Delft3D-FLOW is open source since jan 1st 2011, see http://oss.deltares.nl for details.
%
% Files
%   d3d_sigma           - Calculates the relative vertical sigma positions in %
%   d3d_z               - Calculates the absolute z-layer positions in m
%   delft3d_grid_image  - Show ASCII image of Delft3D grid matrix
%   delft3d_io_ann      - Read annotation files in a nan-separated list struct (*.ann)  (BETA VERSION)
%
% NEFIS file format related
%   vs_get_constituent_index   - Read index information required to read constituents by name.
%   vs_get_elm_def             - Read NEFIS Element data
%   vs_get_elm_size            - Read size of NEFIS Element data
%   vs_get_grp_def             - Read NEFIS Element data
%   vs_get_grp_size            - Read size of NEFIS Element data
%   vs_time                    - Read time information from NEFIS file
%
% NEFIS map file format related (trim*,dat)
%   vs_trim2nc                 - Convert part of a Delft3D trim file to netCDF (BETA)
%                                Note that the Rijkswaterstaat 'getData' tool to convert their 
%                                SIMONA SDS files to netCDF can also handle NEFIS files.
%   vs_area                    - read INCORRECT cell areas from com-file.
%   vs_getmnk                  - Read the grid size from NEFIS file.
%   vs_let_scalar              - Read scalar data defined on grid centers from a trim- or com-file.
%   vs_let_vector_cen          - Read U,V vector data to centers from a trim- or com-file.
%   vs_let_vector_cor          - Read U,V vector data to corners from a trim- or com-file.
%   vs_mask                    - Read active/inactive mask of Delft3D results in trim- or com-file.
%   vs_meshgrid2dcorcen        - Read 2D time-independent grid info from NEFIS file.
%   vs_meshgrid3dcorcen        - Read 3D time-dependent grid info from NEFIS file.
%   vs_mnk                     - Read the grid size from NEFIS file.
%   vs_select_deepest_cell     - From z-layer model select locally deepest cell
%   vs_trim_station            - Read timeseries from one location from map file
%
% NEFIS history file format related (trih*,dat)
%   vs_trih2nc                 - Convert part of a Delft3D trih file to netCDF (BETA)
%                                We recommend use netCDF, and avoid using the slow trih file.
%   adcp_plot                  - plot result as ASCP data
%   vs_trih_crosssection       - Read NEFIS cross-section data for one transect.
%   vs_trih_crosssection_index - Read index NEFIS cross-section properties.
%   vs_trih_station            - Read [x,y,m,n,name] information of history stations (obs point)
%   vs_trih_station_index      - Read index of history station (obs point)
%
% Visualise Delft3D 3D in Matlab
%   delft3d_3d_visualisation_example     - Example to make 3D graphics image
%   delft3d_3d2kml_visualisation_example - Example to make 3D graphics for Google Earth
%
% Visualise delft3d input/outyput in Google Earth:
%   vs_trim2kml                          - output: make a Google Earth movie of a scaler variable (vector)
%   vs_trim_to_kml_tiled_png             - output: make a Google Earth movie of a scaler variable (tiles)
%   delft3d_mdf2kml                      - input:  Save flow input to Google Earth
%   delft3d_grd2kml                      - input:  Save grid (and depth) file as kml feed for Google Earth
%
% Toolboxes
%   part      - tools related to Delft3D-PART
%   tide      - tools related to Delft3D-TIDE
%   waq       - tools related to Delft3D-WAQ
%   flow      - tools related to Delft3D-FLOW
%   dflowfm   - tools related to D-Flow FM (Flexible Mesh); Flow for unstructured grid
%
%See also: 

