% Delft3D-MATLAB interface toolbox.
%   Private functions.
%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%
% Data data access functions
%   ai_ungen                    - Read/write ArcInfo (un)generate files.
%   arcgrid                     - Read/write operations for arcgrid files.
%   asciiwind                   - Read operations for ascii wind files.
%   aukepc                      - Read AUKE/pc files.
%   bagdpt                      - Read output files BAGGER-BOS-RIZA bagger option.
%   bagmap                      - Read output files BAGGER-BOS-RIZA bagger option.
%   bct_io                      - Read/write boundary condition tables.
%   bil                         - Read bil/hdr files.
%   bna                         - Read/write for ArcInfo (un)generate files.
%   boxfile                     - Read/write SIMONA box files.
%   dbase                       - Read data from a dBase file.
%   delwaq                      - Read/write Delwaq files.
%   delwaqtimfile               - Reads in a Delwaq .tim input file (Lex Yacc type).
%   fls                         - Read Delft-FLS and SOBEK2D incremental files.
%   gsharp                      - Read/write GSharp files.
%   inifile                     - Read/write INI files.
%   jspost                      - Read JSPost files.
%   mike                        - Read/write DHI Mike files.
%   morf                        - Read Delft3D-MOR morf files.
%   pcraster                    - Read/write PC-Raster files.
%   qnhls                       - Read/write Quickin HLS files.
%   readswan                    - Read SWAN 1D and 2D spectral files.
%   shape                       - Read ESRI shape files.
%   shapewrite                  - Write ESRI shape files.
%   sobek                       - Read and plot SOBEK topology.
%   swan                        - Read/write SWAN files.
%   tecplot                     - Read/write for Tecplot files.
%   telemac                     - Read Telemac selafin files.
%   trtarea                     - Read Delft3D trachytope/WAQUA ecotope area files.
%   unibest                     - Read Unibest files.
%   waqfil                      - Read various Delwaq files.
%   waqua                       - Read SIMONA SDS files (low level).
%   waquaio                     - Read SIMONA SDS file.
%
% Special graphics routines
%   balanceplot                 - Create a balance plot.
%   classbar                    - Converts a color bar into a classbar.
%   colquiver                   - Color quiver plot.
%   contourfcorr                - Filled contour plot (corrected).
%   getnormpos                  - Select an area (using normalized units).
%   hls2rgb                     - Convert hue-lightness-saturation to red-green-blue colors.
%   idx2rgb                     - Converts an indexed image into a true color RGB image.
%   lddplot                     - Plot local drainage direction for PC-Raster LDD data file.
%   progressbar                 - Display progress bar.
%   qncmap                      - QuickIn color map.
%   recolor                     - Replaces one color by another color.
%   rgb2hls                     - Convert red-green-blue colors to hue-lightness-saturation.
%   series_frame                - Saves a figure in one of a series of bitmap images.
%   series_init                 - Initiates the creation of a series of bitmap files.
%   tick                        - Create ticks and ticklabels.
%   tricontourf                 - Filled contour plot for triangulated data.
%
% Generic helper routines
%   abbrevfn                    - Abbreviate filename.
%   arbcross                    - Arbitrary cross-section through grid.
%   asciiload                   - A compiler compatible version of LOAD -ASCII.
%   avi                         - MATLAB AVI interface.
%   clockwise                   - Determines polygon orientation.
%   deblank2                    - Remove leading and trailing blanks.
%   filesequal                  - Determines whether the contents of two files is the same.
%   findseries                  - Find series of nonzero elements.
%   incanalysis                 - Analyse incremental data.
%   inlist                      - Match cell arrays of strings.
%   int32_byteflip              - Convert integers into integers with flipped byte order.
%   int_lnln                    - Intersection of two lines.
%   int_lntri                   - Intersection of line and triangular mesh.
%   isstandalone                - Determines stand alone execution.
%   multiline                   - Converts a string containing LineFeeds to a char matrix.
%   pathdistance                - Computes the distance along a path.
%   realset                     - Manipulate sets of real values.
%   reducepoints                - Filters a set points using a distance threshold.
%   reducepoints_v6             - REDUCEPOINTS Filters a set points using a distance threshold.
%   stdbeep                     - Produce beep sound.
%   trim2rst                    - Extract Delft3D-FLOW restart file from TRIM-file.
%   ui_getdir                   - Compileable platform independent open directory dialog box.
%   ui_type                     - Simple selection dialog.
%   ui_typeandname              - Selection dialog with name specification.
%   uigetfolder                 - Standard Windows browse for folder dialog box.
%   vardiff                     - Determines the differences between two variables.
%   versionnumber               - Obtain the MATLAB version number.
%   writeavi                    - MEX interface to Windows AVI functions.
%
% QuickPlot file dependent routines
%   arcgridfil                  - ARCGRIDFIL.
%   asciiwindfil                - ASCIIWINDFIL.
%   aukepcfil                   - AUKEPCFIL.
%   bagdptfil                   - BAGDPTFIL.
%   bctfil                      - BCTFIL.
%   bilhdrfil                   - BILHDRFIL.
%   bitmapfil                   - BITMAPFIL.
%   d3d_bagrfil                 - D3D_BAGRFIL.
%   d3d_bothfil                 - D3D_BOTHFIL.
%   d3d_botmfil                 - D3D_BOTMFIL.
%   d3d_comfil                  - D3D_COMFIL.
%   d3d_hwgxyfil                - D3D_HWGXYFIL.
%   d3d_trahfil                 - D3D_TRAHFIL.
%   d3d_tramfil                 - D3D_TRAMFIL.
%   d3d_tridfil                 - D3D_TRIDFIL.
%   d3d_trihfil                 - D3D_TRIHFIL.
%   d3d_trimfil                 - D3D_TRIMFIL.
%   d3d_waqfil                  - D3D_WAQFIL.
%   ecomsedfil                  - ECOMSEDFIL.
%   flsfil                      - FLSFIL.
%   gridfil                     - GRIDFIL.
%   jspostfil                   - JSPOSTFIL.
%   matlabfil                   - MATLABFIL.
%   mikezerofil                 - MIKEZEROFIL.
%   morftreefil                 - MORFTREEFIL.
%   netcdffil                   - NETCDFFIL.
%   nfs_tritonfil               - NFS_TRITONFIL.
%   pcrasterfil                 - PCRASTERFIL.
%   pharosfil                   - PHAROSFIL.
%   resourceobject              - Implements old interface for new QUICKPLOT Data Resource Object.
%   samplesfil                  - SAMPLESFIL.
%   skyllafil                   - SKYLLAFIL.
%   sobekfil                    - SOBEKFIL.
%   swanfil                     - SWANFIL.
%   tekalfil                    - TEKALFIL.
%   telemacfil                  - TELEMACFIL.
%   unibestfil                  - UNIBESTFIL.
%   usrdeffil                   - USRDEFFIL.
%   waquafil                    - WAQUAFIL.
%
% QuickPlot specific helper routines
%   adddimension                - Add a dimension to a dimension list.
%   addlocation                 - Add a location to a location list.
%   auto_map_detect             - Autodetect function for Delft3D map files.
%   compthresholds              - COMPTHRESHOLDS.
%   computecomponent            - Compute component of vector data set.
%   corner2center               - Interpolate data from cell corners to cell centers.
%   cur2ca                      - Rotate velocity components.
%   default_quantities          - Default implementation for quantities.
%   determine_frompoint         - DETERMINE_FROMPOINT.
%   dimensions                  - Default implementation for dimensions.
%   dir2uv                      - Convert magnitude and angle to (x,y) components.
%   domains                     - Default implementation for domains.
%   gencontour                  - GENCONTOUR.
%   genfaces                    - GENFACES.
%   genmarkers                  - GENMARKERS.
%   gensurface                  - GENSURFACE.
%   gentext                     - GENTEXT.
%   gentextfld                  - GENTEXTFLD.
%   get_matching_grid           - GET_MATCHING_GRID.
%   get_nondialogs              - Get handles of all non-dialog windows.
%   getdata                     - Default implementation for getdata.
%   getmatchinglga              - GETMATCHINGLGA.
%   getsubfields                - Default implementation for subfields.
%   getvalstr                   - Get string associated with value of object.
%   gridcelldata                - GRIDCELLDATA.
%   gridinterp                  - Compute grid locations from corner co-ordinates.
%   insstruct                   - Insert array.
%   interp2cen                  - Interpolate to center.
%   limitresize                 - Constrained resize.
%   limits                      - Determine real x,y,z,c limits.
%   listnames                   - Name graphics objects.
%   locations                   - Default implementation for locations.
%   md_dialog                   - Simple dialog tool.
%   md_print                    - Send a figure to a printer.
%   options                     - Default implementation for options.
%   optionstransfer             - Default implementation for optionstransfer.
%   piecewise                   - Checks and fixes a piecewise grid line.
%   plotstatestruct             - PLOTSTATESTRUCT.
%   procargs                    - General function for argument processing.
%   protectstring               - PROTECTSTRING.
%   qp_basedir                  - Get various base directories.
%   qp_cmdstr                   - Process QuickPlot command string.
%   qp_colormap                 - QuickPlot colormap repository.
%   qp_createaxes               - QP_CREATEAXES.
%   qp_createfig                - QP_CREATEFIG.
%   qp_createscroller           - QP_CREATESCROLLER.
%   qp_datafield_name2prop      - Convert data field string to structure.
%   qp_defaultaxessettings      - QP_DEFAULTAXESSETTINGS.
%   qp_export                   - QP_EXPORT.
%   qp_figurebars               - QP_FIGUREBARS.
%   qp_file2function            - Retrieve function name associated with file structure.
%   qp_fmem                     - Routine for opening data files.
%   qp_fontsettings             - Convert between INI file font settings and font structures.
%   qp_gettype                  - Determine file type for file structure.
%   qp_icon                     - QuickPlot icon repository.
%   qp_interface                - Initialize QuickPlot user interface.
%   qp_interface_update_options - Update QuickPlot user interface options.
%   qp_plot                     - Plot function of QuickPlot.
%   qp_plot_default             - QP_PLOT_DEFAULT.
%   qp_plot_pnt                 - QP_PLOT_PNT.
%   qp_plot_polyl               - QP_PLOT_POLYL.
%   qp_plot_seg                 - QP_PLOT_SEG.
%   qp_plotmanager              - QP_PLOTMANAGER.
%   qp_preferences_interface    - Show QuickPlot preferences user interface.
%   qp_prefs                    - QP_PREFS.
%   qp_settings                 - Routine to store and retreive settings.
%   qp_showabout                - QP_SHOWABOUT.
%   qp_state_startup            - QP_STATE_STARTUP.
%   qp_state_version            - Check state.
%   qp_toolbarpush              - QP_TOOLBARPUSH.
%   qp_toolbartoggle            - QP_TOOLBARTOGGLE.
%   qp_tooltip                  - QP_TOOLTIP.
%   qp_uifigure                 - QP_UIFIGURE.
%   qp_uimenu                   - QP_UIMENU.
%   qp_unwrapfi                 - Remove QuickPlot wrapper from file structure.
%   qp_update_evalhistmenu      - QP_UPDATE_EVALHISTMENU.
%   qp_updatefieldprop          - QP_UPDATEFIELDPROP.
%   qp_updaterecentfiles        - QP_UPDATERECENTFILES.
%   qp_updatescroller           - QP_UPDATESCROLLER.
%   qp_vector                   - Wrapper for QUIVER and QUIVER3.
%   qp_wrapfi                   - Add QuickPlot wrapper to file structure.
%   quantities                  - Wrapper for default implementation for quantities.
%   readsts                     - Default implementation for stations.
%   readtim                     - Default implementation for times.
%   separators                  - Remove double sepators and separators at end of list.
%   setaxesprops                - SETAXESPROPS.
%   shiftcontrol                - Change the position of a uicontrol object.
%   simsteps                    - Performs an timestep analysis.
%   spatiallystructured         - SPATIALLYSTRUCTURED.
%   spirint                     - Computes spiral intensity from 3D flow field.
%   stdinputdlg                 - Input dialog box using standard settings.
%   str2file                    - Convert string to filename.
%   str2vec                     - Convert string into a vector.

%   tofront                     - Move graphics objects to front in children list.
%   transferfields              - Copy specified fields to another structure.
%   update_option_positions     - Update vertical position of plot option controls.
%   updateuicontrols            - Force an update of the uicontrol properties.
%   uv2cen                      - Interpolate velocities.
%   var2str                     - Generic "display" function with string output.
%   vec2str                     - Creates a string of a row vector.
%   writelog                    - Write QuickPlot logfile or MATLAB script.
%   xx_constants                - Define several constants.
%   xx_logo                     - Plot a logo in an existing coordinate system.

%   $Id$
