%Class with functions related to Nestor, the dredging routine of Telemac
%
% @author ABR
% @author SEO
% @version
%

classdef Nestor < handle
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
    methods (Static)
        
        function sctVol = readVolume(theFile)
            % reads nestor output from log file
            %
            % sctVol = readVolume(theFile)
            %
            % INPUT:
            % - thefile: filename of preprocessed log file (see below)
            %
            % OUTPUT: 
            % - sctVol: structure with dredging data:
            %    - volume: dredeg volume 
            %    - tStart: start time (s since start model) 
            %    - tEnd  : end time (s since start model) 
            %    - location: dredging zone 
            %    - actionNr: action number of dredging
            % 
            % 
            % NOTE
            %
            % Use the following command in linux to generate the input file
            %
            % grep -A 11 "finalise" PE00159-00001.LOG > dredgeLog.txt
            
            
            fid = fopen(theFile);
            %tmp = textscan(fid,'')
            n = 0;
            VERY_LARGE = 10000;
            % preallocate
            volume   = zeros(VERY_LARGE,1);
            location = cell(VERY_LARGE,1);
            tStart   = zeros(VERY_LARGE,1);
            tEnd     = zeros(VERY_LARGE,1);
            actionNr = zeros(VERY_LARGE,1);
            
            while true
                % read until end of file
                tmp = fgetl(fid);
                if ~ischar(tmp)
                    break;
                end
                n = n+1;
                if ~any(tmp==':')
                    tmp = fgetl(fid);
                    extra = false;
                else
                    extra = true;
                end
                [~,action] = strtok(tmp,':');
                tmp = fgetl(fid);
                tmp2 = split(tmp,':');
                location{n} = strtrim(tmp2{2});
                tmp = fgetl(fid);
                tmp2 = split(tmp,':');
                actionNr(n) = str2double(tmp2{2});
                tmp = fgetl(fid);
                tmp = fgetl(fid);
                tmp = fgetl(fid);
                tmp2 = split(tmp,':');
                tStart(n) = str2double(tmp2{2});
                tmp = fgetl(fid);
                tmp2 = split(tmp,':');
                tEnd(n) = str2double(tmp2{2});
                tmp = fgetl(fid);
                tmp = fgetl(fid);
                tmp = fgetl(fid);
                tmp = fgetl(fid);
                tmp2 = split(tmp,':');
                volume(n)= str2double(tmp2{2});
                tmp = fgetl(fid);
                if extra
                    tmp = fgetl(fid);
                end
                
            end
            fclose(fid);
            
            % delete unused data
            volume(n+1:end) = [];
            tStart(n+1:end) = [];
            tEnd(n+1:end) = [];
            location(n+1:end) = [];
            actionNr(n+1:end) = [];
            
            sctVol.volume = volume; 
            sctVol.tStart = tStart; 
            sctVol.tEnd = tEnd; 
            sctVol.location = location; 
            sctVol.actionNr = actionNr; 
            
        end
        
        
        function sctPoly = readPoly(theFile)
            % reads nestor polygon file
            %
            % sctPoly = readPoly(theFile)
            %
            % INPUT:
            % - theFile: filename of polyline file
            %
            % OUTPUT: 
            % - sctPoly: [Mx1] structure with polygons; fileds
            %    -name: name of the polygon
            %    -xy: x and y coordinates [Nx2]
            
            LARGE = 200;
            fid = fopen(theFile);
            n = 0;
            while 1
                tmpLine = fgetl(fid);
                if ischar(tmpLine)
                    %remove trailing spaces
                    tmpLine = strtrim(tmpLine);
                    % empty line
                    if isempty(tmpLine)
                        continue;
                    end
                    % comment
                    if tmpLine(1) =='#'
                        continue;
                    end
                    if strcmpi(tmpLine,'ENDFILE')
                        break;
                    end
                    
                    if strncmpi(tmpLine,'NAME',4)
                        if (n>0)
                            tmpSct.xy(nXy+1:end,:) = [];
                            sctPoly(n) = tmpSct; %#ok<AGROW>
                        end
                        % preallocate
                        tmpSct.name = strtrim(tmpLine(6:end));
                        tmpSct.xy = zeros(LARGE,2);
                        nXy = 0;
                        n = n+1;
                        continue
                    end
                    nXy = nXy +1;
                    tmpSct.xy(nXy,:) = str2num(tmpLine); %#ok<ST2NM>
                else
                    break;
                end
            end
            if (n>0)
                %delete zero entries
                tmpSct.xy(nXy+1:end,:) = [];
                % save struct
                sctPoly(n) = tmpSct;
            end
            fclose(fid);
        end
        
        
        function sctAction = readAction(theFile)
            % reads nestor action file
            %
            % sctAction = readAction(theFile)
            %
            % INPUT:
            % - theFile: filename of action file
            %
            % OUTPUT: 
            % -sctAction: [Nx1] structure of actions with fields:
            %
            % ActionType: 'Dig_by_criterion'
            % FieldDig: '178_VaarwaterBB'
            % ReferezLevel: 'DSRWSP'
            % TimeStart: '2015.01.01-00:00:00'
            % TimeEnd: '2099.03.31-23:59:59'
            % TimeRepeat: 7776000
            % DigRate: 2.8000e-04
            % DigDepth: 15.2200
            % CritDepth: 14.7200
            % MinVolume: 0
            % MinVolumeRadius: 3.5000
            % FieldDump: '276_SN51'
            % DumpRate: 0.0200
            % DumpPlanar: 'FALSE'
            % AND MAYBE OTHERS
            
            fid = fopen(theFile);
            n = 0;
            while 1
                tmpLine = fgetl(fid);
                if ischar(tmpLine)
                    %remove trailing spaces
                    tmpLine = strtrim(tmpLine);
                    % empty line
                    if isempty(tmpLine)
                        continue;
                    end
                    % comment
                    if tmpLine(1) =='/'
                        continue;
                    end
                    % define start and end of an action
                    if strcmpi(tmpLine,'ACTION')
                        n = n+1;
                        tmpSct = struct;
                        continue
                    end
                    if strcmpi(tmpLine,'ENDACTION')
                        sctAction(n) = tmpSct; %#ok<AGROW>
                        continue
                    end
                    % parse settings
                    % delete comments
                    indCom  = strfind(tmpLine,'/');
                    if ~isempty(indCom)
                        tmpLine = tmpLine(1:indCom-1);
                    end
                    %
                    if n>0
                        [keyWord,tmp] = strtok(tmpLine,'=');
                        value         = strtok(tmp,'=');
                        keyWord       = strtrim(keyWord);
                        value2        = str2double(value);
                        if isnan(value2)
                            value2       = strtrim(value);
                        end
                        tmpSct.(keyWord) = value2;
                    end
                else
                    break;
                end
            end
            fclose(fid);
        end
        
        
    end
end