%ODVTEST   script to test ODVRREAD, ODVDISP, ODVPLOT_CAST, ODVPLOT_OVERVIEW
%
% plots all CTDCAST files in a directory one by one.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL
% $Keywords:

OPT(1).directory = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-270409_result\'];
OPT(1).mask      = 'result_CTDCAST*.txt';

OPT(2).directory = [fileparts(mfilename('fullpath')),filesep,'userkc30e50-data_centre632-090210_result\'];
OPT(2).mask      = 'world*.txt';

for i=1:length(OPT)

   files     = dir([OPT(i).directory,filesep,OPT(i).mask]);

   % Coastline of world
   
      L.lon = nc_varget('http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc','lon');
      L.lat = nc_varget('http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc','lat');
   
   for ifile=1:length(files);
   
       fname = files(ifile).name;
       
       set(gcf,'name',[num2str(ifile),': ',fname])
   
       D = odvread([OPT(i).directory,filesep,fname]);
       
      %odvdisp(D)
   
       if D.cast==1
       odvplot_cast    (D,L.lon,L.lat)
       else
       odvplot_overview(D,L.lon,L.lat)
       end
       
       disp(['plotting # ',num2str(ifile,'%0.3d'),', press key to continue'])
       pausedisp
       clf
          
   end % ifile 
   
end   