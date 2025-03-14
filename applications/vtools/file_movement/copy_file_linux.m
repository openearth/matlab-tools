%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20080 $
%$Date: 2025-03-06 10:26:14 +0100 (Thu, 06 Mar 2025) $
%$Author: chavarri $
%$Id: copy_folder_linux.m 20080 2025-03-06 09:26:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/copy_folder_linux.m $
%
%Write command to copy folder in linux
%
%E.G.:
% copy_folder_linux('p:\studenten-riv\03_Work\220615_Yeditha','p:\studenten-riv-2024\03_Work\220615_Yeditha','exclude',{'*_map.nc','*_his.nc','*_rst.nc','*.dat','*.svn-base','*.svn'})

function copy_file_linux(fpath_o,fpath_d,varargin)

%% PARSE

% parin=inputParser;
% 
% addOptional(parin,'top_folder',true);
% addOptional(parin,'exclude',cell(1,1));
% 
% parse(parin,varargin{:});
% 
% top_folder=parin.Results.top_folder;
% exclude=parin.Results.exclude;

%% CALC

if ~isfile(fpath_o)
    error('No file here: %s',fpath_o);
end

if isfolder(fpath_d)
    [~,fname,fext]=fileparts(fpath_o);
    fpath_d=fullfile(fpath_d,sprintf('%s%s',fname,fext));
end

sprintf('cp %s %s',linuxify(fpath_o),linuxify(fpath_d))

end %function
