function varargout = supertrans_csv2mat
%SUPERTRANS_CSV2MAT convert bunch of EPSG *.csv files to one mat file
%
%   <D> = supertrans_csv2mat  
%
% reads all *csv required for Supertrans and saves them to mat file
% (because reading the *.csv files is slow)
%
% you can load the data with 
%
%   D = load('SuperTransData.mat')
%
% See also :supertrans

%% get all csv files in csv dir, and put their contents in SuperTransData.m
clear all

%% get all csv files in csv dir
csvFiles = dir(fullfile(filepathstr(mfilename('fullpath')),'csv_files/*.csv'));

%% add them all to superTransData.m
for iCsvFile = 1:length(csvFiles)
    fclose all;
    
    disp(['processing ',num2str(iCsvFile,'%0.3d'),' of ',num2str(length(csvFiles),'%0.3d'),': ',csvFiles(iCsvFile).name])
    fid=fopen(fullfile('csv_files',csvFiles(iCsvFile).name));

    %% get header names
    tLine0=fgetl(fid);
    rowNames=lower(strread(tLine0,'%q','delimiter',','));    
    %replace spaces in headers
    for jj=1:length(rowNames)
        rowNames{jj}=strrep(rowNames{jj},' ','_');
    end
    fileName = csvFiles(iCsvFile).name;
    fileName = fileName(1:end-4);
    
    %% find headers that refer to data that should be interpreted as numbers
    %in stead of strings
    for jj=1:length(rowNames) 
        if (strcmpi(rowNames{jj}(end-3:end),'code')&&~strcmpi(rowNames{jj}(1:5),'iso_a'))...
                ||strcmpi(rowNames{jj}(end-2:end),'lat')...
                ||strcmpi(rowNames{jj}(end-2:end),'lon')...
                ||strcmpi(rowNames{jj},'semi_minor_axis')...
                ||strcmpi(rowNames{jj},'semi_major_axis')...
                ||strcmpi(rowNames{jj},'inv_flattening')...
                ||strcmpi(rowNames{jj},'factor_b')... 
                ||strcmpi(rowNames{jj},'factor_c')...
                ||strcmpi(rowNames{jj},'parameter_value')  
                isNum(jj) = true;
        else
            isNum(jj) = false;
        end
    end
   
    %% read entire file
    for ii=1:inf
        tLine = fgetl(fid);
        if ~ischar(tLine),   break,   end
        % check for text qualifiers '"'; if they are found, 
        % add new lines till another text qualifier is found
        if any(strfind(tLine,'"'))
            while odd(sum(tLine=='"'))
                tLine=[tLine,fgetl(fid)];
            end
            %then replace delimiters (',') between text qualifiers with ';'
            textQualifiers = strfind(tLine,'"');
            delimiters = strfind(tLine,',');
            for kk=1:2:length(textQualifiers)
            tLine(delimiters(delimiters>textQualifiers(kk)&delimiters<textQualifiers(kk+1)))=';';
            end
        end
        content=strread(tLine,'%q','delimiter',',');
         for jj=1:length(content)
            if isNum(jj)
            STD.(fileName).(rowNames{jj})(ii)=str2double(content(jj)); 
            else
            STD.(fileName).(rowNames{jj})(ii)=content(jj); 
            end
         end
    end
    fclose(fid);
end
   
save(fullfile(filepathstr(mfilename('fullpath')),'SuperTransData'),'-struct','STD','-V6'); 

if nargout==1
   varargout = {STD};
end