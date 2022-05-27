%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-20 18:31:37 +0200 (Fri, 20 May 2022) $
%$Author: chavarri $
%$Id: D3D_time_dnum.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_time_dnum.m $
%
%

function [m,idx]=cell2mat_clean(c)

idx=[];
for k1=1:size(c,1)
    for k2=1:size(c,2)
        if ~isnumeric(c{k1,k2})
            idx=cat(1,idx,[k1,k2]);
            c{k1,k2}=NaN;
        end
    end
end

m=cell2mat(c);


