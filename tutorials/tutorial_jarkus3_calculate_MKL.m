
% now we want to calculate the MKL position. To do so we need information
% on the MHW and MLW lines. 

MHW = nc_varget(url,'mean_high_water',transect_nr,1)
MLW = nc_varget(url, 'mean_low_water',transect_nr,1)

% To find out what JarKus funtions are available, just enter 'jarkus' in 
% the command prompt or text editor and press tab. Matlab gives suggestions
% to complete the line. To figure out how the funtion works use help.

help jarkus_getMKL

MKL.x = jarkus_getMKL(x,z,MHW,MLW-MHW)
