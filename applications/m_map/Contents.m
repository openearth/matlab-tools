% M_Map - mapping toolbox (Author: rich@eos.ubc.ca)
% Version 1.4d 1 Oct 2008
%
% You have collected your data, loaded it into Matlab, analyzed 
% everything to death, and now you want to make a simple map showing 
% how it relates to the world. 
%
% But you can't. 
%
% Instead you have to figure out how to save all your data, and 
% then read it into a mapping program, and then spend all that extra 
% time figuring out why the mapping program doesn't give you what
% you expected it would...
%
% No more! 
%
%                            Announcing M_Map v1.4! 
%
% M_Map is a set of mapping tools written for Matlab v5. These include: 
%
%    1. Routines to project data in 18 different spherical 
%       projections (and determine inverse mappings) 
%    2. A grid generation routine to make nice axes with 
%       limits either in long/lat terms or in planar
%       X/Y terms. 
%    3. A coastline database (with 1/4 degree resolution) 
%    4. A global elevation database (1 degree resolution) 
%    5. Hooks into freely available high-resolution coastlines and
%       bathymetry/topography.
%
% M_Map v1.4 is available via the web at 
%
%       http://www.eos.ubc.ca/~rich/
%
%
% Toolbox contents
%
%    Contents      - This file
%    m_demo        - demonstrates a few different maps.
%
%  User-callable functions
%
%    m_proj        - initializes projections
%    m_coord       - converts between geomagnetic and geographic coords.
%
%    m_grid        - draws grids 
%    m_scale       - forces map to a given scale.
%    m_ruler       - draw a scale ruler
%
%    m_ungrid      - erases map elements (if you want to change parameters)
%
%    m_coast       - draws a coastline
%    m_elev        - draws elevation data from 1 degree database
%
%    m_tbase       - draws elevation data from 5-minute TerrainBase database
%    m_gshhs       - draws coastline from GSHHS with specified resolution
%    m_gshhs_c     - draws coastline from GSHHS crude database
%    m_gshhs_l     - draws coastline from GSHHS low-resolution database
%    m_gshhs_i     - draws coastline from GSHHS intermediate-resolution database
%    m_gshhs_h     - draws coastline from GSHHS high-resolution database
%    m_gshhs_f     - draws coastline from GSHHS full database
%    m_plotbndry   - draws a political boundary from the DCW 
%    m_usercoast   - draws a coastline using a user-specified subset database.
%
%    m_plot        - draws line data in map coords
%    m_line        - draws line data in map coords
%    m_text        - adds text data in map coords
%    m_legend      - Draw a legend box
%    m_quiver      - draws arrows for vector data
%    m_contour     - draws contour lines for gridded data
%    m_contourf    - draws filled contours
%    m_patch       - draws patch data
%    m_track       - draws annotated tracklines
%    m_hatch       - hatched or speckled patches.
%    m_range_ring  - draws range rings (spherical coords)
%
%    m_ll2xy       - converts from long/lat to map coordinates
%    m_xy2ll       - converts from map coordinates to long/lat
%
%    m_geo2mag       - converts from long/lat to geomagnetic coordinates
%    m_mag2geo       - converts from geomagnetic coordinates to long/lat
%
%    m_lldist      - spherical distance/geodesics between points (long/lat coordinates)
%    m_xydist      - spherical distance between points (map projection coordinates)
%
%    m_fdist       - ellipsoidal geodesic forward calculation 
%    m_idist       - ellipsoidal geodesic inverse calculation 
%    m_geodesic    - points along ellipsoidal geodesics
%
%    m_tba2b       - used in installing high-resolution elevation database.
%
%    m_vec         - fancy arrows
%
%  Internal functions (not meant to be user-callable)
%
%    private/mp_azim     - azimuthal projections
%    private/mp_cyl      - cylindrical projections (equatorial)
%    private/mp_conic    - conic projections
%    private/mp_tmerc    - transverse cylindrical projections
%    private/mp_utm      - elliptical universal transverse cylindrical projections
%    private/mp_omerc    - oblique cylindrical projection
%
%    private/mu_util     - various utility routines
%    private/mu_coast    - routines to handle coastlines.
%
%    private/mc_coords   - coordinate systems based on different poles.
%
%    private/clabel      - patched version of clabel 
%                         (matlab v5.1 version does not contain
%                         capabilities for different text properties).    
%
%    private/m_coasts  at - coastline data
%
%  HTML documentation
%
%    map.html           - Home page, examples
%    private/mapug.html - User's guide
%    private/*gif       - examples.
%  
%
% Questions or problems; email me - rich@eos.ubc.ca.
%
% Rich Pawlowicz
% Oceanography, Dept. of Earth and Ocean Sciences, Univ. of British Columbia, 
% 6339 Stores Rd., Vancouver, B.C. CANADA V6T 1Z4
% email: rich@eos.ubc.ca 
%
%
 

    

