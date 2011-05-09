% Delft3D-MATLAB interface toolbox.
% Version 2.14.00.06176 (Feb 13 2009 21:39:07)
%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%
% Graphical user interfaces
%   d3d_qp              - QuickPlot user interface: plotting interface for Delft3D output data.
%   ecoplot             - EcoPlot: Case Analysis Tool for Delft3D-WAQ/ECO/SED data.
%   qpsa                - Get handle to the current QuickPlot axis.
%   qpsf                - Get handle to the current QuickPlot figure.
%
% Delft3D QuickPlot functions
%   qpfopen             - General routine for open various types of data files.
%   qpread              - Read data from various types of data files.
%   qpfile              - Get information about the active file in QuickPlot.
%   hslice              - Horizontal data slice of 3D data set.
%   vmean               - Compute average of data in vertical direction.
%   vrange              - Selection of data based on a vertical coordinate range.
%
% NEFIS Viewer Selector functions
%   vs_use              - Initiates the use of a NEFIS file.
%   vs_disp             - Displays the filestructure of a NEFIS file.
%   vs_let              - Read one or more elements from a NEFIS file.
%   vs_get              - Read one or more elements from a NEFIS file.
%   vs_find             - Locates an element in the filestructure of a NEFIS file.
%   vs_type             - Determines the type of the NEFIS file.
%   vs_diff             - Locates the differences between two NEFIS files.
%
% Other data access functions
%   ecomsed             - Read an ECOMSED data file.
%   enclosure           - Read/write enclosure files and convert enclosures.
%   landboundary        - Read/write land boundary files.
%   samples             - Read/write sample data from file.
%   tekal               - Read/write for Tekal files.
%   tekal2tba           - Parses comments of a TEKAL to determine tidal analysis data.
%   trirst              - Read/write Delft3D-FLOW restart file.
%   weir                - Read/write a weir file.
%   wldep               - Read/write Delft3D field files (e.g. depth files).
%   wlfdep              - Read/write Delft3D-MOR field files.
%   wlgrid              - Read/write a Delft3D grid file.
%   xyveloc             - Reads X,Y,U,V from a trim- or com-file.
%
% Special plot routines
%   drawgrid            - Plots the grid.
%   md_clock            - Create a clock or calendar.
%   md_paper            - Add border to plot.
%   plotlimitingfactors - Create a limiting factors plot.
%   plot_tidalellipses  - Plot tidal ellipses on a map.
%   qp_drawsymbol       - Draw a north arrow or incident wave arrow.
%   tba_compare         - Plot computed versus observed tidal analysis data.
%   tba_plotellipses    - Plot tidal ellipses from Delft3D-TRIANA TBA file.
%   thindam             - Plot dams, weirs and vanes.
%
% Additional tools
%   unitconversion      - Convert unit strings.
%   ustrcmpi            - Find a unique string.
%   clipgrid            - Clip a grid away from the inside/outside of a polygon.

%   @(#)Deltares, Delft3D-MATLAB interface, Version 2.14.00.06176, Feb 13 2009 21:39:07
%   $Id$

% Helper routines
%   ap2ep               - Convert tidal amplitude and phase lag (ap-) parameters into tidal ellipse
%   checklic            - Interface for checking FlexLM license.
%   convertnval         - Convert NVal between string and number.
%   md_colormap         - Colour map editor.
%   clrmap              - Creates a colormap based on a few colors.
%   qck_anim            - Helper function for QuickPlot Animations.
%   qp_colorbar         - Display color bar (color scale).
%   qp_getdata          - General interface for various data files
%   qp_gridview         - Helper routine for grid selection interface.
%   qp_validate         - Helper function to validate Delft3D-QUICKPLOT.
%   ui_inspectstruct    - Inspect a structure.
%   ui_message          - Graphical display for errors/warnings.
%   dimprint            - Convert dimension structure into string for printing.
%   stagprint           - Convert stagger name into string for printing.
%   printdims           - Display dimension information.
%   tdelft3d            - Conversion procedure for Delft3D date & time.
%   topodescription     - Returns a topology description string for a location.
%   vs_copy             - Copy data from one NEFIS file to another.
%   vs_def              - Changes the groups, cells and element definitions.
%   vs_ini              - Creates a NEFIS file.
%   vs_pack             - Remove inaccessible/unused space from a NEFIS file.
%   vs_put              - Write data to a NEFIS file.
