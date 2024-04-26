%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19511 $
%$Date: 2024-04-02 12:11:51 +0200 (Tue, 02 Apr 2024) $
%$Author: chavarri $
%$Id: labels4all.m 19511 2024-04-02 10:11:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/labels4all.m $
%
%Filters data to that one within bounds.
        
function [x,y,z]=filter_to_figure_limts(x,y,z,lims_x,lims_y)

if [size(x);size(y);size(z)]~=repmat(size(x),3,1) 
    error('Dimensions do not match.')
end

bol=x<lims_x(2) & x>lims_x(1) & y<lims_y(2) & y>lims_y(1);
x=x(bol);
y=y(bol);
z=z(bol);

end