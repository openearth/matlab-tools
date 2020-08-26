%Class to declare the most common Output
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Export < handle
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
        function writeAsciiImdc(strFileToWrite,mClean,cHeader,cColumns,cMetadata,vNumberOfDigits,hWait)
            % writeAsciiImdc(strFileToWrite,mClean,cHeader,cColumns,cMetadata,vNumberOfDigits)
            % is a script that writes cleaned ASCII data in combination with a header
            % file and write an ascii file.
            %
            % #INPUT:-strFileToWrite. Filename for the new file (except for _c, which is added automatically)
            %         -mClean: matrix with cleaned numerical data. First two columns are assumed
            %                  to be date and time.
            %         -cHeader: cell Array with per cell one line of the header that should be
            %                  printed in the file. This can be any text you want and it is printed on top of the file. In order not to use this option use
            %                  an empty matrix [] for this variable.
            %         -cColumns: (optional) a mx1 cell array containing a description of each of
            %                    the m columns in mClean. If this option is used, the standard
            %                    IMDC heading is also printed in the file.
            %         -cMetadata: (optional) nx2 cell array containing the description of the
            %                     n metadata in the first column and the corresponding metadata
            %                     itself in the second column.
            %        -vNumberOfDigits: (optional) a 2x1 vector with the number of numbers after the dot in the first two columns of output values and in all the other columns.
            %        -hWait: (optional): The handle to a waitbar on which the progress
            %        should be updated
            %
            % #OUTPUTS:
            % A text file with the data from mClean and the header from
            % cHeader, cColumns and cMetaData
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: Alexander Breugem
            % Date: June 2008
            % Modified by:
            % Date: strFiletoWrite
            % Modified:
            % Date: 4-10-2011
            % Modified:option to include multiline metadata

            bColumns = 1;
            bMetaData = 1;

            switch nargin
                case 3
                    bColumns = 0;
                    bMetaData = 0;
                    vNumberOfDigits = [0 2];
                    bWaitbar = 0;
                case 4
                    bMetaData = 0;
                    vNumberOfDigits = [0 2];
                    bWaitbar = 0;
                case 5
                    vNumberOfDigits = [0 2];
                    bWaitbar = 0;
                case 6
                    bWaitbar = 0;
                case 7
                    if strcmp(get(hWait,'tag'),'TMWWaitbar')
                        bWaitbar = 1;
                    else
                        bWaitbar = 0;
                    end;

                otherwise
                    errordlg('Wrong number of input arguments in Script_IMDC_LtRCM9_writeIMDCformat');
                    return;
            end;

            if isempty(vNumberOfDigits)
                vNumberOfDigits = [0 2];
            end;

            if bColumns
                if ~isempty(cColumns)
                    if length(cColumns)~=size(mClean,2)
                        warning('Number of columns in data does not match number of columns in cColumns. ');
                    end;
                else
                    bColumns = 0;
                    warning(['No data were found in cColumns. Therefore no column headings and metadata will be added to ',strFiletoWrite]);
                end;
            end;

            strFormat=['%9.',num2str(vNumberOfDigits(1)),'f %7.',num2str(vNumberOfDigits(1)),'f '];
            for i = 3:size(mClean,2)
                strFormat = [strFormat, '%7.',num2str(vNumberOfDigits(2)),'f '];
            end;
            strFormat = [strFormat, '\n'];

            %strFileToWrite = [strFileToWrite(1:end-4),'_c.txt'];

            fid = fopen(strFileToWrite,'wt');
            if fid<0
                strError = [strFileToWrite, ' cannot be opened to write. It may be protected (e.g. be opened in another program, or the location may not exist.'];
                error(strError);
            end;

            %algemene header

            for i=1:length(cHeader)
                fprintf(fid,'%s\n',cHeader{i});
            end;

            if bColumns
                fprintf(fid, '%s\n', '* International Marine and Dredging Consultants, IMDC');
                fprintf(fid, '%s\n', '* Antwerp, Belgium');
                fprintf(fid, '%s\n', '*');

                %header metadata
                if bMetaData
                    nTelMeta = 1;
                    for nI = 1:size(cMetadata,1)
                        nSizeMeta = size(cMetadata{nI,2},1);
                        if nSizeMeta>1
                            strI = [num2str(nTelMeta,'%2.0f'),'-',num2str(nSizeMeta-1+nTelMeta,'%2.0f')];
                            nTelMeta = nTelMeta + nSizeMeta;
                        else
                            strI = num2str(nTelMeta,'%2.0f');
                            nTelMeta = nTelMeta + 1;
                        end;
                        if length(strI)<2
                            strI = [' ',strI];
                        end;
                        fprintf(fid, '%s\n', ['* Line  ',strI,': ',char(cMetadata(nI,1))]);
                    end;
                end;
                fprintf(fid, '%s\n', '*');
                for nI = 1:length(cColumns)
                    strI = num2str(nI,'%2.0f');
                    if length(strI)<2
                        strI = [' ',strI];
                    end;
                    fprintf(fid, '%s\n', ['* Column  ',strI,': ',char(cColumns(nI))]);
                end;

                fprintf(fid, '%s\n', '*');
                fprintf(fid, '%s\n', '* Remarks: - Value indicating a no data situation : NaN');
                fprintf(fid, '%s\n', '* ----------------------------------------------------------------------------------------');
                if bMetaData
                    for nI = 1:size(cMetadata,1)
                        nData = cMetadata{nI,2};
                        for nJJ = 1:size(nData,1)
                            if ischar(nData)
                                strData=nData(nJJ,:);
                            else
                                strData = num2str(nData(nJJ,:),'%f');
                            end;
                            fprintf(fid, '%s\n',strData);
                        end;
                    end;
                end;
            end;

            nLines  = size(mClean,1);
            for i =1:nLines
                if bWaitbar && (0 == mod(i,(nLines/20)))
                    waitbar(i/nLines,hWait);
                end;
                fprintf(fid,strFormat,mClean(i,:));
            end;

            fclose(fid);
        end;

        function  writeArcView(X,Y,Z,theFile,noData,format)
            % This functions writes arciew ascii rasters.
            %
            % writeArcView(X,Y,Z,theFile,noData)
            %
            % INPUTS:-sctData
            % X: matrix with x coordinates. 
            % Y: matrix with y coordinates.
            % Z: matrix with values. Note that the dtaa 
            % theFile: filename that is used for writing the data
            % noData (optional; default = -9999): no data value
            % format (optional default = '%f '): format description
            %
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: JUL 2015
            % Modified by:
            % Date:
            
            %constants
            nSmall = 1e-15;
            
            %checking input data
            if nargin<5
                noData = -9999;
            end;
            if nargin<6
                format = '%f ';
            end;
           
            
            gridSizeX = diff(X(1,:));
            if (gridSizeX==0)
                error('Zero grid size in X direction. Note that X data are expected on the first dimenions.');
            end
            if ~isempty(find(abs(diff(gridSizeX))>nSmall,1))
                error('Raster size in x-direction must be constant!');
            end;
            gridSizeY = diff(Y(:,1));
            if (gridSizeY==0)
                error('Zero grid size in Y direction. Note that Y data are expected on the first dimenions.');
            end
            if gridSizeY(1) > 0
                Y = flipud(Y);
                Z = flipud(Z);
            end
            
            if ~isempty(find(abs(diff(gridSizeY))>nSmall,1))
                error('Raster size in y-direction must be constant!');
            end;
            
            if gridSizeX(1)~=gridSizeX(2)
                error('Raster cells must be square!');
            end;
            
            if any(size(X)~=size(Y))
                error('X and Y must have the same size');
            end;
            
            %writing data
            if  any(size(X)~=size(Z))
                error('Z must have the same size as X and Y');
            end;
            
            % preprocess data
            
            mask = isnan(Z);
            Z(mask) =noData;
            
            % open file
            fid = fopen(theFile,'w');
            if fid<0
                error([theFile ' cannot be opened']);
            end;
            
            % make sure the coordinates are in the right order
            
            
            % write header
            nrCols = size(X,2);
            nrRows = size(X,1);
            xLowLeft = X(end,1);
            yLowLeft = Y(end,1);
            
            fprintf(fid,'ncols \t %6.0f\n',nrCols);
            fprintf(fid,'nrows \t %6.0f\n',nrRows);
            fprintf(fid,'xllcorner \t %6.5f\n',xLowLeft);
            fprintf(fid,'yllcorner \t %6.5f\n',yLowLeft);
            fprintf(fid,'cellsize \t %6.2f\n',gridSizeX(1));
            fprintf(fid,'%s \t','NODATA_value');
            fprintf(fid,[format,'\n'],noData);
            theFormat = repmat(format,1,size(Z,2));
            nrRow = size(Z,1);
           
            % write data
            for i =1:nrRow
                if mod(i,500)==0
                    disp([num2str(100*i/nrRow),'% completed']);
                end;
                fprintf(fid,[theFormat, ' \n'],Z(i,:));
            end;
            
            % close file
            fclose(fid);
        end
        
        
        function writeCsvSynapps(vTime, vParameter, strParameterName, strFile, nDigits)
            %function writeCsv(sctInput)
            % This function writes data to Synapps CSV-data format. The
            % format contains a header (Time, parameter name) and followed 
            % by a N X 2 data. The time serie has expressed in yyyy/mm/dd HH:MM/SS 
            %
            % The NaN-value will be replaced by the dummy value of -999
            %
            % INPUTS:
            %        vTime: Nx1 vector in MATLAB time
            %        vParameter: Nx1 vector containing the data
            %        strParameterName: string of parameter name
            %        strFile: string of the output file (incl. path)
            %        nDigits: number of digits to right (default: 2)      
            %
            % OUTPUTS:-a CSV file in synapps data format
            %
            %
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Jan Claus
            %
            % Date: jan 2018
            % Modified by: 
            % Date: 
            % Modified by: 
            
            % DEFINING DEFAULTS
             if nargin < 5
                nDigits = 2;  
             end
             nEmpty = -999; % empty value
             
             % 
             if isempty(strParameterName)
                strParameterName = 'Measurement value';
             end
             % DEFINING FORMAT;
             MyCell = {round(max(vParameter),0),round(min(vParameter),0),nEmpty};
             MyCell = cellfun(@num2str,MyCell,'UniformOutput',false);
             nValues = max(cellfun(@length,MyCell));
                          
             % REPLACING NAN BY -999
             vParameter(isnan(vParameter)) = nEmpty;
             
             % ROUND THE VALUES
             vParameter = round(vParameter, nDigits);
             
             % WRITE CSV
             Output.strCSVFile = strFile;
             Output.mData = [vTime, vParameter];
             Output.cHeader = {'time', strParameterName};
             Output.strFormat = ['%',num2str(nValues),'.',num2str(nDigits),'f'];
             Output.cTimeFormat = {'yyyy/mm/dd HH:MM:SS',[]};
             Export.writeCsv(Output);
        end
        
         function writeCsv(sctInput, metaData)
            %function writeCsv(sctInput)
            % This function writes dfata as a CSV file
            %
            % INPUTS:-sctInput: a structure with the fields
            %           strCSVFile: the filename of the file to make
            %           mData: a matrix with the data
            %           cHeader: a cell array containing the header cells
            %           cRowname: a cell array with names of the rows to be added to a table
            %           strFormat: a string with the format to use
            %           cTimeFormat: a cell array with the format used to convert serial time to a datestr (e.g. yyyymmdd HHMMSS for IMDC format). Use [] for not converting
            % OUTPUTS:-a CSV file with the data
            %
            %
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: mar 2010
            % Modified by: ABR: extra opties voor Rijnamen en tijdsdata
            % Date: oct 2013
            % Modified by: SEO/JCA
            
            [fid,strMessage] = fopen(sctInput.strCSVFile,'w');
            if fid <0
                %    strMessage = ['Cannot open sctInput.strCSVFile'];
                error(strMessage);
            end;

            if ~isfield(sctInput,'mData');
                error('Input data must contain field mData');
            end;

            if isfield(sctInput,'strFormat');
                strF =  sctInput.strFormat;
            else
                strF =  '%12.2f';
            end;

            nColData = size(sctInput.mData,2) ;
            nRowData = size(sctInput.mData,1) ;

            if isfield(sctInput, 'cHeader')
                nLengthHead = length(sctInput.cHeader);
                if nLengthHead~=nColData
                    error(['The number of cells in cHeader (',num2str(nLengthHead),') does not match the number of columns in sctInput.mData (',num2str(nColData),')']);
                end;
            end;

            if isfield(sctInput,'cRowname')
                if nRowData ~=length(sctInput.cRowname)
                    error(['The number of cells in cRowname (',num2str(length(sctInput.cRowname)),') does not match the number of columns in sctInput.mData (',num2str(nRowData),')']);
                end;
            end;

            nPerc = 5.*round(nRowData/100);

            %eventueel rijnaam plotten
            if isfield(sctInput,'cRowname')
                fprintf(fid,'%s',' ,');
            end;
            strFormat = [];

            %header
            if isfield(sctInput, 'cHeader')
                for nI = 1:nLengthHead-1
                    fprintf(fid,'%s',[sctInput.cHeader{nI},',']);
                    if isfield(sctInput,'cTimeFormat')
                        if ~isempty(sctInput.cTimeFormat{nI})
                            strFormat = [strFormat,'%s,'];
                        else
                            strFormat = [strFormat,[strF,',']];
                        end;
                    else
                        strFormat = [strFormat,[strF,',']];
                    end;

                end;
                if isempty(nI)
                    nI = 0;
                end;
                fprintf(fid,'%s\n',[sctInput.cHeader{nI+1}]);
            end;
            strFormat = [strFormat,[strF,'\n']];

            %data
            mData = [];
            if isfield(sctInput,'cTimeFormat')
                for nJ = 1:nColData
                    strDelimiter = ',';
                    if nJ == nColData
                       strDelimiter = ''; 
                    end
                    if isfield(sctInput,'hWait')
                        waitbar(nJ./nColData./2,sctInput.hWait);
                    end;
                    if ~isempty(sctInput.cTimeFormat{nJ})
                        vData = [datestr(sctInput.mData(:,nJ),sctInput.cTimeFormat{nJ}),repmat(strDelimiter,length(sctInput.mData(:,nJ)),1)];
                    else
                        vData = num2str(sctInput.mData(:,nJ),[strF,strDelimiter]);
                    end;
                    mData = [mData,vData];
                end;
                for nJ = 1:nRowData
                    if mod(nJ,nPerc)==0 && isfield(sctInput,'hWait')
                        waitbar(0.5+ nJ./nRowData/2,sctInput.hWait);
                    end;
                    fprintf(fid,'%s\n',mData(nJ,:));
                end;
            else
                if isfield(sctInput,'cRowname')
                    for nJ = 1:nRowData
                        if mod(nJ,nPerc)==0 && isfield(sctInput,'hWait')
                            waitbar(nJ./nRowData,sctInput.hWait);
                        end;
                        fprintf(fid,'%s\n',[sctInput.cRowname{nJ},',',num2str(sctInput.mData(nJ,:),strFormat)]);
                    end;
                else
                    for nJ = 1:nRowData
                        if mod(nJ,nPerc)==0 && isfield(sctInput,'hWait')
                            waitbar(nJ./nRowData,sctInput.hWait);
                        end;
                        fprintf(fid,strFormat,sctInput.mData(nJ,:));
                    end;
                end;
            end;

            if isfield(sctInput, 'printMetadata')
                if isa(sctInput.printMetadata, 'char')
                    sctInput.printMetadata = str2num(sctInput.printMetadata);
                end;
                if sctInput.printMetadata == 1
                    sizeMeta = size(metaData);
                    for ii=1:sizeMeta(1)
                        %replace the comma character to avoid conflicts
                        %with the columns
                        newStr = strrep(metaData{ii,1}, ',', ' - ');
                        fprintf(fid,'%s\n',[newStr, ',', metaData{ii,2}]);
                    end;
                end;
            end;

            fclose(fid);
        end;

    end
end