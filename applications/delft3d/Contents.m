% DELFT3D - tools related to <a href="http://www.delft3d.nl">Delft3d</a>
%
% For most functionality, you need the proprietery Delft3D Matlab toolbox first:
%
%    addpath('C:\Delft3D\w32\matlab\')
%
% Note that any useful functions in C:\Delft3D\w32\matlab\private\ only
% work when you copy them to one directory level up.
%
% Files
%   d3d_sigma                  - Calculates the relative vertical sigma positions in %
%   d3d_z                      - Calculates the absolute z-layer positions in m
%   delft3d_grd2kml            - Save grid (and depth) file as kml feed for Google Earth
%   delft3d_grid_image         - Show ASCII image of Delft3D grid matrix
%   delft3d_io_ann             - Read annotation files in a nan-separated list struct (*.ann)  (BETA VERSION)
%
% NEFIS file format related
%
%   vs_trim2netcdf                   - Convert part of a Delft3D trim file to netCDF (BETA)
%   delft3d_3d_visualisation_example - Example to make 3D graphics from delft3d trim file
%
%   vs_area                    - read INCORRECT cell areas from com-file.
%   vs_get_constituent_index   - Read index information required to read constituents by name.
%   vs_get_elm_def             - Read NEFIS Element data
%   vs_get_elm_size            - Read size of NEFIS Element data
%   vs_get_grp_def             - Read NEFIS Element data
%   vs_get_grp_size            - Read size of NEFIS Element data
%   vs_getmnk                  - Read the grid size from NEFIS file.
%   vs_let_scalar              - Read scalar data defined on grid centers from a trim- or com-file.
%   vs_let_vector_cen          - Read U,V vector data to centers from a trim- or com-file.
%   vs_let_vector_cor          - Read U,V vector data to corners from a trim- or com-file.
%   vs_mask                    - Read active/inactive mask of Delft3D results in trim- or com-file.
%   vs_meshgrid2d              - Read time-independent grid info from trim/com file
%   vs_meshgrid2d0             - Read all time-independent grid info from trim/com file
%   vs_meshgrid2dcorcen        - Read 2D time-independent grid info from NEFIS file.
%   vs_meshgrid3d              - Read all the relevant griddata
%   vs_meshgrid3dcorcen        - Read 3D time-dependent grid info from NEFIS file.
%   vs_mnk                     - Read the grid size from NEFIS file.
%   vs_select_deepest_cell     - From z-layer model select locally deepest cell
%   vs_time                    - Read time information from NEFIS file
%   vs_trih_crosssection       - Read NEFIS cross-section data for one transect.
%   vs_trih_crosssection_index - Read index NEFIS cross-section properties.
%   vs_trih_station            - Read [x,y,m,n,name] information of history stations (obs point)
%   vs_trih_station_index      - Read index of history station (obs point)
%
% Toolboxes
%   flow                       - tools related to Delft3D-flow
%   part                       - tools related to Delft3D-part
%   tide                       - tools related to Delft3D-tide
%   waq                        - tools related to Delft3D-waq
%
%See also: 

