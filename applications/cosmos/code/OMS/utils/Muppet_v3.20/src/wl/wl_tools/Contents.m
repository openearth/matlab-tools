% Various Matlab tools
%
%   cont2class   - Converts continuous data into classified data.
%   countfreq    - Count frequency of occurrence.
%   thist        - Histogram given thresholds/boundaries.
%   locmin       - Find local minima (1D)
%   tindex       - Find (floating point) index of time in array.
%   curvat       - Compute the curvature in every point of a line.
%
%   matdiff      - Locates the differences between two MAT files.
%   vardiff      - Determines the differences between two variables.
%
%   funsubs      - Function output subscript referencing.
%   lnrun        - Run script (doesn't check path).
%   mypwd        - Get current working directory (no expansion).
%   excelql      - Interactive link with Excel. (PC only)
%
%   real48todouble - Convert 6 byte reals to double precision.
%
%   collabel     - Generate spreadsheet-like column labels.
%   int2roman    - Convert integer into roman numeral.
%   deblank2     - Remove leading and trailing blanks.
%   str2vec      - Convert row vector to string.
%   ustrcmpi     - Find unique string in set of strings.
%   wildstrmatch - Find strings using wildcards. (bug noticed)
%   abbrevfn     - Abbreviate filename to fit a maximum length.
%   range2num    - Interpret spreadsheat range.
%
%   getpasswd    - User interface to enter a password.
%   ui_inspectstruct - GUI for inspection of structure.
%   inquire      - Graphical interface to edit matrices.
%   sortfieldnames - Sort fieldnames in alphabetical order.
%
%   grid2tri     - Convert curvilinear data to triangulated data.
%   triarea      - Compute area covered by a triangulation.
%   trivalue     - Linear interpolation of triangulated data.
%   int_lngrd    - Compute intersection of line and curv. grid.
%   geomcorr     - Geometrical correction of data points.
%   lineseg      - Break line into segments given distance threshold.
%   pathdistance - Compute cumulative distance along a path.
%   corner2center - Interpolate data from cell corners to cell centers.
%
%   helpprint    - Print or save help information to file.
%   filesplit    - Split/combine files.
%
%   inlasgn      - Inline assignment.
%
% Delft3D related
%
%   d3d          - Delft3D/DATSEL object (easy contour, quiver).
%   drawgrid     - Plot grid with grid numbers.
%   dpgrad       - Compute depth gradients.
%   xytransp     - X,Y bottom/total transport components.
%   xyveloc      - X,Y velocity transport components.
%   actwl        - Read active waterlevel (non-dry).
%   thindam      - Plot thin dams (KCU) and inactive vel. points (KFU).
%   station      - Read data for history stations/observation points.
%   crosssec     - Read data for history cross-sections.
%   tdelft3d     - Delft3D day/time numbers <-> MATLAB daynumber.
%   tsobek       - Sobek day/time string <-> MATLAB daynumber.
%
% CFX related
%
%   cfx_da       - Compute depth averaged quantities from CFX data.
%   cfx1block    - Merge CFX 4 multiblock data into one block.
%
% Color commands
%
%   idx2rgb      - Convert indexed image to RGB image.
%   rgb2idx      - Convert RGB image to indexed image and colormap.
%   rgb2hls      - Convert RGB colors to HLS colors.
%   hls2rgb      - Convert HKS colors to RGB colors.
%
%   clrmap       - Construct your own interpolated colormap.
%   colorfix     - Converts indexed coloring to RGB coloring.
%   idxcolors    - Converts to indexed colors.
%   grayscale    - Converts the figure into a grayscale figure.
%   recolor      - Replace a color by another color.
%   qncmap       - Delft3D QuickIn colormap.
%
% Data analysis commands
%
%   arbcross     - Arbitrary cross-section through grid.
%   indcross     - Arbitrary indexed cross-section.
%   int_lngrd    - Intersection of line and grid.
%   clockpoly    - Determine drawing direction of a simple polygon.
%   clockwise    - Determine drawing direction of a simple polygon.
%
% Various graphics commands
%
%   tifseries    - Create of a series of TIFF files.
%
%   listnames    - Create appropriate string for graphic objects.
%
%   gaxes        - Graphical input new axes position.
%   absaxes      - Create axes with specified paper position.
%   relaxes      - Create new axes relative to existing axes.
%   subplots     - Create multiple subplot axes at once.
%   tick         - Change tickmarks.
%   gridlines    - Draw grid lines (don't change the tickmarks).
%   zoombox      - Plots zoombox in other axes.
%
%   getview      - Get view camera position relative to target.
%   setview      - Set camera position relative to target (extension
%                  of view).
%
%   histgauss    - Histogram plot with fitted Gauss curve.
%   errorxy      - Error plot with bars in x and y direction.
%   plotmarker   - Plot a custom marker.
%   xx_quiver    - Quiver plot with several options
%   colquiver    - Add colors to vectors
%   shadow       - Shadow lines indicating one side of line.
%   linedir      - Arrowheads indicating line direction.
%   reducepnts   - Reduce number of points based on distance.
%   reducepntsq  - Reduce number of points (quick solution).
%   rangeselect  - Select points within a square.
%   gcsc         - Get current scaling of axes on paper.
%   scalebar     - Plot a scalebar on a plot.
%   tricontour   - Plot contours for triangulated data.
%   tricontourf  - Plot filled contours for triangulated data.
%   contourfcorr - Filled contour plot (corrected).
%
%   tube3d       - Plot a 3D tube.
%   cones        - Coloured 3D cone plot.
%   my_isosurf   - Advanced isosurface plotting.
%
%   mwaitbar     - Multiple waitbars in one figure.
%   classbar     - Change colorbar into a classified bar.
%
%   exportfig    - Export a figure to Encapsulated Postscript.
%   saveppt      - Save a figure to PowerPoint. (PC only)
%   fig2xls      - Convert MATLAB figures to Excel Charts. (PC only)
%
% For more information contact Bert Jagers
