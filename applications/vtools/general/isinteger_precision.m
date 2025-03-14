%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20065 $
%$Date: 2025-02-21 08:59:22 +0100 (Fri, 21 Feb 2025) $
%$Author: chavarri $
%$Id: D3D_rework.m 20065 2025-02-21 07:59:22Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_rework.m $
%
%Check if a double precision is an integer up to a certain precision

function isint=isinteger_precision(val)

tol=1e-12;
isint=abs(val-round(val))<tol;

end %function

