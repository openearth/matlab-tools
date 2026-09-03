%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Compare a raster with the polygon averaged shapefile computed from it. One
%figure per location given in the river kilometre file and per raster, with
%the raster on the left and the shapefile on the right.
%
%INPUT
%   - fpath_tif_input = path (char) or paths (cell string) to tif-files or
%       vrt-files pointing at a set of tif-files.
%   - fpath_shp_in = paths to the shapefiles produced by <tif_to_shp>, in
%       the same order as <fpath_tif_input>.
%   - fpath_rkm_plot_along = path to the river kilometre file with the
%       locations to plot. Read with <gdm_read_rkm_file>.
%   - fpath_output = folder in which the subfolder <figures> is created.
%
%OUTPUT
%   - fpath_fig = cell string with the paths to the generated figures.
%
%OPTIONAL (pair input)
%   - buffer = half the size of the window around each location [m]. Default 1000.
%   - tag_variable = attribute of the shapefile to colour the polygons with. Default 'MEAN'.
%   - fig_print = 0=no; 1=png; 2=fig; 3=eps; 4=jpg. Default 1.
%   - overwrite = true: regenerate a figure that already exists;
%       false (default): keep it.
%
%E.G.
%
% fpath_fig=plot_tif_to_shp(fpath_tif_input,fpath_shp_out,fpath_rkm_plot_along,fpath_output);
% fpath_fig=plot_tif_to_shp(fpath_tif_input,fpath_shp_out,fpath_rkm_plot_along,fpath_output,'buffer',500);

function fpath_fig=plot_tif_to_shp(fpath_tif_input,fpath_shp_in,fpath_rkm_plot_along,fpath_output,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'buffer',1000);
addOptional(parin,'tag_variable','MEAN');
addOptional(parin,'fig_print',1);
addOptional(parin,'overwrite',false);

parse(parin,varargin{:});

buffer=parin.Results.buffer;
tag_variable=parin.Results.tag_variable;
fig_print=parin.Results.fig_print;
overwrite=parin.Results.overwrite;

if ischar(fpath_tif_input)
    fpath_tif_input={fpath_tif_input};
end
if ischar(fpath_shp_in)
    fpath_shp_in={fpath_shp_in};
end
if numel(fpath_tif_input)~=numel(fpath_shp_in)
    error('There are %d rasters and %d shapefiles',numel(fpath_tif_input),numel(fpath_shp_in))
end

%the paths may have been written on another operating system
fpath_tif_input=cellfun(@(X)adapt_path_local_machine(X),fpath_tif_input(:),'UniformOutput',false);
fpath_shp_in=cellfun(@(X)adapt_path_local_machine(X),fpath_shp_in(:),'UniformOutput',false);
fpath_rkm_plot_along=adapt_path_local_machine(fpath_rkm_plot_along);
fpath_output=adapt_path_local_machine(fpath_output);

if exist(fpath_rkm_plot_along,'file')~=2
    error('River kilometre file does not exist: %s',fpath_rkm_plot_along)
end

fdir_fig=fullfile(fpath_output,'figures');
mkdir_check(fdir_fig,NaN,false,false);

%% READ LOCATIONS

rkm_file=gdm_read_rkm_file(fpath_rkm_plot_along);
rkm_x=rkm_file{1,1};
rkm_y=rkm_file{1,2};
rkm_tag=rkm_file{1,3};
rkm_km=rkm_file{1,4};
nrkm=numel(rkm_x);

%% READ RASTERS AND SHAPEFILES

ntif=numel(fpath_tif_input);
dat=struct('name',{},'tile',{},'pol',{},'val',{},'cen_x',{},'cen_y',{},'fdir',{});

for kt=1:ntif
    [~,name_loc]=fileparts(fpath_tif_input{kt});

    if exist(fpath_shp_in{kt},'file')~=2
        messageOut(NaN,sprintf('Shapefile does not exist and the raster is skipped: %s',fpath_shp_in{kt}));
        continue
    end

    messageOut(NaN,sprintf('Reading raster and shapefile %d of %d: %s',kt,ntif,name_loc));

    kd=numel(dat)+1;
    dat(kd).name=name_loc;
    dat(kd).tile=raster_tile_index(fpath_tif_input{kt});

    shp=D3D_io_input('read',fpath_shp_in{kt},'read_val',true);
    dat(kd).pol=shp.xy.XY(:);
    dat(kd).val=SHP_get_variable(shp,sprintf('polygon:%s',tag_variable));
    dat(kd).cen_x=cellfun(@(X)mean(X(:,1),'omitnan'),dat(kd).pol);
    dat(kd).cen_y=cellfun(@(X)mean(X(:,2),'omitnan'),dat(kd).pol);

    dat(kd).fdir=fullfile(fdir_fig,name_loc);
    mkdir_check(dat(kd).fdir,NaN,false,false);
end

ndat=numel(dat);
if ndat==0
    error('None of the shapefiles exists')
end

%% LOOP LOCATIONS

fpath_fig=cell(0,1);

for krkm=1:nrkm
    lim_x=rkm_x(krkm)+[-1,1]*buffer;
    lim_y=rkm_y(krkm)+[-1,1]*buffer;

    %the tag holds an escaped underscore for the interpreter
    tag_loc=strrep(rkm_tag{krkm},'\_','_');

    %the river kilometre is padded with zeros so that the figures are
    %listed in order
    suffix_loc=regexprep(tag_loc,'^-?[\d\.]+','');
    fname_loc=sprintf('rkm_%07.2f%s',rkm_km(krkm),suffix_loc);

    messageOut(NaN,sprintf('Location %d of %d: %s',krkm,nrkm,tag_loc));

    %% gather the data of every raster before plotting, because the colour
    %% limits are shared by all rasters at this location

    I=cell(ndat,1);
    bol_pol=cell(ndat,1);
    bol_dat=false(ndat,1);
    lim_c=[inf,-inf];

    for kd=1:ndat
        I{kd}=raster_window_grid(dat(kd).tile,lim_x,lim_y);
        bol_pol{kd}=dat(kd).cen_x>lim_x(1) & dat(kd).cen_x<lim_x(2) & ...
                    dat(kd).cen_y>lim_y(1) & dat(kd).cen_y<lim_y(2);

        val_loc=[I{kd}.z(~isnan(I{kd}.z));dat(kd).val(bol_pol{kd})];
        val_loc=val_loc(~isnan(val_loc));
        bol_dat(kd)=~isempty(val_loc);
        if bol_dat(kd)
            lim_c=[min(lim_c(1),min(val_loc)),max(lim_c(2),max(val_loc))];
        end
    end

    if ~all(isfinite(lim_c)) || lim_c(1)==lim_c(2)
        messageOut(NaN,'  no data at this location, skipping');
        continue
    end

    %% plot

    for kd=1:ndat
        if ~bol_dat(kd)
            messageOut(NaN,sprintf('  raster <%s> has no data here, skipping',dat(kd).name));
            continue
        end

        fpath_loc=fullfile(dat(kd).fdir,fname_loc);
        fpath_fig{end+1,1}=fpath_loc; %#ok<AGROW>

        if ~overwrite && figure_exists(fpath_loc,fig_print)
            continue
        end

        plot_one(I{kd},dat(kd),bol_pol{kd},lim_x,lim_y,lim_c, ...
            tag_variable,tag_loc,fpath_loc,fig_print);
    end
end

end %function

%% 
%% FUNCTIONS
%% 

%%
%% PLOT_ONE
%%

function plot_one(I,dat,bol_pol,lim_x,lim_y,lim_c,tag_variable,tag_loc,fpath_loc,fig_print)

cmap=flipud(brewermap(64,'RdYlBu'));

han_fig=figure('visible','off','units','centimeters','position',[0,0,24,11]);

%% raster

han_ax=subplot(1,2,1); %#ok<NASGU>
han_im=imagesc(I.x,I.y,I.z);
set(han_im,'AlphaData',~isnan(I.z));
format_axis(lim_x,lim_y,lim_c,cmap);
title('raster');

%% polygons

han_ax=subplot(1,2,2); %#ok<NASGU>
[face,vertex,cdata]=polygons_to_patch(dat.pol(bol_pol),dat.val(bol_pol));
if ~isempty(face)
    patch('Faces',face,'Vertices',vertex,'FaceVertexCData',cdata, ...
        'FaceColor','flat','EdgeColor','none');
end
format_axis(lim_x,lim_y,lim_c,cmap);
title(sprintf('polygon average of %s',tag_variable));

%% colorbar

han_cb=colorbar('eastoutside');
set(han_cb,'Position',[0.93,0.15,0.015,0.7]);
ylabel(han_cb,labels4all('bl',1,'en'));

sgtitle(sprintf('%s   rkm %s',strrep(dat.name,'_','\_'),strrep(tag_loc,'_','\_')));

fig_print_close(struct(),han_fig,fig_print,fpath_loc);

end %function

%%
%% FORMAT_AXIS
%%

function format_axis(lim_x,lim_y,lim_c,cmap)

set(gca,'YDir','normal');
axis equal
xlim(lim_x)
ylim(lim_y)
clim(lim_c)
colormap(gca,cmap)
box on
grid on
xlabel(labels4all('x',1,'en'))
ylabel(labels4all('y',1,'en'))

end %function

%%
%% POLYGONS_TO_PATCH
%%

%One face per ring, so that a polygon made of several parts is not drawn as
%a single merged face. The faces are padded with NaN because the rings do
%not have the same number of vertices.

function [face,vertex,cdata]=polygons_to_patch(pol,val)

npol=numel(pol);
ring=cell(0,1);
cdata=NaN(0,1);

for kp=1:npol
    xy=pol{kp}(:,1:2);

    %the parts of a multipart polygon are separated by a row of NaN
    idx_nan=[0;find(any(isnan(xy),2));size(xy,1)+1];
    for kr=1:numel(idx_nan)-1
        xy_loc=xy(idx_nan(kr)+1:idx_nan(kr+1)-1,:);
        if size(xy_loc,1)<3
            continue
        end
        ring{end+1,1}=xy_loc; %#ok<AGROW>
        cdata(end+1,1)=val(kp); %#ok<AGROW>
    end
end

if isempty(ring)
    face=[];
    vertex=[];
    cdata=[];
    return
end

nv=cellfun(@(X)size(X,1),ring);
vertex=cell2mat(ring);
face=NaN(numel(ring),max(nv));
idx=0;
for kr=1:numel(ring)
    face(kr,1:nv(kr))=idx+(1:nv(kr));
    idx=idx+nv(kr);
end

end %function

%%
%% FIGURE_EXISTS
%%

function bol=figure_exists(fpath_loc,fig_print)

ext={'.png','.fig','.eps','.jpg'};

bol=false;
for kf=1:numel(fig_print)
    if fig_print(kf)>=1 && fig_print(kf)<=4
        bol=bol || exist(sprintf('%s%s',fpath_loc,ext{fig_print(kf)}),'file')==2;
    end
end

end %function
