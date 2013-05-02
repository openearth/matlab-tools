# Set predir, prodir and postdir for pre-processing, 
# processing, postprocessing
$predir  = "nautboom_pre";
$prodir  = "nautboom_pro";
$postdir = "nautboom_post";

# Bufsizes to use
$bufsize{coppre}  =  50;
$bufsize{waqpre}  =  50;
$bufsize{waqpro}  =  50;
$bufsize{coppos}  = 100;
$bufsize{sds2mat} = 100;

# Number of process used for WAQPRO
$npart{waqpro} = 8;

# PBS options
$Parallel{UsePBS}{waqpro} = 1;
$Parallel{PBSDefaults}{waqpro} =
   "-l nodes=2:ppn=4".
   " -q infinite".
   " -N kustzuid";

