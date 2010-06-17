function OPT = nc_multibeam_from_asc(OPT)
% OPT.cache_path = 'c:\nc';
if OPT.nc_make
    disp('generating nc files...')
    if OPT.nc_delete_existing
        % delete existing nc_files
        delete(fullfile(OPT.netcdf_path, '*.nc'))
    end

    EPSG             = load('EPSG');
    mkpath(OPT.netcdf_path)
    
    fns = dir( fullfile(OPT.netcdf_path,'*.nc'));
    for ii = 1:length(fns)
        delete(fullfile(OPT.netcdf_path,fns(ii).name));
    end
    
    fns = dir(fullfile(OPT.raw_path,'*.asc'));
    
    if isempty(fns)
        % presume file is zipped
        fns = dir(fullfile(OPT.raw_path,'*.zip'));
        if ~isempty(fns)
            OPT.zip = true;
            mkpath(OPT.cache_path);
        else
            error('no raw files')
        end
    else
        OPT.zip = false;
    end
    
    
    WB.done       = 0;
    WB.bytesToDo  = 0;
     %% initialize waitbar
     multiWaitbar('close all')
     multiWaitbar( 'Raw data to NetCDF',0, 'Color', [0.2 0.6 0.2] )
     if OPT.zip
        multiWaitbar('unzipping'       ,0,'Color',    [0.2 0.7 0.9])
     end
     multiWaitbar('reading'            ,0,'Color', [0.1 0.5 0.8],'label','Reading')
     multiWaitbar('writing'            ,0,'Color', [0.1 0.3 0.6],'label','Writing')
    for ii = 1:length(fns)
        WB.bytesToDo = WB.bytesToDo + fns(ii).bytes;
    end
    WB.bytesToDo =  WB.bytesToDo*2;
    WB.bytesDoneClosedFiles = 0;
    WB.zipratio = 1;
    for jj = 1:length(fns)
        if OPT.zip
            multiWaitbar('unzipping', 'increment',0.5/length(fns),'label',sprintf('Unzipping %s',fns(jj).name));
            %delete files in cache
            delete(fullfile(OPT.cache_path, '*'))
            unzip(fullfile(OPT.raw_path,fns(jj).name),OPT.cache_path)
            fns_unzipped = dir(fullfile(OPT.cache_path,'*.asc'));
            
            unpacked_size = 0;
            for kk = 1:length(fns_unzipped)
                unpacked_size = unpacked_size + fns_unzipped(kk).bytes;
            end
            WB.bytesToDo = WB.bytesToDo/WB.zipratio;
            WB.zipratio = (WB.zipratio*(jj-1)+unpacked_size/fns(jj).bytes)/jj;
            WB.bytesToDo = WB.bytesToDo*WB.zipratio;
            multiWaitbar('unzipping', jj/length(fns),'label',sprintf('Processing %s contents',fns(jj).name));
        else
            fns_unzipped = fns(jj);
        end
        
        for ii = 1:length(fns_unzipped)
            %% set waitbars to 0 and update label
            multiWaitbar('writing',0,'label','Writing: *.nc')
            multiWaitbar('reading',0,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name)))
            %% read data
            
            % process time
            timestr = fns_unzipped(ii).name(1:8);
            timestr = strrep(timestr,'mei','may');
            time    = datenum(timestr,'yyyy mmm') - datenum(1970,1,1);
            
            if OPT.zip
                fid      = fopen(fullfile(OPT.cache_path,fns_unzipped(ii).name));
            else
                fid      = fopen(fullfile(OPT.raw_path,fns_unzipped(ii).name));
            end
            s = fgetl(fid); ncols        = strread(s,       'ncols %d');
            s = fgetl(fid); nrows        = strread(s,       'nrows %d');
            s = fgetl(fid); xllcorner    = strread(s,   'xllcorner %f');
            s = fgetl(fid); yllcorner    = strread(s,   'yllcorner %f');
            s = fgetl(fid); cellsize     = strread(s,    'cellsize %f');
            s = fgetl(fid);
            
            try             nodata_value = strread(s,'nodata_value %f');
            catch;          nodata_value = strread(s,'NODATA_value %f'); %#ok<CTCH>
            end
            kk = 0;
            
            while ~feof(fid)

                multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ftell(fid))/WB.bytesToDo)
                multiWaitbar('reading',ftell(fid)/fns_unzipped(ii).bytes,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name))) ;
                kk = kk+1;
                D{kk}     = textscan(fid,repmat('%f32',1,ncols),floor(OPT.block_size/ncols),'CollectOutput',true);
                if all(D{kk}{1}(:)==nodata_value)
                    D{kk}{1} = nan;
                else
                    D{kk}{1}(D{kk}{1}==nodata_value) = nan;
                end
            end
            multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ftell(fid))/WB.bytesToDo)
            multiWaitbar('reading',ftell(fid)/fns_unzipped(ii).bytes,'label',sprintf('Reading: %s', (fns_unzipped(ii).name))) ;
            fclose(fid);
            
            
            %------------------------------------------------------------------------------------------------------------------------------------------
            
            %% write data to nc files
            multiWaitbar('writing',0,'label',sprintf('Writing: %s...', (fns_unzipped(ii).name)))
            % set the extent of the fixed maps (decide according to desired nc filesize)
            xsize       = OPT.mapsizex; % size of fixed map in x-direction
            xstepsize   = OPT.gridsize; % x grid resolution
            ysize       = OPT.mapsizey; % size of fixed map in y-direction
            ystepsize   = OPT.gridsize; % y grid resolution
            
            minx    = xllcorner;
            miny    = yllcorner;
            maxx    = xllcorner + cellsize.*(ncols-1);
            maxy    = yllcorner + cellsize.*(nrows-1);
            minx    = floor(minx/xsize)*xsize - OPT.xoffset;
            miny    = floor(miny/ysize)*ysize - OPT.yoffset;
            
            x      =         xllcorner:xllcorner + cellsize*(ncols-1);
            y      = flipud((yllcorner:yllcorner + cellsize*(nrows-1))');
            y(:,2) = ceil((1:length(y))'./floor(OPT.block_size/ncols));
            y(:,3) = mod((0:length(y)-1)',floor(OPT.block_size/ncols))+1;
            
            % loop through data
            for x0      = minx : xsize : maxx
                for y0  = miny : ysize : maxy
                    ix = find(x     >=x0      ,1,'first'):find(x     <x0+xsize,1,'last');
                    iy = find(y(:,1)<=y0+ysize,1,'first'):find(y(:,1)>y0      ,1,'last');
                    
                    z = nan(length(iy),length(ix));
                    for iD = unique(y(iy,2))'
                        if~(numel(D{iD}{1})==1&&isnan(D{iD}{1}(1)))
                            z(y(iy,2)==iD,:) = D{iD}{1}(y(iy(y(iy,2)==iD),3),ix)*OPT.zfactor;
                        end
                    end
                    
                    % generate X,Y,Z
                    x_vector = x0:xstepsize:x0+xsize;
                    y_vector = y0:ystepsize:y0+ysize;
                    [X,Y]    = meshgrid(x_vector,fliplr(y_vector));
                    Z = nan(size(X));
                    Z(...
                        find(y_vector  >=y(iy(end)),1,'first'):find(y_vector  <=y(iy(1)),1,'last'),...
                        find(x_vector  >=x(ix(1)),1,'first'):find(x_vector  <=x(ix(end)),1,'last')) = z;
                    
                    if any(~isnan(Z(:)))
                        ncfile = fullfile(OPT.netcdf_path,sprintf('%8.2f_%8.2f_%s_data.nc',x0,y0,OPT.datatype));
                        if ~exist(ncfile, 'file')
                            nc_multibeam_createNCfile(OPT,ncfile,X,Y,EPSG)
                        end
                        nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z')
                    end
                    
                    WB.writtenDone =  (find(x0==minx : xsize : maxx,1,'first')-1)/...
                        length(minx : xsize : maxx)+ find(y0==miny : ysize : maxy,1,'first')/...
                        length(miny : ysize : maxy)/...
                        length(minx : xsize : maxx);
                    multiWaitbar('writing',WB.writtenDone,'label',sprintf('%8.2f_%8.2f_%s_data.nc',x0,y0,OPT.datatype))
                    multiWaitbar( 'Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+(1+WB.writtenDone)*fns_unzipped(ii).bytes)/WB.bytesToDo)
                end
            end
            WB.bytesDoneClosedFiles = WB.bytesDoneClosedFiles+fns_unzipped(ii).bytes;
        end
    end
    if OPT.zip
       try %#ok<TRYNC>
           rmdir(OPT.cache_path,'s')
       end
    end
    disp('generation of nc files completed')
else
    disp('generation of nc files skipped')
end