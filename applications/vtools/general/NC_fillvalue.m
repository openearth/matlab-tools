%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19877 $
%$Date: 2024-11-07 12:42:34 +0100 (Thu, 07 Nov 2024) $
%$Author: ottevan $
%$Id: write_subdomain_bc.m 19877 2024-11-07 11:42:34Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/write_subdomain_bc.m $
%
%Replaces the value in an NC variable to the fill value. 
%
%INPUT:
%   - fpath = full path to NC file; [char]
%   - varname = variable name; [char]
%
%OUTPUT:
%

function NC_fillvalue(fpath,varname)

var=ncread(fpath,varname);
fillvalue=ncreadatt(fpath,varname,'_FillValue'); 
ncwrite(fpath,varname,fillvalue*ones(size(var)),1);

end %function