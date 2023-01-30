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
%

function [ismor,is1d,str_network1d,issus,structure]=D3D_is(nc_map)

if iscell(nc_map) %case of SMT-D3D4 
    nc_map=nc_map{1}; %they are all the same
    [ismor,is1d,str_network1d,issus,structure]=D3D_is(nc_map);
    return
end
[~,~,ext]=fileparts(nc_map);

if strcmp(ext,'.nc') %FM
    nci=ncinfo(nc_map);

    %ismor
    idx=find_str_in_cell({nci.Variables.Name},{'mesh2d_mor_bl','mesh1d_mor_bl'});
    ismor=1;
    if any(isnan(idx))
        ismor=0;
    end
    
    %is suspended load
    idx=find_str_in_cell({nci.Variables.Name},{'cross_section_suspended_sediment_transport','mesh2d_sscx'});
    issus=1;
    if any(isnan(idx))
        issus=0;
    end

    %is 1D simulation
    idx=find_str_in_cell({nci.Variables.Name},{'mesh2d_node_x'});
    is1d=0;
    if any(isnan(idx))
        is1d=1;
    end
    idx=find_str_in_cell({nci.Variables.Name},{'network1d_geom_x'});
    if isnan(idx)
        str_network1d='network';
    else
        str_network1d='network1d';
    end

    structure=2;
elseif strcmp(ext,'.dat')
    NFStruct=vs_use(nc_map,'quiet');
    ismor=1;
    is1d=0;
    str_network1d='';
    issus=NaN; %add!
    if isnan(find_str_in_cell({NFStruct.GrpDat.Name},{'map-infsed-serie'})) && isnan(find_str_in_cell({NFStruct.GrpDat.Name},{'his-infsed-serie'}))
        ismor=0;
    end
    structure=1;
elseif strcmp(ext,'.grd')
    ismor=NaN;
    is1d=0;
    str_network1d='';
    issus=NaN; %add!
    structure=1;
else
    error('unknown format %s',ext)
end

end %function
