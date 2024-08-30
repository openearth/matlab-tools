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