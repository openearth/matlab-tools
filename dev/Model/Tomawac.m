
%Class to declare the most common Tomawac
%
% @author ABR
% @author SDO
% @version 0.0, 22/05/2018
%

classdef Tomawac < handle
    %Static methods
    methods (Static)
    
        function writeSpectra(OPT)
            % write spectral boundary conditions for a TOMAWAC simulation.
            % OPT.slfFileIn : Path of the slf file already created with the variable 'BOTTOM'.
            % OPT.cliFile : Path of the cli file already created.
            % OPT.dataPath : Path to the file(s) holding the original
            %       spectra (string or cell array of strings) (REMARK : in
            %       case of large wave models, spectra may have been
            %       downloaded along the boundary only in several files.
            % OPT.mercator: optional field containing long0 and lat0 to
            %               transform mercator coordinate system to WGS84
            
            if ischar(OPT.dataPath) 
                OPT.dataPath = {OPT.dataPath}; % just for processing.
            elseif ~iscell(OPT.dataPath)
                errordlg('not a correct dataPath for the files holding the spectra')
            end
            if ~isfield(OPT, 'append')
                OPT.append = false; 
            end
            if ~isfield(OPT, 'writePointFile') 
                if isfield(OPT, 'outPointFile') && ~OPT.append
                    OPT.writePointFile = true; 
                else
                    OPT.writePointFile = false;
                end
            end
                    
                
            % Dimensions
            dim = Tomawac.dimensionsERA5(OPT.dataPath{1});
            if ~isfield(OPT, 'dir')
                OPT.dir = dim.dir;
            end
            if ~isfield(OPT, 'freq') 
                OPT.freq = dim.freq; 
            end
            ndir = numel(OPT.dir);
            nfreq = numel(OPT.freq);
            % ------------------------
            
            % time
            indtime = find(dim.time >= OPT.timeRange(1), 1, 'first'); 
            endtime = find(dim.time <= OPT.timeRange(2), 1, 'last');
            ntime = endtime-indtime+1; 
            IDATE = datevec(dim.time(indtime)); 
            DT    = diff(dim.time(1:2)); % time difference in seconds.
            % ------------------------
            
            % Lookup closest point
            [nodeNr, lonTel, latTel] = Tomawac.retrieveBoundaryCharacteristics(OPT.cliFile, OPT.slfFileIn, OPT);
            [indLon, indLat, indFile] = Tomawac.getIndex(OPT.dataPath, lonTel, latTel); 
            nnodes = numel(nodeNr); 
            % ------------------------
            
            % Retrieve and convert spectra
            RESULT = NaN(ndir*nfreq, nnodes, ntime);  
            h = waitbar(0,'progress');
            for inode = 1:nnodes
                waitbar(inode / nnodes,h,['Computing node : ' num2str(inode) '/' num2str(nnodes) ' ...'])
                iit = 0; 
                 for itime = indtime:endtime
                     iit = iit+1; 
                    spectra = Tomawac.spectraERA5(OPT.dataPath{indFile(inode)}, indLon(inode), indLat(inode), itime, 1);
                    Ein = squeeze(spectra); 
                    Eout = Waves.spectInterp2D(dim.freq,dim.dir,Ein,OPT.freq,OPT.dir);
                    RESULT(:, inode, iit) = reshape(Eout, [],1);
                 end
            end
            % ------------------------
            
            % Write to file
            if isfield(OPT,'append') && OPT.append
                sctTom  = telheadr(OPT.slfFileOut); 
                fid = fopen(OPT.slfFileOut,'ab','b'); 
                if sctTom.DT ~= round(DT*24*60*60)
                    errordlg('difference in delta T compared to existing file'); 
                end
            else
                sctTom   = Tomawac.createStrucTom(IDATE, DT, nodeNr, OPT.freq, OPT.dir);
                fid      = telheadw(sctTom,OPT.slfFileOut);
            end
            for itime = 1:ntime
                waitbar(itime / ntime,h,['Writing time step : ' num2str(itime) '/' num2str(ntime) ' ...'])
                sctTom.AT = sctTom.DT*sctTom.NSTEPS;
                sctTom.NSTEPS = sctTom.NSTEPS+1;
                sctTom.RESULT = squeeze(RESULT(:,:,itime));
                fid      = telstepw(sctTom,fid);
            end
            close(h)
            fclose(fid); 
            fclose('all');
            % ------------------------ 
        end
        
        function [nodeNr, lonTel, latTel] = retrieveBoundaryCharacteristics(cliFile, mshFile, OPT)
            nodeNr  =  Tomawac.getNodeNr(cliFile);
            slf = telheadr(mshFile);
            x = slf.XYZ(nodeNr,1);
            y = slf.XYZ(nodeNr,2);
            if isfield(OPT,'mercator')
                [lonTel,latTel]=Telemac.mercator2spherical(x,y,OPT.mercator.long0,OPT.mercator.lat0);
            else
                lonTel = x; 
                latTel = y; 
            end
            if OPT.writePointFile
                Tomawac.writePointFile(OPT.outPointFile,nodeNr,x,y); 
            end
        end
        function nodeNr = getNodeNr(cliFile)
            % find boundary nodes
            tmp = Telemac.readCli(cliFile);
            mask = ismember(tmp(:,1:3), [5 4 4], 'rows');
            nodeNr = tmp(logical(mask),12);
        end
        function [indLon, indLat, indFile] = getIndex(dataPath, lonTel, latTel)
            % initiate output variables for ifile = 1; 
            dimensions1 = Tomawac.dimensionsERA5(dataPath{1});
            [indLon,indLat, dist] = Tomawac.getIndexSingleFile(lonTel, latTel, dimensions1);
            indFile = ones(size(indLon));
            for ifile = 2:numel(dataPath)
                dimensions = Tomawac.dimensionsERA5(dataPath{ifile});
                bOke = Tomawac.checkdimensions(dimensions1, dimensions); 
                [indLon2,indLat2, dist2] = Tomawac.getIndexSingleFile(lonTel, latTel, dimensions);
                indShorter = dist2 < dist; 
                indLon(indShorter)  = indLon2(indShorter);
                indLat(indShorter)  = indLat2(indShorter); 
                indFile(indShorter) = ifile; 
            end
        end
        function [indLon,indLat, aDist] = getIndexSingleFile(lonTel, latTel, dataSpec)
         % get index of the closest lat lon coordinate in the spectra l file
            [lonSpec,latSpec] = meshgrid(dataSpec.lon,dataSpec.lat);

            [indLonSpec,indLatSpec] = meshgrid(1:length(dataSpec.lon),1:length(dataSpec.lat));
            for i=length(latTel):-1:1
                dist = Calculate.circle_distance(latTel(i),lonTel(i),latSpec,lonSpec);
                [mn,ind] = min(dist(:));
                indLon(i) = indLonSpec(ind);
                indLat(i) = indLatSpec(ind);
                aDist(i)  = mn; 
            end
        end
        function bOke = checkdimensions(dim0, dim1)
%             check = all(dim0.lon==dim1.lon); % should be different! 
%             check = all(dim0.lat==dim1.lat); % should be different! 
              checkT = all(dim0.time==dim1.time);
              checkD = all(dim0.dir==dim1.dir);
              checkF = all(dim0.freq==dim1.freq);
              if checkT && checkD && checkF 
                  bOke = true; 
              else
                  bOke = false;
                  mess = {'The following dimensions do not agree between the source files'}; 
                  if ~checkT;mess{end+1,1} = 'time'; end
                  if ~checkD;mess{end+1,1} = 'directional discretisation'; end
                  if ~checkF;mess{end+1,1} = 'frequential discretisation'; end
                  errordlg(mess)
              end 
        end
        function dimERA5 = dimensionsERA5(theFile)
            % read metadata from ECMWF - ERA5 spectral files.
            dimERA5.lon  = ncread(theFile,'longitude');
            dimERA5.lat  = ncread(theFile,'latitude');
            tmp           = double(ncread(theFile,'direction'));
            dt = 2.*pi/length(tmp);
            dimERA5.dir  = (tmp-0.5).*dt;
            tmp           = double(ncread(theFile,'frequency'));
            dimERA5.freq = 0.03453.*1.1.^(tmp-1);
            %0.03453 Hz and the following ones are : f(n) = f(n-1)*1.1, n=2,3

            % read time and convert to matlab time
            time = ncread(theFile,'time');
            dimERA5.time = double(time)./24 + datenum([1900 1 1]);

%             %read data (and convert including conversion radians to degree)
%             %dimERA5.spec = pi/180*10.^ncread(theFile,'d2fd');
%             dimERA5.spec = 10.^ncread(theFile,'d2fd');
%             dimERA5.spec(isnan(dimERA5.spec)) = 0.0;
        end
        function specERA5 = spectraERA5(theFile, indlon, indlat, indtime, ntime)
            % dimensions : longitude, latitude, direction, frequency and time 
            specERA5 = squeeze(10.^ncread(theFile,'d2fd', [indlon, indlat, 1, 1, indtime], [1 1 Inf Inf ntime]));
            specERA5(isnan(specERA5)) = 0.0; 
        end
                
        

        function sctTom = createStrucTom(IDATE, DT, nodeNr,freqOut,dirOut)
            % creates a tomawac data structure from spectrum

            % space info
            sctTom.NBV = length(nodeNr);
            for i = sctTom.NBV:-1:1
                sctTom.RECV{i} = ['F',num2str(i,'%02i'),'PT2D',num2str(nodeNr(i),'%06.0f'),' UNITE SI         '];
            end

            sctTom.title = 'Spectral boundary condition file                                        SERAFIN ';
            sctTom.type  = 'seraphin';        
            % fixes constants
            sctTom.NPLAN = 1;
            sctTom. NDP = 4;
            sctTom.IPARAM = [    1
                                 0
                                 0
                                 0
                                 0
                                 0
                                 0
                               144 % what is this
                                57 % and this
                                 1];
            % time info                         
            sctTom.IDATE  =  IDATE;
            sctTom.NSTEPS = 0;
            sctTom.DT     = round(86400*DT);
            sctTom.AT     = 0; 

            % spectral mesh definition

            sctTom.freq = freqOut;
            sctTom.dir  = dirOut;

            nrF   = length(freqOut);
            nrDir = length(dirOut);
            sctTom.NELEM = (nrF-1)*nrDir;
            sctTom.NPOIN = nrF*nrDir;

            sctTom.XYZ  = zeros(sctTom.NPOIN,1);
            sctTom.IKLE = zeros(sctTom.NELEM,4);
            for i=1:nrF
                n1 = (i-1)*nrDir+1;
                n2 = i*nrDir;
                % note conversion to nautical direction
                sctTom.XYZ(n1:n2,1) = freqOut(i).*cos(pi/2-dirOut);
                sctTom.XYZ(n1:n2,2) = freqOut(i).*sin(pi/2-dirOut);
            end
            for i=1:nrF-1
                n1 = (i-1)*nrDir+1;
                n2 = i*nrDir;
                ind2 = (1:nrDir)';
                ind1 = circshift(ind2,1);
                tmp = [ind2,ind1,ind1+nrDir,ind2+nrDir];
                tmp = circshift(tmp,-1);
                sctTom.IKLE(n1:n2,:) = tmp+(i-1).*nrDir;
            end

            sctTom.IPOBO  = zeros(sctTom.NPOIN,1);
            sctTom.RESULT = zeros(sctTom.NPOIN,sctTom.NBV);
        end
    
        function slfWind = createSelafinWind(OPT)
         % I accidently erased the previous routine from Telemac
            slfWind = telheadr(OPT.slfFileIn);

            % space info
            slfWind.NBV = 2;
            slfWind.RECV = {'WIND ALONG X    M/S             '; 
                            'WIND ALONG Y    M/S             '};


            slfWind.title = pad('Wind Condition file',80);
            slfWind.type  = 'seraphin';        
            % fixes constants
            slfWind.NPLAN = 1;
            slfWind.NDP = 3;
            slfWind.IPARAM = [   1
                                 0
                                 0
                                 0
                                 0
                                 0
                                 0
                                 0 
                                 0 
                                 1];
            % time info                         
            slfWind.IDATE  =  IDATE;
            slfWind.NSTEPS = 0;
            slfWind.DT     = 86400*DT;
            slfWind.AT     = 0; 

            slfWind.IPOBO  = zeros(slfWind.NPOIN,1);
            slfWind.RESULT = zeros(slfWind.NPOIN,slfWind.NBV);
            slfWind = rmfield(slfWind, {'startfpos', 'len1rec'});
        end   
        function writePointFile(outPointFile,nodeNr,x,y)
            fid = fopen(outPointFile,'w');
            fprintf(fid,'%4.0f %4.0f\n',[1,length(nodeNr)]);
            fprintf(fid,'%8.0f %8.0f %8.0f %8.0f\n',[nodeNr,x,y,zeros(size(x))]');
            fclose(fid);
        end
        
        function slf = createSelafin(nodes, elements, ipobo)
            slf.NBV = 1; 
            slf.RECV = {}; 
            slf.type  = 'seraphin';     
            slf.title = pad('newMesh',80); 
            slf.IPARAM = [   1
                             0
                             0
                             0
                             0
                             0
                             0
                             0 
                             0 
                             0];
            slf.NPOIN = size(nodes,1);  
            slf.NELEM = size(elements,1);   
            slf.NDP = 3; %number of points per element 
            slf.IDATE = []; 
            slf.NSTEPS = 0; 
            slf.IKLE = elements;
            slf.IPOBO = ipobo; 
            slf.XYZ = nodes; 
            slf.RESULT = []; 
            slf.DT = 0; 
            slf.AT = 0;
        end
        
    end
end