%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 11:17:04 +0200 (do, 30 sep 2021) $
%$Author: chavarri $
%$Id: NC_read_time_0.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_time_0.m $
%
%Read text from nc-file and put in cell array

function c=NC_read_text(fpath,varname)

aux=ncread(fpath,varname)';
nobs_a=size(aux,1);
c=cell(nobs_a,1);
for k1=1:nobs_a
    c{k1,1}=deblank(aux(k1,:));
end

end %function