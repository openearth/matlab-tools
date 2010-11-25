/*
 * MATLAB Compiler: 4.11 (R2009b)
 * Date: Thu Nov 25 14:32:13 2010
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "-v" "-d"
 * "bin" "ucit_netcdf.m" "-a" "..\..\io\netcdf\toolsUI-4.1.jar" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_ucit_netcdf_session_key[] = {
    '8', '3', 'A', '5', '9', '5', 'C', 'B', '2', 'C', '6', '6', 'F', '3', '9',
    '3', 'C', '4', '5', '0', '3', '0', 'B', '0', 'C', 'F', 'B', 'A', '0', '6',
    '5', '3', '8', '4', 'D', 'D', '2', 'C', '0', 'C', '4', '9', '0', 'F', 'A',
    '7', '5', '7', 'C', '6', '9', '6', 'E', '7', '8', 'E', 'D', '2', 'F', '1',
    'F', 'D', '6', '6', 'A', '7', '6', '3', '6', '0', '6', '5', '2', '3', '9',
    '3', 'A', '1', 'C', '2', '5', 'C', '7', '7', '1', '4', '2', '5', '3', 'C',
    '6', '4', 'F', 'C', '0', '8', '9', '2', 'E', '3', 'C', 'D', 'A', '1', '7',
    'A', '8', '9', '8', 'E', '4', 'E', 'B', '3', 'E', 'C', 'B', 'F', 'E', 'F',
    '6', '1', 'E', '7', 'E', '4', 'B', '4', 'C', '2', '8', '9', '6', 'B', '1',
    '7', '8', '5', 'C', '4', '6', '3', '7', '7', '0', '2', '0', '5', '0', 'E',
    'C', 'E', '6', '2', 'C', '0', '5', '6', '8', '7', '4', '0', '1', 'C', '4',
    '3', '6', '8', '7', '0', '7', '6', 'C', '4', 'A', 'F', 'B', '0', '4', '6',
    '8', '9', '4', '5', '3', '2', '2', 'A', '4', '7', 'A', '5', 'C', '0', '5',
    '6', '7', 'B', '1', 'D', '9', 'F', '0', '8', 'C', '6', 'D', '4', '8', '3',
    '4', '2', 'F', 'F', '4', 'C', 'B', 'B', '6', 'C', '3', '3', '5', '8', '7',
    '8', 'C', '0', '8', 'B', '5', '8', 'C', '7', '5', 'D', 'B', '3', '3', '0',
    'E', '8', '7', '8', 'D', '3', '4', '8', 'B', '5', '7', '8', 'C', '7', '8',
    'F', '\0'};

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
  { "ucit_netcdf/", "$TOOLBOXDEPLOYDIR/", "gui/base/", "gui/data/",
    "gui/figs/", "app/matlab/toolbox/wl_guitools/",
    "app/matlab/toolbox/wl_mexnc/", "app/matlab/toolbox/wl_ncutility/",
    "app/matlab/toolbox/wl_oldtools/", "app/matlab/toolbox/wl_snctools/",
    "Repositories/OeTools/general/", "Repositories/OeTools/general/plot_fun/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/randfun/", "$TOOLBOXMATLABDIR/elfun/",
    "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
    "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
    "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
    "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/graph2d/",
    "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/winfun/NET/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "toolbox/shared/dastudio/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

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
  50,

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
  "ucit_netcdf_B9D75BA903F5AE3615A477CB96A55071",

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


