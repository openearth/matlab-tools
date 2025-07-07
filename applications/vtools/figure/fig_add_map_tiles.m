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

function fig_add_map_tiles(in_p,han_sfig_kr_kc)

%% PARSE

in_p=isfield_default(in_p,'plot_tiles',0);
in_p=isfield_default(in_p,'save_tiles',0);
in_p=isfield_default(in_p,'path_save',fullfile(pwd,'tiles'));
in_p=isfield_default(in_p,'path_tiles',fullfile(pwd,'earth_tiles'));
in_p=isfield_default(in_p,'epsg_in',28992);
in_p=isfield_default(in_p,'epsg_out',in_p.epsg_in);
in_p=isfield_default(in_p,'save_tiles',false);
in_p=isfield_default(in_p,'tiles',{});

v2struct(in_p);

%% CALC


if ~plot_tiles 
    return
end

OPT.xlim=lims_x;
OPT.ylim=lims_y;
OPT.epsg_in=epsg_in; %WGS'84 / google earth
OPT.epsg_out=epsg_out; %Amersfoort
dx=diff(lims_x);
tzl=tiles_zoom(dx);
OPT.tzl=tzl; %zoom
OPT.save_tiles=save_tiles;
OPT.path_save=path_save; %mat file to save tiles
OPT.path_tiles=path_tiles; %folder with tiles
OPT.map_type=3;%map type
OPT.han_ax=han_sfig_kr_kc;
OPT.tiles=tiles;

plotMapTiles(OPT);

end %function
