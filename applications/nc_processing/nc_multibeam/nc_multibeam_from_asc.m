function OPT = nc_multibeam_from_asc(OPT)
if OPT.nc_make
    disp('generating nc files...')
    if OPT.nc_delete_existing
        % delete existing nc_files
        delete(fullfile(OPT.netcdf_path, '*.nc'))
    end
    
    startTime        = tic;
    EPSG             = load('EPSG');
    mkpath(OPT.netcdf_path)
    

    fns = dir( fullfile(OPT.netcdf_path,'*.nc'));
    for ii = 1:length(fns)
        delete(fullfile(OPT.netcdf_path,fns(ii).name));
    end
    
    fns = dir(fullfile(OPT.raw_path,'*.asc'));
    
    WB.handle    = waitbar(0, 'initializing file... ');

    axes(get(WB.handle,'Children'))

    WB.read    = patch([0 0 0 0],[0 0 1 1],[0.5 0.5 0.5 0.5],[1 0 0]);
    WB.written = patch([0 0 0 0],[0 0 1 1],[1 1 1 1],[0 0.5 0]);
     
    set(WB.read,'XDATA',[0 10 10 0])
    set(WB.written,'XDATA',[0 0 0 0])
    
    WB.done       = 0;
    WB.bytesToDo  = 0;
    for ii = 1:length(fns)
        WB.bytesToDo = WB.bytesToDo + fns(ii).bytes;
    end
    WB.bytesDoneClosedFiles = 0;
    
    
    for ii = 1:length(fns)
        %% read data
        fprintf('Reading data ... \n');
        
        time     =                     datenum(fns(ii).name(1:8),'yyyy mmm') - datenum(1970,1,1);
        fid      = fopen(fullfile(OPT.raw_path,fns(ii).name));
        
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
            WB.bytesDoneOfCurrentFile = ftell(fid);
            WB.done = (WB.bytesDoneClosedFiles+WB.bytesDoneOfCurrentFile)/WB.bytesToDo;
            WB.msg  = {sprintf('processing %s:',mktex(fns(ii).name)),'Reading data'};
           set(WB.read,'XDATA',[0 100*WB.done 100*WB.done 0])
           drawnow
            
            kk = kk+1;
            D{kk}     = textscan(fid,repmat('%f32',1,ncols),floor(OPT.block_size/ncols),'CollectOutput',true); 
            if all(D{kk}{1}(:)==nodata_value)
                D{kk}{1} = nan;
            else
                D{kk}{1}(D{kk}{1}==nodata_value) = nan;
            end
%             fprintf('% 6.2f%% done, ETA is %s\n',...
%                 ((bytesRead+ ftell(fid))/totalBytes)*100,datestr((toc(startTime)*...
%                 (1/((bytesRead+ ftell(fid))/totalBytes)-1)/3600/24)+now,'HH:MM:SS'))
        end
        WB.bytesDoneClosedFiles = WB.bytesDoneClosedFiles+ ftell(fid);
        fclose(fid);
        WB.done = WB.bytesDoneClosedFiles/WB.bytesToDo;
        set(WB.read,'XDATA',[0 100*WB.done 100*WB.done 0])
        drawnow
        
%------------------------------------------------------------------------------------------------------------------------------------------        
        
        %% write data to nc files
        fprintf('Writing data ... \n');
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
                [X,Y]    = meshgrid(x_vector,y_vector);
                Y = flipud(Y);
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
                
                WB.writtenDone = (WB.bytesDoneClosedFiles-fns(ii).bytes + ...
                    fns(ii).bytes * ...
                    ((find(x0==minx : xsize : maxx,1,'first')-1)/...
                    length(minx : xsize : maxx)+ find(y0==miny : ysize : maxy,1,'first')/...
                    length(miny : ysize : maxy)/...
                    length(minx : xsize : maxx)))/...
                    WB.bytesToDo;
   
                set(WB.written,'XDATA',[0 100*WB.writtenDone 100*WB.writtenDone 0])
                drawnow
            end
        end
    end
    close(WB.handle)
    disp('generation of nc files completed')
else
    disp('generation of nc files skipped')
end