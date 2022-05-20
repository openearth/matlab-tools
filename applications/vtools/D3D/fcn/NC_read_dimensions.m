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
%get data from 1 time step in D3D, output name as in D3D

function out=NC_read_dimensions(simdef_file)

%% domain size
nc_info=ncinfo(simdef_file);
ndim=numel(nc_info.Dimensions);
for kdim=1:ndim
    switch nc_info.Dimensions(kdim).Name
        case 'nBedLayers'
            out.nl=nc_info.Dimensions(kdim).Length;
        case 'time'
            out.nTt=nc_info.Dimensions(kdim).Length;
        case 'nSedTot'
            out.nf=nc_info.Dimensions(kdim).Length;
        case 'nmesh2d_layer' %this and next are the same
            out.nfl=nc_info.Dimensions(kdim).Length; 
        case 'mesh2d_nLayers' %this and previous are the same
            out.nfl=nc_info.Dimensions(kdim).Length; 
        case 'mesh1d_nNodes' %this and previous are the same
            out.nn=nc_info.Dimensions(kdim).Length; 
        case 'laydim'
            out.kz=nc_info.Dimensions(kdim).Length; 
        case 'stations'
            out.stations=nc_info.Dimensions(kdim).Length; 
        case 'ndump'
            out.ndump=nc_info.Dimensions(kdim).Length; 
    end

end

if isfield(out,'nfl')==0 %if the field 'nmesh2d_layer' does not exist, it is 2DH
    out.nfl=1;
end


