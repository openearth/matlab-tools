%Class to declare mlost common ERA5 functions
%


classdef ERA5 < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
    properties (Dependent = true, SetAccess = private)
        
    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end
    
    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end
    
    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'private')
        
    end
    
    %Stactic methods
    methods(Static)
        function tblERA5 = extractTimeSeriesWind(strdirin, coordx, coordy, refTimeStart, refTimeEnd)
            cwd = cd; 
            if isempty(strdirin)
                strdirin = 'K:/DATA/golfgegevens_wereldwijd/ERA5/meteo_extra/'; 
            end
            cd(strdirin)
            time0 = datenum('01-Jan-1900');  % reference time

            if nargin<4
                refTimeStart = 0; 
                refTimeEnd   = Inf; 
            end
            
            % Start at first of month
                tmp = datevec(refTimeStart); 
                tmp(:,3) = 1; tmp(4:6) = 0; 
            refTimeStart = datenum(tmp);     
            sctf = dir([strdirin '/ERA5*']); 

            for ifile = 1:numel(sctf)
                vectime = datevec(sctf(ifile).name(end-5:end), 'yyyymm'); 
                sctf(ifile).refTime = datenum(vectime); 
                ind = refTimeStart<=sctf(ifile).refTime & sctf(ifile).refTime<refTimeEnd;
                sctf(ifile).pro = ind; 
            end

            index = find(arrayfun(@(x) x.pro, sctf)); 

            first = true; 
            for ifile = index'
                lat = ncread(sctf(ifile).name, 'latitude');
                lon = ncread(sctf(ifile).name, 'longitude');
                time = double(ncread(sctf(ifile).name, 'time'))/24+time0; % hours since reference time 1-Jan-1990
                Time = datetime(time, 'ConvertFrom', 'datenum'); 
                [~, indlon] = min(abs(lon-coordx)); 
                [~, indlat] = min(abs(lat-coordy)); 
                u10 = squeeze(ncread(sctf(ifile).name, 'u10', [indlon, indlat,1], [1 1 Inf])); 
                v10 = squeeze(ncread(sctf(ifile).name, 'v10', [indlon, indlat,1], [1 1 Inf])); 
                tbl = table(Time, u10, v10); 
                if first 
                    tblERA5 = tbl; 
                    first = false; 
                else
                    tblERA5 = [tblERA5; tbl]; 
                end
            end

            wind = tblERA5.u10+i*tblERA5.v10; 
            tblERA5.windSpeed = abs(wind);
            tblERA5.windDir   = mod(270-angle(wind)*180/pi,360); 
            cd(cwd);         
        end
        
        function tblERA5 = extractTimeSeriesWaves(strdirin, coordx, coordy, refTimeStart, refTimeEnd)

            cwd = cd; 
            if isempty(strdirin)
                strdirin = 'K:/DATA/golfgegevens_wereldwijd/ERA5/waves/'; 
            end
            cd(strdirin)
            time0 = datenum('01-Jan-1900');  % reference time

            if nargin<4
                refTimeStart = 0; 
                refTimeEnd   = Inf; 
            end

            % Start at first of month
                tmp = datevec(refTimeStart); 
                tmp(:,3) = 1; tmp(4:6) = 0; 
            refTimeStart = datenum(tmp);     
            sctf = dir([strdirin '/ERA5*']); 

            for ifile = 1:numel(sctf)
                vectime = datevec(sctf(ifile).name(end-9:end-3), 'yyyy_mm'); 
                sctf(ifile).refTime = datenum(vectime); 
                ind = datenum(refTimeStart)<=sctf(ifile).refTime & sctf(ifile).refTime<datenum(refTimeEnd);
                sctf(ifile).pro = ind; 
            end

            index = find(arrayfun(@(x) x.pro, sctf)); 

            first = true; 
            inf = ncinfo(sctf(index(1)).name); 
            variables = {inf.Variables.Name}; 
            [~, indvar] = setdiff(variables, {'longitude', 'latitude', 'time'}); 
            indvar = sort(indvar); 
            variables = variables(indvar); 
            nvar = numel(variables);
            for ifile = index'
                lat = ncread(sctf(ifile).name, 'latitude');
                lon = ncread(sctf(ifile).name, 'longitude');
                time = double(ncread(sctf(ifile).name, 'time'))/24+time0; % hours since reference time 1-Jan-1990
                Time = datetime(time, 'ConvertFrom', 'datenum'); 
                [~, indlon] = min(abs(lon-coordx)); 
                [~, indlat] = min(abs(lat-coordy)); 
                for ivar = 1:nvar
                    data(:,ivar) = squeeze(ncread(sctf(ifile).name, variables{ivar}, [indlon, indlat,1], [1 1 Inf]));
                end
                tbl = [table(Time) array2table(data)];
                clear data
                if first 
                    tblERA5 = tbl; 
                    first = false; 
                else
                    tblERA5 = [tblERA5; tbl]; 
                end
            end
            % Variable Names
            tblERA5.Properties.VariableNames(2:end) = variables; 
            % Variable Long Names
            teller = 1; 
            for ivar = indvar'
                teller = teller+1; 
                indname = find(arrayfun(@(x) strcmp(x.Name, 'long_name'), inf.Variables(ivar).Attributes)); 
                tblERA5.Properties.VariableDescriptions{teller} = inf.Variables(ivar).Attributes(indname).Value; 
            end
        end
        
        function tblERA5 = extractTimeSeriesMaxInRegion(strdirin, north, west, south, east, mxVar, refTimeStart, refTimeEnd)
            % strdirin : directory where to find the ERA5-files
            % north, west, south, east : coordinates of the boundaing box of the area
            % Variable to maximize (default : swh [Significant Wave Height]) 
            % refTimeStart : starting time (default 0)
            % refTimeEend  : end time (default Inf)
            
            cwd = cd; 
            if isempty(strdirin)
                strdirin = 'K:/DATA/golfgegevens_wereldwijd/ERA5/waves/'; 
            end
            cd(strdirin)
            time0 = datenum('01-Jan-1900');  % reference time

            if nargin<6 || isempty(mxVar)
                mxVar = 'swh'; 
            end
            if nargin<7
                refTimeStart = 0; 
                refTimeEnd   = Inf; 
            end

            if west > east
                error('not implemented yet')
            end
            
            % Start at first of month
                tmp = datevec(refTimeStart); 
                tmp(:,3) = 1; tmp(4:6) = 0; 
            refTimeStart = datenum(tmp);     
            sctf = dir([strdirin '/ERA5*']); 

            for ifile = 1:numel(sctf)
                vectime = datevec(sctf(ifile).name(end-5:end), 'yyyymm'); 
                sctf(ifile).refTime = datenum(vectime); 
                ind = refTimeStart<=sctf(ifile).refTime & sctf(ifile).refTime<refTimeEnd;
                sctf(ifile).pro = ind; 
            end

            index = find(arrayfun(@(x) x.pro, sctf)); 

            first = true; 
            inf = ncinfo(sctf(index(1)).name); 
            variables = {inf.Variables.Name}; 
            [~, indvar] = setdiff(variables, {'longitude', 'latitude', 'time'}); 
            indvar = sort(indvar); 
            variables = variables(indvar); 
            nvar = numel(variables);
            for ifile = index'
                lat = ncread(sctf(ifile).name, 'latitude');
                lon = ncread(sctf(ifile).name, 'longitude');
                time = double(ncread(sctf(ifile).name, 'time'))/24+time0; % hours since reference time 1-Jan-1990
                Time = datetime(time, 'ConvertFrom', 'datenum'); 
                nTime = numel(Time); 
                indlon = find( west<=lon & lon<=east );
                indlat = find(south<=lat & lat<=north);
                % initiate
                data = NaN(nTime,nvar);
                nlon = numel(indlon); 
                nlat = numel(indlat);
                for itime = 1:nTime
                    var = squeeze(ncread(sctf(ifile).name, mxVar, [indlon(1), indlat(1),itime], [nlon nlat 1]));
                    var1 = reshape(var, [],1);
                    [mx, mxind] = max(var1); 
                    [I, J] = ind2sub([nlon, nlat], mxind);
                    ILON = indlon(I); 
                    JLAT = indlat(J); 
                    for ivar = 1:nvar
                        data(itime,ivar) = squeeze(ncread(sctf(ifile).name, variables{ivar}, [ILON, JLAT,itime], [1 1 1]));
                    end
                end
                tbl = [table(Time) array2table(data)];
                clear data
                if first 
                    tblERA5 = tbl; 
                    first = false; 
                else
                    tblERA5 = [tblERA5; tbl]; 
                end
            end
            % Variable Names
            tblERA5.Properties.VariableNames(2:end) = variables; 
            % Variable Long Names
            teller = 1; 
            for ivar = indvar'
                teller = teller+1; 
                indname = find(arrayfun(@(x) strcmp(x.Name, 'long_name'), inf.Variables(ivar).Attributes)); 
                tblERA5.Properties.VariableDescriptions{teller} = inf.Variables(ivar).Attributes(indname).Value; 
            end
        end
        
        function tblERA5 = era52tpar(strfilein, strfileout, append, startdt, enddt, indlon, indlat)

            time0 = datenum('01-Jan-1900');  % reference time

            if ~exist('indlat') || isempty(indlat)
                indlat = 1; 
            end
            if ~exist('indlon') || isempty(indlon) 
                indlon = 1; 
            end

            mattime = double(ncread(strfilein, 'time'))/24+time0; % hours since reference time 1-Jan-1990
            Time = datetime(mattime, 'ConvertFrom', 'datenum');
            Time.Format = 'yyyyMMdd.hhmmss'; 
            Hm0 = squeeze(ncread(strfilein, 'swh', [indlon, indlat,1], [1 1 Inf])); 
            Tm = squeeze(ncread(strfilein, 'mwp', [indlon, indlat,1], [1 1 Inf]));  
            Dirm = squeeze(ncread(strfilein, 'mwd', [indlon, indlat,1], [1 1 Inf])); 
            wdw = squeeze(ncread(strfilein, 'wdw', [indlon, indlat,1], [1 1 Inf])); 
            dspr = wdw*180/pi;

            tblERA5 = table(Time, Hm0, Tm, Dirm, dspr); 

            if ~exist('startdt') || isempty(startdt)
                startdt = datetime(-Inf,0,0);
            end
            if ~exist('enddt') || isempty(enddt)
                enddt = datetime(Inf,0,0);
            end

            indtime = startdt<=Time & Time<=enddt; 
            tblERA5 = tblERA5(indtime,:); 


            if nargin>1 && ~isempty(strfileout)
                % restrict to interval
                mattime = mattime(indtime); 
                Hm0 = Hm0(indtime); 
                Tm = Tm(indtime); 
                Dirm = Dirm(indtime); 
            %     wdw = wdw(indtime); 
                dspr = dspr(indtime); 
                if nargin==2
                    if exist(strfileout) 
                        append = true; 
                    else 
                        append = false;
                    end
                end
                if append 
                    fid = fopen(strfileout, 'a'); 
                else
                    fid = fopen(strfileout, 'w'); 
                    fprintf(fid, '%s\r\n', 'TPAR');
                end

                vectime = datevec(mattime); 
                conv = [1e4 1e2 1 1e-2 1e-4 1e-6]';
                isotime = vectime*conv;

                matr = [isotime, Hm0, Tm, Dirm, dspr]; 
                cmatr = matr'; 
                fprintf(fid, '%15.6f %6.2f %6.2f %6.1f %6.2f\r\n', cmatr); 
                fclose(fid); 
            end
        end
   
    end

end

        
    