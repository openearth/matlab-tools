% DELFT3D - tools related to <a href="http://www.delft3d.nl">Delft3d</a>
%
% Files
%   d3d_sigma                  - calculates the relative vertical sigma positions in %
%   d3d_z                      - calculates the absolute z-layer positions in m
%   delft3d_grid_image         - ASCII image of Delft3D grid matrix
%   delft3d_io_ann             - Read annotation files in a nan-separated list struct (*.ann)  (BETA VERSION)
%   vs_area                    - reads INCORRECT cell areas from com-file.
%   vs_get_constituent_index   - get index information required to read constituents by name.
%   vs_get_elm_def             - Extract NEFIS Element data
%   vs_get_elm_size            - Extract size of NEFIS Element data
%   vs_get_grp_def             - vs_get_grp_def   Extract NEFIS Element data
%   vs_get_grp_size            - Extract size of NEFIS Element data
%   vs_getmnk                  - Reads the grid size from NEFIS file.
%   vs_let_scalar              - Reads scalar data defined on grid centers from a trim- or com-file.
%   vs_let_vector_cen          - Reads U,V vector data to centers from a trim- or com-file.
%   vs_let_vector_cor          - Reads U,V vector data to corners from a trim- or com-file.
%   vs_mask                    - returns active/inactive mask of Delft3D results in trim- or com-file.
%   vs_meshgrid2d              - reads time-independent grid info from trim/com file
%   vs_meshgrid2d0             - reads all time-independent grid info from trim/com file
%   vs_meshgrid2dcorcen        - Reads 2D time-independent grid info from NEFIS file.
%   vs_meshgrid3d              - reads all the relevant griddata
%   vs_meshgrid3dcorcen        - Reads 3D time-dependent grid info from NEFIS file.
%   vs_mnk                     - Reads the grid size from NEFIS file.
%   vs_select_deepest_cell     - From z-layer model select locally deepest cell
%   vs_time                    - reads time information from NEFIS file
%   vs_trih_crosssection       - Reads NEFIS cross-section data for one transect.
%   vs_trih_crosssection_index - List index NEFIS cross-section properties.
%   vs_trih_station            - get [x,y,m,n,name] information of history stations (obs point)
%   vs_trih_station_index      - get index of history station (obs point)
%
% Toolboxes
%   flow                       - tools related to Delft3D-flow
%   part                       - tools related to Delft3D-part
%   tide                       - tools related to Delft3D-tide
%   waq                        - tools related to Delft3D-waq
%
%See also: 

