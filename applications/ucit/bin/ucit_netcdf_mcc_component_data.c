/*
 * MATLAB Compiler: 4.11 (R2009b)
 * Date: Thu Nov 25 14:52:53 2010
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "-v" "-d"
 * "bin" "ucit_netcdf.m" "-B" "complist" "-a" "betacdf.m" "betainv.m"
 * "betapdf.m" "distchck.m" "polyconf.m" "tinv.m" "UCIT_IsohypseInPolygon.m"
 * "UCIT_getCrossSection.m" "UCIT_plotDataInGoogleEarth.m"
 * "UCIT_plotDataInPolygon.m" "UCIT_plotDifferenceMap.m"
 * "UCIT_plotGridOverview.m" "UCIT_sandBalanceInPolygon.m"
 * "UCIT_exportTransects2GoogleEarth.m" "UCIT_plotTransectOverview.m"
 * "UCIT_selectTransect.m" "UCIT_showTransectOnOverview.m"
 * "UCIT_analyseTransectVolume.m" "UCIT_calculateMKL.m" "UCIT_calculateTKL.m"
 * "UCIT_plotMultipleYears.m" "UCIT_plotTransect.m" "UCIT_plotAlongshore.m"
 * "UCIT_plotDots.m" "UCIT_plotDotsInPolygon.m" "UCIT_plotLidarTransect.m"
 * "UCIT_plotMultipleTransects.m" "UCIT_SelectTransectsUS.m" "UCIT_cdots_amy.m"
 * "UCIT_clbPlotUSGS.m" "UCIT_exportSelectedTransects2GoogleEarth.m"
 * "UCIT_fncResizeUSGS.m" "UCIT_getLidarMetaData.m" "UCIT_plotDots.m"
 * "UCIT_plotDotsAmy.m" "UCIT_saveDataUS.m" "UCIT_toggleCheckBoxes.m"
 * "UCIT_DC_selectTransects.m" "UCIT_DC_setValuesOnPopup.m" "UCIT_Help.m"
 * "UCIT_Options.m" "UCIT_batchCommand.m" "UCIT_checkPopups.m"
 * "UCIT_findAvailableActions.m" "UCIT_getInfoFromPopup.m" "UCIT_getObjTags.m"
 * "UCIT_loadRelevantInfo2Popup.m" "UCIT_makeUCITConsole.m" "UCIT_next.m"
 * "UCIT_preparePlot.m" "UCIT_print.m" "UCIT_quit.m" "UCIT_resetUCITDir.m"
 * "UCIT_resetValuesOnPopup.m" "UCIT_restoreWindowsPositions.m"
 * "UCIT_selectFile.m" "UCIT_selectRay.m" "UCIT_selectRayPoly.m"
 * "UCIT_selectUser.m" "UCIT_setIniDir.m" "UCIT_setValues2Popup.m"
 * "UCIT_showRay.m" "UCIT_takeAction.m" "addUCIT.m" "doNothing.m"
 * "ucit_about.m" "UCIT_computeGridVolume.m" "UCIT_findCoverage.m"
 * "UCIT_getDatatypes.m" "UCIT_getMetaData.m" "UCIT_getMetaData_grid.m"
 * "UCIT_getMetaData_transect.m" "UCIT_getSandBalance.m"
 * "UCIT_getSandBalance_test_exclude.m" "UCIT_plotSandbalance.m"
 * "readLidarDataNetcdf.m" "UCIT_CompXYLim.m" "UCIT_WS_getCrossSection.m"
 * "UCIT_WS_polydraw.m" "UCIT_ZoomInOutPan.m" "UCIT_findAllObjectsOnToken.m"
 * "UCIT_focusOn_Window.m" "UCIT_getPlot.m" "UCIT_getPlotPosition.m"
 * "UCIT_parseStringOnToken.m" "UCIT_plotFilteredTransectContours.m"
 * "UCIT_plotGrid.m" "UCIT_plotLandboundary.m" "UCIT_plotTransectContours.m"
 * "UCIT_prepareFigureN.m" "UCIT_selectGridPoly.m" "UCIT_selectObject.m"
 * "Im2Ico.m" "-a" "..\..\io\netcdf\toolsUI-4.1.jar" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_ucit_netcdf_session_key[] = {
    '5', 'F', '2', 'C', 'D', '4', 'B', '6', '6', '3', 'C', '4', 'C', '2', '7',
    '2', 'D', '6', 'F', 'A', 'D', 'C', 'D', '3', '4', '1', 'A', '5', '5', '8',
    '2', 'F', 'C', '3', '4', '2', '8', '5', '1', '6', '5', '8', '7', 'C', 'D',
    'E', '8', 'A', '6', '3', '2', '0', '6', '5', '6', 'E', '3', '5', '1', 'F',
    'B', 'F', '6', '5', '1', '2', '5', 'C', '5', '5', '4', 'D', '5', '7', '3',
    '5', '6', 'A', '8', '2', 'C', 'C', '0', '5', '7', 'F', '1', '3', '6', '1',
    'D', '7', '7', '6', '2', 'A', '5', '4', '9', '1', '5', 'F', 'A', 'E', '5',
    '7', 'F', '3', 'E', '0', '6', 'A', 'D', 'E', '2', '3', '2', '1', '9', '3',
    'B', '2', '4', 'B', '5', 'F', 'C', 'D', '9', 'A', 'D', 'D', 'F', '9', '9',
    '9', 'E', '6', '9', '1', 'F', '9', '3', '9', 'D', '6', '7', '8', '4', '4',
    '4', '0', '1', '4', '9', '8', '7', '1', 'F', '6', 'C', 'E', 'F', '9', '3',
    'E', '1', '2', '9', '5', 'A', '6', '4', '3', 'F', '5', '5', 'E', '3', '8',
    'D', 'B', '4', '3', '5', 'E', 'A', '7', 'D', '3', '7', '2', '7', '0', 'C',
    '9', '7', '7', '0', '4', '7', 'D', '9', 'C', 'E', 'B', '7', 'A', '0', '3',
    '9', '2', '6', 'E', 'F', '6', 'D', '3', 'A', '3', '9', '4', 'C', 'A', '8',
    '6', 'E', '6', 'E', '1', '1', '2', '1', '1', '5', '7', '6', '1', '8', 'A',
    'B', '0', 'D', 'E', '5', 'F', '7', '5', 'E', '2', '6', '4', '2', 'B', '5',
    '7', '\0'};

const unsigned char __MCC_ucit_netcdf_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_ucit_netcdf_matlabpath_data[] = 
  { "ucit_netcdf/", "$TOOLBOXDEPLOYDIR/",
    "gui/actions/UCIT_CommonActions/DataGrids/",
    "gui/actions/UCIT_CommonActions/DataTransects/",
    "gui/actions/UCIT_SpecificActions/DataTransects/JarkusData/",
    "gui/actions/UCIT_SpecificActions/DataTransects/LidarDataUS/",
    "gui/actions/UCIT_SpecificActions/DataTransects/LidarDataUS/plotAlongshore/",
    "gui/base/", "gui/data/", "gui/figs/", "gui/icons/", "engines/",
    "app/matlab/toolbox/wl_fileio/", "app/matlab/toolbox/wl_guitools/",
    "app/matlab/toolbox/wl_ideas/", "app/matlab/toolbox/wl_mexnc/",
    "app/matlab/toolbox/wl_ncutility/", "app/matlab/toolbox/wl_oldtools/",
    "app/matlab/toolbox/wl_quickplot/", "app/matlab/toolbox/wl_snctools/",
    "app/matlab/toolbox/wl_tools/", "Repositories/OeTools/",
    "Repositories/OeTools/applications/DUROS/engines/",
    "Repositories/OeTools/applications/DUROS/engines/Crossings/",
    "Repositories/OeTools/applications/DelftDashBoard/general/misc/",
    "Repositories/OeTools/applications/Rijkswaterstaat/jarkus/",
    "Repositories/OeTools/applications/SuperTrans/conversion/",
    "Repositories/OeTools/applications/SuperTrans/conversion_dlls_32/",
    "Repositories/OeTools/applications/SuperTrans/conversion_m/",
    "Repositories/OeTools/applications/SuperTrans/general/",
    "Repositories/OeTools/applications/SuperTrans/gui/",
    "Repositories/OeTools/applications/googleplot/",
    "Repositories/OeTools/applications/googleplot/KMLengines/",
    "Repositories/OeTools/applications/grid_2D_orthogonal/",
    "Repositories/OeTools/general/",
    "Repositories/OeTools/general/color_fun/colormaps/",
    "Repositories/OeTools/general/debug_fun/",
    "Repositories/OeTools/general/el_fun/",
    "Repositories/OeTools/general/el_mat/",
    "Repositories/OeTools/general/gui_fun/",
    "Repositories/OeTools/general/io_fun/",
    "Repositories/OeTools/general/oet_defaults/",
    "Repositories/OeTools/general/phys_fun/",
    "Repositories/OeTools/general/plot_fun/",
    "Repositories/OeTools/general/poly_fun/",
    "Repositories/OeTools/general/string_fun/",
    "Repositories/OeTools/general/struct_fun/",
    "Repositories/OeTools/general/time_fun/",
    "Repositories/OeTools/io/opendap/",
    "Repositories/OeTools/maintenance/1_MTest/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/winfun/NET/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "toolbox/shared/dastudio/", "$TOOLBOXMATLABDIR/datamanager/",
    "toolbox/compiler/", "Repositories/OeTools/io/netcdf/nctools/" };

static const char * MCC_ucit_netcdf_classpath_data[] = 
  { "Repositories/OeTools/io/netcdf/toolsUI-4.1.jar" };

static const char * MCC_ucit_netcdf_libpath_data[] = 
  { "" };

static const char * MCC_ucit_netcdf_app_opts_data[] = 
  { "" };

static const char * MCC_ucit_netcdf_run_opts_data[] = 
  { "" };

static const char * MCC_ucit_netcdf_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_ucit_netcdf_component_data = { 

  /* Public key data */
  __MCC_ucit_netcdf_public_key,

  /* Component name */
  "ucit_netcdf",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_ucit_netcdf_session_key,

  /* Component's MATLAB Path */
  MCC_ucit_netcdf_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  89,

  /* Component's Java class path */
  MCC_ucit_netcdf_classpath_data,
  /* Number of directories in the Java class path */
  1,

  /* Component's load library path (for extra shared libraries) */
  MCC_ucit_netcdf_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_ucit_netcdf_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_ucit_netcdf_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "ucit_netcdf_537A64970B715D56ECD47124A851B786",

  /* MCR warning status data */
  MCC_ucit_netcdf_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


