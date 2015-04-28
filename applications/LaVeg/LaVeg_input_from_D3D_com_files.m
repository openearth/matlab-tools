function csv_data = LaVeg_input_from_D3D_com_files(com_files,varargin)
% This function creates input files for the LaVeg habitat model based on
% multiple sets of com-*.* files.
%
% Therefore, the function requires a list of com-*.* file sets as input.
% For each of the specified com-*.* file sets, the following files need to
% be available (examples for the com-*.* set com-domain_1.*):
% 
%      - com-domain_1.lga
%      - com-domain_1.cco
%      - com-domain_1.sal
%      - com-domain_1.tem
%      - com-domain_1.vol
%      - com-domain_1.srf
%      - com-domain_1.dat
%
% SYNTAX (<> indicates optional keywords):
%
% <csv_data> = LaVeg_input_from_D3D_com_files(com_files,<keyword,value>)
%
% INPUT VARIABLES (REQUIRED):
%
% com_files       Cellstr of all com-<domains>.* file sets to consider. When
%                 only considering 1 domain, a single line char string is
%                 also allowed. For each com-*.* file set, the path can be
%                 in- or exluded. When specifying e.g. a com-*.* file set for
%                 a domain called "domain_1", one could use either
%                 com-domain_1 or com-domain_1.*, with or without starting
%                 with the complete path. The script will then automaticall
%                 look for com-domain_1.lga, com-domain_1.cco, etc. and will
%                 return errors when missing files are encountered.
%
%                 Examples:
%
%                 (1) {'com-domain1','com-domain2.*','D:/model/com-domain3'};
%                 (2) 'com-test_model'
% 
%
% INPUT VARIABLES (OPTIONAL <KEYWORD,VALUE> PAIRS):
%
% To get an overview of the default <keyword,value> pairs, simply call the
% function without any input arguments (LaVeg_input_from_D3D_com_files)
%
% 'averaging'      The keyword 'averaging' is used to set the way the data
%                  is averaged. The following options are available for
%                  this:
%
%                  - 'all'       <-- this is the default
%                  - 'yearly'
%                  - 'monthly'
%                  - 'weekly'
%                  - 'daily'
%                  - [matlab_datenum_start matlab_datenum_end]
%
%                  Below, a description of all the options is provided. For
%                  these examples, we assume a com-*.* file set is
%                  specified, which runs from 01/07/2014 untill 31/12/2015
%                  
%                  - 'all'        This (default) option creates one single
%                                 LaVeg input file, for each of the provided
%                                 com-*.* file sets. Using all the data
%                                 that is provided
%
%                  - 'yearly'     This option creates LaVeg input files for
%                                 each of the different (calendar) years.
%                                 For this example, this would result in a
%                                 2014 and 2015 file
%
%                  - 'monthly'    This option creates LaVeg input files for
%                                 each of the different (calendar) months.
%                                 For this example, this would result in a
%                                 total of 18 files (Called 2014_Jun,
%                                 2014_Jul, ... , 2015_Nov up to 2015_Dec)
%
%                  - 'weekly'     This option creates LaVeg input files for
%                                 every week (7 consecutive days). The
%                                 aggregation is not done per calendar
%                                 week, so for our example (which starts on
%                                 a Wednesday), each week starts at
%                                 Wednesday and ends on Tuesday. In this
%                                 example, we would end up with 79 files
%                                 (called week_01 till week_79), in which
%                                 the last week only consists of 3 days
%                                 (the remainder)
%
%                  - 'daily'      This option creates LaVeg input files for
%                                 each day. In this example, we would end
%                                 up with 549 input files (called
%                                 2014_07_01, 2014_07_02, ... , 2015_12_30
%                                 up to 2015_12_31).
%
%                  - [matlab_datenum_start matlab_datenum_end]
%                                 This option creates a single LaVeg input
%                                 file for the specified time interval.
%                                 Please note that any com-*.* file set dat
%                                 data should be available within this
%                                 specified interval
%
%                  Please note that for all interval options, the com-*.*
%                  file set output interval should be smaller than (or at
%                  least equal to) the requested interval, this is checked.
%
% 'output_folder'  The keyword 'output_folder' sets the output folder where
%                  the LaVeg input files are written to. It is to be
%                  specified in a single line char string. By default, this
%                  equals the folder LaVeg in the current working directory
%                  All LaVeg input files will be written to different
%                  directories, for each of the specified com-*.* file sets
%
% 'overwrite'      When setting the keyword 'overwrite' to true, LaVed
%                  input files that already exist will be overwritten. By
%                  default, this keyword is set to false.
%
% 'separator'      The separator keyword can be used to alter the value
%                  separator in the output *.csv files. By default, this is
%                  set to ',' (such that the latest versions of Excel will 
%                  generate separte columns upon opening, some older
%                  versions might still work with the separator ';')
%
% 'write_to_file'  This keyword can be set to false (default is true) when
%                  only the data is required (and csv files don't have to 
%                  be written). The data will be stored in the specified
%                  output variable (or ans if not).
%
% 'limiter'        This keyword allows you to specify some limiters for the
%                  data (depth, salinity & temp), the format is as follows:
%
%                  [min_dep max_dep min_sal max_sal min_temp max_temp]
%
%                  By default, this is set to [-15 11050 0 400 -90 60], but
%                  can be changed to any value. The units are in meter, ppt 
%                  and degrees Celcius.
%
% OUTPUT VARIABLES:
%
% csv_data         This optional output keyword (else data is send to the
%                  default ans variable) stores all the data associated
%                  with the csv files. Incl. data, path, format, name and
%                  location.
%
% Cell_ID,M,N,X,Y,mean(dep),std(dep),mean(sal),std(sal),mean(tem),std(tem)
%
% Contact Freek Scheel (freek.scheel@deltares.nl) if bugs are encountered
%              
% See also: waqfil delwaq fread dlmwrite

%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
%       Freek Scheel
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Developed as part of the TO27 project at the Water Institute of the
%       Gulf, Baton Rouge, Louisiana. Please do not make any functional
%       changes to this script, as it is relied upon within this modelling
%       framework.
%
%       Please contact me if errors occur.
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Default keywords:
%

OPT.output_folder = [pwd filesep 'LaVeg'];
OPT.averaging     = 'all';
OPT.overwrite     = false;
OPT.separator     = ',';
OPT.write_to_file = true;
OPT.limiter       = [-15 11050 0 400 -90 60];

if nargin == 0
    disp(' ')
    disp('Default OPT = ')
    disp(' ')
    disp(OPT)
    return
end

OPT = setproperty(OPT,varargin);

%% Check all the input
%

% Check the limiter:
if isnumeric(OPT.limiter)
    OPT.limiter = OPT.limiter(:);
    if min(size(OPT.limiter) == [6,1]) == 1
        if min(diff(reshape(OPT.limiter,2,3)) > 0) == 1
            % Good, we will not check for physical limits, thats up to the user 
        else
            error('Please make sure the limiters have increasing values')
        end
    else
        error('Please specify 6 values for the keyword ''limiter''')
    end
else
    error('Please specify a vector for the keyword ''limiter''')
end

% Check the averaging keyword:
if isstr(OPT.averaging)
    if size(OPT.averaging,1) == 1
        if ~isempty(strfind(OPT.averaging,'all'))
            OPT.averaging = 'all';
        elseif ~isempty(strfind(OPT.averaging,'year'))
            OPT.averaging = 'yearly';
        elseif ~isempty(strfind(OPT.averaging,'month'))
            OPT.averaging = 'monthly';
        elseif ~isempty(strfind(OPT.averaging,'week'))
            OPT.averaging = 'weekly';
        elseif ~isempty(strfind(OPT.averaging,'day')) || ~isempty(strfind(OPT.averaging,'daily'))
            OPT.averaging = 'daily';
        else
            error(['Unknown text input for the keyword ''averaging'': ' OPT.averaging])
        end 
    else
        error('Text input for the keyword ''averaging'' should contain a single line')
    end
elseif isnumeric(OPT.averaging)
    OPT.averaging = OPT.averaging(:);
    if min(size(OPT.averaging) == [2,1]) == 0
        error('The datenum input should contain 2 values, a start and end value, indicating the considered interval')
    end
    if diff(OPT.averaging) <= 0
        error('The datenum input should have increasing size to specify the interval')
    end
else
    error('Unknown input for the keyword ''averaging'', please check the options in the functions'' help')
end

% Check the overwrite keyword:
if OPT.write_to_file
    if ~islogical(OPT.overwrite) && OPT.overwrite~=0 && OPT.overwrite~=1
        error('Please set the keyword ''overwrite'' to either true or false')
    end
end

% Check the write_to_file keyword:
if ~islogical(OPT.write_to_file) && OPT.write_to_file~=0 && OPT.write_to_file~=1
    error('Please set the keyword ''write_to_file'' to either true or false')
end

% Check the separator keyword:
if OPT.write_to_file
    if isstr(OPT.separator)
        if min(size(OPT.separator)) ~= 1
            error('Please make sure the separator is a single character')
        end
    else
        error(['Please specify the separator in a string'])
    end
end

% Check the output_folder keyword:
if OPT.write_to_file
    if isstr(OPT.output_folder)
        if strcmp(OPT.output_folder(1,end),filesep)
            OPT.output_folder = OPT.output_folder(1,1:end-1);
        end
        if exist(OPT.output_folder,'dir')~=7
            try
                mkdir(OPT.output_folder)
            catch
                error(['Matlab was unable to create the folder ' OPT.output_folder])
            end
        else
            if size(dir(OPT.output_folder),1)>2
                if OPT.overwrite
                    % Allright, we will overwrite files if needed...
                else
                    disp(['Output folder: ' OPT.output_folder])
                    error(['The specified output folder is not empty, if you wish to continue, either specify a different output_folder, empty the folder, or set the keyword ''overwrite'' to true'])
                end
            end
        end
    else
        error('Please specify the ''output_folder'' keyword in a single line char string')
    end
end

% Check the com_files input:

% Start with checking the format:
if isstr(com_files)
    if size(com_files,1) == 1
        com_files = {com_files};
    else
        error('The provided single line char string specifying a com-*.* file set does not contain a single line, please check this and use a cellstr when specifying multiple com-*.* sets (see help)')
    end
elseif iscellstr(com_files)
    % Make sure the contents are placed in {N,1} order:
    com_files = com_files(:);
end

% Now lets check the contents, does it comply with the format?
for ii=1:size(com_files,1)
    if isempty(strfind(com_files{ii,1},filesep))
        folder = [pwd filesep];
    else
        folder = com_files{ii,1}(1,1:max(strfind(com_files{ii,1},filesep)));
        if length(com_files{ii,1}) > max(strfind(com_files{ii,1},filesep))
            com_files{ii,1} = com_files{ii,1}(1,max(strfind(com_files{ii,1},filesep))+1:end);
        else
            error(['Incorrect input for com-*.* file set on line ' num2str(ii) ': ' com_files{ii,1} ' (?)'])
        end
    end
    % First set of checks:
    if length(com_files{ii,1})<5 || ~strcmp(com_files{ii,1}(1,1:4),'com-')
        error(['Incorrect input for com-*.* file set on line ' num2str(ii) ': ' com_files{ii,1} ' (?)'])
    end
    % remove any .* tails (they are perfectly allowed):
    if strcmp(com_files{ii,1}(1,end-1:end),'.*')
        com_files{ii,1} = com_files{ii,1}(1,1:end-2);
    end
    % Second set of checks:
    if ~isempty(strfind(com_files{ii,1},'.')) || length(com_files{ii,1})<5
        error(['Incorrect input for com-*.* file set on line ' num2str(ii) ': ' com_files{ii,1} ' (?)'])
    end
    com_files{ii,1} = [folder com_files{ii,1}];
end

% Finally, let's check whether all files linked to these sets exist or not:
for ii=1:size(com_files,1)
    if exist([com_files{ii,1} '.lga'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.lga'', please check this'])
    end
    if exist([com_files{ii,1} '.cco'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.cco'', please check this'])
    end
    if exist([com_files{ii,1} '.sal'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.sal'', please check this'])
    end
    if exist([com_files{ii,1} '.tem'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.tem'', please check this'])
    end
    if exist([com_files{ii,1} '.vol'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.vol'', please check this'])
    end
    if exist([com_files{ii,1} '.srf'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.srf'', please check this'])
    end
    if exist([com_files{ii,1} '.dat'],'file') ~= 2
        error(['The following file does not exist: ''' com_files{ii,1} '.dat'', please check this'])
    end
end

%% Load the data:
%

% All input is correct, lets load all the data from the different files:
for ii=1:size(com_files,1)
    if OPT.write_to_file
        disp([num2str(ii,'%02.0f') '/' num2str(size(com_files,1),'%02.0f') ' - Starting LaVeg input file creation for com-*.* file set ''' com_files{ii,1} '.*'':'])
        disp(' ')
    else
        disp([num2str(ii,'%02.0f') '/' num2str(size(com_files,1),'%02.0f') ' - Starting LaVeg input data creation for com-*.* file set ''' com_files{ii,1} '.*'':'])
        disp(' ')
    end
    lga_files{ii,1} = [com_files{ii,1} '.lga'];
    cco_files{ii,1} = [com_files{ii,1} '.cco'];
    sal_files{ii,1} = [com_files{ii,1} '.sal'];
    tem_files{ii,1} = [com_files{ii,1} '.tem'];
    vol_files{ii,1} = [com_files{ii,1} '.vol'];
    srf_files{ii,1} = [com_files{ii,1} '.srf'];
    dat_files{ii,1} = [com_files{ii,1} '.dat'];
    
    % Load the lga data:
    try
        lga_data{ii,1}         = delwaq('open',lga_files{ii,1});
        lga_data{ii,1}.X_clean = lga_data{ii,1}.X; lga_data{ii,1}.X_clean(find(round(lga_data{ii,1}.X_clean)==-1000))=NaN; lga_data{ii,1}.X_clean(lga_data{1,1}.Index<0)=NaN;
        lga_data{ii,1}.Y_clean = lga_data{ii,1}.Y; lga_data{ii,1}.Y_clean(find(round(lga_data{ii,1}.Y_clean)==-1000))=NaN; lga_data{ii,1}.Y_clean(lga_data{1,1}.Index<0)=NaN;
    catch err
        error(['Unable to load data from lga file: ' lga_files{ii,1} ' with message: ' err.message])
    end
    disp(['cco file: Loaded succesfully'])
    disp(['lga file: Loaded succesfully'])
    % Load the dat data:
    try
        dat_data{ii,1} = datenum(num2str(vs_let(vs_use(dat_files{ii,1},'quiet'),'PARAMS','IT01','quiet')),'yyyymmdd');
    catch err
        error(['Unable to load time information from dat file: ' dat_files{ii,1} ' with message: ' err.message])
    end
    disp(['dat file: Loaded succesfully'])
    % Load the sal data:
    try
        sal_info{ii,1} = waqfil('open',sal_files{ii,1},lga_data{ii,1}.NoSeg);
        % At this moment, waqfil limits some functionality and documentation
        % We need all the available data (all timepoints), which is done next: 
        csv_fid = fopen(sal_files{ii,1},'r');
        sal_data = fread(csv_fid,[sal_info{ii,1}.NVals+1 sal_info{ii,1}.NTimes],'float32');
        fclose(csv_fid);
        % Please be aware that the first indice resembles time, so we can exlude that: 
        sal_data     = sal_data(2:end,:);
        sal_tim_data{ii,1} = round(((dat_data{ii,1} + (sal_info{ii,1}.Times)./(60*60*24))*24*60*60))./(24*60*60);
        sal_tim_dt{ii,1}   = (unique(round(diff(round(sal_tim_data{ii,1}.*10^6)./10^6)*24*3600))./3600); % in hours
        if min(size(sal_tim_dt{ii,1}) == [1,1]) == 0
            error('The time axis appears to be non-linear');
        end
        % Now lets remove those limits:
        sal_data_lims = max(OPT.limiter(3,1),min(sal_data,OPT.limiter(4,1)));
        sal_data_lims(isnan(sal_data)) = NaN; sal_data = sal_data_lims;
        sal_data_gridded = NaN([size(lga_data{ii,1}.X) size(sal_data,2)]);
        for jj=1:size(sal_data,2)
            sal_data_gridded((jj-1)*(prod(size(lga_data{ii,1}.X))) + find(lga_data{ii,1}.Index>0)) = sal_data(lga_data{ii,1}.Index(find(lga_data{ii,1}.Index>0)),jj);
            % Want to check it out?
            % for t=1:size(sal_data,2); pcolor(lga_data{ii,1}.X_clean,lga_data{ii,1}.Y_clean,squeeze(sal_data_gridded(:,:,t))); shading flat; drawnow; end
        end
    catch err
        error(['Unable to load data from sal file: ' sal_files{ii,1} ' with message: ' err.message])
    end
    disp(['sal file: Loaded succesfully'])
    % Load the tem data:
    try
        tem_info{ii,1} = waqfil('open',tem_files{ii,1},lga_data{ii,1}.NoSeg);
        % At this moment, waqfil limits some functionality and documentation
        % We need all the available data (all timepoints), which is done next: 
        csv_fid = fopen(tem_files{ii,1},'r');
        tem_data = fread(csv_fid,[tem_info{ii,1}.NVals+1 tem_info{ii,1}.NTimes],'float32');
        fclose(csv_fid);
        % Please be aware that the first indice resembles time, so we can exlude that: 
        tem_data     = tem_data(2:end,:);
        tem_tim_data{ii,1} = round(((dat_data{ii,1} + (tem_info{ii,1}.Times)./(60*60*24))*24*60*60))./(24*60*60);
        tem_tim_dt{ii,1}   = (unique(round(diff(round(tem_tim_data{ii,1}.*10^6)./10^6)*24*3600))./3600); % in hours
        if min(size(tem_tim_dt{ii,1}) == [1,1]) == 0
            error('The time axis appears to be non-linear');
        end
        % Now lets remove those limits:
        tem_data_lims = max(OPT.limiter(5,1),min(tem_data,OPT.limiter(6,1)));
        tem_data_lims(isnan(tem_data)) = NaN; tem_data = tem_data_lims;
        tem_data_gridded = NaN([size(lga_data{ii,1}.X) size(tem_data,2)]);
        for jj=1:size(tem_data,2)
            tem_data_gridded((jj-1)*(prod(size(lga_data{ii,1}.X))) + find(lga_data{ii,1}.Index>0)) = tem_data(lga_data{ii,1}.Index(find(lga_data{ii,1}.Index>0)),jj);
            % Want to check it out?
            % for t=1:size(tem_data,2); pcolor(lga_data{ii,1}.X_clean,lga_data{ii,1}.Y_clean,squeeze(tem_data_gridded(:,:,t))); shading flat; drawnow; end
        end
    catch err
        error(['Unable to load data from tem file: ' tem_files{ii,1} ' with message: ' err.message])
    end
    disp(['tem file: Loaded succesfully'])
    % Load the vol data:
    try
        vol_info{ii,1} = waqfil('open',vol_files{ii,1},lga_data{ii,1}.NoSeg);
        % At this moment, waqfil limits some functionality and documentation
        % We need all the available data (all timepoints), which is done next: 
        csv_fid = fopen(vol_files{ii,1},'r');
        vol_data = fread(csv_fid,[vol_info{ii,1}.NVals+1 vol_info{ii,1}.NTimes],'float32');
        fclose(csv_fid);
        % Please be aware that the first indice resembles time, so we can exlude that: 
        vol_data     = vol_data(2:end,:);
        vol_tim_data{ii,1} = round(((dat_data{ii,1} + (vol_info{ii,1}.Times)./(60*60*24))*24*60*60))./(24*60*60);
        vol_tim_dt{ii,1}   = (unique(round(diff(round(vol_tim_data{ii,1}.*10^6)./10^6)*24*3600))./3600); % in hours
        if min(size(vol_tim_dt{ii,1}) == [1,1]) == 0
            error('The time axis appears to be non-linear');
        end
        vol_data_gridded = NaN([size(lga_data{ii,1}.X) size(vol_data,2)]);
        for jj=1:size(vol_data,2)
            vol_data_gridded((jj-1)*(prod(size(lga_data{ii,1}.X))) + find(lga_data{ii,1}.Index>0)) = vol_data(lga_data{ii,1}.Index(find(lga_data{ii,1}.Index>0)),jj);
            % Want to check it out?
            % for t=1:size(vol_data,2); pcolor(lga_data{ii,1}.X_clean,lga_data{ii,1}.Y_clean,squeeze(vol_data_gridded(:,:,t))); shading flat; drawnow; end
        end
    catch err
        error(['Unable to load data from vol file: ' vol_files{ii,1} ' with message: ' err.message])
    end
    disp(['vol file: Loaded succesfully'])
    % Load the srf data:
    try
        srf_info{ii,1}         = waqfil('open',srf_files{ii,1});
        srf_data{ii,1}         = waqfil('read',srf_info{ii,1});
        srf_data_gridded{ii,1} = NaN(size(lga_data{ii,1}.X));
        srf_data_gridded{ii,1}(find(lga_data{ii,1}.Index>0)) = srf_data{ii,1}(lga_data{ii,1}.Index(find(lga_data{ii,1}.Index>0)),1);
        % Want to check it out?
        % pcolor(lga_data{ii,1}.X_clean,lga_data{ii,1}.Y_clean,srf_data_gridded{ii,1}); shading flat;
    catch err
        error(['Unable to load data from srf file: ' srf_files{ii,1} ' with message: ' err.message])
    end
    
    dep_data_gridded = vol_data_gridded ./ repmat(srf_data_gridded{ii,1},1,1,size(vol_data,2));
    % Now lets remove those limits:
    dep_data_gridded_lims = max(OPT.limiter(1,1),min(dep_data_gridded,OPT.limiter(2,1)));
    dep_data_gridded_lims(isnan(dep_data_gridded)) = NaN; dep_data_gridded = dep_data_gridded_lims;
    % Want to check it out?
    % for t=1:size(vol_data,2); pcolor(lga_data{ii,1}.X_clean,lga_data{ii,1}.Y_clean,squeeze(dep_data_gridded(:,:,t))); shading flat; drawnow; end
    
    disp(['srf file: Loaded succesfully'])
    disp(' ')
    
    % Check if all the times are identical:
    if min(size(unique([size(sal_tim_data{ii,1},1) size(tem_tim_data{ii,1},1) size(vol_tim_data{ii,1},1)])) == [1,1]) == 0
        error('Different time axis found for the sal, tem and vol files, please check this')
    end
    if min(size(unique([sal_tim_dt{ii,1} tem_tim_dt{ii,1} vol_tim_dt{ii,1}])) == [1,1]) == 0
        error('Different output timesteps found for the sal, tem and vol files, please check this')
    end
    
    precision = 10^-6; % sub second precision
    if max(max(abs(diff([sal_tim_data{ii,1} tem_tim_data{ii,1} vol_tim_data{ii,1}],2)))) > precision
        error('Different time axis found for the sal, tem and vol files, please check this')
    else
        % One uniform time axis availabe:
        time_ax = sal_tim_data{ii,1}; % datenum
        time_dt = sal_tim_dt{ii,1}; % in hours
    end
    
    % Check if all the output is of identical size:
    if ~isempty(find(diff([size(sal_data_gridded); size(tem_data_gridded); size(vol_data_gridded); size(dep_data_gridded)])~=0))
        error('Output grid appear of different sizes, strange error, please contact the developer with error code: 1553684634563');
    end
    
    % All data was loaded, all time axis are identical, now lets determine the averaging:
    if isstr(OPT.averaging)
        if strcmp(OPT.averaging,'all')
            sep_inds          = ones(size(time_ax));
            output_names_time = {''};
        elseif strcmp(OPT.averaging,'yearly')
            sep_inds          = year(time_ax) - min(year(time_ax)) + 1;
            output_names_time = cellstr([repmat('_',size(unique(year(time_ax)),1),1) num2str(unique(year(time_ax)))]);
        elseif strcmp(OPT.averaging,'monthly')
            sep_inds          = month(time_ax) + ((year(time_ax) - min(year(time_ax)))*12) - month(time_ax(1,1)) + 1;
            output_names_time = cellstr(datestr(datenum(year(time_ax(1,1)),month(time_ax(1,1)):month(time_ax(1,1))+max(sep_inds)-1,1),'_yyyy_mmm'));
        elseif strcmp(OPT.averaging,'weekly')
            sep_inds          = floor((time_ax - time_ax(1))./7)+1;
            output_names_time = cellstr([repmat('_week_',length(unique(sep_inds)),1) num2str(unique(sep_inds),['%0' num2str(length(num2str(max(sep_inds)))) '.0f'])]);
        elseif strcmp(OPT.averaging,'daily')
            sep_inds          = floor((time_ax - time_ax(1))./1)+1;
            output_names_time = cellstr([repmat('_day_',length(unique(sep_inds)),1) num2str(unique(sep_inds),['%0' num2str(length(num2str(max(sep_inds)))) '.0f'])]);
        end
    elseif isnumeric(OPT.averaging)
        sep_inds              = nan(size(time_ax));
        sep_inds(find((time_ax >= OPT.averaging(1,1)) & (time_ax <= OPT.averaging(2,1)))) = 1;
        if isempty(find(sep_inds == 1))
            error(['No data found between ' datestr(OPT.averaging(1,1),'dd-mm-''yy') ' and ' datestr(OPT.averaging(2,1),'dd-mm-''yy') ' as the com-*.* file set time-axis runs from ' datestr(time_ax(1,1),'dd-mm-''yy') ' till ' datestr(time_ax(end,1),'dd-mm-''yy')]);
        end
        if diff(OPT.averaging) >= 1
            output_names_time = {[datestr(OPT.averaging(1,1),'_yyyy_mm_dd') '_till_' datestr(OPT.averaging(2,1),'yyyy_mm_dd')]};
        else
            output_names_time = {[datestr(OPT.averaging(1,1),'_yyyy_mm_dd_HH_MM_SS') '_till_' datestr(OPT.averaging(2,1),'yyyy_mm_dd_HH_MM_SS')]}
        end
    else
        error('Unexpected error, contact the developer with error code: 3265479612348')
    end
    
    if OPT.write_to_file
        disp(['Writing ' num2str(max(sep_inds)) ' LaVeg input files:']);
        disp(' ');
    else
        disp(['Saving data for ' num2str(max(sep_inds)) ' LaVeg input files:']);
        disp(' ');
    end
    
    cur_output_folder = [OPT.output_folder filesep com_files{ii,1}(1,max(strfind(com_files{ii,1},filesep))+5:end)];
    if OPT.write_to_file
        try
            mkdir(cur_output_folder)
        catch
            error(['Matlab was unable to create the output folder ' cur_output_folder])
        end
    end
    
    csv_data.(['domain_number_' num2str(ii,'%03.0f')]).domain_name = com_files{ii,1}(1,max(strfind(com_files{ii,1},filesep))+5:end);
    if OPT.write_to_file
        csv_data.(['domain_number_' num2str(ii,'%03.0f')]).location = cur_output_folder;
    end
    csv_data.(['domain_number_' num2str(ii,'%03.0f')]).format = ['Cell_ID,M,N,X,Y,mean(dep),std(dep),mean(sal),std(sal),mean(tem),std(tem)'];
    csv_data.(['domain_number_' num2str(ii,'%03.0f')]).number_of_csv = max(sep_inds);
    
    for lf = 1:max(sep_inds)
        % The separate csv-files with LaVeg input will contain the following information:
        %
        % CELLID,m,n,X,Y,mean(dep),std(dep),mean(sal),std(sal),mean(tem),std(tem)
        %
        
        if OPT.write_to_file
            cur_file = [cur_output_folder filesep 'LaVeg_input' output_names_time{lf,1} '.csv'];
        end
        
        if OPT.write_to_file
            disp(['Saving csv file ' num2str(lf) '/' num2str(max(sep_inds)) ': .' filesep com_files{ii,1}(1,max(strfind(com_files{ii,1},filesep))+5:end) filesep 'LaVeg_input' output_names_time{lf,1} '.csv']);
        else
            disp(['Saving csv data (not to file) ' num2str(lf) '/' num2str(max(sep_inds)) ': .' filesep com_files{ii,1}(1,max(strfind(com_files{ii,1},filesep))+5:end) filesep 'LaVeg_input' output_names_time{lf,1}]);
        end
        
        cur_time_inds = find(sep_inds==lf);
        
        % csv_text = cellstr(repmat(' ',prod(size(lga_data{ii,1}.X)),1));
        
        csv_data.(['domain_number_' num2str(ii,'%03.0f')]).(['data_for_csv_file_LaVeg_input' output_names_time{lf,1}]) = NaN(prod(size(lga_data{ii,1}.X)),11);
        
        tel1 = 0; tel2 = 0;
        for mm = 1:size(sal_data_gridded,1)
            for nn = 1:size(sal_data_gridded,2)
                tel1 = tel1 + 1;
                if lga_data{ii,1}.Index(mm,nn) > 0
                    tel2 = tel2 + 1;
                    cur_sal = squeeze(sal_data_gridded(mm,nn,cur_time_inds));
                    cur_tem = squeeze(tem_data_gridded(mm,nn,cur_time_inds));
                    cur_dep = squeeze(dep_data_gridded(mm,nn,cur_time_inds));
                    % Want to check it out?:
                    % figure; hold on; subplot(3,1,1); plot(time_ax(cur_time_inds),cur_sal,'k'); title(['Salinity at cell (' num2str(mm) ',' num2str(nn) ')']); axis tight; datetickzoom('x','dd-mm-''yy','keepticks','keeplimits'); grid on; subplot(3,1,2); plot(time_ax(cur_time_inds),cur_tem,'k'); title(['Temperature at cell (' num2str(mm) ',' num2str(nn) ')']); axis tight; datetickzoom('x','dd-mm-''yy','keepticks','keeplimits'); grid on; subplot(3,1,3); plot(time_ax(cur_time_inds),cur_dep,'k'); title(['Depth at cell (' num2str(mm) ',' num2str(nn) ')']); axis tight; datetickzoom('x','dd-mm-''yy','keepticks','keeplimits'); grid on; 
                    
                    % CELLID,m,n,X,Y,mean(dep),std(dep),mean(sal),std(sal),mean(tem),std(tem):
                    csv_data.(['domain_number_' num2str(ii,'%03.0f')]).(['data_for_csv_file_LaVeg_input' output_names_time{lf,1}])(tel2,:) = [tel1 mm nn lga_data{ii,1}.X(mm,nn) lga_data{ii,1}.Y(mm,nn) mean(cur_dep) std(cur_dep) mean(cur_sal) std(cur_sal) mean(cur_tem) std(cur_tem)];
                end
            end
        end
        csv_data.(['domain_number_' num2str(ii,'%03.0f')]).(['data_for_csv_file_LaVeg_input' output_names_time{lf,1}]) = csv_data.(['domain_number_' num2str(ii,'%03.0f')]).(['data_for_csv_file_LaVeg_input' output_names_time{lf,1}])(1:tel2,:);
        
        if OPT.write_to_file
            dlmwrite(cur_file,csv_data.(['domain_number_' num2str(ii,'%03.0f')]).(['data_for_csv_file_LaVeg_input' output_names_time{lf,1}]),'delimiter',OPT.separator,'precision','%20.10g');
        end
    end
    if ii < size(com_files,1)
        disp(' ');
    end
end