%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef OpenFoam < handle
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
        function dataOut = readProbe(thePath,theVar,nrProbes)
            % read variables from a probe in OpenFOAM
            %
            % dataOut = readProbe(thePath,theVar,nrProbes)
            %
            % INPUT: 
            %
            % thePath :  the directory where the directories with the
            % output from different timesteps are located. All available
            % time steps are merged automatically
            %        theVar  : name of the variable
            %        nrProbes: the number of points in the file
            % 
            % OUTPUT:
            %
            % dataOut: atsructure with the fields:
            %           dataOut.time 
            %           dataOut.x 
            %           dataOut.y 
            %           dataOut.z 
            %           dataOut.(theVar)
            % Note that in case a file with velocities is read, the files
            % are:
            %    dataOut.u 
            %    dataOut.v 
            %    dataOut.w 
            
            %look for all files in case of restart
            allDir = dir(thePath);
            data = [];
            time = [];
            for i=3:length(allDir)
                theFile = fullfile(thePath,allDir(i).name,theVar);
                %ôpen the file
                fid = fopen(theFile);
                
                % read coordinates
                cTmp  = textscan(fid,'# Probe %f (%f %f %f)',nrProbes);
                coord = cell2mat(cTmp);
                %i x y z
                
                % dummies
                str = fgetl(fid);
                str = fgetl(fid);
                str = fgetl(fid);
                
                % read data (different for U)
                if theFile(end)=='U'
                    cTmp = textscan(fid,['%f ',repmat('(%f %f %f) ',1,nrProbes)]);
                else
                    cTmp = textscan(fid,repmat('%f ',1,nrProbes+1));
                end
                fclose(fid);
                
                % extract time
                tmpTime = cTmp{1};
                
                %extract data and delete NaN
                tmpData = cell2mat(cTmp(2:end));
                mask = tmpData<-199;
                tmpData(mask) = nan;
                
                % cut overlap from original data
                mask = time<tmpTime(1);
                
                % merge
                data = [data(mask,:);tmpData];
                time = [time(mask);tmpTime];
            end
            
            % cut overlap
            
            
            if theFile(end)=='U'
                dataOut.u = data(:,1:3:end);
                dataOut.v = data(:,2:3:end);
                dataOut.w = data(:,3:3:end);
            else
                dataOut.(theVar) = data;
            end
            dataOut.time = time;
            dataOut.x = coord(:,2);
            dataOut.y = coord(:,3);
            dataOut.z = coord(:,4);
        end
        
        function dataOut = readWl(thePath,nrProbes)
            % read water levels from interfaceHeight probe
            %
            % dataOut = readWl(thePath,nrProbes)
            %
            % INPUT: thePath :  the directory where the directories with the
            % output from different timesteps are located. All available
            % time steps are merged automatically
            %        nrProbes: the number of points in teh data
            %
            % OUTPUT: dataOut a structure with the fields:
            %            dataOut.time 
            %            dataOut.wl 
            %            dataOut.depth 
            %            dataOut.x 
            %            dataOut.y 
            %            dataOut.z 
            %
            %
            %
            time  = [];
            wl    = [];
            depth = [];
            allFiles = dir(thePath);
            for i=3:length(allFiles)
                theFile = fullfile(thePath,allFiles(i).name,'height.dat');
                fid = fopen(theFile);
                % read coordinates
                cTmp  = textscan(fid,'# Location %f : (%f %f %f)',nrProbes);
                coord = cell2mat(cTmp);
                %i x y z
                
                % dummies
                str = fgetl(fid);
                str = fgetl(fid);
                str = fgetl(fid);
                str = fgetl(fid);
                str = fgetl(fid);
                
                % read data
                cTmp = textscan(fid,repmat('%f ',1,nrProbes*2+1));
                fclose(fid);
                
                % extract data; do calculations and mask nan
                tmpTime   = cTmp{1};
                tmpWl     = cell2mat(cTmp(3:2:end))+coord(:,4)';
                tmpDepth     = cell2mat(cTmp(2:2:end));
                tmpWl(tmpWl>1e99) = nan;
                
                % cut overlap from original data
                mask = time<tmpTime(1);
                
                
                % merge
                wl    = [wl(mask,:);tmpWl];
                depth = [depth(mask,:);tmpDepth];
                time  = [time(mask);tmpTime];
                
            end
            dataOut.time = time;
            dataOut.wl = wl;
            dataOut.depth = depth;
            dataOut.x = coord(:,2);
            dataOut.y = coord(:,3);
            dataOut.z = coord(:,4);
        end
        
        function dataOut = readForce(thePath)
            % read all data files with forces in a path and merges them
            % 
            % dataOut = readForce(thePath)
            %
            % INPUT: thePath: the directory where the directories with the
            % output form different timesteps are located
            %
            % OUTPUT: dataOut; a structure with the fields
            %   dataOut.time  : time
            %   dataOut.fX    : forces in x and y z direction
            %   dataOut.fY  
            %   dataOut.fZ  
            % 
            %   dataOut.mX    : moments in x y z direction (use righthand
            %   rule
            %   dataOut.mY    :
            %   dataOut.mZ    :

            %
            %
            
            
            allFiles = dir(thePath);
            for i=3:length(allFiles)
                % read adata
                theFile = fullfile(thePath,allFiles(i).name,'forces.dat');
                fid = fopen(theFile);
                cData = textscan(fid,'%f ((%f %f %f) (%f %f %f) (%f %f %f)) ((%f %f %f) (%f %f %f) (%f %f %f))','headerlines',3);
                fclose(fid);
                tmpData = cell2mat(cData);
                
                % cut overlap
                if i>3
                    mask = data(:,1)<tmpData(1,1);
                    %merge data
                    data = [data(mask,:);tmpData];
                else
                    data = tmpData;
                end
            end
            % extrract data
            dataOut.time   = data(:,1);
            dataOut.fX  = sum(data(:,[2 5 8]),2);
            dataOut.fY  = sum(data(:,[3 6 9]),2);
            dataOut.fZ  = sum(data(:,[4 7 10]),2);
            
            dataOut.mX  = sum(data(:,[11 14 17]),2);
            dataOut.mY  = sum(data(:,[12 15 18]),2);
            dataOut.mZ  = sum(data(:,[13 16 19]),2);
        end
    end
end