%Class to declare the most common utilities
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Util < handle
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
        function [cDataOut,bGo] = adaptData(cData)
            % this function checks wher=ther all the cells has matrixes that are the
            % same length. If not extra NaN values are added
            nLen    = length(cData);
            vLength = zeros(1,nLen);

            for nI = 1:nLen
                vLength(nI) = size(cData{nI},1);
            end

            minLen = min(vLength);
            maxLen = max(vLength);

            if minLen==maxLen
                bGo = 0;
                cDataOut = cData;
            else
                bGo = 1;
                vMask = find(vLength<maxLen);
                cDataOut = cData;
                for nI = vMask
                    cDataOut{nI}(minLen+1:maxLen) = nan;
                end
            end
        end

        function cAllData = addData(cData,cAllData)
            % this function adds the data of one cell array to the next
            if ~isempty(cAllData)
                for nI = 1:length(cAllData)
                    cAllData{nI} = [cAllData{nI};cData{nI}];
                end
            else
                cAllData = cData;
            end
        end

        function [xNew,yNew,zNew] = alwaysRepeatData(x,y,z)
            % performs repmat on x and y data to become  matrices for
            % contour plot
            % INPUT:
            %  x, y, z: data to be used for a contour plot. x must be a column
            %  vector or matrix or 3d array (if z is present). y must be a row vector or matrix. In case
            %  a variable is a matrix, nothing happen. z can be any vector,
            %  matrix or 3d array. Z is optional.
            % OUTPUT: xNew, yNew, zNew: matrices with the same size as z, with the singleton
            % dimension copied to match the size. znew is only generated if
            % z is present

            % Written by: ABR
            % Date: 7-8-2013

            sizeX = size(x);
            sizeY = size(y);

            % copy Xdata if necessary
            if sizeX(2)==1
                xNew = repmat(x,1,sizeY(2));
            else
                xNew = x;
            end

            %copy y data if necessary
            if sizeY(1)==1
                yNew = repmat(y,sizeX(1),1);
            else
                yNew = y;
            end

            % add third dimensions
            if nargin == 3
                sizeZ = size(z);
                % copy X data if necessary
                if length(sizeX)==2 || sizeX(3)==1
                    xNew = repmat(xNew,[1 1 sizeZ(3)]);
                end

                % copy Y data if necessary
                if length(sizeY)==2 || sizeY(3)==1
                    yNew = repmat(yNew,[1 1 sizeZ(3)]);
                end

                % copy z data if necessary
                if sizeZ(2)==1
                    zNew = repmat(z,[1,sizeY(2),1]);
                else
                    zNew = z;
                end

                if sizeZ(2)==1
                    zNew = repmat(zNew,[sizeX(1),1,1]);
                end
            end
        end
        
        function checkColVec(aVar,varName)
            % checks whether a variable is column vector
            % INPUT: aVar: variable to be checked
            %        varName: the name of the variable to be checked
            %
            %
            if size(aVar,1)<size(aVar,2)
                error([varName,' must be a column vector']);
            end
        end

        function folderPath = checkFolderPath(folderPath)
            % adds a backslash to a path in needed
            % INPUT: folderPath: a string with a path
            % OUTPUT
            if ~strcmp(folderPath(end), '\')
                folderPath = [folderPath '\'];
            end
        end

        function varargout = deleteNans(varargin)
            %delete nan values from all the input arguments (which can be any number)
            % and gives all these input arguments back with the nan values deleted

            % allocate mask
            sizeMask = size(varargin{1});
            mask = false(sizeMask);
            % determine the mask filtereing out all nans
            for i = 1:nargin
                if  sizeMask == size(varargin{i})
                    mask = isnan(varargin{i})|mask;
                else
                    error('Wrong input dimension')
                end
            end
            for i = 1:nargin
                varargout{i} = varargin{i}(~mask);
            end
        end

        function varargout = deleteNansColumn(varargin)
            %delete nan values from all the input arguments (which can be any number)
            % and gives all these input arguments back with the nan values deleted
            % this function will work per column (so  a column with a nan value will be deletedfrom the matrix)

            % allocate mask
            sizeMask = size(varargin{1});
            mask = false(sizeMask);
            % determine the mask filtereing out all nans
            for i = 1:nargin
                if  sizeMask == size(varargin{i})
                    mask = isnan(varargin{i})|mask;
                else
                    errordlg('Wrong input dimension')
                end
            end
            for i = 1:nargin
                maskCol = any(mask,1);
                varargout{i} = varargin{i}(:,~maskCol);
            end
        end

        function varargout = deleteNansRow(varargin)
            %delete nan values from all the input arguments (which can be any number)
            % and gives all these input arguments back with the nan values deleted
            % this function will work per row (so  a row with a nan value will be deleted)

            % allocate mask
            sizeMask = size(varargin{1});
            mask = false(sizeMask);
            % determine the mask filtereing out all nans
            for i = 1:nargin
                if  sizeMask == size(varargin{i})
                    mask = isnan(varargin{i})|mask;
                else
                    error('Wrong input dimension')
                end
            end
            for i = 1:nargin
                maskRow = any(mask,2);
                varargout{i} = varargin{i}(~maskRow,:);
            end
        end

        function thePath  = findFile(startPath,fileName,thePath)
            % finds a file in all subdirectories (inspired by linux find)
            %
            % thePath  = findFile(startPath,fileName)
            %
            % INPUT:
            % - startPath : startPath to start looking
            % - fileName  : fileName to look for
            %
            % OUTPUT
            % - thePath   : cell area with all paths containing fileName
            %
            % NOTES: DO NOT use the third input argument.
            
            if nargin==2
                thePath = {};
            end
            % cylce over all dirs
            allDir = dir(startPath);
            for i = 3:length(allDir)
                % file is found
                tmpPath = fullfile(allDir(i).folder,allDir(i).name);
                if isdir(tmpPath)
                    thePath  = Util.findFile(tmpPath,fileName,thePath);
                end
                if strcmpi(allDir(i).name,fileName)
                    thePath = [thePath;tmpPath];
                end
            end
            
        end
        
        function [indexStart,indexEnd] = getBinIndexOneD(x,xStamp,overlap)
            % makes the bin index of a one-dimensional startset
            % [indexStart,indexEnd] = getBinIndexOneD (x,xStamp,overlap)
            % INPUT: x: a 1d vector with x data
            %         xStamp: a 1d vector with values of x (edges of a bin) to which the
            %         closest matching points shoudl be sought
            %       overlap (optional): logical to see whether overlap should be added at the sides of the bins
            % OUTPUT: indexStart: the index of the point where a bin starts
            %       : indexEnd:   the index of the point where a bin ends
            %
            if nargin == 2
                overlap = 0;
            end

            %sort the data to guarantee find the rigth index
            x = sort(x);

            sizeX      = length(x);
            nrIndex    = length(xStamp)-1;
            indexStart = zeros(nrIndex,1);
            indexEnd   = zeros(nrIndex,1);
            % loop to find indices
            for i = 1:nrIndex
                indexStart(i) = find(x >= xStamp(i),1,'first');
                indexEnd(i)   = find(x <  xStamp(i+1),1,'last');
            end
            % add overlap at the both sides of the data
            if overlap
                indexStart = max(indexStart-1,1);
                indexEnd   = min(indexStart+1,sizeX);
            end
        end

        function indexStart = getIndexOneD(x,xStamp)
            % makes the index of a one-dimensional startset
            % indexStart = getIndexOneD (x,xStamp)
            % INPUT: x: a 1d vector with x data
            %         xStamp: a 1d vector with values of x to which the
            %         closest matching points should be sought
            % OUTPUT: indexStart: the index of the point where a bin starts
            %

            %sort the data to guarantee find the rigth index
            x = sort(x);

            nrIndex    = length(xStamp);
            indexStart = zeros(nrIndex,1);
            % loop to find indices
            for i = 1:nrIndex
                index =  find(x >= xStamp(i),1,'first');
                if ~isempty(index)
                    indexStart(i) = index;
                else
                    indexStart(i) = nan;
                end
            end
        end
        
        function myKey = getKeyFromMapValue(mapContainer, value)
            %Return the key from a Map container with an specific value
            myKey = [];
            
            myValues = mapContainer.values;
            if isa(myValues, 'cell')
                [~,key] = find(strcmp(myValues,value));
                
                if ~isempty(key)
                    allKeys = mapContainer.keys;
                    %return the key in the right position
                    myKey = allKeys{key};
                end
            else
                %TODO: implement.
            end
        end

        function data = insertData(data,index,values)
            % insert data in value splitting up the first dimension
            %
            % data = insertData(data,index,values)
            %
            % INPUT
            % - data: data vector or matrix
            % - index: location where to insert the data
            % - values: values to insert either an array 
            %
            % OUTPUT
            % -data: updated dat avector or matrix
            
            nrI   = length(index);
            nrCol = size(data,2);
            if numel(values) == 1
                values = values.*ones(nrI,nrCol);
            elseif size(values,2) ==1
                values = repmat(values,1,nrCol);
            end
           
            for i=nrI:-1:1
                ind = index(i);
                data = [data(1:ind,:);
                        values(i,:)
                        data(ind+1:end,:)];
            end
            
        end
        
        function isCol = isColVec(aVar)
            % checks whether a variable is column vector
            % 
            % isCol = Util.isColVec(aVar)
            %
            % INPUT: aVar: variable to be checked
            % OUTPUT:  isCol: logical. True is a vector is a column vector.
            %
            %
            isCol = size(aVar,2)== 1;
        end
        
        function makeDir(fileName)
            % checks is a path exists and make a directory otherwise
            %
            theDir = fileparts(fileName);
            if ~exist(theDir,'dir')
                mkdir(theDir);
            end
        end
        
        function varOut = makeColVec(varIn)
            % makes sure a variable is a colum vector
            % 
            % varOut = Util.makeColVec(varIn)
            %
            % INPUT:  varIn: vector to be checked
            % OUTPUT: varOut: column vector with data from varIn
            %
            %
            
            sizeVar = size(varIn);
            if ~any(sizeVar==1)||length(sizeVar)>2
                error('This function only works on vectors');
            end
            if (size(varIn,1)~= 1)
                varOut = varIn;
            else
                varOut = varIn';
            end
        end
        
        
        function varOut = makeRowVec(varIn)
            % makes sure a variable is a colum vector
            % 
            % varOut = Util.makeRowVec(varIn)
            %
            % INPUT:  varIn: vector to be checked
            % OUTPUT: varOut: row vector with data from varIn
            %
            %
            
            sizeVar = size(varIn);
            if ~any(sizeVar==1)||length(sizeVar)>2
                error('This function only works on vectors');
            end
            if (size(varIn,2)~= 1)
                varOut = varIn;
            else
                varOut = varIn';
            end
        end


        function y = negative2nan(x)
            %converts values <=0 to NaN
            %
            % y = negative2nan(x)
            %
            % INPUT: x: matrix with data
            % OUTPUT: y: matrix with data, where negative values are set to
            % NaN
            y = x;
            mask = (x<=0);
            nrWrong = sum(mask);
            % delete values below 0
            if nrWrong>0
                y(mask) = nan;
                warning([num2str(nrWrong),'Values below or equal to zero are deleted from the data']);
            end
        end
        
        function xy = polyLineSelect()
            % gets coordinates of a polyline by clicking
            %
            %xy = polyLineSelect()
            %
            % INPUT:
            %
            % OUTPUT:
            % - xy: [Nx2] vector with coordinates of the polyline
            hold on;
            w = 1;
            xy = [];
            while w==1
                
                %get point
                [x,y,w] = ginput(1);
                if w ==1
                    % get next point
                    if ~isempty(xy)
                        delete(hL);
                    end
                    xy = [xy;x,y];
                    % plot polyline
                    xyp = [xy;xy(1,:)];
                    hL = plot(xyp(:,1),xyp(:,2),'r');
                else
                    if ~isempty(xy)
                        delete(hL);
                        % close polyline
                        xy = [xy;xy(1,:)];
                    end
                end
            end
        end
        
        function [xBox,yBox] = rbboxSelect(hAx)
                % gets coordinates of box made with rbbox selection
                %
                % [xBox,yBox] = rbboxSelect(hAx)
                %
                % INPUT:
                %
                %  -hAx: handle of the axis in which teh selection is
                %  performed
                %
                % OUTPUT:
                %
                % -[xBox,yBox]: [1x5] vectors with the coordinates of the
                % points of the box (first one and last one are equal
                
                % code copied from help file
                waitforbuttonpress;
                point1 = hAx.CurrentPoint; 
                rbbox;           
                point2 = hAx.CurrentPoint; 
                point1 = point1(1,1:2);    
                point2 = point2(1,1:2);
                p1     = min(point1,point2);  
                offset = abs(point1-point2);  
                xBox   = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
                yBox   = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
        end
        
        

        function [xNew,yNew] =  repeatData(x,y,z)
            % performs repmat on x and y data to be the same size as z data
            % INPUT:
            %  x, y, z: data to be used for a contour plot. Data can be either row or
            %  column vectors or matrices
            % OUTPUT: xNew, yNew: matrices with the same size as z, with the singleton
            % dimension copied to match the size

            % Written by: ABR
            % Date: 7-8-2013

            sizeX = size(y);
            sizeY = size(y);
            sizeZ = size(z);

            % calcualte non singletin dimensions
            dimX = sum(sizeX>1);
            dimY = sum(sizeY>1);
            dimZ = sum(sizeZ>1);

            % no repmat necessary for 1D data matrices
            if dimZ == 1
                xNew = x;
                yNew = y;
                return
            end

            % copy Xdata if necessary
            if dimX == 1
                if sizeX(1)== 1
                    % row vector
                    xNew = repmat(x',1,sizeZ(2));
                else
                    % colom vector
                    xNew = repmat(x,1,sizeZ(2));
                end
            else
                % 2D x data; check if they have the same size
                if all(sizeX==sizeZ)
                    xNew = x;
                else
                    error('x and z must have the same simensions if they are both 2d');
                end
            end

            %copy y data if necessary
            if dimY == 1
                if sizeY(1)== 1
                    % row vector
                    yNew = repmat(y,sizeZ(1),1);
                else
                    % colom vector
                    yNew = repmat(y',sizeZ(1),1);
                end
            else
                % 2D y data; check if they have the same size
                if all(sizeY==sizeZ)
                    yNew = y;
                else
                    error('x and z must have the same simensions if they are both 2d');
                end
            end
        end

        function sct = setDefault(sct,field,value)
            % function for setting default values in the options for input
            % sct = Util.setDefault(sct,field,value)
            % INPUT: sct: a structure
            %           : field: the name of the field
            %           : value: the default value of a field
            if ~isfield(sct,field) || isempty(sct.(field))
                sct.(field) = value;
            end
        end

        function sct = setDefaultNumberField(sct, field)
            % function for converting field values from strings to nums
            if isfield(sct, field)
                if ~isempty(sct.(field))
                    if isa(sct.(field),'char')
                        sct.(field) = str2num(sct.(field));
                    end
                end
            end
        end

        function sct = setHighToNan(sct,highVal)
            % set values higher than a threshold tot nan in a struct
            %
            % sct = setHighToNan(sct,highVal)
            %
            % INPUT: 
            % - sct: a structure
            % -highVal: a threshold
            %
            % OUTPUT: updateed sttructure
            fieldNames = fieldnames(sct);
            for i=1:length(fieldNames)
                mask = sct.(fieldNames{i})>highVal;
                sct.(fieldNames{i})(mask) = nan;
            end
        end
        
        function [k1,k2] = sortVal(k1,k2)
            % sorts values such that k1 < k2
            % 
            % [k1,k2] = sortVal(k1,k2)
            %
            if k1>k2
                tmp = k2;
                k2  = k1;
                k1  = tmp;
            end
        end
        
        function outFile = stdFile(fileName,dirNr)
            % make a filename in a standard directory structure
            %
            %  outFile = stdFile(fileName,dirNr)
            %
            %  INPUT: 
            %  - fileName: name of the file (including subpaths below th main path)
            %  - dirNr: optional a number of the path whete you want to go.
            %  i.e 1 to go to the 01-mesh directory

            %
            %
            matDir = '99-matlab';
            filePath = pwd;
            if strfind(filePath,matDir)==0
                error('Wrong directory structure');
            end
            % delete matlab fdirectory
            filePath = strrep(filePath,matDir,'');            
            if nargin >1
                % find the directory with the right number
                dirStr = num2str(dirNr,'%02.0f');
                % up one dir
                filePath = Util.getSubdir(filePath,dirStr);
            end
            outFile = fullfile(filePath,fileName);
            filePath = fileparts(outFile);
            if ~exist(filePath,'dir')
                mkdir(filePath);
                disp('Making new directory');
            end            
            
        end
        
        function filePath = getSubdir(filePath,dirStr)
            % find a subpath based on a specuific string
            %
            % filePath = getSubdir(filePath,dirStr)
            %
            % INPUT: 
            %    - filePath: the path
            %    - dirStr: the strting to look for
            tmp = fileparts(filePath);
            allDir = dir(tmp);
            found = false;
            for i=3:length(allDir)
                tmpDir = fullfile(allDir(i).folder,allDir(i).name);
                if length(allDir(i).name)<2
                    continue
                end
                if isfolder(tmpDir) && strcmpi(dirStr,allDir(i).name(1:2))
                    filePath = tmpDir;
                    found = true;
                    break;
                end
            end
            if ~found
                error('Specified directory could not be found');
            end
        end
        
        function outFile = stdFileZ(fileName,modelNr)
            % make a filename in a standard directory structure
            %
            %  outFile = stdFileZ(fileName,modelNr)
            
            Z_PATH = 'Z:\projects';
            sevenDir = '07-Uitv';
            matDir = '\99-matlab';
            filePath = pwd;
            if strfind(filePath,matDir)==0
                error('Wrong directory structure');
            end
            % delete matlab directory
            filePath = strrep(filePath,matDir,'');
            
            % projectnumber
            tmp = regexp(filePath,'\d*','match');
            if length(tmp)<4
                error('Wrong directory structure. Project number not found');
            end
            projNr   = tmp{2};
            curDirNr = tmp{end};
            indEnd   = strfind(filePath,curDirNr);
            indEnd    = indEnd(end)-2;
            filePath = filePath(1:indEnd);
            
            % look for model number and change
            
            if nargin ==2
                dirStr = num2str(modelNr,'%02.0f');
                filePath = Util.getSubdir(filePath,dirStr);
            end

% model name and workpackage
            ind  = strfind(filePath,sevenDir);
            if isempty(ind)
                error(['Wrong directory structure. ',sevenDir,' not found.']);
            end
            ind = ind+length(sevenDir);            
            filePath = filePath(ind:end);
            % filename
            filePath = fullfile(Z_PATH,projNr,filePath);
            outFile = fullfile(filePath,fileName);

        end
        
        function dirList  = getSubDir(aPath)
            % make list of subdirectories
            % 
            %  dirList  = getSubDir(aPath)
            
            allDir = dir(aPath);
            n = 0;
            dirList = {};
            for i=3:length(allDir)
                thePath = fullfile(allDir(i).folder, allDir(i).name);
                if isdir(thePath)
                    n = n+1;
                    dirList{n} = thePath;
                end
            end
            
        end
        
        function makeStdDir(pathK,modelName)
            % make a standardized directory structure on K and Z
            %
            % makeStdDir(pathK,modelName)
            %
            %
            EXEC_DIR     = '07-Uitv';
            STANDARD_DIR = 'K:\PROJECTS\00\00083\00083-01 Algemeen Kennisbeheer\AA knowledge domains before 2018\Dynamics of Estuaries and seas\01-modelling-directory-structure\templateStructure';
            ZDIR          = 'Z:\projects\';
            
            %extract numbes from dir
            allDir = Util.getSubDir(pathK);
            
            n = 0;
            theNum = 0;
            for i=1:length(allDir)
                [~,tmp] = fileparts(allDir{i});
                if isempty(tmp)
                    continue;
                end
                tmpNum = regexp(tmp,'\d*','match');
                if ~isempty(tmpNum)
                    n = n+1;
                    theNum(n) = str2double(tmpNum{1});
                end
            end
            newNum = max(theNum)+1;

            
            % make new path on K and check if ok
            modelName  = [num2str(newNum,'%02.0f-'),modelName];
            outPath = fullfile(pathK,modelName);
            
            button = questdlg({'Make the following path: ',outPath});
            if strcmpi(button,'yes')
                % copy standard structure to k-drive
                copyfile(STANDARD_DIR,outPath);
            else
                return;
            end
            
            % make directory on the z drive
            allNum = regexp(outPath,'\d*','match');
            projNumber = allNum{2};
            % subfolder
            ind = strfind(outPath,EXEC_DIR);
            if isempty(ind)
                errordlg('Non standard directory');
                return;
            end
            n = ind+length(EXEC_DIR);
            subFolder = outPath(n:end);
            
            outPath = fullfile(ZDIR,projNumber,subFolder);
            % check if exists
            if exist(outPath,'dir')
                errordlg('Path on the z does already exist');
                return;
            end
           
            button = questdlg({'Make the following path: ',outPath});
            if strcmpi(button,'yes')
                % make files on the k
                mkdir(outPath);
            else
                return;
            end

            
        end
        
        function terms = strsplit(s, delimiter)
            %Splits a string into multiple terms
            %
            %   terms = strsplit(s)
            %       splits the string s into multiple terms that are separated by
            %       white spaces (white spaces also include tab and newline).
            %
            %       The extracted terms are returned in form of a cell array of
            %       strings.
            %
            %   terms = strsplit(s, delimiter)
            %       splits the string s into multiple terms that are separated by
            %       the specified delimiter.
            %
            %   Remarks
            %   -------
            %       - Note that the spaces surrounding the delimiter are considered
            %         part of the delimiter, and thus removed from the extracted
            %         terms.
            %
            %       - If there are two consecutive non-whitespace delimiters, it is
            %         regarded that there is an empty-string term between them.
            %
            %   Examples
            %   --------
            %       % extract the words delimited by white spaces
            %       ts = strsplit('I am using MATLAB');
            %       ts <- {'I', 'am', 'using', 'MATLAB'}
            %
            %       % split operands delimited by '+'
            %       ts = strsplit('1+2+3+4', '+');
            %       ts <- {'1', '2', '3', '4'}
            %
            %       % It still works if there are spaces surrounding the delimiter
            %       ts = strsplit('1 + 2 + 3 + 4', '+');
            %       ts <- {'1', '2', '3', '4'}
            %
            %       % Consecutive delimiters results in empty terms
            %       ts = strsplit('C,Java, C++ ,, Python, MATLAB', ',');
            %       ts <- {'C', 'Java', 'C++', '', 'Python', 'MATLAB'}
            %
            %       % When no delimiter is presented, the entire string is considered
            %       % as a single term
            %       ts = strsplit('YouAndMe');
            %       ts <- {'YouAndMe'}
            %

            %   History
            %   -------
            %       - Created by Dahua Lin, on Oct 9, 2008
            %

            %% parse and verify input arguments

            assert(ischar(s) && ndims(s) == 2 && size(s,1) <= 1, ...
                'strsplit:invalidarg', ...
                'The first input argument should be a char string.');

            if nargin < 2
                by_space = true;
            else
                d = delimiter;
                assert(ischar(d) && ndims(d) == 2 && size(d,1) == 1 && ~isempty(d), ...
                    'strsplit:invalidarg', ...
                    'The delimiter should be a non-empty char string.');

                d = strtrim(d);
                by_space = isempty(d);
            end

            %% main

            s = strtrim(s);

            if by_space
                w = isspace(s);
                if any(w)
                    % decide the positions of terms
                    dw = diff(w);
                    sp = [1, find(dw == -1) + 1];     % start positions of terms
                    ep = [find(dw == 1), length(s)];  % end positions of terms

                    % extract the terms
                    nt = numel(sp);
                    terms = cell(1, nt);
                    for i = 1 : nt
                        terms{i} = s(sp(i):ep(i));
                    end
                else
                    terms = {s};
                end

            else
                p = strfind(s, d);
                if ~isempty(p)
                    % extract the terms
                    nt = numel(p) + 1;
                    terms = cell(1, nt);
                    sp = 1;
                    dl = length(delimiter);
                    for i = 1 : nt-1
                        terms{i} = strtrim(s(sp:p(i)-1));
                        sp = p(i) + dl;
                    end
                    terms{nt} = strtrim(s(sp:end));
                else
                    terms = {s};
                end
            end
        end
        
        function table2wiki(cellTable,fileOut)
            % generates wiki input from a table in a cell array
            %
            %Util.table2wiki(cellTable,fileOut)
            %
            %INPUT: cellTable: cellArray with the table to write. all cells should be
            %strings
            %       fileOut: filename where the wikitable is written
            %
            %
            
            nrRow = size(cellTable,1);
            nrCol = size(cellTable,2);
            % open file
            fid = fopen(fileOut,'w');
            
            % write header
            fprintf(fid,'%s \n','{|');
            
            for j=1:nrCol
                fprintf(fid,'! %s \n',cellTable{1,j});
            end
            fprintf(fid,'%s \n','|-');
            
            % write data
            for i = 2:nrRow
                for j=1:nrCol
                    fprintf(fid,'| %s \n',cellTable{i,j});
                end
                fprintf(fid,'%s \n','|-');
            end
            
            fprintf(fid,'%s \n','|}');
        end
        
    end
end