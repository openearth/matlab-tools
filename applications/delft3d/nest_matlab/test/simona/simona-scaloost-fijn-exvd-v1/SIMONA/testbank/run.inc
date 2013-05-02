
# Bufsizes to use
$bufsize{coppre} = 200;
$bufsize{waqpre} = 40;
$bufsize{waqpro} = 40;
$bufsize{coppos} = 200;

# Number of process used for WAQPRO
$npart{waqpro} = 4;

# PBS options
##$Parallel{UsePBS}{waqpro} = 1;
##$Parallel{PBSDefaults}{waqpro} =
##   "-l nodes=$npart{waqpro}".
##     ",walltime=10:00:00".
##     ",cput=100:00:00".
##     ",mem=20mb".
##   " -N zuno";

