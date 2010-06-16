function OPT = nc_from_xyz_multibeam(OPT)
if OPT.nc_make
    disp('generating nc files...')
    if OPT.nc_delete_existing
        % delete existing nc_files
        delete(fullfile(OPT.netcdf_path, '*.nc'))
    end
    
    % set the extent of the fixed maps (decide according to desired nc filesize)
    xsize       = OPT.mapsizex; % size of fixed map in x-direction
    xstepsize   = OPT.gridsize; % x grid resolution
    ysize       = OPT.mapsizey; % size of fixed map in y-direction
    ystepsize   = OPT.gridsize; % y grid resolution
    
    fns         = dir(fullfile(OPT.raw_path,OPT.rawdata_ext));
    
    %% first: determine the outline of the dataset getting all the timestamps
    time = nan(1,length(fns));
    
    OPT.WBbytesToDo = 0;
    for kk = 1:size(fns,1)
        time(kk) = datenum(str2double(fns(kk).name(1:4)), str2double(fns(kk).name(5:6)), str2double(fns(kk).name(7:8))) ...
            - datenum(1970,01,01);
        OPT.WBbytesToDo = OPT.WBbytesToDo+fns(kk).bytes;
    end
    
    OPT.wb                   = waitbar(0, 'initializing file...');
    OPT.WBbytesDoneClosedFiles = 0;
    for kk = 1:size(fns,1)
        fid             = fopen(fullfile(OPT.raw_path, fns(kk).name));
        headerlines     = OPT.headerlines;
        while ~feof(fid)
            %% read data
            OPT.WBbytesDoneOfCurrentFile = ftell(fid);
            OPT.WBdone = (OPT.WBbytesDoneClosedFiles+OPT.WBbytesDoneOfCurrentFile)/OPT.WBbytesToDo;
            OPT.WBmsg       = {sprintf('processing %s:',mktex(fns(kk).name(1:8))),'Reading data'};
            waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
            % read the data with 'OPT.block_size' lines at a time
            data            = textscan(fid,OPT.format,OPT.block_size,'delimiter',OPT.delimiter,...
                            'headerlines',headerlines,'MultipleDelimsAsOne',OPT.MultipleDelimsAsOne);
            headerlines     = 0; % only skip headerlines on first read
            OPT.WBbytesRead = ftell(fid) - OPT.WBbytesDoneOfCurrentFile;
            %% find min and max
            
            minx    = min(data{OPT.xid});
            miny    = min(data{OPT.yid});
            maxx    = max(data{OPT.xid});
            maxy    = max(data{OPT.yid});
            minx    = floor(minx/xsize)*xsize - OPT.xoffset;
            miny    = floor(miny/ysize)*ysize - OPT.yoffset;
            
            
            %% loop through data
            OPT.WBnumel = length(data{OPT.xid});
            for x0      = minx : xsize : maxx
                for y0  = miny : ysize : maxy
                    OPT.WBmsg{2}  = 'Gridding Z data';
                    waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
                    try
                    ids =  inpolygon(data{OPT.xid},data{OPT.yid},[x0 x0+xsize x0+xsize x0 x0],[y0 y0 y0+ysize y0+ysize y0]);
                    catch
                        1
                    end
                    x   =  data{OPT.xid}(ids);
                    y   =  data{OPT.yid}(ids);
                    z   =  data{OPT.zid}(ids);
                    
                    %  waitbar stuff
                    OPT.WBnumelDone              = length(x);
                    OPT.WBbytesDoneOfCurrentFile = OPT.WBbytesDoneOfCurrentFile+OPT.WBnumelDone/OPT.WBnumel*OPT.WBbytesRead;
                    OPT.WBdone                   = (OPT.WBbytesDoneClosedFiles+OPT.WBbytesDoneOfCurrentFile)/OPT.WBbytesToDo;
                    
                    % generate X,Y,Z
                    x_vector = x0:xstepsize:x0+xsize;
                    y_vector = y0:ystepsize:y0+ysize;
                    [X,Y]    = meshgrid(x_vector,y_vector);
                    
                    % place xyz data on XY matrices
                    Z = OPT.gridFcn(x,y,z,X,Y);
                    
                    if sum(~isnan(Z(:)))>=3
                        Z = flipud(Z);
                        Y = flipud(Y);
                        % if a non trivial Z matrix is returned write the data
                        % to a nc file
                        ncfile = fullfile(OPT.netcdf_path,sprintf('%8.2f_%8.2f_%s_data.nc',x0,y0,OPT.datatype));
                        if ~exist(ncfile, 'file')
                            nc_multibeam_createNCfile(OPT,ncfile,X,Y,EPSG)
                        end
                        nc_multibeam_putDataInNCfile(OPT,ncfile,time(kk),Z')
                    end
                end
            end
        end
        OPT.WBbytesDoneClosedFiles = OPT.WBbytesDoneClosedFiles + fns(kk).bytes;
    end
    close(OPT.wb)
    disp('generation of nc files completed')
else
    disp('generation of nc files skipped')
end