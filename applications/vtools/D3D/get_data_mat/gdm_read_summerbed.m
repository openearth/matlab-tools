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
%%Reads summerbed polygons in a shp-file and finds the points of a grid that are
%inside the polygon. 
%

function sb_def=gdm_read_summerbed(flg_loc,fid_log,fdir_mat,fpath_sb_pol,fpath_map)

messageOut(NaN,'Start reading summer bed polygon')

%% PARSE

if isfield(flg_loc,'do_polygon_boundary')==0
    flg_loc.do_polygon_boundary=0; %not backward compatible, but safest. 
end

if isfield(flg_loc,'polygon_boundary_shrink')
    flg_loc.polygon_boundary_shrink=0.8;
end

%% PATHS

fpath_sb_mat=fpath_rkm_sb_bol(fdir_mat,fpath_sb_pol);

%%

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

if exist(fpath_sb_mat,'file')==2
    messageOut(fid_log,sprintf('Loading mat-file with summerbed inpolygon: %s',fpath_sb_mat));
    load(fpath_sb_mat,'sb_def');
    return
end

messageOut(fid_log,sprintf('Mat-file does not exist. Creating.'));

sb_raw=shp2struct(fpath_sb_pol);
sb=polcell2nan(sb_raw.xy.XY);

%why did I do this?
% is_nan_1=isnan(sb(:,1));
% sb(is_nan_1,:)=[];

%boundary
if flg_loc.do_polygon_boundary
    messageOut(fid_log,'Start finding boundary summer bed with shrink parameter %f',flg_loc.polygon_boundary_shrink)
    idx_b=boundary(sb(:,1),sb(:,2),flg_loc.polygon_boundary_shrink); %shrink value found by trial and error
    sb=sb(idx_b,:);
else
    messageOut(fid_log,'Not finding boundary of summerbed polygon. Hence, the polygon must be unique and in order.')
end

messageOut(fid_log,'Start finding inpolygon summer bed.')
bol_sb=inpolygon(gridInfo.Xcen(:),gridInfo.Ycen(:),sb(:,1),sb(:,2));

%% DEBUG

% figure
% hold on
% scatter(gridInfo.Xcen(:),gridInfo.Ycen(:),10,'b')
% plot(sb(:,1),sb(:,2))
% scatter(gridInfo.Xcen(bol_sb),gridInfo.Ycen(bol_sb),10,'r')
% axis equal

%%
%% SAVE
%%

sb_def.bol_sb=bol_sb;
sb_def.sb=sb;

save_check(fpath_sb_mat,'sb_def'); 

end %function 

%% 
%% FUNCTIONS
%%

function fpath_sb_mat=fpath_rkm_sb_bol(fdir_mat,fpath_pol)

[~,fname_pol,~]=fileparts(fpath_pol);
fpath_sb_mat=fullfile(fdir_mat,sprintf('%s.mat',fname_pol));

end %function

