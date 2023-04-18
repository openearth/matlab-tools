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
%Check if query values `q` are members of vector `v` considering a tolerance `tol`.

function bol_v=ismember_num(v,q,tol)

v=reshape(v,[],1);
q=reshape(q,[],1);

bol_l=v>q'-tol;
bol_h=v<q'+tol;
bol_m=bol_l & bol_h;
bol_v=any(bol_m,2);

end %function