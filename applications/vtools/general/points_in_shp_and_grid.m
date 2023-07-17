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
%find points `nodes_x` and `nodes_y` inside a shapefile (several in a directory
%or one)

function [in_bol,x_pol_in,y_pol_in]=points_in_shp_and_grid(fpath_pol_in,nodes_x,nodes_y,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'nparts_inpoly',1000);
addOptional(parin,'overwrite',1);

parse(parin,varargin{:});

nparts_inpoly=parin.Results.nparts_inpoly;
overwrite=parin.Results.overwrite;

%% CALC

if isfolder(fpath_pol_in)
    fpath_inpol=fullfile(fpath_pol_in,'bol.mat');
else
    [fdir,fname]=fileparts(fpath_pol_in);
    fpath_inpol=fullfile(fdir,sprintf('%s.mat',fname));
end

if exist(fpath_inpol,'file')==2 && ~overwrite
    load(fpath_inpol,'in_bol','x_pol_in','y_pol_in')
else
    [x_pol_in,y_pol_in]=join_shp_xy(fpath_pol_in);
    in_bol=inpolygon_chunks(nodes_x,nodes_y,x_pol_in,y_pol_in,nparts_inpoly);
    save(fpath_inpol,'in_bol','x_pol_in','y_pol_in')
end

%%
figure
hold on
plot(x_pol_in,y_pol_in)
scatter(nodes_x,nodes_y,10,'k*')
scatter(nodes_x(in_bol),nodes_y(in_bol),10,'ro')
axis equal
end %function