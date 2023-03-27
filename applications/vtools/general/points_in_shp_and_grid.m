%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18819 $
%$Date: 2023-03-13 16:40:14 +0100 (Mon, 13 Mar 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18819 2023-03-13 15:40:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%find points `nodes_x` and `nodes_y` inside a shapefile (several in a directory
%or one)

function [in_bol,x_pol_in,y_pol_in]=points_in_shp_and_grid(fpath_pol_in,nodes_x,nodes_y,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'nparts_inpoly',1000);

parse(parin,varargin{:});

nparts_inpoly=parin.Results.nparts_inpoly;

%% CALC

if isfolder(fpath_pol_in)
    fpath_inpol=fullfile(fpath_pol_in,'bol.mat');
else
    [fdir,fname]=fileparts(fpath_pol_in);
    fpath_inpol=fullfile(fdir,sprintf('%s.mat',fname));
end

if exist(fpath_inpol,'file')==2
    load(fpath_inpol,'in_bol','x_pol_in','y_pol_in')
else
    [x_pol_in,y_pol_in]=join_shp_xy(fpath_pol_in);
    in_bol=inpolygon_chunks(nodes_x,nodes_y,x_pol_in,y_pol_in,nparts_inpoly);
    save(fpath_inpol,'in_bol','x_pol_in','y_pol_in')
end

%%
% figure
% hold on
% plot(x_pol_in,y_pol_in)
% scatter(nodes_x,nodes_y)
% axis equal
end %function