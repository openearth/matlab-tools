% googlePlot: command-line toolbox to make KML (Google Earth) files
%
% This toolbox is continously in development. Please help
% us in improving this toolbox, see the official OGC documentation:
% http://www.opengeospatial.org/standards/kml
% plus the examples in the Tutorial, Developers Guide and Reference:
% http://code.google.com/apis/kml/
% This toolbox is part of the OpenEarthTools dstribition (http://OpenEarth.eu)
%
% Every googlePlot function has a number of <keyword,value> pairs with
% good defaults. To get a list of the available keywords plus their
% defaults call a function without input, e.g.: KMLline(). For examples
% and tests: https://repos.deltares.nl/repos/OpenEarthTools/test/matlab/applications/googleplot/
% 
% Single object(s) plots:
%  KMLanimatedIcon                - adds place markers with color varying in time
%  KMLcurtain                     - Create a time animated curtain for e.g. adcp data
%  KMLcolumn                      - draw a 3D cylinder at a specific location (enveloping tubes)
%  KMLcylinder                    - draw a 3D cylinder at a specific location (stacked segments)
%  KMLline                        - Just like line (and that's just like plot)
%  KMLmarker                      - add a placemarker pushpin with text ballon
%  KMLpatch                       - Just like patch
%  KMLpatch3                      - Just like patch
%  KMLscatter                     - Just like scatter and plotc
%  KMLtext                        - Just like text 
%
% Surface plots (continuous 2D & 3D):
%  KMLcontour                     - Just like contour
%  KMLcontour3                    - Just like contour3
%  KMLcontourf                    - Just like contourf (BETA!!!)
%  KMLcontourf3                   - Wrapper for KMLtricontourf, to make it 3D
%  KMLfigure_tiler                - makes a tiled png figure for google earth
%  KMLmesh                        - Just like mesh
%  KMLpcolor                      - Just like pcolor
%  KMLsurf                        - Just like surf
%  KMLsurf_tiled                  - BETA!!!!
%  KMLtricontour                  - Just like contour
%  KMLtricontour3                 - Just like contour3
%  KMLtricontourf                 - Just like tricontourc
%  KMLtricontourf3                - Wrapper for KMLtricontourf, to make it 3D
%  KMLtrisurf                     - Just like trisurf
%
% Vectors plots:
%  KMLcurvedArrows                - makes nice curved arrows that 'go with the flow'
%  KMLquiver                      - Just like quiver
%  KMLquiver3                     - Just like quiver3 (except no w yet)
%
% File and image overlay mangling:
%  KMLcolorbar                    - make KML colorbar
%  KMLlogo                        - make a white logo *.png with transparent background of an image
%  KMLtest                        - batch for all unit tests of googleplot
%  KML2kmz                        - zip kml (and subsidiary files) files into kmz
%  KMLmerge_files                 - merges all KML files in a certain directory
%
% Tutorials:
%  KMLline_tutorial               - tutorial for KMLline
%  KMLcontour3_tutorial           - tutorial for KMLcontour3
%  KMLcurvedArrows_tutorial       - tutorial for KMLcurvedArrows
%  kml_included_in_tutorial       - tutorial for including KML in web pages via Google Earth plugin
%
%See also: KMLengines, convertcoordinates (to obtain [lat,lon] in WGS 84 (EPSG:4326))