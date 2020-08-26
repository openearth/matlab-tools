%Class to declare the most common Telemac
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Telemac < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
    properties(Dependent = true, SetAccess = private)
        
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
    
    %Static methods
    methods (Static)
        
        function addVar2slf(fileIn,fileOut,varName,varData)
            % add a new variable to the first time step a selafin file
            %
            % addVar2slf(fileIn,fileOut,varName,varData)
            %
            % INPUT: 
            % - fileIn, fileOUt: names of the file to read and write
            % - varName: cell array with the names of the new variables to
            % add
            % - varData: matrix with in each column data for a new
            % variable to add.
            % OUTPUT:
            %
            
            % read slf
            sct = telheadr(fileIn);
            sct = telstepr(sct,1);
            
            % add variables
            for i=1:length(varName)
                sct.RECV(end+1) = varName(i);
                sct.RESULT(:,end+1) = varData(:,i);
                sct.NBV = sct.NBV+1;
            end
            
            %write slf
            fid = telheadw(sct,fileOut);
            fid = telstepw(sct,fid);
            fclose(fid);
        end
        
        function addWindCoeffSlf(windFile,slfFile,fileIndex,interpVar,ncCode,merc)
            % Add coefficients to the slf file for wind .nc/.grb file
            %
            % addWindCoeffSlf(windFile,slfFile,fileIndex,interpVar,ncCode,merc)
            %
            % INPUT
            % winFile = .nc/.grb file 
            % slfFile = serafin file
            % fileIndex = file number to add to coeff variables (in case we
            % implement using this with multiple netcdf files)
            % interpVar = name of variable to use (e.g., 'u10' -> for era data),
            % ('ugrd10m' -> for gfs data)
            % ncCode = 1 (era), 2 (gfs)
            % Specify merc to include conversion from merc to lat lon
            % (needed for interpolating wind data which is in WGS84 lat lon)
            % merc = merc.lon0 -> origin long
            %        merc.lat0 -> origin lat
            % E.g:
            % windFile = 'test.nc';
            % slfFile = 'grid.slf';
            % interpVar = 'u10';
            % fileIndex = 1;
            % ncCode = 1;
            % merc.lon0 = 38; merc.lat0 = 12;
            
            %read selafin file
            
            sct = telheadr(slfFile);
            sct = telstepr(sct,1);
            x = sct.XYZ(:,1);
            y = sct.XYZ(:,2);
            if exist('merc','var')
                [lon, lat] = Telemac.mercator2spherical(x,y,merc.lon0,merc.lat0);
		    else
			    lon = x;
                lat = y;
            end
            % convert To lat long using Telemac toolbox
                        
            % read glfsgrid to determine interpolation coeffcients
            if ncCode == 1
                [lonGrid,latGrid,mask] = Telemac.getEra(windFile,interpVar);
            elseif ncCode == 2
                [lonGrid,latGrid,mask] = Telemac.getgfs(windFile);
            end
            
            % determine the interpolation coeffcients for the mesh
            
            [indexLat,indexLon] = meshgrid(1:size(lonGrid,2),1:size(lonGrid,1));
            interpLat = interp2(latGrid,lonGrid,indexLat,lat,lon);
            interpLon = interp2(latGrid,lonGrid,indexLon,lat,lon);

            
            if any(isnan(interpLat)) || any(isnan(interpLon))
                error('Some of the meshpoints are outside the mesh of the wind data');
            end
            
            
            indLat = floor(interpLat);
            weightLat = interpLat-indLat;
            indLon = floor(interpLon);
            weightLon = interpLon-indLon;
            % weight per point (clockwise starting left below)
            w1 = (1-weightLat).*(1-weightLon); %lat,lon
            w2 = weightLat.*(1-weightLon);     %lat+1,lon
            w3 = weightLat.*weightLon;         %lat+1,lon+1
            w4 = (1-weightLat).*weightLon;     %lat,lon+1
            
            % correct for no_data values
            
            linearInd1 = sub2ind(size(indexLat), indLon, indLat);
            linearInd2 = sub2ind(size(indexLat), indLon, indLat);
            linearInd3 = sub2ind(size(indexLat), indLon, indLat);
            linearInd4 = sub2ind(size(indexLat), indLon, indLat);
            mask1 = mask(linearInd1);
            mask2 = mask(linearInd2);
            mask3 = mask(linearInd3);
            mask4 = mask(linearInd4);
            w1(mask1) = 0;
            w2(mask2) = 0;
            w3(mask3) = 0;
            w4(mask4) = 0;
            w = w1+w2+w3+w4;
            mask = w>0;
            if any(w==0)
                warning('There are points without data');
            end
            w1(mask)=w1(mask)./w(mask);
            w2(mask)=w2(mask)./w(mask);
            w3(mask)=w3(mask)./w(mask);
            w4(mask)=w4(mask)./w(mask);            
            
            % add to telemac data structure
            stri = num2str(fileIndex,'%02.0f');
            
            newVar = {['INDEXLAT',stri];['INDEXLON',stri];['WLL',stri];['WUL',stri];['WUR',stri];['WLR',stri]};
            indVar = Telemac.findVar(newVar,sct);
            if sum(indVar)>0
                sct = Telemac.deleteVar(sct,indVar,true);
            end
            
            sct.RECV = [sct.RECV;newVar];
            sct.RESULT = [sct.RESULT,indLat,indLon,w1,w2,w3,w4];
            sct.NBV = sct.NBV + 6;
            
            % write selafin file
            if ncCode == 1
                fileOut = [slfFile(1:end-4),'_ERA.slf'];
            elseif ncCode == 2
                fileOut = [slfFile(1:end-4),'_GFS.slf'];
            end
            
            fid = telheadw(sct,fileOut);
            fid = telstepw(sct,fid);
            fclose(fid);                                  
            
        end
        
        function changeVar(fileIn,fileOut, varName, minVals, maxVals, equation)
            % changes variables in a telemac file  to a min or max
            %
            % changeVar (fileIn,fileOut, varName, minVals, maxVals, equation)
            %
            % INPUT:
            % -fileIn,
            % -fileOut,
            % -varName, cell array with nams of he variables to change
            % - minVals, maxVals: arrays (smae size as varName) with minimum
            % and maximum for each variable. Set to nan to ignore. Can be
            % set empty.
            % -equation: (optional): string with an equation to apply to a
            % variable, which is denoted with 'x'; Time is denoted by 't'
            
            if ~iscell(varName) || isempty(varName)
                error('Invalid input for variable name');
            end
            
            % read slf
            sct = telheadr(fileIn);
            %write slf
            fid = telheadw(sct,fileOut);
            for iTime = 1:sct.NSTEPS
                sct = telstepr(sct,iTime);
                
                
                % change variables
                for i=1:length(varName)
                    ind = Telemac.findVar(varName(i),sct);
                    if isempty(ind)
                        error('variable not found');
                    end
                    if ~isempty(minVals) && ~isnan(minVals(i))
                        sct.RESULT(:,ind) = max(sct.RESULT(:,ind),minVals(i));
                    end
                    if ~isempty(maxVals) &&~isnan(maxVals(i))
                        sct.RESULT(:,ind) = min(sct.RESULT(:,ind),maxVals(i));
                    end
                    if nargin > 5
                        x  = sct.RESULT(:,ind); %#ok<NASGU>
                        t  = sct.AT; %#ok<NASGU>
                        sct.RESULT(:,ind) = eval(equation);
                    end
                end
                
                fid = telstepw(sct,fid);
            end
            fclose(fid);
            
        end
        
        function hFig = cliViz(slfFile,cliFile,inputParams)
            % function [] = Telemac.cliViz(slfFile,cliFile);
            % Plot cli file along with names of each boundary segment
            % tides
            % Inputs:
            %  - slfFile: Name (including path) of Selafin file of Telemac
            %  - cliFile: Name (including path) of Cli file
            %  - inputParams: cell array of parameters to visualize. Includes:
            %    - 'name': Name of segment
            %    - 'tetap'
            %    - 'Rp': Reflection coefficient
            
            if nargin < 3;
                inputParams = {'name'};
            end
            
            [ds,slf]=Telemac.readTelemacData(slfFile);
            [cli,boundNames]=Telemac.readCli(cliFile);
            
            bn = unique(boundNames);
            
            hFig = UtilPlot.reportFigureTemplate(15,15);
            hold all;
            hp = Plot.plotTriangle(ds.X.data,ds.Y.data,nan*ds.X.data,slf.IKLE);
            hp.Annotation.LegendInformation.IconDisplayStyle = 'off'
            hp.EdgeColor = 'k';
            hp.EdgeAlpha = 0.05;
            axis equal;
            for i = 1:numel(bn);
                mask = strcmpi(boundNames,bn{i});
                
                % initialize string
                txt = '';
                
                
                if any(strcmpi(inputParams,'name'))
                    if strcmpi(bn{i},'');
                        txt = 'EMPTY';
                    else
                        txt = bn{i};
                    end
                end
                
                if any(strcmpi(inputParams,'type'));
                    switch unique(cli(mask,1))
                        case 1
                            txt = [txt newline 'INCOMING'];
                        case 2
                            txt = [txt newline 'WALL'];
                        case 4
                            txt = [txt newline 'OUTGOING'];
                    end
                end
                
                
                if any(strcmpi(inputParams,'tetap'));
                    txt = [txt newline sprintf('tetap %.1f',unique(cli(mask,5)))];
                end
                
                if any(strcmpi(inputParams,'Rp'));
                    txt = [txt newline sprintf('Rp %.2f',unique(cli(mask,7)))];
                end
                
                if ~(mask(1)&mask(end));%One boundary goes around the end point of the cli file -> split in two
                    belem = cli(mask,12);
                    hp = plot(ds.X.data(belem),ds.Y.data(belem));
                    tx = mean(ds.X.data(belem));
                    ty = mean(ds.Y.data(belem));
                    ht = text(tx,ty,txt,'interpreter','none',...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','middle',...
                        'color',hp.Color);
                else
                    belem = cli(1:find(~mask,1)-1,12);
                    if ~isempty(belem)
                        hp = plot(ds.X.data(belem),ds.Y.data(belem));
                        tx = mean(ds.X.data(belem));
                        ty = mean(ds.Y.data(belem));
                        ht = text(tx,ty,txt,'interpreter','none',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'color',hp.Color);
                    end
                    
                    belem = cli(find(~mask,1,'last')+1:end,12);
                    if ~isempty(belem)
                        hp = plot(ds.X.data(belem),ds.Y.data(belem));
                        tx = mean(ds.X.data(belem));
                        ty = mean(ds.Y.data(belem));
                        ht = text(tx,ty,txt,'interpreter','none',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'color',hp.Color);
                    end
                end
            end
            % add markers as in BlueKenue
            clear mask;
            marker = {'k.','vg','^b','cd','sy','sr'};
            name = {'222','H(544)','Q(455)','QH(555)','UH(566)','U(466)'};
            mask{1}= cli(:,1)==2 & cli(:,2)==2 & cli(:,3)==2;
            mask{2} = cli(:,1)==5 & cli(:,2)==4 & cli(:,3)==4;
            mask{3} = cli(:,1)==4 & cli(:,2)==5 & cli(:,3)==5;
            mask{4} = cli(:,1)==5 & cli(:,2)==5 & cli(:,3)==5;
            mask{5} = cli(:,1)==5 & cli(:,2)==6 & cli(:,3)==6;
            mask{6} = cli(:,1)==4 & cli(:,2)==6 & cli(:,3)==6;
            hold on;
            for i=1:length(mask)
                if any(mask{i})
                    ind = cli(mask{i},12);
                    plot(ds.X.data(ind),ds.Y.data(ind),marker{i},'DisplayName',name{i},'MarkerSize',3);
                end
            end
            legend('location','best');
            box on;
        end

        function connectTelTom(telFile,tomFile,contourTom,contourTel)
            %
            %
            % connectTelTom(telFile,tomFile,contourTom,contourTel)
            % 
            % INPUT:
            % - telFile, tomFile: selafin files with the meshes of telemac
            % and tomawac
            % - contourTel, contourTom: i2s files with contours that should
            % not be taken into account
            
            % read meshes
            sctT2d=telheadr(telFile);
            sctTom=telheadr(tomFile);
            sctT2d = telstepr(sctT2d,1);
            sctTom = telstepr(sctTom,1);
            % extract points
            x_t2d = sctT2d.XYZ(:,1);
            y_t2d = sctT2d.XYZ(:,2);
            x_tom = sctTom.XYZ(:,1);
            y_tom = sctTom.XYZ(:,2);
            xy_t2d = [x_t2d y_t2d];
            xy_tom = [x_tom y_tom];
            
            %  linear interpolation from telemac to tomawac
            if nargin <3 || isempty(contourTel)
                mask = true(size(x_tom));
            else
               % specify a mask based on a polyline
                mask = true(size(x_tom));
                cTmp = Telemac.readKenue(contourTel);
                for j=1:length(cTmp)
                    mask = mask & ~inpoly(xy_tom, cTmp{j}(:,1:2));
                end
            end
            outFile = [tomFile(1:end-4),'tel2tom.slf'];
            Telemac.connectSendRecv('TEL2TOM',mask,sctT2d,sctTom,outFile)
            
            %  linear interpolation from tomawac to telemac
            if nargin <4 || isempty(contourTom)
                mask = true(size(x_t2d));
            else
               % specify a mask based on a polyline
                mask = true(size(x_t2d));
                cTmp = Telemac.readKenue(contourTel);
                for j=1:length(cTmp)
                    mask = mask & ~inpoly(xy_t2d, cTmp{j}(:,1:2));
                end
            end
            outFile = [telFile(1:end-4),'tom2tel.slf'];
            Telemac.connectSendRecv('TOM2TEL',mask,sctTom,sctT2d,outFile)
        end
        
        
        function connectSendRecv(varName,mask,sctSend,sctRecv,outFile)
            % computed connectivity list between telemac and tomowac
            %
            %connectSendRecv(varName,mask,sctSend,sctRecv,outFile)
            %
            % INPUT:
            % - varName: name of variables to create. can be either TEL2TOm
            % or TOM2TEL
            % - mask: list of points not to include
            % - sctSend: - strcuture of mesh for sender using telheadr
            % - sctRecv: - strcuture of mesh for receiver using telheadr
            % - outFile: name of file to make
            %
            % IT COMPUTES THE CONNECTIVITY LIST BETWEEN
            % TELEMAC2D AND TOMAWAC SELAFIN FILES
            %
            % --------------------------------------------------------------
            % The new TOMAWAC selafin file TOM_interp.slf created, includes:
            % --------------------------------------------------------------
            % ->TEL2TOM:
            % CLOSEST INDEX OF THE TELEMAC2D MESH ONTO
            % THE TOMAWAC GRID NODES
            % ->TEL2TOM01,TEL2TOM02,TEL2TOM03:
            % NEAREST NEIGHBOR INDEX (THE OTHER TWO VARIABLES ARE ZERO)
            % ->TEL2TOMWTS01,TEL2TOMWTS02,TEL2TOMWTS03:
            % LINEAR INTERPOLATION COEFFICIENTS
            
            
            sctTel2Tom = Triangle.interpTrianglePrepare(sctSend.IKLE,sctSend.XYZ(:,1),sctSend.XYZ(:,2),sctRecv.XYZ(mask,1),sctRecv.XYZ(mask,2),true,true);
            %transform extrapolation coefficients
            sctTel2Tom.coordIndex(~sctTel2Tom.mask,1)=sctTel2Tom.nanPoints;
            sctTel2Tom.coordIndex(~sctTel2Tom.mask,2:3)=0;
            sctTel2Tom.interpCoef(~sctTel2Tom.mask,1)=1;
            sctTel2Tom.interpCoef(~sctTel2Tom.mask,2:3)=0;
            % add to structure
            NBV = sctRecv.NBV;
            for i=1:3
                ind = NBV+2*i;
                sctRecv.RESULT(mask,ind-1) = sctTel2Tom.coordIndex(:,i);
                sctRecv.RESULT(mask,ind)   = sctTel2Tom.interpCoef(:,i);
                sctRecv.RECV{ind} = [varName,'WTS',num2str(i,'%02.0f')];
                sctRecv.RECV{ind-1} = [varName,num2str(i,'%02.0f')];
                sctRecv.NBV = sctRecv.NBV+2;
            end
            % save
            fid = telheadw(sctRecv,outFile);
            fid = telstepw(sctRecv,fid);
            fclose(fid);
        end
        
        function convertCli(oldSlf,oldCli,newSlf,newCli)
            % adapts mesh settings when a mesh as changed
            %
            %convertCli(oldSlf,oldCli,newSlf,newCli)
            %
            % INPUT
            % -oldSlf, -newSlf: mesh files for the old and new mesh
            % -oldCli, newCli: cli files for the two meshes. the newCli is
            % without any specifications of open boundaries (i.e. 2 2 2
            % everywhere). These settings are copied from the old to the
            % new file (using the closest node approach).
            %
            
            % read mesh and cli
            sctOld = telheadr(oldSlf);
            sctNew = telheadr(newSlf);
            [obcOld,boundaryNameOld] = Telemac.readCli(oldCli);
            [obcNew,boundaryNameNew] = Telemac.readCli(newCli);
            
            % find non standard boundaries
            maskObc  = obcOld(:,1)~=2 | obcOld(:,2)~=2 | obcOld(:,3)~=2;
            indexOld = obcOld(:,12);
            indexNew = obcNew(:,12);
            xOld = sctOld.XYZ(indexOld(maskObc),1);
            xNew = sctNew.XYZ(indexNew,1);
            yOld = sctOld.XYZ(indexOld(maskObc),2);
            yNew = sctNew.XYZ(indexNew,2);
            indObc = find(maskObc);
            
            %change boundary conditins in new file
            for i=1:size(xOld,1)
                dist = hypot(xNew-xOld(i),yNew-yOld(i));
                [tmp,ind] = min(dist);
                obcNew(ind,1:11)=obcOld(indObc(i),1:11);
                obcNew(ind,14)  =1;
                boundaryNameNew{ind} = boundaryNameOld{indObc(i)};
            end
            
            % write new cli file
            outFile = [newCli(1:end-4),'_new.cli'];
            Telemac.writeCli(outFile,obcNew,boundaryNameNew);
            
            
        end
        
        function [] = cotidalMap(slfFile,topexFile,opt)
            % function [] = cotidalMaps(slfFile,topexFile,opt);
            % Plot cotidal maps that show the difference between Telemac and TOPEX
            % tides
            % Inputs:
            %  slfFile: Name (including path) of Selafin output file of Telemac
            %  topexFile: Name (including path) of Topex binary elevation file
            %  opt : options structure, including:
            %  opt.outputFolder: Folder where the resulting figures are outputted
            %  opt.const: Cell array containing constituents (in TOPEX format)
            %  opt.projection: Either 'mercatorTelemac' or 'spherical'
            %  opt.lat0 = Latitude of origin (for mercatorTelemac projection);
            %  opt.lon0 = Longitude of origin (for mercatorTelemac projection);
            %  opt.ampRange: Color range for tidal amplitudes, in a cell array, one per
            %  constituent
            %  opt.diffRange: Color range for difference in tidal amplitudes, in a cell
            %  array, one per constituent
            %  opt.CSout = name of coordinate system to plot output in
            %  (makes use of the convertCoordinates command of OpenEarth)
            %  opt.time: time
            %
            %  Example:
            %  opt.const = ['k1';'m2';'s2'];
            %  opt.ampRange = {[0 0.8];[0 2];[0 0.8]};
            %  opt.diffRange = {[-.2 0.2];[-0.4 0.4];[-0.4 0.4]};
            
            
            if ~isfield(opt,'time')
                warning('No time spacified. Nodal factor will not be applied!');
                useNodal = false;
            else
                useNodal = true;
                % conversion to modified julian days
                time = opt.time-datenum([1858 11 17 0 0 0]);
                if numel(time)>1
                    error('Only one time is allowed');
                end
            end
            
            if ~isfield(opt,'outputFolder')
                opt.outputFolder = './';
            end
            if ~isfield(opt,'plotGoogleMaps')
                opt.plotGoogleMaps = false;
            end
            if ~isfield(opt,'ampRange')
                opt.ampRange={};
                for i = 1:size(opt.const,1)
                    opt.ampRange = [opt.ampRange;[0 1]];
                end
            end
            if ~isfield(opt,'diffRange')
                opt.diffRange={};
                for i = 1:size(opt.const,1)
                    opt.diffRange = [opt.diffRange;[-1 1]];
                end
            end
            %change size of string. Needed for tpxo
            if size(opt.const,2)<4
                opt.const(:,4) = ' ';
                opt.const(opt.const==0) = 32;
            end
            %% TELEMAC Calculations
            
            slfHead = telheadr(slfFile);
            slfGrid = slfHead.XYZ;
            slfIkle = slfHead.IKLE;
            
            switch opt.projection
                case 'spherical'
                    lon = slfGrid(:,1);
                    lat = slfGrid(:,2);
                case 'mercatorTelemac'
                    [lon,lat] = Telemac.mercator2spherical(slfGrid(:,1),slfGrid(:,2),opt.lon0,opt.lat0);
            end
            
            %convert tpxo to be between 0 and 360 deg
            latTpxo = lat;
            lonTpxo = lon;
            %lonTpxo(lonTpxo<0) = lonTpxo(lonTpxo<0) + 360;
            
            
            
            %Initiate cell arrays:
            nrConst = size(opt.const,1);
            telAmp = cell(nrConst,1);
            telPhase = cell(nrConst,1);
            topexAmp = cell(nrConst,1);
            topexPhase = cell(nrConst,1);
            % Read the Telemac and Topex amplitudes and phases
            slfHead = telheadr(slfFile);
            slfLast = telstepr(slfHead,slfHead.NSTEPS);
           
            if useNodal
                [nodalPhase,nodalAmp] = nodal(time,opt.const);
            end
            
            
            
            for iCon =1:nrConst
                % telemac 2d convention
                col1 = find(strcmp(slfLast.RECV,sprintf('AMPLI PERIOD  %u M               ',iCon)));
                col2 = find(strcmp(slfLast.RECV,sprintf('PHASE PERIOD  %u DEGRES          ',iCon)));
                % telemac 3d convention
                if isempty(col1)
                    tmpName = upper(['AMPLITUDE_',opt.const(iCon,1:2)]);
                    col1 = Telemac.findVar({tmpName},slfLast);
                    tmpName = upper(['PHASE_',opt.const(iCon,1:2)]);
                    col2 = Telemac.findVar({tmpName},slfLast);
                end
                
                telAmp{iCon}   = slfLast.RESULT(:,col1);
                telPhase{iCon} = slfLast.RESULT(:,col2);
                
                %% TOPEX Co-Tidal Maps
                ModName = rdModFile(topexFile,1);
                conList = rd_con(ModName);
                conListCell = mat2cell(conList,ones(size(conList,1),1));
                iC = find(strcmpi(conListCell,opt.const(iCon,:)));
                [topexAmp{iCon},topexPhase{iCon},~,~] = tmd_extract_HC(topexFile,latTpxo,lonTpxo,'z',iC);
                topexAmp{iCon}   = topexAmp{iCon}';
                topexPhase{iCon} = topexPhase{iCon}';
                if useNodal
                    topexAmp{iCon} = nodalAmp(iCon).*topexAmp{iCon};
                    topexPhase{iCon} = topexPhase{iCon}+nodalPhase(iCon)*180/pi;
                end
                
                
            end
            
            %% Coordinate conversion for output if requested
            
            if isfield(opt,'CSout')
                CSin = 'WGS 84'; %code: 4326
                try
                    [lon,lat]=convertCoordinates(lon,lat,'CS1.name',CSin,'CS1.type','geo','CS2.name',opt.CSout);
                    sXlabel = ['x-coord (',opt.CSout,')'];
                    sYlabel = ['y-coord (',opt.CSout,')'];
                catch
                    warning(['>>> no coordinate conversion performed: check if name for output coordinate system is correct: ',opt.CSout,' & ' ...
                        'check if OpenEarth toolbox is added (necessary to run convertCoordinates.m).']);
                    %rethrow(err);
                end
            else % everything plotted in lat, long
                sXlabel = '°E';
                sYlabel = '°N';
            end
            
            %% Plot results
            for iCon = 1:nrConst
                
                %% TELEMAC Plotting
                
                % Plot Amplitudes
                
                h_fig = figure('units','centimeters','position',[4 4 15 9],'paperpositionmode','auto');
                set(gca,'position',[0.08 0.11 0.9 0.78]);
                
                h_tel = patch('faces',slfIkle,'vertices',[lon lat],'FaceVertexCData',telAmp{iCon}, ...
                    'FaceColor','interp','EdgeColor','none','linewidth',0.01);hold on;
                
                axis equal
                set(gca,'box','on')
                xlabel(sXlabel)
                ylabel(sYlabel)
                
                title(['Telemac Amplitude map of Constituent ' opt.const(iCon,:)],'FontSize',15);
                clm1=colormap(jet(96));
                clm2=clm1(8:88,1:3);
                colormap(clm2);
                cb = colorbar;
                caxis(opt.ampRange{iCon});
                
                % Save Figure
                
                fileName = ['CoTidalMap_Amp_' opt.const(iCon,:)];
                print('-dpng','-r200',fullfile(opt.outputFolder,fileName));
                
                clf;close('all');
                
                % Plot Phases
                
                h_fig = figure('units','centimeters','position',[4 4 15 9],'paperpositionmode','auto');
                set(gca,'position',[0.08 0.11 0.9 0.78]);
                
                h_tel = patch('faces',slfIkle,'vertices',[lon lat],'FaceVertexCData',telPhase{iCon}, ...
                    'FaceColor','interp','EdgeColor','none','linewidth',0.01);hold on;
                
                axis equal
                set(gca,'box','on')
                xlabel(sXlabel)
                ylabel(sYlabel)
                
                title(['Telemac Phase map of Constituent ' opt.const(iCon,:)],'FontSize',15);
                clm1=colormap(hsv(12));
                colormap(clm1);
                cb = colorbar;
                caxis([0 360]);
                set(cb,'Ytick',0:30:360);
                
                % Save Figure
                
                fileName = ['CoTidalMap_Pha_' opt.const(iCon,:)];
                print(gcf,'-dpng','-r200',fullfile(opt.outputFolder,fileName));
                
                clf;close('all');
                
                %% Plotting TOPEX
                
                % Plot Amplitudes
                
                h_fig = figure('units','centimeters','position',[4 4 15 9],'paperpositionmode','auto');
                set(gca,'position',[0.08 0.11 0.9 0.78]);
    
                h_tel = patch('faces',slfIkle,'vertices',[lon lat],'FaceVertexCData',topexAmp{iCon}, ...
                    'FaceColor','interp','EdgeColor','none','linewidth',0.01);hold on;
                
                axis equal
                set(gca,'box','on')
                xlabel(sXlabel)
                ylabel(sYlabel)
                
                title(['TOPEX Amplitude map of Constituent ' opt.const(iCon,:)],'FontSize',15);
                
                clm1=colormap(jet(96));
                clm2=clm1(8:88,1:3);
                colormap(clm2);
                cb = colorbar;
                caxis(opt.ampRange{iCon});
                
                
                % Save Figure
                
                fileName = ['CoTidalMap_AmpTopex_' opt.const(iCon,:)];
                print(gcf,'-dpng','-r200',fullfile(opt.outputFolder,fileName));
                
                clf;close('all');
                
                % Plot Phases
                
                h_fig = figure('units','centimeters','position',[4 4 15 9],'paperpositionmode','auto');
                set(gca,'position',[0.08 0.11 0.9 0.78]);
                
                h_tel = patch('faces',slfIkle,'vertices',[lon lat],'FaceVertexCData',topexPhase{iCon}, ...
                    'FaceColor','interp','EdgeColor','none','linewidth',0.01);hold on;
                
                axis equal
                set(gca,'box','on')
                xlabel(sXlabel)
                ylabel(sYlabel)
                
                
                title(['TOPEX Phase map of Constituent ' opt.const(iCon,:)],'FontSize',15);
                clm1=colormap(hsv(12));
                colormap(clm1);
                cb = colorbar;
                caxis([0 360]);
                set(cb,'Ytick',0:30:360);
                
                % Save Figure
                
                fileName = ['CoTidalMap_PhaseTopex_' opt.const(iCon,:)];
                print(gcf,'-dpng','-r200',fullfile(opt.outputFolder,fileName));
                
                clf;close('all');
                
                %% Telemac - TOPEX maps
                
                % Calculate difference
                
                ampDiff = telAmp{iCon} - topexAmp{iCon};
                phaseDiff = telPhase{iCon} - topexPhase{iCon};
                
                % Plotting Amplitude difference
                
                h_fig = figure('units','centimeters','position',[4 4 15 9],'paperpositionmode','auto');
                set(gca,'position',[0.08 0.11 0.9 0.78]);
                
                h_tel = patch('faces',slfIkle,'vertices',[lon lat],'FaceVertexCData',ampDiff, ...
                    'FaceColor','interp','EdgeColor','none','linewidth',0.01);hold on;
                axis equal
                set(gca,'box','on')
                xlabel(sXlabel)
                ylabel(sYlabel)
                
                title(['Amplitude difference (model - Topex) map of constituent ' opt.const(iCon,:)],'FontSize',15);
                
                colormap(UtilPlot.colormapIMDC('rwg',96));
                cb = colorbar;
                caxis(opt.diffRange{iCon});
                
                % Save Figure
                
                fileName = ['DIFF_CoTidalMap_Amp_' opt.const(iCon,:)];
                print(gcf,'-dpng','-r200',fullfile(opt.outputFolder,fileName));
                
                clf;close('all');
                
                % Plot Phases
                
                h_fig = figure('units','centimeters','position',[4 4 15 9],'paperpositionmode','auto');
                set(gca,'position',[0.08 0.11 0.9 0.78]);
                
                h_tel = patch('faces',slfIkle,'vertices',[lon lat],'FaceVertexCData',phaseDiff, ...
                    'FaceColor','interp','EdgeColor','none','linewidth',0.01);hold on;
                
                axis equal
                set(gca,'box','on')
                xlabel(sXlabel)
                ylabel(sYlabel)
                
                
                title(['Phase difference (model - Topex) of constituent ' opt.const(iCon,:)],'FontSize',15);
                colormap(UtilPlot.colormapIMDC('rwg',96));
                cb = colorbar;
                caxis([-90 90]);
                set(cb,'Ytick',-90:15:90);
                
                % Save Figure
                
                fileName = ['DIFF_CoTidalMap_Phase_' opt.const(iCon,:)];
                print(gcf,'-dpng','-r200',fullfile(opt.outputFolder,fileName));
                
                clf;
                close('all');
                
                
                
            end
            fclose(slfLast.fid);
        end
        
        
        function changeBathHotstart(meshFile,hot3DFile,outFile,sigma)
            % adds a bathymetry to a hotstart
            %
            % changeBathHotstart(meshFile,hot3DFile,outFile,sigma)
            %
            % INPUT:
            %  - meshFile: file with a mesh
            %  - hot3Dfile: 3d hotstart file
            %  - outFile: name of the new file
            %  - sigma (optional): sigma mesh to use; should start at 0 and
            %  end at 1 and have the size of the number of layers of the
            %  three d model
            %
            % Note; telemac overwrites vertical coordinate spacing.
            
            
            MIN_DEPTH = 0.1;
            
            % read files
            sctBed = telheadr(meshFile);
            indBed = Telemac.findVar({'BOTTOM'},sctBed);
            sct3D  = telheadr(hot3DFile);
            sct3D  = telstepr(sct3D,sct3D.NSTEPS);
            indZ = Telemac.findVar({'ELEVATION Z'},sct3D);
            
            % check mesh sizes correspond
            np = sctBed.NPOIN;
            if sct3D.NPOIN/sct3D.NPLAN ~=np
                error('Meshes have different sizes');
            end
            
            % copy bathymetry
            wl = sct3D.RESULT(end-np+1:end,indZ);
            b  = sctBed.RESULT(:,indBed);
            % make sure water level is higher than the bathymetry
            wl = max(wl,b+1e-16);
            d = wl - b;
            
            if nargin ==4
                % use existing sigma acoordinates
                sigma = Util.makeRowVec(sigma);
            else
                % look for wet point
                i = 1;
                while d(i)<MIN_DEPTH
                    i=i+1;
                    if i==length(d)
                        error('No wet points!')
                    end
                end
                z = sct3D.RESULT(i:np:end,indZ);
                sigma = (z-z(1))/(z(end)-z(1));
                sigma = Util.makeRowVec(sigma);
            end
            % new z coordinates (using broadcasting)
            z  = b +sigma.*d;
            
            % check
            dz = diff(z,1,2);
            dzMin = min(dz(:));
            if (dzMin)<0
                error('Mesh layers cross.');
            end
            
            sct3D.RESULT(:,indZ) = z(:);
            
            % write new file
            fid = telheadw(sct3D,outFile);
            fid = telstepw(sct3D,fid);
            fclose all;
            
        end
        
        function checkMesh(slfFile,cliFile)
            % checks a Telemac model for common errors
            %
            % checkMesh(slfFile,cliFile)
            %
            % INPUT:
            
            % open data
            cliData = Telemac.readCli(cliFile);
            sctData = telheadr(slfFile);
            fclose all;
            nrErr = 0;
            
            % check for variables in slf file
            if ~any('BOTTOM FRICTION',strncmp(sctData.RECV,15));
                warning('No bottom friction defined in the cas file. Make sure you use it in the cli file');
                nrErr = nrErr +1;
            end
            if ~any('BOTTOM         ',strncmp(sctData.RECV,15));
                warning('No BOTTOM  defined in the cas file. You really want this?');
                nrErr = nrErr +1;
            end
            
            % check double boundary points
            nodes = cliData(:,12);
            uniqueNodes = unique(nodes);
            if length(uniqueNodes) ~= length(nodes)
                % look for double point
                for i=1:length(uniqueNodes)
                    if sum(uniqueNodes(i)==nodes)>1
                        disp(['Double nodes in cli file: ',num2str(uniqueNodes(i))]);
                    end
                end
                nrErr = nrErr +1;
            end
            
            % check boundary conditions
            mask = sct.IPOBO(sct.IPOBO>0);
            sdf = setdiff(cliData(:,12),mask);
            if ~isempty(sdf)
                disp('The following nodes are boundaries in the cli file but not in the mesh');
                disp(num2str(sdf));
                warning('Problem with the boundaries');
                nrErr = nrErr +1;
            end
            
            sdf = setdiff(mask,cliData(:,12));
            if ~isempty(sdf)
                disp('The following nodes are boundaries in the mesh but not in the cli file');
                disp(num2str(sdf));
                warning('Problem with the boundaries');
                nrErr = nrErr +1;
            end
            
            disp(['There were ',num2str(nrErr),' with the mesh']);
            
            %Still add checks from improve grid?
        end
        
        function dataOut = convertTelemac3Ddata(sctIn,selectedVar)
            %This function converts grid and data of a 3d telemac file, to 2d maps
            %
            %dataOut = convertTelemac3Ddata(sctIn,selectedVar)
            %
            %sctIn: Telemac structure from telreads
            %selectedVars: scalar the number of the variables to extract
            
            % Selecting 2D data from 3D data for plotting one layer:
            
            % in this case, the data are put after each other starting in the lowest layer, up to the highest layer
            % the connectivity matrix has no 6 points, 3 with the lowest triangle and then 3 with the highest triangle.
            
            
            nrLayers = sctIn.nrLayers;
            nrPoints = sctIn.nrPoints;
            %nrElements = sctIn.NELEM/(nrLayers-1);
            
            % converting the data
            dataOut = reshape(sctIn.RESULT(:,selectedVar),nrPoints,nrLayers);
        end
        
        function dataOut = convertTelemac2Ddata(sctIn,nrLayers,selectedVar)
            %This function converts grid and data of a 2d data file to 3d
            %by copying data
            %
            %dataOut = convertTelemac2Ddata(sctIn,nrPlanes,selectedVar)
            %
            %sctIn: Telemac structure from telreads
            %nrPlanes: the number of planes
            %selectedVars: scalar the number of the variables to extract
            %(optional)
            
            nrLayers = sctIn.NPLAN;
            nrPoints = sctIn.NPOIN/nrLayers;
            %nrElements = sctIn.NELEM/(nrLayers-1);
            
            % converting the data
            dataOut = reshape(sctIn.RESULT(:,selectedVar),nrPoints,nrLayers);
        end
        
        function sctOut = convertTelemac2Dgrid(sctIn,nrLayers)
            %This function converts grid and data of a 2d telemac file, to
            %3d data structure
            %
            %sctOut = convertTelemac2Dgrid(sctIn,nrLayers)
            %
            % - sctIn: Telemac structure from telreads
            % - nrLayers: number of nodes in the 3d dataset
            
            % copy structure and adapat the size
            sctOut       = sctIn;
            sctOut.NPLAN = nrLayers;
            nrPoin2      = sctOut.NPOIN;
            nrElem2      = sctOut.NELEM;
            nrPoints     = nrPoin2*nrLayers;
            nrElements   = nrElem2*(nrLayers-1);
            sctOut.NPOIN = nrPoints;
            sctOut.NELEM = nrElements;
            sctOut.IPARAM(7) = nrLayers;
            sctOut.NDP   = 6;
            
            % converting the grid
            ikle = zeros(nrElements,6);
            for i=1:nrLayers-1
                i1 = 1+(i-1)*nrElem2;
                i2 = i*nrElem2;
                ikle(i1:i2,1:3)     = sctOut.IKLE + (i-1) * nrPoin2;
                ikle(i1:i2,4:6)     = sctOut.IKLE +  i    * nrPoin2;
            end
            sctOut.IKLE  = ikle;
            sctOut.XYZ   = repmat(sctOut.XYZ,nrLayers,1);
            sctOut.IPOBO = repmat(sctOut.IPOBO,nrLayers,1);
        end
        
        function sctOut = convertTelemac2Dto3D(sctIn,bed,surface,sigma,minDep)
            % converts a 2d telemac data structure to a 3d one
            %
            % sctOut = convertTelemac2Dto3D(sctIn,bed,surface,sigma,minDep)
            %
            % INPUT:
            % - sctIn: telemac data structure
            % - bed: [Nx1] vector with bed lebel elevations
            % - surface: [Nx1] vector with water level elevations
            % - sigma: [Mx1] vector with sigma coordinates of the nodes to
            % - additionally for double sigma cordinates a structure with fields:
            %    -- sigma.sigma: sigma coordinates for each layer
            %    -- sigma.z: z z coordinates for each layer
            %    -- sigma.isS: define is a points is sigma or z coordinate
            % additional details in the telemac source code (calcot.f)
            % e.g the following distribution with 11 layers
            %      sigma.sigma1 = [0:0.2:0.8]
            %     sigma.sigma2 = [0.2:0.2:1];
            %     sigma.split  = -4
            %    
            % - minDep (optional): minimum water depth. default = 0.01
            %             
            % OUTPUT:
            % -sctOut: new telemac structure
            
            
            if nargin<5
                minDep = 0.01;
            end
            minDz = 0.002;
            
            if isstruct(sigma)
                nrLayers = length(sigma.sigma);
            else
                nrLayers = length(sigma);
            end
            
            sctOut   = Telemac.convertTelemac2Dgrid(sctIn,nrLayers);
            
            % convert other variables
            sctOut.RESULT = repmat(sctOut.RESULT,nrLayers,1);
            % make Z and add to the data
            nrPoin = length(bed);
            
            depth = max(surface-bed,minDep);
            if isstruct(sigma)
                z = ModelUtil.vertCoord(bed, surface,sigma.z,sigma.sigma,sigma.isZ);
                z = z(:);
            else
                % classical sigma coordinates
                z = zeros(nrLayers*nrPoin,1);
                for i=1:nrLayers
                    z(1+(i-1)*nrPoin:i*nrPoin) = bed + depth.*sigma(i);
                end
            end
            sctOut.RESULT =  [sctOut.RESULT,z];
            sctOut.RECV   =  [sctOut.RECV;'ELEVATION Z     M               '];
            sctOut.NBV    =  sctOut.NBV+1;
           
        end
        
        
        function sctOut = convertTelemac3Dgrid(sctIn)
            %This function converts grid and data of a 3d telemac file, to 2d maps
            %
            %sctOut = ConvertTelemac3D(sctIn)
            %
            %sctIn: Telemac structure from telreads
            %selectedVars: vector with the nuimber of the variables to extract
            
            % Selecting 2D data from 3D data for plotting one layer:
            
            % in this case, the data are put after each other starting in the lowest layer, up to the highest layer
            % the connectivity matrix has no 6 points, 3 with the lowest triangle and then 3 with the highest triangle.
            
            
            nrLayers   = sctIn.NPLAN;
            nrPoints   = sctIn.NPOIN/nrLayers;
            if nrLayers>1
                nrElements = sctIn.NELEM/(nrLayers-1);
            else
                nrElements = sctIn.NELEM;
            end
            
            sctOut = sctIn;
            % converting the grid
            sctOut.IKLE     = sctIn.IKLE(1:nrElements,1:3);
            sctOut.XYZ      = sctIn.XYZ(1:nrPoints,:);
            sctOut.NPOIN    = nrPoints;
            sctOut.NPLAN    = 1;
            sctOut.IPARAM(7)= 1;
            sctOut.NDP      = 3;
            sctOut.NELEM    = nrElements;
            sctOut.IPOBO    = sctIn.IPOBO(1:nrPoints,:);
            % ooriginal data (not used)
            sctOut.nrLayers = nrLayers;
            sctOut.nrPoints = nrPoints;
        end
        
        function sctTel = deleteVar(sctTel,iVar,delHeader)
            % deletes  variables from a Telemac structure
            %
            % deleteVar(sctTel,iVar,delHeader)
            %
            % INPUT: sctTel: telemac structure from telheadr
            %          iVar: indices of the variables to be deleted
            %     delHeader: true if variable shoudl also be removed form
            %     the header(first time only)
            
            iVar;
            sctTel.RESULT(:,iVar) = [];
            if delHeader
                sctTel.RECV(iVar) = [];
                sctTel.NBV        = sctTel.NBV-length(iVar);
            end
        end
        
        function [] = editSteering(casFilename,casOptions)
            % [] = editSteering(casFilename,casOptions);
            % Edit certain input parameters in a Telemac .cas steering file
            % Inputs:
            % casFilename: Name of the .cas file that needs to be edited
            % casOptions: Nx2 cell array where the first column contains
            % the parameters that need to be changed and the second column
            % contains the new parameters (as strings)
            %
            % Outputs
            % (none)
            % Example:
            % casFilename = 'CSM.cas';
            % casOptions =  {
            %    'WIND','YES'
            %    'TIME STEP','60'
            %    };
            % Telemac.editSteering(casFilename,casoptions);
            
            
            %Make a temporary copy of the original cas file
            oldCopy = [casFilename 'old'];
            copyfile(casFilename,oldCopy);
            
            %Now re-read the file line by line
            fid = fopen(oldCopy);
            
            %Open the cas file (overwrite original file);
            fidNew = fopen(casFilename,'w');
            
            casOptionsChanged = false(size(casOptions,1),1);
            
            i = 1;
            while i<1e6%Read file line by line
                if feof(fid)%If we reached the end of the file, stop
                    break;
                end
                
                line = fgetl(fid);%Read a line
                
                if strcmp(line,'&FIN') || ~ischar(line) %If we reached the end of the file, stop
                    break;
                end
                
                if ~isempty(line) && ~strcmp(line(1),'/')%If the line is not empty or a comment line
                    c = textscan(line,'%s','delimiter',{':','/'});
                    
                    c=c{1};
                    
                    settings(i).name = strtrim(c{1});%Separate each line into the parameter name, choice and comment
                    settings(i).choice = strtrim(c{2});
                    if numel(c)==3
                        settings(i).comment = strtrim(c{3});
                    end
                    
                    for j = 1:size(casOptions,1) %Check if current parameter needs to be changed
                        if strcmp(casOptions{j,1},{settings(i).name})
                            newLine = sprintf('%s\t: %s',casOptions{j,:}); %Write line with adjusted parameter
                            casOptionsChanged(j) = true;%Indicate that this option has in fact been changed in the cas file
                            break;
                        else
                            newLine = line; %If the parameter didn't need to be changed, leave it as is
                        end
                    end
                    i = i+1;
                else
                    newLine = line; %if it was a comment line, copy it
                end
                fprintf(fidNew,'%s\n',newLine); %Write the new line to the file
            end
            
            %Add options that were not in the cas file already
            fprintf(fidNew,'/----------------------------------------------------------------------/\n');
            fprintf(fidNew,'/                       CUSTOM OPTIONS\n');
            fprintf(fidNew,'/----------------------------------------------------------------------/\n');
            
            %Add options that weren't in the original cas file template
            
            for j = find(~casOptionsChanged)'
                newLine = sprintf('%s\t: %s',casOptions{j,:});
                fprintf(fidNew,'%s\n',newLine);
            end
            fclose all;
            
            % Delete temporary copy
            delete(oldCopy);
            
        end
        
        function sctOut = extractTimeSteps(fileIn,fileOut,timeStep,startFromEnd,setTime2Zero)
            % extracts time steps from a selafinFile
            %
            % sctOut = extractTimeSteps(fileIn,fileOut,timeStep,startFromEnd,setTime2Zero)
            %
            %INPUT
            %  - fileIn: selafin file to read; optionally use a cell with 
            %   1: not-reconstructed file
            %   2: geoFile
            %  - fileOut: the selafin file to write
            %  - timeStep: array of time steps to write
            %  - startFromEnd: if true (default) then the time steps are
            %  counted strating form the end
            %  - setTime2Zero: if true (default = false), the time in the file is set to 0 
            if nargin < 5
                setTime2Zero = false;
            end
            if nargin <4
                startFromEnd = true;
            end
            if iscell(fileIn)
                [sct,sctTmp] = Telemac.telheadr(fileIn{1},fileIn{2});
            else
                [sct,sctTmp] = Telemac.telheadr(fileIn);
            end
            [sct,sctTmp] = Telemac.telstepr(sct,sctTmp,1);

            % get times
            if startFromEnd
                timeStep = sort(sct.NSTEPS+1 - timeStep);
            end
            nrTimeStep = length(timeStep);

            if setTime2Zero
                [sct,sctTmp] = Telemac.telstepr(sct,sctTmp,timeStep(1));
                dt = sct.AT;
                sct.IDATE = datevec(datenum(sct.IDATE)+dt/86400);
            end

            sctOut = sct;            
            % write header
            fid = telheadw(sctOut,fileOut);

            % write time steps
            for iT=1:nrTimeStep
                [sct,sctTmp] = Telemac.telstepr(sct,sctTmp,timeStep(iT));
                if setTime2Zero
                    sct.AT = sct.AT-dt;
                end
                sctOut = sct;
                sctOut.NSTEPS = nrTimeStep;
                fid = telstepw(sctOut,fid);
            end
            fclose all;
        end
        
        function varListInd = findVar(varList,sctTel)
            %finds the index of a variable in a Telemac data structure
            %
            % varListInd = findVar(varList,sctTel)
            %
            % INPUT: varList:  cell array or string with a Telemac variable
            %                  name
            %        sctTel: data structure from telheadr
            %
            % OUTPUT: varListInd: index of the variables; if the variable
            % is not found it is 0
            %
            %
            if iscell(varList)
                nrVar = length(varList);
                varListInd = zeros(nrVar,1);
                for j=1:nrVar
                    varName = varList{j};
                    if length(varName<16) %#ok<ISMT>
                        varName(length(varName)+1:16) = ' ';
                    end
                    tmpVar = find(strncmpi(varName,sctTel.RECV,16));
                    if ~isempty(tmpVar)
                        varListInd(j) = tmpVar;
                    end
                end
            else
                if length(varList<16) %#ok<ISMT>
                    varList(length(varList)+1:16) = ' ';
                end
                varListInd = find(strncmpi(varList,sctTel.RECV,16));    
                if isempty(varListInd)
                    error('Variable not found');
                end
            end
            
        end
        
        function [outLine, xOut,yOut] = getBoundary(sct,sorted)
            % determines boundary of an telemac mesh
            %
            %
            % [outLine, xOut,yOut] = getBoundary(sct,sorted)
            % INPUT:
            % - sct: telemac structure (from telheadr)
            % - sorted: if true polylines are extracted
            %
            % OUTPUT:
            % - outLine: list of boudary points
            % - xOut, yOut: x and y coordinates of boundary points (ready
            % to plot)
            
            if nargin ==1
                sorted =false;
            end
            myTri = triangulation(double(sct.IKLE),sct.XYZ);
            outLine = freeBoundary(myTri);
            x = sct.XYZ(:,1);
            y = sct.XYZ(:,2);
            if sorted
                outLine = PolyLine.makePoly(outLine);
                for i = length(outLine):-1:1
                    xOut{i} = x(outLine{i});
                    yOut{i} = y(outLine{i});
                    area(i) = polyarea(xOut{i},yOut{i});
                end
                % sort that the largest is first
                [~,ind] = sort(area,'descend');
                xOut = xOut(ind);
                yOut = yOut(ind);
                outLine = outLine(ind);
                
            else
                xOut = x(outLine)';
                yOut = y(outLine)';
            end
        end
        
        
        function data = getData(sctTel,timeSteps,pointList,varNr)
            % extract data from aselafin file
            %
            % data = getData(sctTel,timeSteps,pointList,varNr)
            %
            %
            % INPUT
            %    -   sctTel:    a structure array as produced by telheadr.m
            %    -   timeSteps: a vector with timesteps to read
            %    -   pointList: a vector wih node numbers to read
            %    -   varNr:     the number of the variable to read
            %
            % OUTPUT
            %    - data: read from the telemac file
            
            if length(varNr)>1
                error('Only one variable at a time!');
            end
                
            % check for file type, and assign automatically by looking for INDIC
            beginPos =  ftell(sctTel.fid);
            try sctTel.type;
                error('Only selafin files are supported');
            catch
                try sctTel.INDIC;
                    sctTel.type = 'leonard';
                catch
                    try sctTel.NELEM;
                        sctTel.type = 'seraphin';
                    catch
                        error('Structure array does not contain recognised data format')
                    end
                end
            end
            if nargin == 1
                error('Two arguments are needed');
            end
            % preallocate
            nrT = length(timeSteps);
            nrX = length(pointList);
            
            data   = zeros(nrT,nrX);
            varLen = 4*(sctTel.NPOIN+2);
            for i= 1:nrT
                startT = sctTel.len1rec*(timeSteps(i)-1)+sctTel.startfpos + 12 + (varNr-1)*varLen;
                
                if nrX < sctTel.NPOIN
                
                
                for j = 1:nrX
                    % look up the right position
                    thePos = startT + 4*pointList(j);
                    fseek(sctTel.fid,thePos,'bof');
                    data(i,j) = fread(sctTel.fid,1,'float32');
                end
                
                elseif isequal(pointList,1:sctTel.NPOIN)
                  startPos = startT + 4;
                  fseek(sctTel.fid,startPos,'bof');
                  data(i,:) = fread(sctTel.fid,sctTel.NPOIN,'float32');
                    
                end
            end
            % reset filepointer
            fseek(sctTel.fid,beginPos,'bof');
        end
        
        function data = getDataGretel(sctTel,timeSteps,pointList,varNr,procNr,locNr)
            % wrapper around getData for parallel processing
            
            % look up local proc number
            locs  = locNr(pointList);
            procs = procNr(pointList);
            
            allProc = unique(procs);
            
            % preallocate

            nrT = length(timeSteps);
            nrX = length(pointList);
            
            data   = zeros(nrT,nrX);
            
            % read on all subdomains
            for i=1:length(allProc)
                mask =  procs==allProc(i);
                % note proc are process number, starting counting at 0;
                % therefore +1
                tmp  =  Telemac.getData(sctTel(allProc(i)+1),timeSteps,locs(mask),varNr);
                % merge together
                data(:,mask) = tmp;
            end
        end
        
        function t = getTime(sctTel,timeSteps)
            % get times from a selafin file
            %
            %  t = getTime(sctTel,timeSteps)
            %
            % INPUT
            %    -   sctTel:    a structure array as produced by telheadr.m
            %    -   timeSteps (optional): a vector with timesteps to read.
            %    default = 1:NSTEPS
            %
            % OUTPUT
            %    - t: the time of timeSteps(i) (in seconds since the start of the model)
            

            % set defualt time steps
            if nargin ==1
                timeSteps = 1:sctTel.NSTEPS;
            end
            
            % check for file type, and assign automatically by looking for INDIC
            beginPos =  ftell(sctTel.fid);
            try sctTel.type;
                error('Only selafin files are supported');
            catch
                try sctTel.INDIC;
                    sctTel.type = 'leonard';
                catch
                    try sctTel.NELEM;
                        sctTel.type = 'seraphin';
                    catch
                        error('Structure array does not contain recognised data format')
                    end
                end
            end
            % preallocate
            nrT = length(timeSteps);
            t   = zeros(nrT,1);
            for i= 1:nrT
                % look up the right position
                fseek(sctTel.fid,sctTel.len1rec*(timeSteps(i)-1)+sctTel.startfpos,'bof');
                % get first 2D time start tag
                steptag = fread(sctTel.fid,1,'int32');
                if isempty(steptag)
                    error(['Timestep ',num2str(timeSteps(i)),' does not exist']);
                end
                % read time (in seconds)
                t(i) = fread(sctTel.fid,1,'float32');
            end
            % reset filepointer
            fseek(sctTel.fid,beginPos,'bof');
        end
        
        function ind = getTimeSteps(sctTel,timeLims)
            % get the time steps in the selafin file that need to be
            % processed
            %
            % ind = getTimeSteps(sctTel,timeLims)
            %
            % INPUT:
            %     - sctTel: the Telemac selafin data read with telheadr
            %     - timeLims: a NxM matrix with in the first column the
            %     start time and in the last column teh end time of ecah
            %     period to be considered
            %
            % OUTPUT:
            %   - ind: a Nx1 cell array with in each cell the time steps in
            %   the telemac model that fall inside the period delimited by
            %   timeLims
            %
            
            % read times in the telemac files
            timeSteps = 1:sctTel.NSTEPS;
            % convert to date time
            t       = Telemac.getTime(sctTel,timeSteps)./86400 + datenum(sctTel.IDATE);
            % preallocate
            nrTimes = length(timeLims);
            ind     = cell(nrTimes,1);
            % select timesteps for each period
            for i=1:nrTimes
                mask = (t>=timeLims{i}(1) & t<=timeLims{i}(end));
                ind{i} = find(mask);
            end
        end
        
        function interp3Dhotstart(oldFile,newFile,layers)
            % vertically interpolates a hotstart file in order to change
            % the number of layers (Telemac 3d only)
            %
            % interp3Dhotstart(oldFile,newFile,layers)
            %
            % INPUT:
            % -oldFile: the name of the original 3d hotstart file
            % -newFile: the name of the generated 3d hotstart file
            % -layers: vector with the sigma coordinates of the new layers.
            % The first must be 0 and the last must be 1.
            
            sct = telheadr(oldFile);
            sct = telstepr(sct,sct.NSTEPS);
            
            nrLayer =length(layers);
            
            
            % change IKLE and XYZ
            sctNew  = Telemac.convertTelemac2Dgrid(sct2D,nrLayer);
            
            % interpolate variables
            result = Telemac.interpTelZ(sct,[],layers);
            sctNew.RESULT = result;
            % write
            fid = telheadw(sctNew,newFile);
            fid = telstepw(sctNew,fid);
            fclose(fid);
        end
        
        
        function result = interpTelZ(sct,zInterp,layers)
            % interpolates telemac variables vertically
            %
            % result = interpTelZ(sct,zInterp)
            %
            % INPUT:
            % -sct: telemac structure from telhedr
            % - zInterp (): z values on the new mesh to interpolate to [NPOINxNPLAN]
            % - layers(optional): sigma values [NPLANx1] to which to interpolate; if used zInterp is ignored
            
            
            % change IKLE and XYZ
            sct2D   = Telemac.convertTelemac3Dgrid(sct);
            
            %get number of layers
            
            if nargin ==3
                nrLayer  = length(layers);
                useSigma = true;
            else
                nrLayer  = size(zInterp,2);
                useSigma = false;
            end
            
            
            % look for z coordinate
            indZ  = Telemac.findVar('ELEVATION Z',sct);
            z     = reshape(sct.RESULT(:,indZ),[sct2D.NPOIN,sct.NPLAN]);
            sigma = (z-z(:,1))./(z(:,end)-z(:,1));
            
            % interpolate vertically
            for iVar = sct.NBV:-1:1
                tmp  = reshape(sct.RESULT(:,iVar),[sct2D.NPOIN,sct.NPLAN]);
                if useSigma
                    for iLayer =nrLayer:-1:1
                        tmp2(:,iLayer) = Interpolate.interpMat1(sigma,tmp,layers(iLayer),true);
                    end
                else
                    for iLayer =nrLayer:-1:1
                        tmp2(:,iLayer) = Interpolate.interpMat1(z,tmp,zInterp(:,iLayer),true);
                    end
                end
                % set constant value for nans (typically because sigma
                % layer cannot interpolate
                
                for iLayer =nrLayer:-1:1
                    msk = isnan(tmp2(:,iLayer));
                    tmp2(msk,iLayer) = tmp(msk,1);
                end
                result(:,iVar) = tmp2(:);
                
            end
            % reset Z coordinates to specified values
            if ~useSigma
                result(:,indZ) =zInterp(:);
            end
            
        end
        
        
        function sctInterp = interpTriPrepare(sct,x,y,varargin)
            % wrapper aournd InterpTrainglePrepare
            %
            % sctInterp = Telemac.interpTriPrepare(sct,x,y,varargin)
            %
            switch length(varargin)
                
                case 0
                    sctInterp = Triangle.interpTrianglePrepare(sct.IKLE,sct.XYZ(:,1),sct.XYZ(:,2),x,y);
                case 1
                    sctInterp = Triangle.interpTrianglePrepare(sct.IKLE,sct.XYZ(:,1),sct.XYZ(:,2),x,y,varargin{1});
                case 2
                    sctInterp = Triangle.interpTrianglePrepare(sct.IKLE,sct.XYZ(:,1),sct.XYZ(:,2),x,y,varargin{1},varargin{2});
                otherwise
                    error('Wrong');
            end
        end
        
        function kml2i2s(inFile,outFile,lon0,lat0)
            % converts kml file to a i2s file (including coordinate
            % conversion
            %
            % kml2i2s(inFile,outFile,lon0,lat0)
            % INPUT:
            % -inFile: kml file to convert
            % -outFile (optional): i2s file to make
            % -lon0, lat0 (optional): i2s file to make
            
            sct = kml2struct(inFile);
            % process all lines
            for i = length(sct):-1:1
                if nargin > 2
                    [x,y] = Telemac.spherical2mercator(sct.Lon,sct.Lat,lon0,lat0);
                else
                    x = sct.Lon;
                    y = sct.Lat;
                end
                cDat{i}  = [x,y,i.*ones(size(x))];
            end
            % make file
            if nargin <2
                [path,file] = fileparts(inFile);
                outFile = fullfile(path,[file,'.i2s']);
            end
            % save data
            Telemac.writeKenue(outFile,cDat);
        end
        
        function makeHotstart(meshFile,previousDataFile,hotstartFile,indTime,zInterp)
            % make a hotstart using two selafin files
            %
            % makeHotstart(meshFile,previousDataFile,hotstartFile,indTime,zInterp)
            %
            % INPUT
            % - meshFile: file with the mesh of the new model
            % - previousDataFile: data file. the data on the last time step
            %                for variables are added to the hotstart file.
            %                can be 2D or 3D data. the result will then be
            %                2D or 3D.
            % - hotstartFile: name of the new file
            % - indTime (optional): specify time step to used for making hotstart
            % - zInterp (optional): [] specified z ccordinates for hotstart
            % file [NPOIN2xNPLAN]
            % 
            % OUTPUT
            %-
            
            % read mesh
            sctIn = telheadr(meshFile);
            sctIn = telstepr(sctIn,1);
            
            
            % read data (last timestep)
            sctData = telheadr(previousDataFile);
            
            if nargin > 4
               indTime = sctData.NSTEPS;               
            end
            
            sctData = telstepr(sctData,indTime);
            nrVar = sctData.NBV;
            nPlan = sctData.NPLAN;
            
            % prepare output
            sctOut2D = sctIn;
            sctOut2D.NSTEPS = 1;
            sctOut2D.NBV    = nrVar;
            sctOut2D.RECV   = sctData.RECV;
            sctOut2D.RESULT = zeros(sctIn.NPOIN,nrVar);
            sctOut2D.IDATE = sctData.IDATE;
            sctOut2D.IPARAM(10) = sctData.IPARAM(10);
            
            % 2D data file
            if nPlan == 1
                sctInterp = Triangle.interpTrianglePrepare(sctData.IKLE,sctData.XYZ(:,1),sctData.XYZ(:,2),sctOut2D.XYZ(:,1),sctOut2D.XYZ(:,2));                
                for i=1:sctOut2D.NBV
                    sctOut2D.RESULT(:,i) =  Triangle.interpTriangle(sctInterp,sctData.RESULT(:,i));    
                end
                sctOut = sctOut2D;
            else
                sctOut  = Telemac.convertTelemac2Dgrid(sctOut2D,nPlan);
                % horizontal interpolation for all layers
                sctData2D  = Telemac.convertTelemac3Dgrid(sctData);
                sctInterp = Triangle.interpTrianglePrepare(sctData2D.IKLE,sctData2D.XYZ(:,1),sctData2D.XYZ(:,2),sctOut2D.XYZ(:,1),sctOut2D.XYZ(:,2),true,true);
                sctOut.RESULT = [];
                % 3D data file
                nP = sctData.NPOIN/nPlan;
                for i=1:sctOut.NBV
                    tmp  = reshape(sctData.RESULT(:,i),nP,nPlan);
                    tmp2 =  Triangle.interpTriangle(sctInterp,tmp);    
                    sctOut.RESULT(:,i) = tmp2(:);
                end
            
            
                % vertical interpolation
                if nargin  == 5
                    nPlan  = size(zInterp,2);
                    result = Telemac.interpTelZ(sctOut,zInterp);
                    sctOut = Telemac.convertTelemac2Dgrid(sctOut2D,nPlan);
                    sctOut.RESULT = result;
                end
            end
            % check for nans
            if any(isnan(sctOut.RESULT(:)))
                error('NaN is  hotstart file. TELEMAC will crash.');
            end
            
            % save data file
            fid = telheadw(sctOut,hotstartFile);
            fid = telstepw(sctOut,fid);
            fclose(fid);
            
        end
        
        function [ikle,xyz] = makePeriodic(ikle,xyz,leftObc,rightObc)
            % makes a mesh periodic
            %
            % ikle = makePeriodic(ikle,xyz,leftObc,rightObc)
            % INPUT
            % - ikle: connection table
            % - xyz: coordinates of the points
            % - leftObc: list with node numbers of the boundary points that
            % are to be connected
            % - rightObc: list (same size and order as rightObc) with node
            % numbers of boundary points on the opposite side, that are to
            % be connected with the the points in leftObc
            
            % OUTPUT
            % - ikle: updated connection table
            % - xyz: updated list with coordinates of the points
            
            
            nrObc = length(leftObc);
            
            % check input
            if nrObc ~= length(rightObc)
                error('leftObc and rightObc must have the same number of elements');
            end
            
            if ~isempty(intersect(leftObc,rightObc))
                error('leftObc and rightObc cannot have the same node');
            end
            
            % look up right elements and replace them in the structure
            for i = 1:nrObc
                mask = ikle==rightObc(i);
                ikle(mask) = leftObc(i);
            end
            
            % delete unused points
            [ikle,xyz] = Triangle.deletePoints(ikle,xyz,rightObc);
            
        end
        
        function sct = makeSct(ikle,xy,z,varNames,time,title,nPlan)
            % make a telehadr structure from a mesh with data
            %
            % sct = Telemac.makeSct(ikle,xy,z,varNames)
            %
            % INPUT
            % - ikle, xy: mesh information (column oriented)
            % - z: variable data (column oriented)
            % - varNames: cell awrray with najmes of the variables
            % - time(optional): matlab time format
            % - title(optional): string with the title
            % - nPlan(optional): number of layers (default = 1)
            

            % error checking
            if size(xy,2)~=2
                error('wrong number of elemnts in xy');
            end
            if length(varNames)~=size(z,2)
                error('Wrong number of variables in z');
            end
            if size(xy,1)~=size(z,1)
                error('Wrong length of z');
            end
            
            % make counter clockiwise elemnts
            ikle = Triangle.makeCcw(ikle,xy);
            sct.type = 'seraphin';
            % file in all fields
            if nargin >5
            sct.title = title;
            else
                sct.title = '';
            end
            % variables
            sct.NBV     = length(varNames);
            sct.RESULT  = z;
            sct.RECV    = varNames;
            % mesh
            sct.NELEM = size(ikle,1);
            sct.NPOIN = size(xy,1);
            sct.NDP= size(ikle,2);
            sct.IKLE =ikle;
            sct.XYZ = xy;
            % boundary
            outLine = Telemac.getBoundary(sct,false);
            sct.IPOBO = zeros(sct.NPOIN,1);
            sct.IPOBO(outLine) = outLine;
            
            % time
            sct.NSTEPS = 1;
            sct.DT = 0;
            sct.AT = 0;

            % parameters
            sct.IPARAM = zeros(10,1);
            sct.IPARAM(1) = 1;
            sct.IPARAM(8) = sum(sct.IPOBO>0); % number of boundary points
            if nargin>4
                sct.IPARAM(10) = 1;
                sct.IDATE = datevec(time);
            else
                sct.IPARAM(10) = 0;
                sct.IDATE = [];
            end
            % vertical
            if nargin >5
                sct.NPLAN = nPlan;
            else
                sct.NPLAN = 1;
            end
            if sct.NPLAN>1
                sct.IPARAM(7) = sct.NPLAN;
            else
                sct.IPARAM(7) = 0;
            end
        
          
        
 
            
            
        end
        
        function [long,lat] = mercator2spherical(gridMercX,gridMercY,long0,lat0)
            % Convert  Mercator for Telemac coordinates to spherical (from readgeo.f)
            % [long,lat] = mercator2spherical(gridMercX,gridMercY,long0,lat0);
            % Input:
            % gridMercX: Grid X data in Mercator for Telemac projection
            % gridMercY: Grid Y data in Mercator for Telemac projection
            % long0:  Longitude of origin (in decimal degrees)
            % lat0: Latitude of origin (in decimal degrees)
            % Output:
            % long: Longitude (in decimal degrees)
            % lat: Latitude (in decimal degrees)
            
            R = 6.37e6; %Earth radius according to Telemac
            
            long = gridMercX/R*180/pi + long0;
            lat = (2*atan(exp(gridMercY/R)*tan(0.5*lat0*pi/180+pi/4))- pi/2)*180/pi;
            
        end
        
        function xyTarget = convertCoor(xySource,sctCoor)
            % performs coordinatestranforms between any coordinate system,
            % including telemac mercator projectiobn
            %
            % xyTarget = convertCoor(xySource,sctCoor)
            %
            % INPUT:
            % - xySource: [Mx2] matrix with x and y coordinates of the input data
            %  - sctCoor: structure with informations of coordinate
            %  transforms., with the fields:
            %  -- sourceLonLat: lon0 and lat0 coordinate for mercator to
            %  telemac conversion of mother model (in case in MerForTel
            %  format)
            %  -- targetLonLat: lon0 and lat0 coordinate for mercator to
            %  telemac conversion of mother model (in case in MerForTel
            %  format)
            %  -- sourceCs: CS1  code of the mother model
            %  -- targetCs: CS1  code of the mother model
            %  -- targetShift: 2x1 vector with shift (x and y)
            %  -- sourceShift: 2x1 vector with shift (x and y)
            % INPORTANT, you can only uise one of the two possible options
            % for the source and the target
            %
            % OUTPUT:
            % - xyTarget: [Mx2] matrix with x and y coordinates of the converteddata
            
            addOpenEarth;
            % check input; only one possible
            
            if ~isfield(sctCoor,'sourceLonLat') && ~isfield(sctCoor,'sourceCs')
                error('No coordinate information for source');
            end
            if ~isfield(sctCoor,'targetLonLat') && ~isfield(sctCoor,'targetCs')
                error('No coordinate information for target');
            end
            if isfield(sctCoor,'targetLonLat') && isfield(sctCoor,'targetCs')
                error('Too much information for target');
            end
            if isfield(sctCoor,'sourceLonLat') && isfield(sctCoor,'sourceCs')
                error('No coordinate information for source');
            end

            if isfield(sctCoor,'sourceShift')
                xySource(:,1) = xySource(:,1) + sctCoor.sourceShift(1);
                xySource(:,2) = xySource(:,2) + sctCoor.sourceShift(2);
            end
            
            
            % convert source data to spherical coordinates
            if isfield(sctCoor,'sourceLonLat')
                lon0 = sctCoor.sourceLonLat(1);
                lat0 = sctCoor.sourceLonLat(2);
                [tmpX,tmpY] = Telemac.mercator2spherical(xySource(:,1),xySource(:,2),lon0,lat0);
            elseif isfield(sctCoor,'sourceCs')
                [tmpX,tmpY] = convertCoordinates(xySource(:,1),xySource(:,2),'CS1.code',sctCoor.sourceCs,'CS2.code',4326);                
            else
                tmpX = xySource(:,1);
                tmpY = xySource(:,2);
            end
            % convert data back to the requiered coordinate system
            if isfield(sctCoor,'targetLonLat')
                lon0 = sctCoor.targetLonLat(1);
                lat0 = sctCoor.targetLonLat(2);
                [tmp2X,tmp2Y] = Telemac.spherical2mercator(tmpX,tmpY,lon0,lat0);
            elseif isfield(sctCoor,'targetCs')
                [tmp2X,tmp2Y]=convertCoordinates(tmpX,tmpY,'CS1.code',4326,'CS2.code',sctCoor.targetCs);
            else
                tmp2X = tmpX;
                tmp2Y = tmpY;
            end
            
            xyTarget(:,1) = tmp2X;
            xyTarget(:,2) = tmp2Y;
            if isfield(sctCoor,'targetShift')
                xyTarget(:,1) = xyTarget(:,1) + sctCoor.targetShift(1);
                xyTarget(:,2) = xyTarget(:,2) + sctCoor.targetShift(2);
            end            

        end
            
        
        function [nodes,xys] = nestingPoints(slfNew,cliNew,startTime,endTime,timeStep,coordFile,nestSelf,sctCoor,boundaryName)
            % writes coordinates.txt file for nesting points and grabs node
            % files
            %
            % [nodes,xys] = Telemac.nestingPoints(slfNew,cliNew,startTime,endTime,timeStep,coordFile,nestSelf,sctCoor,boundaryName);
            %
            % Port of convertToBND.py
            % INPUT:
            %  - slfNew: selafin file of new mesh
            %  - cliNew: cli file of new boundary
            %  - startTime: start time to write to coordinate.txt
            %  - endTime: end time to write to coordinate.txt
            %  - timeStep: timestep to write to coordinate.txt
            %  - coordFile: location of coordinate.txt. Leave empty if you don't want to write a coordinates.txt file
            %  - nestSelf (boolean): If you nest a model in itself, script
            %  will shift the coordinate locations slightly inward so that
            %  they are certainly in the mesh
            %  - sctCoor: structure with informations of coordinate
            %  transforms., with the fields:
            %  -- sourceLonLat: lon0 and lat0 coordinate for mercator to
            %  telemac conversion of DAUGHTER model (in case in MerForTel
            %  format)
            %  -- targetLonLat: lon0 and lat0 coordinate for mercator to
            %  telemac conversion of MOTHER model (in case in MerForTel
            %  format)
            %  -- sourceCs: CS1  code of the DAUGHTER model
            %  -- targetCs: CS1  code of the MOTHER model
            % INPORTANT, you can only uise one of the two possible options
            % for the source and the target
            % - boundaryName: name of the boundary to apply nesting to 
            % 
            % OUTPUT:
            %  - nodes: Node numbers
            %  - xys: XY locations of node numbers
            
            
            if nargin<=2
                startTime = 0;
            end
            if nargin <=3
                endTime = 3600;
            end
            if nargin <=4
                timeStep = 3600;
            end
            if nargin <= 5
                coordFile = '';
            end
            if nargin <=6
                nestSelf = false;
            end
            if nargin <= 7
                sctCoor = [];
            end
            if nargin <= 8
            boundaryName = '';
            end
            
            if ~isempty(boundaryName)
                cli = Telemac.readCli(cliNew,boundaryName);
            else
                cli = Telemac.readCli(cliNew);
            end
            %Select only open boundary points (not wall points)
            openBoundMask = ~(cli(:,1) == 2 & ...
                cli(:,2) == 2 & cli(:,3) == 2 & cli(:,8) == 2);
            if ~isempty(boundaryName)
                openBoundMask=openBoundMask&cli(:,14);
            end
            nodes = cli(openBoundMask,12);
            
            % Find corresponding (x,y) in corresponding new mesh
            [ds,geo,varNames] = Telemac.readTelemacHeader(slfNew);
            [ds,geo] = Telemac.readTelemacData(ds,geo,varNames);
            xys = geo.XYZ(nodes,:);
            
            % apply coordinate transformt
            if ~isempty(sctCoor)
                xys = Telemac.convertCoor(xys,sctCoor);
            end            
            
            % change xy values when nesting to itself
            if nestSelf
                xys2 = xys;
                for i = 1:numel(nodes)
                    node = nodes(i);
                    mask = any(geo.IKLE == node,2);
                    for j = 1:2
                        xys2(i,j) = mean(geo.XYZ(geo.IKLE(mask,:),j));
                    end
                end
                frac = 1e-4;
                xys = frac*xys2 + (1-frac) * xys;
            end
            
            % write the coordinate file
            if ~isempty(coordFile)
                theTime  = [startTime endTime timeStep];
                nodes    = Util.makeColVec(nodes);
                for i=length(nodes):-1:1
                    statName{i} = num2str(nodes(i),'Bound%.0f');
                end
                Telemac.writeCoordinateFile(coordFile,statName,xys(:,1),xys(:,2),nodes,theTime);
                % also write blueKenue file so you can check the nesting
                coordFileKenue = strrep(coordFile,'.txt','.xyz');
                Telemac.writeKenue(coordFileKenue,{[xys(:,1:2),nodes]});
            end
            
        end
        
        function writeCoordinateFile(outFile,statName,x,y,nodes,theTime)
            % write coordinate.txt
            %
            % writeCoordinateFile(outFile,statName,x,y,nodes,theTime)
            %
            startTime = theTime(:,1);
            endTime   = theTime(:,2);
            timeStep  = theTime(:,3);
            nrT = length(startTime);
            nrX = length(x);
            fid = fopen(outFile,'w+');
            fprintf(fid,'%u %u\n',1,nrX);
            for  i=1:nrT
                fprintf(fid,'%.0f %.f %.0f\n',startTime(i),endTime(i),timeStep(i));
            end
            for  i=1:nrX
                fprintf(fid,'%8.2f\t%8.2f\t%u\t %s\n',x(i), y(i),nodes(i), statName{i});
            end
            fclose(fid);
        end
        
        function [nodes,xys] = nestingPointsWaves(slfNew,cliNew,coordFile)
            % writes a file with the coordinates of the open boundary for a
            % TOMAWAC model with spectral input.
            
            [nodes,xys] = Telemac.nestingPoints(slfNew,cliNew);
            
            if ~isempty(coordFile)
                fid = fopen(coordFile,'w+');
                fprintf(fid,'%u %u\n',1,size(xys,1));
                fprintf(fid,'%u %16.14e %16.14e %16.14e\n', [nodes(:) xys(:,1) xys(:,2) zeros(size(nodes))]');
                fclose(fid);
            end
        end
        
        function nestingFileWrite(dataFolder,outFile,tStartStop,tracerNames, tracerDefaultVals, tideCorr, is3D,meshFile,sctOpt)
            % make a nesting file form netcdf files of a previous runs
            %
            % nestingFileWrite(dataFolder,outFile,tStartStop,tracerNames,tracerDefaultVals,tideCorr,is3D,meshFile)
            %
            % INPUT
            % - dataFolder : path with ncfiel. it is assumed than only
            % 'OUTPUT_002' files are used
            % - outFile,
            % - tStartStop (optional): start time of the daughter model in
            % seconds since start of the mother model.
            % Alteratively a 3x1 vector can be used with starttime, endtime
            % and time interval (all in seconds) e.g. [0 86400 600];
            % - tracerNames (optional): cell array with the TELEMAC names
            % of the tracers to read; set to {} to ignore.
            % - tracerDefaultVals(optional): array with thedefault values
            % of the tracers
            % - tideCorr (optional): structure with data to do tidal
            % correction (ttide) with fields:
            %      tideCorr.comp: cell array with name of components
            %      tideCorr.phaseShift: array with change in phase for each
            %      component
            %      tideCorr.ampShift: array with change iin amplitude for
            %      echa component
            %      tideCorr.useVel: if 1: pahse shift is also applied to
            %      velocities
            % - is3d (optional): logical: if true, a three dimensional
            % boundary condition file is written (in .slf format); 
            % default= false
            % - meshFile: path of the mesh of the daughtermodel. Needed if is3d = true;
            % - sctOpt: structure with options with the fields
            % -- sctOpt.shiftWl: shift to convert vertical water level
            % reference
            % --sctOpt.isQ: if true. discharge values (u*H are written and
            % used)
            % --sctOpt.meshMother: needed if isQ; mesh of the mother model
            % --sctOpt.minU: minumum velocity threshold; outliers are deleted
            % and interpolated
            % --sctOpt.maxU: maximum velocity threshold; outliers are deleted
            % and interpolated
            % --sctOpt.minH: minumum water level threshold; outliers are deleted
            % and interpolated
            % --sctOpt.maxH: maximum water level threshold; outliers are deleted
            % and interpolated
            
            
            
            % default no tracers
            if nargin <7
                is3D = false;
            end
            if is3D
                mode = '3D';
            else
                mode = '2D';
            end
            if nargin <4
                tracerNames = {};
            end
            if nargin < 6
                tideCorr = false;
            end
            if nargin < 9
                sctOpt = struct;
            end
            sctOpt = Util.setDefault(sctOpt,'isQ',false);
            sctOpt = Util.setDefault(sctOpt,'minH',-15);
            sctOpt = Util.setDefault(sctOpt,'maxH',15);
            if sctOpt.isQ
                sctOpt = Util.setDefault(sctOpt,'minU',-1500);
                sctOpt = Util.setDefault(sctOpt,'maxU',1500);            
            else
                sctOpt = Util.setDefault(sctOpt,'minU',-15);
                sctOpt = Util.setDefault(sctOpt,'maxU',15);            
            end
                
            
            if ~exist(dataFolder,'dir')
                error(['The directory ',dataFolder, ' does not exist']);
            end
            
            % find node numbers in files
            if isfolder(dataFolder)
                dataFolder = fullfile(dataFolder,'OUTPUT_002_*.nc');
            end
            ncFile = dir(dataFolder);
            nrFiles = length(ncFile);
            nodes = zeros(nrFiles,1);
            xy    = zeros(nrFiles,2);
            for i=1:nrFiles
                theNcFile = fullfile(ncFile(i).folder,ncFile(i).name);
                nodes(i) = ncread(theNcFile,'station_id');
                xy(i,1)  = ncread(theNcFile,'x');
                xy(i,2)  = ncread(theNcFile,'y');
            end
            %dataFolder = dataFolder(1:end-4);
            
            
            
            % read and write scripts
            [t,h,u,v,trac,startDate,tracFound] = Telemac.readNestingNetCDF(dataFolder,nodes,tracerNames,mode);
            
            % apply corrections %TODO: tracer correction
            mask = u<sctOpt.minU | u>sctOpt.maxU; 
            if any(mask(:))
                warning('Outliers found in the velocities. Correcting boundary conditions');
                u(mask) = nan;
                u = Interpolate.interpNan(u);
            end

            mask = v<sctOpt.minU | v>sctOpt.maxU; 
            if any(mask(:))
                warning('Outliers found in the velocities. Correcting boundary conditions');
                v(mask) = nan;
                v = Interpolate.interpNan(v);
            end
            
            mask = h<sctOpt.minH | h>sctOpt.maxH; 
            if any(mask(:))
                warning('Outliers found in the water levels. Correcting boundary conditions');
                h(mask) = nan;
                h = Interpolate.interpNan(h);
            end
            
            % convert time
            if nargin < 3
                tStart = t(1);
                t = (t-tStart);
            else
                if length(tStartStop)==3
                    tStart  = tStartStop(1);
                    tEnd    = tStartStop(2);
                    tInt    = tStartStop(3);
                    dt      = median(diff(t));
                    tStride = round(tInt/dt);
                    if tStride<1
                        error ('Wrong time interval is used');
                    end
                else
                    tStart  = tStartStop(1);
                    tEnd    = max(t);
                    tStride = 1;
                end
                t0 = find(t>=tStart,1,'first');
                t1 = find(t<=tEnd  ,1,'last');
                mask = t0:tStride:t1;
                t    = (t-tStart);
                t = t(mask);
                h = h(mask,:,:);
                u = u(mask,:,:);
                v = v(mask,:,:);
                if ~isempty(trac)
                    trac = trac(mask,:,:,:);
                end
            end
            
            %apply tide correction
            if tideCorr
                tmp = zeros(size(tideCorr.phaseShift));
                tideCorr = Util.setDefault(tideCorr,'useVel',false);
                tideCorr = Util.setDefault(tideCorr,'ampShift',tmp);
                tDay = startDate+(t+tStart)/86400;
                if ~isfield(tideCorr,'ampShift')
                    tideCorr.ampShift = zeros(size( tideCorr.phaseShift));
                end
                nrP  = size(h,2);
                for iP = 1:nrP
                    h(:,iP) =  TidalAnalysis.adaptTide(tDay,h(:,iP),tideCorr.comp, tideCorr.phaseShift, tideCorr.ampShift);
                end
                if (tideCorr.useVel)
                    for iP = 1:nrP
                        u(:,iP) =  TidalAnalysis.adaptTide(tDay,u(:,iP),tideCorr.comp, tideCorr.phaseShift, tmp);
                        v(:,iP) =  TidalAnalysis.adaptTide(tDay,v(:,iP),tideCorr.comp, tideCorr.phaseShift, tmp);
                    end
                end
            end
            
            % determine discharges from mother model
            if sctOpt.isQ
                % determine water depth
                sctMot = telheadr(sctOpt.meshMother);
                indH   = Telemac.findVar('BOTTOM',sctMot);
                sctInt = Triangle.interpTrianglePrepare(sctMot.IKLE,sctMot.XYZ(:,1),sctMot.XYZ(:,2),xy(:,1),xy(:,2));
                H = h - Triangle.interpTriangle(sctInt,sctMot.RESULT(:,indH))';
                % determine discharge
                u = u.*H;
                v = v.*H;
            end
            
            % apply optional corrections
            if isfield (sctOpt,'shiftWl')
                h = h + sctOpt.shiftWl;
            end
            
            
            % add default tracer values
            if nargin>4
                if length(tracerDefaultVals)~=length(tracFound)
                    error('Wrong dimension of tracerDefaultVals');
                end
                tmp = ones([size(u),length(tracerDefaultVals)]);
                if length(size(trac))==4
                    % 3d data
                    for i=1:length(tracerDefaultVals)
                        if ~tracFound(i)
                            trac(:,:,:,i) = tmp(:,:,:,i).*tracerDefaultVals(i);
                        end
                    end
                else
                    % 2d data
                    for i=1:length(tracerDefaultVals)
                        if ~tracFound(i)
                            trac(:,:,i) = tmp(:,:,i).*tracerDefaultVals(i);
                        end
                    end
                end
            end
            
            % convert
            if is3D
                tFirst = startDate+tStart/86400;
                Telemac.writeBinaryBnd(outFile,nodes,t,h,u,v,trac,tracerNames,meshFile,tFirst);
            else
                if ~isempty(trac)
                    Telemac.writeNesting(outFile,nodes,t,h,u,v,trac,sctOpt.isQ);
                else
                    Telemac.writeNesting(outFile,nodes,t,h,u,v,[],sctOpt.isQ);
                end
            end
            
            %
            
        end
        
        function openI2s(fileIn,doOpen)
            % this file opens or closes all
            % Telemac.openI2s(fileIn,doOpen)
            % INPUT: fileIn: filename of i2s file
            %        doOpen: boolian: true to open all files, false to close
            % OUTPUT: new file with the name of fileIn but with _new added
            
            DIST_MAX = 0.01;
            % read data
            cLine = Telemac.readKenue(fileIn);
            
            % open or close all lines
            cLine2 = cLine;
            for i =1:length(cLine)
                line = cLine{i};
                d = abs(line(1,1)-line(end,1))+abs(line(1,2)-line(end,2));
                % delete end point
                if d < DIST_MAX && doOpen
                    cLine2{i} = line(1:end-1,:);
                end
                % add being point
                if d > DIST_MAX && ~doOpen
                    cLine2{i} = [line(1:end,:);line(1,:)];
                end
            end
            
            % save data
            fileOut = [fileIn(1:end-4),'_new.i2s'];
            Telemac.writeKenue(fileOut,cLine2);
        end
        
        function [cliData,boundaryNameOut] = readCli(theFile,boundaryNameIn)
            % This function reads Telemac boundary files (.cli)
            % [cliData,boundaryNameOut] = Telemac.readCli(theFile,boundaryNameIn)
            %
            % Input:
            % - theFile: cli file to be read
            % - boundaryNameIn (optional): a string with the name of the boundary that is
            % searched for
            %
            % Output:
            % - cliData: matrix with data (Nx14) from cli file. Last column is boolean,
            % indicating that the string boundaryNameIn was found in the boundary name in the
            % cli file
            %
            % - boundaryNameOut: Cell array of boundary names
            %
            %
            
            if nargin ==1
                boundaryNameIn =  'Boundary';
            end
            fid = fopen(theFile);
            theFormat = [repmat('%f ',1,13),'%s %s %s %s %s'];
            cellData = textscan(fid,theFormat);
            fclose(fid);
            cliData = cell2mat(cellData(1:13));
            theMask = ~cellfun('isempty',(strfind(cellData{15}',boundaryNameIn)));
            
            boundaryNameOut = cellData{15};
            
            cliData = [cliData,theMask'];
        end
        
        function data = readFloat(theFile)
        % reads data from a Telemac tracer file
        %
        % data = readFloat(theFile)
        %
        % INPUT:
        % -theFile: filename of the tracer file
        %
        % OUTPUT:
        %
        % data: a structure with for each time step the field
        % - t: time in sectonds since the start of the model
        % - x and y: x and y coordinatess of the particles
        % - c: the colour of the particle. no idea what that means.
        
        VERY_HIGH = 10000;
        % open file
            fid = fopen(theFile);
            % read header
            head = fgetl(fid);
            head = fgetl(fid);
            n = 0;
            goOn = true;
            % preaallocate data
            sct.t = [];
            sct.x = [];
            sct.y = [];
            sct.c = [];
            data(VERY_HIGH) = sct;
            while goOn
                % read time and number of particles
                head = fgetl(fid);
                if ischar(head)
                    n = n+1;
                    %extract data from string
                    tmp  = regexp(head,'[\d.]*','match');
                    t    = str2double(tmp{3});
                    numPart = str2double(tmp{2});
                    % read xy coordinates
                    tmp = textscan(fid,'%f %f %f %f ',numPart,'delimiter',',');
                    % add data to struct
                    sct.t = t;
                    sct.x = tmp{2};
                    sct.y = tmp{3};
                    sct.c = tmp{4};
                    % add to structure
                    data(n) = sct;
                    
                    % read last line separator
                    head = fgetl(fid);
                else
                    % end of file reached
                    goOn = false;
                end
            end
            % delete repallocated data
            if n< VERY_HIGH
                data(n+1:end) = [];
            end
            
        end
        
        function [] = writeCli(theFile,cliData,boundaryNameIn)
            % This function reads Telemac boundary files (.cli)
            % [] = Telemac.writeCli(theFile,cliData,boundaryNameIn)
            %
            % INPUT:
            % - cliData: matrix with data (Nx13) from cli file. 
            %
            % - boundaryNameOut: Cell array of boundary names
            %
            % OUTPUT:
            %
            
            if size(cliData,2)>13
               cliData(:,14:end)= [];
            end
            
            cellData = mat2cell(cliData,...
                repmat(1,size(cliData,1),1),repmat(1,size(cliData,2),1));
            cellData = [cellData repmat({'#'},size(cellData,1),1) boundaryNameIn]';
            fid = fopen(theFile,'w+');
            theFormat = [repmat('%i ',1,3) repmat('%.4f ',1,4),'%i ', repmat('%.4f ',1,3), repmat('%i ',1,2) '%s %s \n'];
            fprintf(fid,theFormat,cellData{:});
            fclose(fid);
            
        end
        
        
        function theData = readKenue(theFile)
            % reads Bluekenue files (i2s: line files and xyz point files)
            %
            % theData = Telemac.readKenue(theFile);
            %
            % INPUT: theFile: is a filename
            % OUTPUT: theData: a cell array with the data. One cell for
            % each line.
            %
            
            % determine file tyope
            [~,~,theType] = fileparts(theFile);
            
            bNrData = false;
            nrData = nan;
            
            switch (strtrim(theType))
                case '.i2s'
                    nrCol = 2;
                    bNrData = true;
                case '.xyz'
                    nrCol = 3;
                case '.ts1'
                    nrCol = 1;
                case '.ts2'
                    nrCol = 2;
                otherwise
                    error('Unknown file type');
            end
            % open file
            fid = fopen(theFile);
            if fid<0
                error([theFile,  ' does not exist'])
            end
            bGo = 1;
            % look for the end of the header file
            while bGo
                theLine = fgetl(fid);
                if ~isempty(strfind(theLine,':EndHeader'))
                    bGo = 0;
                    theLine = fgetl(fid);
                    % use information
                    if nrCol ==2 && bNrData % for .i2s files (.t2s has 2 columns but no header data)
                        %cellData = textscan(theLine,'%f %f');
                        cellDataTmp = str2num(theLine); %#ok<ST2NM>
                        if isempty(cellDataTmp)
                            cellDataTmp = textscan(theLine,'%f *');
                            cellDataTmp = cellDataTmp{1};
                        end
                        if isstring(cellDataTmp)
                            for iC = 1:length(cellDataTmp)
                                cellData(iC) = str2double(cellDataTmp{iC});
                            end
                        else
                            cellData = cellDataTmp;
                        end
                        if  length(cellData)>=2
                            theValue = cellData(2:end)';
                        else
                            theValue = nan;
                        end
                        nrData = cellData(1);
                    else
                        nrData=nan;
                    end
                end
                % end of file; appararently, there is no header
                if theLine==-1
                    bGo = 0;
                    fseek(fid,0,-1);
                    nrData = nan;
                end
            end
            % read the data
            if ~isnan(nrData)
                i = 1;
                bGo = true;
                while  bGo
                    cellData = textscan(fid,repmat('%f ',1,nrCol),nrData);
                    theData{i} = cell2mat(cellData);
                    if nrCol ==2
                        theData{i}(:,3:2+length(theValue)) = repmat(theValue',nrData,1);
                    end
                    i = i+1;
                    fgetl(fid);
                    theLine = fgetl(fid);
                    if theLine==-1
                        bGo = 0;
                    else
                        temp1 = cell2mat(textscan(theLine,'%f'));
                        nrData = temp1(1);
                        theValue = temp1(2:end);
                    end
                    
                end
            else
                % read only once (for .xyz files, .ts1 files and .ts2 files)
                cellData = textscan(fid,repmat('%f ',1,nrCol));
                % quick hack to alsoo read .xyz files
                if isempty(cellData{2})
                    cellData = textscan(fid,repmat('%f ',1,nrCol),'delimiter',',');
                end
                if ischar(theLine)
                    lineData = str2num(theLine);
                    theData{1}  = [lineData;cell2mat(cellData)];
                else
                    theData{1}  = cell2mat(cellData);
                end
            end
            
            
            fclose(fid);
        end
        
        function [t,h,u,v,trac,nodes] = readNesting(theFile,numTrac)
            % reads an IMDC format Telemac Nesting file
            %
            %  [t,h,u,v,trac,nodes] = readNesting(theFile,numTrac)
            %
            % INPUT:
            %   - theFile: filename of the nesting file
            %   - numTrac: the number of tracers in the file(optional)
            %
            % OUTPUT:
            %   -t  :  the time (in seconds since the start of the model)
            %   -h  : water level [nrTime x nr Nodes]
            %   -u  : x velocity  [nrTime x nr Nodes]
            %   -v  : y velocity  [nrTime x nr Nodes]
            %   -trac : tracers   [nrTime x nr Nodes x nrTracers]
            %
            if nargin==1
                numTrac =0;
            end
            
            fid = fopen(theFile);
            MAXVAL = 500000;
            showProgress = false;
            headr = fgets(fid);
            numPoint = fscanf(fid,'%f',1);
            nodes = fscanf(fid,'%f',numPoint);
            % preallocate
            t = zeros(MAXVAL,1);
            h = zeros(MAXVAL,numPoint);
            u = zeros(MAXVAL,numPoint);
            v = zeros(MAXVAL,numPoint);
            
            trac = zeros(MAXVAL,numPoint,numTrac);
            
            
            i = 1;
            while 1
                try
                    t(i)   = fscanf(fid,'%f',1);
                    h(i,:) = fscanf(fid,'%f',numPoint);
                    u(i,:) = fscanf(fid,'%f',numPoint);
                    v(i,:) = fscanf(fid,'%f',numPoint);
                    for iTrac =1:numTrac
                        trac(i,:,iTrac) = fscanf(fid,'%f',numPoint);
                    end
                    i = i+1;
                catch
                    break
                end
                if i> MAXVAL
                    error('File to big. Change MAXVAL in the code.');
                end
                
                if showProgress && mod(i,1000)==0
                    disp(num2str(i,'reading line %f'));
                end
            end
            fclose(fid);
            % delete empty data
            if i<=MAXVAL
                t(i:end)= [];
                h(i:end,:)= [];
                u(i:end,:)= [];
                v(i:end,:)= [];
                if numTrac >0
                    trac(i:end,:,:)= [];
                end
            end
        end
        
        function [t,h,u,v,trac,startDate,tracFound] = readNestingNetCDF(dataFolder,nodes,tracers,mode,varargin)
            % Read nesting data from NetCDFs
            %
            % [t,h,u,v,trac,nodes,startDate] = readNestingNetCDF(dataFolder,nodes,tracers,mode)
            %
            % INPUT:
            % - dataFolder: Folder where nesting netCDFs are located
            %
            % - nodes: node number of files to nest
            % - tracers: cell array with the names of the tracers
            % - mode (optional): 2D or 3D
            %
            % OUTPUT:
            % - t,h,u,v,trac: arrays with the read variables from the
            %      Netcdf file
            % - startDate: startDate of the simuation
            % - tracFound: logical arrays with the size of tracers,
            %      specifying whether this rtacre is found
            %
            
            tracFound = false(size(tracers));
            
            p = inputParser;
            addOptional(p,'tracers',{});
            addOptional(p,'mode',nan);
            addParameter(p,'waitbar',false);
            parse(p,varargin{:});
            
            nNodes = numel(nodes);
            %Pr
            % First node
            ix = nodes(1);
            if ~isdir(dataFolder)
                [dataFolder,fileStart] = fileparts(dataFolder);
            else
                fileStart = '';
            end
            ncFile = dir(fullfile(dataFolder,[fileStart,sprintf('%06u.nc',ix)]));
            ncReadFile = fullfile(ncFile(1).folder,ncFile(1).name);
            t = ncread(ncReadFile,'time');
            % get start date
            tmp = ncreadatt(ncReadFile,'time','units');
            tmp = regexp(tmp,'\d*','match');
            tmp = cellfun(@str2double,tmp);
            startDate  = datenum(tmp);
            nt = numel(t);
            meta = ncinfo(ncReadFile);
            
            if isnan(mode)
                %Default mode
                if any(ismember({meta.Variables.Name},'ELEVATION_Z_3D'))
                    mode = '3D';
                else
                    mode = '2D';
                end
            end
            % preallocate
            if strcmpi(mode,'3D')
                tmp = ncread(fullfile(ncReadFile),'ELEVATION_Z_3D');
                h    = nan(size(tmp,3),size(tmp,1),numel(nodes));
                u    = nan(size(tmp,3),size(tmp,1),numel(nodes));
                v    = nan(size(tmp,3),size(tmp,1),numel(nodes));
                trac = nan(size(tmp,3),size(tmp,1),numel(nodes),numel(tracers));
            elseif strcmpi(mode,'2D')
                h    = nan(numel(t),numel(nodes));
                u    = nan(numel(t),numel(nodes));
                v    = nan(numel(t),numel(nodes));
                trac = nan(numel(t),numel(nodes),numel(tracers));
            end
            
            if p.Results.waitbar
                hb=waitbar(0,sprintf('Loading file %i of %i.',0,nNodes));
            end
            % read netcdf files
            for ix = 1:numel(nodes)
                if p.Results.waitbar
                    waitbar(ix/nNodes,hb,sprintf('Loading file %i of %i.',ix,nNodes));
                end
                
                ncFile = dir(fullfile(dataFolder,[fileStart,sprintf('%06u.nc',nodes(ix))]));
                theFile = fullfile(ncFile(1).folder,ncFile(1).name);
                switch mode
                    case '2D'
                        tmp = squeeze(ncread(theFile,'FREE_SURFACE_2D'))';
                        nrPoint = size(tmp,1);
                        h(1:nrPoint,ix) = tmp;
                        u(1:nrPoint,ix) = squeeze(ncread(theFile,'VELOCITY_U_2D'))';
                        v(1:nrPoint,ix) = squeeze(ncread(theFile,'VELOCITY_V_2D'))';
                        % determime variable names in the file
                        tmp = ncinfo(theFile);
                        ncVarNames = {tmp.Variables.Name};
                        for itrac = 1:numel(tracers)
                            tracName = sprintf('%s_2D',tracers{itrac});
                            existTrac = any(strcmpi(tracName,ncVarNames));
                            if existTrac
                                tracFound(itrac) = true;
                                trac(:,ix,itrac) = squeeze(ncread(theFile,...
                                    sprintf('%s_2D',tracers{itrac})))';
                            end
                        end
                    case '3D'
                        tempVal = squeeze(ncread(theFile,'ELEVATION_Z_3D'))';
                        if size(tempVal,1)~=nt
                            tempVal(end+1:nt,:)=repmat(tempVal(end,:),nt-size(tempVal,1),1);
                        end
                        h(:,:,ix) = tempVal;
                        tempVal = squeeze(ncread(theFile,'VELOCITY_U_3D'))';
                        if size(tempVal,1)~=nt
                            tempVal(end+1:nt,:)=repmat(tempVal(end,:),nt-size(tempVal,1),1);
                        end
                        u(:,:,ix) = tempVal;
                        tempVal = squeeze(ncread(theFile,'VELOCITY_V_3D'))';
                        if size(tempVal,1)~=nt
                            tempVal(end+1:nt,:)=repmat(tempVal(end,:),nt-size(tempVal,1),1);
                        end
                        v(:,:,ix) = tempVal;
                        % determime variable names in the file
                        tmp = ncinfo(theFile);
                        ncVarNames = {tmp.Variables.Name};
                        for itrac = 1:numel(tracers)
                            % check if a tracer exists
                            tracName = sprintf('%s_3D',tracers{itrac});
                            existTrac = any(strcmpi(tracName,ncVarNames));
                            if existTrac
                                tracFound(itrac) = true;
                                tempVal = squeeze(ncread(theFile,...
                                    tracName))';
                                if size(tempVal,1)~=nt
                                    tempVal(end+1:nt,:)=repmat(tempVal(end,:),nt-size(tempVal,1),1);
                                end
                                trac(:,:,ix,itrac)=tempVal;
                            else
                                trac(:,:,ix,itrac)=nan;
                            end
                        end
                        if any(isnan(trac))
                            warning('Nans in the tracer field');
                        end
                end
            end
        end
        
        
        function [paramsOut] = readSteering(casFilename)
            % [paramsOut] = readSteering(casFilename);
            % Read Telamac .cas steering file
            % Inputs:
            % casFilename: Name of the .cas file that needs to be edited
            % casOptions: Nx2 cell array where the first column contains
            % the parameters that need to be changed and the second column
            % contains the new parameters (as strings)
            %
            % Outputs
            % paramsOut: Nx3 cell array where the first column contains
            % the parameters, the second column contains the parameter choices (as strings)
            % and the third column contains any comments put after the
            % parameter choices
            
            
            %Now re-read the file line by line
            fid = fopen(casFilename,'r');
            
            paramsOut = {};
            
            i = 1;
            
            while i<1e6%Read file line by line
                if feof(fid)%If we reached the end of the file, stop
                    break;
                end
                
                line = fgetl(fid);%Read a line
                
                if strcmp(line,'&FIN') || ~ischar(line)%If we reached the end of the file, stop
                    break;
                end
                
                if ~isempty(line) && ~strcmp(line(1),'/')%If the line is not empty or a comment line
                    c = textscan(line,'%s','delimiter',{':','=','/'});
                    
                    c=c{1};
                    
                    % If parameter name and choice are split over 2 lines, read the
                    % second line
                    while numel(c)==1
                        line = fgetl(fid);%Read a line
                        if ~isempty(line) && ~strcmp(line(1),'/')
                            cBis = textscan(line,'%s','delimiter',{':','/'});
                            c = [c cBis{1}];
                        end
                    end
                    % If long parameters sets are split over 2 lines, read the
                    % second line
                    parList = strtrim(c{2});
                    while strcmpi(parList(end),';');
                            line = fgetl(fid);%Read a line
                            if ~isempty(line) && ~strcmp(line(1),'/')
                            cBis = textscan(line,'%s','delimiter','');
                            parList = [parList strtrim(cBis{1})];
                            end
                    end
                    
                    
                    paramsOut{i,1} = strtrim(c{1});%Separate each line into the parameter name, choice and comment
                    paramsOut{i,2} = parList;
                    if numel(c)==3
                        paramsOut{i,3} = strtrim(c{3});
                    end
                    i = i+1;
                    
                end
                
            end
        end
        
        function [xy,ikle] = readT3s(theFile)
            % Reads a T3S file wilth a mesh (BlueKenue)
            %
            %
            %
            %[xy,ikle] = Telemac.readT3s(theFile)
            %
            % #INPUTS:
            % theFile: the filename
            %           -
            % #OUTPUTS:
            % xy: Matrix with x and y coordinates of the nodes
            % ikle: Matrix with the connecions between the edges
            %
            %
            % #STEPS:
            % #KNOWN ISSUES:
            %
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 26/6/2012
            % Modified by:
            % Date:
            
            %1.) Open file and read header
            
            fid = fopen(theFile);
            bGo = 1;
            nrNodes =  0;
            nrElements = 0;
            nrAttributes = 0;
            while bGo
                theLine = fgetl(fid);
                bGo = isempty(strfind(theLine,':EndHeader'));
                if bGo
                    %:AttributeName 1 NodeType
                    %:AttributeType 1 oneof  "Interior=0" "OutLine=1" "SubMesh=2" "HardPoint=3" "HardLine=4" "HardIsland=5" "SoftLine=6" "SoftIsland=7"
                    %:AttributeName 2 Density
                    bAtt = ~isempty(strfind(theLine,':AttributeName'));
                    if bAtt
                        nrAttributes = nrAttributes + 1;
                    end
                    %:NodeCount 12534
                    %:ElementCount 23775
                    nrNodes    =  Telemac.convertTag(theLine,':NodeCount',nrNodes);
                    nrElements =  Telemac.convertTag(theLine,':ElementCount',nrElements);
                end
            end
            
            % read coordinates
            theFormat = ['%f %f ', repmat('%f ',1,max(nrAttributes,1))];
            cData = textscan(fid,theFormat,nrNodes);
            xy = cell2mat(cData);
            % read connections
            
            cData = textscan(fid,'%f %f %f',nrElements);
            ikle = cell2mat(cData);
            
            fclose(fid);
        end
        
        function aVal = convertTag(aLine,aTag,aVal)
            % Converts the tag to a number; privarte function from readT3s
            %
            
            ind = strfind(aLine,aTag);
            if ~isempty(ind)
                [~,remain] = strtok(aLine);
                aVal = str2double(remain);
            end
            
        end
        
        function slf = ds2slf(ds,templateSlf,outFile,opt)
            % Convert 4D (Time-Z-X-Y) dataset to Selafin file, for nudging.
            % Includes all necessary interpolation in horizontal and
            % vertical
            %
            % slf = ds2slf(ds,templateSlf,outFile,opt)
            % OUTPUTS:
            % - ds: Dataset, e.g. as generated by GlobalModel.HycomDataLoad
            % - templateSlf: template selafin file containing mesh, layers
            % etc. (e.g. from previous computation)
            % - outFile: Selafin output file
            % - opt: options structure
            %
            % OUTPUTS:
            % - slf: generated selafin structure at last timestep (is also written to file)
            %
            
            %% Options structure;
            if nargin < 4
                opt = struct;
            end
            opt = Util.setDefault(opt,'merc2spher',false);
            opt = Util.setDefault(opt,'lon0',0);
            opt = Util.setDefault(opt,'lat0',0);
            opt = Util.setDefault(opt,'noSediment',false);
            
            %% Size of dataset
            nX = numel(ds.X.data);
            nY = numel(ds.Y.data);
            nZ = numel(ds.Z.data);
            nT = numel(ds.Time.data);
            
            if numel(ds.X.data)==max(size(ds.X.data)) %If X and Y are supplied as vectors
                [X,Y]=meshgrid(ds.X.data,ds.Y.data);
            else
                X = ds.X.data;
                Y = ds.Y.data;
            end
            
            
            %% Read template Selafin
            slf = telheadr(templateSlf);
            slf = telstepr(slf,1);
            
            
            
            %% Add a few simple parameters
            slf.DT = median(diff(ds.Time.data));
            slf.NPOIN2 = slf.NPOIN/slf.NPLAN;
            
            
            slf.XYZ2D = slf.XYZ(1:slf.NPOIN2,:);
            
            %% Remove sediment if necessary
            if opt.noSediment
                maskNoSed = ~contains(slf.RECV,'SEDIMENT');
                slf.RECV = slf.RECV(maskNoSed);
                slf.RESULT(:,maskNoSed);
                slf.NBV = sum(maskNoSed);
            end
            
            %% If necessary, convert from mercator to lat/lon
            if opt.merc2spher
                [slf.XYZ2D(:,1),slf.XYZ2D(:,2)] = ...
                    Telemac.mercator2spherical(slf.XYZ2D(:,1),slf.XYZ2D(:,2),...
                    opt.lon0,opt.lat0);
            end
            
            
            % Write header to output file:
            fid = telheadw(slf,outFile);
            %% Determine weighing factors for horizontal interpolation of dataset to Selafin
            
            [m,n]=size(X);
            [indexX,indexY] = meshgrid(1:n,1:m);
            interpX = interp2(X,Y,indexX,slf.XYZ2D(:,1),slf.XYZ2D(:,2));
            interpY = interp2(X,Y,indexY,slf.XYZ2D(:,1),slf.XYZ2D(:,2));
            
            if any(isnan(interpY)) || any(isnan(interpX))
                error('Some of the meshpoints are outside the dataset');
            end
            
            indX = floor(interpX);
            indX(indX==n)=n-1;
            weightX = interpX-indX;
            indY = floor(interpY);
            indY(indY==m)=m-1;
            weightY = interpY-indY;
            % weight per point (clockwise starting left below)
            %             w1 = (1-weightX).*(1-weightY); %X,Y
            %             w2 = weightX.*(1-weightY);     %X+1,Y
            %             w3 = weightX.*weightY;         %X+1,Y+1
            %             w4 = (1-weightX).*weightY;     %X,Y+1
            w1 = (1-weightX).*(1-weightY); %X,Y
            w2 = (1-weightX).*weightY;     %X,Y+1
            w3 = weightX.*weightY;         %X+1,Y+1
            w4 = weightX.*(1-weightY);     %X+1,Y
            
            w = w1+w2+w3+w4;
            w1=w1./w;
            w2=w2./w;
            w3=w3./w;
            w4=w4./w;
            
            %% Perform 2D horizontal interpolation from datset to selafin
            % grid, but on the vertical layers of the dataset
            
            for iT = 1:nT
                resWatLev =    w1 .* ds.Watlev.data(...
                    sub2ind(size(ds.Watlev.data),iT*ones(size(indX)),...
                    indY,indX)) + ...
                    w2 .* ds.Watlev.data(...
                    sub2ind(size(ds.Watlev.data),iT*ones(size(indX)),...
                    indY+1,indX)) + ...
                    w3 .* ds.Watlev.data(...
                    sub2ind(size(ds.Watlev.data),iT*ones(size(indX)),...
                    indY+1,indX+1)) + ...
                    w4 .* ds.Watlev.data(...
                    sub2ind(size(ds.Watlev.data),iT*ones(size(indX)),...
                    indY,indX+1));
                
                
                resHoriz = zeros(slf.NPOIN2,nZ,numel(slf.RECV));
                for iPlan = 1:nZ  %Loop over vertical layers
                    for iVar = 1:numel(slf.RECV)
                        dsVar =  ModelUtil.lookupVarName(slf.RECV{iVar}(1:16),'telemac');
                        if strcmp(dsVar,'Z')
                            %Elevation -> just copy per layer
                            resHoriz(:,iPlan,iVar) = ds.(dsVar).data(iPlan);
                        else
                            resHoriz(:,iPlan,iVar) = ...
                                w1 .* ds.(dsVar).data(...
                                sub2ind(size(ds.(dsVar).data),iT*ones(size(indX)),...
                                ones(size(indX))*(iPlan),indY,indX)) + ...
                                w2 .* ds.(dsVar).data(...
                                sub2ind(size(ds.(dsVar).data),iT*ones(size(indX)),...
                                ones(size(indX))*(iPlan),indY+1,indX)) + ...
                                w3 .* ds.(dsVar).data(...
                                sub2ind(size(ds.(dsVar).data),iT*ones(size(indX)),...
                                ones(size(indX))*(iPlan),indY+1,indX+1)) + ...
                                w4 .* ds.(dsVar).data(...
                                sub2ind(size(ds.(dsVar).data),iT*ones(size(indX)),...
                                ones(size(indX))*(iPlan),indY,indX+1));
                        end
                    end
                end
                
                %% Now, interpolate resHoriz (with the ds vertical layers) to the
                % vertical layers in the Selafin file
                res3D = zeros(slf.NPOIN2,slf.NPLAN,numel(slf.RECV));
                
                %First, do elevation, since we need this one for all the other variables
                zInd = find(strcmp(slf.RECV,'ELEVATION Z     M               '));
                res3D(:,:,zInd) = reshape(slf.RESULT(:,zInd),slf.NPOIN2,slf.NPLAN);
                for iPlan = 1:slf.NPLAN
                    
                    
                    for iVar = 1:numel(slf.RECV)
                        dsVar =  ModelUtil.lookupVarName(slf.RECV{iVar}(1:16),'telemac');
                        if strcmp(dsVar,'Z')
                            %Elevation -> skip, we've already treated it
                            continue
                        else
                            res3D(:,iPlan,iVar) = Interpolate.interpMat1(...
                                resHoriz(:,:,zInd),resHoriz(:,:,iVar),res3D(:,iPlan,zInd));
                        end
                    end
                end
                %Add water level at surface layer
                res3D(:,end,zInd) = resWatLev;
                
                slf.RESULT = reshape(res3D,slf.NPOIN2*slf.NPLAN,numel(slf.RECV));
                slf.AT = ds.Time.data(iT);
                
                
                
                %% Write timestep
                fprintf('Writing timestep %u of %u.\n',iT,nT);
                if any(isnan(slf.RESULT(:)))
                    error('NaNs in written Selafin data. Telemac will crash.');
                end
                fid = telstepw(slf,fid);
                
            end %End loop over time
            
            % Close all file
            fclose(fid);
            fclose all
            
            
        end
        
        function [] = mapCli(oldSlfFile,oldCliFile,newSlfFile,newEmptyCliFile,newFullCliFile)
            % Map cli file from old mesh to new mesh
            % [] = Telemac.mapCli(oldSlfFile,oldCliFile,newSlfFile,newEmptyCliFile,newFullCliFile);
            %
            % INPUT:
            % - oldSlfFile: Selafin file of old mesh
            % - oldCliFile: Cli file of old mesh
            % - newSlfFile: Selafin file of new mesh
            % - newEmptyCliFile: Cli file of new mesh (doens't need to have any boundaries
            % - newFullCliFile: New mapped cli file (output)
            %
            
            % Load files
            [dsOld,slfOld]=Telemac.readTelemacData(oldSlfFile);
            [dsNew,slfNew]=Telemac.readTelemacData(newSlfFile);
            [cliOld,bnOld]=Telemac.readCli(oldCliFile);
            cliOld = cliOld(:,1:13);
            [cliNewEmpty,~]=Telemac.readCli(newEmptyCliFile);
            cliNewEmpty = cliNewEmpty(:,1:13);
            nbnd = size(cliNewEmpty,1);%Number of boundary points
            bnNew = cell(nbnd,1);
            
            % Loop over all new boundary points
            for i = 1:nbnd
                % X and Y coordinates of new boundary points
                xNew = dsNew.X.data(cliNewEmpty(i,12));
                yNew = dsNew.Y.data(cliNewEmpty(i,12));
                % Find closest old boundary point
                [~,mi] = min((dsOld.X.data(cliOld(:,12))-xNew).^2+(dsOld.Y.data(cliOld(:,12))-yNew).^2);
                % Name of boundary segment
                bnNew{i} = bnOld{mi};
            end
            
            Telemac.writeCli(newFullCliFile,cliNewEmpty,bnNew);
            
        end
        
        function [stats,ncs] = readNetcdfStations(folder)
            % function to read all the available stations in netcdf output
            % in the specified folder
            % INPUTS:
            %   - folder : folder where all output netcdf are saved
            % OUTPUTS:
            %   - stats  : cellstr with list of all stations
            %   - ncs    : cellstr with names of netcdf files
            
            temp = dir(fullfile(folder,'*.nc'));
            iCount = 1;
            stats = {};
            ncs = {};
            for i=1:numel(temp)
                try
                    stats{iCount,1} = ncreadatt(fullfile(folder,temp(i).name),'/','station_names');
                    ncs{iCount,1} = temp(i).name;
                    iCount = iCount+1;
                catch
                    warning(['File: ',temp(i).name,' is not a station or does not have a station name as attribute. It is not included in the list.']);
                end
            end
        end
        
        function [dataset2D,varNames2D,dataset3D,varNames3D] = readNetcdfData(strRead,opt)
            % Read netcdf telemac data
            %
            % [dataset2D,varNames2D,dataset3D,varNames3D] = readNetcdfData(strRead,opt)
            % INPUTS:
            %   - strRead : folder or file, if folder all netcdf are read,
            %   if file can be netcdf file that is read directly or can be
            %   coordinate.txt file, in which case it will only read the
            %   netcdf data from the stations in that coordinate.txt file
            %   - opt: Structure with options
            %   -   waitbars: Show waitbars for parts that may take a while
            %   (default = false)
            %   -  crappyStruc (default = true): use to make standard
            %   conforming structures; default is ECA setting
            %   - reads now all varNames, not implemented yet
            % OUTPUTS:
            %   - dataset structure
            
            %Handle optional inputs;
            if nargin ==1
                opt = struct;
            end
            % Set defaults
            opt = Util.setDefault(opt,'waitbars',false);
            opt = Util.setDefault(opt,'crappyStruc',true);
            
            % make list of files to read
            if ~isdir(strRead)
                [path,filename,ext] = fileparts(strRead);
            else
                path = strRead;
                ext = '';
            end
            temp = dir(fullfile(path,'OUTPUT_00*.nc'));
            switch ext
                case '.nc'
                    list.name = [filename,ext];
                case '.txt'
                    [stations,vX,vY,~,~] = Telemac.readCoordinateFile(strRead);
                    for i=1:numel(temp)
                        sStat{i} = ncreadatt(fullfile(path,temp(i).name),'/','station_names');
                    end
                    iCount = 1;
                    for i=1:numel(stations)
                        ind = find(strcmp(sStat,stations{i}),1,'first');
                        if ~isempty(ind)
                            list(iCount).name = temp(ind).name;
                            iCount = iCount+1;
                        end
                    end
                otherwise
                    % must be a folder specified
                    list = temp;
            end
            
            numList = numel(list);
            
            % read all data
            meta = ncinfo(fullfile(path,list(1).name));
            nrVars = length(meta.Variables);
            
            varNames2D{1} = 'Stations';
            varNames3D{1} = 'Stations';
            varNames2D{2} = 'X';
            varNames3D{2} = 'X';
            varNames2D{3} = 'Y';
            varNames3D{3} = 'Y';
            
            if opt.waitbars
                hb = waitbar(0,'Reading file headers');
            end
            for iS = 1:numList
                if opt.waitbars && (mod(iS,1000)==0)
                    waitbar(iS/numList,hb);
                end
                if opt.crappyStruc
                    dataset2D.(varNames2D{1}).data{iS}   = ncreadatt(fullfile(path,list(iS).name),'/','station_names');
                    dataset3D.(varNames3D{1}).data{iS}   = dataset2D.Stations.data{iS};
                    dataset2D.(varNames2D{2}).data(iS,1) = double(ncread(fullfile(path,list(iS).name),'x'));
                    dataset2D.(varNames2D{3}).data(iS,1) = double(ncread(fullfile(path,list(iS).name),'y'));
                    dataset3D.(varNames3D{2}).data(iS,1) = double(ncread(fullfile(path,list(iS).name),'x'));
                    dataset3D.(varNames3D{3}).data(iS,1) = double(ncread(fullfile(path,list(iS).name),'y'));
                else
                    dataset2D(iS).(varNames2D{1}).data   = ncreadatt(fullfile(path,list(iS).name),'/','station_names');
                    dataset3D(iS).(varNames3D{1}).data   = dataset2D(iS).Stations.data;
                    dataset2D(iS).(varNames2D{2}).data = double(ncread(fullfile(path,list(iS).name),'x'));
                    dataset2D(iS).(varNames2D{3}).data = double(ncread(fullfile(path,list(iS).name),'y'));
                    dataset3D(iS).(varNames3D{2}).data = double(ncread(fullfile(path,list(iS).name),'x'));
                    dataset3D(iS).(varNames3D{3}).data = double(ncread(fullfile(path,list(iS).name),'y'));
                end
                
            end
            if opt.waitbars
                close(hb);
            end
            % read time seperately
            varNames2D{4}       = 'Time';
            varNames3D{4}       = 'Time';
            if opt.crappyStruc
                t                   = ncread(fullfile(path,list(1).name),'time');
                tStr                = ncreadatt(fullfile(path,list(1).name),'time','units');
                t0                  = datenum(tStr(15:end));
                dataset2D.(varNames2D{4}).data = t/86400+t0;
                dataset3D.(varNames3D{4}).data = dataset2D.Time.data;
            else
                for iS = 1:numList
                    t                   = ncread(fullfile(path,list(iS).name),'time');
                    tStr                = ncreadatt(fullfile(path,list(iS).name),'time','units');
                    t0                  = datenum(tStr(15:end));
                    dataset2D(iS).(varNames2D{4}).data = t/86400+t0;
                    dataset3D(iS).(varNames3D{4}).data = dataset2D(iS).Time.data;
                end
            end
            
            iCount2D = length(varNames2D)+1;
            iCount3D = length(varNames2D)+1;
            for j = 1:nrVars
                varName = strrep(meta.Variables(j).Name,'_',' ');
                if length(varName)>2
                    suff = varName(end-1:end);
                else
                    suff = '';
                end
                switch suff
                    case '2D'
                        varTemp = ModelUtil.lookupVarName(varName(1:end-3),'telemac');
                        if ~isempty(varTemp)
                            varNames2D{iCount2D} = varTemp;
                            dataset2D = Telemac.readStationsNetcdf(dataset2D,path,list,meta.Variables(j).Name,varNames2D{iCount2D},opt);
                            iCount2D = iCount2D + 1;
                        end
                    case '3D'
                        varTemp = ModelUtil.lookupVarName(varName(1:end-3),'telemac');
                        if ~isempty(varTemp)
                            varNames3D{iCount3D} = varTemp;
                            dataset3D = Telemac.readStationsNetcdf(dataset3D,path,list,meta.Variables(j).Name,varNames3D{iCount3D},opt);
                            iCount3D = iCount3D + 1;
                        end
                    otherwise
                        % not specific 2D or 3D, add for both
                        varTemp = ModelUtil.lookupVarName(varName,'telemac');
                        if ~isempty(varTemp)
                            varNames2D{iCount2D} = varTemp;
                            varNames3D{iCount3D} = varTemp;
                            dataset2D = Telemac.readStationsNetcdf(dataset2D,path,list,meta.Variables(j).Name,varNames3D{iCount2D},opt);
                            dataset3D = Telemac.readStationsNetcdf(dataset3D,path,list,meta.Variables(j).Name,varNames3D{iCount3D},opt);
                            iCount2D = iCount2D + 1;
                            iCount3D = iCount3D + 1;
                        end
                end
            end
        end
        
        function dataset = readStationsNetcdf(dataset,path,list,varNameNc,varNameData,opt)
            % function to read a variable from a list of stations
            %
            %dataset = readStationsNetcdf(dataset,path,list,varNameNc,varNameData,opt)
            %
            % INPUT:
            % - dataset: dataset to add the data to
            % - path: folder with the nc files
            % - list: lits of nc files to read (list.name)
            % - varNameNc: variable name in nc file to read
            % - varNameData: variable name to save in dataset
            % - opt: Options structure, including:
            %   -useWaitbar (default false).
            % OUTPUT:
            %   - dataset
            
            if nargin < 6
                opt = struct;
            end
            opt = Util.setDefault(opt,'crappyStruc',true);
            opt = Util.setDefault(opt,'useWaitbar',false);
            
            if opt.useWaitbar
                hb = waitbar(0,sprintf('Reading variable %s',strrep(varNameNc,'_','-')));
            end
            
            for iS = 1:numel(list)
                dataTemp = ncread(fullfile(path,list(iS).name),varNameNc);
                if ~isempty(dataTemp)
                    if opt.crappyStruc
                        dataset.(varNameData).data{iS} = squeeze(dataTemp);
                    else
                        dataset(iS).(varNameData).data = squeeze(dataTemp);
                    end
                end
                if opt.useWaitbar
                    waitbar(iS/numel(list),hb);
                end
            end
            if opt.useWaitbar
                close(hb);
            end
        end
        
        function [statName,x,y,id,nodes,theTime] = readCoordinateFile(strRead)
            % function to read a coordinate file
            % INPUT:
            %   - strRead: string with coordinate file
            % OUTPUT:
            %   - statName: cellstring
            %   - x: x-coordinate
            %   - y: y-coordinate
            %   - id: station-id
            %   - nodes: total number of nodes
            %   - theTime: start time, end time, and time step
            fid = fopen(strRead);
            str = fgetl(fid);
            nr  = str2num(str); %#ok<ST2NM>
            nrTimes = nr(1);
            nodes   = nr(2);
            theTime = zeros(nrTimes,3);
            for i=1:nrTimes
                str = fgetl(fid);
                theTime(i,:) = str2num(str); %#ok<ST2NM>
            end
            cData = textscan(fid,'%f %f %d %s');
            fclose(fid);
            statName = cData{:,4};
            x        = cData{:,1};
            y        = cData{:,2};
            id       = cData{:,3};
        end
        
        function [dataset,sctData,sctDataPartial] = readTelemacData(dataset,sctData,varNames,sctOptions)
            % read the Telemac data
            %
            % Method 1: Flexible reading
            % --------------------------
            %
            % function [dataset,sctData] = readTelemacData(dataset,sctData,varNames,sctOptions)
            %
            % INPUT:
            % - dataset: dataset read with Telemac.readTelemacHeader
            % - sctData: Selafin structure read with
            % Telemac.readTelemacHeader
            % - varNames (required; no default)
            % - sctOptions.startDate (default: sctData.IDATA if available, 0 otherwise)
            % - sctOptions.start (default: 1)
            % - sctOptions.stop (default: sctOptions.start)
            % - sctOptions.stride (default: 1)
            % - sctOptions.verbose (default: false);
            % - sctOptions.readPartial (default: false);
            % - sctOptions.sctDataPartial
            %
            %
            % Example:
            % [ds,slf,varNames] = Telemac.readTelemacHeader(filename);
            % [ds,slf] = Telemac.readTelemac
            %
            % Method 2: Read entire Selafin file (non-flexible, may be slow)
            % --------------------------------------------------------------
            %
            % function [dataset,sctData] = readTelemacData(filename)
            %
            % INPUT:
            % - filename: name of Selafin file
            
            % Simple method: (don't tell Alexander I added this).
            if nargin == 1
                [dataset,sctData,varNames] = Telemac.readTelemacHeader(dataset);
            end
            
            % preprocessing of default options
            if nargin <4
                sctOptions = struct;
            end
            if isempty(sctData.IDATE)
                sctOptions = Util.setDefault(sctOptions,'startDate',0);
            else
                sctOptions = Util.setDefault(sctOptions,'startDate',datenum(sctData.IDATE));
            end
            sctOptions = Util.setDefault(sctOptions,'start',1);
            sctOptions = Util.setDefault(sctOptions,'stop',sctOptions.start);
            sctOptions = Util.setDefault(sctOptions,'stride',1);
            sctOptions = Util.setDefault(sctOptions,'verbose',false);
            sctOptions = Util.setDefault(sctOptions,'readVarOnly',[]);
            sctOptions = Util.setDefault(sctOptions,'readPartial',false);
            sctOptions = Util.setDefault(sctOptions,'sctDataPartial',[]);

            sctDataPartial = sctOptions.sctDataPartial;
            
            is3d    = sctData.NPLAN>1;
            nrSteps = (sctOptions.stop - sctOptions.start)/sctOptions.stride + 1;
            if isempty(sctOptions.readVarOnly)
                nrVars  = length(varNames);
                varInds = 1: nrVars;
            else
                nrVars = length(sctOptions.readVarOnly);
                varInds = sctOptions.readVarOnly;
            end
            
            % preallocate output data
            for j = 1:nrVars
                theVar = varNames{varInds(j)};
                
                if ~isempty(theVar)
                    if is3d
                        dataset.(theVar).data = zeros(sctData.nrPoints,sctData.nrLayers,nrSteps);
                    else
                        dataset.(theVar).data = zeros(sctData.nrPoints,nrSteps);
                    end
                end
            end
            dataset.Time.data = zeros(nrSteps,1);
            
            iCount = 1;
            for i = sctOptions.start:sctOptions.stride:sctOptions.stop
                % read time steps
                if ~sctOptions.readPartial
                    sctData      = telstepr(sctData,round(i));
                    sctDataPartial = [];
                else
                    [sctData,sctDataPartial] = Telemac.telsteprGretel(sctData,sctDataPartial,round(i));
                    
                end
%                 dataset.Time.data(iCount) = sctData.AT/(3600*24)+sctOptions.startDate;
                dataset.Time.data(iCount) = ((sctData.DT*sctData.timestep)-sctData.DT)/(3600*24)+sctOptions.startDate;
                
                % conversion 3D -> 2D
                if is3d
                    for j = 1:nrVars
                        theVar = varNames{varInds(j)};
                        if ~isempty(theVar)
                            DataOut = Telemac.convertTelemac3Ddata(sctData,varInds(j));
                            dataset.(theVar).data(:,:,iCount) = DataOut;
                        end
                    end
                else
                    for j = 1:nrVars
                        theVar = varNames{varInds(j)};
                        if ~isempty(theVar)
                            dataset.(theVar).data(:,iCount) = sctData.RESULT(:,varInds(j));
                        end
                    end
                end
                iCount = iCount +1;
            end
        end
        
        function [sct,sctTmp] = telheadr(fileName,geoFile)
            % wrapper around telheadr/telheadrGretel
            % 
            % [sct,sctTmp] = telheadr(fileName,geoFile)
            %
            %note geoFile is only needed if gretel is used
            if nargin == 1 || isempty(geoFile)
                sct    = telheadr(fileName);
                sctTmp = [];
            else
                [sct,sctTmp] = Telemac.telheadrGretel(fileName,geoFile);
            end
        end
        
        function [sct,sctTmp] = telstepr(sct,sctTmp,iTime)
            %wrapper around telstepr/telsteprGretel
            %
            % [sct,sctTmp] = telstepr(sct,sctTmp,iTime)
            %
            % Note. Use in combination with Telemac.telheadr
            
            if isstruct(sctTmp)
                [sct,sctTmp] = Telemac.telsteprGretel(sct,sctTmp,iTime);
            else
                sct = telstepr(sct,iTime);
            end
        end
        
        function [sct,sctTmp] = telheadrGretel(fileName,geoFile)
            % read header from a split up telemac file
            %
            % [sct,sctTmp] = telheadrGretel(fileName,geoFile)
            %
            %
            %EXAMPLE (gretel for matlab)
            % clear;clc
            % [sctAll,tmp] = Telemac.telheadrGretel('T3DRES','T3DGEO');
            % sctOut = sctAll;
            % fid = telheadw(sctOut,'..\RES3D.slf');
            % for i=1:tmp(1).NSTEPS
            %     disp(num2str(i,'merging step %03.0f'));
            %     [sctAll,tmp] = Telemac.telsteprGretel(sctAll,tmp,i);
            %     sctOut = sctAll;
            %     fid    = telstepw(sctOut,fid);
            % end
            % fclose(fid);
            %
            
            % read the global Mesh
            sctGeo = telheadr(geoFile);
            
            % read all partial files; do not included recomposed file
            allFiles = dir([fileName,'*']);
            [~,tmpFile] = fileparts(fileName);
            recomposedInd = strcmpi(tmpFile,{allFiles.name});
            allFiles(recomposedInd) = [];
            for i=length(allFiles):-1:1
                theFile = fullfile(allFiles(i).folder,allFiles(i).name);
                try
                    tmp = telheadr(theFile);
                    tmp.OK = true;
                    sctTmp(i) = tmp;
                catch
                    warning(['There is a problem reading ',theFile]);
                    sctTmp(i).OK = false;
                end
            end
            for i=length(allFiles):-1:1
                sctTmp(i).AT = 0;
            end

            %adapth data structure
            sct = sctTmp(1);
            sct.IKLE   = sctGeo.IKLE;
            sct.NPOIN  = sctGeo.NPOIN;
            sct.NELEM  = sctGeo.NELEM;
            sct.XYZ    = sctGeo.XYZ;
            for i=length(allFiles):-1:1
                %get global to local info
                if sctTmp(i).OK
                    NPOIN2 = sctTmp(i).NPOIN/sctTmp(i).NPLAN;
                    klgb = sctTmp(i).IPOBO(1:NPOIN2);
                    mask = klgb>0;
                    %copy data back
                    for iVar=sct.NBV:-1:1
                        sct.XYZ(klgb(mask),:) = sctTmp(i).XYZ(mask,:);
                    end
                end
            end
            sct.IPOBO  = sctGeo.IPOBO;
            if sct.NPLAN >1
                sct = Telemac.convertTelemac2Dgrid(sct,sctTmp(1).NPLAN);
            end
            % read first time step
            [sct,sctTmp] = Telemac.telsteprGretel(sct,sctTmp,1);
            
        end
        
        function [sct,sctTmp,procNr,locNr] = telsteprGretel(sct,sctTmp,iTime)
            % read data from a split up telemac file
            %
            % [sct,sctTmp,procNr,locNr] = telsteprGretel(sct,sctTmp,iTime)
            %
            % INPUT:
            %
            % OUTPUT:
            % - sct: structure wih telemac dat asoimalar as generated with
            % telheadr
            % - sctTmp: an array with the telheadr structure for each
            % processor separately
            % -procNr: array with for each node the number of the processor
            % of that node
            % -locNr: array with loc number of the node ona specific
            % processor
            
            % read all files
            sct.RESULT = nan(sct.NPOIN,sct.NBV);
            procNr     = nan(sct.NPOIN,1);
            locNr     = nan(sct.NPOIN,1);
            for iFile=1:length(sctTmp)
                if sctTmp(iFile).OK
                    sctTmp(iFile) = telstepr(sctTmp(iFile),iTime);
                    %get global to local info
                    klgb = sctTmp(iFile).IPOBO;
                    mask = klgb>0;
                    %copy data back
                    for iVar=sct.NBV:-1:1
                        sct.RESULT(klgb(mask),iVar) = sctTmp(iFile).RESULT(mask,iVar);
                    end
                    sct.AT = sctTmp.AT;
                    %make map with cpu numbers
                    tmp     = regexp(sctTmp(iFile).filename,'\d*','match');
                    tmpProc = str2double(tmp{end});
                    procNr(klgb(mask)) = tmpProc;
                    locNr (klgb(mask)) = (1:sctTmp(iFile).NPOIN)';
                end
                
                % delete temporary data
                %sctTmp(iFile).RESULT = [];
            end
        end
        
        function plotMesh(sct)
            % wrapper to plot telemac mesh rapidly
            %
            % Telemac.plotMesh(sct)
            %
            % INPUT:
            % -sct: structure from telheadr
            triplot(double(sct.IKLE),sct.XYZ(:,1),sct.XYZ(:,2));
            axis equal;
            grid on;
        end
        
        function plotMeshData(sct,z)
            % wrapper to plot telemac data rapidly
            %
            % Telemac.plotMeshData(sct,z)
            %
            % INPUT:
            % -sct: structure from telheadr
            % -z: array with data to plot
            
            Plot.plotTriangle(sct.XYZ(:,1),sct.XYZ(:,2),z,sct.IKLE);
            axis equal;
            colorbar;
            grid on;
        end
        
        function  thalweg2xyzDensity(fileIn,fileOut,distance, interval, density)
            %Computes density points (.xyz) around thalweg (.i2s)
            %
            %   fileIn = input file (.i2s)
            %   fileOut = output file (.xyz)
            %   distance = distance from thalweg to new xyz points
            %   interval = factor to decrease the number of nodes along 
            %              the thalweg which are converted to xyz points  
            %   density = density of xyz points

            data = Telemac.readKenue(fileIn);
            x0 = data{1,1}(:,1);
            y0 = data{1,1}(:,2);
            dx = diff(x0);
            dy = diff(y0);

            angle = atan2(dy,dx).*180/pi;
            perpAngle = angle +90;

            r= distance;
            dens = density;
            int = interval;

            x2 = x0(2:end) + r.*cos(deg2rad(perpAngle));
            y2 = y0(2:end) + r.*sin(deg2rad(perpAngle));

            x3 = x0(2:end) - r.*cos(deg2rad(perpAngle));
            y3 = y0(2:end) - r.*sin(deg2rad(perpAngle));

            %Interval used for output number xyz points
            x = [x2(1:int:end); x3(1:int:end)];
            y = [y2(1:int:end);y3(1:int:end)];
            z = ones(length(x),1).*dens;

            Telemac.writeKenue(fileOut,{[x,y,z]});

        end
        
        function plotDomain (fileName,geoFile)
            % plot domaindecomposition of a telemac model 
            %
            % plotDomain (fileName,geoFile)
            % 
            % INPUT:
            % - fileName: name of the decomposed files to view (e.g. T3DRES)
            % - geoFile : name of a full file (e.g. T3DGEO)
            
            % load data
            [sct,sctTmp] = Telemac.telheadrGretel(fileName,geoFile);
            [sct,sctTmp,cpuMap] = Telemac.telsteprGretel(sct,sctTmp,sctTmp(1).NSTEPS);
            
            % plot data
            UtilPlot.reportFigureTemplate;
            Plot.plotTriangle(sct.XYZ(:,1),sct.XYZ(:,2),cpuMap,sct.IKLE); 
            axis equal; 
            grid on; 
            shading flat
            hold on
            % add processor number in the middle
            for iFile = 0:length(sctTmp)-1
                mask = cpuMap==iFile;
                xy   = mean(sct.XYZ(mask,:));
                text(xy(1),xy(2),num2str(iFile));
            end
            
        end
        
        function plotBinObc(fileIn,varName)
            % crappy function to animate rapidly a binary boundary
            % conditions file
            %
            % plotBinObc(fileIn,varName)
            %
            % INPUT
            sct = telheadr(fileIn);
            indZ   = Telemac.findvar('ELEVATION Z',sct);
            indVar = Telemac.findvar(varName,sct);
            UtilPlot.reportFigureTemplate;
            nPoin2 = sct.NPOIN/sct.NPLAN;
            nPlan = sct.NPLAN;
            for i=1:sct.NSTEPS
                sct = telstepr(sct,i);
                z = reshape(sct.RESULT(:,indZ),nPoin2,nPlan);
                s = reshape(sct.RESULT(:,indVar),nPoin2,nPlan);
                % TODO; use meshFile to get coordinates and real distances
                x = repmat((1:nPoin2)',1,nPlan);
                
                pcolor(x,z,s);
                colorbar;
                title(num2str(sct.AT/3600,'%6.3h'));
                pause(0.5);
            end
        end
        
        function [dataset,sctData,varNames,sctDataPartial] = readTelemacHeader(strFile,sctOptions)
            %read Telemac Header
            %
            %function [dataset,sctData,varNames] = readTelemacHeader(strFile,sctOptions)
            %
            % sctOptions.startDate
            % sctOptions.start
            % sctOptions.end
            % sctOptions.varNames
            % sctOptions.verbose
            % sctOptions.readVarOnly: index of only variable to read
            % - sctOptions.readPartial (default: false);
            % - sctOptions.masterFile
            
            % preprocessing of default options
            if nargin <2
                sctOptions = struct;
            end
            sctOptions = Util.setDefault(sctOptions,'verbose',false);
            sctOptions = Util.setDefault(sctOptions,'readPartial',false);
            % read header
            if ~sctOptions.readPartial
            sctData = telheadr(strFile);
            sctDataPartial = [];
            else
                [sctData,sctDataPartial] = Telemac.telheadrGretel(strFile,sctOptions.masterFile);
            end
            
            % process header
            dataset.Time.data = zeros(sctData.NSTEPS,1);
            if isfield(sctOptions,'startDate')
                dataset.Time.data = [sctOptions.startDate:sctData.DT/(3600*24):sctOptions.startDate+((sctData.NSTEPS-1)*sctData.DT/(3600*24))]';
            elseif ~isempty(sctData.IDATE)
                dataset.Time.data = [datenum(sctData.IDATE):sctData.DT/(3600*24):datenum(sctData.IDATE)+((sctData.NSTEPS-1)*sctData.DT/(3600*24))]';
            else
                warning('Please specify a start date in sctOptions.startDate to write timesteps out')
            end
            is3d = sctData.NPLAN>1;
            
            % convert grid
            if is3d
                sctGrid = Telemac.convertTelemac3Dgrid(sctData);
                sctData.nrPoints = sctGrid.nrPoints;
                sctData.nrLayers = sctGrid.nrLayers;
            else
                sctData.nrPoints = sctData.NPOIN;
                sctData.nrLayers = 1;
            end
            sctData.nrSteps = sctData.NSTEPS;
            
            nrVars = length(sctData.RECV);
            
            % determine varnames
            % and preallocate  data
            varNames = cell(nrVars,1);
            for j = 1:nrVars
                varNames{j} = ModelUtil.lookupVarName(strtrim(sctData.RECV{j}(1:16)),'telemac');
            end
            
            % conversion to standard datastructure
            dataset.title = sctData.title;
            
            if is3d
                dataset.X.data    = sctGrid.XYZ(:,1);
                dataset.Y.data    = sctGrid.XYZ(:,2);
                dataset.IKLE.data = sctGrid.IKLE;
            else
                dataset.X.data    = sctData.XYZ(:,1);
                dataset.Y.data    = sctData.XYZ(:,2);
                dataset.IKLE.data = sctData.IKLE;
            end
        end
        
        function logData = readTelemacLog(fileName,nrVar)
            % read a telemac log file
            %
            % logData = Telemac.readTelemacLog(fileName,nrVar)
            %
            % INPUT: fileName: the file to read
            %        nrVar: the number of variables in the file
            %
            % OUTPUT: logData: a structure with the fields (N is the number of timesteps, M=nrVar)
            %          logData.iterations: [NxM]: Nr of iterations of the solver
            %          logData.precision: [NxM]: Precision of the solcer
            %          logData.time: [Nx1]: time in seconds
            %          logData.step: [Nx1]: time step
            %          logData.massErr: [NxM]: The error in the mass balance
            %          logData.mass: [NxM]:    Total mass in the domain
            %          logData.nrExc: [Nx1]: Nr of times that exceeding iterations coorus per time step.
            %          logData.maxExc: [Nx1]: Worst (maximum) obtained precision value
            %
            % Notes: The function now assumes that GMRES is used.
            
            % options
            nrSteps = 10000;
            
            % open file
            fid = fopen(fileName);
            
            % read every line
            theLine = fgetl(fid);
            
            % preallocate
            n = 0;
            time    = zeros(nrSteps,1);
            step    = zeros(nrSteps,1);
            iter    = zeros(nrSteps,nrVar);
            prec    = zeros(nrSteps,nrVar);
            mass    = zeros(nrSteps,nrVar);
            massErr = zeros(nrSteps,nrVar);
            exceed  = zeros(nrSteps,1);
            maxExceed  = zeros(nrSteps,1);
            nrExc    = 0;
            maxExc   = 0;
            
            while 1
                % read every line
                theLine = fgetl(fid);
                if ~ischar(theLine)
                    break;
                end
                theLine = strtrim(theLine);
                % read time
                nrL = length(theLine);
                if strcmpi(theLine(1:min(9,nrL)),'ITERATION')
                    %store data
                    if n>0
                        exceed(n)   = nrExc;
                        maxExceed(n) = maxExc;
                    end
                    
                    % go to new time step
                    n= n + 1;
                    
                    % process text
                    cData = textscan(theLine, 'ITERATION     %f TIME    %f D %f H %f MN %f S   (     %f S)');
                    time(n) = cData{end};
                    step(n) = cData{1};
                    
                    % reset values
                    nrExc    = 0;
                    maxExc   = 0;
                    iVar  = 1;
                    iVarM = 1;
                end
                %Process GMRES
                if strcmpi(theLine(1:min(12,nrL)),'GMRES (BIEF)')
                    if isempty(strfind(theLine, 'EXCEEDING'))&&isempty(strfind(theLine, 'ALGORITHM FAILED'))
                        cData = textscan(theLine, 'GMRES (BIEF) :       %f ITERATIONS, %s PRECISION:   %f');
                    elseif isempty(strfind(theLine, 'ALGORITHM FAILED'))
                        cData = textscan(theLine, 'GMRES (BIEF) : EXCEEDING MAXIMUM ITERATIONS:     %f %s PRECISION:   %f');
                        maxExc = max(maxExc,cData{3});
                        nrExc  = nrExc + 1;
                    else
                        warning(['Algorithm failed at iteration ',num2str(n)]);
                        continue;
                        
                    end
                    if iVar <=nrVar
                        iter(n,iVar) = cData{1};
                        prec(n,iVar) = cData{3};
                        iVar = iVar + 1;
                    end
                    
                end
                if strcmpi(theLine(1:min(15,nrL)),'POSITIVE DEPTHS')
                    % not yet implemented
                end
                if strcmpi(theLine(1:min(10,nrL)),'MURD3D_POS')
                    % not yet implemented
                end
                if strcmpi(theLine(1:min(12,nrL)),'MASSE OF BED')
                    % not yet implemented
                end
                if strcmpi(theLine(1:min(20,nrL)),'TOTAL DEPOSITED MASS')
                    % not yet implemented
                end
                % Get the mass
                if strcmpi(theLine(1:min(29,nrL)),'MASS AT THE PRESENT TIME STEP')
                    cData = textscan(theLine, 'MASS AT THE PRESENT TIME STEP                 :    %f');
                    mass(n,iVarM) = cData{1};
                end
                % Get the error in the mass
                if strcmpi(theLine(1:min(39,nrL)),'ERROR ON THE MASS DURING THIS TIME STEP')
                    cData = textscan(theLine, 'ERROR ON THE MASS DURING THIS TIME STEP       :     %f');
                    massErr(n,iVarM) = cData{1};
                    iVarM            = iVarM + 1;
                end
            end
            
            fclose(fid);
            
            %add data to structure and delete unused timesteps
            logData.iterations = iter(1:n,:);
            logData.precision  = prec(1:n,:);
            logData.time       = time(1:n,:);
            logData.step       = step(1:n,:);
            logData.massErr    = massErr(1:n,:);
            logData.mass       = mass(1:n,:);
            logData.nrExc      = exceed(1:n,:);
            logData.maxExc     = maxExceed(1:n,:);
            
        end
        
        function [gridMercX,gridMercY] = spherical2mercator(long,lat,long0,lat0)
            % [gridMercX,gridMercY] = Telemac.spherical2mercator(long,lat,long0,lat0);
            % Convert sperical coordinates to Mercator for Telemac (from readgeo.f)%
            % Input:
            % long: Longitude
            % lat: Latitude
            % long0:  Longitude of origin (in decimal degrees)
            % lat0: Latitude of origin (in decimal degrees)
            % Output:
            % gridMercX: Grid X data in Mercator for Telemac projection
            % gridMercY: Grid Y data in Mercator for Telemac projection
            
            latRad = lat*pi/180;  %In Radians
            longRad = long*pi/180;%In Radians
            
            long0Rad =  long0 * pi/180; %In Radians (corresponds to Telemac internal variable
            lat0rad = lat0*pi/180;
            R = 6.37e6; %Earth radius according to Telemac
            PS4 = pi/4; %Teleamc parameter
            
            gridMercX = R * (longRad-long0Rad);
            gridMercY = R * (log(tan(0.5*latRad+PS4)) - log(tan(0.5*lat0rad+PS4)));
        end
        
        function kenue2kml(fileName,fileOut,CScode,lonlat0)
            % converts a blue kenue file to a kml file
            %
            % kenue2kml(fileName,fileOut,CScode)
            %
            % INPUT:
            % - filename: inputfile in i2s format
            % - fileOut: output file in .kml format
            % - CScode (optional): conversion code of the original mesh
            % - lonlat0 (optional): lat en lon coordinate of zeroe, when a
            % mesh is in mercator for telemac
            % OUTPUT:
            
            addOpenEarth;
            LARGE = 1e6;
            
            % read the file
            tmp = Telemac.readKenue(fileName);
            allLon = nan(LARGE,1);
            allLat = nan(LARGE,1);
            n = 1;
            for i = 1:length(tmp)
                xL = tmp{i}(:,1);
                yL = tmp{i}(:,2);
                % convert data to lat lon
                if nargin ==3
                    [lon,lat] = convertCoordinates(xL,yL,'CS1.code',CScode,'CS2.code',4326);
                elseif nargin ==4
                    lon0 = lonlat0(1);
                    lat0 = lonlat0(2);
                    [lon,lat] = Telemac.mercator2spherical(xL,yL,lon0,lat0);
                end
                % add data to structure
                n2 = n +length(lon) - 1;
                allLon(n:n2) = lon;
                allLat(n:n2) = lat;
                n = n2+2;
            end
            % delete data
            allLon(n2+1:end) = [];
            allLat(n2+1:end) = [];
            % write data
            KMLline(allLat,allLon,'fileName',fileOut);
            
        end
        
        function tel2kml(fileName,fileOut,CScode,lonlat0)
            % converts a telemac mesh to a kml file
            %
            % tel2kml(fileName,fileOut,CScode)
            %
            % INPUT:
            % - filename: inputfile in .t3s or .slf format
            % - fileOut: output file in .kml format
            % - CScode (optional): conversion code of the original mesh
            % - lonlat0 (optional): lat en lon coordinate of zeroe, when a
            % mesh is in mercator for telemac
            % OUTPUT:
            
            addOpenEarth;
            
            % read the file
            [~,~,ext] = fileparts(fileName);
            switch ext
                case '.t3s'
                    [xy,connection] = Telemac.readT3s(fileName);
                case '.slf'
                    sct = telheadr(fileName);
                    xy = sct.XYZ;
                    connection = sct.IKLE;
                otherwise
                    error('Unknown file format');
            end
            
            % extract lines
            [xL,yL] = Triangle.getLine(connection,xy);
            
            % convert data to lat lon
            
            if nargin ==3
                [lon,lat] = convertCoordinates(xL,yL,'CS1.code',CScode,'CS2.code',4326);
            elseif nargin ==4
                lon0 = lonlat0(1);
                lat0 = lonlat0(2);
                [lon,lat] = Telemac.mercator2spherical(xL,yL,lon0,lat0);
            end
            
            % write data
            KMLline(lat,lon,'fileName',fileOut);
            
            
        end
        
        function tel2vtk(fileName, timeRange)
            % converts data from telemac to paraview
            %
            % Telemac.tel2vtk(fileName, timeRange)
            %
            % Input: fileName: the name of the slf file to convert (can be
            % 2d or 3d)
            % timeRange (optional): vector with the index of the timesteps
            % to export
            
            % read header
            sct = telheadr(fileName);
            if nargin ==1
                timeRange = 1:sct.NSTEPS;
            end
            vtk_title = sct.title;
            
            if sct.NPLAN<=1
                % 2d data
                n = 1;
                colU = find(strcmpi('VELOCITY U      M/S             ',sct.RECV));
                colV = find(strcmpi('VELOCITY V      M/S             ',sct.RECV));
                if ~isempty(colU) && ~isempty(colU)
                    dataStruct(1).type = 'vector';
                    dataStruct(1).name = 'velocity';
                    dj = 1;
                else
                    dj = 0;
                end
                
                colRest = setdiff(1:length(sct.RECV),[colU,colV]);
                for j =1:length(colRest)
                    dataStruct(j+dj).type = 'scalar'; %#ok<AGROW>
                    dataStruct(j+dj).name = strtrim(sct.RECV{colRest(j)}(1:16)); %#ok<AGROW>
                    dataStruct(j+dj).name = strrep(dataStruct(j+dj).name,' ','_');%#ok<AGROW>
                end
                zero = zeros(size(sct.RESULT(:,1)));
                for i = timeRange
                    % read data
                    sct = telstepr(sct,i);
                    % add velocity (copy data to make 3d)
                    if ~isempty(colU) && ~isempty(colU)
                        dataStruct(1).data = [sct.RESULT(:,[colU, colV]),zero;sct.RESULT(:,[colU, colV]),zero];
                    end
                    for j =1:length(colRest)
                        dataStruct(j+dj).data = [sct.RESULT(:,colRest(j));sct.RESULT(:,colRest(j))]; %#ok<AGROW>
                    end
                    % add other variables (copy data to make 3d)
                    fileOut = [fileName(1:end-4),'_',num2str(n,'%04.0f'),'.vtk'];
                    % mesh (z data to zero and one)
                    grid_X = [sct.XYZ,zero;sct.XYZ,zero+1]; %#ok<FNDSB>
                    grid_TET = [sct.IKLE,sct.IKLE+sct.NPOIN];
                    % write
                    vtkWriteUnstructered(fileOut,vtk_title,grid_X,grid_TET,dataStruct);
                    n = n + 1;
                end
            else
                % 3d data
                n = 1;
                colZ = find(strcmpi('ELEVATION Z     M               ',sct.RECV));
                colU = find(strcmpi('VELOCITY U      M/S             ',sct.RECV));
                colV = find(strcmpi('VELOCITY V      M/S             ',sct.RECV));
                colW = find(strcmpi('VELOCITY W      M/S             ',sct.RECV));
                colRest = setdiff(1:length(sct.RECV),[colZ, colU,colV,colW]);
                if ~isempty(colU) && ~isempty(colV) && ~isempty(colW)
                    dataStruct(1).type = 'vector';
                    dataStruct(1).name = 'velocity';
                    dj = 1;
                else
                    dj = 0;
                end
                for j =1:length(colRest)
                    dataStruct(j+dj).type = 'scalar'; %#ok<AGROW>
                    dataStruct(j+dj).name = strtrim(sct.RECV{colRest(j)}(1:16)); %#ok<AGROW>
                    dataStruct(j+dj).name = strrep(dataStruct(j+dj).name,' ','_'); %#ok<AGROW>
                end
                for i = timeRange
                    % read data
                    sct = telstepr(sct,i);
                    % add velocity
                    if ~isempty(colU) && ~isempty(colV) && ~isempty(colW)
                        dataStruct(1).data = sct.RESULT(:,[colU, colV, colW]);
                    end
                    for j =1:length(colRest)
                        dataStruct(j+dj).data = sct.RESULT(:,colRest(j)); %#ok<AGROW>
                    end
                    % add other variables
                    fileOut = [fileName(1:end-4),'_',num2str(i,'%04.0f'),'.vtk'];
                    % mesh
                    grid_X = [sct.XYZ,sct.RESULT(:,colZ)]; %#ok<FNDSB>
                    grid_TET = sct.IKLE;
                    % write
                    vtkWriteUnstructered(fileOut,vtk_title,grid_X,grid_TET,dataStruct);
                    n = n + 1;
                end
            end
            % close the file
            fclose(sct.fid);
            
            
        end
        
        function writeKenue(theFile,theData)
            % write Bluekenue files (i2s: line files and xyz point files)
            %
            % Telemac.writeKenue(theFile,theData)
            %
            % INPUT: theFile: is a filename
            %        theData: a cell array with the data. One cell for
            % each line/dataset.
            %
            
            
            
            % determine file tyope
            [~,~,theType] = fileparts(theFile);
            
            fileType  = strtrim(theType);
            fileType = fileType(2:end);
            switch (fileType)
                case 'i2s'
                    nrCol = 2;
                case 'xyz'
                    nrCol = 3;
                otherwise
                    error('Unknown file type');
            end
            % open file
            
            fid = fopen(theFile,'w');
            
            %write header
            
            fprintf(fid,'%s\n','#########################################################################');
            fprintf(fid,'%s\n',[':FileType ',fileType,'  ASCII  EnSim 1.0']);
            fprintf(fid,'%s\n','# Canadian Hydraulics Centre/National Research Council (c) 1998-2011');
            if nrCol == 2
                fprintf(fid,'%s\n','# DataType                   2D Line Set');
            else
                fprintf(fid,'%s\n','# DataType                 XYZ Point Set');
            end
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',':Application              BlueKenue');
            fprintf(fid,'%s\n',':Version                  3.2.31');
            fprintf(fid,'%s\n',':WrittenBy                abr');
            fprintf(fid,'%s\n',[':CreationDate            ',datestr(now)]);
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n','#------------------------------------------------------------------------');
            fprintf(fid,'%s\n',':AttributeUnits 1 m');
            fprintf(fid,'%s\n',':EndHeader');
            
            %write data
            switch nrCol
                case 2
                    
                    format = '%f %f\n';
                    for i=1:length(theData)
                        
                        % check format
                        if isempty(theData{i})
                            continue
                        end
                        if size(theData{i},1)==1
                            error('Data must be organized by columns');
                        end
                        
                        if size(theData{i},2)>2
                            zVal = theData{i}(1,3:end);
                        else
                            zVal = 0;
                        end
                        fmtZ = ['%8.0f ',repmat('%f ',1,length(zVal)),'\n'];
                        fprintf(fid,fmtZ,[size(theData{i},1),zVal]);
                        fprintf(fid,format,theData{i}(:,1:2)');
                    end
                case 3
                    format = '%f %f %f\n';
                    for i=1:length(theData)
                        % check format
                        if size(theData{i},2)~=3
                            error('Data must be organized by columns');
                        end
                        fprintf(fid,format,theData{i}');
                    end
            end
            
            
            fclose(fid);
        end
        
        function writeKenueTS(theFile,theData,vTstart,DeltaT,theName)
            % write Bluekenue timeserie files (t1s: water level, t2s mag,dir)
            %
            % Telemac.writeKenueTS(theFile,theData,vTstart,deltaT)
            %
            % INPUT: theFile: is a filename (including t1s or t2s
            %        extension)
            %        theData: a vector (nx1) in case of WL, a nx2 matrix in
            %        case of velocity (mag, direction)
            %        vTstart: datenum of starttime
            %        deltaT: vector with timestap [hrs, minutes, sec]
            %        theName: name of file shown in BlueKenue (also used for title)
            %
            
            % determine file tyope
            [~,~,theType] = fileparts(theFile);
            fileType  = strtrim(theType);
            fileType = fileType(2:end);
            switch (fileType)
                case 'ts1' % assuming WL
                    sType = 'Type 1 Time Series';
                    sUnit = 'M';
                    sDef = '';
                    sFormat = '%.6f\n';
                    if size(theData,2)>1
                        error('specify input data as a nx1 vector')
                    end
                case 'ts2' % assuming VEL
                    sType = 'Type 2 Time Series';
                    sUnit = 'M/S';
                    sDef = 'MAGDIR';
                    sFormat = '%.6f %.6f\n';
                    if size(theData,2)>2
                        error('specify input data as a nx2 vector')
                    end
                otherwise
                    error('Unknown file type');
            end
            
            fid = fopen(fullfile(theFile),'w');
            fprintf(fid,'%s\n','#########################################################################');
            fprintf(fid,'%s\n',[':FileType ',fileType,'  ASCII  EnSim 1.0']);
            fprintf(fid,'%s\n','# Canadian Hydraulics Centre/National Research Council (c) 1998-2012');
            fprintf(fid,'%s\n',['# DataType                 ',sType]);
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',':Application              BlueKenue');
            fprintf(fid,'%s\n',':Version                  3.3.4');
            fprintf(fid,'%s\n',':WrittenBy                vba');
            fprintf(fid,'%s\n',':CreationDate             Wed, Dec 21, 2016 03:02 PM');
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n','#------------------------------------------------------------------------');
            fprintf(fid,'%s\n',':SourceFile   dummy.slf');
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',[':Name  ',theName]);
            fprintf(fid,'%s\n',[':Title ',theName]);
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',[':AttributeUnits 1 ',sUnit]);
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',':LocationX       0.000');
            fprintf(fid,'%s\n',':LocationY       0.000');
            fprintf(fid,'%s\n','#');
            if ~isempty(sDef)
                fprintf(fid,'%s\n',[':DataDefinition  ',sDef]);
                fprintf(fid,'%s\n','#');
            end
            fprintf(fid,'%s\n',[':StartTime       ',datestr(vTstart,'yyyy/mm/dd HH:MM:SS')]);
            fprintf(fid,'%s\n',[':DeltaT          ',num2str(DeltaT(1),'%02d'),':',num2str(DeltaT(2),'%02d'),':',num2str(DeltaT(3),'%02.2f')]);
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',':EndHeader');
            fprintf(fid,sFormat,transpose(theData));
            fclose(fid);
        end
        
        function writeNesting(outFile,nodes,t,h,u,v,trac,isQ)
            % writes imdc style nesting file
            %
            % Telemac.writeNesting(outFile,nodes,t,h,u,v,trac,isQ)
            %
            % INPUT:
            %  - outFile: file to write
            %  - nodes: array with nodes
            %  - t : array with the time (seconds since start of model) [nrT x 1]
            %  - h : array with the water level [nrT x nrNode]
            %  - u : array with u velocity      [nrT x nrNode]
            %  - v : array with v velocity      [nrT x nrNode]
            %  - trac : (optional) array with tracers   [nrT x nrNode x nrTrac]
            %  -isQ: (optional) if true discharge (q=u*h) is written to the
            %  file
            
            if nargin<7
                nrTrac = 0;
            elseif ~isempty(trac)
                nrTrac = size(trac,3);
            else
                nrTrac = 0;
            end
            if nargin < 8
                isQ = false;
            end
            fid = fopen(outFile,'w');
            if isQ
                fprintf(fid,'%s\n','OBCFILEQ');
            else
                fprintf(fid,'%s\n','OBCFILE');
            end
            fprintf(fid,'%8.0f\n',length(nodes));
            fmt = [repmat('%8.0f ',1,length(nodes)),'\n'];
            fprintf(fid,fmt,nodes);
            fmt = [repmat('%10.6f ',1,length(nodes)),'\n'];
            for i=1:length(t)
                fprintf(fid,'%10.2f\n',t(i));
                fprintf(fid,fmt,h(i,:));
                fprintf(fid,fmt,u(i,:));
                fprintf(fid,fmt,v(i,:));
                for j=1:nrTrac
                    fprintf(fid,fmt,trac(i,:,j));
                end
            end
            fclose(fid);
            
        end
        
        function writeBinaryBnd(outFile,nodes,t,h,u,v,trac,tracers,slfNew,tStart)
            % writes binary boundary file
            %
            % writeBinaryBnd(outFile,nodes,t,h,u,v,trac,tracers,slfNew,tStart)
            %
            % Port of convertToBND.py
            %
            % INPUT:
            %  - outFile: file to write
            %  - nodes: array with nodes
            % if 2D (not yet implemented)
            %  - t : array with the time (seconds since start of model) [nrT x 1]
            %  - h : array with the water level [nrT x nrNode]
            %  - u : array with u velocity      [nrT x nrNode]
            %  - v : array with v velocity      [nrT x nrNode]
            %  - trac : (optional) array with tracers   [nrT x nrNode x nrTrac]
            % if 3D:
            %  - t : array with the time (seconds since start of model) [nrT x 1]
            %  - h : array with the water level [nrT x nrZ x nrNode]
            %  - u : array with u velocity      [nrT x nrZ x nrNode]
            %  - v : array with v velocity      [nrT x nrZ x nrNode]
            %  - trac : (optional) array with tracers   [nrT x nrZ x nrNode x nrTrac]
            %  - slfNew: Selafin file of new mesh
            % - tStart; starttime in datenum format
            %
            
            
            
            BOR = nodes;
            % Find corresponding (x,y) in corresponding new mesh
            [ds,geo,varNames] = Telemac.readTelemacHeader(slfNew);
            %             bat = ds.BotZ.data(BOR);
            
            %    % Extract triangles and weigths in 2D
            %    support2d = []
            %    ibar = 0;
            %    for xyi = xys:
            %       support2d.append(xysLocateMesh(xyi,slf.IKLE2,slf.MESHX,slf.MESHY,slf.tree,slf.neighbours))
            %
            % %     Extract support in 3D
            %    support3d = zip(support2d,len(xys)*[range(slf.NPLAN)])
            %
            % Write BND header
            bnd = struct;
            % Meta data and variable names
            bnd.title = '';
            bnd.type = 'seraphin';
            bnd.NBV = 3+numel(tracers);
            bnd.NBV1 = 3 + numel(tracers);
            % /!\ ELEVATION has to be the first variable
            % (for possible vertical re-interpolation within TELEMAC)
            for i = 1:numel(tracers)
                if numel(tracers{i} < 32)
                    tracers{i} = [tracers{i} repelem(' ',32 - numel(tracers{i}))];
                end
            end
            bnd.RECV = [{
                'ELEVATION Z     M               '
                'VELOCITY U      M/S             '
                'VELOCITY V      M/S             '
                }' tracers(:)'];
            
            
            bnd.NVAR = bnd.NBV1;
            bnd.VARINDEX = max(bnd.NVAR)-min(bnd.NVAR);
            
            switch ndims(h)
                case 3
                    fprintf('3D mode\n');
                    %            Sizes and mesh connectivity
                    bnd.NPLAN = size(h,2);
                    bnd.NDP2 = 2;
                    bnd.NDP3 = 4;
                    bnd.NDP = bnd.NDP3;
                    bnd.NPOIN2 = numel(BOR);
                    bnd.NPOIN3 = bnd.NPOIN2*bnd.NPLAN;
                    bnd.NPOIN = bnd.NPOIN3;
                    bnd.IPARAM = [0,0,0,0,0,0,bnd.NPLAN,0,0,0];
                    if nargin == 10
                        bnd.IPARAM(10) = 1;
                        bnd.IDATE = datevec(tStart);
                    end
                    bnd.IPOB2 = BOR;   % /!\ Note that IPOBO keeps the original numbering
                    ovcon = geo.IKLE(sum(reshape(ismember(geo.IKLE,BOR),geo.NELEM,geo.NDP),2)==3,:);
                    if ~isempty(ovcon);
                        erStr = ['somewhere in nodes ' sprintf('%u;',ovcon(:)') '.'];
                        error(['Input mesh has overconstrained elements (all 3 nodes on border). Please fix ' erStr]);
                    end
                    
                    MASK = geo.IKLE(sum(reshape(ismember(geo.IKLE,BOR),geo.NELEM,geo.NDP),2)==2,:);
                    
                    m1 = MASK';
                    m2 =(ismember(MASK,sort(BOR)))';
                    IKLE = reshape(m1(m2),2,size(MASK,1))';
                    KNOLG = unique(IKLE);
                    KNOGL = [KNOLG(:) (1:numel(KNOLG))'];
                    bnd.IKLE2 = -1 * ones(size(IKLE));
                    for k = 1:size(IKLE,1)
                        bnd.IKLE2(k,:) = [KNOGL(find(KNOGL(:,1)==IKLE(k,1)),2) KNOGL(find(KNOGL(:,1)==IKLE(k,2)),2)];
                    end
                    bnd.NELEM2 = size(bnd.IKLE2,1);
                    
                    bnd.IPOB3 = [];
                    for j = 1:bnd.NPLAN
                        bnd.IPOB3 = [bnd.IPOB3; bnd.IPOB2+bnd.NPOIN2*(j-1)];
                    end
                    %                     bnd.IKLE3 = reshape(repelem(bnd.NPOIN2*(0:(bnd.NPLAN-2)),bnd.NELEM2*bnd.NDP3),bnd.NDP3,[])'+...
                    %                         repmat((repmat(bnd.IKLE2,1,2)+repelem([0 1],bnd.NDP2)*bnd.NPOIN2),bnd.NPLAN-1,1);
                    bnd.IKLE3 = reshape(repelem(bnd.NPOIN2*(0:(bnd.NPLAN-2)),bnd.NELEM2*bnd.NDP3),bnd.NDP3,[])'+...
                        repmat((repmat(bnd.IKLE2,1,2)+repmat(repelem([0 1],bnd.NDP2),bnd.NELEM2,1)*bnd.NPOIN2),bnd.NPLAN-1,1);
                    
                    %    # Last few numbers
                    
                    bnd.XYZ = repmat(geo.XYZ(BOR,:),bnd.NPLAN,1);
                    bnd.IKLE = bnd.IKLE3;
                    bnd.IPOBO = bnd.IPOB3;
                    bnd.NELEM3 = bnd.NELEM2*(bnd.NPLAN-1);
                    bnd.NELEM = bnd.NELEM3;
                    bnd.timestep = diff(t([1 2]));
                    % Writing bnd header
                    fid = telheadw(bnd,outFile);
                    
                    % Write BND core - write the data
                    for i = 1:numel(t)
                        bnd.AT = t(i);
                        bnd.RESULT = [...
                            reshape(squeeze(h(i,:,:))',[],1) ...
                            reshape(squeeze(u(i,:,:))',[],1) ...
                            reshape(squeeze(v(i,:,:))',[],1) ...
                            reshape(squeeze(permute(trac(i,:,:,:),[1 3 2 4])),[],numel(tracers))];
                        fid = telstepw(bnd,fid);
                        if any(isnan(bnd.RESULT(:)))
                            error('NaNs in written Selafin data. Telemac will crash.');
                        end
                        
                    end
                    fclose(fid);
                case 2
                    error('2D mode not yet implemented');
            end
            
        end
        
        function writeT3s(theFile,ikle,xy)
            % Writes a T3S file (BlueKenue)
            %
            % Telemac.writeT3s(theFile,ikle,xy)
            %
            % #INPUTS:
            % theFile: the filename
            % xy Matrix with x and y coordinates of the nodes (Nx2)
            % ikle: Matrix with the connecions between the edges  (Mx3)         -
            %
            %
            % #OUTPUTS:
            %
            % #STEPS:
            % #KNOWN ISSUES:
            %
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 10/7/2012
            % Modified by:
            % Date:
            
            %1.) Open file and read header
            
            fid = fopen(theFile,'w');
            
            nrNodes =  size(xy,1);
            nrValues = size(xy,2);
            nrElements = size(ikle,1);
            
            % write header
            fprintf(fid,'%s\n','##############################');
            fprintf(fid,'%s\n',':FileType t3s ASCII EnSim 1.0');
            fprintf(fid,'%s\n','');
            fprintf(fid,'%s\n','#');
            for i = 1:nrValues-2
                fprintf(fid,'%s\n',[':AttributeName ',num2str(i),' unknown']);
            end
            fprintf(fid,'%s\n','#');
            fprintf(fid,'%s\n',[':CreationDate ',datestr(now)]);
            fprintf(fid,'%s\n',[':NodeCount ',num2str(nrNodes)]);
            fprintf(fid,'%s\n',[':ElementCount ',num2str(nrElements)]);
            fprintf(fid,'%s\n',':ElementType T3');
            fprintf(fid,'%s\n',':EndHeader');
            
            % write XY coordinates
            theFormat = [repmat('%f ',1,nrValues) ,'\n'];
            fprintf(fid,theFormat,xy');
            % write connections
            fprintf(fid,'%4.0f %4.0f %4.0f \n',ikle');
            
            fclose(fid);
            
        end
        
        function writeMeteo(inFile,outFile,meteoFiles,sctOpt)
            % converts meteo data to selafin files
            % replaces  writeWindPressure2Slf
            %
            % writeMeteo(inFile,outFile,meteoFiles,sctOpt)
            %
            % INPUT
            %  - inFile: selefin mesh file
            %  - outFile: selafin file with meteo data
            %  - meteoFiles: cellArrray with filenames of input data to use
            %  - sctOpt: structure with fields:
            %        -type: input file format. default is 'era'
            %        -outVar: cellArray with varnames in Telemac
            %        -inVar: cellArray with varnames in meteoFiles
            %        -telCoor: coordinate system used in telemac. Options as
            %        'lonlat','mercator' and 'espg'
            %        -lon0: zero longitude for mercator system
            %        -lat0: zero latitude for mercator system
            %        -CS1: CS1 code for coordinate transform
            %        - ignoreOutside: if true, then wind outside the model domain is not used. default is true.
            %        -copyVars: copy variables from input selafin file to
            %        output
            %        -tStart: starttime (Matlab time format)
            %        -tEnd  : lasttime (Matlab time format)
            %        -convertFunc : cell array of  function handles to a function used to
            %        convert the data.
            % OUTPUT
            
            % set defaults
            sctOpt = Util.setDefault(sctOpt,'type','era');
            sctOpt = Util.setDefault(sctOpt,'outVar',{
                'WIND VELOCITY U '
                'WIND VELOCITY V '
                'PRESSURE        '
                });
            sctOpt = Util.setDefault(sctOpt,'inVar',{
                'u10'
                'v10'
                'sp'
                });
            nrVar    = length(sctOpt.inVar);
            
            sctOpt = Util.setDefault(sctOpt,'convertFunc',cell(nrVar,1));
            
            sctOpt = Util.setDefault(sctOpt,'ignoreOutside','true');
            
            
            % read input telemac file
            sctTel = telheadr(inFile);
            sctTel = telstepr(sctTel,1);
            x = sctTel.XYZ(:,1);
            y = sctTel.XYZ(:,2);
            
            % coordinate conversions for telemac (todo add more
            
            switch lower(sctOpt.telCoor)
                case 'latlon'
                    lonTel = x;
                    latTel = y;
                case 'mercator'
                    [lonTel,latTel] = Telemac.mercator2spherical(x,y,sctOpt.lon0,sctOpt.lat0);
                case 'espg'
                    [lonTel,latTel]=convertCoordinates(x,y,'CS1.code',sctOpt.CS1,'CS2.code',4326);
                otherwise
                    error('unknown coordinate system');
            end
            
            % get outer boundary
            if (sctOpt.ignoreOutside)
                tmp = Telemac.getBoundary(sctTel,true);
                lonBound = lonTel(tmp{1});
                latBound = latTel(tmp{1});
            end
            
            % read times in the data
            nrFiles = length(meteoFiles);
            meteoData = struct;
            for iFile = 1:nrFiles
                switch sctOpt.type
                    case 'era'
                        meteoData = Telemac.readEraHeader(meteoFiles{iFile},meteoData);
                    case 'telemac'
                        % some other function
                        % TODO
                    case 'imdc'
                        % TODO
                    case 'navgem'
                        % TODO
                    otherwise
                        error('Unknown input');
                end
            end
            % convert time to matlab time
            
            nrTime   = length(meteoData.t);
            nrLonLat = size(meteoData.lon);
            
            
           
            % prepare interpolation
            if (sctOpt.ignoreOutside)
                maskMeteo  = inpoly([meteoData.lon(:),meteoData.lat(:)],[lonBound,latBound]);
                % prepare interpolation
                tmpLon = double(meteoData.lon(maskMeteo));
                tmpLat = double(meteoData.lat(maskMeteo));
                Finterp = scatteredInterpolant(tmpLon,tmpLat,tmpLat,'linear','linear');
            end
            
            %determine start and end time of the data
            timeStart = 1;
            timeStop  = nrTime;
            
            if isfield(sctOpt,'tStart')
                tmp  = find(meteoData.t>=sctOpt.tStart,1,'first');
                if ~isempty(tmp)
                    timeStart = tmp;
                end
            end
            
            if isfield(sctOpt,'tEnd')
                tmp  = find(meteoData.t<=sctOpt.tEnd,1,'last');
                if ~isempty(tmp)
                    timeStop = tmp;
                end
            end

            % convert to telemac time
            sctTel.IDATE = datevec(meteoData.t(timeStart));
            sctTel.IPARAM(10) = 1;
            meteoData.t  = (meteoData.t-meteoData.t(timeStart))*86400;
            
            % telemac file to write
            sctTel.NBV = length(sctOpt.inVar);
            sctTel.RECV = sctOpt.outVar;
            fid  = telheadw(sctTel,outFile);
            

            % START OF THE TIME LOOP
            hWait = waitbar(0,'adding Meteo');
            for iTime = timeStart:timeStop
                % read meteo
                waitbar((iTime-timeStart)/(timeStop-timeStart),hWait);
                switch lower(sctOpt.type)
                    case 'era'
                        meteoData = Telemac.readEra(meteoData,meteoFiles,iTime,sctOpt.inVar,nrLonLat);
                    case 'telemac'
                        % some other function
                        % TODO
                    case 'imdc'
                        % TODO
                    case 'navgem'
                        % TODO
                end
                    
                
                % add data to telemac structure
                sctTel.AT = meteoData.t(iTime);
                for iVar = nrVar:-1:1
                    varName = sctOpt.inVar{iVar};                    
                    % apply conversions
                    if ~isempty(sctOpt.convertFunc{iVar})
                        meteoData.(varName) = sctOpt.convertFunc{iVar}(meteoData.(varName));
                    end
                    % interpolate
                    if (sctOpt.ignoreOutside)
                        Finterp.Values = meteoData.(varName)(maskMeteo);
                        intVar = Finterp(lonTel,latTel);
                    else
                        intVar = interp2(meteoData.lon',meteoData.lat',meteoData.(varName)',lonTel,latTel);
                    end
                    % add
                    sctTel.RESULT(:,iVar) = intVar;
                end
                % write telemac data
                fid = telstepw(sctTel,fid);
                
            end
            % clsoe selafin file
            fclose(fid);
            close(hWait);
            
        end
        
        
        function writeWindPressure2Slf(OPT)
            % The script writes wind and pressure data to 2D or 3D SLF file. Inputs required
            % are as follows:
            % Check test file before using.
            % OPT.slfFileIn : Path of the slf file already created with the variable
            %                 'BOTTOM'.
            % OPT.slfFileOut: Path of the result slf file (with the name of the new file required)
            % ================
            % For ECMWF data:
            % OPT.dataSource = 1;
            %
            % OPT.dataPath = Path to NetCDF files from ECMWF (1 nc file containing msl
            %                pressure and wind u & v data);
            %
            % ================
            % For IMDC format Mat files:
            % OPT.dataSource = 2;
            % OPT.timeRange  = time to output
            %
            % OPT.dataPath.uwnd = Path to IMDC formatted mat file with U Wind data.
            % OPT.dataPath.vwnd = Path to IMDC formatted mat file with V Wind data.
            % OPT.dataPath.atmp = Path to IMDC formatted mat file with atm Pressure data.
            %
            %                   IMDC data format should have following
            %                   variables: Each dataset should have
            %                   variables 'data' and 'metadata'. Data
            %                   structure should contain following format:
            %                   Time, Lat, Lon and the reqd. variable with
            %                   name:
            %                   Time
            %                   Lat = Latitude
            %                   Lon = Longitude
            %                   WindVelX = Wind U direction
            %                   WindVelY = Wind V direction
            %                   AirPress = Atmospheric Pressure
            %
            % OPT.slfSys : EPSG Code for the coordinate system of the SLF file.
            %              If not provided, it is assumed it is in WGS 84 spherical
            %              coordinate system (EPSG: 4326).
            %              It is assumed that the data to be interpolated is always in
            %              WGS 84 spherical coordinate system (EPSG:4326)
            % OPT.mercator: optional field containing lon0 and lat0 to
            %               transform mercator coordinate system to WGS84
            % OPT.version: optional field ('without_bottom' or
            %                'with_bottom')
            %               'without_bottom': creates a slf file with only
            %               wind field
            %               'with_bottom': leaves other map fields in slf
            %               file
            % OPT.variables: list of variables to interpolate. Default:
            % {
            %                 'WIND VELOCITY U '
            %                 'WIND VELOCITY V '
            %                 'PRESSURE        '
            %                 }
            %
            %% Set default variables
            OPT = Util.setDefault(OPT,'variables',{
                'WIND VELOCITY U '
                'WIND VELOCITY V '
                'PRESSURE        '
                });
            OPT = Util.setDefault(OPT,'timeRange',[-inf inf]);
            OPT = Util.setDefault(OPT,'append',false);
            
            imdcTelMap = {
                'WIND ALONG X    M/S             ' 'WindVelX'
                'WIND ALONG Y    M/S             ' 'WindVelY'
                'WIND VELOCITY U ' 'WindVelX'
                'WIND VELOCITY V ' 'WindVelY'
                'PRESSURE        ' 'AirPress'
                'AIR TEMPERATURE ' 'AirTemp'
                'RELATIVEHUMIDITY' 'RelHumid'
                'NEBULOSITY      ' 'Nebulosity'
                };
            imdc2Tel = containers.Map(imdcTelMap(:,2),imdcTelMap(:,1));
            tel2Imdc = containers.Map(imdcTelMap(:,1),imdcTelMap(:,2));
            
            %%
            if ~OPT.append
                copyfile(OPT.slfFileIn,OPT.slfFileOut); % Create a copy of the file
            end
            % Read Telemac grid
            slfPath = OPT.slfFileOut;
            slfTel = telheadr(slfPath);
            % for utm
            if isfield(OPT,'slfSys')
                [lonTel,latTel] = convertCoordinates(slfTel.XYZ(:,1),slfTel.XYZ(:,2),'CS1.code',OPT.slfSys,'CS2.code',4326);
            end
            if isfield(OPT,'mercator')
                [lonTel,latTel]=Telemac.mercator2spherical(slfTel.XYZ(:,1),slfTel.XYZ(:,2),OPT.mercator.long0,OPT.mercator.lat0);
            end
            if ~exist('lonTel','var')>0
                lonTel = slfTel.XYZ(:,1);
                latTel = slfTel.XYZ(:,2);
            end
            %% Read Data
            % netcdf files
            if OPT.dataSource == 1
                t = nc2struct(OPT.dataPath);
                % sort dates
                [t.datenum,I_t]=sort(t.datenum);
                t.time=t.time(I_t);
                st=size(t.datenum);
                f_names = fieldnames(t);
                for i_f=1:numel(f_names) % sort mapdata
                    s1=size(t.(f_names{i_f}));
                    if numel(s1)==3
                        if s1(1)==st(1)
                            t.(f_names{i_f})=t.(f_names{i_f})(I_t,:,:);
                        end
                    end
                end
                % Look for time variable
                timenc = t.time;
                
                lon = t.longitude;
                lon(lon>180)=lon(lon>180)-360;
                %                 lon = lon-360;
                lat = t.latitude;
                
                time = t.datenum;
                
                
                % Read in necessary data per variable
                for i = 1:numel(OPT.variables)
                    telName = OPT.variables{i};
                    imdcName = tel2Imdc(telName);
                    
                    ds.(imdcName).Lon.data = lon;
                    ds.(imdcName).Lat.data = lat;
                    ds.(imdcName).Time.data = timenc;
                    
                    switch imdcName
                        case 'WindVelX'
                            ds.(imdcName).(imdcName).data = t.u10;
                        case 'WindVelY'
                            ds.(imdcName).(imdcName).data = t.v10;
                        case 'AirPress'
                            ds.(imdcName).(imdcName).data = t.msl;
                        case 'AirTemp'
                            ds.(imdcName).(imdcName).data = t.t2m-273.15;
                        case 'Nebulosity'
                            ds.(imdcName).(imdcName).data = t.tcc*8;
                        case 'RelHumid'
                            tDew = t.d2m;
                            tS = t.t2m;
                            pS = t.sp;
                            RdryoRvap = 0.621981;
                            
                            eSat = 611.21 .* exp(17.502 * (tDew-273.16)./(tDew+0.7));
                            e = 611.21 .* exp(17.502 * (tS-273.16)./(tS+0.7));
                            hrel = 100*eSat./e;
                            ds.(imdcName).(imdcName).data = hrel;
                        otherwise
                            error('Unknown variable name %s',imdcName);
                    end
                end
                
                % imdc format mat files
            elseif OPT.dataSource == 2
                if length(fieldnames(OPT.dataPath)) < 3
                    error('Data path missing. Please provide 3 file paths for the 3 datasets')
                else
                    WindX  = load(OPT.dataPath.uwnd);
                    WindY = load(OPT.dataPath.vwnd);
                    AirP = load(OPT.dataPath.atmp);
                end
                timenc = WindX.data.Time;
                lon = WindX.data.Lon;
                lat = WindX.data.Lat;
                
                lonP = AirP.data.Lon; % Air pressure may have different spatial resolution than wind data (e.g, if downloaded from CFSR)
                latP = AirP.data.Lat;
                
                uWind = WindX.data.WindVelX;
                vWind = WindY.data.WindVelY;
                mslPres = AirP.data.AirPress;
                diffT(1,1) = numel(timenc)-size(uWind,1);
                diffT(2,1) = numel(timenc)-size(vWind,1);
                diffT(3,1) = numel(timenc)-size(mslPres,1);
                if sum(diffT) > 0
                    error('No. of timesteps is not equal to the number of data timesteps. Please check input data.')
                end
                
                timeStart = WindX.data.Time(1);
                timeDiff = WindX.data.Time(2)-WindX.data.Time(1);
                DT = timeDiff*24*60*60;
                % telemac files
            elseif OPT.dataSource==3
                
                for i = 1:numel(OPT.variables)
                    telName = OPT.variables{i};
                    imdcName = tel2Imdc(telName);
                    
                    ds.(imdcName) = Dataset.loadData(OPT.dataPath.(imdcName));
                    
                    % Variable-specific hacks
                    switch imdcName
                        case 'Nebulosity'
                            ds.(imdcName) = Dataset.loadData(OPT.dataPath.AirPress);
                            ds.Nebulosity.Nebulosity.data = OPT.standardNebu ...
                                * ones(size(ds.Nebulosity.AirPress.data));
                            ds.Nebulosity = rmfield(ds.Nebulosity,'AirPress');
                        otherwise
                    end
                    
                    
                    if i ==1
                        time = ds.(imdcName).Time.data;
                    else
                        if ~isequal(time,ds.(imdcName).Time.data)
                            error('Time vectors in different variables don''t match');
                        end
                    end
                    
                    
                end
                
                
                if isfield(ds,'RelHumid') && ~isfield(ds.RelHumid,'RelHumid')
                    
                    % Interpolate air pressure onto humidity spatial grid
                    ds.RelHumid.AirPress.data = nan(size(ds.RelHumid.SpecHumid.data));
                    [LON,LAT] = meshgrid(ds.RelHumid.Lon.data,ds.RelHumid.Lat.data);
                    for itt = 1:size(ds.RelHumid.AirPress.data,1)
                        ds.RelHumid.AirPress.data(itt,:,:) = interp2(...
                            ds.AirPress.Lon.data,ds.AirPress.Lat.data,...
                            squeeze(ds.AirPress.AirPress.data(itt,:,:)),...
                            LON,LAT);
                    end
                    ds.RelHumid.AirPress.data(1)
                    ds.RelHumid.SpecHumid.data(1)
                    ds.AirTemp.AirTemp.data(1)
                    
                    ds.RelHumid.RelHumid.data = 0.263 * ds.RelHumid.AirPress.data .* ...
                        ds.RelHumid.SpecHumid.data .* ...
                        exp( (17.67*(ds.AirTemp.AirTemp.data - 273.16)) ./ ...
                        (ds.AirTemp.AirTemp.data - 29.65)).^(-1);
                    ds.RelHumid.RelHumid.data(ds.RelHumid.RelHumid.data>100)=100;
                end
                if median(ds.AirTemp.AirTemp.data(:))>200
                    ds.AirTemp.AirTemp.data = ds.AirTemp.AirTemp.data -273.16;
                end
                
                % CFRS .d file
            elseif OPT.dataSource==4
                % determine filenames
                sctTmp = GlobalModel.navgemNames(OPT.dataPath.allData);
                % read data
                [mask,lon,lat,time] = GlobalData.readFileD(opt.dataPath.landMaskFile,1);
                for i=length(time):-1:1
                    tmp = GlobalData.readFileD(sctTmp.wind.path,i,2);
                    u = tmp(:,:,1);
                    u(mask==1) = nan;
                    v = tmp(:,:,2);
                    v(mask==1) = nan;
                    ds.WindVelX.WindVelX.data(:,:,i) = u;
                    ds.WindVelY.WindVelY.data(:,:,i) = v;
                    tmp = GlobalData.readFileD(sctTmp.pres.path,i,1);
                    p = tmp(:,:,1);
                    p(mask==1) = nan;
                    ds.AirPress.AirPress.data(:,:,i) = p;
                    tmp = GlobalData.readFileD(sctTmp.temp.path,i,4);
                    t = tmp(:,:,1);
                    t(mask==1) = nan;
                    r = tmp(:,:,1);
                    r(mask==1) = nan;
                    ds.AirTemp.AirTemp.data(:,:,i) = t;
                    ds.RelHumid.RelHumid.data(:,:,i) =r;
                end
                ds.Nebulosity.Nebulosity.data = OPT.standardNebu.*ones(size(ds.AirPress.AirPress.data));
                % add to structure
                allFields = fieldnames(ds);
                for i =1:length(allFields)
                    ds.(allFields{i}).Lon.data = lon;
                    ds.(allFields{i}).data = lat;
                end
                
            else
                
                error('Data source not specified. Put OPT.dataSource as 1 (ECMWF),2 (IMDC mat format, 1 var per file) or 3 (IMDC format, 1 file for all vars) or 4 .d file')
            end
            
            %% Clip to time range
            mask = time >= OPT.timeRange(1) & time <= OPT.timeRange(2);
            time = time(mask);
            for i = 1:numel(OPT.variables)
                telName = OPT.variables{i};
                imdcName = tel2Imdc(telName);
                ds.(imdcName).(imdcName).data = ds.(imdcName).(imdcName).data(mask,:,:);
            end
            
            dft = diff(time);
            if any(dft==0)
                error('Time vector in forcing file contains duplicates.')
            end
            if std(dft)/mean(dft)>0.01
                error('Time vector not sufficiently uniform.');
            end
            
            timeStart = time(1);
            timeDiff = time(2)-time(1);
            DT = timeDiff*24*60*60;
            %% Write slf file
            if isfield(OPT,'version')
                version=OPT.version;
            else
                version='with_bottom';
            end
            if strcmpi(version,'with_bottom') && ~OPT.append
                slfTel.RECV = [slfTel.RECV ; OPT.variables];
            elseif strcmpi(version,'without_bottom')
                slfTel.RECV = OPT.variables;
            end
            slfTel.NBV = numel(slfTel.RECV);
            
            inds = nan(numel(OPT.variables),1);
            for i = 1:numel(OPT.variables)
                inds(i) = find(strcmp(slfTel.RECV,OPT.variables{i}));
            end
            if ~OPT.append
                fid = telheadw(slfTel,OPT.slfFileOut);
                NSTEPS = 0;
            else
                slfTmp = telheadr(OPT.slfFileOut);
                fid = fopen(OPT.slfFileOut,'ab','b');
                NSTEPS = slfTmp.NSTEPS;
            end
            
            slfTel.IDATE = datevec(timeStart);
            h = waitbar(0,'progress');
            for index = 1:numel(time)
                waitbar(index / numel(time),h,['Writing Block : ' num2str(index) '/' num2str(numel(time)) ' ...'])
                
                %                 % add wind if needed
                %                 if ~any(strncmp('WIND ALONG X',slfTel.RECV,12))
                %                     slfTel.RECV(end+1:end+3) = {'WIND ALONG X';'WIND ALONG Y';'PRESSURE'};
                %                     slfTel.RESULT(:,end+1:end+3) = 0;
                %                     slfTel.NBV = slfTel.NBV  + 3;
                %                 end
                
                for i = 1:numel(OPT.variables)
                    telName = OPT.variables{i};
                    imdcName = tel2Imdc(telName);
                    
                    numdat = squeeze(ds.(imdcName).(imdcName).data(index,:,:));
                    % Interpolate;
                    interdat = interp2(...
                        ds.(imdcName).Lon.data,...
                        ds.(imdcName).Lat.data,...
                        numdat,...
                        lonTel,latTel);
                    slfTel.RESULT(:,inds(i)) = interdat;
                end
                slfTel.IDATE = datevec(timeStart);
                
                slfTel.AT = (NSTEPS+index-1)*DT;
                
                if any(isnan(slfTel.RESULT(:)))
                    error('NaNs in written Selafin data. Telemac will crash.');
                end
                fid = telstepw(slfTel,fid);
                
            end
            close(h)
            fclose(slfTel.fid);
            fclose(fid);
            fclose('all');
            
        end
        
        function nestingFromSlf(slfFile,cliFile,dataSlfFile,outFile,sctOptions)
            % interpolates boundary files from a slfFile
            %
            % sctOptions.nrT
            % sctOptions,'nrTracer
            % sctOptions,'tracerVal'
            % sctOptions.epsgChild
            % sctOptions.lon0,sctOptions.lat0
            % sctOptions,boundaryName
            
            
            
            if nargin<=4
                sctOptions = struct;
            end
            
            sctOptions = Util.setDefault(sctOptions,'boundaryName','Boundary');
            % read mesh and clifile
            sctTel = telheadr(slfFile);
            cliData = Telemac.readCli(cliFile,sctOptions.boundaryName);
            
            
            % coordinate transformation INPLEMENT MORE
            if isfield(sctOptions,'epsgChild')
                addOpenEarth;
                % convert to latlon
                [lon,lat]=convertCoordinates(sctTel.XYZ(:,1),sctTel.XYZ(:,2),'CS1.code',sctOptions.epsgChild,'CS2.code',4326);
                % convert to mercator for Telemac
                [x,y] = Telemac.spherical2mercator(lon,lat,sctOptions.lon0,sctOptions.lat0);
            else
                x = sctTel.XYZ(:,1);
                y = sctTel.XYZ(:,2);
            end
            
            %process clifile
            mask   = cliData(:,14)>0;
            nodeNr = cliData(mask,12);
            xObc = x(nodeNr);
            yObc = y(nodeNr);
            
            
            % tracer
            sctOptions = Util.setDefault(sctOptions,'nrTracer',0);
            sctOptions = Util.setDefault(sctOptions,'tracerVal',0);
            
            % getdata
            sctData = telheadr(dataSlfFile);
            sctOptions = Util.setDefault(sctOptions,'nrT',sctData.NSTEPS);
            nrT = sctOptions.nrT;
            indWl = Telemac.findVar('FREE SURFACE', sctData);
            indU  = Telemac.findVar('VELOCITY V', sctData);
            indV  = Telemac.findVar('VELOCITY U', sctData);
            
            % interpolation coefficients
            sctInterp = Triangle.interpTrianglePrepare(sctData.IKLE,sctData.XYZ(:,1),sctData.XYZ(:,2),xObc,yObc);
            
            
            % preallocate
            nrP =  length(xObc);
            t   =  zeros(nrT,1);
            wl  =  zeros(nrP,nrT);
            u   =  zeros(nrP,nrT);
            v   =  zeros(nrP,nrT);
            % read data
            for i = 1:nrT
                sctData = telstepr(sctData,i);
                t(i)    = sctData.AT;
                u(:,i)  = Triangle.interpTriangle(sctInterp,sctData.RESULT(:,indU));
                v(:,i)  = Triangle.interpTriangle(sctInterp,sctData.RESULT(:,indV));
                wl(:,i) = Triangle.interpTriangle(sctInterp,sctData.RESULT(:,indWl));
            end
            % check nans
            if any(isnan(wl(:))|isnan(u(:))|isnan(v(:)))
                error('Nans found in interpolation data');
            end
            
            % write boundary file
            fid = fopen(outFile,'w');
            % write header
            fprintf(fid,'%s\n','OBCFILE');
            fprintf(fid,'%8.0f\n',nrP);
            fprintf(fid,'%8.0f',nodeNr);
            fprintf(fid,'%s\n','');
            % write time data
            for i=1:nrT
                fprintf(fid,'%8.0f\n',t(i));
                fprintf(fid,'%8.4f',wl(:,i));
                fprintf(fid,'%s\n','');
                fprintf(fid,'%8.4f',u(:,i));
                fprintf(fid,'%s\n','');
                fprintf(fid,'%8.4f',v(:,i));
                fprintf(fid,'%s\n','');
                for iTrac = 1:sctOptions.nrTracer
                    fprintf(fid,'%8.4f',sctOptions.tracerVal.*ones(nrP,1));
                    fprintf(fid,'%s\n','');
                end
            end
            fclose(fid);
            
            
        end
        
        function data = readTxycq(fileName)
            % reads a txycq file
            %
            % data = readTxycq(fileName)
            %
            % INPUT:
            % -fileName: name of the file to read
            %
            % OUTPUT:
            % - data: a structure with the fields:
            %   - t,x,y,q,c: coluimn vectors with data
            %   - type: Source type (integer)
            %   - flags: Source flags
            %
            
            fid = fopen(fileName);
            % read header
            theLine = fgetl(fid);
            NUM_VAR = 1e7;
            nrFrac = str2num(theLine(29:30));
            
            % preallocate
            t = zeros(NUM_VAR,1);
            q = zeros(NUM_VAR,1);
            x = zeros(NUM_VAR,1);
            y = zeros(NUM_VAR,1);
            c = zeros(NUM_VAR,nrFrac);
            
            i = 0;
            while true
                %read t x y q ci
                theLine = fgetl(fid);
                if (~ischar(theLine)) || (isempty(theLine))
                    break;
                end
                theData = str2num(theLine);
                i = i + 1;
                t(i) = theData(1);
                x(i) = theData(2);
                y(i) = theData(3);
                q(i) = theData(4);
                c(i,:) = theData(5:end);
                
                % ignore flags (for now)
                %                 theLine = fgetl(fid);
                typeLine = textscan(fgetl(fid),'%u %u',1);
                type(i) = typeLine{1};
                numFlags = typeLine{2};
                flags{i} = cell2mat(textscan(fgetl(fid),repmat('%f ',1,numFlags),1));
                
            end
            
            % close file
            fclose(fid);
            
            % merge data in a structure
            data.t = t(1:i);
            data.x = x(1:i);
            data.y = y(1:i);
            data.q = q(1:i);
            data.c = c(1:i,:);
            data.flag = type(1:i);
            data.flagPar= flags(1:i);
        end
        
        function writeTxycq(fileName,data)
            % write txycq file
            %
            % writeTxycq(fileName,data)
            %
            % INPUT
            %  - fileName: the name of the file to be written (should be source with a
            %  nummer)
            %  - data: structure with the data to be written. It has the following
            %          fields:
            %    -- t,x,y,q: column vectors with time, coordinates and discharge
            %    -- c: nTxnF matrix with concentrations for each fraction
            %    -- tempSal(optional): nTxnF matrix with values of other released
            %    tracers (such as temperature and salinity)
            %    --: flag: column vector with type of parameter model
            %      -- 1: sigma prof
            %      -- 2: z prof
            %      -- 3: plume model TSHD by BDC
            %      -- 4: propellor wash
            %      -- 5: sigma prof for tracer (temperature salinity)
            %      -- 6: deap sea near field model
            %    --: flagPar: cell array with flag parameters (depending on
            %    the flag)
            %  flag 1 and 5: first sigma coordinates then relative
            %  concentration for each sigma point
            %  flag 2: depth of top layer, depth om bottom layer (both in
            %  m) and fraction in top and bottom layer rest is in the
            %  moiddle layer
            % flag 3: overflow diameter, ship length and shipt depth; I do
            % not remember the right order. look up in Fortran code
            % flag 4 and 6: look up in the Fortran code.
            
            
            
            % check column vectors
            Util.checkColVec(data.t,'time');
            Util.checkColVec(data.x,'x');
            Util.checkColVec(data.y,'y');
            Util.checkColVec(data.q,'q');
            
            
            % merge data
            if isfield(data,'tempSal')
                allData = [data.t,data.x,data.y,data.q,data.tempSal,data.c];
                nTempSal = size(data.tempSal,2);
            else
                allData = [data.t,data.x,data.y,data.q,data.c];
                nTempSal = 0;
            end
            nFrac = nTempSal + size(data.c,2);
            
            % open file
            fid =fopen(fileName,'w');
            
            % write header
            header = ['txycq file: with t x y q c (',num2str(nFrac,'%02.0f'),' fraction ',num2str(nTempSal,'%02.0f'),' default)'];
            fprintf(fid,'%s\n',header);
            
            
            
            [nT,nVar] = size(allData);
            for i =1:nT
                %write data
                fprintf(fid,[repmat('%f ',1,nVar), '\n'],allData(i,:));
                
                % write flags
                switch data.flag(i)
                    case 1
                        fmt1 = repmat('%10.4f ',1,length(data.flagPar{i}));
                        fprintf(fid,['%4.0f %4.0f \n',fmt1,'\n'],[data.flag(i), length(data.flagPar{i})/2,data.flagPar{i}]);
                    otherwise
                        fmt2 = repmat('%10.4f ',1,length(data.flagPar{i}));
                        fprintf(fid,['%4.0f %4.0f \n',fmt2,'\n'],[data.flag(i), length(data.flagPar{i}), data.flagPar{i}]);
                end
            end
            
            % close file
            fclose(fid);
            
        end
        function writeLiquidBoundaryFile(fileName,Table)
            % Writes a writeLiquidBoundaryFile file
            %
            % Telemac.writeLiquidBoundaryFile(theFile,Table)
            %
            % #INPUTS:
            % theFile: the filename
            % Table: table with time as a first column (datenum) and VariableDescriptions and
            % units assigned. these will be used in the header
            %
            %
            % #OUTPUTS:
            %
            % #STEPS:
            % #KNOWN ISSUES:
            %
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: GLE
            % Date: 06/06/2018
            % Modified by:
            % Date:
            

            startdate=Table.Time(1);
            Table.Time=(Table.Time-startdate)*60*60*24;
            variables='T';
            units='s';
            nr_var=numel(Table.Properties.VariableUnits);
            for i=2:nr_var
                variables=[variables  ' ' Table.Properties.VariableDescriptions{i}];
                units=[units '  ' Table.Properties.VariableUnits{i}];
            end
            
            fid = fopen(fileName,'w');
            fprintf(fid,'%s\n','# liquid boundary file');
            fprintf(fid,'%s\n',['# startdate ',datestr(startdate)]);
            fprintf(fid,'%s\n',variables);
            fprintf(fid,'%s\n',units);
            if istable(Table)
                fprintf(fid,[repmat('%f ',1,nr_var),'\n'],table2array(Table)');
            elseif isstruct(Table)
                fprintf(fid,[repmat('%f ',1,nr_var),'\n'],[Table.Time,Table.Data]');
            else
                error('Unknown type');
            end
            fclose(fid);
        end
        
        function Table = readLiquidBoundaryFile(theFile)
            
            fid = fopen(theFile);
            t = '#';
            while strcmp(t(1),'#')
                t = fgets(fid);
            end
            % line with variables
            sp = isspace(t);
            ch = ~sp;
            indFirst = find(ch,1,'first');
            indLast = find(sp,1,'first');
            variables = {};
            while ~isempty(indFirst)
                variables = [variables;{t(indFirst:indLast-1)}];
                ch(1:indLast) = false;
                sp(1:indLast) = false;
                indFirst = find(ch,1,'first');
                indLast = find(sp,1,'first');
                if isempty(indLast)
                    indLast = length(sp)+1;
                end
            end
            % line with units
            t = fgets(fid);
            sp = isspace(t);
            ch = ~sp;
            indFirst = find(ch,1,'first');
            indLast = find(sp,1,'first');
            units = {};
            while ~isempty(indFirst)
                units = [units;{t(indFirst:indLast-1)}];
                ch(1:indLast) = false;
                sp(1:indLast) = false;
                indFirst = find(ch,1,'first');
                indLast = find(sp,1,'first');
                if isempty(indLast)
                    indLast = length(sp)+1;
                end
            end
            
            % read all data
            format = ['%f',repmat(' %f',1,numel(variables)-1)];
            t = cell2mat(textscan(fid,format));
            
            Table.Time = t(:,1);
            Table.Data = t(:,2:end);
            Table.Properties.VariableDescriptions = variables;
            Table.Properties.VariableUnits = units;
            
            fclose(fid);
        end
        
        function xyzFindOutline(fileIn,fileOut)
            % Makes an outline (.i2s) around an xyz dataset
            % Input: fileIn (.xyz), fileOut (.i2s)
            
            data = Telemac.readKenue(fileIn);
            
            k = boundary(data{1, 1}(:,1),data{1, 1}(:,2),1.0);
            
            x = data{1, 1}(k,1);
            y = data{1, 1}(k,2);
            
            Telemac.writeKenue(fileOut,{[x, y]});
        end
    end
    
    methods (Static,Access = private)
        
        function meteoData = readEraHeader(fileName,meteoData)
            % reads time independent data of era wave data
            t = ncread(fileName,'time');
            t = double(t)/24 +datenum([1900 1 1]);
            lon = ncread(fileName,'longitude');
            % convert to -180 to 180
            lon(lon>180)= lon(lon>180)-360;
            lat = ncread(fileName,'latitude');
            [meteoData.lat,meteoData.lon] = meshgrid(lat,lon);
            if ~isfield(meteoData,'iFile')
                meteoData.t = t;
                meteoData.iFile = 1;
                meteoData.fileInd = [ones(size(t)),(1:length(t))'];
            else
                meteoData.t = [meteoData.t;t];
                meteoData.iFile = meteoData.iFile + 1;
                meteoData.fileInd = [meteoData.fileInd;[meteoData.iFile*ones(size(t)),(1:length(t))']];
            end
        end
        
        function meteoData = readEra(meteoData,fileNames,timeStep,varNames,nrLonLat)
            % reads a time step of a era netcdf file
            iTime = meteoData.fileInd(timeStep,2);
            iFile = meteoData.fileInd(timeStep,1);
            for i =1:length(varNames)
                meteoData.(varNames{i}) = ncread(fileNames{iFile},varNames{i},[1,1,iTime],[nrLonLat 1]);
            end
        end
        function [lon,lat,mask] = getgfs(gfsFile)
            % read data from gfs
            lat = ncread(gfsFile,'latitude');
            lon = ncread(gfsFile,'longitude');
            [lat,lon] = meshgrid(double(lat),double(lon));
            pres   = ncread(gfsFile,'pressfc');
            mask = isnan(squeeze(pres(:,:,1)));
        end
        
        function [lon,lat,mask] = getEra(windFile,interpVar)
            % read data from gfs
            lon = ncread(windFile,'longitude');
            lat = ncread(windFile,'latitude');
            %t   = ncread(erafile,'time');
            [lat,lon] = meshgrid(double(lat),double(lon));
            pres   = ncread(windFile,interpVar);
            pres = double(squeeze(pres(:,:,1)));
            nodataValue = ncreadatt(windFile,interpVar,'missing_value');
            mask = pres==nodataValue;
        end
    end
end