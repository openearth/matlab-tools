%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function pol_nan=polcell2nan(pol_cell)

np=numel(pol_cell);
pol_nan=[];
ndim=size(pol_cell{1,1},2);
nanm=NaN(1,ndim);
for kp=1:np
    pol_nan=cat(1,pol_nan,pol_cell{kp,1},nanm);
end
