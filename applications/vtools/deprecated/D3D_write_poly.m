%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_write_poly.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_poly.m $
%
function D3D_write_poly(poly_number,cords,path_out)

% L000005
%           56           2
%    1.9385889E+05   4.4052012E+05
%    1.9380717E+05   4.4048145E+05

warning('deprecated. call <D3D_write_poly>')

nv=size(cords,1);

kf=1;
if isa(poly_number,'double')
    data{kf,1}=sprintf('L%06d',poly_number); kf=kf+1;
elseif isa(poly_number,'char')
    data{kf,1}=sprintf('%s',poly_number); kf=kf+1;
end
data{kf,1}=sprintf('           %d           2',nv); kf=kf+1;
for kv=1:nv
data{kf,1}=sprintf('    %9.8E   %9.8E',cords(kv,1),cords(kv,2)); kf=kf+1;
end

writetxt(path_out,data)

end %function
