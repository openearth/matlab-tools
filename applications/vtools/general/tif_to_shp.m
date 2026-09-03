%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Compute zonal statistics of GeoTIFF files inside a set of polygons and
%store them in a shapefile per input raster. The attributes of the input
%shapefile are carried over unchanged; this function only appends the
%statistics.
%
%INPUT
%   - fpath_tif_input = path (char) or paths (cell string) to tif-files or
%       vrt-files pointing at a set of tif-files.
%   - fpath_shp_in = path to the shapefile with the polygons to average in.
%   - fpath_output = folder where the output shapefiles are written.
%
%OUTPUT
%   - fpath_shp_out = cell string with the paths to the generated shapefiles.
%
%OPTIONAL (pair input)
%   - overwrite = true: regenerate a shapefile that already exists;
%       false (default): keep it and skip the raster.
%
%E.G.
%
% fpath_shp_out=tif_to_shp(fpath_tif_input,fpath_shp_in,fpath_output);
% fpath_shp_out=tif_to_shp(fpath_tif_input,fpath_shp_in,fpath_output,'overwrite',true);

function fpath_shp_out=tif_to_shp(fpath_tif_input,fpath_shp_in,fpath_output,varargin)

%% CONSTANTS

%statistics appended to the attributes of the input shapefile
tag_stat={'COUNT','MEAN','STD','MIN','MAX','RANGE'};

%number of polygons between checkpoints
npol_checkpoint=250;

%RD New (EPSG:28992) with NAP as vertical datum
str_prj='PROJCS["RD_New",GEOGCS["GCS_Amersfoort",DATUM["D_Amersfoort",SPHEROID["Bessel_1841",6377397.155,299.1528128]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Double_Stereographic"],PARAMETER["False_Easting",155000.0],PARAMETER["False_Northing",463000.0],PARAMETER["Central_Meridian",5.38763888888889],PARAMETER["Scale_Factor",0.9999079],PARAMETER["Latitude_Of_Origin",52.1561605555556],UNIT["Meter",1.0]],VERTCS["NAP",VDATUM["Normaal_Amsterdams_Peil"],PARAMETER["Vertical_Shift",0.0],PARAMETER["Direction",1.0],UNIT["Meter",1.0]]';

%% PARSE

parin=inputParser;

addOptional(parin,'overwrite',false);

parse(parin,varargin{:});

overwrite=parin.Results.overwrite;

if ischar(fpath_tif_input)
    fpath_tif_input={fpath_tif_input};
end
if ~iscellstr(fpath_tif_input)
    error('<fpath_tif_input> must be a char or a cell string')
end
fpath_tif_input=fpath_tif_input(:);
ntif=numel(fpath_tif_input);

%the paths may have been written on another operating system
fpath_tif_input=cellfun(@(X)adapt_path_local_machine(X),fpath_tif_input,'UniformOutput',false);
fpath_shp_in=adapt_path_local_machine(fpath_shp_in);
fpath_output=adapt_path_local_machine(fpath_output);

if exist(fpath_shp_in,'file')~=2
    error('Shapefile does not exist: %s',fpath_shp_in)
end

mkdir_check(fpath_output,NaN,false,false);

%% READ POLYGONS

messageOut(NaN,sprintf('Reading polygons: %s',fpath_shp_in));

shp=D3D_io_input('read',fpath_shp_in,'read_val',true);
XY=shp.xy.XY(:);
npol=numel(XY);

lim_x=NaN(npol,2);
lim_y=NaN(npol,2);
for kp=1:npol
    lim_x(kp,:)=[min(XY{kp}(:,1)),max(XY{kp}(:,1))];
    lim_y(kp,:)=[min(XY{kp}(:,2)),max(XY{kp}(:,2))];
end

%% LOOP RASTERS

fpath_shp_out=cell(ntif,1);

for kt=1:ntif
    fpath_tif_loc=fpath_tif_input{kt};
    [~,fname_loc]=fileparts(fpath_tif_loc);
    fpath_shp_out{kt}=fullfile(fpath_output,sprintf('%s.shp',fname_loc));

    messageOut(NaN,sprintf('Raster %d of %d: %s',kt,ntif,fpath_tif_loc));

    if exist(fpath_shp_out{kt},'file')==2 && ~overwrite
        messageOut(NaN,sprintf('Output already exists, skipping: %s',fpath_shp_out{kt}));
        continue
    end

    fpath_chk=fullfile(fpath_output,sprintf('%s_checkpoint.mat',fname_loc));

    %a failing raster must not discard the rasters that come after it
    try
        tile=raster_tile_index(fpath_tif_loc);

        fingerprint=checkpoint_fingerprint(fpath_shp_in,fpath_tif_loc,npol,tag_stat);
        [stat,kp_ini]=checkpoint_read(fpath_chk,fingerprint,npol,numel(tag_stat));

        for kp=kp_ini:npol
            if mod(kp,100)==0 || kp==npol
                messageOut(NaN,sprintf('  polygon %d of %d',kp,npol));
            end

            z=read_window(tile,lim_x(kp,:),lim_y(kp,:),XY{kp});
            stat(kp,:)=zonal_statistics(z);

            if mod(kp,npol_checkpoint)==0
                checkpoint_write(fpath_chk,fingerprint,stat,kp);
            end
        end

        %% WRITE

        shp_out=shp;
        for ks=1:numel(tag_stat)
            shp_out.val{end+1}.Name=tag_stat{ks};
            shp_out.val{end}.Val=stat(:,ks);
        end
        shp_out.val_names=cellfun(@(X)X.Name,shp_out.val,'UniformOutput',false);

        D3D_io_input('write',fpath_shp_out{kt},shp_out);
        write_prj(fpath_shp_out{kt},str_prj);

        if exist(fpath_chk,'file')==2
            delete(fpath_chk);
        end

        messageOut(NaN,sprintf('File written: %s',fpath_shp_out{kt}));
    catch err
        messageOut(NaN,sprintf('Raster %d of %d failed and is skipped: %s',kt,ntif,err.message));
        messageOut(NaN,sprintf('  the progress made is kept in %s',fpath_chk));
    end
end

end %function

%% 
%% FUNCTIONS
%% 

%%
%% CHECKPOINT_FINGERPRINT
%%

%Identifies the run that a checkpoint belongs to, so that a checkpoint left
%behind by another shapefile, raster or polygon set is not reused.

function fingerprint=checkpoint_fingerprint(fpath_shp_in,fpath_tif,npol,tag_stat)

dir_shp=dir(fpath_shp_in);

fingerprint.fpath_shp=fpath_shp_in;
fingerprint.bytes_shp=dir_shp.bytes;
fingerprint.datenum_shp=dir_shp.datenum;
fingerprint.fpath_tif=fpath_tif;
fingerprint.npol=npol;
fingerprint.tag_stat=tag_stat;

end %function

%%
%% CHECKPOINT_READ
%%

function [stat,kp_ini]=checkpoint_read(fpath_chk,fingerprint,npol,nstat)

stat=NaN(npol,nstat);
kp_ini=1;

if exist(fpath_chk,'file')~=2
    return
end

try
    chk=load(fpath_chk);
catch
    messageOut(NaN,sprintf('Checkpoint cannot be read and is ignored: %s',fpath_chk));
    return
end

if ~isfield(chk,'fingerprint') || ~isequal(chk.fingerprint,fingerprint)
    messageOut(NaN,sprintf('Checkpoint belongs to another run and is ignored: %s',fpath_chk));
    return
end

stat=chk.stat;
kp_ini=chk.kp+1;

messageOut(NaN,sprintf('Resuming at polygon %d of %d',kp_ini,npol));

end %function

%%
%% CHECKPOINT_WRITE
%%

function checkpoint_write(fpath_chk,fingerprint,stat,kp)

%written to a temporary file first so that an interrupted save cannot
%destroy a valid checkpoint
fpath_tmp=sprintf('%s.tmp',fpath_chk);
save(fpath_tmp,'fingerprint','stat','kp','-v7');
movefile(fpath_tmp,fpath_chk,'f');

end %function

%%
%% READ_WINDOW
%%

%Values of the cells whose centre lies inside the polygon.

function z=read_window(tile,lim_x,lim_y,xy_pol)

I=raster_window_grid(tile,lim_x,lim_y);

if isempty(I.x) || isempty(I.y)
    z=[];
    return
end

[xg,yg]=meshgrid(I.x,I.y);
bol_in=inpolygon(xg,yg,xy_pol(:,1),xy_pol(:,2));

z=I.z(bol_in);
z=z(:);

end %function

%%
%% ZONAL_STATISTICS
%%

function stat=zonal_statistics(z)

z=z(~isnan(z));

if isempty(z)
    stat=[0,NaN,NaN,NaN,NaN,NaN];
    return
end

%the standard deviation is normalised by the number of cells, which is the
%convention used by the zonal statistics of ArcGIS
stat=[numel(z),mean(z),std(z,1),min(z),max(z),max(z)-min(z)];

end %function

%%
%% WRITE_PRJ
%%

function write_prj(fpath_shp,str_prj)

[fdir,fnam]=fileparts(fpath_shp);
fpath_prj=fullfile(fdir,sprintf('%s.prj',fnam));

fid=fopen(fpath_prj,'w');
if fid<0
    warning('Cannot write the projection file: %s',fpath_prj)
    return
end
fprintf(fid,'%s',str_prj);
fclose(fid);

end %function
