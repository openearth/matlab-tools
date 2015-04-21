function LAVEG_input_from_D3D_com_files(com_files,varargin)
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
% 'output_folder'  The keyword 'output_folder' sets the output folder where
%                  the LaVeg input files are written to. It is to be
%                  specified in a single line char string. By default, this
%                  equals pwd (the current working directory)
%
% 'create_folder'  If you wish to create the output folder that you've
%                  specified with the keyword 'output_folder', set this
%                  keyword to true (default is false)
%
% OUTPUT VARIABLES:
%
% No output variables are used within this script
%
% Contact Freek Scheel (freek.scheel@deltares.nl) if bugs are encountered
%              
% See also: waqfil delwaq fread

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

OPT.output_folder = pwd;
OPT.create_folder = false;

OPT = setproperty(OPT,varargin);

%% Check all the input
%

% Check the create_folder keyword first:
if ~islogical(OPT.create_folder)
    error('Please set the keyword ''create_folder'' to either true or false')
end

% Check the output_folder keyword second:
if isstr(OPT.output_folder)
    if exist(OPT.output_folder,'dir')~=7
        if OPT.create_folder
            try
                mkdir(OPT.output_folder)
            catch
                error(['Matlab was unable to create the folder ' OPT.output_folder])
            end
        else
            error(['The specified output folder does not exist, if you would like to create it, simply call: mkdir(''' OPT.output_folder ''') and run this script again']);
        end
    end
else
    error('Please specify the ''output_folder'' keyword in a single line char string')
end

% Finally, check the com_files input:

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
end

%% Load the data:
%

% All input is correct, lets all the data from the different files:
for ii=1:size(com_files,1)
    lga_files{ii,1} = [com_files{ii,1} '.lga'];
    cco_files{ii,1} = [com_files{ii,1} '.cco'];
    sal_files{ii,1} = [com_files{ii,1} '.sal'];
    tem_files{ii,1} = [com_files{ii,1} '.tem'];
    vol_files{ii,1} = [com_files{ii,1} '.vol'];
    srf_files{ii,1} = [com_files{ii,1} '.srf'];
    
    % Load the lga data:
    try
        lga_data{ii,1} = delwaq('open',lga_files{ii,1});
    catch err
        error(['Unable to load lga file: ' lga_files{ii,1} ' with message: ' err.message])
    end
    % And load the sal data:
    try
        figure; tel = 0; for t = [1 10 50 100 1000 2905]; tel = tel+1;
        X   = lga_data{1,1}.X; X(find(round(X)==-1000))=NaN; X(lga_data{1,1}.Index<0)=NaN;
        Y   = lga_data{1,1}.Y; Y(find(round(Y)==-1000))=NaN; Y(lga_data{1,1}.Index<0)=NaN;
        
        sal_info{ii,1} = waqfil('open',sal_files{ii,1},lga_data{ii,1}.NoSeg);
        
        fid = fopen(sal_files{ii,1},'r');
        sal_data = fread(fid,[sal_info{ii,1}.NVals+1 sal_info{ii,1}.NTimes+0],'float32');
        fclose(fid);
        
        sal = nan(size(lga_data{1,1}.X));
        for jj=1:size(X,1)
            for kk=1:size(X,2)
                if lga_data{1,1}.Index(jj,kk)>=0
                    sal(jj,kk) = sal_data(lga_data{1,1}.Index(jj,kk)+1,t);
                end
            end
        end
        subplot(2,3,tel); pcolor(X,Y,sal); shading flat; colorbar; axis equal; axis tight; title(['t = ' num2str(t)]); set(gca,'XTick',[],'YTick',[]); grid on;
        end; set(gcf,'color','w')
        
        sal_data = waqfil('read',sal_info{ii,1},lga_data{ii,1}.NoSeg);
        test = waqfil('read',sal_info{ii,1},lga_data{ii,1}.NoSeg);
    catch err
        error(['Unable to load sal file: ' sal_files{ii,1} ' with message: ' err.message])
    end
    
    
    disp([num2str(ii,'%02.0f') '/' num2str(size(com_files,1),'%02.0f') ' - All files present for ''' com_files{ii,1} '.*''.'])
    
end
disp(' ');

% The csv-files with LaVeg input should contain the following information:
%
% year,CELLID,m,n,X,Y,STDEV_whole_TotalDepth,MEAN_whole_Salinity,MEAN_summer_TotalDepth,Mean_summer_Salinity,MEAN_summer_Temp
%















