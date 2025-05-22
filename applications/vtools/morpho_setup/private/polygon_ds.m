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
%Distance between polygons in shp. 
%
%This is very poor. First, the distance could be read from the shp-file. Second,
%ideally one would query all the polygons that are within a certain distance 
%from the objective one rather than trying to match the rkm.

function ds=polygon_ds(varargin)

br=varargin{1,1};

switch br
    case {'WA','IJ','WL','NI','BO','BR','PK'}
        ds=100; 
    case {'MA'}
        ds=250;
    otherwise
        error('branch not recognized: %s',br)
end 

end %function
